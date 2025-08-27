param sqlLogicalServer object
@secure()
param sqlPassword string

resource primaryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = if (contains(sqlLogicalServer, 'primaryUserAssignedIdentity')) {
  name: sqlLogicalServer.primaryUserAssignedIdentity.name
  scope: resourceGroup(sqlLogicalServer.primaryUserAssignedIdentity.?subscriptionId ?? subscription().subscriptionId, sqlLogicalServer.primaryUserAssignedIdentity.resourceGroupName)
}

resource sqlLogicalServerRes 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlLogicalServer.name
  location: resourceGroup().location
  tags: sqlLogicalServer.?tags ?? {}
  identity: {
    type: sqlLogicalServer.?enableSystemAssignedIdentity ?? false
      ? contains(sqlLogicalServer, 'userAssignedIdentities')
        ? 'SystemAssigned,UserAssigned'
        : 'SystemAssigned'
      : contains(sqlLogicalServer, 'userAssignedIdentities')
        ? 'UserAssigned'
        : 'None'
    userAssignedIdentities: contains(sqlLogicalServer, 'userAssignedIdentities')
      ? toObject(
          map(
            sqlLogicalServer.userAssignedIdentities!,
            userAssignedIdentity =>
            resourceId(
              userAssignedIdentity.?subscriptionId ?? subscription().subscriptionId,
              userAssignedIdentity.resourceGroupName,
              'Microsoft.ManagedIdentity/userAssignedIdentities',
              userAssignedIdentity.name
            )
          ),
          identity =>
          identity, identity => {}
        )
      : null
  }
  properties: {
    administratorLogin: sqlLogicalServer.authentication.type =~ 'SQLOnly' || sqlLogicalServer.authentication.type =~ 'EntraAndSQL'
      ? sqlLogicalServer.authentication.sqlLogin.username
      : null
    administratorLoginPassword: sqlLogicalServer.authentication.type =~ 'SQLOnly' || sqlLogicalServer.authentication.type =~ 'EntraAndSQLn' ? sqlPassword : null
    administrators: sqlLogicalServer.authentication.type =~ 'EntraOnly' || sqlLogicalServer.authentication.type =~ 'EntraAndSQL' ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: sqlLogicalServer.authentication.type =~ 'EntraOnly'
      login: sqlLogicalServer.authentication.entraLogin.principalDisplayName
      principalType: sqlLogicalServer.authentication.entraLogin.principalType
      sid: sqlLogicalServer.authentication.entraLogin.principalId
      tenantId: sqlLogicalServer.authentication.entraLogin.?tenantId ?? subscription().tenantId
    } : null
    minimalTlsVersion: sqlLogicalServer.?minimumTlsVersion ?? '1.2'
    publicNetworkAccess: sqlLogicalServer.?publicNetworkAccess ?? 'Enabled'
    restrictOutboundNetworkAccess: sqlLogicalServer.?restrictOutboundNetworkAccess ?? 'Enabled'
    primaryUserAssignedIdentityId: contains(sqlLogicalServer, 'primaryUserAssignedIdentity') ? primaryUserAssignedIdentity.id : null
  }
}

resource entraAuthentication 'Microsoft.Sql/servers/administrators@2024-05-01-preview' = if (sqlLogicalServer.authentication.type =~ 'EntraOnly' || sqlLogicalServer.authentication.type =~ 'EntraAndSQL') {
  name: 'ActiveDirectory'
  parent: sqlLogicalServerRes
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlLogicalServer.authentication.entraLogin.principalDisplayName
    sid: sqlLogicalServer.authentication.entraLogin.principalId
    tenantId: sqlLogicalServer.authentication.entraLogin.?tenantId ?? subscription().tenantId
  }
}

resource connectionPolicy 'Microsoft.Sql/servers/connectionPolicies@2024-05-01-preview' = {
  name: 'default'
  parent: sqlLogicalServerRes
  dependsOn: [
    entraAuthentication
  ]
  properties: {
    connectionType: sqlLogicalServer.?connectionPolicy ?? 'Default'
  }
}

var defaultSqlLogicalServerArrays = {
  diagnosticSettings: []
  databases: []
}

// Diagnostic settings for SQL logical server are assigned at master database resource which is created by default
resource masterDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' existing = {
  name: 'master'
  parent: sqlLogicalServerRes
}

resource logAnalyticsWorkspaces 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = [for (diagnosticSetting, i) in union(defaultSqlLogicalServerArrays, sqlLogicalServer).diagnosticSettings: if (diagnosticSetting.destinationType == 'LogAnalytics') {
  name: diagnosticSetting.logAnalytics.name
  scope: resourceGroup(diagnosticSetting.logAnalytics.?subscriptionId ?? subscription().subscriptionId, diagnosticSetting.logAnalytics.resourceGroupName)
}]

resource storageAccounts 'Microsoft.Storage/storageAccounts@2024-01-01' existing = [for (diagnosticSetting, i) in union(defaultSqlLogicalServerArrays, sqlLogicalServer).diagnosticSettings: if (diagnosticSetting.destinationType == 'StorageAccount') {
  name: diagnosticSetting.storageAccount.name
  scope: resourceGroup(diagnosticSetting.storageAccount.?subscriptionId ?? subscription().subscriptionId, diagnosticSetting.storageAccount.resourceGroupName)
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (diagnosticSetting, i) in union(defaultSqlLogicalServerArrays, sqlLogicalServer).diagnosticSettings: {
  name: diagnosticSetting.name
  scope: masterDatabase
  properties: {
    eventHubAuthorizationRuleId: null
    eventHubName: null
    workspaceId: diagnosticSetting.destinationType == 'LogAnalytics' ? logAnalyticsWorkspaces[i].id : null
    logAnalyticsDestinationType: null
    storageAccountId: diagnosticSetting.destinationType == 'StorageAccount' ? storageAccounts[i].id : null
    marketplacePartnerId: null
    serviceBusRuleId: null
    logs: contains(diagnosticSetting, 'enabledLogs') ? map(diagnosticSetting.enabledLogs, log => {
      enabled: true
      category: log
    }) : []
    metrics: contains(diagnosticSetting, 'enabledMetrics') ? map(diagnosticSetting.enabledMetrics, metrics => {
      enabled: true
      category: metrics
    }) : []
  }
}]


module databases 'database.bicep' = [for (database, i) in union(defaultSqlLogicalServerArrays, sqlLogicalServer).databases: {
  name: 'database-${uniqueString(sqlLogicalServerRes.name)}-${i}'
  params: {
    database: database
    sqlLogicalServerName: sqlLogicalServerRes.name
  }
}]

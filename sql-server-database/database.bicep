param database object
@secure()
param sqlLogicalServerName string

resource sqlLogicalServer 'Microsoft.Sql/servers@2024-05-01-preview' existing = {
  name: sqlLogicalServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  name: database.name
  parent: sqlLogicalServer
  location: resourceGroup().location
  tags: database.?tags ?? {}
  identity: {
    type: contains(database, 'userAssignedIdentities')
      ? 'UserAssigned'
      : 'None'
    userAssignedIdentities: contains(database, 'userAssignedIdentities')
      ? toObject(
          map(
            database.userAssignedIdentities!,
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
  sku: {
    name: database.skuName
    capacity: database.skuCapacity
    family: last(split(database.skuName, '_'))
  }
  properties: {
    createMode: null
    zoneRedundant: database.?zoneRedundant ?? false
    availabilityZone: contains(database, 'availabilityZone') ? string(database.availabilityZone) : 'NoPreference'
    collation: database.?collation ?? 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: startsWith(database.skuName, 'HS_') ? -1 : database.dataMaxSize == 0 ? 0 : database.dataMaxSize * 1024 * 1024 * 1024
    requestedBackupStorageRedundancy: database.?backup.?storageRedundancy ?? 'Geo'
  }
}

resource transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  name: 'current'
  parent: sqlDatabase
  properties: {
    state: database.?dataEncryption ?? 'Enabled'
  }
}

resource backupShortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2024-05-01-preview' = {
  name: 'default'
  parent: sqlDatabase
  dependsOn: [
    transparentDataEncryption
  ]
  properties: {
    retentionDays: database.?backup.?shortTerm.?retention ?? 7
    // Not applicable for Hyperscale SKUs so set value to null
    diffBackupIntervalInHours: startsWith(database.skuName, 'HS_')
      ? null
      : database.skuName =~ 'Standard' || database.skuName =~ 'Premium'
        ? database.?backup.?shortTerm.?differentialBackupInterval ?? 24
        : database.?backup.?shortTerm.?differentialBackupInterval ?? 12
  }
}

resource backupLongTermRetention 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2024-05-01-preview' = if (contains(database, 'backup') ? contains(database.backup, 'longTerm') : false) {
  name: 'default'
  parent: sqlDatabase
  dependsOn: [
    transparentDataEncryption
    backupShortTermRetention
  ]
  properties: {
    weeklyRetention: database.backup.longTerm.weeklyRetention
    monthlyRetention: database.backup.longTerm.monthlyRetention
    yearlyRetention: database.backup.longTerm.yearlyRetention
    weekOfYear: database.backup.longTerm.weekOfYear
  }
}

var defaultDatabaseArrays = {
  diagnosticSettings: []
  dataCollectionRuleAssociations: []
}

resource logAnalyticsWorkspaces 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = [for (diagnosticSetting, i) in union(defaultDatabaseArrays, database).diagnosticSettings: if (diagnosticSetting.destinationType == 'LogAnalytics') {
  name: diagnosticSetting.logAnalytics.name
  scope: resourceGroup(diagnosticSetting.logAnalytics.?subscriptionId ?? subscription().subscriptionId, diagnosticSetting.logAnalytics.resourceGroupName)
}]

resource storageAccounts 'Microsoft.Storage/storageAccounts@2024-01-01' existing = [for (diagnosticSetting, i) in union(defaultDatabaseArrays, database).diagnosticSettings: if (diagnosticSetting.destinationType == 'StorageAccount') {
  name: diagnosticSetting.storageAccount.name
  scope: resourceGroup(diagnosticSetting.storageAccount.?subscriptionId ?? subscription().subscriptionId, diagnosticSetting.storageAccount.resourceGroupName)
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (diagnosticSetting, i) in union(defaultDatabaseArrays, database).diagnosticSettings: {
  name: diagnosticSetting.name
  scope: sqlDatabase
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

resource dataCollectionRules 'Microsoft.Insights/dataCollectionRules@2023-03-11' existing = [for dataCollectionRuleAssociation in union(defaultDatabaseArrays, database).dataCollectionRuleAssociations: {
  name: dataCollectionRuleAssociation.dataCollectionRule.name
  scope: resourceGroup(dataCollectionRuleAssociation.dataCollectionRule.?subscriptionId ?? subscription().subscriptionId, dataCollectionRuleAssociation.dataCollectionRule.resourceGroup)
}]

resource dataCollectionRuleAssociations 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = [for (dataCollectionRuleAssociation, i) in union(defaultDatabaseArrays, database).dataCollectionRuleAssociations: {
  name: dataCollectionRuleAssociation.name
  scope: sqlDatabase
  properties: {
    dataCollectionRuleId: dataCollectionRules[i].id
    description: dataCollectionRuleAssociation.?description ?? null
    dataCollectionEndpointId: null
  }
}]

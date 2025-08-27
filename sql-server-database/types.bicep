@export()
type resourceGroup = {
  @description('The name of the resource group.')
  @minLength(1)
  @maxLength(90)
  name: string
  @description('The Azure location of the resource group and the resources in it.')
  location: string
  @description('The tags to be applied to the resource group.')
  tags: tags?
  @description('SQL logical server configuration.')
  sqlLogicalServer: sqlLogicalServer?
}

type sqlLogicalServer = {
  @description('The name of the SQL logical server.')
  @minLength(1)
  @maxLength(63)
  name: string
  @description('Tags to be applied to the SQL logical server.')
  tags: tags?
  @description('Enables the system assigned identity for the SQL Logical Server. Default value is false.')
  enableSystemAssignedIdentity: bool?
  @description('User assigned identities for the SQL Logical Server.')
  userAssignedIdentities: userAssignedIdentity[]?
  @description('Configures minimum TLS version. Default value is 1.2.')
  minimumTlsVersion: '1.0' | '1.1' | '1.2' | '1.3' | 'None'?
  @description('Configures public network access. Default value is Enabled.')
  publicNetworkAccess: 'Disabled' | 'Enabled' | 'SecuredByPerimeter'?
  @description('Whether or not to restrict outbound network access for this server. Default value is Enabled.')
  restrictOutboundNetworkAccess: 'Enabled' | 'Disabled'?
  @description('The primary user assigned identity for the SQL logical server.')
  primaryUserAssignedIdentity: userAssignedIdentity?
  @description('The authentication type to be used to login to the SQL logical server.')
  authentication: authentication
  @description('The connection policy to be used for the SQL logical server. Default value is Default.')
  connectionPolicy: 'Default' | 'Proxy' | 'Redirect'?
  @description('Diagnostic settings to configure.')
  diagnosticSettings: diagnosticSetting[]?
  @description('The SQL databases to be created.')
  databases: database[]?
}

@discriminator('type')
type authentication = authenticationEntra | authenticationSQL | authenticationEntraAndSQL

type authenticationEntra = {
  @description('The type of authentication.')
  type: 'EntraOnly'
  @description('The Microsoft Entra login.')
  entraLogin: entraLogin
}

type authenticationSQL = {
  @description('The type of authentication.')
  type: 'SQLOnly'
  @description('The SQL login credentials.')
  sqlLogin: sqlLogin
}

type authenticationEntraAndSQL = {
  @description('The type of authentication.')
  type: 'EntraAndSQL'
  @description('The SQL login credentials.')
  sqlLogin: sqlLogin
  @description('The Microsoft Entra login.')
  entraLogin: entraLogin
}

type sqlLogin = {
  @description('The user name of the SQL login.')
  username: string
  @description('The password of the SQL login stored as secret in Key Vault.')
  password: password
}

type entraLogin = {
  @description('The display name of Microsoft Entra user, group or application.')
  principalDisplayName: string
  @description('Microsoft Entra object ID of the user, group or application.')
  principalId: string
  @description('The type of the principal.')
  principalType: 'User' | 'Group' | 'Application'
  @description('The tenant ID of the Microsoft Entra user, group or application. Default value is the tenant of the SQL logical server.')
  tenantId: string?
}

type password = {
  @description('The subscription ID where the Key Vault is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the Key Vault is located.')
  resourceGroupName: string
  @description('The name of the Key Vault.')
  name: string
  @description('The name of the secret in the Key Vault.')
  secretName: string
}

type database = {
  @description('The name of the database.')
  name: string
  @description('Tags to be applied to the SQL logical server.')
  tags: tags?
  @description('User assigned identities for the SQL Logical Server.')
  userAssignedIdentities: userAssignedIdentity[]?
  @description('The SKU name.')
  skuName: ('GP_Gen5' | 'GP_Fsv2' | 'BC_Gen5' | 'GP_S_Gen5' | 'HS_Gen5' | 'HS_S_Gen5' | 'HS_PRMS' | 'HS_MOPRMS' | 'HS_DC' | 'GP_DC' | 'Standard' | 'Premium' )
  @description('The SKU capacity. DTU for DTU-based databases, number of cores for vCore-based databases.')
  skuCapacity: int
  @description('Enables zone redundancy for the database. Default value is false.')
  zoneRedundant: bool?
  @description('The availability zone for the database. Default value is NoPreference.')
  availabilityZone: 1 | 2 | 3?
  @description('The collation for the database. Default value is SQL_Latin1_General_CP1_CI_AS.')
  collation: string?
  @description('Database maximum size in GB. For Hyperscale databases you can set it to 0.')
  dataMaxSize: int
  @description('The backup configuration.')
  backup: backup?
  @description('Enables transparent data encryption for the database. Default value is Enabled.')
  dataEncryption: 'Enabled' | 'Disabled'?
  @description('Diagnostic settings to configure.')
  diagnosticSettings: diagnosticSetting[]?
  @description('Associates data collection rules to the database.')
  dataCollectionRuleAssociations: dataCollectionRuleAssociation[]?
}

type backup = {
  @description('The backup storage redundancy. Default value is Geo.')
  storageRedundancy: 'Geo' | 'GeoZone' | 'Local' | 'Zone'?
  @description('Configures short term backup.')
  shortTerm: shortTermBackup?
  @description('Configures long term backup.')
  longTerm: longTermBackup?
}

type shortTermBackup = {
  @description('Short term backup retention in days. Default value is 7.')
  retention: 7 | 14 | 21 | 28 | 35?
  @description('''The differential backup interval in hours.
    Hyperscale SKUs does not support this setting.
    Default value is 24 for DTU based SKUs and 12 for vCore based SKUs.''')
  differentialBackupInterval: 12 | 24?
}

type longTermBackup = {
  @description('Retention of weekly backups. The value is in ISO 8601 format.')
  weeklyRetention: string
  @description('Retention of monthly backups. The value is in ISO 8601 format')
  monthlyRetention: string
  @description('Retention of yearly backups. The value is in ISO 8601 format.')
  yearlyRetention: string
  @description('The week of year to take the yearly backup retention.')
  @minValue(1)
  @maxValue(52)
  weekOfYear: int
}

type dataCollectionRuleAssociation = {
  @description('Data collection rule association name.')
  name: string
  @description('Description for the association.')
  description: string?
  @description('Data collection rule.')
  dataCollectionRule: dataCollectionRule
}

type dataCollectionRule = {
  @description('The subscription ID where the data collection rule is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the data collection rule is located.')
  resourceGroupName: string
  @description('The name of the data collection rule.')
  name: string
}

type userAssignedIdentity = {
  @description('The subscription ID where the user assigned identity is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the user assigned identity is located.')
  resourceGroupName: string
  @description('The name of the user assigned identity.')
  name: string
}

@discriminator('destinationType')
type diagnosticSetting = diagnosticSettingLogAnalytics | diagnosticSettingStorageAccount

type diagnosticSettingLogAnalytics = {
  @description('The name of the diagnostic setting.')
  name: string
  @description('The type of destination for diagnostic settings.')
  destinationType: 'LogAnalytics'
  @description('The Log Analytics workspace to send logs and metrics to')
  logAnalytics: logAnalytics
  @description('The metrics to be enabled.')
  enabledMetrics: ('Basic' | 'InstanceAndAppAdvanced' | 'WorkloadManagement')[]?
  @description('The logs to be enabled.')
  enabledLogs: ('SQLInsights' | 'AutomaticTuning' | 'QueryStoreRuntimeStatistics' | 'QueryStoreWaitStatistics' | 'Errors'
    | 'DatabaseWaitStatistics' | 'Timeouts' | 'Blocks' | 'Deadlocks' | 'DevOpsOperationsAudit' | 'SQLSecurityAuditEvents')[]?
}

type logAnalytics = {
  @description('The subscription ID where the Log Analytics workspace is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the Log Analytics workspace is located.')
  resourceGroupName: string
  @description('The name of the Log Analytics workspace.')
  name: string

}

type diagnosticSettingStorageAccount = {
  @description('The name of the diagnostic setting.')
  name: string
  @description('The type of destination for diagnostic settings.')
  destinationType: 'StorageAccount'
  @description('The storage account to send logs and metrics to.')
  storageAccount: storageAccount
  @description('The metrics to be enabled.')
  enabledMetrics: ('Basic' | 'InstanceAndAppAdvanced' | 'WorkloadManagement')[]?
  @description('The logs to be enabled.')
  enabledLogs: ('SQLInsights' | 'AutomaticTuning' | 'QueryStoreRuntimeStatistics' | 'QueryStoreWaitStatistics' | 'Errors'
    | 'DatabaseWaitStatistics' | 'Timeouts' | 'Blocks' | 'Deadlocks' | 'DevOpsOperationsAudit' | 'SQLSecurityAuditEvents')[]?
}

type storageAccount = {
  @description('The subscription ID where the storage account is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the storage account is located.')
  resourceGroupName: string
  @description('The name of the storage account.')
  name: string
}

type tags = {
  @description('The tag value.')
  *: string
}

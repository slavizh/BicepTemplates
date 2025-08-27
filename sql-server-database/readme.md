# Bicep Schema Documentation

This document describes the schema for the SQL Server Database Bicep deployment. All parameters and types are extracted from the Bicep files and presented in a structured format.

## Parameters

| Name           | Type         | Required | Description |
|----------------|--------------|----------|-------------|
| [resourceGroup](#resourcegroup) | [resourceGroup](#resourcegroup) | Yes      | Resource group configuration. |

---

## Types

### <a name="resourcegroup"></a>resourceGroup
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| name             | string       | Yes      | The name of the resource group. |
| location         | string       | Yes      | The Azure location of the resource group and the resources in it. |
| tags             | [tags](#tags) | No       | The tags to be applied to the resource group. |
| sqlLogicalServer | [sqlLogicalServer](#sqllogicalserver) | No       | SQL logical server configuration. |

---

### <a name="sqllogicalserver"></a>sqlLogicalServer
| Property                   | Type         | Required | Description |
|----------------------------|--------------|----------|-------------|
| name                       | string       | Yes      | The name of the SQL logical server. |
| tags                       | [tags](#tags) | No       | Tags to be applied to the SQL logical server. |
| enableSystemAssignedIdentity | bool         | No       | Enables the system assigned identity for the SQL Logical Server. Default value is false. |
| userAssignedIdentities     | [userAssignedIdentity](#userassignedidentity)[] | No       | User assigned identities for the SQL Logical Server. |
| minimumTlsVersion          | string       | No       | Configures minimum TLS version. Default value is 1.2. Allowed values: '1.0', '1.1', '1.2', '1.3', 'None'. |
| publicNetworkAccess        | string       | No       | Configures public network access. Default value is Enabled. Allowed values: 'Disabled', 'Enabled', 'SecuredByPerimeter'. |
| restrictOutboundNetworkAccess | string    | No       | Whether or not to restrict outbound network access for this server. Default value is Enabled. Allowed values: 'Enabled', 'Disabled'. |
| primaryUserAssignedIdentity | [userAssignedIdentity](#userassignedidentity) | No       | The primary user assigned identity for the SQL logical server. |
| authentication             | [authentication](#authentication) | Yes      | The authentication type to be used to login to the SQL logical server. |
| connectionPolicy           | string       | No       | The connection policy to be used for the SQL logical server. Default value is Default. Allowed values: 'Default', 'Proxy', 'Redirect'. |
| diagnosticSettings         | [diagnosticSetting](#diagnosticsetting)[] | No       | Diagnostic settings to configure. |
| databases                  | [database](#database)[] | No       | The SQL databases to be created. |

---

### <a name="authentication"></a>authentication
Discriminator: `type`. Allowed values: 'EntraOnly', 'SQLOnly', 'EntraAndSQL'.

- [authenticationEntra](#authenticationentra)
- [authenticationSQL](#authenticationsql)
- [authenticationEntraAndSQL](#authenticationentraandsql)

#### <a name="authenticationentra"></a>authenticationEntra
| Property     | Type         | Required | Description |
|--------------|--------------|----------|-------------|
| type         | string       | Yes      | The type of authentication. Allowed value: 'EntraOnly'. |
| entraLogin   | [entraLogin](#entralogin) | Yes      | The Microsoft Entra login. |

#### <a name="authenticationsql"></a>authenticationSQL
| Property     | Type         | Required | Description |
|--------------|--------------|----------|-------------|
| type         | string       | Yes      | The type of authentication. Allowed value: 'SQLOnly'. |
| sqlLogin     | [sqlLogin](#sqllogin) | Yes      | The SQL login credentials. |

#### <a name="authenticationentraandsql"></a>authenticationEntraAndSQL
| Property     | Type         | Required | Description |
|--------------|--------------|----------|-------------|
| type         | string       | Yes      | The type of authentication. Allowed value: 'EntraAndSQL'. |
| sqlLogin     | [sqlLogin](#sqllogin) | Yes      | The SQL login credentials. |
| entraLogin   | [entraLogin](#entralogin) | Yes      | The Microsoft Entra login. |

---

### <a name="sqllogin"></a>sqlLogin
| Property     | Type         | Required | Description |
|--------------|--------------|----------|-------------|
| username     | string       | Yes      | The user name of the SQL login. |
| password     | [password](#password) | Yes      | The password of the SQL login stored as secret in Key Vault. |

---

### <a name="entralogin"></a>entraLogin
| Property             | Type         | Required | Description |
|----------------------|--------------|----------|-------------|
| principalDisplayName | string       | Yes      | The display name of Microsoft Entra user, group or application. |
| principalId          | string       | Yes      | Microsoft Entra object ID of the user, group or application. |
| principalType        | string       | Yes      | The type of the principal. Allowed values: 'User', 'Group', 'Application'. |
| tenantId             | string       | No       | The tenant ID of the Microsoft Entra user, group or application. Default value is the tenant of the SQL logical server. |

---

### <a name="password"></a>password
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| subscriptionId   | string       | No       | The subscription ID where the Key Vault is located. Default value is current subscription for deployment. |
| resourceGroupName| string       | Yes      | The name of the resource group where the Key Vault is located. |
| name             | string       | Yes      | The name of the Key Vault. |
| secretName       | string       | Yes      | The name of the secret in the Key Vault. |

---

### <a name="database"></a>database
| Property                   | Type         | Required | Description |
|----------------------------|--------------|----------|-------------|
| name                       | string       | Yes      | The name of the database. |
| tags                       | [tags](#tags) | No       | Tags to be applied to the SQL logical server. |
| userAssignedIdentities     | [userAssignedIdentity](#userassignedidentity)[] | No       | User assigned identities for the SQL Logical Server. |
| skuName                    | string       | Yes      | The SKU name. Allowed values: 'GP_Gen5', 'GP_Fsv2', 'BC_Gen5', 'GP_S_Gen5', 'HS_Gen5', 'HS_S_Gen5', 'HS_PRMS', 'HS_MOPRMS', 'HS_DC', 'GP_DC', 'Standard', 'Premium'. |
| skuCapacity                | int          | Yes      | The SKU capacity. DTU for DTU-based databases, number of cores for vCore-based databases. |
| zoneRedundant              | bool         | No       | Enables zone redundancy for the database. Default value is false. |
| availabilityZone           | int          | No       | The availability zone for the database. Default value is NoPreference. Allowed values: 1, 2, 3. |
| collation                  | string       | No       | The collation for the database. Default value is SQL_Latin1_General_CP1_CI_AS. |
| dataMaxSize                | int          | Yes      | Database maximum size in GB. For Hyperscale databases you can set it to 0. |
| backup                     | [backup](#backup) | No       | The backup configuration. |
| dataEncryption             | string       | No       | Enables transparent data encryption for the database. Default value is Enabled. Allowed values: 'Enabled', 'Disabled'. |
| diagnosticSettings         | [diagnosticSetting](#diagnosticsetting)[] | No       | Diagnostic settings to configure. |
| dataCollectionRuleAssociations | [dataCollectionRuleAssociation](#datacollectionruleassociation)[] | No       | Associates data collection rules to the database. |

---

### <a name="backup"></a>backup
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| storageRedundancy| string       | No       | The backup storage redundancy. Default value is Geo. Allowed values: 'Geo', 'GeoZone', 'Local', 'Zone'. |
| shortTerm        | [shortTermBackup](#shorttermbackup) | No       | Configures short term backup. |
| longTerm         | [longTermBackup](#longtermbackup) | No       | Configures long term backup. |

---

### <a name="shorttermbackup"></a>shortTermBackup
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| retention        | int          | No       | Short term backup retention in days. Default value is 7. Allowed values: 7, 14, 21, 28, 35. |
| differentialBackupInterval | int | No       | The differential backup interval in hours. Hyperscale SKUs does not support this setting. Default value is 24 for DTU based SKUs and 12 for vCore based SKUs. Allowed values: 12, 24. |

---

### <a name="longtermbackup"></a>longTermBackup
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| weeklyRetention  | string       | Yes      | Retention of weekly backups. The value is in ISO 8601 format. |
| monthlyRetention | string       | Yes      | Retention of monthly backups. The value is in ISO 8601 format. |
| yearlyRetention  | string       | Yes      | Retention of yearly backups. The value is in ISO 8601 format. |
| weekOfYear       | int          | Yes      | The week of year to take the yearly backup retention. Allowed values: 1-52. |

---

### <a name="datacollectionruleassociation"></a>dataCollectionRuleAssociation
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| name             | string       | Yes      | Data collection rule association name. |
| description      | string       | No       | Description for the association. |
| dataCollectionRule | [dataCollectionRule](#datacollectionrule) | Yes      | Data collection rule. |

---

### <a name="datacollectionrule"></a>dataCollectionRule
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| subscriptionId   | string       | No       | The subscription ID where the data collection rule is located. Default value is current subscription for deployment. |
| resourceGroupName| string       | Yes      | The name of the resource group where the data collection rule is located. |
| name             | string       | Yes      | The name of the data collection rule. |

---

### <a name="userassignedidentity"></a>userAssignedIdentity
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| subscriptionId   | string       | No       | The subscription ID where the user assigned identity is located. Default value is current subscription for deployment. |
| resourceGroupName| string       | Yes      | The name of the resource group where the user assigned identity is located. |
| name             | string       | Yes      | The name of the user assigned identity. |

---

### <a name="diagnosticsetting"></a>diagnosticSetting
Discriminator: `destinationType`. Allowed values: 'LogAnalytics', 'StorageAccount'.

- [diagnosticSettingLogAnalytics](#diagnosticsettingloganalytics)
- [diagnosticSettingStorageAccount](#diagnosticsettingstorageaccount)

#### <a name="diagnosticsettingloganalytics"></a>diagnosticSettingLogAnalytics
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| name             | string       | Yes      | The name of the diagnostic setting. |
| destinationType  | string       | Yes      | The type of destination for diagnostic settings. Allowed value: 'LogAnalytics'. |
| logAnalytics     | [logAnalytics](#loganalytics) | Yes      | The Log Analytics workspace to send logs and metrics to. |
| enabledMetrics   | string[]     | No       | The metrics to be enabled. Allowed values: 'Basic', 'InstanceAndAppAdvanced', 'WorkloadManagement'. |
| enabledLogs      | string[]     | No       | The logs to be enabled. Allowed values: 'SQLInsights', 'AutomaticTuning', 'QueryStoreRuntimeStatistics', 'QueryStoreWaitStatistics', 'Errors', 'DatabaseWaitStatistics', 'Timeouts', 'Blocks', 'Deadlocks', 'DevOpsOperationsAudit', 'SQLSecurityAuditEvents'. |

#### <a name="loganalytics"></a>logAnalytics
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| subscriptionId   | string       | No       | The subscription ID where the Log Analytics workspace is located. Default value is current subscription for deployment. |
| resourceGroupName| string       | Yes      | The name of the resource group where the Log Analytics workspace is located. |
| name             | string       | Yes      | The name of the Log Analytics workspace. |

#### <a name="diagnosticsettingstorageaccount"></a>diagnosticSettingStorageAccount
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| name             | string       | Yes      | The name of the diagnostic setting. |
| destinationType  | string       | Yes      | The type of destination for diagnostic settings. Allowed value: 'StorageAccount'. |
| storageAccount   | [storageAccount](#storageaccount) | Yes      | The storage account to send logs and metrics to. |
| enabledMetrics   | string[]     | No       | The metrics to be enabled. Allowed values: 'Basic', 'InstanceAndAppAdvanced', 'WorkloadManagement'. |
| enabledLogs      | string[]     | No       | The logs to be enabled. Allowed values: 'SQLInsights', 'AutomaticTuning', 'QueryStoreRuntimeStatistics', 'QueryStoreWaitStatistics', 'Errors', 'DatabaseWaitStatistics', 'Timeouts', 'Blocks', 'Deadlocks', 'DevOpsOperationsAudit', 'SQLSecurityAuditEvents'. |

#### <a name="storageaccount"></a>storageAccount
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| subscriptionId   | string       | No       | The subscription ID where the storage account is located. Default value is current subscription for deployment. |
| resourceGroupName| string       | Yes      | The name of the resource group where the storage account is located. |
| name             | string       | Yes      | The name of the storage account. |

---

### <a name="tags"></a>tags
| Property         | Type         | Required | Description |
|------------------|--------------|----------|-------------|
| *                | string       | No       | The tag value. |

---

## Notes
- All types are linked for easy navigation.
- Enum values are listed in the description for each property.
- Required column is based on the presence of `?` in the type definition.

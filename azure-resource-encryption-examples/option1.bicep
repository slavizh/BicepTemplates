@description('The name of the SQL logical server.')
param sqlServerName string
@description('The subscription ID of the user-assigned identity. Default: current subscription.')
param userAssignedIdentitySubscriptionId string = subscription().subscriptionId
@description('The resource group of the user-assigned identity.')
param userAssignedIdentityResourceGroup string
@description('The name of the user-assigned identity.')
param userAssignedIdentityName string
@description('The principal ID of Microsoft Entra user.')
param entraUserPrincipalId string
@description('The display name of Microsoft Entra user.')
param entraUserDisplayName string
@description('The name of the key vault. If not provided, no CMK encryption is applied.')
param keyVaultName string = ''
@description('The name of the key in the key vault.')
param keyVaultKeyName string = ''
@description('The version of the key in the key vault.')
param keyVaultKeyVersion string = ''


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = {
  name: userAssignedIdentityName
  scope: resourceGroup(userAssignedIdentitySubscriptionId, userAssignedIdentityResourceGroup)
}

resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: sqlServerName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: entraUserDisplayName
      principalType: 'User'
      sid: entraUserPrincipalId
      tenantId: subscription().tenantId
    }
    primaryUserAssignedIdentityId: userAssignedIdentity.id
    keyId: !empty(keyVaultName)
      ? 'https://${toLower(keyVaultName)}${environment().suffixes.keyvaultDns}/keys/${toLower(keyVaultKeyName)}/${keyVaultKeyVersion}'
      : null
  }
}

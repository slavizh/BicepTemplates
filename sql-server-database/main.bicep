targetScope = 'subscription'

import * as inputTypes from 'types.bicep'

@description('Resource group configuration.')
param resourceGroup inputTypes.resourceGroup

resource resourceGroupResource 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroup.name
  location: resourceGroup.location
  tags: resourceGroup.?tags ?? {}
}

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (contains(resourceGroup, 'sqlLogicalServer') && resourceGroup.?sqlLogicalServer.authentication.type =~ 'SQLOnly' || resourceGroup.?sqlLogicalServer.authentication.type =~ 'EntraAndSQL') {
  name: resourceGroup.?sqlLogicalServer.authentication.login.password.name
  scope: az.resourceGroup(resourceGroup.?sqlLogicalServer.authentication.sqlLogin.?subscriptionId ?? subscription().subscriptionId, resourceGroup.?sqlLogicalServer.authentication.sqlLogin.password.resourceGroupName)
}

module sqlLogicalServer 'sql-logical-server.bicep' = if (contains(resourceGroup, 'sqlLogicalServer')) {
  name: 'sqlLogicalServer-${uniqueString(deployment().location)}'
  scope: resourceGroupResource
  params: {
    sqlLogicalServer: resourceGroup.sqlLogicalServer!
    sqlPassword: resourceGroup.?sqlLogicalServer.authentication.type =~ 'SQLOnly' || resourceGroup.?sqlLogicalServer.authentication.type =~ 'EntraAndSQL'
      ? keyVault!.getSecret(resourceGroup.?sqlLogicalServer.authentication.sqlLogin.password.secretName)
      : ''
  }
}

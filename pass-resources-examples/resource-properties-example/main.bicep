type virtualNetworkRuleType = {
  @description('The name of the virtual network rule.')
  name: string
  @description('Ignores missing virtual network service endpoint. Default value: false.')
  ignoreMissingVnetServiceEndpoint: bool?
  @description('The virtual network subnet to be added for the virtual network rule.')
  virtualNetwork: {
    @description('The subscription ID where the virtual network is located. Default value: current subscription for deployment.')
    subscriptionId: string?
    @description('The name of the resource group where the virtual network is located.')
    resourceGroupName: string
    @description('The virtual network name.')
    name: string
    @description('The name of the subnet.')
    subnetName: string
  }
}

@description('The name of the SQL server.')
param sqlServerName string
@description('The user name for the SQL server login.')
param sqlServerUserName string
@description('The password for the SQL server login.')
@secure()
param sqlServerPassword string
@description('Configures virtual network rules for the SQL server.')
param virtualNetworkRule virtualNetworkRuleType?

resource server 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: resourceGroup().location
  properties: {
    administratorLogin: sqlServerUserName
    administratorLoginPassword: sqlServerPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (virtualNetworkRule != null) {
  name: virtualNetworkRule.?virtualNetwork.?name!
  scope: resourceGroup(virtualNetworkRule.?virtualNetwork.?subscriptionId ?? subscription().subscriptionId, virtualNetworkRule.?virtualNetwork.?resourceGroupName!)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = if (virtualNetworkRule != null) {
  name: virtualNetworkRule.?virtualNetwork.?subnetName!
  parent: virtualNetwork
}

resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2024-05-01-preview' = if (virtualNetworkRule != null) {
  name: virtualNetworkRule.?name!
  parent: server
  properties: {
    virtualNetworkSubnetId: subnet.id
    ignoreMissingVnetServiceEndpoint: virtualNetworkRule.?ignoreMissingVnetServiceEndpoint ?? false
  }
}

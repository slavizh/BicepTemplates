
@description('The name of the SQL server.')
param sqlServerName string
@description('The user name for the SQL server login.')
param sqlServerUserName string
@description('The password for the SQL server login.')
@secure()
param sqlServerPassword string
@description('The virtual Network rule name. Requires to configure virtualNetworkSubnetId as well.')
param virtualNetworkRuleName string = ''
@description('Ignores missing virtual network service endpoint. Default value: false.')
param ignoreMissingVnetServiceEndpoint bool = false
@description('The resource ID of the virtual network subnet to be added for the virtual network rule. Requires to configure virtualNetworkRuleName as well.')
param virtualNetworkSubnetId string = ''

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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (!empty(virtualNetworkSubnetId)) {
  name: split(virtualNetworkSubnetId, '/')[8]
  scope: resourceGroup(split(virtualNetworkSubnetId, '/')[2], split(virtualNetworkSubnetId, '/')[4])
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = if (!empty(virtualNetworkSubnetId)) {
  name:  split(virtualNetworkSubnetId, '/')[10]
  parent: virtualNetwork
}

resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2024-05-01-preview' = if (!empty(virtualNetworkSubnetId) && !empty(virtualNetworkRuleName)) {
  name: virtualNetworkRuleName
  parent: server
  properties: {
    virtualNetworkSubnetId: subnet.id
    ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
  }
}

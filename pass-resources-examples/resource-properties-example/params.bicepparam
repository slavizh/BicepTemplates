using 'main.bicep'

param sqlServerName = 'srv00232asfd'
param sqlServerUserName = 'sqla001'
param sqlServerPassword = '<REPLACE-WITH-A-PASSWORD>'
param virtualNetworkRule = {
  name: 'vnetrule001'
  ignoreMissingVnetServiceEndpoint: true
  virtualNetwork: {
    resourceGroupName: '<RESOURCE GROUP NAME>'
    name: '<VIRTUAL NETWORK NAME>'
    subnetName: '<SUBNET NAME>'
  }
}

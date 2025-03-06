using 'main.bicep'

param sqlServerName = 'srv00232asfd'
param sqlServerUserName = 'sqla001'
param sqlServerPassword = '<REPLACE-WITH-A-PASSWORD>'
param virtualNetworkRuleName = 'vnetrule001'
param ignoreMissingVnetServiceEndpoint = true
param virtualNetworkSubnetId = '/subscriptions/<SUBSCRIPTION ID>/resourceGroups/<RESOURCE GROUP NAME>/providers/Microsoft.Network/virtualNetworks/<VIRTUAL NETWORK NAME>/subnets/<SUBNET NAME>'


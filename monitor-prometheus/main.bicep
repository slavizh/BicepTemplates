targetScope = 'subscription'

@description('Resource group for Azure Monitor resources.')
param resourceGroupName string
@description('The location for Azure Monitor resources hat will be created.')
param location string
@description('The name of the Azure Monitor workspace that will be created.')
param monitorWorkspaceName string
@description('The name of the Managed grafana resource hat will be created.')
param grafanaName string
@description('Unique GUID for the role assignment.')
param roleAssignmentGuid string
@description('Full resource ID of the AKS cluster')
param aksResourceId string
@description('The location for the AKS cluster')
param aksLocation string
@description('Resource ID of the action group that will be attached to Prometheus alerts')
param actionGroupResourceId string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: {}
  properties: {}
}

module rgResources 'rg-resources.bicep' = {
  name: 'rgResources'
  scope: rg
  params: {
    monitorWorkspaceName: monitorWorkspaceName
    grafanaName: grafanaName
    roleAssignmentGuid: roleAssignmentGuid
    aksResourceId: aksResourceId
    aksLocation: aksLocation
    actionGroupResourceId: actionGroupResourceId
    location: location
  }
}

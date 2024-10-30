targetScope = 'resourceGroup'

@description('The name of the Azure VM.')
param vmName string

@description('The Azure VM location.')
param vmLocation string

@description('The name of the maintenance configuration assignment.')
param assignmentName string

@description('The subscription ID where the maintenance configuration is located.')
param maintenanceConfigurationSubscriptionId string = subscription().id

@description('The resource group name where the maintenance configuration is located.')
param maintenanceConfigurationResourceGroupName string

@description('The maintenance configuration name.')
param maintenanceConfigurationName string

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-10-01-preview' existing = {
  name: maintenanceConfigurationName
  scope: resourceGroup(maintenanceConfigurationSubscriptionId, maintenanceConfigurationResourceGroupName)
}

resource assignment 'Microsoft.Maintenance/configurationAssignments@2023-10-01-preview' = {
  name: assignmentName
  location: vmLocation
  scope: vm
  properties: {
    maintenanceConfigurationId: maintenanceConfiguration.id
    resourceId: vm.id
  }
}

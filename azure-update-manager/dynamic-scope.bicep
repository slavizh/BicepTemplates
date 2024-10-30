targetScope = 'subscription'

type filterTagOperatorType = 'All' | 'Any'

type tagsFilterType = {
  @description('The values for the tags.')
  *: string[]
}

@description('The name of the maintenance configuration assignment.')
param assignmentName string

@description('The Azure location for filter by. Default value: all locations.')
param filterLocations array = []

@description('The operating systems to filter by. Default value: Linux and Windows.')
@allowed([
  'Linux'
  'Windows'
])
param filterOsTypes array = []

@description('The resource group names to filter by. Default value: all resource groups.')
param filterResourceGroups array = []

@description('The resource types to filter by. Default value: microsoft.hybridcompute/machines and Microsoft.Compute/virtualMachines.')
@allowed([
  'microsoft.hybridcompute/machines'
  'Microsoft.Compute/virtualMachines'
])
param filterResourceTypes array = []

@description('The operator to use when filtering by tags. Default value: All.')
param filterTagOperator filterTagOperatorType = 'All'

@description('Tags and multiple values for each tag to filter by. Default value: any tag.')
param filterTags tagsFilterType = {}

@description('The subscription ID where the maintenance configuration is located.')
param maintenanceConfigurationSubscriptionId string = subscription().id

@description('The resource group name where the maintenance configuration is located.')
param maintenanceConfigurationResourceGroupName string

@description('The maintenance configuration name.')
param maintenanceConfigurationName string

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-10-01-preview' existing = {
  name: maintenanceConfigurationName
  scope: resourceGroup(maintenanceConfigurationSubscriptionId, maintenanceConfigurationResourceGroupName)
}

resource dynamicScope 'Microsoft.Maintenance/configurationAssignments@2023-10-01-preview' = {
  name: assignmentName
  properties: {
    #disable-next-line use-resource-id-functions
    resourceId: subscription().id // The format of the value is /subscriptions/{sub id}
    filter: {
      locations: filterLocations
      osTypes: filterOsTypes
      resourceGroups: filterResourceGroups
      resourceTypes: filterResourceTypes
      tagSettings: {
        tags: filterTags
        filterOperator: filterTagOperator
      }
    }
    maintenanceConfigurationId: maintenanceConfiguration.id
  }
}

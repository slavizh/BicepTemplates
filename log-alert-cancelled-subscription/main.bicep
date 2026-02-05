targetScope = 'resourceGroup'

type logAnalyticsWorkspaceType = {
  @description('The subscription ID of the Log Analytics workspace. Default value: current subscription.')
  subscriptionId: string?
  @description('The resource group name of the Log Analytics workspace.')
  resourceGroupName: string
  @description('The name of the Log Analytics workspace.')
  name: string
}

type identityType = {
  @description('The subscription ID of the identity. Default value: current subscription.')
  subscriptionId: string?
  @description('The resource group name of the identity.')
  resourceGroupName: string
  @description('The name of the identity.')
  name: string
}

type actionGroupType = {
  @description('The subscription ID of the action group. Default value: current subscription.')
  subscriptionId: string?
  @description('The resource group name of the action group.')
  resourceGroupName: string
  @description('The name of the action group.')
  name: string
}

@description('The log analytics workspace for the alert.')
param logAnalyticsWorkspace logAnalyticsWorkspaceType

@description('The managed identity for the alert.')
param managedIdentity identityType

@description('The action group for the alert.')
param actionGroup actionGroupType

resource logAnalyticsWorkspaceResource 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
  name: logAnalyticsWorkspace.name
  scope: resourceGroup(logAnalyticsWorkspace.?subscriptionId ?? subscription().subscriptionId, logAnalyticsWorkspace.?resourceGroupName!)
}

resource managedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = {
  name: managedIdentity.name
  scope: resourceGroup(managedIdentity.?subscriptionId ?? subscription().subscriptionId, managedIdentity.resourceGroupName)
}

resource actionGroupResource 'Microsoft.Insights/actionGroups@2024-10-01-preview' existing = {
  name: actionGroup.name
  scope: resourceGroup(actionGroup.?subscriptionId ?? subscription().subscriptionId, actionGroup.resourceGroupName)
}

resource logAlert 'Microsoft.Insights/scheduledQueryRules@2025-01-01-preview' = {
  name: 'Azure Subscription was cancelled'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResource.id}': {}
    }
  }
  kind: 'LogAlert'
  properties: {
    scopes: [
      logAnalyticsWorkspaceResource.id
    ]
    displayName: 'Azure Subscription was cancelled'
    autoMitigate: false
    description: 'Alert triggered when a subscription is cancelled'
    enabled: true
    windowSize: 'PT15M'
    evaluationFrequency: 'PT15M'
    severity: 1
    muteActionsDuration: null
    overrideQueryTimeRange: null
    criteria: {
      allOf: [
        {
          query: '''AzureActivity
| where CategoryValue == "Administrative"
    and ResourceProviderValue == "MICROSOFT.SUBSCRIPTION"
    and ActivityStatusValue == "Success"
    and OperationNameValue =~ 'Microsoft.Subscription/cancel/action'
| extend managementGroup = tostring(split(tostring(todynamic(Properties).hierarchy), '/')[-2])
| extend subscriptionId = tostring(todynamic(Properties).subscriptionId)'''
          timeAggregation: 'Count'
          metricMeasureColumn: null
          resourceIdColumn: null
          operator: 'GreaterThan'
          threshold: 0
          dimensions: [
            {
              name: 'managementGroup'
              operator: 'Include'
              values: ['*']
            }
            {
              name: 'subscriptionId'
              operator: 'Include'
              values: ['*']
            }
          ]
          failingPeriods: {
            minFailingPeriodsToAlert: 1
            numberOfEvaluationPeriods: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroupResource.id
      ]
      customProperties: {}
    }
    checkWorkspaceAlertsStorageConfigured: false
    skipQueryValidation: false
  }
}

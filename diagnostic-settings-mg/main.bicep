targetScope = 'managementGroup'

@description('The subscription ID of the Log Analytics workspace.')
param subscriptionId string
@description('The resource group name of the Log Analytics workspace.')
param resourceGroupName string
@description('The name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

resource logAnalyticsWorkspaceResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'sendLogs'
  properties: {
    workspaceId: logAnalyticsWorkspaceResource.id
    logAnalyticsDestinationType: null
    eventHubAuthorizationRuleId: null
    eventHubName: null
    marketplacePartnerId: null
    serviceBusRuleId: null
    storageAccountId: null
    logs: [
      {
        category: 'Administrative'
        enabled: true
        categoryGroup: null
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'Policy'
        enabled: true
        categoryGroup: null
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: []
  }
}

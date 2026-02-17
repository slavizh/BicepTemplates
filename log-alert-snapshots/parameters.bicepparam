using 'main.bicep'

param logAlerts = [
  {
    name: 'logAlert001'
    type: 'LogAlertStaticThreshold'
    displayName: 'Log Alert 001'
    severity: 3
    scope: {
      type: 'LogAnalyticsWorkspace'
      name: 'workspace001'
      resourceGroupName:'kusto'
      subscriptionId: '11111111-1111-1111-1111-111111111111'
    }
    query: 'Perf'
    timeAggregation: 'Average'
    operator: 'GreaterThan'
    threshold: '0.5'
    metricMeasureColumn: 'CounterValue'
  }
  {
    name: 'logAlert002'
    type: 'LogAlertDynamicThreshold'
    displayName: 'Log Alert 002'
    severity: 2
    scope: {
      resourceGroupName: 'identities'
      type: 'ResourceGroup'
    }
    query: 'AzureActivity'
    timeAggregation: 'Count'
    metricMeasureColumn: 'TableRows'
    operator: 'GreaterThan'
    thresholdSensitivity: 'Low'
  }
  {
    name: 'logAlert003'
    displayName: 'Log Alert 003'
    type:'SimpleLogSearchAlert'
    severity: 4
    minRecurrenceCount: 5
    scope: {
      name: 'workspace001'
      resourceGroupName: 'kusto'
      subscriptionId: '11111111-1111-1111-1111-111111111111'
      type: 'LogAnalyticsWorkspace'
    }
    query: 'AzureActivity'
    identity: {
      name: 'identity1'
      resourceGroupName: 'identities'
      type: 'UserAssigned'
    }
  }
]

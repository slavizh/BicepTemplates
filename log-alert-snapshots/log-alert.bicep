import * as types from 'types.bicep'

param logAlert types.logAlert

func returnIso8601(minutes int) string => minutes > 1440 ? 'P${minutes/1440}D' : minutes < 60 ? 'PT${minutes}M': 'PT${minutes/60}H'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = if (contains(logAlert, 'identity') ? logAlert.?identity.type == 'UserAssigned' : false ) {
  name: logAlert.?identity.name
  scope: resourceGroup(logAlert.?identity.?subscriptionId ?? subscription().subscriptionId, logAlert.?identity.resourceGroupName)
}

resource resourceGroupResource 'Microsoft.Resources/resourceGroups@2025-04-01' existing = if (logAlert.scope.type == 'ResourceGroup') {
  name: logAlert.scope.resourceGroupName
  scope: subscription(logAlert.scope.?subscriptionId ?? subscription().subscriptionId)
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = if (logAlert.scope.type == 'LogAnalyticsWorkspace') {
  name: logAlert.scope.name
  scope: resourceGroup(logAlert.scope.?subscriptionId ?? subscription().subscriptionId, logAlert.scope.resourceGroupName)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (logAlert.scope.type == 'ApplicationInsights') {
  name: logAlert.scope.name
  scope: resourceGroup(logAlert.scope.?subscriptionId ?? subscription().subscriptionId, logAlert.scope.resourceGroupName)
}

resource actionGroups 'Microsoft.Insights/actionGroups@2024-10-01-preview' existing = [for actionGroup in logAlert.?actionGroups ?? []: {
  name: actionGroup.name
  scope: resourceGroup(actionGroup.?subscriptionId ?? subscription().subscriptionId, actionGroup.resourceGroupName)
}]

resource logAlertResource 'Microsoft.Insights/scheduledQueryRules@2025-01-01-preview' = {
  name: logAlert.name
  location: resourceGroup().location
  tags: logAlert.?tags ?? {}
  identity: {
    type: logAlert.?identity.type ?? 'None'
    userAssignedIdentities: contains(logAlert, 'identity') ? logAlert.?identity.type == 'UserAssigned' ? {
      '${identity.id}': {}
    } : null : null
   }
  kind: logAlert.type == 'LogAlertStaticThreshold' || logAlert.type == 'LogAlertDynamicThreshold'
    ? 'LogAlert'
    // SimpleLogAlert case
    : 'SimpleLogAlert'
  properties: {
    displayName: logAlert.displayName
    description: logAlert.?description ?? null
    enabled: logAlert.?enabled ?? true
    autoMitigate: logAlert.?autoMitigate ?? false
    severity: logAlert.severity
    evaluationFrequency: logAlert.type == 'SimpleLogSearchAlert' ? null : returnIso8601(logAlert.?frequencyInMinutes ?? 15)
    windowSize: logAlert.type == 'SimpleLogSearchAlert' ? null : returnIso8601(logAlert.?windowSizeInMinutes ?? 15)
    overrideQueryTimeRange: contains(logAlert, 'overrideQueryTimeRangeInMinutes')
      ? returnIso8601(logAlert.overrideQueryTimeRangeInMinutes)
      : null
    muteActionsDuration: contains(logAlert, 'muteActionsDurationInMinutes')
      ? returnIso8601(logAlert.muteActionsDurationInMinutes)
      : null
    scopes: [
      logAlert.scope.type == 'ResourceGroup'
        ? resourceGroupResource.id
        : logAlert.scope.type == 'LogAnalyticsWorkspace'
          ? logAnalyticsWorkspace.id
          : logAlert.scope.type == 'ApplicationInsights'
            ? applicationInsights.id
            // Subscription scope type
            : '/subscriptions/${logAlert.scope.?subscriptionId ?? subscription().subscriptionId}'
    ]
    criteria: {
      allOf: [
        {
          criterionType: logAlert.type == 'LogAlertStaticThreshold'
            ? 'StaticThresholdCriterion'
            : logAlert.type == 'LogAlertDynamicThreshold'
              ? 'DynamicThresholdCriterion'
              : null
          query: logAlert.query
          timeAggregation: logAlert.type == 'SimpleLogSearchAlert' ? null : logAlert.timeAggregation
          metricMeasureColumn: logAlert.type == 'SimpleLogSearchAlert'
            ? null
            : logAlert.metricMeasureColumn =~ 'TableRows'
              ? null
              : logAlert.metricMeasureColumn
          operator: logAlert.type == 'SimpleLogSearchAlert' ? null : logAlert.operator
          threshold: logAlert.type == 'SimpleLogSearchAlert' ? null : logAlert.?threshold ?? null
          alertSensitivity: logAlert.type == 'SimpleLogSearchAlert'
            ? null
            : logAlert.?thresholdSensitivity ?? null
          minRecurrenceCount: logAlert.type == 'SimpleLogSearchAlert'
            ? logAlert.?minRecurrenceCount
            : null
          ignoreDataBefore: logAlert.type == 'SimpleLogSearchAlert'
            ? null
            : logAlert.?ignoreDataBefore ?? null
          resourceIdColumn: logAlert.type == 'SimpleLogSearchAlert'
            ? null
            : contains(logAlert, 'resourceIdColumn')
              ? logAlert.?resourceIdColumn ?? null
              : logAlert.scope.type == 'ResourceGroup' || logAlert.scope.type == 'Subscription'
                ? '_ResourceId'
                : null
          failingPeriods: logAlert.type == 'SimpleLogSearchAlert'
            ? null
            : {
              minFailingPeriodsToAlert: logAlert.?minFailingPeriodsToAlert ?? 1
              numberOfEvaluationPeriods: logAlert.?numberOfEvaluationPeriods ?? 1
            }
          dimensions: logAlert.type == 'SimpleLogSearchAlert' ? null : logAlert.?dimensions ?? []
        }
      ]
    }
    checkWorkspaceAlertsStorageConfigured: logAlert.?checkWorkspaceAlertsStorageConfigured ?? false
    skipQueryValidation: logAlert.?skipQueryValidation ?? false
    actions: {
      actionGroups: [for (actionGroup, index) in logAlert.?actionGroups ?? []: actionGroups[index].id]
      actionProperties: logAlert.?actionProperties ?? {}
      customProperties: logAlert.?customProperties ?? {}
    }
  }
}

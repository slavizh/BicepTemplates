@export()
@discriminator('type')
type logAlert = logAlertStatic | logAlertDynamic | logAlertSimpleLogSearchAlert

type logAlertStatic = {
  @description('The name (id) of the log alert rule.')
  name: string
  type: 'LogAlertStaticThreshold'
  @description('The display name of the log alert rule.')
  displayName: string
  @description('Tags.')
  tags: tags?
  @description('The severity of the alert rule.')
  severity: 0 | 1 | 2 | 3 | 4
  @description('The identity of the alert rule. Default: None.')
  identity: identity?
  @description('The scope of the log alert rule.')
  scope: scope
  @description('The description of the log alert rule.')
  description: string?
  @description('Enables the log alert rule. Default: true.')
  enabled: bool?
  @description('''Makes the log alert rule stateless or stateful. Value true for stateful, false for stateless.
    Use stateful in cases where the log in the query is metric based or it logs data at certain frequency and stateless when the log is event based or it logs data at irregular frequency.
    Default: false (stateless).''')
  autoMitigate: bool?
  @description('The frequency at which the alert rule is evaluated in minutes. Default: 15.')
  frequencyInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440?
  @description('The period of time (in minutes) on which the Alert query will be executed (bin size). Default: 15.')
  windowSizeInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('Overrides the query time range (in minutes). Default: null.')
  overrideQueryTimeRangeInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('Mute actions for the chosen period of time (in minutes) after the alert is fired. Default: null.')
  muteActionsDurationInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('The Kusto (KQL) query for the alert rule.')
  query: string
  @description('Aggregation type.')
  timeAggregation: 'Average' | 'Count' | 'Maximum' | 'Minimum' | 'Total'
  @description('The operator to compare the metric against the threshold.')
  operator: 'Equal' | 'GreaterThan' | 'GreaterThanOrEqual' | 'LessThan' | 'LessThanOrEqual'
  @description('The threshold for the alert rule. For decimal values enter them as string, e.g. "0.5".')
  threshold: any
  @description('Metric measure column. This is the column that contains the metric to be measured against the threshold. Use value TableRows when using Count as time aggregation.')
  metricMeasureColumn: string
  @description('The column containing the resource id. The content of the column must be a uri formatted as resource id. Default: _ResourceId when scope is ResourceGroup or Subscription, otherwise null.')
  resourceIdColumn: string?
  @description('The number of violations to trigger an alert. Should be smaller or equal to numberOfEvaluationPeriods. Default: 1.')
  minFailingPeriodsToAlert: 1 | 2 | 3 | 4 | 5 | 6?
  @description('The number of aggregated lookback points. The lookback time window is calculated based on the aggregation granularity (windowSize) and the selected number of aggregated points. Default: 1.')
  numberOfEvaluationPeriods: 1 | 2 | 3 | 4 | 5 | 6?
  @description('Dimensions to add to the alert rule. Default: empty array.')
  dimensions: dimension[]?
  @description('The flag which indicates whether this scheduled query rule should be stored in storage account. Default: false.')
  checkWorkspaceAlertsStorageConfigured: bool?
  @description('The flag which indicates whether the provided query should be validated or not. Default: false.')
  skipQueryValidation: bool?
  @description('Action groups to be triggered when the alert rule is fired. Default: empty array.')
  actionGroups: actionGroup[]?
  @description('Action properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  actionProperties: actionProperties?
  @description('Custom properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  customProperties: customProperties?
}

type logAlertDynamic = {
  @description('The name (id) of the log alert rule.')
  name: string
  type: 'LogAlertDynamicThreshold'
  @description('The display name of the log alert rule.')
  displayName: string
  @description('Tags.')
  tags: tags?
  @description('The severity of the alert rule.')
  severity: 0 | 1 | 2 | 3 | 4
  @description('The identity of the alert rule. Default: None.')
  identity: identity?
  @description('The scope of the log alert rule.')
  scope: scope
  @description('The description of the log alert rule.')
  description: string?
  @description('Enables the log alert rule. Default: true.')
  enabled: bool?
  @description('''Makes the log alert rule stateless or stateful. Value true for stateful, false for stateless.
    Use stateful in cases where the log in the query is metric based or it logs data at certain frequency and stateless when the log is event based or it logs data at irregular frequency.
    Default: false (stateless).''')
  autoMitigate: bool?
  @description('The frequency at which the alert rule is evaluated in minutes. Default: 15.')
  frequencyInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440?
  @description('The period of time (in minutes) on which the Alert query will be executed (bin size). Default: 15.')
  windowSizeInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('Overrides the query time range (in minutes). Default: null.')
  overrideQueryTimeRangeInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('Mute actions for the chosen period of time (in minutes) after the alert is fired. Default: null.')
  muteActionsDurationInMinutes: 1 | 5 | 10 | 15 | 30 | 45 | 60 | 120 | 180 | 240 | 300 | 360 | 1440 | 2880?
  @description('The Kusto (KQL) query for the alert rule.')
  query: string
  @description('Aggregation type.')
  timeAggregation: 'Average' | 'Count' | 'Maximum' | 'Minimum' | 'Total'
  @description('The operator to compare the metric against the threshold.')
  operator: 'GreaterOrLessThan' | 'GreaterThan' | 'LessThan'
  @description('The extent of deviation required to trigger an alert. This will affect how tight the threshold is to the metric series pattern.')
  thresholdSensitivity: 'Low' | 'Medium' | 'High'
  @description('Use this option to set the date from which to start learning the metric historical data and calculate the dynamic thresholds (in ISO8601 format).')
  ignoreDataBefore: string?
  @description('Metric measure column. This is the column that contains the metric to be measured against the threshold. Use value TableRows when using Count as time aggregation.')
  metricMeasureColumn: string
  @description('The column containing the resource id. The content of the column must be a uri formatted as resource id. Default: _ResourceId when scope is ResourceGroup or Subscription, otherwise null.')
  resourceIdColumn: string?
  @description('The number of violations to trigger an alert. Should be smaller or equal to numberOfEvaluationPeriods. Default: 1.')
  minFailingPeriodsToAlert: 1 | 2 | 3 | 4 | 5 | 6?
  @description('The number of aggregated lookback points. The lookback time window is calculated based on the aggregation granularity (windowSize) and the selected number of aggregated points. Default: 1.')
  numberOfEvaluationPeriods: 1 | 2 | 3 | 4 | 5 | 6?
  @description('Dimensions to add to the alert rule. Default: empty array.')
  dimensions: dimension[]?
  @description('The flag which indicates whether this scheduled query rule should be stored in storage account. Default: false.')
  checkWorkspaceAlertsStorageConfigured: bool?
  @description('The flag which indicates whether the provided query should be validated or not. Default: false.')
  skipQueryValidation: bool?
  @description('Action groups to be triggered when the alert rule is fired. Default: empty array.')
  actionGroups: actionGroup[]?
  @description('Action properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  actionProperties: actionProperties?
  @description('Custom properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  customProperties: customProperties?
}

type logAlertSimpleLogSearchAlert = {
  @description('The name (id) of the log alert rule.')
  name: string
  type: 'SimpleLogSearchAlert'
  @description('The display name of the log alert rule.')
  displayName: string
  @description('Tags.')
  tags: tags?
  @description('The severity of the alert rule.')
  severity: 0 | 1 | 2 | 3 | 4
  @description('The identity of the alert rule. Default: None.')
  identity: identity?
  @description('The scope of the log alert rule.')
  scope: scope
  @description('The description of the log alert rule.')
  description: string?
  @description('Enables the log alert rule. Default: true.')
  enabled: bool?
  @description('''Makes the log alert rule stateless or stateful. Value true for stateful, false for stateless.
    Use stateful in cases where the log in the query is metric based or it logs data at certain frequency and stateless when the log is event based or it logs data at irregular frequency.
    Default: false (stateless).''')
  autoMitigate: bool?
  @description('The Kusto (KQL) query for the alert rule.')
  query: string
  @description('Minimal number of times in the last minute when the condition is met to trigger an alert. Value 0 for every time the condition is met.')
  minRecurrenceCount: int
  @description('The flag which indicates whether this scheduled query rule should be stored in storage account. Default: false.')
  checkWorkspaceAlertsStorageConfigured: bool?
  @description('The flag which indicates whether the provided query should be validated or not. Default: false.')
  skipQueryValidation: bool?
  @description('Action groups to be triggered when the alert rule is fired. Default: empty array.')
  actionGroups: actionGroup[]?
  @description('Action properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  actionProperties: actionProperties?
  @description('Custom properties to configure on the alert rule when an action group is triggered. Default: empty object.')
  customProperties: customProperties?
}

type tags = {
  @description('The value of the tag.')
  *: string
}

@discriminator('type')
type identity = identitySystemAssigned | identityUserAssigned

type identitySystemAssigned = {
  @description('The type of the identity.')
  type: 'SystemAssigned'
}

type identityUserAssigned = {
  @description('The type of the identity.')
  type: 'UserAssigned'
  @description('The name of the user assigned identity.')
  name: string
  @description('The resource group name of the user assigned identity.')
  resourceGroupName: string
  @description('The subscription id of the user assigned identity. Default: current subscription.')
  subscriptionId: string?
}

@discriminator('type')
type scope = scopeResourceGroup | scopeLogAnalyticsWorkspace | scopeApplicationInsights | scopeSubscription

type scopeResourceGroup = {
  @description('The type of the scope.')
  type: 'ResourceGroup'
  @description('The name of the resource group.')
  resourceGroupName: string
  @description('The subscription id of the resource group. Default: current subscription.')
  subscriptionId: string?
}

type scopeLogAnalyticsWorkspace = {
  @description('The type of the scope.')
  type: 'LogAnalyticsWorkspace'
  @description('The name of the Log Analytics workspace.')
  name: string
  @description('The resource group name of the Log Analytics workspace.')
  resourceGroupName: string
  @description('The subscription id of the Log Analytics workspace. Default: current subscription.')
  subscriptionId: string?
}

type scopeApplicationInsights = {
  @description('The type of the scope.')
  type: 'ApplicationInsights'
  @description('The name of the Application Insights resource.')
  name: string
  @description('The resource group name of the Application Insights resource.')
  resourceGroupName: string
  @description('The subscription id of the Application Insights resource. Default: current subscription.')
  subscriptionId: string?
}

type scopeSubscription = {
  @description('The type of the scope.')
  type: 'Subscription'
  @description('The subscription id. Default: current subscription.')
  subscriptionId: string?
}

type dimension = {
  @description('The name of a column of type string that will be used as dimension.')
  name: string
  @description('The operator.')
  operator: 'Include' | 'Exclude'
  @description('Values of the column to compare. Value * can be used to include any value available in the column.')
  values: string[]
}

type actionGroup = {
  @description('The subscription ID of the action group. Default: current subscription.')
  subscriptionId: string?
  @description('The resource group name of the action group.')
  resourceGroupName: string
  @description('The name of the action group.')
  name: string
}

type actionProperties = {
  @description('The value of the action property.')
  *: string
}

type customProperties = {
  @description('The value of the custom property.')
  *: string
}

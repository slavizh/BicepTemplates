import * as types from './types.bicep'

param logAlerts types.logAlert[]

module logAlertsModule 'log-alert.bicep' = [for (logAlert, index) in logAlerts: {
  name: 'logAlert-${index}'
  params: {
    logAlert: logAlert
  }
}]

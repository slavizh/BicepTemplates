param aksResourceId string
param dataCollectionRuleId string
param aksLocation string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2025-10-02-preview' existing = {
  name: split(aksResourceId, '/')[8]
}

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2024-03-11' = {
  name: '${split(dataCollectionRuleId, '/')[8]}-${split(aksResourceId, '/')[8]}'
  scope: aksCluster
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}

resource aksClusterUpdate 'Microsoft.ContainerService/managedClusters@2025-10-02-preview' = {
  name: split(aksResourceId, '/')[8]
  location: aksLocation
  identity: {type: 'SystemAssigned'}
  properties: {
    mode: 'Incremental'
    id: aksResourceId
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {
          // a comma-separated list of Kubernetes annotations keys that will be used in the resource's labels metric.
          // By default the metric contains only name and namespace labels. To include additional annotations provide
          // a list of resource names in their plural form and Kubernetes annotation keys, you would like to allow for them.
          // A single * can be provided per resource instead to allow any annotations, but that has severe performance implications.
          metricLabelsAllowlist: ''
          // a comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.
          // By default the metric contains only name and namespace labels. To include additional labels provide
          // a list of resource names in their plural form and Kubernetes label keys you would like to allow for them.
          // A single * can be provided per resource instead to allow any labels, but that has severe performance implications.
          metricAnnotationsAllowList: ''
        }
      }
    }
  }
}

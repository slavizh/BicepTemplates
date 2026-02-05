@description('The API Management service name.')
param apiManagementServiceName string
@description('The API name to onboard to Defender for APIs.')
param apiName string

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}
resource api 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' existing = {
  name: apiName
  parent: apiManagementService
}

resource defenderForAPIs 'Microsoft.Security/apiCollections@2023-11-15' = {
  name: api.name
  scope: apiManagementService
}

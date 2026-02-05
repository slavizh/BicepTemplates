import * as a2aApiType from './types.bicep'

@description('The name of the API Management service instance.')
param apiManagementServiceName string

@description('The A2A API configuration.')
param a2aApi a2aApiType.a2aApi

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource a2aApiResource 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: a2aApi.name
  parent: apiManagementService
  properties: {
    displayName: a2aApi.?displayName ?? a2aApi.name
    description: a2aApi.?description ?? null
    type: 'a2a'
    apiType: 'a2a'
    isAgent: true
    agent: {
      id: a2aApi.agentId
      name: a2aApi.?agentName ?? null
      managementPortalUrl: a2aApi.?agentManagementPortalUrl ?? null
      providerName: a2aApi.?agentProviderName ?? null
    }
    a2aProperties: {
      agentCardPath: a2aApi.?agentCardPath ?? '/${last(split(a2aApi.agentCardBackendUrl, '/'))}'
      agentCardBackendUrl: a2aApi.agentCardBackendUrl
    }
    jsonRpcProperties: {
      path: a2aApi.?jsonRpcPath ?? '/'
      backendUrl: a2aApi.jsonRpcBackendUrl
    }
    protocols: [
      'http'
      'https'
    ]
    path: a2aApi.path
    mcpProperties: null
    backendId: null
    format: null
    apiVersion: null
    apiVersionSet: null
    apiVersionSetId: null
    apiVersionDescription: null
    apiRevisionDescription: null
    authenticationSettings: {
      oAuth2: null
      openid: null
      returnProtectedResourceMetadata: false
    }
    contact: null
    license: null
    serviceUrl: null
    sourceApiId: null
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    subscriptionRequired: true
    termsOfServiceUrl: null
    translateRequiredQueryParameters: null
    value: null
    wsdlSelector: null
  }
}


import * as types from './existing-mcp-server-types.bicep'

@description('The name of the API Management service instance.')
param apiManagementServiceName string
@description('The backend configuration for the MCP server.')
param backend types.backend
@description('The MCP server configuration.')
param mcpServer types.mcpServer

resource apiManagementService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apiManagementServiceName
}

resource mcpBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  name: backend.name
  parent: apiManagementService
  properties: {
    protocol: 'http'
    url: backend.url
    title: backend.?title ?? null
    description: backend.?description ?? null
    circuitBreaker: null
    credentials: null
    pool: null
    properties: null
    proxy: null
    resourceId: null
    tls: null
    type: null
  }
}

resource mcp 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  name: mcpServer.name
  parent: apiManagementService
  properties: {
    path: mcpServer.path
    displayName: mcpServer.displayName
    description: mcpServer.?description ?? null
    apiType: 'mcp'
    type: 'mcp'
    protocols: [
      'https'
    ]
    backendId: mcpBackend.name
    mcpProperties: {
      endpoints: null
      transportType: 'streamable'
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    subscriptionRequired: false
    contact: null
    format: null
    serviceUrl: null
    sourceApiId: null
    termsOfServiceUrl: null
    wsdlSelector: null
    value: null
    translateRequiredQueryParameters: null
    apiVersionDescription: null
    apiVersionSet: null
    apiVersionSetId: null
    apiRevisionDescription: null
    apiVersion: null
    license: null
    authenticationSettings: {
      oAuth2: null
      openid: null
    }
  }
}

resource mcpPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = if (contains(mcpServer, 'policy')) {
  name: 'policy'
  parent: mcp
  properties: {
    format: 'rawxml'
    value: mcpServer.?policy ?? ''
  }
}


import * as types from './exposing-api-mcp-server-types.bicep'

@description('The name of the API Management service instance.')
param apiManagementServiceName string
@description('The MCP server configuration.')
param mcpServer types.mcpServer

resource apiManagementService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apiManagementServiceName
}

resource api 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  name: mcpServer.apiName
  parent: apiManagementService
}

resource operations 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = [for operation in mcpServer.operations: {
  name: operation
  parent: api
}]

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
    mcpTools: [for (operation, i) in mcpServer.operations: {
      name: operations[i].name
      operationId: operations[i].id
    }]
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

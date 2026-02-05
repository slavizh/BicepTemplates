using 'main.bicep'

param apiManagementServiceName = 'api0002'

param a2aApi = {
  name: 'myA2A'
  agentCardBackendUrl: 'https://appweb-ls332fdgdf43.azurewebsites.net/a2a/.well-known/agent-card.json'
  agentId: 'sk-travel-agent'
  jsonRpcBackendUrl: 'http://0.0.0.0:8000/'
  path: 'travel'
}

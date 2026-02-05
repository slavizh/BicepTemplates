@export()
type a2aApi = {
  @description('The name of the A2A API.')
  @minLength(1)
  @maxLength(256)
  name: string
  @description('The display name of the A2A API. Default: same as name.')
  @minLength(1)
  @maxLength(300)
  displayName: string?
  @description('The description of the A2A API.')
  description: string?
  @description('''The unique identifier of the agent.
    API Management will log the provided value in the gen_ai.agent.id attribute of OpenTelemetry traces for consistency with agent execution traces.''')
  agentId: string
  @description('The agent name. Default: null.')
  agentName: string?
  @description('The agent management portal URL. Default: null.')
  agentManagementPortalUrl: string?
  @description('The agent provider name. Default: null.')
  agentProviderName: string?
  @description('Agent card URL.')
  agentCardBackendUrl: string
  @description('Agent card path. Default: the last segment of the agentCardBackendUrl.')
  agentCardPath: string?
  @description('The backend (runtime) URL (JSON-RPC).')
  jsonRpcBackendUrl: string
  @description('The JSON-RPC path. Default: "/".')
  jsonRpcPath: string?
  @description('The API base path.')
  path: string
}

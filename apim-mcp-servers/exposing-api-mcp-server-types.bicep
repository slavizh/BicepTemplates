@export()
type mcpServer = {
  @description('The name of the MCP server.')
  @minLength(1)
  @maxLength(80)
  name: string
  @description('Relative URL uniquely identifying this MCP server.')
  @minLength(1)
  @maxLength(400)
  path: string
  @description('The display name of the MCP server.')
  @minLength(1)
  @maxLength(300)
  displayName: string
  @description('The description of the MCP server.')
  description: string?
  @description('The name of the API.')
  apiName: string
  @description('The operations exposed by the MCP server.')
  operations: string[]
  @description('The policy content for the MCP server.')
  policy: string?
}

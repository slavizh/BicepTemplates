@export()
type backend = {
  @description('The name of the backend.')
  @minLength(1)
  @maxLength(80)
  name: string
  @description('The URL of the backend.')
  @minLength(1)
  @maxLength(2000)
  url: string
  @description('The description of the backend.')
  @minLength(1)
  @maxLength(2000)
  description: string?
  @description('The title of the backend.')
  @minLength(1)
  @maxLength(300)
  title: string?
}

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
  @description('The policy content for the MCP server.')
  policy: string?
}

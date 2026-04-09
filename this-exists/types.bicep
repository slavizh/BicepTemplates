@export()
type replicaMySqlFlexibleSever = {
  @description('The name of the MySQL flexible server replica.')
  name: string
  @description('The location of the MySQL flexible server replica. Default: resource group location.')
  location: string?
  sku: sku
  sourceServer: sourceServer
}

type sku = {
  @description('The name of the SKU.')
  name: string
  @description('The tier of the SKU.')
  // Replicas cannot be burstable tier
  tier: 'GeneralPurpose' | 'MemoryOptimized'
}

type sourceServer = {
  @description('The name of the source MySQL flexible server.')
  name: string
  @description('The resource group name of the source MySQL flexible server.')
  resourceGroupName: string
  @description('The subscription ID of the source MySQL flexible server. Default: current subscription.')
  subscriptionId: string?
}

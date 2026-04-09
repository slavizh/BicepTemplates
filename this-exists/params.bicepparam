using 'main.bicep'

param replicaMySqlFlexibleSever = {
  name: 'replica0008'
  location: 'West US 2'
  sku: {
    name: 'Standard_D2ads_v5'
    tier: 'GeneralPurpose'
  }
  sourceServer: {
    name: 'source0004'
    resourceGroupName: 'mysql-database'
  }
}

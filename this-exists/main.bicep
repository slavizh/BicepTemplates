import * as types from './types.bicep'

param replicaMySqlFlexibleSever types.replicaMySqlFlexibleSever

resource sourceServer 'Microsoft.DBforMySQL/flexibleServers@2025-06-01-preview' existing = {
  name: replicaMySqlFlexibleSever.sourceServer.name
  scope: resourceGroup(replicaMySqlFlexibleSever.sourceServer.?subscriptionId ?? subscription().subscriptionId, replicaMySqlFlexibleSever.sourceServer.resourceGroupName)
}

resource replicaServer 'Microsoft.DBforMySQL/flexibleServers@2025-06-01-preview' = {
  name: replicaMySqlFlexibleSever.name
  location: replicaMySqlFlexibleSever.?location ?? resourceGroup().location
  sku: {
    name: replicaMySqlFlexibleSever.sku.name
    tier: replicaMySqlFlexibleSever.sku.tier
  }
  properties: {
    createMode: this.exists() ? 'Update' : 'Replica'
    sourceServerResourceId: this.exists() ? null : sourceServer.id
    replicationRole: 'Replica'
    administratorLogin: null
    administratorLoginPassword: null
    version: this.exists() ? this.existingResource()!.properties.version : null
    storage: {
      storageSizeGB: 64
      autoGrow: 'Enabled'
      autoIoScaling: 'Enabled'
      storageRedundancy: 'LocalRedundancy'
      iops: 492
      logOnDisk: 'Disabled'
    }
    availabilityZone: ''
    network: {
      delegatedSubnetResourceId: null
      privateDnsZoneResourceId: null
      publicNetworkAccess: 'Enabled'
    }
    backup: {
      backupIntervalHours: 24
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    databasePort: 3306
    dataEncryption: null
    highAvailability: {
      mode: 'Disabled'
      replicationMode: 'BinaryLog'
      standbyAvailabilityZone: ''
    }
    maintenancePolicy: {
      patchStrategy: 'Regular'
    }
    maintenanceWindow: {
      batchOfMaintenance: 'Default'
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
  }
}

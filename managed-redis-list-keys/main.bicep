@description('The name of the Managed Redis cache.')
param redisName string

resource redis 'Microsoft.Cache/redisEnterprise@2025-05-01-preview' existing = {
  name: redisName
}

resource redisDatabase 'Microsoft.Cache/redisEnterprise/databases@2025-05-01-preview' = {
  name: 'default'
  parent: redis
}

@description('The primary key of the Redis database.')
@secure()
output primaryKey string = redisDatabase.listKeys().primaryKey

@description('The connection string of the Redis database.')
@secure()
output connectionString string = '${redis.properties.hostName}:${redisDatabase!.properties.port},password=${redisDatabase.listKeys().primaryKey},ssl=True,abortConnect=False'

@description('The name of the storage account.')
param storageAccountName string

@description('The location of the storage account.')
param storageAccountLocation string = 'West Europe'

@description('The SKU of the storage account. Default value: Standard_LRS.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountSku string = 'Standard_LRS'

@description('The kind of the storage account. Default value: StorageV2.')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param storageAccountKind string = 'StorageV2'

@description('Enable Files shares identity-based authentication to Microsoft Entra Kerberos Authentication. Default value: false.')
param enableMicrosoftEntraKerberosAuthentication bool = false

@description('The default share permission for the files shared identity-based authentication. Default value: None.')
@allowed([
  'None'
  'StorageFileDataSmbShareContributor'
  'StorageFileDataSmbShareElevatedContributor'
  'StorageFileDataSmbShareReader'
])
param defaultSharePermission string = 'None'

@description('The domain name for the files shared identity-based authentication.')
param domainName string = ''

@description('The domain GUID for the files shared identity-based authentication.')
param domainGuid string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: storageAccountLocation
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: enableMicrosoftEntraKerberosAuthentication ? 'AADKERB' : 'None'
      defaultSharePermission: defaultSharePermission
      activeDirectoryProperties: !empty(domainName) && enableMicrosoftEntraKerberosAuthentication ? {
        domainName: domainName
        domainGuid: !empty(domainGuid) ? domainGuid : fail('Parameter domainGuid is required when domainName is configured.')
      } : null
    }
  }
}

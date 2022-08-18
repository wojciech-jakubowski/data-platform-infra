param config object
param networking object
param name string
param isHnsEnabled bool = false


resource storage_account 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${config.dashlessNamePrefix}${name}sa'
  location: config.location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: false
    isHnsEnabled: isHnsEnabled
    isSftpEnabled: false
    networkAcls:{
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

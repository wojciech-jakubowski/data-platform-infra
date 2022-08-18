param config object
param networking object
param name string
param isHnsEnabled bool = false
param containers array = []


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
      defaultAction: 'Deny'
    }
  }
}

module dlPrivateEndpoint '../networking/private-endpoint.bicep' = {
  name: 'dlPrivateEndpoint'
  params: {
    config: config
    dnsZones: {
      kv: networking.privateDnsZones.kv
    }
    endpointType: isHnsEnabled ? 'dfs' : 'blob'
    parentId: storage_account.id
    parentName: storage_account.name
    subnetId: networking.mainSubnetId
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storage_account

  dependsOn: [
    dlPrivateEndpoint
  ]
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers:{
  name: container
  parent: blobServices
  properties:{
    publicAccess:'None'
  }
}]

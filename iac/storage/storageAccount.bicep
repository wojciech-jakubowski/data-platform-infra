param config object
param networking object
param monitoring object
param name string
param isHnsEnabled bool = false
param containers array = []


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
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
  tags: config.tags
}

module privateEndpoint '../networking/private-endpoint.bicep' = {
  name: 'dlPrivateEndpoint'
  params: {
    config: config
    dnsZones: {
      kv: networking.privateDnsZones.kv
    }
    endpointType: isHnsEnabled ? 'dfs' : 'blob'
    parentId: storageAccount.id
    parentName: storageAccount.name
    subnetId: networking.mainSubnetId
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount

  dependsOn: [
    privateEndpoint
  ]
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers:{
  name: container
  parent: blobServices
  properties:{
    publicAccess:'None'
  }
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${storageAccount.name}-blob-diagnosticSettings'
  scope: blobServices
  properties:{
    workspaceId: monitoring.logAnalyticsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
    ]
  }
}

param config object
param networking object

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${config.namePrefix}'
  location: '${config.location}'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: config.tenantId
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    networkAcls: {
      bypass:'AzureServices'
      defaultAction:'Deny'
    }
    accessPolicies: [
      {
        tenantId: config.tenantId
        objectId: config.deployerObjectId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
        }
      }
    ]
  }
}

resource secretZ 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'mySecretY'
  parent: keyvault  
  properties: {
    value: 'mySecretValueYT'
  }
}

resource secretA 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'mySecretA'
  parent: keyvault  
  properties: {
    value: 'mySecretValueA'
  }
}


var privateEndpointName = '${config.namePrefix}-kv-pe'
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: config.location
  properties: {
    subnet: {
      id: networking.mainSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

var pvtEndpointDnsGroupName = '${config.namePrefix}-kv-dns-group'
resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${config.namePrefix}-kv-dns-group-config'
        properties: {
          privateDnsZoneId: networking.privateDnsZones.kv
        }
      }
    ]
  }
}

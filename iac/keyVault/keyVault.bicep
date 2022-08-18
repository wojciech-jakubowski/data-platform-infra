param config object
param networking object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
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

module kvPrivateEndpoint '../networking/private-endpoint.bicep' = {
  name: 'kvPrivateEndpoint'
  params: {
    config: config
    dnsZones: {
      kv: networking.privateDnsZones.kv
    }
    endpointType: 'vault'
    parentId: keyVault.id
    parentName: keyVault.name
    subnetId: networking.mainSubnetId
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'sampleSecret'
  parent: keyVault  
  properties: {
    value: 'sampleSecretValue'
  }

  dependsOn: [
    kvPrivateEndpoint
  ]
}

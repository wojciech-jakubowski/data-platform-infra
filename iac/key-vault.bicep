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

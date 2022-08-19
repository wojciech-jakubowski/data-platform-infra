param config object
param networking object
param monitoring object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${config.namePrefix}-kv'
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
  tags: config.tags
}

module privateEndpoint '../networking/private-endpoint.bicep' = {
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
    privateEndpoint
  ]
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyVault.name}-diagnosticSettings'
  scope: keyVault
  properties:{
    workspaceId: monitoring.logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
      // {
      //   category: 'AzurePolicyEvaluationDetails'
      //   enabled: true
      //   retentionPolicy: {
      //     days: 0
      //     enabled: true
      //   }
      // }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: true
        }
      }
    ]
  }
}

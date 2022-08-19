param config object
param networking object
param monitoring object

module datalakeStorage 'storageAccount.bicep' = {
  name: 'datalake'
  params: {
    config: config
    name: 'dl'
    networking: networking
    monitoring: monitoring
    isHnsEnabled: true
    containers: ['raw', 'conformed', 'curated']
  }
}

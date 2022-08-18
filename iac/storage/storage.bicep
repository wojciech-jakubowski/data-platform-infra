param config object
param networking object

module datalake 'storageAccount.bicep' = {
  name: 'datalake'
  params: {
    config: config
    name: 'dl'
    networking: networking
    isHnsEnabled: true
    containers: ['raw', 'conformed', 'curated']
  }
}

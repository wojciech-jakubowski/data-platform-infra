@minLength(2)
@maxLength(10)
@description('Technical name of the client - 5 to 10 alphanumeric characters')
param clientName string

@minLength(3)
@maxLength(10)
@description('Technical name of the project - 3 to 10 alphanumeric characters')
param projectName string

@allowed(['dev', 'test', 'uat', 'prod'])
@description('Name of the environment - dev, test, uat or prod')
param envName string

@minLength(36)
@maxLength(36)
@description('Object id of the indentity that deploys the infrastructure')
param deployerObjectId string

@description('Location of the environment - by default westeurope')
param location string = resourceGroup().location

module config 'config/config.bicep' = {
  name: 'config'
  params:{
    clientName: clientName
    projectName: projectName
    envName: envName
    deployerObjectId: deployerObjectId
    location: location
  }
}

module networking 'networking/networking.bicep' = {
  name: 'networking'
  params: {
    config: config.outputs.values
  }
}

module monitoring 'monitoring/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    config: config.outputs.values
    networking: networking.outputs.values
  }
}

module keyVault 'keyVault/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    config: config.outputs.values
    networking: networking.outputs.values
    monitoring: monitoring.outputs.values
  }
}

module storage 'storage/storage.bicep' = {
  name: 'storage'
  params: {
    config: config.outputs.values
    networking: networking.outputs.values
    monitoring: monitoring.outputs.values
  }
  dependsOn: [
    keyVault
  ]
}

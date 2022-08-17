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

@description('Location of the environment - by default westeurope')
param location string = resourceGroup().location

module config 'config.bicep' = {
  name: 'config'
  params:{
    clientName: clientName
    projectName: projectName
    envName: envName
    location: location
  }
}

module networking 'networking.bicep' = {
  name: 'networking'
  params: {
    config: config.outputs.values
  }
}

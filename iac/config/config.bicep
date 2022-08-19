param clientName string
param projectName string
param envName string
param location string
param deployerObjectId string

var configValues = {
  namePrefix: '${clientName}-${projectName}-${envName}'
  dashlessNamePrefix: '${clientName}${projectName}${envName}'
  location: location
  tenantId: tenant().tenantId
  deployerObjectId: deployerObjectId
  networkAddress: {
    firstOctet: 10
    secondOctet: 0
    thirdOctet: 0
  }
}

//output resourcePrefix string = config.prefix
//output location string = location
output values object = configValues

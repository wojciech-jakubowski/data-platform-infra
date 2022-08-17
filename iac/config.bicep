param clientName string
param projectName string
param envName string
param location string

var configValues = {
  namePrefix: '${clientName}-${projectName}-${envName}'
  location: location
  networkAddress: {
    firstOctet: 10
    secondOctet: 0
    thirdOctet: 0
  }
}

//output resourcePrefix string = config.prefix
//output location string = location
output values object = configValues

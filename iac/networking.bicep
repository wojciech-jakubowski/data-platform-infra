param config object

var networkAddressPart = '${config.networkAddress.firstOctet}.${config.networkAddress.secondOctet}.${config.networkAddress.thirdOctet}'

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: '${config.namePrefix}-vnet'
  location: config.location
  properties: {
    addressSpace: {
      addressPrefixes: [
       '${networkAddressPart}.0/24'
      ]
    }

    subnets: [
      {
       name: 'main'
       properties: {
        addressPrefix: '${networkAddressPart}.0/25'
       }
      }
      {
        name: 'secondary'
        properties: {
         addressPrefix: '${networkAddressPart}.128/25'
        }
       }
    ]
  }
}

output values object = {
  vnetId: vnet.id
}

param config object

var networkAddressPart = '${config.networkAddress.firstOctet}.${config.networkAddress.secondOctet}.${config.networkAddress.thirdOctet}'

var privateDnsZones = {
  kv: 'privatelink.vaultcore.azure.net'
  dl: 'privatelink.dfs.core.windows.net'
  bl: 'blob.core.windows.net'
}

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

resource dnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for dnsZone in items(privateDnsZones): {
  name: dnsZone.value
  location: 'global'

  dependsOn: [
    vnet
  ]
}]

resource dnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (dnsZone, i) in items(privateDnsZones): {
  name: '${dnsZone.key}-link'
  location: 'global'
  parent: dnsZones[i]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}]

var dnsZonesObjectArray = [for (dnsZone, i) in items(privateDnsZones): {
  '${dnsZone.key}': dnsZones[i].id
}]

// ugly hack due to lack of built-in function that converts an array to an object
var dnsZonesObjectArrayString = replace(replace(replace(string(dnsZonesObjectArray), '[{', '{'), '},{', ','), '}]', '}')
var dnsZonesObject = json(dnsZonesObjectArrayString)


output values object = {
  vnetId: vnet.id
  mainSubnetId: vnet.properties.subnets[0].id
  secondarySubnetId: vnet.properties.subnets[1].id
  privateDnsZones: dnsZonesObject
  vnet: vnet
}

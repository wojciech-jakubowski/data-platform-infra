param config object
param parentId string
param parentName string
param nameSuffix string = ''
param endpointType string
param subnetId string
param dnsZones object

var fullSuffix = empty(nameSuffix) ? '' : '-${nameSuffix}'
var privateEndpointName = '${parentName}${fullSuffix}-pe'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: config.location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: parentId
          groupIds: [
            endpointType
          ]
        }
      }
    ]
  }
}

var pvtEndpointDnsGroupName = '${privateEndpointName}-dnsgroup'
resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [for dnsZone in items(dnsZones): {
        name: '${pvtEndpointDnsGroupName}-${dnsZone.key}-config'
        properties: {
          privateDnsZoneId: dnsZone.value
        }
      }]
  }
}

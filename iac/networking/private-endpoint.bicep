param config object
param parentId string
param parentName string
param nameSuffix string 
param endpointType string
param subnetId string
param dnsGroups object

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
    privateDnsZoneConfigs: [for dnsGroup in items(dnsGroups): {
        name: '${pvtEndpointDnsGroupName}-${dnsGroup.key}-config'
        properties: {
          privateDnsZoneId: dnsGroup.value
        }
      }]
  }
}

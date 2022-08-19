param config object
param networking object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${config.namePrefix}-lgw'
  location: config.location

  properties:{
   sku: {
    name: 'PerGB2018'
   } 
  } 
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${config.namePrefix}-ai'
  location: config.location
  kind: ''
  properties: {
    Application_Type: ' '
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}


resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: 'privateLinkScope'
  location: 'global'
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'PrivateOnly'
    }
  }
}

module pesPrivateEndpoint '../networking/private-endpoint.bicep' = {
  name: 'pesPrivateEndpoint'
  params: {
    config: config
    dnsZones: {
      mon: networking.privateDnsZones.mon
      ods: networking.privateDnsZones.ods
      oms: networking.privateDnsZones.oms
      asc: networking.privateDnsZones.asc
      bl: networking.privateDnsZones.bl
    }
    endpointType: 'azuremonitor'
    parentId: privateLinkScope.id
    parentName: privateLinkScope.name
    subnetId: networking.mainSubnetId
  }
}

resource privateLinkScopeLogAnalyticsConnection 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: 'privateLinkScopeLogAnalyticsConnection'
  parent: privateLinkScope
  properties: {
    linkedResourceId: logAnalyticsWorkspace.id
  }

  dependsOn: [
    pesPrivateEndpoint    
  ]
}

resource privateLinkScopeAppInsightsConnection 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: 'privateLinkScopeAppInsightsConnection'
  parent: privateLinkScope
  properties: {
    linkedResourceId: appInsights.id
  }

  dependsOn: [
    pesPrivateEndpoint    
  ]
}

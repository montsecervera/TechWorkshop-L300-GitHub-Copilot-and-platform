// App Service Plan module (Linux)

@description('Name of the App Service Plan.')
param name string

@description('Azure region for this resource.')
param location string

@description('Resource tags.')
param tags object = {}

@description('App Service Plan SKU (e.g. B1, B2, S1).')
param sku string = 'B1'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: sku
  }
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name

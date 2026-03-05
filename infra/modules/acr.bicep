// Azure Container Registry module

@description('Name of the Azure Container Registry (alphanumeric, 5-50 chars).')
@minLength(5)
@maxLength(50)
param name string

@description('Azure region for this resource.')
param location string

@description('Resource tags.')
param tags object = {}

@description('ACR SKU: Basic, Standard, or Premium.')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

resource registry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}

output id string = registry.id
output name string = registry.name
output loginServer string = registry.properties.loginServer

// Log Analytics Workspace module

@description('Name of the Log Analytics Workspace.')
param name string

@description('Azure region for this resource.')
param location string

@description('Resource tags.')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name

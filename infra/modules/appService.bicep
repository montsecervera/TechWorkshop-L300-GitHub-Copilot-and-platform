// App Service (Web App for Containers) module
// Uses a system-assigned managed identity to pull images from ACR (no passwords).

@description('Name of the App Service.')
param name string

@description('Azure region for this resource.')
param location string

@description('Resource tags.')
param tags object = {}

@description('Resource ID of the App Service Plan.')
param appServicePlanId string

@description('Login server of the Azure Container Registry (e.g. myacr.azurecr.io).')
param acrLoginServer string

@description('Application Insights connection string.')
param appInsightsConnectionString string

@description('Application Insights instrumentation key.')
param appInsightsInstrumentationKey string

@description('Initial container image to use. Updated by AZD on deploy.')
param containerImage string = 'mcr.microsoft.com/appsvc/staticsite:latest'

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': 'web' })
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
}

output id string = appService.id
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
output identityPrincipalId string = appService.identity.principalId

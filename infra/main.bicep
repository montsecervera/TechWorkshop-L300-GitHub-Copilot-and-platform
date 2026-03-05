targetScope = 'subscription'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g. dev, test, prod).')
param environmentName string

@minLength(1)
@description('Primary Azure region for all resources. Defaults to westus3.')
param location string = 'westus3'

@description('SKU for the Linux App Service Plan.')
param appServicePlanSku string = 'B1'

@description('SKU for Azure Container Registry.')
param acrSku string = 'Basic'

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

var resourceGroupName = 'rg-${environmentName}-${resourceToken}'

// ---------------------------------------------------------------------------
// Resource Group
// ---------------------------------------------------------------------------

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ---------------------------------------------------------------------------
// Log Analytics Workspace (required by Application Insights)
// ---------------------------------------------------------------------------

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: 'law-${resourceToken}'
    location: location
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Application Insights
// ---------------------------------------------------------------------------

module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    name: 'appi-${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// ---------------------------------------------------------------------------
// Azure Container Registry
// ---------------------------------------------------------------------------

module acr 'modules/acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    name: 'acr${resourceToken}'
    location: location
    tags: tags
    sku: acrSku
  }
}

// ---------------------------------------------------------------------------
// App Service Plan (Linux)
// ---------------------------------------------------------------------------

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    name: 'asp-${resourceToken}'
    location: location
    tags: tags
    sku: appServicePlanSku
  }
}

// ---------------------------------------------------------------------------
// App Service – Web App for Containers
// ---------------------------------------------------------------------------

module appService 'modules/appService.bicep' = {
  name: 'appService'
  scope: rg
  params: {
    name: 'app-${resourceToken}'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
  }
}

// ---------------------------------------------------------------------------
// AcrPull Role Assignment (managed identity → ACR)
// ---------------------------------------------------------------------------

module acrPullRole 'modules/roleAssignment.bicep' = {
  name: 'acrPullRole'
  scope: rg
  params: {
    principalId: appService.outputs.identityPrincipalId
    acrName: acr.outputs.name
  }
}

// ---------------------------------------------------------------------------
// Azure AI Foundry (AI Services – GPT-4 and Phi models)
// ---------------------------------------------------------------------------

module aiFoundry 'modules/aiFoundry.bicep' = {
  name: 'aiFoundry'
  scope: rg
  params: {
    name: 'aif-${resourceToken}'
    location: location
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Outputs (consumed by azd and application configuration)
// ---------------------------------------------------------------------------

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name

output APP_SERVICE_NAME string = appService.outputs.name
output APP_SERVICE_URI string = appService.outputs.uri

output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.outputs.connectionString

output AZURE_AI_FOUNDRY_ENDPOINT string = aiFoundry.outputs.endpoint

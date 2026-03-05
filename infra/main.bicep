param location string = 'westus3'
param environmentName string = 'dev'

var uniqueSuffix = uniqueString(subscription().id, resourceGroup().id)
var baseName = 'zava${uniqueSuffix}'

module acr './modules/acr.bicep' = {
  name: 'acr'
  params: {
    acrName: toLower(take('acr${baseName}', 50))
    location: location
  }
}

module insights './modules/insights.bicep' = {
  name: 'insights'
  params: {
    appInsightsName: take('appi-${baseName}-${environmentName}', 260)
    logAnalyticsName: take('law-${baseName}-${environmentName}', 63)
    location: location
  }
}

module appService './modules/appservice.bicep' = {
  name: 'appService'
  params: {
    appServicePlanName: take('asp-${baseName}-${environmentName}', 40)
    appServiceName: toLower(take('app-${baseName}-${environmentName}', 60))
    location: location
    acrName: acr.outputs.acrName
    acrLoginServer: acr.outputs.acrLoginServer
    appInsightsConnectionString: insights.outputs.connectionString
  }
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: toLower(take('ais-${baseName}-${environmentName}', 63))
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

output appServiceName string = appService.outputs.appServiceName
output acrName string = acr.outputs.acrName
output acrLoginServer string = acr.outputs.acrLoginServer
output appInsightsName string = insights.outputs.appInsightsName
output aiServicesName string = aiServices.name

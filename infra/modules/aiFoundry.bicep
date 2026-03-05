// Azure AI Foundry module
// Provisions an Azure AI Services account (kind: AIServices) which provides
// access to GPT-4 and Phi models through the Azure AI Foundry portal.
// westus3 region is required for these model deployments.

@description('Name of the Azure AI Services / AI Foundry account.')
param name string

@description('Azure region for this resource. Must be westus3 for GPT-4 and Phi availability.')
param location string

@description('Resource tags.')
param tags object = {}

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// GPT-4 model deployment
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'gpt-4'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
  }
}

// Phi model deployment
resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'Phi-4'
  dependsOn: [gpt4Deployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4'
    }
  }
}

output id string = aiServices.id
output name string = aiServices.name
output endpoint string = aiServices.properties.endpoint

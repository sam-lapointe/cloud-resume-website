targetScope = 'subscription'

@description('The name of the resource group for the Cloud Resume Challenge.')
param rgName string = 'Cloud-Resume'

@description('The location of the resources.')
param location string = deployment().location

@description('Tags for the resources.')
param tags object = {
  Project: 'Cloud-Resume'
}

@description('True if you want to add your custom domain.')
// If true it will create the CDN profile and endpoint. You will have to manually configure your custom domain in the CDN endpoint.
param customDomain bool = true


resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgName
  location: location
  tags: tags
}

module storage 'modules/storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    location: location
    tags: tags
    customDomain: customDomain
  }
}

module database 'modules/database.bicep' = {
  scope: rg
  name: 'database'
  params: {
    location: location
    tags: tags
  }
}

module appInsights 'modules/appinsights.bicep' = {
  scope: rg
  name: 'appInsights'
  params: {
    location: location
    tags: tags
  }
}

module functionApp 'modules/function.bicep' = {
  scope: rg
  name: 'functionApp'
  dependsOn: [
    appInsights
  ]
  params: {
    location: location
    tags: tags
    storageAccountName: storage.outputs.storageAccountName
    appInsightsName: appInsights.outputs.appInsightsName
  }
}

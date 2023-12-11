@description('The function app name.')
param funcName string = 'func-cloudresume'

@description('The name of the Hosting plan.')
param hostingName string = 'asp-cloudresume'

@description('The location of the Function app resources.')
param location string

param tags object

param storageAccountName string

param appInsightsName string

param databaseName string


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource database 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: databaseName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${hostingName}-${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${funcName}-${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
  kind: 'functionapp,linux'
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'PersonalWebsite_DB_ConnectionString'
          value: database.listConnectionStrings().connectionStrings[0].connectionString
        }
      ]
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'Python|3.11'
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
    serverFarmId: hostingPlan.id
  }
}

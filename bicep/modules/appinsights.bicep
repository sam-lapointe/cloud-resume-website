@description('The name of the log analytics workspace.')
param workspaceName string = 'ws-cloudresume'

@description('The name of the appliation insights.')
param insightsName string = 'insights-cloudresume'

@description('The location of the diagnostics resources.')
param location string

param tags object


resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${workspaceName}-${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${insightsName}-${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtensionEnablementBlade'
    WorkspaceResourceId: workspace.id
  }
}

output appInsightsName string = appInsights.name

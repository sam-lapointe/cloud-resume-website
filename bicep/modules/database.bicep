@description('The database name.')
param databaseName string = 'db-cloudresume'

@description('The location of the database.')
param location string

param tags object


resource database 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: '${databaseName}-${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: 'Canada East'
        failoverPriority: 0
      }
    ]
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'
      }
    }
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    ipRules: []
    minimalTlsVersion: 'Tls12'
    capabilities: [
      {
        name: 'EnableTable'
      }
      {
        name: 'EnableServerless'
      }
    ]
    enableFreeTier: false
    capacity: {
      totalThroughputLimit: 4000
    }
  }
}

resource databaseTable 'Microsoft.DocumentDB/databaseAccounts/tables@2023-09-15' = {
  parent: database
  name: 'websites_views'
  properties: {
    resource: {
      id: 'websites_views'
    }
  }
}

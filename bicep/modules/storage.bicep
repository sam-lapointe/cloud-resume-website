@description('The name of the storage account. Only lowercase characters')
param storageName string = 'cloudresume'

@description('The name for the CDN resources.')
param cdnName string = 'cdn-cloudresume'

@description('The location of the storage account.')
param location string

param tags object

@description('The path of the web index document.')
param indexDocumentPath string = 'index.html'

@description('The path to the web error document.')
param errorDocument404Path string = ''

@description('True if you want to add your custom domain.')
param customDomain bool = true


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${storageName}${take(uniqueString(resourceGroup().id), 5)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
    }
    dnsEndpointType: 'Standard'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
           enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
      }
      requireInfrastructureEncryption: false
    }
  }
}

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: resourceGroup()
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'DeploymentScript'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition.id
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deploymentScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('../scripts/enable-static-website.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: storageAccount.name
      }
      {
        name: 'IndexDocumentPath'
        value: indexDocumentPath
      }
      {
        name: 'ErrorDocument404Path'
        value: errorDocument404Path
      }
    ]
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2023-07-01-preview' = if(customDomain) {
  name: '${cdnName}-profile-${take(uniqueString(resourceGroup().id), 5)}'
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource cdnEnpoint 'Microsoft.Cdn/profiles/endpoints@2023-07-01-preview' = if(customDomain) {
  parent: cdnProfile
  name: '${cdnName}-endpoint-${take(uniqueString(resourceGroup().id), 5)}'
  location: 'Global'
  dependsOn: [
    deploymentScript
  ]
  properties: {
    origins: [
      {
        name: 'default-origin-${take(uniqueString(resourceGroup().id), 5)}'
        properties: {
          hostName: replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
          enabled: true
          httpPort: 80
          httpsPort: 443
          originHostHeader: replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
          priority: 1
          weight: 1000
        }
      }
    ]
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
    isCompressionEnabled: true
    isHttpAllowed: true
    isHttpsAllowed: true
    originHostHeader: replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
    queryStringCachingBehavior: 'IgnoreQueryString'
  }
}

output storageAccountName string = storageAccount.name
output cdnEndpoint string = cdnEnpoint.properties.hostName

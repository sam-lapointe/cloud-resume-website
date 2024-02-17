@description('The keyvault name.')
param keyvaultName string = 'kv-cloudresume'

@description('The location of the database.')
param location string

param tags object


resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
  }
}

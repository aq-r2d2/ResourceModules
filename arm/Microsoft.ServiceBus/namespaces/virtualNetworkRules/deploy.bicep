@description('Required. Name of the parent Service Bus Namespace for the Service Bus Queue.')
@minLength(6)
@maxLength(50)
param namespaceName string

@description('Optional. The name of the virtual network rule')
param name string = '${namespaceName}-vnr'

@description('Required. Resource ID of Virtual Network Subnet')
param virtualNetworkSubnetId string

@description('Optional. Customer Usage Attribution ID (GUID). This GUID must be previously registered')
param cuaId string = ''

resource pid_cuaId 'Microsoft.Resources/deployments@2021-04-01' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource namespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: namespaceName
}

resource virtualNetworkRule 'Microsoft.ServiceBus/namespaces/virtualNetworkRules@2018-01-01-preview' = {
  name: name
  parent: namespace
  properties: {
    virtualNetworkSubnetId: virtualNetworkSubnetId
  }
}

@description('The name of the virtual network rule.')
output virtualNetworkRuleName string = virtualNetworkRule.name

@description('The Resource ID of the virtual network rule.')
output virtualNetworkRuleResourceId string = virtualNetworkRule.id

@description('The name of the Resource Group the virtual network rule was created in.')
output virtualNetworkRuleResourceGroup string = resourceGroup().name

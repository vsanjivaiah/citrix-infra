targetScope = 'tenant'

@description('Provide the management group id')
param targetManagementGroupId string 

@description('Provide the subscriptionId you will place into the management group')
param subscriptionId string

resource mapSubscription 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  name: '${targetManagementGroupId}/${subscriptionId}'
}

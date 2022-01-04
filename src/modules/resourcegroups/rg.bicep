targetScope = 'subscription'

@description('Resource Group Name')
param rgName string 

@description('Resource Group Location')
param rgLocation string

@description('Resource Group Tags')
param rgTags object

var tags = !(empty(rgTags)) ? rgTags : {}

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: rgName
  location: rgLocation
  tags: tags
}

output rgDetails object = rg

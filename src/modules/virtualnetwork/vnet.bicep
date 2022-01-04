targetScope = 'resourceGroup'

@description('Virtual Network Name')
param vnetName string

@description('Virtual Network Resource Group Name')
param vnetRG object

@description('Vnet Address Prefix')
param vnetAddressPrefix array

@description('Virtual Network Subnets')
param vnetSubnets array = [
  
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: vnetRG.location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefix
    }
    subnets: vnetSubnets
  }
}



output vnetName string = vnet.name
output vnetId string = vnet.id
output vnetSubnets array = vnet.properties.subnets



targetScope = 'subscription'

param nsNames array = [
  'ns001'
  'ns002'
]
param cloudconnectornames array = [
  'cc001'
  'ns002'
]
param rgMgmtName string = 'rg-mgmt'
param rgWlName string = 'rg-wl'
param location string = 'westus2'
@allowed([
  'new'
  'existing'
])
param virtualNetworkNewOrExisting string = 'new'

param vnetName string = 'citrix-workloads-vnet'
param vnetPrexix array = [
  '10.0.0.0/16'
]

param subnet01Name string = 'untrusted'
param subnet02Name string = 'trusted'
param subnet03Name string =  'mgmt'

param subnet01Prefix string = '10.0.0.0/24'
param subnet02Prefix string = '10.0.1.0/24'
param subnet03Prefix string = '10.0.2.0/24'


param nsAdminUserName string = 'nsadministrator'
@secure()
param nsAdminPassword string 

@allowed([
  'Standard_DS3_v2'
  'Standard_DS4_v2'
])
@description('Size of ADC VM')
param nsVmSize string = 'Standard_DS3_v2'

@description('Citrix ADC Version. netscalervpx-131 is recommended. Note: 5000Mbps is supported only in 13.1 version.')
@allowed([
  'netscalervpx-131'
  'netscalervpx-130'
  'netscalervpx-121'
])
param ADCVersion string = 'netscalervpx-131'

@allowed([
  'netscalerbyol'
  'netscaler10standard'
  'netscaler10enterprise'
  'netscaler10platinum'
  'netscaler200standard'
  'netscaler200enterprise'
  'netscaler200platinum'
  'netscaler1000standard'
  'netscaler1000enterprise'
  'netscaler1000platinum'
  'netscaler3000standard'
  'netscaler3000enterprise'
  'netscaler3000platinum'
  'netscaler5000standard'
  'netscaler5000enterprise'
  'netscaler5000platinum'
])
@description('SKU of Citrix ADC Image.')
param nsVmSku string = 'netscalerbyol'



var subnets = [
  {
    name: subnet01Name
    properties: {
      addressPrefix: subnet01Prefix
    }
  }
  {
    name: subnet02Name
    properties: {
      addressPrefix: subnet02Prefix
    }
  }
  {
    name: subnet03Name
    properties: {
      addressPrefix: subnet03Prefix
    }
  }
]



// var vnetId = {
//   new: resourceId('Microsoft.Network/virtualNetworks',vnetName)
//   existing: resourceId(rgMgmtName,'Microsoft.Network/virtualNetworks',vnetName)
// }
module rgMgmt 'modules/resourcegroups/rg.bicep' = {
  scope: subscription()
  name: rgMgmtName
  params: {
    rgLocation: location
    rgName: rgMgmtName
    rgTags: {
    }
  }
}

module rgwl 'modules/resourcegroups/rg.bicep' = {
  scope: subscription()
  name: rgWlName
  params: {
    rgLocation: location
    rgName: rgWlName
    rgTags: {
    }
  }
}

module vnet 'modules/virtualnetwork/vnet.bicep' = if(virtualNetworkNewOrExisting == 'new'){
  scope: resourceGroup(rgMgmt.name)
  name: vnetName
  params: {
    vnetAddressPrefix: vnetPrexix
    vnetName: vnetName
    vnetRG: rgMgmt.outputs.rgDetails
    vnetSubnets: subnets
  }
}

module adc 'modules/netscaler/ns.bicep' = {
  name: 'adc'
  scope: resourceGroup(rgMgmt.name) 
  params: {
    snetName01: vnet.outputs.vnetSubnets[0].name
    snetName12: vnet.outputs.vnetSubnets[2].name
    vnetRGName: rgMgmt.name
    snetName11: vnet.outputs.vnetSubnets[1].name
    nsAdminPassword: nsAdminPassword
    vnetName: vnet.name
    nsAdminUserName: nsAdminUserName
    nsVmSize: nsVmSize
    nsVmSku: nsVmSku    
    ADCVersion: ADCVersion
    nsNames: nsNames
  }
}

module cloudconnector 'modules/cloudconnectors/cc.bicep' = {
  scope: resourceGroup(rgwl.name)
  name: 'cc'
  params: {
    ccSnet: vnet.outputs.vnetSubnets[2].name
    cloudConnectorAdminPassword: ''
    cloudConnectorAdminUserName: ''
    cloudConnectorOffer: ''
    cloudConnectorPublisher: ''
    cloudConnectorSKU: ''
    cloudConnectorVersion: ''
    cloudConnectorVMSize: ''
    cloudconnectornames: cloudconnectornames
  }
}





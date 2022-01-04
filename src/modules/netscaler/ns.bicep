param elbName string
param elbLocation string
param vnetRGName string
param vnetName string
param snetName01 string
param snetName11 string
param snetName12 string

var vmNS = 'ns-vpx'
var nicNS = 'ns-vpx-nic'
var nsgNS = 'ns-vpx-nic-nsg'
var lbN = 'alb'
var bePoolN = 'bepool-11'
var probeN = 'probe-11'
var ipConfN = 'ipconf-1'
var avsN = 'avl-set'
var albpipN = 'alb-publicip'
var mgmtpipNsuffix = '-mgmt-publicip'
var vnetRg = empty(vnetRGName) ? resourceGroup().name : vnetRGName
var vnetId =  resourceId(vnetRg, 'Microsoft.Network/virtualNetworks', vnetName)
var snetRef01 = '${vnetId}/subnets/${snetName01}'
var snetRef11 = '${vnetId}/subnets/${snetName11}'
var snetRef12 =  '${vnetId}/subnets/${snetName12}'
var lbId = resourceId('Microsoft.Network/loadBalancers', lbN)
var bePoolId = '${lbId}/backendAddressPools/${bePoolN}'
var probeId = '${lbId}/probes/${probeN}'
var ipConfId = '${lbId}/frontendIpConfigurations/${ipConfN}'


resource elb 'Microsoft.Network/loadBalancers@2021-03-01' = {
  name: elbName
  location: resourceGroup().location
  properties: {
    
  }
}

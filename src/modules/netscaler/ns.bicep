param elbName string
param elbLocation string
param vnetRGName string
param vnetName string
param snetName01 string
param snetName11 string
param snetName12 string

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


// resource elb 'Microsoft.Network/loadBalancers@2021-03-01' = {
//   name: elbName
//   location: resourceGroup().location
//   properties: {
    
//   }
// }

resource nsmgmtpip 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0,2): {
  name: '${vmNS}${i}${mgmtpipNsuffix}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}]

resource nsalbpip 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0,2): {
  name: '${vmNS}${i}${albpipN}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}]

//nsg rules
resource nsgint01 'Microsoft.Network/networkSecurityGroups@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-01'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh'
        properties: {
          priority: 1000
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          destinationPortRange: '22'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'autoscale-daemon'
        properties: {
          priority: 1001
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          destinationPortRange: '9001'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}]

//nsg rules for nic 11
resource nsgint11 'Microsoft.Network/networkSecurityGroups@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-11'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh'
        properties: {
          priority: 1000
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          destinationPortRange: '22'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}]

//nsg rules for nic 12
resource nsgint12 'Microsoft.Network/networkSecurityGroups@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-12'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh'
        properties: {
          priority: 1000
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          destinationPortRange: '22'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}]

resource nsavalset 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: avsN
  location: resourceGroup().location
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 20
  }
}

resource lb 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: lbN
  location: resourceGroup().location
  properties: {
    frontendIPConfigurations: [
      { 
        name: ipConfN
        properties: {
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIpAddresses', albpipN)
          }

          
        }
      }
    ]
    backendAddressPools: [
      {
        name: bePoolN 
      }
    ]
    probes: [
      {
        name: probeN 
        properties: {
          protocol: 'Tcp'
          port: 9000
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbRule1'
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          frontendIPConfiguration: {
            id: ipConfId
          }
          enableFloatingIP: true
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'
          backendAddressPool: {
            id: bePoolId
          }
          probe: {
            id: probeId
          }
        }
      }
    ]
  }
  dependsOn: [
    nsalbpip
    nsavalset
  ]
}

resource nsnic01 'Microsoft.Network/networkInterfaces@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-nic-01'
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: true
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: snetRef01
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: nsmgmtpip[i].id
          }
        }
      }
    ]
  }
}]

resource nsnic011 'Microsoft.Network/networkInterfaces@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-nic-11'
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: true
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: snetRef01
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: bePoolId
            }
          ]
        }
      }
    ]
  }
}]

resource nsnic012 'Microsoft.Network/networkInterfaces@2020-08-01' = [for i in range(0,2) : {
  name: '${nsgNS}${i}-nic-12'
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: true
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: snetRef01
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: bePoolId
            }
          ]
        }
      }
    ]
  }
}]

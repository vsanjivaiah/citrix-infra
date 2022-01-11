param cloudconnectornames array = [
  'cc001'
  'ns002'
]
param cloudConnectorVMSize string
param cloudConnectorOffer string 
param cloudConnectorPublisher string
param cloudConnectorSKU string
param cloudConnectorVersion string
param cloudConnectorAdminUserName string
@secure()
param cloudConnectorAdminPassword string

param ccSnet string

var avalsetname  = 'aval-ctx-cloudconnector'
var ccVMCount = length(cloudconnectornames)

resource ccavalset 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: avalsetname
  location: resourceGroup().location
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 5
  }
}

resource ccnic01 'Microsoft.Network/networkInterfaces@2020-08-01' = [for i in range(0,ccVMCount) : {
  name: '${cloudconnectornames[i]}-nic-01'
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: true
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: ccSnet
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource cloudConnectors 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0,ccVMCount) :{
  name: '${cloudconnectornames[i]}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: cloudConnectorVMSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: ccnic01[i].id
        }
      ]
    }
    availabilitySet: {
      id: ccavalset.id
    }
    storageProfile: {
      imageReference: {
        offer: cloudConnectorOffer
        publisher: cloudConnectorPublisher
        sku: cloudConnectorSKU
        version: cloudConnectorVersion
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        name: '${cloudconnectornames[i]}-osdisk'
        osType: 'Windows'
      }
    }
    osProfile: {
      adminUsername: cloudConnectorAdminUserName
      adminPassword: cloudConnectorAdminPassword
      computerName: '${cloudconnectornames[i]}'

    }
    
  }
}]

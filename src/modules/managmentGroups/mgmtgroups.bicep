targetScope = 'tenant'

@description('Provide prefix for the management group structure.')
param topLevelManagementGroupPrefix string
@description('Management groups for platform specific purposes, such as management, networking, identity etc.')
param platformMgs array = [
  'management'
  'connectivity'
  'identity'
]

@description('These are the landing zone management groups.')
param landingZoneMgs array = [
  'VirtualDesktop'
  'corp'
]

var enterpriseScaleManagementGroups = {
  platform: '${topLevelManagementGroupPrefix}-platform'
  landingzone: '${topLevelManagementGroupPrefix}-landingzone'
}

resource TopLevelManagmentGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: topLevelManagementGroupPrefix
}

resource PlatformManagmentGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: enterpriseScaleManagementGroups.platform
  properties: {
    displayName: enterpriseScaleManagementGroups.platform
    details:  {
      parent: {
        id: TopLevelManagmentGroup.id
      }
    }
  }
}

resource LandingzoneMgmtnd 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: enterpriseScaleManagementGroups.platform
  properties: {
    displayName: enterpriseScaleManagementGroups.landingzone
    details:  {
      parent: {
        id: TopLevelManagmentGroup.id
      }
    }
  }
}

resource PlatformChildManagmentGroups 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in platformMgs: {
  name: mg
  properties: {
    displayName: mg
    details: {
      parent: {
        id: PlatformManagmentGroup.id
      }
    }
  }
}]

resource LandingzoneChildMgmt 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in landingZoneMgs: {
  name: mg
  properties: {
    displayName: mg
    details: {
      parent: {
        id: LandingzoneMgmtnd.id
      }
    }
  }
}]

output mgmtmg object = PlatformChildManagmentGroups[0]
output connmg object = PlatformChildManagmentGroups[1]
output identitymg object = PlatformChildManagmentGroups[2]
output VirtualDesktopmg object = LandingzoneChildMgmt[0]
output corpmg object = LandingzoneChildMgmt[1]

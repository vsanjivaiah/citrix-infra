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

module mgmtGroups 'modules/managmentGroups/mgmtgroups.bicep' = {
  name: 'mgmtGroupDeployment'
  params: {
    topLevelManagementGroupPrefix: topLevelManagementGroupPrefix
    platformMgs: platformMgs
    landingZoneMgs: landingZoneMgs
  }
}

module mapmgmtmg 'modules/subscriptionmapping/mapsubscription.bicep' = {
  name: 'mgmt1'
  params: {
    subscriptionId: mgmtGroups.outputs.mgmtmg.Id
    targetManagementGroupId: mgmtGroups.outputs.mgmtmg.Id
  }

}




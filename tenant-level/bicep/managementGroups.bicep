targetScope = 'managementGroup'

param topLevelManagementGroupName string
param environment string

var childManagementGroupNames = [
  'platform'
  'online'
]

module child 'modules/managementGroups.bicep' = [
  for item in childManagementGroupNames: {
    name: 'tenantLevel-${item}-${environment}'
    params: {
      parentManagementGroupId: topLevelManagementGroupName
      managementGroupName: '${item}-${environment}'
    }
  }
]

module defaultSettings 'modules/managementGroupSettings.bicep' = if (environment == 'prod') {
  name: 'tenantLevel-defaultSettings'
  dependsOn: [
    child
  ]
  params: {
    defaultManagementGroup: 'online-${environment}'
  }
}

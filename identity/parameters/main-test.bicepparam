using '../bicep/main.bicep'

param environment = readEnvironmentVariable('managementGroupHierarchy', '')
param topLevelManagementGroupName = readEnvironmentVariable('TOP_LEVEL_MANAGEMENT_GROUP_NAME', '')
param gazelleAdminGroupId = readEnvironmentVariable('gazelleAdminGroupId', '')

var customRoles = loadJsonContent('customRoles.json')

param roles = [
  {
    roleName: customRoles['landing-zone-admin'].roleName
    scope: topLevelManagementGroupName
    principalId: '533b62b7-39c8-4eaf-b9a4-d3e034c0c3af' // landingzone-engineers-test
    actions: customRoles['landing-zone-admin'].actions
    principalType: 'Group'
  }
  {
    roleName: customRoles['landing-zone-owner'].roleName
    scope: topLevelManagementGroupName
    actions: customRoles['landing-zone-owner'].actions
    principalId: gazelleAdminGroupId
    principalType: 'Group'
  }
]

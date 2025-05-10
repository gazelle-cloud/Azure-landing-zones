using '../bicep/main.bicep'

param environment = readEnvironmentVariable('managementGroupHierarchy', '')
param topLevelManagementGroupName = readEnvironmentVariable('TOP_LEVEL_MANAGEMENT_GROUP_NAME', '')
param gazelleAdminGroupId = readEnvironmentVariable('gazelleAdminGroupId', '')

var customRoles = loadJsonContent('customRoles.json')

param roles = [
  {
    roleName: customRoles['landing-zone-admin'].roleName
    scope: topLevelManagementGroupName
    principalId: gazelleAdminGroupId
    actions: customRoles['landing-zone-admin'].actions
    principalType: 'Group'
  }
]

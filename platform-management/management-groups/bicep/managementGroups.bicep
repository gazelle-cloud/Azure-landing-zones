targetScope = 'managementGroup'

param topLevelManagementGroupName string?
param environment string?
param deploymentNameSuffix string = take(newGuid(), 4)

var childManagementGroupNames = [
  'oases'
]

module child 'modules/managementGroups.bicep' = [
  for item in childManagementGroupNames: {
    name: 'tenantLevel-${item}-${environment!}-${deploymentNameSuffix}'
    params: {
      parentManagementGroupId: topLevelManagementGroupName!
      managementGroupName: '${item}-${environment!}'
    }
  }
]

module defaultSettings 'modules/managementGroupSettings.bicep' = if (environment == 'prod') {
  name: 'tenantLevel-defaultSettings-${deploymentNameSuffix}'
  params: {
    defaultManagementGroup: 'subscription-bank'
  }
}

output GitHubActionsVariables object = {}

output GitHubRepositoryVariables object = {}

output GitHubEnvironmentVariables object = {}

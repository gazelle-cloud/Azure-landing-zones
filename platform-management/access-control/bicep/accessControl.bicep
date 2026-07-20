targetScope = 'managementGroup'

module customDefinition './modules/customRoleDefinitions.bicep' = [
  for (item, i) in accessControlMgmtLevel: {
    name: 'customRoleDefinition-${replace(item.roleName,' ', '')}-${deploymentNameSuffix}'
    params: {
      roleName: item.roleName
      actions: item.actions
      environment: environment!
    }
  }
]

module roleAssignment './modules/roleAssignment.bicep' = [
  for (item, i) in accessControlMgmtLevel: {
    name: 'roleAssignment-${replace(item.roleName,' ', '')}-${deploymentNameSuffix}'
    scope: managementGroup(item.scope)
    params: {
      principalId: item.principalId
      principalType: 'Group'
      roleDefinitionId: customDefinition[i].outputs.roleResourceId
    }
  }
]

module roleAssignmentSubscriptionBank './modules/roleAssignment.bicep' = [
  for item in subscriptionBankReader: if (environment == 'prod') {
  name: 'roleAssignment-${item}'
  scope: managementGroup(subscriptionBankName)
  params: {
    principalId: item
    principalType: 'Group'
    roleDefinitionId: roleDefinitions('Reader').id
  }
}]

module applicationEngineerRole 'modules/customRoleDefinitions.bicep' = {
  name: 'customRoleDefinition-AppEngineer-${deploymentNameSuffix}'
  params: {
    actions: appEngineerRoleActions
    environment: environment!
    roleName: 'App Engineer'
  }
}

param environment string?
param accessControlMgmtLevel accessControlType
param subscriptionBankReader array
param appEngineerRoleActions array
#disable-next-line no-unused-params
param topLevelManagementGroupName string
#disable-next-line no-unused-params
param subscriptionBankName string
#disable-next-line no-unused-params
param azurePlatformEngineerGroupId string
#disable-next-line no-unused-params
param breakGlassGroupId string
#disable-next-line no-unused-params
param applicationEngineersGroupId string
param deploymentNameSuffix string = take(newGuid(), 4)

output GitHubActionsVariables object = {}

output GitHubRepositoryVariables object = {}

output GitHubEnvironmentVariables object = {
  APP_ENGINEER_ROLE_ID: applicationEngineerRole.outputs.roleResourceId
}

type accessControlType = {
  roleName: string
  actions: array
  principalId: string
  scope: string
}[]

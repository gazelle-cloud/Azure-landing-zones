targetScope = 'managementGroup'

param environment string
param roles accessControl
#disable-next-line no-unused-params
param gazelleAdminGroupId string
#disable-next-line no-unused-params
param topLevelManagementGroupName string

module customDefinition 'modules/customRoleDefinitions.bicep' = [
  for (item, i) in roles: {
    name: 'customRoleDefinition-${replace(item.roleName,' ', '')}'
    params: {
      roleName: item.roleName
      actions: item.actions
      environment: environment
    }
  }
]

module roleAssignment 'modules/roleAssignment.bicep' = [
  for (item, i) in roles: {
    name: 'roleAssignment-${replace(item.roleName,' ', '')}'
    scope: managementGroup(item.scope)
    params: {
      principalId: item.principalId
      principalType: item.principalType
      roleDefinitionId: customDefinition[i].outputs.roleResourceId
    }
  }
]

type principalType = 'Group' | 'ServicePrincipal' | 'User'

type accessControl = {
  roleName: string
  actions: array
  principalId: string
  principalType: principalType
  scope: string
}[]

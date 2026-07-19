targetScope = 'managementGroup'

param principalId string
param roleDefinitionId string
param principalType string

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleDefinitionId, managementGroup().id, principalId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principalType
  }
}

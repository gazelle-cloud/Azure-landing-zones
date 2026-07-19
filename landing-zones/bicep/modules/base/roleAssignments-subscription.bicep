targetScope = 'subscription'

param principalId string
param roleDefinitionId string
@allowed(['ServicePrincipal', 'Group'])
param principleType string

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleDefinitionId, principalId, subscription().id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principleType
  }
}

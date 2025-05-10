targetScope = 'managementGroup'

param principlesId string
param roleDefinitions array

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for item in roleDefinitions: {
    name: guid(item, managementGroup().name, principlesId)
    properties: {
      principalId: principlesId
      roleDefinitionId: item
      principalType: 'ServicePrincipal'
    }
  }
]

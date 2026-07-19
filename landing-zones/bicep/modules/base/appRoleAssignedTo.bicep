targetScope = 'subscription'
extension microsoftGraphV1

param appRoleId string
param principalId string

resource GraphAggregatorService 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: '00000003-0000-0000-c000-000000000000'
}

resource appRole 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  appRoleId: appRoleId
  principalId: principalId
  resourceId: GraphAggregatorService.id
}

targetScope = 'subscription'
extension microsoftGraphV1  as v1

@description('https://graphpermissions.merill.net/permission/Directory.Read.All?tabs=apiv1%2CadminConsentRequestPolicy1')
param appRoleId string
param principalId string
param graphObjectId string

resource appRole 'v1:Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  appRoleId: appRoleId
  principalId: principalId
  resourceId: graphObjectId
}

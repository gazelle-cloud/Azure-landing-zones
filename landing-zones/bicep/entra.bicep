targetScope = 'subscription'

param principalId string

var graphAppRoleIds = {
  'User.Read.All': 'df021288-bdef-4463-88db-98f22de89214'
  'Group.Read.All': '5b567255-7703-4780-807c-7be8301ae99b'
  'Application.Read.All': '9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30'
}

var roles = [
  'User.Read.All'
  'Group.Read.All'
  'Application.Read.All'
]

@batchSize(1)
module EntraRoles 'modules/base/appRoleAssignedTo.bicep' = [for role in roles: {
  name: 'entra-role-${role}'
  params: {
    appRoleId: graphAppRoleIds[role]
    principalId: principalId
  }
}]

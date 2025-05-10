targetScope = 'subscription'

param principalId string


var entraObjectId = {
  MicrosoftGraph: 'bf017b10-192c-4a53-bf60-b871ddb00036'
}

var entraAppRoleId = {
  DirectoryReadAll: '7ab1d382-f21e-4acd-a863-ba3e13f7da61'
}

module EntraRole 'modules/appRoleAssignedTo.bicep' = {
  name: 'entra-roles'
  params: {
    principalId: principalId
    appRoleId: entraAppRoleId.DirectoryReadAll
    graphObjectId: entraObjectId.MicrosoftGraph
  }
}

param appName string
param environment string
param location string

var name = 'id-${appName}-${environment}'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
}


output principalId string = identity.properties.principalId
output clientId string = identity.properties.clientId
output resourceId string = identity.id

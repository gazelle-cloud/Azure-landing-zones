targetScope = 'managementGroup'

param environment string
param roleName string
param actions array


resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(roleName, environment)
  properties: {
    roleName: '${roleName} - ${environment}'
    assignableScopes: [
      managementGroup().id
    ]
    permissions: [
      {
        actions: actions
      }
    ]
  }
}

output roleName string = customRole.properties.roleName
output roleResourceId string = customRole.id

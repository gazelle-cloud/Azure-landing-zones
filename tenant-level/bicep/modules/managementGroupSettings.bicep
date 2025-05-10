targetScope = 'managementGroup'

param defaultManagementGroup string
param requireAuthorizationForGroupCreation bool = true

resource managementGroup 'Microsoft.Management/managementGroups/settings@2023-04-01' = {
  name: '${tenant().tenantId}/default'
  scope: tenant()
  properties: {
    defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${defaultManagementGroup}'
    requireAuthorizationForGroupCreation: requireAuthorizationForGroupCreation
  }
}

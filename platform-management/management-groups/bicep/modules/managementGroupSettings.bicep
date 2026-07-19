targetScope = 'managementGroup'

param defaultManagementGroup string
param requireAuthorizationForGroupCreation bool = true

resource managementGroup 'Microsoft.Management/managementGroups/settings@2024-02-01-preview' = {
  name: '${tenant().tenantId}/default'
  scope: tenant()
  properties: {
    defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${defaultManagementGroup}'
    requireAuthorizationForGroupCreation: requireAuthorizationForGroupCreation
  }
}

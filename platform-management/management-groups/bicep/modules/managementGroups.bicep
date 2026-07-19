targetScope = 'managementGroup'

param managementGroupName string
param parentManagementGroupId string

resource managementGroup 'Microsoft.Management/managementGroups@2024-02-01-preview' = {
  name: managementGroupName
  scope: tenant()
  properties: {
    displayName: managementGroupName
    details: {
      parent: {
        id: parentManagementGroupId
      }
    }
  }
}

output mgmtName string = managementGroup.name
output mgmtId string = managementGroup.id

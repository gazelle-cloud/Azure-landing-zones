targetScope = 'managementGroup'

param location string = deployment().location
param displayName string
param parameters object
param policyDefinitionId string
param name string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: name
  location: location
  properties: {
    displayName: displayName
    parameters: parameters
    policyDefinitionId: policyDefinitionId
  }
}

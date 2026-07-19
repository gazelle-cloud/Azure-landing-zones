targetScope = 'managementGroup'

param policyName string
param displayName string
param location string
param setDefinitions array

var shortenPolicyName = take(policyName, 24)

resource initiative 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
  name: shortenPolicyName
  properties: {
    displayName: displayName
    policyDefinitions: setDefinitions
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: shortenPolicyName
  location: location
  properties: {
    policyDefinitionId: initiative.id
    displayName: displayName
  }
}

output resourceId string = assignment.id

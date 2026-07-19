targetScope = 'subscription'

param policyExemptionName string
param policyAssignmentId string
param description string
param policyDefinitionReferenceIds array

resource policyExemption 'Microsoft.Authorization/policyExemptions@2024-12-01-preview' = {
  name: policyExemptionName
  properties: {
    exemptionCategory: 'Waiver'
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceIds: policyDefinitionReferenceIds
    description: description
  }
}


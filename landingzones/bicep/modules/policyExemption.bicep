targetScope = 'subscription'

param policyExemptionName string = 'Recommendations-Not-Applicable'
param policyAssignmentId string
param description string = 'Recommendations does not align with landing zone design'
param policyDefinitionReferenceIds array

resource policyExemption 'Microsoft.Authorization/policyExemptions@2022-07-01-preview' = {
  name: policyExemptionName
  properties: {
    exemptionCategory: 'Waiver'
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceIds: policyDefinitionReferenceIds
    description: description
  }
}

targetScope = 'managementGroup'

param environment string
param location string = deployment().location
param deploymentNameSuffix string = take(newGuid(), 4)

var customPolicyScope = '/providers/Microsoft.Management/managementGroups/oases-${environment}/providers/Microsoft.Authorization/policyDefinitions'
var policyAssignmentScope = 'oases-${environment}'

module allowedResources 'modules/assignment.bicep' = {
  name: 'policy-allowedResources-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    location: location
    displayName: 'Allowed Resources'
    policyName: 'allowedResources'
    setDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
        policyDefinitionReferenceId: 'allowed-resources'
        parameters: {
          listOfResourceTypesAllowed: {
            value: loadJsonContent('../parameters/oases/allowedResources.json')
          }
        }
      }
    ]
  }
}

module allowedLocations 'modules/assignment.bicep' = {
  name: 'policy-allowedLocations-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    policyName: 'allowedLocations'
    location: location
    displayName: 'Allowed Locations'
    setDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
        policyDefinitionReferenceId: 'allowed-locations-resourceGroups'
        parameters: {
          listOfAllowedLocations: {
            value: [
              location
            ]
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
        policyDefinitionReferenceId: 'allowed-locations'
        parameters: {
          listOfAllowedLocations: {
            value: [
              location
            ]
          }
        }
      }
    ]
  }
}

module denyLocalAuthentication 'modules/assignment.bicep' = {
  name: 'policy-denyLocalAuthentication-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    policyName: 'denyLocalAuthentication'
    displayName: 'Deny Local Authentication Methods'
    location: location
    setDefinitions: json(replace(
      loadTextContent('../parameters/oases/denyLocalAuthentication.json'),
      '{{custom}}',
      customPolicyScope
    ))
  }
}

module denyPublicNetworkAccess 'modules/assignment.bicep' = {
  name: 'policy-denyPublicNetworkAccess-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    policyName: 'denyPublicNetworkAccess'
    displayName: 'Deny Public Network Access'
    location: location
    setDefinitions: json(replace(
      loadTextContent('../parameters/oases/denyPublicNetworkAccess.json'),
      '{{custom}}',
      customPolicyScope
    ))
  }
}

module denyCrossTenantReplication 'modules/assignment.bicep' = {
  name: 'policy-denyCrossTenantReplication-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    displayName: 'Deny Cross Tenant Replication'
    policyName: 'denyCrossTenantReplication'
    location: location
    setDefinitions: json(replace(
      loadTextContent('../parameters/oases/denyCrossTenantReplication.json'),
      '{{custom}}',
      customPolicyScope
    ))
  }
}

module denyWeakTLS 'modules/assignment.bicep' = {
  name: 'policy-denyWeakTLS-${deploymentNameSuffix}'
  scope: managementGroup(policyAssignmentScope)
  params: {
    location: location
    displayName: 'Deny Weak TLS'
    policyName: 'denyWeakTLS'
    setDefinitions: json(replace(
      loadTextContent('../parameters/oases/denyWeakTLS.json'),
      '{{custom}}',
      customPolicyScope
    ))
  }
}

output GitHubActionsVariables object = {
  policy_assignment_scope: policyAssignmentScope
}

output GitHubRepositoryVariables object = {}

output GitHubEnvironmentVariables object = {}

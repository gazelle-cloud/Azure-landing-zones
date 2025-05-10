targetScope = 'managementGroup'

param environment string

module allowedResources 'modules/assignment.bicep' = {
  name: 'policy-allowedResources'
  scope: managementGroup('online-${environment}')
  params: {
    location: deployment().location
    displayName: 'Allowed Resources'
    policyName: 'allowedResources'
    setDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
        policyDefinitionReferenceId: 'allowed-resources'
        parameters: {
          listOfResourceTypesAllowed: {
            value: loadJsonContent('../parameters/online/allowedResources.json')
          }
        }
      }
    ]
  }
}

module allowedLocations 'modules/assignment.bicep' = {
  name: 'policy-allowedLocations'
  scope: managementGroup('online-${environment}')
  params: {
    policyName: 'allowedLocations'
    location: deployment().location
    displayName: 'Allowed Locations'
    setDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
        policyDefinitionReferenceId: 'allowed-locations-resourceGroups'
        parameters: {
          listOfAllowedLocations: {
            value: [
              deployment().location
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
              deployment().location
            ]
          }
        }
      }
    ]
  }
}

module denyLocalAuthentication 'modules/assignment.bicep' = {
  name: 'policy-denyLocalAuthentication'
  scope: managementGroup('online-${environment}')
  params: {
    policyName: 'denyLocalAuthentication'
    displayName: 'Deny Local Authentication Methods'
    location: deployment().location
    setDefinitions: loadJsonContent('../parameters/online/denyLocalAuthentication.json')
  }
}

module denyPublicNetworkAccess 'modules/assignment.bicep' = {
  name: 'policy-denyPublicNetworkAccess'
  scope: managementGroup('online-${environment}')
  params: {
    policyName: 'denyPublicNetworkAccess'
    displayName: 'Deny Public Network Access'
    location: deployment().location
    setDefinitions: loadJsonContent('../parameters/online/denyPublicNetworkAccess.json')
  }
}

output GitHubRepositoryVariables object = {
  policy_online_allowed_resources_id: allowedResources.outputs.resourceId
  policy_online_allowed_locations_id: allowedLocations.outputs.resourceId
  policy_online_deny_local_authentication_id: denyLocalAuthentication.outputs.resourceId
  policy_online_deny_public_network_access_id: denyPublicNetworkAccess.outputs.resourceId
}

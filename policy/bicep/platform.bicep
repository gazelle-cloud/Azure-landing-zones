targetScope = 'managementGroup'

param environment string
param diagnosticSettingsPolicyResourceId string
param logAnalyticsResourceId string
param policyIdentityResourceId string
param platformEngineerEmail string

module allowedResources 'modules/assignment.bicep' = {
  name: 'policy-allowedResources'
  scope: managementGroup('platform-${environment}')
  params: {
    displayName: 'Allowed Resources'
    policyName: 'allowedResources'
    setDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
        policyDefinitionReferenceId: 'allowed-resources'
        parameters: {
          listOfResourceTypesAllowed: {
            value: loadJsonContent('../parameters/platform/allowedResources.json')
          }
        }
      }
    ]
  }
}

module allowedLocations 'modules/assignment.bicep' = {
  name: 'policy-allowedLocations'
  scope: managementGroup('platform-${environment}')
  params: {
    policyName: 'allowedLocations'
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
  scope: managementGroup('platform-${environment}')
  params: {
    policyName: 'denyLocalAuthentication'
    displayName: 'Deny Local Authentication Methods'
    setDefinitions: loadJsonContent('../parameters/platform/denyLocalAuthentication.json')
  }
}

module denyPublicNetworkAccess 'modules/assignment.bicep' = {
  name: 'policy-denyPublicNetworkAccess'
  scope: managementGroup('platform-${environment}')
  params: {
    policyName: 'denyPublicNetworkAccess'
    displayName: 'Deny Public Network Access'
    setDefinitions: loadJsonContent('../parameters/platform/denyPublicNetworkAccess.json')
  }
}

module diagnosticSettings 'modules/policyAssignment.bicep' = {
  name: 'policy-diagnosticSettings'
  scope: managementGroup('platform-${environment}')
  params: {
    name: 'configDiagnosticSettings'
    displayName: 'Config Diagnostic Settings'
    identityResourceId: policyIdentityResourceId
    policyDefinitionId: diagnosticSettingsPolicyResourceId
    parameters: {
      logAnalytics: {
        value: logAnalyticsResourceId
      }
    }
  }
}

module tags 'modules/policyAssignment.bicep' = {
  name: 'policy-tag-engineer-email'
  scope: managementGroup('platform-${environment}')
  params: {
    name: 'tag-platformEngineer'
    displayName: 'Config Tag: Platform Engineer Contact'
    identityResourceId: policyIdentityResourceId
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1'
    parameters: {
      tagName: {
        value: 'engineerEmail'
      }
      tagValue: {
        value: platformEngineerEmail
      }
    }
  }
}

output GitHubRepositoryVariables object = {
  policy_platform_allowed_resources_id: allowedResources.outputs.resourceId
  policy_platform_allowed_locations_id: allowedLocations.outputs.resourceId
  policy_platform_deny_local_authentication_id: denyLocalAuthentication.outputs.resourceId
  policy_platform_deny_public_network_access_id: denyPublicNetworkAccess.outputs.resourceId
}

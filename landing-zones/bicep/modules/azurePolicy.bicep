targetScope = 'subscription'

param location string
param identityResourceId string
param diagnosticSettingsPolicyResourceId string
param logAnalyticsResourceId string
param resourceLevelTags object
param subscriptionLevelTags object
param exemptions array
param defenderRecommendationExemptions bool
param diagSettingsExemption bool = false

var defenderForCloudExemptions = loadJsonContent('../../defenderForCloudExemptions.jsonc')

module configDiagnosticSettings 'base/policyAssignment.bicep' = {
  name: 'lz-config-diagnosticSettings'
  params: {
    name: 'config-diagnosticSettings'
    location: location
    displayName: 'Config Diagnostic Settings'
    identityResourceId: identityResourceId
    policyDefinitionId: diagnosticSettingsPolicyResourceId
    parameters: {
      logAnalytics: {
        value: logAnalyticsResourceId
      }
    }
  }
}

module resourceTagsPolicy 'base/policyAssignment.bicep' = [
  for item in items(resourceLevelTags): {
    name: 'lz-resourceLevelTag-${item.key}'
    params: {
      name: 'Config-ResourceLevelTag-${item.key}'
      location: location
      displayName: 'Config Resource Level Tag: ${item.key}'
      identityResourceId: identityResourceId
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4f9dc7db-30c1-420c-b61a-e1d640128d26'
      parameters: {
        tagName: {
          value: item.key
        }
        tagValue: {
          value: item.value
        }
      }
    }
  }
]

module subscriptionTagsPolicy 'base/policyAssignment.bicep' = [
  for item in items(subscriptionLevelTags): {
    name: 'lz-subscriptionLevelTag-${item.key}'
    params: {
      name: 'Config-SubscriptionLevelTag-${item.key}'
      location: location
      displayName: 'Config Subscription Level Tag: ${item.key}'
      identityResourceId: identityResourceId
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1'
      parameters: {
        tagName: {
          value: item.key
        }
        tagValue: {
          value: item.value
        }
      }
    }
  }
]

module customExemption 'base/policyExemption.bicep' = [
  for item in exemptions: {
    params: {
      description: item.clarifications
      policyAssignmentId: item.policyToExclude
      policyDefinitionReferenceIds: item.referenceId
      policyExemptionName: 'lzparam-${split(item.policyToExclude, '/')[8]}'
    }
  }
]

module defenderForCloud 'base/policyExemption.bicep' = if (defenderRecommendationExemptions) {
  name: 'lz-policyExemption-defenderForCloud'
  params: {
    policyExemptionName: 'not applicable reccomendations'
    description: ''
    policyAssignmentId: '${subscription().id}/providers/Microsoft.Authorization/policyAssignments/SecurityCenterBuiltIn'
    policyDefinitionReferenceIds: defenderForCloudExemptions
  }
}

module diagSettingsPolicyExemption 'base/policyExemption.bicep' = if (diagSettingsExemption) {
  name: 'lz-policyExemption-diagSettings'
  dependsOn: [configDiagnosticSettings]
  params: {
    policyExemptionName: 'default'
    description: 'Opted out of automatic diagnostic settings configuration.'
    policyAssignmentId: '${subscription().id}/providers/Microsoft.Authorization/policyAssignments/config-diagnosticSettings'
    policyDefinitionReferenceIds: []
  }
}

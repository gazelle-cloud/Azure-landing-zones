targetScope = 'subscription'

param parameters object
param addressPrefix string
param diagnosticSettingsPolicyResourceId string
param GitHubOrganizationName string = 'gazelle-cloud'
param GitHubRepositoryName string = 'MSDN'

var defenderForCLoudExemptions = loadJsonContent('../defenderForCLoudExemptions.jsonc')

var subscriptionTags = {
  engineerEmail: parameters.engineerEmail
}

resource landingzoneResources 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'landingzone-resources'
  location: deployment().location
}

module identity 'modules/identity.bicep' = {
  name: 'lz-serviceConnectionIdentity'
  params: {
    appName: parameters.appName
    environment: parameters.environment
    location: deployment().location
    githubOrganizationName: GitHubOrganizationName
    githubRepoName: GitHubRepositoryName
    landingzoneResourceGroupName: landingzoneResources.name
  }
}

module subscriptionLevelTags 'modules/policyAssignment.bicep' = [
  for item in items(subscriptionTags): {
    name: 'lz-tag-${item.key}'
    params: {
      name: 'config-tag-${item.key}'
      location: deployment().location
      displayName: 'Config Tag: ${item.key}'
      identityResourceId: identity.outputs.resourceId
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

module configDiagnosticSettings 'modules/policyAssignment.bicep' = {
  name: 'lz-config-diagnosticSettings'
  params: {
    name: 'config-diagnosticSettings'
    location: deployment().location
    displayName: 'Config Diagnostic Settings'
    identityResourceId: identity.outputs.resourceId
    policyDefinitionId: diagnosticSettingsPolicyResourceId
    parameters: {
      logAnalytics: {
        value: logAnalytics.outputs.logAnalyticsResourceId
      }
    }
  }
}

module budget 'modules/budget.bicep' = {
  name: 'lz-budget-configuration'
  params: {
    budgetAmount: int(parameters.budget)
    actionGroupResourceId: actionGroup.outputs.resourceId
  }
}

module securityContacts 'modules/securityContacts.bicep' = {
  name: 'lz-security-contacts'
  params: {
    engineerEmail: parameters.engineerEmail
  }
}

module actionGroup 'modules/actionGroup.bicep' = {
  scope: landingzoneResources
  name: 'lz-actionGroup-notify'
  params: {
    email: parameters.engineerEmail
  }
}

module alert 'modules/ActivityLogAlerts.bicep' = {
  scope: landingzoneResources
  name: 'lz-health-alert'
  params: {
    actionGroupId: actionGroup.outputs.resourceId
  }
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: landingzoneResources
  name: 'lz-vnet-deployment'
  params: {
    appName: parameters.appName
    environment: parameters.environment
    location: deployment().location
    addressPrefix: addressPrefix
  }
}

module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  scope: landingzoneResources
  name: 'lz-logAnalytics'
  params: {
    appName: parameters.appName
    environment: parameters.environment
    location: deployment().location
  }
}

module policyExemption 'modules/policyExemption.bicep' = {
  name: 'lz-policyExemption-defenderForCloud'
  params: {
    policyAssignmentId: '${subscription().id}/providers/Microsoft.Authorization/policyAssignments/SecurityCenterBuiltIn'
    policyDefinitionReferenceIds: defenderForCLoudExemptions
  }
}

output GitHubRepositoryVariables object = {
  serviceConnection_client_Id: identity.outputs.clientId
}

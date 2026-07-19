targetScope = 'managementGroup'

param policyDefinitions array

resource diagnosticSettings 'Microsoft.Authorization/policySetDefinitions@2026-01-01-preview' = {
  name: 'diagnosticSettings'
  properties: {
    displayName: 'config diagnostic settings'
    parameters: {
      effect: {
        type: 'String'
        defaultValue: 'DeployIfNotExists'
      }
      logAnalytics: {
        type: 'String'
      }
      categoryGroup: {
        type: 'String'
        defaultValue: 'allLogs'
      }
      diagnosticSettingName: {
        type: 'String'
        defaultValue: 'set-by-create-landingzone'
      }
    }
    policyDefinitions: policyDefinitions
  }
}

output GitHubEnvironmentVariables object = {
  policy_config_diagnosticsettings_resource_id: diagnosticSettings.id
}

output GitHubActionsVariables object = {}

output GitHubRepositoryVariables object = {}

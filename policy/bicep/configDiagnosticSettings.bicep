targetScope = 'managementGroup'

var policyDefinitions = [
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3234ff41-8bec-40a3-b5cb-109c95f1c8ce'
    policyDefinitionReferenceId: 'virtual-network'
    parameters: policyParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/baa4c6de-b7cf-4b12-b436-6e40ef44c8cb'
    policyDefinitionReferenceId: 'network-security-group'
    parameters: policyParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/818719e5-1338-4776-9a9d-3c31e4df5986'
    policyDefinitionReferenceId: 'log-analytics'
    parameters: policyParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b4fe1a3b-0715-4c6c-a5ea-ffc33cf823cb'
    policyDefinitionReferenceId: 'storage-blob'
    parameters: storageParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7bd000e3-37c7-4928-9f31-86c4b77c5c45'
    policyDefinitionReferenceId: 'storage-queue'
    parameters: storageParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2fb86bf3-d221-43d1-96d1-2434af34eaa0'
    policyDefinitionReferenceId: 'storage-table'
    parameters: storageParameters
  }
  {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/25a70cc8-2bd4-47f1-90b6-1478e4662c96'
    policyDefinitionReferenceId: 'storage-file'
    parameters: storageParameters
  }
]

var policyParameters = {
  effect: {
    value: '[parameters(\'effect\')]'
  }
  categoryGroup: {
    value: '[parameters(\'categoryGroup\')]'
  }
  diagnosticSettingName: {
    value: '[parameters(\'diagnosticSettingName\')]'
  }
  logAnalytics: {
    value: '[parameters(\'logAnalytics\')]'
  }
}

var storageParameters = {
  effect: {
    value: '[parameters(\'effect\')]'
  }
  profileName: {
    value: '[parameters(\'diagnosticSettingName\')]'
  }
  logAnalytics: {
    value: '[parameters(\'logAnalytics\')]'
  }
  metricsEnabled: {
    value: false
  }
}

resource initiative 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
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

output GitHubRepositoryVariables object = {
  Policy_config_diagnosticSettings_resource_Id: initiative.id
}

targetScope = 'managementGroup'

param customDefinitions array
param environment string?

var policyDefinitionScope = 'oases-${environment}'

@batchSize(10)
module policyDefinitions 'modules/policyDefinitions.bicep' = [
  for item in customDefinitions: {
    name: 'policy-definition-${item.name}'
    scope: managementGroup(policyDefinitionScope)
    params: {
      policyName: item.name
      policyProperties: item.properties
    }
  }
]

output GitHubActionsVariables object = {}

output GitHubRepositoryVariables object = {}

output GitHubEnvironmentVariables object = {}

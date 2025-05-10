targetScope = 'managementGroup'

var customDefinitions = [
  loadJsonContent('st_allowCrossTenantReplication.json')
  loadJsonContent('st_virtualNetworkRules.json')
]

@batchSize(10)
module abc '../../bicep/modules/policyDefinitions.bicep' = [for item in customDefinitions: {
  name: 'policy-definition-${item.name}'
  params: {
    policyName: item.name
    policyProperties: item.properties
  }
}]

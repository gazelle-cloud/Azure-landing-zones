using '../../bicep/customPolicyDefinitions.bicep'

param customDefinitions = [
  loadJsonContent('st_allowCrossTenantReplication.json')
  loadJsonContent('st_virtualNetworkRules.json')
  loadJsonContent('cae_publicNetworkAccess.json')
]

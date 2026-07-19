using '../bicep/main.bicep'

param appName = '__AppName__'
param environment = '__environment__'
param budget = __budget__
param vnetAddressSpace = [
  '__vnetAddressSpace__'
]
param subscriptionId = '__subscriptionId__'
param subscriptionLevelTags = {
  engineerEmail: engineerEmail
  ownerEmail: ownerEmail
}
param resourceLevelTags = {}
param defenderRecommendationExemptions = false
param diagSettingsExemption = false
param exemptions = []

// values are fetched from GitHub Variables
param appEngineerEntraGroupId = readEnvironmentVariable('ENTRAID_READER_GROUP_ID', '')
param appEngineerRoleDefinitionId = readEnvironmentVariable('APP_ENGINEER_ROLE_ID', '')
param diagnosticSettingsPolicyResourceId = readEnvironmentVariable('POLICY_CONFIG_DIAGNOSTICSETTINGS_RESOURCE_ID', '')
param engineerEmail = readEnvironmentVariable('ENGINEER_CONTACT', '')
param ownerEmail = readEnvironmentVariable('OWNER_CONTACT', '')
param GitHubOrganizationDatabaseId = readEnvironmentVariable('GH_ORGANIZATION_DATABASE_ID', '')

#disable-next-line no-unused-vars
var policyReference = loadJsonContent('policy-assignment-reference.json')

using '../bicep/main.bicep'

param appName = 'HeyAzure'
param environment = 'prod'
param budget = 10
param vnetAddressSpace = [
  '10.10.1.0/24'
]
param subscriptionId = '00000000-0000-0000-0000-000000000000'
param subscriptionLevelTags = {
  engineerEmail: engineerEmail
  ownerEmail: ownerEmail
}
param resourceLevelTags = {
  engineerEmail: engineerEmail
}
param defenderRecommendationExemptions = true
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

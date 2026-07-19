targetScope = 'subscription'

param location string = deployment().location
param engineerEmail string
#disable-next-line no-unused-params
param ownerEmail string
param appName string
param environment string
param budget int
param vnetAddressSpace array
param GitHubOrganizationDatabaseId string
param diagnosticSettingsPolicyResourceId string
param appEngineerEntraGroupId string
param appEngineerRoleDefinitionId string
param subscriptionLevelTags object
param resourceLevelTags object
param exemptions exemptionType
param defenderRecommendationExemptions bool
param diagSettingsExemption bool = false
param GitHubOrganizationName string?
param GitHubRepositoryName string?
#disable-next-line no-unused-params
param subscriptionId string

var PowerShellJobs = {
  'cleanup-Roles': {
    variables: []
  }
  'remediate-Policies': {
    variables: []
  }
}

resource landingzoneResources 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'landingzone-resources'
  location: location
}

module identity 'modules/identity.bicep' = {
  name: 'lz-identity'
  params: {
    appName: appName
    environment: environment
    location: location
    githubOrganizationName: GitHubOrganizationName!
    githubRepoName: GitHubRepositoryName!
    landingzoneResourceGroupName: landingzoneResources.name
    appEngineerEntraGroupId: appEngineerEntraGroupId
    appEngineerRoleDefinitionId: appEngineerRoleDefinitionId
  }
}

module virtualNetwork 'modules/base/virtualNetwork.bicep' = {
  name: 'lz-vnet'
  scope: landingzoneResources
  params: {
    appName: appName
    environment: environment
    location: location
    vnetAddressSpace: vnetAddressSpace
    GitHubOrganizationDatabaseId: GitHubOrganizationDatabaseId
  }
}

module azurePolicy 'modules/azurePolicy.bicep' = {
  name: 'lz-azure-policy'
  params: {
    location: location
    exemptions: exemptions
    identityResourceId: identity.outputs.resourceId
    resourceLevelTags: resourceLevelTags
    subscriptionLevelTags: subscriptionLevelTags
    diagnosticSettingsPolicyResourceId: diagnosticSettingsPolicyResourceId
    logAnalyticsResourceId: monitor.outputs.logAnalyticsResourceId
    defenderRecommendationExemptions: defenderRecommendationExemptions
    diagSettingsExemption: diagSettingsExemption
  }
}

module automationJobs 'modules/landingzone-automation.bicep' = {
  name: 'lz-automationJobs'
  scope: landingzoneResources
  params: {
    appName: appName
    location: location
    environment: environment
    GitHubOrganizationName: GitHubOrganizationName!
    PowerShellJobs: PowerShellJobs
    identityClientId: identity.outputs.clientId
    identityResourceId: identity.outputs.resourceId
  }
}

module monitor 'modules/monitor.bicep' = {
  name: 'lz-monitor'
  scope: landingzoneResources
  params: {
    appName: appName
    location: location
    engineerEmail: engineerEmail
    environment: environment
  }
}

module budgets 'modules/base/budget.bicep' = {
  name: 'lz-budget'
  params: {
    budgetAmount: budget
    actionGroupResourceId: monitor.outputs.actionGroupResourceId
  }
}

module securityContacts 'modules/base/securityContacts.bicep' = {
  name: 'lz-security-contacts'
  params: {
    engineerEmail: engineerEmail
  }
}

output GitHubEnvironmentVariables object = {
  service_connection_client_id: identity.outputs.clientId
  virtual_network_resource_id: virtualNetwork.outputs.resourceId
  log_analytics_workspace_id: monitor.outputs.logAnalyticsResourceId
  managed_identity_resource_id: identity.outputs.resourceId
  gh_runners_subnet_resource_id: virtualNetwork.outputs.GitHubSubnetResourceId
}

output GitHubActionsVariables object = {
  gh_network_id: virtualNetwork.outputs.GitHubNetworkId
  landingzone_principal_id: identity.outputs.principalId
}

type exemptionType = {
  policyToExclude: string
  referenceId: array
  clarifications: string
}[]

targetScope = 'resourceGroup'

param appName string
param environment string
param location string
param identityResourceId string
param identityClientId string
param GitHubOrganizationName string
param PowerShellJobs object

module containerAppEnvironment 'base/managedEnvironments.bicep' = {
  params: {
    appName: appName
    environment: environment
    location: location
  }
}

module automationJobs 'base/jobs-cron.bicep' = [
  for item in items(PowerShellJobs): {
    name: 'cron-${item.key}'
    params: {
      environment: environment!
      location: location
      environmentId: containerAppEnvironment.outputs.environmentResourceId
      userAssignedIdentityResourceId: identityResourceId
      jobName: item.key
      userAssignedIdentityClientId: identityClientId
      containerEnvironmentVariables: item.value.variables
      GitHubOrganizationName: GitHubOrganizationName!
    }
  }
]

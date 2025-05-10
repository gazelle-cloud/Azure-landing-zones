targetScope = 'managementGroup'

param appName string = 'automation'
param environment string
param subscriptionId string
param logAnalyticsResourceId string
param topLevelManagementGroupName string

var azureRoles = loadJsonContent('../../AzureRoleDefinitions.json')
var automationResourceGroup = '${appName}-${environment}'

var logAnalyticsName = split(logAnalyticsResourceId, '/')[8]
var logAnalyticsResourceGroup = split(logAnalyticsResourceId, '/')[4]

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
  scope: az.resourceGroup(subscriptionId, logAnalyticsResourceGroup)
}

module resourceGroup 'modules/resourceGroup.bicep' = {
  scope: az.subscription(subscriptionId)
  name: '${appName}-resourceGroup'
  params: {
    location: deployment().location
    resourceGroupName: automationResourceGroup
  }
}

module managedEnvironment 'modules/managedEnvironments.bicep' = {
  scope: az.resourceGroup(subscriptionId, automationResourceGroup)
  name: '${appName}-appEnvrionment'
  dependsOn: [
    resourceGroup
  ]
  params: {
    appName: appName
    location: deployment().location
    environment: environment
    logAnalyticsWorkspaceId: logAnalytics.properties.customerId
    logAnalyticsPrimaryKey: logAnalytics.listKeys().primarySharedKey
  }
}

module automationIdentity 'modules/userAssignedManagedIdentity.bicep' = {
  scope: az.resourceGroup(subscriptionId, automationResourceGroup)
  name: '${appName}-uami'
  dependsOn: [
    resourceGroup
  ]
  params: {
    environment: environment
    appName: appName
    location: deployment().location
  }
}

module rbacManagementGroupLevel 'modules/roleAssignment.bicep' = {
  name: '${appName}-identity-rbac'
  params: {
    principlesId: automationIdentity.outputs.principalId
    roleDefinitions: [
      azureRoles.Contributor
      azureRoles.RoleBasedAccessControlAdministrator
    ]
  }
}


module timeAttack 'modules/jobs-timeBased.bicep' = {
  scope: az.resourceGroup(subscriptionId, automationResourceGroup)
  name: '${appName}-job-timeAttack'
  params: {
    jobName: 'timeattack'
    location: deployment().location
    environment: environment
    environmentId: managedEnvironment.outputs.environmentResourceId
    userAssignedIdentityResourceId: automationIdentity.outputs.resourceId
    containerEnvironmentVariables: [
      {
        name: 'topLevelManagementGroupName'
        value: topLevelManagementGroupName
      }
      {
        name: 'identityClientId'
        value: automationIdentity.outputs.clientId
      }
    ]
  }
}

module orphaned 'modules/jobs-timeBased.bicep' = {
  scope: az.resourceGroup(subscriptionId, automationResourceGroup)
  name: '${appName}-job-orphaned'
  params: {
    jobName: 'cleanup-orphaned-roles'
    environment: environment
    location: deployment().location
    environmentId: managedEnvironment.outputs.environmentResourceId
    userAssignedIdentityResourceId: automationIdentity.outputs.resourceId
    containerEnvironmentVariables: [
      {
        name: 'identityClientId'
        value: automationIdentity.outputs.clientId
      }
    ]
  }
}

output GitHubEnvironmentVariables object = {
  principalId: automationIdentity.outputs.principalId
}

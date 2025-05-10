targetScope = 'managementGroup'

param appName string = 'monitor'
param environment string
param subscriptionId string
param engineerEmail string

var monitorResourceGroup = '${appName}-${environment}'

module resourceGroup 'modules/resourceGroup.bicep' = {
  scope: az.subscription(subscriptionId)
  name: '${appName}-resourceGroup'
  params: {
    location: deployment().location
    resourceGroupName: monitorResourceGroup
  }
}

module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  scope: az.resourceGroup(subscriptionId, monitorResourceGroup)
  name: '${appName}-logAnalytics'
  dependsOn: [
    resourceGroup
  ]
  params: {
    appName: appName
    environment: environment
    location: deployment().location
  }
}

module actionGroup 'modules/actionGroup.bicep' = {
  scope: az.resourceGroup(subscriptionId, monitorResourceGroup)
  name: '${appName}-actionGroup'
  dependsOn: [
    resourceGroup
  ]
  params: {
    email: engineerEmail
  }
}

module healthAlert 'modules/ActivityLogAlerts.bicep' = {
  scope: az.resourceGroup(subscriptionId, monitorResourceGroup)
  name: '${appName}-healthAlert'
  dependsOn: [
    resourceGroup
  ]
  params: {
    actionGroupId: actionGroup.outputs.resourceId
  }
}

module securityAlerts 'modules/securityContacts.bicep' = {
  scope: az.subscription(subscriptionId)
  name: '${appName}-securityNotifications'
  params: {
    engineerEmail: engineerEmail
  }
}

output GitHubRepositoryVariables object = {
  log_analytics_resource_id: logAnalytics.outputs.logAnalyticsResourceId
}

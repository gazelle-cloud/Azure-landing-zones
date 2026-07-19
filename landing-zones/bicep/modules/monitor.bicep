targetScope = 'resourceGroup'

param appName string
param environment string
param location string
param engineerEmail string

module actionGroup 'base/actionGroup.bicep' = {
  name: 'lz-actionGroup-notify'
  params: {
    email: engineerEmail
  }
}

module healthAlert 'base/ActivityLogAlerts.bicep' = {
  name: 'lz-health-alert'
  params: {
    actionGroupId: actionGroup.outputs.resourceId
  }
}

module logAnalytics 'base/logAnalyticsWorkspace.bicep' = {
  name: 'lz-logAnalytics'
  params: {
    appName: appName
    environment: environment
    location: location
  }
}

output logAnalyticsResourceId string = logAnalytics.outputs.logAnalyticsResourceId
output actionGroupResourceId string = actionGroup.outputs.resourceId

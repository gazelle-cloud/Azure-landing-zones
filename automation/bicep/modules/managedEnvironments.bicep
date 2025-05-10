param appName string
param environment string
param location string
param logAnalyticsWorkspaceId string
param logAnalyticsPrimaryKey string
@allowed(['Disabled', 'Enabled'])
param publicNetworkAccess string = 'Disabled'

resource appEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: 'cae-${appName}-${environment}'
  location: location
  properties: {
    publicNetworkAccess: publicNetworkAccess
    peerTrafficConfiguration: {
      encryption: {
        enabled: true
      }
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspaceId
        sharedKey: logAnalyticsPrimaryKey
        dynamicJsonColumns: false
      }
    }
  }
}

output environmentResourceId string = appEnv.id

param appName string
param environment string
param location string

resource appEnv 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: 'cae-${appName}-${environment}'
  location: location
  properties: {
    publicNetworkAccess: 'Disabled'
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    appLogsConfiguration: {
      destination: 'azure-monitor'
    }
  }
}

output environmentResourceId string = appEnv.id

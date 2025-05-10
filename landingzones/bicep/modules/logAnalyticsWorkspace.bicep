param appName string
param environment string
param location string
param retentionInDays int = 90

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'la-${appName}-${environment}'
  location: location
  properties: {
    retentionInDays: retentionInDays
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsResourceId string = logAnalytics.id

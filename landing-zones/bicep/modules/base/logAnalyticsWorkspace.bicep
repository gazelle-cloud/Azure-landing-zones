param appName string
param environment string
param location string
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: 'la-${appName}-${environment}'
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsResourceId string = logAnalytics.id

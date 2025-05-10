param appName string
param environment string
param location string
param retentionInDays int = 30

// https://learn.microsoft.com/en-us/azure/azure-monitor/logs/basic-logs-azure-tables
var basicTables = [
  'StorageTableLogs'
  'StorageQueueLogs'
  'StorageFileLogs'
  'StorageBlobLogs'
]

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

module tables 'logAnalyticsWorkspace-tables.bicep' = [
  for item in basicTables: {
    name: '${appName}-tables-${item}'
    params: {
      logAnalyticsName: logAnalytics.name
      tableName: item
    }
  }
]

output logAnalyticsResourceId string = logAnalytics.id

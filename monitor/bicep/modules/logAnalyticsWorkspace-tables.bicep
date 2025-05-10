param logAnalyticsName string
param tableName string

resource existingWOrkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource tables 'Microsoft.OperationalInsights/workspaces/tables@2023-09-01' = {
  name: tableName
  parent: existingWOrkspace
  properties: {
    plan: 'Basic'
  }
}

targetScope = 'resourceGroup'

param email string

resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'ag-notify-engineer'
  location: 'global'
  properties: {
    enabled: true
    groupShortName: 'engineer'
    emailReceivers: [
      {
        name: 'landing zone engineer'
        emailAddress: email
      }
    ]
  }
}

output resourceId string = actionGroup.id

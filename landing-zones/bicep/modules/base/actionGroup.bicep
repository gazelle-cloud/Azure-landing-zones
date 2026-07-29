targetScope = 'resourceGroup'

param email string

resource notifyEngineer 'Microsoft.Insights/actionGroups@2023-01-01' = {
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

output resourceId string = notifyEngineer.id

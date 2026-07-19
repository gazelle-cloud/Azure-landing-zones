targetScope = 'subscription'

param engineerEmail string


resource notifications 'Microsoft.Security/securityContacts@2023-12-01-preview' = {
  name: 'default'
  properties: {
    isEnabled: true
    notificationsSources: [
      {
        sourceType: 'Alert'
        minimalSeverity: 'Low'
      }
    ]
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
        'Contributor'
      ]
    }
    emails: engineerEmail
  }
}

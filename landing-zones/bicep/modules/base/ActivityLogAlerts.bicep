
param actionGroupId string

resource ActivityLogAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'alert-Azure-health'
  location: 'global'
  properties: {
    enabled: true
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Recommendation'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Advisor/recommendations/available/action'
        }
        {
          field: 'properties.recommendationType'
          equals: '242639fd-cd73-4be2-8f55-70478db8d1a5'
        }
      ]
    }
  }
}

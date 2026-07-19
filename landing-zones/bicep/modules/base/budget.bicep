targetScope = 'subscription'

param budgetAmount int
param startDate string = '${utcNow('yyyy-MM')}-01'
param actionGroupResourceId string

resource budget 'Microsoft.Consumption/budgets@2024-08-01' = {
  #disable-next-line use-stable-resource-identifiers
  name: 'set-by-create-landingzone-${startDate}'
  properties: {
    amount: budgetAmount
    category: 'Cost'
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      abc: {
        contactEmails: []
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Forecasted'
        locale: 'en-gb'
        contactGroups: [
          actionGroupResourceId
        ]
      }
    }
  }
}

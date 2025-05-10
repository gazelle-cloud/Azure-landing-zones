targetScope = 'managementGroup'

param billingAccountName string
param billingProfileName string

param invoiceSectionName string

resource billingAccount 'Microsoft.Billing/billingAccounts@2024-04-01' existing = {
  name: billingAccountName
  scope: tenant()
}

resource billingProfile 'Microsoft.Billing/billingAccounts/billingProfiles@2024-04-01' existing = {
  name: billingProfileName
  parent: billingAccount
}

resource invoice 'Microsoft.Billing/billingAccounts/billingProfiles/invoiceSections@2024-04-01' = {
  name: invoiceSectionName
  parent: billingProfile
  properties: {
    displayName: invoiceSectionName
  }
}

output invoiceSectionResourceId string = invoice.id

using '../bicep/billing.bicep'

param billingAccountName = readEnvironmentVariable('BILLING_ACCOUNT_NAME','')
param billingProfileName = readEnvironmentVariable('BILLING_PROFILE_NAME', '')
param invoiceSections = [
  'platform'
]

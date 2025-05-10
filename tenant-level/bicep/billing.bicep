targetScope = 'managementGroup'


param billingAccountName string
param billingProfileName string
param invoiceSections array

module invoice 'modules/invoice.bicep' = [
  for item in invoiceSections: {
    name: 'tenantLevel-invoiceSection-${item}'
    params: {
      billingAccountName: billingAccountName
      billingProfileName: billingProfileName
      invoiceSectionName: item
    }
  }
]

// deployment outputs does not support array format
// output GitHubRepositoryVariables array = [
//   for (item, i) in invoiceSections: {
//     'billingScope_${item}' : invoice[i].outputs.invoiceSectionResourceId
//   }
// ]

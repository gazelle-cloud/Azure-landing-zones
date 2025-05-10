$getSubscriptions = Search-AzGraph -Query @"
resourcecontainers
| where type == 'microsoft.resources/subscriptions'
| mv-expand  foo = properties.managementGroupAncestorsChain
| where foo.name contains "platform-prod"
| project subscriptionId
"@

Write-Output "subscriptions found: $($getSubscriptions.subscriptionId)"

Write-Output "deleting deployment stacks for subscriptions ..."

# $landingzoneDeploymentStacks.id | foreach-object -ThrottleLimit 10 -Parallel {
#     Write-Host "Deleting deployment stacks $($item.id)"
#     Remove-AzManagementGroupDeploymentStack -ResourceId $_.id -ActionOnUnmanage DeleteAll -Force -Verbose
# }
param (
    [string]$topLevelManagementGroupName
)

$getSubscriptions = Search-AzGraph -Query @"
resourcecontainers
| where type == 'microsoft.resources/subscriptions'
| extend mgmgtGroupChain = properties.managementGroupAncestorsChain
| extend mgmgtGroupChainLength = array_length(mgmgtGroupChain)
| where mgmgtGroupChain contains "$topLevelManagementGroupName"
| where mgmgtGroupChainLength > 2
| project subscriptionId
"@ -ManagementGroup $topLevelManagementGroupName

Write-Output "subscriptions found: $($getSubscriptions.Count)"

if ($getSubscriptions.Count -gt 0) {
    $getSubscriptions | foreach-object -ThrottleLimit 10 -Parallel {
        Write-Host "Moving subscription $($_.subscriptionId) to $using:topLevelManagementGroupName"
        New-AzManagementGroupSubscription -GroupName $using:topLevelManagementGroupName -SubscriptionId $_.subscriptionId
    } 
} else {
    Write-Output "No subscriptions found. Skipping task."
}

param (
    [Parameter(Mandatory = $true)]
    [string]$topLevelManagementGroupName,
    [Parameter(Mandatory = $true)]
    [string]$managementSubscriptionId
)


$MgDeployment = Get-AzManagementGroupDeployment -ManagementGroupId $topLevelManagementGroupName
write-output "management group deployment: $($MgDeployment.Count)"
$MgDeployment | foreach-object -ThrottleLimit 50 -Parallel {
    Remove-AzManagementGroupDeployment -Id $_.Id -verbose
}

Select-AzSubscription $managementSubscriptionId

$SubscriptionDeployment = Get-AzSubscriptionDeployment -Id $managementSubscriptionId
write-output "subscription deployment: $($SubscriptionDeployment.Count)"
$SubscriptionDeployment | foreach-object -ThrottleLimit 50 -Parallel {
    Remove-AzSubscriptionDeployment -Id $_.id -verbose
}
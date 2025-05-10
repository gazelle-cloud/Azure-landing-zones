
$connect = Connect-AzAccount -Identity -AccountId $env:identityClientId 

$getSubscriptions = (Get-AzSubscription | where-object { $_.State -eq 'Enabled' }).id
Write-Output "Found $($getSubscriptions.count) active subscriptions"


foreach ($subscription in $getSubscriptions) {
    try {
        $select = Select-AzSubscription -SubscriptionId $subscription
        $orphanedRoles = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq "Unknown" }
        Write-Output "Found $($orphanedRoles.count) orphaned roles in subscription $subscription"
        foreach ($role in $orphanedRoles) {
            $params = @{
                ObjectId           = $role.ObjectId
                RoleDefinitionName = $role.RoleDefinitionName
                ErrorAction        = 'Stop'
            }
            Remove-AzRoleAssignment @params 
        }
    }
    catch {
        Write-Error "Failed to remove orphaned roles in subscription $subscription. Error: $_"
    }
}
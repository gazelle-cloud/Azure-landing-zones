
$connect = Connect-AzAccount -Identity -AccountId $env:identityClientId 

$connect.Context

$scope = Select-AzSubscription -SubscriptionId $env:subscriptionId
$scope
$scope.Name


try {

    $orphanedRoles = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq "Unknown" }

    Write-Output "Found $($orphanedRoles.Count) orphaned roles in subscription $subscriptionId"

    $orphanedRoles | ForEach-Object {
        $params = @{
            ObjectId           = $_.ObjectId
            RoleDefinitionName = $_.RoleDefinitionName
            Scope              = $_.Scope
            ErrorAction        = 'Stop'
        }
        Remove-AzRoleAssignment @params
    }
}
catch {
    Write-Error "Failed to remove orphaned roles in subscription $subscriptionId. Error: $_"
}
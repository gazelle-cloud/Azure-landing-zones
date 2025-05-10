param (
    [string]$topLevelManagementGroupName
)

$params = @{
    managementGroupId = $topLevelManagementGroupName
    verbose           = $true
}


Write-Output "deployment stacks exclude management group hierarchy"
$deploymentStacks = Get-AzManagementGroupDeploymentStack @params | Where-Object { $_.name -notlike 'tenantLevel-*' }

Write-Output "deployment stacks found: $($deploymentStacks.id.Count)"
$deploymentStacks.id

Write-Output "remove deployment stacks..."
if ($deploymentStacks.id.Count -gt 0) {
    $deploymentStacks.id | foreach-object -ThrottleLimit 10 -Parallel {
        Write-Host "Deleting deployment stack $_"
        Remove-AzManagementGroupDeploymentStack -ResourceId $_ -ActionOnUnmanage DeleteAll -Force -Verbose
    }
}
else {
    Write-Output "No deployment stacks found. Skipping task."
}

Write-Output "getting management group hierarchy deployment stack ..."
$mgmtHierarchyDeploymentStack = Get-AzManagementGroupDeploymentStack @params  | Where-Object { $_.name -notlike 'tenantLevel-invoiceSections' }
Write-Output "deployment stacks found: $($mgmtHierarchyDeploymentStack.id.Count)"
$mgmtHierarchyDeploymentStack.id
Write-Output "remove deployment stacks..."
if ($mgmtHierarchyDeploymentStack.id.Count -gt 0) {
    $mgmtHierarchyDeploymentStack.id | foreach-object -ThrottleLimit 10 -Parallel {
        Write-Host "Deleting deployment stack $_"
        Remove-AzManagementGroupDeploymentStack -ResourceId $_ -ActionOnUnmanage DeleteAll -Force -Verbose
    }
}
else {
    Write-Output "No deployment stacks found. Skipping task."
}
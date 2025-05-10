param (
    [string]$environment = 'test'
)

$managementGroupsPrefix = "online"

$managementGroups = foreach($group in $managementGroupsPrefix) {
    $group + "-" + $environment
}

$landingzoneDeploymentStacks = @()
foreach ($group in $managementGroups) {
    $deploymentStacks = Get-AzManagementGroupDeploymentStack -ManagementGroupId $group
    if ($deploymentStacks) {
        $landingzoneDeploymentStacks += $deploymentStacks.id
    }
}

Write-Output "deployment stacks found: $($landingzoneDeploymentStacks.count)"

if ($landingzoneDeploymentStacks.Count -gt 0) {
    $landingzoneDeploymentStacks | foreach-object -ThrottleLimit 10 -Parallel {
        Write-Host "Deleting deployment stack $_"
        Remove-AzManagementGroupDeploymentStack -ResourceId $_ -ActionOnUnmanage DeleteAll -Force -Verbose
    }
} else {
    Write-Output "No deployment stacks found. Skipping task."
}
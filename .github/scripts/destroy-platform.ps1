param (
    [Parameter(Mandatory = $true)]
    [string]$actionOnUnmanage,

    [Parameter(Mandatory = $true)]
    [string]$ChildManagementGroupName,

    [Parameter(Mandatory = $true)]
    [string]$TopLevelManagementGroupName,

    [Parameter(Mandatory = $true)]
    [string]$SetDefinitionId
)

$ErrorActionPreference = "Stop"

Write-Output "=== DESTROY PLATFORM FLOW ==="
Write-Output "Child Management Group: $ChildManagementGroupName"
Write-Output "Top-level Management Group: $TopLevelManagementGroupName"
Write-Output "actionOnUnmanage: $actionOnUnmanage"


#region  Remove deployment history
Write-Output "=== REMOVE DEPLOYMENT HISTORY ==="

$deployments = az deployment mg list `
    --management-group-id $ChildManagementGroupName `
    --query "[].name" -o tsv

$deploymentCount = ($deployments | Measure-Object).Count
Write-Output "Deleting $deploymentCount management group deployments"

$deployments | ForEach-Object -Parallel {
    az deployment mg delete `
        --management-group-id $using:ChildManagementGroupName `
        --name $_ `
        --only-show-errors
} -ThrottleLimit 20
#endregion

#region Remove diagnostic policy assignments
Write-Output "=== REMOVE - DIAGNOSTIC POLICY ASSIGNMENTS ==="

$policyAssignments = az graph query --graph-query @"
policyresources
| where type == 'microsoft.authorization/policyassignments'
| extend setDefinitionId = tostring(properties.policyDefinitionId)
| where setDefinitionId == '$SetDefinitionId'
| project name, scope=tostring(properties.scope)
"@ `
    --management-groups $ChildManagementGroupName `
    --output json | ConvertFrom-Json

$policyAssignments = $policyAssignments.data

Write-Output "Deleting $($policyAssignments.Count) policy assignments"

$policyAssignments | ForEach-Object -Parallel {

    Write-Output "Removing policy assignment: $($_.name)"

    az policy assignment delete `
        --name $_.name `
        --scope $_.scope `
        --only-show-errors

} -ThrottleLimit 20

#endregion

#region Remove custom role assignments

Write-Output "=== REMOVE CUSTOM ROLE ASSIGNMENTS ==="

$subscriptions = az account management-group subscription show-sub-under-mg `
    --name $ChildManagementGroupName `
    --query "[].name" -o tsv

$assignmentIds = $subscriptions | ForEach-Object {
    az role assignment list --subscription $_  `
        --query "[?starts_with(roleDefinitionId, '/subscriptions/') && principalType == 'Group'].id" `
        -o tsv
}

Write-Output "Custom role assignments found: $($assignmentIds.Count)"

$assignmentIds | ForEach-Object -Parallel {
    Write-Output "Removing: $_"
    az role assignment delete --ids $_ --only-show-errors
} -ThrottleLimit 20

#endregion

#region Move subscriptions

Write-Output "=== MOVE SUBSCRIPTIONS ==="

$subscriptions = az account management-group subscription show-sub-under-mg `
    --name $ChildManagementGroupName `
    --query "[].name" `
    -o tsv    


Write-Output "Moving $($subscriptions.Count) subscriptions from $ChildManagementGroupName to $TopLevelManagementGroupName "

$subscriptions | ForEach-Object -Parallel {

    Write-Output "Moving subscription: $_"

    az account management-group subscription add `
        --name $using:topLevelManagementGroupName `
        --subscription $_ `
        --only-show-errors

} -ThrottleLimit 10

#endregion

#region Remove deployment stacks
Write-Output "=== REMOVE DEPLOYMENT STACKS ==="

$existingStacks = az stack mg list `
    --management-group-id $TopLevelManagementGroupName `
    --query "[].name" -o tsv

function Remove-DeploymentStacks {
    param([string[]]$Stacks)

    $Stacks | Where-Object { $existingStacks -notcontains $_ } | ForEach-Object { Write-Output " - Skipping stack (not found): $_" }
    $Stacks | Where-Object { $existingStacks -contains $_ } | ForEach-Object -Parallel {
        Write-Output " - Deleting stack: $_"
        az stack mg delete `
            --management-group-id $using:TopLevelManagementGroupName `
            --name $_ `
            --action-on-unmanage $using:actionOnUnmanage `
            --yes `
            --only-show-errors
    } -ThrottleLimit 5
}

Remove-DeploymentStacks @("policy-assignments-oases")
Remove-DeploymentStacks @("accessControl", "policy-customDefinitions", "policy-diagnosticSettings")
Remove-DeploymentStacks @("managementGroups")

#endregion

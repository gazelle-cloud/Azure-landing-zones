param (
    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$PlatformObjectId,

    [Parameter(Mandatory = $true)]
    [string]$TenantId
)

az account set --subscription $subscriptionId
Write-Output "Clearing Azure subscription with ID: $subscriptionId"

#region Remove Deployment Stacks

Write-Output "=== REMOVE DEPLOYMENT STACKS ==="

$deploymentStack = az graph query --graph-query @"
deploymentresources
| where type == "microsoft.resources/deploymentstacks"
| extend deploymentScope = tostring(properties.deploymentScope)
| where deploymentScope contains '$subscriptionId'
| project id
"@ `
    --management-groups $TenantId `
    --output json | ConvertFrom-Json

if ($deploymentStack.data.Count -eq 1) {

    $id = $deploymentStack.data.id

    $deploymentStackName = ($id -split "/")[-1]
    $managementGroupName = ($id -split "/")[4]

    Write-Output "Deleting deployment stack: $deploymentStackName"
    Write-Output "Located in management group: $managementGroupName"

    az stack mg delete `
        --id $id `
        --management-group-id $managementGroupName `
        --name $deploymentStackName `
        --action-on-unmanage deleteAll `
        --yes `
        --only-show-errors
}
else {
    Write-Output "Deployment stack not found."
}

#endregion

#region Remove resource groups

write-output "=== REMOVE RESOURCE GROUPS ==="

$resourceGroups = az group list --query "[].name" -o tsv

Write-Output "Resource groups found: $($resourceGroups.Count)"

$resourceGroups | ForEach-Object -Parallel {
    Write-Output "Removing resource group: $_"
    az group delete `
        --name $_ `
        --yes `
        --no-wait
} -ThrottleLimit 20

#endregion

#region Remove tags

Write-Output "=== REMOVE TAGS ==="

az tag delete --resource-id "/subscriptions/$subscriptionId" --yes

#endregion

#region Remove budgets

Write-Output "=== REMOVE BUDGETS ==="

$budgets = az consumption budget list --subscription $subscriptionId --query "[].name" -o tsv

$budgets | ForEach-Object {
    Write-Output "Removing budget: $_"
    az consumption budget delete --budget-name $_
}

#endregion

#region Remove Defender for Cloud security contacts

Write-Output "=== REMOVE SECURITY CONTACTS ==="

$securityContacts = az security contact list --query "[].id" -o tsv

$securityContacts | ForEach-Object {
    Write-Output "Removing contact: $_"
    az security contact delete --ids $_
}

#endregion

#region Set Defender for Cloud pricing tier to Standard

Write-Output "=== SET DEFENDER PRICING TO FREE ==="

$exclude = @('FoundationalCspm', 'Discovery')
$pricingNames = az security pricing list --query "value[].name" -o tsv

$pricingNames | Where-Object { $_ -notin $exclude } | ForEach-Object {
    Write-Output "Upgrading pricing tier to Free for: $_"
    az security pricing create -n $_ --tier Free
}

#endregion


#region Remove role assignments

Write-Output "=== REMOVE ROLE ASSIGNMENTS ==="

$roleAssignments = az role assignment list `
    --scope "/subscriptions/$subscriptionId" `
    --query "[?
      principalId != '$PlatformObjectId'
      && roleDefinitionName != 'Owner'
  ].{
      id:id,
      principalId:principalId,
      roleDefinitionName:roleDefinitionName,
      principalName:principalName
  }" `
    -o json | ConvertFrom-Json

Write-Output "RBAC assignments found at subscription scope: $($roleAssignments.Count)"

$roleAssignments | ForEach-Object -Parallel {
    Write-Output "Removing role assignment: $($_.role) $($_.principal)"
    az role assignment delete --ids $_.id
} -ThrottleLimit 20
#endregion

#region Rename subscription

Write-Output "=== RENAME SUBSCRIPTION ==="

az account subscription rename --id $subscriptionId --name $subscriptionId  

#endregion

#region Move to subscription-bank

Write-Output "=== MOVE TO SUBSCRIPTION-BANK ==="

az account management-group subscription add --name subscription-bank --subscription $subscriptionId

#endregion
param (
    [string]$policyAssignmentScope
)

$a = az graph query -q "policyresources | where type =~ 'microsoft.authorization/policyassignments' | extend setDefinitionId = tostring(properties.policyDefinitionId) | project assignmentId = id, assignmentName = name, setDefinitionId | join kind=inner (policyresources | where type =~ 'microsoft.authorization/policysetdefinitions' | project setDefinitionId = id, policyDefinitions = properties.policyDefinitions | mv-expand p = policyDefinitions | extend referenceIds = tostring(p.policyDefinitionReferenceId) | project setDefinitionId, referenceIds) on setDefinitionId" --management-groups $policyAssignmentScope 


$AzurePolicies = ($a | ConvertFrom-Json).data 



$result = [ordered]@{}

foreach ($item in ($AzurePolicies | Group-Object -Property assignmentName | Sort-Object Name)) {
    $assignmentName = $item.Name
    $firstRow = $item.Group | Select-Object -First 1

    $referenceMap = [ordered]@{}
    ($item.Group.referenceIds | Where-Object { $_ } | Sort-Object -Unique) |
    ForEach-Object { $referenceMap[$_] = $_ }

    $result[$assignmentName] = [ordered]@{
        assignmentId = $firstRow.assignmentId
        referenceIds = $referenceMap
    }
}

$json = $result | ConvertTo-Json
$json | Set-Content -Path "./landing-zones/$policyAssignmentScope/policy-assignment-reference.json"

Write-Output $json





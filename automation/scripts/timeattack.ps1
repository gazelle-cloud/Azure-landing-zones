$connect = Connect-AzAccount -Identity -AccountId $env:identityClientId 

$managementGroupName = $env:topLevelManagementGroupName

$nonCompliantPolicies = Get-AzPolicyState -ManagementGroupName $managementGroupName | Where-Object {
    $_.ComplianceState -eq 'NonCompliant' -and $_.PolicyDefinitionAction -notlike 'audit*'
}

if ($nonCompliantPolicies.Count -eq 0) {
    Write-Output "No non-compliant policies found in management group '$managementGroupName'. Skipping job."
    return
}

Write-Output "Found $($nonCompliantPolicies.Count) non-compliant policies in management group '$managementGroupName'."

foreach ($policy in $nonCompliantPolicies) {
    try {
        $remediationParameters = @{
            PolicyAssignmentId  = $policy.PolicyAssignmentId
            Name                = [guid]::NewGuid().ToString()
            ManagementGroupName = $policy.PolicyAssignmentId.Split('/')[4]
        }
        if ($policy.PolicyDefinitionReferenceId -ne '') {
            $remediationParameters.PolicyDefinitionReferenceId = $policy.PolicyDefinitionReferenceId
        }
        Start-AzPolicyRemediation @remediationParameters -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to start remediation for policy assignment ID: $($policy.PolicyAssignmentId). Error: $_"
    }
}
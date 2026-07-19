function Write-DeploymentStackSummary {
    param (
        [Parameter(Mandatory)]
        $StackJson
    )

    $stack = ($StackJson -join '') | ConvertFrom-Json

    "**deployment stack: $($stack.name)**" >> $env:GITHUB_STEP_SUMMARY
    "" >> $env:GITHUB_STEP_SUMMARY

    "**Managed Resources**" >> $env:GITHUB_STEP_SUMMARY
    $managed = $stack.resources
    if ($null -eq $managed -or $managed.Count -eq 0) {
        "_None._" >> $env:GITHUB_STEP_SUMMARY
    } else {
        ($managed | ForEach-Object { "<sub>$($_.id)</sub>" }) -join "<br>" >> $env:GITHUB_STEP_SUMMARY
    }

    $deleted = $stack.deletedResources
    if ($deleted -and $deleted.Count -gt 0) {
        "" >> $env:GITHUB_STEP_SUMMARY
        "**Deleted Resources**" >> $env:GITHUB_STEP_SUMMARY
        ($deleted | ForEach-Object { "<sub>$($_.id)</sub>" }) -join "<br>" >> $env:GITHUB_STEP_SUMMARY
    }

    $outputs = $stack.outputs
    $nonNullOutputs = $outputs.PSObject.Properties | Where-Object { $null -ne $_.Value.value }
    if ($nonNullOutputs) {
        "" >> $env:GITHUB_STEP_SUMMARY
        "**Outputs**" >> $env:GITHUB_STEP_SUMMARY
        foreach ($output in $nonNullOutputs) {
            $props = $output.Value.value.PSObject.Properties | Where-Object { $null -ne $_.Value }
            if (-not $props) { continue }
            "<sub><b>$($output.Name)</b></sub>" >> $env:GITHUB_STEP_SUMMARY
            ($props | ForEach-Object { "<sub>$($_.Name): $($_.Value)</sub>" }) -join "<br>" >> $env:GITHUB_STEP_SUMMARY
        }
    }
}

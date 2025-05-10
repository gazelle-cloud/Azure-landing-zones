
$ManagementGroupId = $env:ManagementGroupId
$Location = $env:Location
$DenySettingsMode = $env:DenySettingsMode
$ActionOnUnmanage = $env:ActionOnUnmanage
$environment = $env:environment
$GitHubOrganizationName = $env:GitHubOrganizationName
$GitHubRepositoryName = $env:GitHubRepositoryName
$DenySettingsApplyToChildScopes = [bool]::Parse($env:DenySettingsApplyToChildScopes)
function New-platformDeployment {
    $deploymentStackParameters = @{
        ManagementGroupId              = $ManagementGroupId
        DenySettingsMode               = $DenySettingsMode
        Location                       = $Location
        ActionOnUnmanage               = $ActionOnUnmanage
        DenySettingsApplyToChildScopes = $DenySettingsApplyToChildScopes
        Verbose                        = $true
        Force                          = $true
    }

    $deploy = New-AzManagementGroupDeploymentStack @args @deploymentStackParameters
    $formatOutputs = $deploy | ConvertTo-Json | ConvertFrom-Json
    $envOutputs = $formatOutputs.outputs.GitHubEnvironmentVariables
    $repoOutputs = $formatOutputs.outputs.GitHubRepositoryVariables

    Write-Output "GitHub Actions environment variables:"

    foreach ($item in $envOutputs.Value.PSObject.Properties) {
        Write-Output "-------------------------"
        Write-Output "$($item.Name)=$($item.Value)"
        "$($item.Name)=$($item.Value)" >> $env:GITHUB_ENV
    }

    Write-Output "GitHub repository environment variables:"

    foreach ($item in $repoOutputs.Value.PSObject.Properties) {
        Write-Output "$($item.Name):$($item.Value)"
        gh variable set "$($item.Name)" `
            --body "$($item.Value)" `
            --env $environment `
            --repo $GitHubOrganizationName/$GitHubRepositoryName
    }
}
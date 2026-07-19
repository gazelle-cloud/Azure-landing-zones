$environment = $env:ENVIRONMENT
$GitHubOrganizationName = $env:GITHUB_ORGANIZATION_NAME
$GitHubRepositoryName = $env:GITHUB_REPOSITORY_NAME


function Set-GitHubActionsVariables {
    param (
        $ActionsVariables
    )
    Write-Output "GitHub Actions variables:"
    foreach ($item in $ActionsVariables) {
        Write-Output "$($item.Name)=$($item.Value)"
        "$($item.Name)=$($item.Value)" >> $env:GITHUB_ENV
    }
}

function Set-GitHubRepositoryVariables {
    param (
        $RepositoryVariables
    )
    Write-Output "GitHub repository variables:"
    foreach ($item in $RepositoryVariables) {
        Write-Output "$($item.Name):$($item.Value)"
        gh variable set "$($item.Name)" `
            --body "$($item.Value)" `
            --repo $GitHubOrganizationName/$GitHubRepositoryName
    }
}

function Set-GitHubEnvironmentVariables {
    param (
        $EnvironmentVariables
    )
    Write-Output "GitHub environment variables:"
    foreach ($item in $EnvironmentVariables) {
        Write-Output "$($item.Name):$($item.Value)"
        gh variable set "$($item.Name)" `
            --body "$($item.Value)" `
            --env $Environment `
            --repo $GitHubOrganizationName/$GitHubRepositoryName
    }
}

function Set-GitHubOrganizationVariables {
    param (
        $OrganizationVariables
    )
    Write-Output "GitHub organization variables:"
    foreach ($item in $OrganizationVariables) {
        Write-Output "$($item.Name):$($item.Value)"
        gh variable set "$($item.Name)" `
            --body "$($item.Value)" `
            --org $GitHubOrganizationName `
            --visibility all
    }
}
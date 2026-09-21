param (
    [string]$GitHubRunnersName,
    [string]$GitHubOrganizationName
)


#region Remove Hosted Runners

Write-Output "=== REMOVE HOSTED RUNNERS ==="

$hostedRunners = gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/actions/hosted-runners"

$runner = ($hostedRunners | ConvertFrom-Json).runners | Where-Object { $_.name -eq $GitHubRunnersName }

if ($runner) {
    Write-Output "Removing hosted runner: $GitHubRunnersName"
    gh api --method DELETE `
        -H "Accept: application/vnd.github+json" `
        -H "X-GitHub-Api-Version: 2022-11-28" `
        "/orgs/$GitHubOrganizationName/actions/hosted-runners/$($runner.id)"
} else {
    Write-Output "Hosted runner $GitHubRunnersName not found, skipping."
}

#endregion


#region Remove Runner Group

Write-Output "=== REMOVE RUNNER GROUP ==="

$runnerGroups = gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/actions/runner-groups"

$group = ($runnerGroups | ConvertFrom-Json).runner_groups | Where-Object { $_.name -eq $GitHubRunnersName }

if ($group) {
    Write-Output "Removing runner group: $GitHubRunnersName"
    gh api --method DELETE `
        -H "Accept: application/vnd.github+json" `
        -H "X-GitHub-Api-Version: 2022-11-28" `
        "/orgs/$GitHubOrganizationName/actions/runner-groups/$($group.id)"
} else {
    Write-Output "Runner group $GitHubRunnersName not found, skipping."
}

#endregion


#region Remove Network Configuration

Write-Output "=== REMOVE NETWORK CONFIGURATION ==="

$configurations = gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/settings/network-configurations"

$config = ($configurations | ConvertFrom-Json).network_configurations | Where-Object { $_.name -eq $GitHubRunnersName }

if ($config) {
    Write-Output "Removing network configuration: $GitHubRunnersName"
    gh api --method DELETE `
        -H "Accept: application/vnd.github+json" `
        -H "X-GitHub-Api-Version: 2022-11-28" `
        "/orgs/$GitHubOrganizationName/settings/network-configurations/$($config.id)"
} else {
    Write-Output "Network configuration $GitHubRunnersName not found, skipping."
}

#endregion

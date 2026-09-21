param (
    [string]$githubNetworkId,
    [string]$GitHubRunnersName,
    [string]$GitHubOrganizationName
)


$configurations = gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/settings/network-configurations"

$configNames = ($configurations | ConvertFrom-Json).network_configurations.name

$exists = $configNames | Where-Object { $_ -eq $GitHubRunnersName }

if ($exists) {
    Write-Output "Network configuration $GitHubRunnersName already exists, skipping creation."
    exit 0
} else {
    Write-Output "Creating private runners: $GitHubRunnersName"
}

$netConfig = [PSCustomObject]@{
    name                 = $GitHubRunnersName
    network_settings_ids = @($githubNetworkId)
    compute_service      = "actions"
}

$createNetwork = $netConfig | ConvertTo-Json -Depth 10 | gh api --method POST `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/settings/network-configurations" `
    --input -

Write-Output "----------"
Write-Output $createNetwork | ConvertFrom-Json

$networkId = ($createNetwork | ConvertFrom-Json).id

$groupConfig = [PSCustomObject]@{
    name                     = $GitHubRunnersName
    visibility               = "all"
    runners                  = @()
    network_configuration_id = $networkId
}

$createGroup = $groupConfig | ConvertTo-Json -Depth 10 | gh api --method POST `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/actions/runner-groups" `
    --input -

Write-Output "----------"
Write-Output $createGroup | ConvertFrom-Json

$groupId = ($createGroup | ConvertFrom-Json).id

$runnersConfig = [PSCustomObject]@{
    name             = $GitHubRunnersName
    image            = [PSCustomObject]@{
        id     = "2306"
        source = "github"
    }
    runner_group_id  = $groupId
    size             = "2-core"
    maximum_runners  = 50
    enable_static_ip = $false
}

$createRunners = $runnersConfig | ConvertTo-Json -Depth 5 | gh api --method POST `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    "/orgs/$GitHubOrganizationName/actions/hosted-runners" `
    --input -

Write-Output "----------"
Write-Output $createRunners | ConvertFrom-Json

$runnersName = ($createRunners | ConvertFrom-Json).name
          
Write-Output $runnersName
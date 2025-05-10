param (
    [string]$JsonFilePath,
    [string]$Environment,
    [string]$organizationName
)

$jsonContent = Get-Content $JsonFilePath -Raw | ConvertFrom-Json

foreach ($key in $jsonContent.organizationVariables.PSObject.Properties) {
    $variableName = $key.Name
    $variableValue = $key.Value

    gh variable set $variableName --body $variableValue --org $organizationName --visibility all
}

foreach ($key in $jsonContent.repositoryVariables.PSObject.Properties) {
    $variableName = $key.Name
    $variableValue = $key.Value

    gh variable set $variableName --body $variableValue
}

foreach ($key in $jsonContent.environmentVariables.PSObject.Properties) {
    $variableName = $key.Name
    $variableValue = $key.Value.$Environment

    gh variable set $variableName --body $variableValue --env $Environment
}
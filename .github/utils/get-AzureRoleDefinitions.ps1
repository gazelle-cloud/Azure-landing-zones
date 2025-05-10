$jsonFilePath = "AzureRoleDefinitions.json"
$BuildInRoles = Get-AzRoleDefinition | Where-Object { $_.IsCustom -like 'False' } 

$existingRoles = Get-Content $jsonFilePath -Raw | ConvertFrom-Json
$totalExistingRoles = ($existingRoles | Get-Member -MemberType NoteProperty).Count

function Format-BuildInRoles {
    $roleMappings = @{}
    foreach ($role in $BuildInRoles) {
        $roleName = $role.Name -replace ' ', ''
        $roleId = "/providers/Microsoft.Authorization/roleDefinitions/$($role.Id)"
        $roleMappings[$roleName] = $roleId  
    }
    $sortedRoleMappings = [ordered]@{}
    $roleMappings.GetEnumerator() | Sort-Object Name | ForEach-Object {
        $sortedRoleMappings[$_.Key] = $_.Value
    }
    Write-Output $sortedRoleMappings
}

$totalBuildInRoles = (Format-BuildInRoles).count

$compare = $totalBuildInRoles - $totalExistingRoles
if ($compare -ne 0) {
    Write-Output "update role definitions: $compare"
    Format-BuildInRoles | ConvertTo-Json -Depth 5 | Out-File $jsonFilePath
} else {
    Write-Output "No updates on role definitions"
}
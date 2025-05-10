
param (
    [int]$CIDR,
    [string]$basevNet = "10.10.0.0/16"
)


$ExcludePlaygrounds = Get-AzManagementGroup | Where-Object {
    $_.Name -notlike "playground*" -and $_.DisplayName -ne "Tenant Root Group"
}

$getVnets = Search-AzGraph -Query 'resources
| where type == "microsoft.network/virtualnetworks"
| mv-expand  IP = properties.addressSpace.addressPrefixes
| project IP' -ManagementGroup $ExcludePlaygrounds.DisplayName


if ($getVnets.IP.Count -eq 0) {
    $existingVnets = ($basevNet -split "/")[0] + "/" + 24
} else {
    $existingVnets = $getVnets.IP
}


$params = @{
    networks = $existingVnets
    CIDR     = $CIDR
    baseNet  = $basevNet
}

$IpRange = Get-IPRanges @params
$NextFreeIP = ($ipRange | Where-Object { $_.isFree -eq $true })[0].Network.IPAddressToString
$NextFreeAddressSpace = $NextFreeIP + "/$CIDR"
$NextFreeAddressSpace
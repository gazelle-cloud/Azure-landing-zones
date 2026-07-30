$ErrorActionPreference = 'Stop'

$root = Join-Path $PSScriptRoot '..' '..' 'knowledge-graph'
$decisionRoot = Join-Path $root 'decisions'
$errors = [System.Collections.Generic.List[string]]::new()

$requiredProperties = @('id', 'decision', 'why', 'links', 'violations', 'files')
$allowedProperties = [System.Collections.Generic.HashSet[string]]::new([string[]]$requiredProperties)
$requiredLinkProperties = @('id', 'note')
$allowedLinkProperties = [System.Collections.Generic.HashSet[string]]::new([string[]]$requiredLinkProperties)

function Add-Error {
    param (
        [string]$File,
        [string]$Message
    )

    $errors.Add("  $File`: $Message")
}

function Test-StringProperty {
    param (
        [pscustomobject]$Document,
        [string]$File,
        [string]$Name
    )

    $property = $Document.PSObject.Properties[$Name]
    if ($null -eq $property) {
        Add-Error -File $File -Message "$Name is required"
        return
    }

    if ($property.Value -isnot [string]) {
        Add-Error -File $File -Message "$Name must be a string"
    }
}

function Test-StringArrayProperty {
    param (
        [pscustomobject]$Document,
        [string]$File,
        [string]$Name
    )

    $property = $Document.PSObject.Properties[$Name]
    if ($null -eq $property) {
        Add-Error -File $File -Message "$Name is required"
        return
    }

    if ($null -eq $property.Value -or $property.Value -isnot [array]) {
        Add-Error -File $File -Message "$Name must be an array of strings"
        return
    }

    for ($i = 0; $i -lt $property.Value.Count; $i++) {
        if ($property.Value[$i] -isnot [string]) {
            Add-Error -File $File -Message "$Name[$i] must be a string"
        }
    }
}

function Test-LinksProperty {
    param (
        [pscustomobject]$Document,
        [string]$File
    )

    $property = $Document.PSObject.Properties['links']
    if ($null -eq $property) {
        Add-Error -File $File -Message 'links is required'
        return
    }

    if ($null -eq $property.Value -or $property.Value -isnot [array]) {
        Add-Error -File $File -Message 'links must be an array of objects with id and note'
        return
    }

    for ($i = 0; $i -lt $property.Value.Count; $i++) {
        $link = $property.Value[$i]
        if ($null -eq $link -or $link -isnot [pscustomobject]) {
            Add-Error -File $File -Message "links[$i] must be an object with id and note"
            continue
        }

        foreach ($linkProperty in $link.PSObject.Properties) {
            if (-not $allowedLinkProperties.Contains($linkProperty.Name)) {
                Add-Error -File $File -Message "links[$i].$($linkProperty.Name) is not allowed"
            }
        }

        foreach ($requiredLinkProperty in $requiredLinkProperties) {
            $linkProperty = $link.PSObject.Properties[$requiredLinkProperty]
            if ($null -eq $linkProperty) {
                Add-Error -File $File -Message "links[$i].$requiredLinkProperty is required"
                continue
            }

            if ($linkProperty.Value -isnot [string]) {
                Add-Error -File $File -Message "links[$i].$requiredLinkProperty must be a string"
            }
        }
    }
}

if (-not (Test-Path -Path $decisionRoot -PathType Container)) {
    throw "Decision directory not found: $decisionRoot"
}

foreach ($decisionFile in Get-ChildItem -Path $decisionRoot -Filter '*.json' | Sort-Object Name) {
    $file = "decisions/$($decisionFile.Name)"

    try {
        $document = Get-Content -Raw -Path $decisionFile.FullName | ConvertFrom-Json
    }
    catch {
        Add-Error -File $file -Message "invalid JSON: $($_.Exception.Message)"
        continue
    }

    foreach ($property in $document.PSObject.Properties) {
        if (-not $allowedProperties.Contains($property.Name)) {
            Add-Error -File $file -Message "$($property.Name) is not allowed"
        }
    }

    foreach ($propertyName in @('id', 'decision', 'why')) {
        Test-StringProperty -Document $document -File $file -Name $propertyName
    }

    Test-LinksProperty -Document $document -File $file

    foreach ($propertyName in @('violations', 'files')) {
        Test-StringArrayProperty -Document $document -File $file -Name $propertyName
    }
}

if ($errors.Count -gt 0) {
    [Console]::Error.WriteLine('FAIL: knowledge graph decision schema')
    $errors | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 2
}

Write-Output 'OK: knowledge graph decision schema'
exit 0

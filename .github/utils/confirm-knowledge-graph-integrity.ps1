$ErrorActionPreference = 'Stop'

$root = Join-Path $PSScriptRoot '..' '..' 'knowledge-graph'
$decisionRoot = Join-Path $root 'decisions'
$guidingPrincipleRoot = Join-Path $root 'guiding-principles'
$operationRoot = Join-Path $root 'operations'
$errors = [System.Collections.Generic.List[string]]::new()

function Add-Error {
    param (
        [string]$File,
        [string]$Message
    )

    $errors.Add("  $File`: $Message")
}

function Read-JsonFile {
    param (
        [System.IO.FileInfo]$File,
        [string]$DisplayPath
    )

    try {
        return Get-Content -Raw -Path $File.FullName | ConvertFrom-Json
    }
    catch {
        Add-Error -File $DisplayPath -Message "invalid JSON: $($_.Exception.Message)"
        return $null
    }
}

function Get-ArrayValues {
    param (
        [object]$Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [array]) {
        return $Value
    }

    return @($Value)
}

function Get-IdSet {
    param (
        [string]$Directory,
        [string]$Kind
    )

    $ids = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($file in Get-ChildItem -Path $Directory -Filter '*.json' | Sort-Object Name) {
        $displayPath = "$Kind/$($file.Name)"
        $document = Read-JsonFile -File $file -DisplayPath $displayPath
        if ($null -eq $document) {
            continue
        }

        if ($document.id -is [string]) {
            [void]$ids.Add($document.id)
        }
        else {
            Add-Error -File $displayPath -Message 'id must be a string'
        }
    }

    return $ids
}

foreach ($directory in @($decisionRoot, $guidingPrincipleRoot, $operationRoot)) {
    if (-not (Test-Path -Path $directory -PathType Container)) {
        throw "Knowledge graph directory not found: $directory"
    }
}

$decisionIds = Get-IdSet -Directory $decisionRoot -Kind 'decisions'
$guidingPrincipleIds = Get-IdSet -Directory $guidingPrincipleRoot -Kind 'guiding-principles'
$operationIds = Get-IdSet -Directory $operationRoot -Kind 'operations'

foreach ($file in Get-ChildItem -Path $operationRoot -Filter '*.json' | Sort-Object Name) {
    $displayPath = "operations/$($file.Name)"
    $document = Read-JsonFile -File $file -DisplayPath $displayPath
    if ($null -eq $document) {
        continue
    }

    foreach ($ref in Get-ArrayValues -Value $document.decisions) {
        if (-not $decisionIds.Contains($ref)) {
            Add-Error -File $displayPath -Message "decisions[] -> '$ref' not found in decisions"
        }
    }

    if ($null -ne $document.prerequisite -and -not $operationIds.Contains($document.prerequisite)) {
        Add-Error -File $displayPath -Message "prerequisite -> '$($document.prerequisite)' not found in operations"
    }
}

foreach ($file in Get-ChildItem -Path $guidingPrincipleRoot -Filter '*.json' | Sort-Object Name) {
    $displayPath = "guiding-principles/$($file.Name)"
    $document = Read-JsonFile -File $file -DisplayPath $displayPath
    if ($null -eq $document) {
        continue
    }

    foreach ($ref in Get-ArrayValues -Value $document.decisions) {
        if (-not $decisionIds.Contains($ref)) {
            Add-Error -File $displayPath -Message "decisions[] -> '$ref' not found in decisions"
        }
    }
}

foreach ($file in Get-ChildItem -Path $decisionRoot -Filter '*.json' | Sort-Object Name) {
    $displayPath = "decisions/$($file.Name)"
    $document = Read-JsonFile -File $file -DisplayPath $displayPath
    if ($null -eq $document) {
        continue
    }

    foreach ($link in Get-ArrayValues -Value $document.links) {
        $linkId = $link.id
        if (-not $decisionIds.Contains($linkId) -and -not $guidingPrincipleIds.Contains($linkId)) {
            Add-Error -File $displayPath -Message "links[] -> '$linkId' not found in decisions or guiding-principles"
        }
    }
}

if ($errors.Count -gt 0) {
    [Console]::Error.WriteLine('FAIL: knowledge graph referential integrity')
    $errors | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 2
}

Write-Output 'OK: knowledge graph referential integrity'
exit 0

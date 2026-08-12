[CmdletBinding()]
param (
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$root = Join-Path $PSScriptRoot '..' '..' 'knowledge-graph'

# One entry per generated artifact. Properties are listed in render order, and a
# node property missing from this table is an error - see the guard below.
$artifacts = @(
    @{
        Directory  = 'decisions'
        Title      = 'Decisions'
        Properties = [ordered]@{
            decision   = 'Paragraph'
            why        = 'Inline'
            links      = 'LinkList'
            violations = 'List'
            files      = 'CodeList'
        }
    }
    @{
        Directory  = 'foundations'
        Title      = 'Foundations'
        Properties = [ordered]@{
            intent     = 'Paragraph'
            decisions  = 'List'
            violations = 'List'
        }
    }
    @{
        Directory  = 'operations'
        Title      = 'Operations'
        Properties = [ordered]@{
            triggers     = 'List'
            intent       = 'Paragraph'
            prerequisite = 'Inline'
            workflow     = 'Inline'
            decisions    = 'List'
            violations   = 'List'
            steps        = 'Steps'
            files        = 'CodeList'
        }
    }
)

function Format-Artifact {
    param (
        [Parameter(Mandatory)] [string] $Directory,
        [Parameter(Mandatory)] [string] $Title,
        [Parameter(Mandatory)] [System.Collections.Specialized.OrderedDictionary] $Properties
    )

    $nodeRoot = Join-Path $root $Directory

    if (-not (Test-Path -Path $nodeRoot -PathType Container)) {
        throw "Node directory not found: $nodeRoot"
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("<!-- GENERATED FROM knowledge-graph/$Directory/ - DO NOT EDIT -->")
    $lines.Add('')
    $lines.Add("# $Title")

    foreach ($nodeFile in Get-ChildItem -Path $nodeRoot -Filter '*.json' | Sort-Object Name) {
        $file = "$Directory/$($nodeFile.Name)"
        $document = Get-Content -Raw -Path $nodeFile.FullName | ConvertFrom-Json

        # An unknown property means the schema grew and this renderer did not. Fail
        # loudly rather than dropping the content silently out of the graph.
        foreach ($property in $document.PSObject.Properties) {
            if ($property.Name -ne 'id' -and -not $Properties.Contains($property.Name)) {
                throw "$file`: $($property.Name) is not a known property - teach the renderer before adding it"
            }
        }

        $lines.Add('')
        $lines.Add("## $($document.id)")

        foreach ($property in $Properties.GetEnumerator()) {
            $value = $document.($property.Key)
            $label = $property.Key.Substring(0, 1).ToUpperInvariant() + $property.Key.Substring(1)

            switch ($property.Value) {
                'Paragraph' {
                    if ([string]::IsNullOrWhiteSpace($value)) { break }
                    $lines.Add('')
                    $lines.Add($value)
                }
                'Inline' {
                    if ([string]::IsNullOrWhiteSpace($value)) { break }
                    $lines.Add('')
                    $lines.Add("**$label`:** $value")
                }
                'List' {
                    if ($value.Count -eq 0) { break }
                    $lines.Add('')
                    $lines.Add("**$label`:**")
                    $lines.Add('')
                    foreach ($item in $value) { $lines.Add("- $item") }
                }
                'CodeList' {
                    if ($value.Count -eq 0) { break }
                    $lines.Add('')
                    $lines.Add("**$label`:**")
                    $lines.Add('')
                    foreach ($item in $value) { $lines.Add("- ``$item``") }
                }
                'LinkList' {
                    if ($value.Count -eq 0) { break }
                    $lines.Add('')
                    $lines.Add("**$label`:**")
                    $lines.Add('')
                    foreach ($item in $value) { $lines.Add("- $($item.id) — $($item.note)") }
                }
                'Steps' {
                    if ($value.Count -eq 0) { break }
                    $lines.Add('')
                    $lines.Add("**$label`:**")
                    $lines.Add('')
                    $number = 1
                    foreach ($item in $value) {
                        $lines.Add("$number. $item")
                        $number++
                    }
                }
                default {
                    throw "$file`: no renderer named $($property.Value)"
                }
            }
        }
    }

    # LF endings so the artifact is byte-identical whether it is generated on
    # Windows or on a Linux runner.
    return ($lines -join "`n") + "`n"
}

# UTF-8 without BOM, for the same byte-identical reason.
$encoding = [System.Text.UTF8Encoding]::new($false)
$stale = [System.Collections.Generic.List[string]]::new()

foreach ($artifact in $artifacts) {
    $name = "$($artifact.Directory).md"
    $outputPath = Join-Path $root $name
    $content = Format-Artifact -Directory $artifact.Directory -Title $artifact.Title -Properties $artifact.Properties

    if ($Check) {
        if (-not (Test-Path -Path $outputPath -PathType Leaf)) {
            $stale.Add("  knowledge-graph/$name is missing - run write-knowledge-graph.ps1")
            continue
        }

        if ([System.IO.File]::ReadAllText($outputPath, $encoding) -ne $content) {
            $stale.Add("  knowledge-graph/$name is stale - run write-knowledge-graph.ps1")
        }

        continue
    }

    [System.IO.File]::WriteAllText($outputPath, $content, $encoding)
    Write-Output "OK: wrote knowledge-graph/$name"
}

if ($Check) {
    if ($stale.Count -gt 0) {
        [Console]::Error.WriteLine('FAIL: knowledge graph artifacts')
        foreach ($message in $stale) { [Console]::Error.WriteLine($message) }
        exit 2
    }

    Write-Output 'OK: knowledge graph artifacts'
}

exit 0

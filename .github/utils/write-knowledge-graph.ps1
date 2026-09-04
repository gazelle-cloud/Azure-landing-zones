[CmdletBinding()]
param (
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$root = Join-Path $PSScriptRoot '..' '..' 'knowledge-graph'

# The graph renders as one artifact, in reading order: what the words mean, what
# the platform values, what counts as what, and what has to happen inside that.
# The regulative rules split by subject: an entity rule constrains a thing, a
# process rule carries the steps for doing something, and only the latter holds
# trigger, steps, and workflow.
# Properties are listed in render order, and a node property missing from these
# tables is an error - see the guard in Format-Entry.
$monolith = @{
    Name     = 'graph.md'
    Title    = 'Knowledge Graph'
    Sections = @(
        @{
            Directory  = 'vocabulary'
            Title      = 'Vocabulary'
            Tables     = [ordered]@{
                term     = @{
                    Heading = 'Terms'
                    Columns = [ordered]@{ id = 'term' }
                }
                relation = @{
                    Heading = 'Relations'
                    Columns = [ordered]@{ id = 'relation'; definition = 'definition' }
                }
            }
        }
        @{
            Directory  = 'foundations'
            Title      = 'Foundations'
            Properties = [ordered]@{
                intent     = 'Paragraph'
                violations = 'List'
            }
        }
        @{
            Directory  = 'constitutive'
            Title      = 'Constitutive'
            Properties = [ordered]@{
                subject    = 'Subject'
                rule       = 'Paragraph'
                why        = 'Inline'
                anchor     = 'Inline'
                links      = 'RelationList'
                violations = 'List'
                files      = 'CodeList'
                properties = 'Bag'
            }
        }
        @{
            Directory  = 'regulative-entity'
            Title      = 'Regulative - entity'
            Properties = [ordered]@{
                subject    = 'Subject'
                decision   = 'Paragraph'
                why        = 'Inline'
                anchor     = 'Inline'
                implements = 'List'
                links      = 'RelationList'
                violations = 'List'
                files      = 'CodeList'
                properties = 'Bag'
            }
        }
        @{
            Directory  = 'regulative-process'
            Title      = 'Regulative - process'
            Properties = [ordered]@{
                subject    = 'Subject'
                decision   = 'Paragraph'
                why        = 'Inline'
                anchor     = 'Inline'
                implements = 'List'
                trigger    = 'List'
                workflow   = 'Inline'
                steps      = 'Steps'
                links      = 'RelationList'
                violations = 'List'
                files      = 'CodeList'
                properties = 'Bag'
            }
        }
    )
}

function Get-NodeSet {
    param (
        [Parameter(Mandatory)] [string] $Directory
    )

    $nodeRoot = Join-Path $root $Directory

    if (-not (Test-Path -Path $nodeRoot -PathType Container)) {
        throw "Node directory not found: $nodeRoot"
    }

    # A node file normally holds one node. Where it holds an array, take each
    # element - the file is the container, not the node.
    foreach ($nodeFile in Get-ChildItem -Path $nodeRoot -Filter '*.json' | Sort-Object Name) {
        $parsed = Get-Content -Raw -Path $nodeFile.FullName | ConvertFrom-Json
        foreach ($node in @($parsed)) {
            [pscustomobject]@{ File = "$Directory/$($nodeFile.Name)"; Document = $node }
        }
    }
}

function Format-Entry {
    param (
        [Parameter(Mandatory)] [pscustomobject] $Entry,
        [Parameter(Mandatory)] [System.Collections.Specialized.OrderedDictionary] $Properties,
        [Parameter(Mandatory)] [string] $NodeHeading
    )

    $lines = [System.Collections.Generic.List[string]]::new()

    $file = $Entry.File
    $document = $Entry.Document

    # An unknown property means the schema grew and this renderer did not. Fail
    # loudly rather than dropping the content silently out of the graph.
    # id and type identify the node rather than describing it, so neither renders.
    foreach ($property in $document.PSObject.Properties) {
        if ($property.Name -notin @('id', 'type') -and -not $Properties.Contains($property.Name)) {
            throw "$file`: $($property.Name) is not a known property - teach the renderer before adding it"
        }
    }

    $lines.Add('')
    $lines.Add("$NodeHeading $($document.id)")

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
            # The relation carries the meaning, so it renders even where the
            # note is absent - governed-by needs none.
            'RelationList' {
                if ($value.Count -eq 0) { break }
                $lines.Add('')
                $lines.Add("**$label`:**")
                $lines.Add('')
                foreach ($item in $value) {
                    if ([string]::IsNullOrWhiteSpace($item.note)) {
                        $lines.Add("- $($item.relation) → $($item.target)")
                    }
                    else {
                        $lines.Add("- $($item.relation) → $($item.target) — $($item.note)")
                    }
                }
            }
            # A constitutive subject names the vocabulary term it constitutes. A
            # regulative subject carries only the type, which the section heading
            # already states, so it renders as nothing.
            'Subject' {
                if ($null -eq $value) { break }
                if ([string]::IsNullOrWhiteSpace($value.term)) { break }
                $lines.Add('')
                $lines.Add("**$label`:** $($value.term) ($($value.type))")
            }
            # properties is free-form and never load-bearing, so an empty bag
            # renders as nothing rather than as an empty section.
            'Bag' {
                if ($null -eq $value) { break }
                $pairs = @($value.PSObject.Properties)
                if ($pairs.Count -eq 0) { break }
                $lines.Add('')
                $lines.Add("**$label`:**")
                $lines.Add('')
                foreach ($pair in $pairs) { $lines.Add("- $($pair.Name): $($pair.Value)") }
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

    return $lines
}

# A pipe inside a cell would split it into two, so the only transformation a cell
# takes is escaping one.
function Format-Cell {
    param (
        $Value
    )

    if ($null -eq $Value) { return '' }

    return ([string]$Value).Replace('|', '\|')
}

# A section renders as one entry per node, unless it declares Tables. Where it
# does, the nodes bucket by their type and each bucket renders as one table -
# every column is a property the node already holds, so the table is a layout of
# the JSON rather than a reading of it.
function Format-Nodes {
    param (
        [Parameter(Mandatory)] [string] $Directory,
        [Parameter(Mandatory)] [string] $NodeHeading,
        [System.Collections.Specialized.OrderedDictionary] $Properties,
        [System.Collections.Specialized.OrderedDictionary] $Tables
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $nodes = @(Get-NodeSet -Directory $Directory)

    if ($null -eq $Tables) {
        foreach ($entry in $nodes) {
            foreach ($line in Format-Entry -Entry $entry -Properties $Properties -NodeHeading $NodeHeading) {
                $lines.Add($line)
            }
        }

        return $lines
    }

    $tabulated = 0

    foreach ($table in $Tables.GetEnumerator()) {
        $columns = $table.Value.Columns
        $members = @($nodes | Where-Object { $_.Document.type -eq $table.Key })
        if ($members.Count -eq 0) { continue }

        $lines.Add('')
        $lines.Add("$NodeHeading $($table.Value.Heading)")
        $lines.Add('')
        $lines.Add('| ' + (@($columns.Values) -join ' | ') + ' |')
        $lines.Add('| ' + (@($columns.Keys | ForEach-Object { '---' }) -join ' | ') + ' |')

        foreach ($entry in $members) {
            $document = $entry.Document

            # As in Format-Entry: a property with no column would drop out of the
            # artifact silently. type identifies the node rather than describing
            # it, and is what the table is keyed on, so it takes no column.
            foreach ($property in $document.PSObject.Properties) {
                if ($property.Name -ne 'type' -and -not $columns.Contains($property.Name)) {
                    throw "$($entry.File)`: $($property.Name) has no column in the $($table.Key) table - teach the renderer before adding it"
                }
            }

            $cells = foreach ($column in $columns.Keys) { Format-Cell -Value $document.$column }
            $lines.Add('| ' + (@($cells) -join ' | ') + ' |')
        }

        $tabulated += $members.Count
    }

    # A node whose type has no table would vanish from the artifact, which is the
    # silent drop the renderer exists to prevent.
    if ($tabulated -ne $nodes.Count) {
        throw "$Directory`: $($nodes.Count - $tabulated) node(s) carry a type no table in this section declares"
    }

    return $lines
}

function Format-Monolith {
    param (
        [Parameter(Mandatory)] [string] $Title,
        [Parameter(Mandatory)] [array] $Sections
    )

    $sources = ($Sections | ForEach-Object { "knowledge-graph/$($_.Directory)/" }) -join ', '

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("<!-- GENERATED FROM $sources - DO NOT EDIT -->")
    $lines.Add('')
    $lines.Add("# $Title")

    foreach ($section in $Sections) {
        $lines.Add('')
        $lines.Add("## $($section.Title)")

        foreach ($line in Format-Nodes -Directory $section.Directory -NodeHeading '###' -Properties $section.Properties -Tables $section.Tables) {
            $lines.Add($line)
        }
    }

    # LF endings so the artifact is byte-identical whether it is generated on
    # Windows or on a Linux runner.
    return ($lines -join "`n") + "`n"
}

# UTF-8 without BOM, for the same byte-identical reason.
$encoding = [System.Text.UTF8Encoding]::new($false)

$outputPath = Join-Path $root $monolith.Name
$content = Format-Monolith -Title $monolith.Title -Sections $monolith.Sections

if ($Check) {
    if (-not (Test-Path -Path $outputPath -PathType Leaf)) {
        [Console]::Error.WriteLine('FAIL: knowledge graph artifact')
        [Console]::Error.WriteLine("  knowledge-graph/$($monolith.Name) is missing - run write-knowledge-graph.ps1")
        exit 2
    }

    if ([System.IO.File]::ReadAllText($outputPath, $encoding) -ne $content) {
        [Console]::Error.WriteLine('FAIL: knowledge graph artifact')
        [Console]::Error.WriteLine("  knowledge-graph/$($monolith.Name) is stale - run write-knowledge-graph.ps1")
        exit 2
    }

    Write-Output 'OK: knowledge graph artifact'
    exit 0
}

[System.IO.File]::WriteAllText($outputPath, $content, $encoding)
Write-Output "OK: wrote knowledge-graph/$($monolith.Name)"

exit 0

param (
    [Parameter(Mandatory = $true)]
    [string]$Decision,

    [Parameter(Mandatory = $true)]
    [string]$Fields,

    [Parameter(Mandatory = $true)]
    [string[]]$Files,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdditionalFiles
)

$ErrorActionPreference = 'Stop'

$Files = @(@($Files) + @($AdditionalFiles) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Where-Object { Test-Path -Path $_ })

if ($Files.Count -eq 0) {
    Write-Host 'No existing decision files to validate.'
    exit 0
}

if ([string]::IsNullOrWhiteSpace($env:CLAUDE_CODE_OAUTH_TOKEN)) {
    throw 'CLAUDE_CODE_OAUTH_TOKEN is required to call the Anthropic API.'
}

$fieldList = $Fields -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

# Read violations from the knowledge graph
$decisionFilePath = Join-Path $PSScriptRoot '..' '..' 'knowledge-graph' 'decisions' "$Decision.json"
if (-not (Test-Path $decisionFilePath)) {
    throw "Decision file not found: $decisionFilePath"
}
$decisionRecord = Get-Content -Raw -Path $decisionFilePath | ConvertFrom-Json

# Build response format from field list
$resultFields = ($fieldList | ForEach-Object {
    "`"$_`": `"pass|fail`", `"${_}_reason`": `"only on fail`""
}) -join ', '
$responseFormat = "{`"results`": [{`"id`": `"...`", $resultFields}]}"

# Build system prompt from violations in the knowledge graph
$violationLines = ($decisionRecord.violations | ForEach-Object { "- $_" }) -join "`n"

$systemPrompt = @"
You are a software engineer reviewing architectural decision records for a cloud platform.

The following are violations of the '$Decision' decision — conditions that must not exist:
$violationLines

Evaluate each entry's fields: $($fieldList -join ', ').

Return a JSON object with a result entry for every decision, including those that pass. Omit _reason fields only when that specific field passes — never omit the entry itself:
$responseFormat
"@

# Extract id and requested fields from each changed file
$entries = @(foreach ($file in $Files) {
    $doc = Get-Content -Raw -Path $file | ConvertFrom-Json
    $props = [ordered]@{ id = $doc.id }
    foreach ($field in $fieldList) {
        $props[$field] = $doc.PSObject.Properties[$field].Value
    }
    [pscustomobject]$props
})

$payload = @{
    model      = 'claude-sonnet-4-6'
    max_tokens = 4096
    system     = $systemPrompt
    messages   = @(
        @{ role = 'user'; content = (ConvertTo-Json -InputObject $entries -Depth 10 -Compress) }
    )
} | ConvertTo-Json -Depth 10

$raw = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.anthropic.com/v1/messages' `
    -Headers @{
        'Authorization'     = "Bearer $env:CLAUDE_CODE_OAUTH_TOKEN"
        'anthropic-version' = '2023-06-01'
    } `
    -ContentType 'application/json' `
    -Body $payload

$response = $raw.content[0].text | ConvertFrom-Json

# Build summary table
$summaryLines = [System.Collections.Generic.List[string]]::new()
$summaryLines.Add("## $Decision validation")
$summaryLines.Add('')
$headerCells = @('id') + $fieldList
$summaryLines.Add('| ' + ($headerCells -join ' | ') + ' |')
$summaryLines.Add('| ' + (($headerCells | ForEach-Object { '---' }) -join ' | ') + ' |')

$failed = $false
$failureLines = [System.Collections.Generic.List[string]]::new()

foreach ($result in $response.results) {
    $rowCells = @($result.id)
    foreach ($field in $fieldList) {
        $fieldResult = $result.PSObject.Properties[$field].Value
        $fieldReason = $result.PSObject.Properties["${field}_reason"].Value
        if ($fieldResult -eq 'pass') {
            $rowCells += 'pass'
        }
        else {
            $rowCells += "**$fieldReason**"
            $failureLines.Add("  $($result.id) [$field]: $fieldReason")
            $failed = $true
        }
    }
    $summaryLines.Add('| ' + ($rowCells -join ' | ') + ' |')
}

if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_STEP_SUMMARY)) {
    $summaryLines | Add-Content -Path $env:GITHUB_STEP_SUMMARY
}
else {
    $summaryLines | Write-Output
}

if ($failed) {
    $failureLines | ForEach-Object { [Console]::Error.WriteLine($_) }
    [Console]::Error.WriteLine("one or more decisions failed $Decision validation - fix before opening a PR.")
    exit 1
}

Write-Output "OK: $Decision validation"
exit 0

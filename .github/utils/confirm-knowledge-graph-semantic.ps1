param (
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

if ([string]::IsNullOrWhiteSpace($env:GH_TOKEN)) {
    throw 'GH_TOKEN is required to call GitHub Models.'
}

$systemPrompt = @'
You are a software engineer reading technical documentation for a cloud platform.
For each decision, assess whether it functions as useful technical documentation.

Field 1 — decision: Would an engineer reading this understand what technical choice was made?
Fail only if the statement is so vague it conveys no technical choice, or describes only a process or goal with no structural content.

Field 2 — why: Would an engineer understand what goes wrong if this decision is absent?
Fail only if the why is a direct restatement of the decision, or so generic it applies to any decision.

Return a JSON object with a result entry for every decision, including those that pass. Omit _core and _reason fields only when that specific field passes — never omit the entry itself: {"results": [{"id": "...", "decision": "pass|fail", "decision_core": "only on fail", "decision_reason": "only on fail", "why": "pass|fail", "why_core": "only on fail", "why_reason": "only on fail"}]}
'@

$decisions = @(foreach ($file in $Files) {
    $decision = Get-Content -Raw -Path $file | ConvertFrom-Json
    [pscustomobject]@{
        id       = $decision.id
        decision = $decision.decision
        why      = $decision.why
    }
})

$payload = @{
    model           = 'openai/gpt-4o'
    temperature     = 0
    max_tokens      = 4096
    response_format = @{
        type = 'json_object'
    }
    messages        = @(
        @{
            role    = 'system'
            content = $systemPrompt
        },
        @{
            role    = 'user'
            content = (ConvertTo-Json -InputObject $decisions -Depth 10 -Compress)
        }
    )
} | ConvertTo-Json -Depth 10

$raw = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://models.github.ai/inference/chat/completions' `
    -Headers @{
        Authorization = "Bearer $env:GH_TOKEN"
    } `
    -ContentType 'application/json' `
    -Body $payload

$response = $raw.choices[0].message.content | ConvertFrom-Json
$summaryLines = [System.Collections.Generic.List[string]]::new()
$summaryLines.Add('## knowledge graph validation')
$summaryLines.Add('')
$summaryLines.Add('| id | decision | why |')
$summaryLines.Add('|---|---|---|')

$failed = $false

foreach ($result in $response.results) {
    $decisionResult = $result.decision
    $whyResult = $result.why

    if ($decisionResult -eq 'pass') {
        $decisionCell = 'pass'
    }
    else {
        $decisionCell = "**$($result.decision_reason)** <br><sub>core: $($result.decision_core)</sub>"
    }

    if ($whyResult -eq 'pass') {
        $whyCell = 'pass'
    }
    else {
        $whyCell = "**$($result.why_reason)** <br><sub>core: $($result.why_core)</sub>"
    }

    $summaryLines.Add("| $($result.id) | $decisionCell | $whyCell |")

    if ($decisionResult -eq 'fail' -or $whyResult -eq 'fail') {
        $failed = $true
    }
}

if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_STEP_SUMMARY)) {
    $summaryLines | Add-Content -Path $env:GITHUB_STEP_SUMMARY
}
else {
    $summaryLines | Write-Output
}

if ($failed) {
    [Console]::Error.WriteLine('one or more decisions failed validation - fix before opening a PR.')
    exit 1
}

Write-Output 'OK: knowledge graph semantic validation'
exit 0

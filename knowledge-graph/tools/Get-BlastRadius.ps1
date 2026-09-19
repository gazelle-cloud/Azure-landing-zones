param(
    [Parameter(Mandatory)]
    [string]$Id
)

$root = Join-Path $PSScriptRoot ".."
$files = Get-ChildItem -Path $root -Recurse -Filter *.json |
    Where-Object { $_.DirectoryName -notmatch "vocabulary" }

# node id -> list of ids it points to (anchor, implements, links[].target)
$edges = @{}

foreach ($file in $files) {
    $node = Get-Content $file.FullName -Raw | ConvertFrom-Json
    $targets = @()
    if ($node.anchor) { $targets += $node.anchor }
    if ($node.implements) { $targets += $node.implements }
    if ($node.links) { $targets += $node.links | ForEach-Object { $_.target } }
    $edges[$node.id] = $targets
}

if (-not $edges.ContainsKey($Id)) {
    Write-Error "No node with id '$Id' found."
    exit 1
}

# reverse edges: who points at $Id, transitively
$visited = [System.Collections.Generic.HashSet[string]]::new()
$queue = [System.Collections.Generic.Queue[string]]::new()
$queue.Enqueue($Id)

while ($queue.Count -gt 0) {
    $current = $queue.Dequeue()
    foreach ($nodeId in $edges.Keys) {
        if ($edges[$nodeId] -contains $current -and -not $visited.Contains($nodeId)) {
            $visited.Add($nodeId) | Out-Null
            Write-Output $nodeId
            $queue.Enqueue($nodeId)
        }
    }
}

if ($visited.Count -eq 0) {
    Write-Output "Nothing depends on '$Id'."
}

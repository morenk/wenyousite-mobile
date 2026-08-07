param(
  [string]$BackendPath = "..\wenyousite-backend"
)

$ErrorActionPreference = "Stop"
$backend = (Resolve-Path -LiteralPath $BackendPath).Path
$mobile = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$contractDir = Join-Path $mobile "contracts"

New-Item -ItemType Directory -Force -Path $contractDir | Out-Null
Copy-Item -LiteralPath (Join-Path $backend "contracts\openapi.json") -Destination $contractDir -Force
Copy-Item -LiteralPath (Join-Path $backend "contracts\markdown-v2-fixtures.json") -Destination $contractDir -Force
Copy-Item -LiteralPath (Join-Path $backend "contracts\CHANGELOG.md") -Destination $contractDir -Force
Copy-Item -LiteralPath (Join-Path $backend "docs\mobile-client-guide.md") -Destination (Join-Path $contractDir "mobile-client-guide.md") -Force

$revision = (& git -C $backend rev-parse HEAD).Trim()
$contractVersionLine = Select-String -LiteralPath (Join-Path $backend "contracts\CHANGELOG.md") -Pattern '^##\s+(.+)$' | Select-Object -First 1
$contractVersion = $contractVersionLine.Matches[0].Groups[1].Value
$metadata = @(
  "backendRevision=$revision"
  "contractVersion=$contractVersion"
  "markdownContractVersion=2"
) -join "`n"
[System.IO.File]::WriteAllText((Join-Path $contractDir "backend-contract.properties"), "$metadata`n", [System.Text.UTF8Encoding]::new($false))

Write-Host "Synced backend contract $contractVersion from $revision"

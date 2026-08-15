[CmdletBinding()]
param(
  [string]$BackendPath = '..\wenyousite-backend',
  [string]$Remote = 'origin',
  [string]$Branch = 'dev',
  [switch]$SkipFetch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
  throw 'Mobile contract sync is only supported on Windows.'
}

$backend = (Resolve-Path -LiteralPath $BackendPath).Path
$mobile = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$contractDirectory = Join-Path $mobile 'contracts'
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)

function Invoke-BackendGit {
  param([string[]]$GitArguments)

  $output = @(& git -C $backend @GitArguments)
  if ($LASTEXITCODE -ne 0) {
    throw "Backend reference git command failed: git $($GitArguments -join ' ')"
  }
  return $output
}

function Export-BackendBlob {
  param(
    [string]$Source,
    [string]$Destination
  )

  $gitCommand = (Get-Command git.exe -ErrorAction Stop).Source
  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.FileName = $gitCommand
  $startInfo.Arguments = "-C `"$backend`" show `"$revision`:$Source`""
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $startInfo
  if (-not $process.Start()) {
    throw "Cannot start git while exporting $Source."
  }
  $bytes = New-Object System.IO.MemoryStream
  try {
    $process.StandardOutput.BaseStream.CopyTo($bytes)
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
      throw "Cannot export $Source from backend commit $revision. $errorOutput"
    }
    [System.IO.File]::WriteAllBytes($Destination, $bytes.ToArray())
  } finally {
    $bytes.Dispose()
    $process.Dispose()
  }
}

if (-not $SkipFetch) {
  Write-Host "Fetching committed backend contract source: $Remote/$Branch"
  Invoke-BackendGit @('fetch', '--quiet', $Remote, $Branch) | Out-Null
}

$contractRef = "$Remote/$Branch"
$revisionOutput = @(Invoke-BackendGit @(
  'rev-parse',
  '--verify',
  "$contractRef^{commit}"
))
$revision = $revisionOutput[-1].Trim()
if ($revision -notmatch '^[0-9a-f]{40}$') {
  throw "Cannot resolve $contractRef to a full backend commit."
}

$contractFiles = @(
  @{ Source = 'contracts/openapi.json'; Destination = 'openapi.json' },
  @{ Source = 'contracts/markdown-v2-fixtures.json'; Destination = 'markdown-v2-fixtures.json' },
  @{ Source = 'contracts/markdown-v2-nodes-fixtures.json'; Destination = 'markdown-v2-nodes-fixtures.json' },
  @{ Source = 'contracts/markdown-editor-roundtrip-v1-fixtures.json'; Destination = 'markdown-editor-roundtrip-v1-fixtures.json' },
  @{ Source = 'contracts/mobile-push-v1-fixtures.json'; Destination = 'mobile-push-v1-fixtures.json' },
  @{ Source = 'contracts/mobile-push-v1.schema.json'; Destination = 'mobile-push-v1.schema.json' },
  @{ Source = 'contracts/mobile-v1-golden-fixtures.json'; Destination = 'mobile-v1-golden-fixtures.json' },
  @{ Source = 'contracts/mobile-v1-operation-coverage.json'; Destination = 'mobile-v1-operation-coverage.json' },
  @{ Source = 'contracts/thread-category-v1-fixtures.json'; Destination = 'thread-category-v1-fixtures.json' },
  @{ Source = 'contracts/internal-reference-v1-fixtures.json'; Destination = 'internal-reference-v1-fixtures.json' },
  @{ Source = 'contracts/CHANGELOG.md'; Destination = 'CHANGELOG.md' },
  @{ Source = 'docs/mobile-client-guide.md'; Destination = 'mobile-client-guide.md' }
)

New-Item -ItemType Directory -Force -Path $contractDirectory | Out-Null
foreach ($contractFile in $contractFiles) {
  $source = [string]$contractFile.Source
  $destination = Join-Path $contractDirectory ([string]$contractFile.Destination)
  Export-BackendBlob $source $destination
}

Push-Location $mobile
try {
  & dart run 'tool/normalize_synced_contract.dart' 'contracts/openapi.json'
  if ($LASTEXITCODE -ne 0) {
    throw "OpenAPI contract normalization failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

$contractVersionLine = Select-String `
  -LiteralPath (Join-Path $contractDirectory 'CHANGELOG.md') `
  -Pattern '^##\s+(.+)$' |
  Select-Object -First 1
if ($null -eq $contractVersionLine) {
  throw 'Cannot read the contract version from contracts/CHANGELOG.md.'
}
$contractVersion = $contractVersionLine.Matches[0].Groups[1].Value
$metadata = @(
  "backendRevision=$revision"
  "contractVersion=$contractVersion"
  'markdownContractVersion=2'
  'internalReferenceContractVersion=1'
) -join "`n"
[System.IO.File]::WriteAllText(
  (Join-Path $contractDirectory 'backend-contract.properties'),
  "$metadata`n",
  $utf8WithoutBom
)

Write-Host "Synced backend contract $contractVersion from committed $contractRef ($revision)"

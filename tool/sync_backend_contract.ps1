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

$backendContractPaths = @(Invoke-BackendGit @(
  'ls-tree',
  '-r',
  '--name-only',
  $revision,
  '--',
  'contracts'
))

function Resolve-UniqueBackendContract {
  param(
    [string]$Pattern,
    [string]$Description
  )

  $matches = @($backendContractPaths | Where-Object { $_ -match $Pattern })
  if ($matches.Count -ne 1) {
    throw "Expected exactly one $Description contract at $revision, found $($matches.Count)."
  }
  return $matches[0]
}

$markdownNodesSource = Resolve-UniqueBackendContract `
  '^contracts/markdown-v[0-9]+-nodes-fixtures\.json$' `
  'Markdown nodes'
$markdownVersionMatch = [regex]::Match(
  $markdownNodesSource,
  '^contracts/markdown-v([0-9]+)-nodes-fixtures\.json$'
)
if (-not $markdownVersionMatch.Success) {
  throw "Cannot read the Markdown version from $markdownNodesSource."
}
$markdownFixtureSource =
  "contracts/markdown-v$($markdownVersionMatch.Groups[1].Value)-fixtures.json"
if ($markdownFixtureSource -notin $backendContractPaths) {
  throw "The active Markdown content contract is missing: $markdownFixtureSource"
}
$markdownEditorSource = Resolve-UniqueBackendContract `
  '^contracts/markdown-editor-roundtrip-v[0-9]+-fixtures\.json$' `
  'Markdown editor round-trip'
$threadCategorySource = Resolve-UniqueBackendContract `
  '^contracts/thread-category-v[0-9]+-fixtures\.json$' `
  'thread category'

$contractFiles = @(
  @{ Source = 'contracts/openapi.json'; Destination = 'openapi.json' },
  @{ Source = $markdownFixtureSource; Destination = (Split-Path -Leaf $markdownFixtureSource) },
  @{ Source = $markdownNodesSource; Destination = (Split-Path -Leaf $markdownNodesSource) },
  @{ Source = $markdownEditorSource; Destination = (Split-Path -Leaf $markdownEditorSource) },
  @{ Source = 'contracts/mobile-push-v1-fixtures.json'; Destination = 'mobile-push-v1-fixtures.json' },
  @{ Source = 'contracts/mobile-push-v1.schema.json'; Destination = 'mobile-push-v1.schema.json' },
  @{ Source = 'contracts/mobile-v1-golden-fixtures.json'; Destination = 'mobile-v1-golden-fixtures.json' },
  @{ Source = 'contracts/mobile-v1-operation-coverage.json'; Destination = 'mobile-v1-operation-coverage.json' },
  @{ Source = $threadCategorySource; Destination = (Split-Path -Leaf $threadCategorySource) },
  @{ Source = 'contracts/internal-reference-v1-fixtures.json'; Destination = 'internal-reference-v1-fixtures.json' },
  @{ Source = 'contracts/CHANGELOG.md'; Destination = 'CHANGELOG.md' },
  @{ Source = 'docs/mobile-client-guide.md'; Destination = 'mobile-client-guide.md' }
)

New-Item -ItemType Directory -Force -Path $contractDirectory | Out-Null
$desiredMarkdownFiles = @(
  Split-Path -Leaf $markdownFixtureSource
  Split-Path -Leaf $markdownNodesSource
  Split-Path -Leaf $markdownEditorSource
)
Get-ChildItem -LiteralPath $contractDirectory -File |
  Where-Object {
    $_.Name -match '^markdown-(?:v[0-9]+(?:-nodes)?|editor-roundtrip-v[0-9]+)-fixtures\.json$' -and
    $_.Name -notin $desiredMarkdownFiles
  } |
  Remove-Item -Force
$desiredThreadCategoryFile = Split-Path -Leaf $threadCategorySource
Get-ChildItem -LiteralPath $contractDirectory -File |
  Where-Object {
    $_.Name -match '^thread-category-v[0-9]+-fixtures\.json$' -and
    $_.Name -ne $desiredThreadCategoryFile
  } |
  Remove-Item -Force
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
$markdownFixture = Get-Content `
  -LiteralPath (Join-Path $contractDirectory (Split-Path -Leaf $markdownFixtureSource)) `
  -Encoding UTF8 `
  -Raw |
  ConvertFrom-Json
$markdownNodes = Get-Content `
  -LiteralPath (Join-Path $contractDirectory (Split-Path -Leaf $markdownNodesSource)) `
  -Encoding UTF8 `
  -Raw |
  ConvertFrom-Json
$markdownEditor = Get-Content `
  -LiteralPath (Join-Path $contractDirectory (Split-Path -Leaf $markdownEditorSource)) `
  -Encoding UTF8 `
  -Raw |
  ConvertFrom-Json
$markdownContractVersion = [int]$markdownNodes.markdownContractVersion
if ($markdownContractVersion -lt 1 -or
    [int]$markdownFixture.version -ne $markdownContractVersion -or
    [int]$markdownEditor.markdownContractVersion -ne $markdownContractVersion) {
  throw 'Synced Markdown contracts disagree about markdownContractVersion.'
}
$metadata = @(
  "backendRevision=$revision"
  "contractVersion=$contractVersion"
  "markdownContractVersion=$markdownContractVersion"
  'internalReferenceContractVersion=1'
) -join "`n"
[System.IO.File]::WriteAllText(
  (Join-Path $contractDirectory 'backend-contract.properties'),
  "$metadata`n",
  $utf8WithoutBom
)

Write-Host "Synced backend contract $contractVersion from committed $contractRef ($revision)"

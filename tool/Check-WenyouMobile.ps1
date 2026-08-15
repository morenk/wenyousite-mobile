[CmdletBinding()]
param(
  [switch]$BuildDebugApk
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
  throw 'The mobile quality gate is only supported on Windows.'
}

$repository = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$dartCommand = (Get-Command dart -ErrorAction Stop).Source
$flutterCommand = (Get-Command flutter -ErrorAction Stop).Source
$npmCommand = (Get-Command npm -ErrorAction Stop).Source

function Invoke-WenyouCheckStep {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string[]]$CommandArguments = @(),
    [string]$WorkingDirectory = $repository
  )

  Write-Host "`n==> $Label"
  Push-Location $WorkingDirectory
  try {
    & $Command @CommandArguments
    if ($LASTEXITCODE -ne 0) {
      throw "$Label failed with exit code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

Invoke-WenyouCheckStep 'Validate OpenAPI' $npmCommand @('run', 'api:validate')
Invoke-WenyouCheckStep 'Regenerate and verify API client' $npmCommand @('run', 'api:check')
Invoke-WenyouCheckStep 'Check Dart formatting' $dartCommand @(
  'format',
  '--output=none',
  '--set-exit-if-changed',
  'lib',
  'test',
  'tool'
)
Invoke-WenyouCheckStep 'Analyze mobile application' $flutterCommand @(
  'analyze',
  '--fatal-infos',
  '--fatal-warnings'
)
Invoke-WenyouCheckStep 'Analyze generated API package' $dartCommand @(
  'analyze',
  '--fatal-infos',
  '--fatal-warnings'
) (Join-Path $repository 'packages\wenyou_api')
Invoke-WenyouCheckStep 'Check architecture boundaries' $dartCommand @(
  'run',
  'tool/check_architecture.dart'
)
Invoke-WenyouCheckStep 'Check module documentation' $dartCommand @(
  'run',
  'tool/check_docs.dart'
)
Invoke-WenyouCheckStep 'Check mobile API coverage' $dartCommand @(
  'run',
  'tool/audit_api_coverage.dart',
  '--require-complete'
)
Invoke-WenyouCheckStep 'Run Flutter tests' $flutterCommand @('test')
Invoke-WenyouCheckStep 'Run Windows release tooling tests' $npmCommand @(
  'run',
  'test:release-tool'
)

if ($BuildDebugApk) {
  Invoke-WenyouCheckStep 'Build Android Debug APK' $flutterCommand @(
    'build',
    'apk',
    '--debug'
  )
}

Write-Host "`nWenyou mobile quality gate passed."

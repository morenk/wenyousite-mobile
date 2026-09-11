[CmdletBinding()]
param(
  [switch]$BuildDebugApk,
  # Windows 开发机同时运行多项任务时限制测试进程数，仍执行全部测试。
  [ValidateRange(1, 64)]
  [int]$TestConcurrency = 1,
  # 候选契约尚未部署时仍可收集其他检查；任一失败仍返回非零。
  [switch]$ContinueAfterFailure
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
$checkFailures = [System.Collections.Generic.List[string]]::new()

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
  } catch {
    if (-not $ContinueAfterFailure) { throw }
    $checkFailures.Add("$Label : $($_.Exception.Message)")
    Write-Warning $checkFailures[$checkFailures.Count - 1]
  } finally {
    Pop-Location
  }
}

Invoke-WenyouCheckStep 'Validate OpenAPI' $npmCommand @('run', 'api:validate')
Invoke-WenyouCheckStep 'Regenerate and verify API client' $npmCommand @('run', 'api:check')
Invoke-WenyouCheckStep 'Verify production contract and Markdown compatibility' $npmCommand @(
  'run',
  'api:verify:production'
)
Invoke-WenyouCheckStep 'Check Dart formatting' $dartCommand @(
  'format',
  '--output=none',
  '--set-exit-if-changed',
  'lib',
  'test',
  'tool',
  'integration_test',
  'test_driver'
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
Invoke-WenyouCheckStep 'Run Flutter tests' $flutterCommand @(
  'test',
  "--concurrency=$TestConcurrency"
)
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

if ($checkFailures.Count -gt 0) {
  Write-Host "`nWenyou mobile quality gate FAILED ($($checkFailures.Count) steps):"
  foreach ($failure in $checkFailures) { Write-Host "- $failure" }
  exit 1
}
Write-Host "`nWenyou mobile quality gate passed."

[CmdletBinding()]
param(
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
  [string[]]$TestPath = @(),
  [ValidateRange(1, 64)]
  [int]$TestConcurrency = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
  throw 'The mobile Debug candidate builder is only supported on Windows.'
}

$repository = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$testRoot = (Resolve-Path -LiteralPath (Join-Path $repository 'test')).Path
$testRootPrefix = $testRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar

if ($TestPath.Count -eq 0) {
  throw 'At least one relevant test file or subdirectory under test/ is required.'
}

$resolvedTestPaths = [System.Collections.Generic.List[string]]::new()
$seenTestPaths = [System.Collections.Generic.HashSet[string]]::new(
  [StringComparer]::OrdinalIgnoreCase
)

foreach ($candidatePath in $TestPath) {
  if ([string]::IsNullOrWhiteSpace($candidatePath)) {
    throw 'Test paths must not be empty.'
  }

  $requestedPath = if ([IO.Path]::IsPathRooted($candidatePath)) {
    $candidatePath
  } else {
    Join-Path $repository $candidatePath
  }
  if (-not (Test-Path -LiteralPath $requestedPath)) {
    throw "Test path does not exist: $candidatePath"
  }

  $resolvedPath = (Resolve-Path -LiteralPath $requestedPath).Path
  if ($resolvedPath -eq $testRoot -or
      -not $resolvedPath.StartsWith($testRootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Test path must be a file or subdirectory below test/: $candidatePath"
  }
  if ((Test-Path -LiteralPath $resolvedPath -PathType Leaf) -and
      -not $resolvedPath.EndsWith('_test.dart', [StringComparison]::OrdinalIgnoreCase)) {
    throw "Test file must end with _test.dart: $candidatePath"
  }

  $relativePath = [IO.Path]::GetRelativePath($repository, $resolvedPath)
  if ($seenTestPaths.Add($relativePath)) {
    $resolvedTestPaths.Add($relativePath)
  }
}

$dartCommand = (Get-Command dart -ErrorAction Stop).Source
$flutterCommand = (Get-Command flutter -ErrorAction Stop).Source

function Invoke-WenyouCandidateStep {
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

Invoke-WenyouCandidateStep 'Check Dart formatting' $dartCommand @(
  'format',
  '--output=none',
  '--set-exit-if-changed',
  'lib',
  'test',
  'tool',
  'integration_test',
  'test_driver'
)
Invoke-WenyouCandidateStep 'Analyze mobile application' $flutterCommand @(
  'analyze',
  '--fatal-infos',
  '--fatal-warnings'
)
Invoke-WenyouCandidateStep 'Analyze generated API package' $dartCommand @(
  'analyze',
  '--fatal-infos',
  '--fatal-warnings'
) (Join-Path $repository 'packages\wenyou_api')
Invoke-WenyouCandidateStep 'Run relevant Flutter tests' $flutterCommand @(
  'test',
  "--concurrency=$TestConcurrency",
  [string[]]$resolvedTestPaths
)
Invoke-WenyouCandidateStep 'Build Android Debug APK' $flutterCommand @(
  'build',
  'apk',
  '--debug'
)

$apkPath = Join-Path $repository 'build\app\outputs\flutter-apk\app-debug.apk'
if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
  throw "Debug APK build completed without the expected output: $apkPath"
}

$apk = Get-Item -LiteralPath $apkPath
$sha256 = (Get-FileHash -LiteralPath $apkPath -Algorithm SHA256).Hash
Write-Host "`nWenyou Debug candidate APK created."
Write-Host "Path: $($apk.FullName)"
Write-Host "Size: $($apk.Length) bytes"
Write-Host "SHA-256: $sha256"

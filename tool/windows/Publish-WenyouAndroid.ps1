[CmdletBinding()]
param(
  [string]$ConfigPath = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\release-config.json'),
  [string]$SshAlias
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'WenyouRelease.Common.ps1')

$config = Read-WenyouReleaseConfig -ConfigPath $ConfigPath
$projectPath = $config.projectPath
if ([string]::IsNullOrWhiteSpace($SshAlias)) {
  $SshAlias = $config.sshAlias
}
$sshPath = Join-Path $config.gitSshDirectory 'ssh.exe'
$releaseWrapper = Join-Path $PSScriptRoot 'Invoke-WenyouAndroidRelease.ps1'
$version = Get-WenyouPubspecVersion -ProjectPath $projectPath
$dartPath = (Get-Command dart -ErrorAction Stop).Source

$changes = @(& git -C $projectPath status --porcelain --untracked-files=normal)
if ($LASTEXITCODE -ne 0) {
  throw 'Unable to inspect the mobile Git repository.'
}
if ($changes.Count -ne 0) {
  Write-Host 'The mobile repository has uncommitted files:'
  $changes | ForEach-Object { Write-Host "  $_" }
  throw 'Commit or remove the changes before publishing.'
}

$head = (& git -C $projectPath rev-parse HEAD).Trim()
$upstream = (& git -C $projectPath rev-parse '@{u}' 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
  throw 'The current branch has no upstream branch.'
}
if ($head -ne $upstream) {
  throw 'Local HEAD does not match its upstream. Push or pull before publishing.'
}

Push-Location $projectPath
try {
  & $dartPath run tool/verify_production_api.dart
  if ($LASTEXITCODE -ne 0) {
    throw 'Production contract preflight failed. Sync the backend contract before publishing.'
  }
} finally {
  Pop-Location
}

$liveMeta = Invoke-RestMethod -Uri 'https://wenyou.site/api/v1/meta' -Method Get
$liveAndroid = $liveMeta.data.mobileCompatibility.android
if ($null -ne $liveAndroid.recommendedBuild -and
    [int]$liveAndroid.recommendedBuild -ge $version.Build) {
  throw "Build $($version.Build) must be greater than live recommended build $($liveAndroid.recommendedBuild)."
}

$preflight = Invoke-WenyouSshPreflight -SshPath $sshPath -SshAlias $SshAlias
if ($preflight.ExitCode -ne 0) {
  $preflight.Output | ForEach-Object { Write-Host $_ }
  throw 'VPS release access is not ready. Run Wenyou-Release-Setup.cmd once.'
}

Write-Host ''
Write-Host "Ready to publish Android $($version.Full)"
Write-Host "Source commit: $head"
$confirmation = Read-Host 'Publish this version to users now? [y/N]'
if ($confirmation -notmatch '^(?i:y|yes)$') {
  Write-Host 'Publish cancelled.'
  exit 0
}

& $releaseWrapper -Mode Publish -VersionName $version.Name -BuildNumber $version.Build -ConfigPath $ConfigPath -SshTarget $SshAlias
if ($LASTEXITCODE -ne 0) {
  throw "Release wrapper failed with exit code $LASTEXITCODE."
}

$meta = Invoke-RestMethod -Uri 'https://wenyou.site/api/v1/meta' -Method Get
$android = $meta.data.mobileCompatibility.android
if ($android.recommendedBuild -ne $version.Build) {
  throw "Live meta verification failed. Expected build $($version.Build)."
}
Write-Host ''
Write-Host "Android $($version.Full) is now recommended to users."
Write-Host "Download URL: $($android.updateUrl)"

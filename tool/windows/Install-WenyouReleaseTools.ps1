[CmdletBinding()]
param(
  [string]$ReleaseRoot = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release'),
  [string]$DesktopPath = [Environment]::GetFolderPath('Desktop'),
  [string]$BashPath,
  [string]$GitSshDirectory,
  [string]$ReleaseKeyPath,
  [string]$SshHost = 'wenyou.site',
  [string]$SshUser = 'wenyou-release',
  [string]$SshAlias = 'wenyou-release-vps'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (-not (Test-Path -LiteralPath (Join-Path $projectPath 'pubspec.yaml') -PathType Leaf)) {
  throw "Mobile project was not found: $projectPath"
}

$gitCommand = Get-Command git.exe -ErrorAction Stop
$gitCommandDirectory = Split-Path -Parent $gitCommand.Source
$gitRoot = [IO.Path]::GetFullPath((Join-Path $gitCommandDirectory '..'))
if ([string]::IsNullOrWhiteSpace($BashPath)) {
  $BashPath = Join-Path $gitRoot 'bin\bash.exe'
}
if ([string]::IsNullOrWhiteSpace($GitSshDirectory)) {
  $GitSshDirectory = Join-Path $gitRoot 'usr\bin'
}
if (-not (Test-Path -LiteralPath $BashPath -PathType Leaf)) {
  throw "Git Bash was not found: $BashPath"
}
foreach ($tool in @('ssh.exe', 'ssh-keygen.exe', 'ssh-keyscan.exe')) {
  $toolPath = Join-Path $GitSshDirectory $tool
  if (-not (Test-Path -LiteralPath $toolPath -PathType Leaf)) {
    throw "Git SSH tool was not found: $toolPath"
  }
}

$sshDirectory = Join-Path $env:USERPROFILE '.ssh'
[void](New-Item -ItemType Directory -Path $sshDirectory -Force)
if ([string]::IsNullOrWhiteSpace($ReleaseKeyPath)) {
  $keyCandidates = @(Get-ChildItem -LiteralPath $sshDirectory -File | Where-Object {
    $_.Name -like 'wenyou_release_ed25519*' -and $_.Extension -ne '.pub'
  })
  if ($keyCandidates.Count -ne 1) {
    throw 'Unable to choose the release SSH key. Pass -ReleaseKeyPath after creating a dedicated ED25519 key.'
  }
  $ReleaseKeyPath = $keyCandidates[0].FullName
}
$ReleaseKeyPath = [IO.Path]::GetFullPath($ReleaseKeyPath)
if (-not (Test-Path -LiteralPath $ReleaseKeyPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath "$ReleaseKeyPath.pub" -PathType Leaf)) {
  throw "The release SSH key pair was not found: $ReleaseKeyPath"
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$system = ([Security.Principal.SecurityIdentifier]'S-1-5-18').Translate(
  [Security.Principal.NTAccount]
).Value
$privateKeyAcl = [IO.File]::GetAccessControl(
  $ReleaseKeyPath,
  [Security.AccessControl.AccessControlSections]::Access
)
$privateKeyAcl.SetAccessRuleProtection($true, $false)
foreach ($rule in @($privateKeyAcl.Access)) {
  [void]$privateKeyAcl.RemoveAccessRuleAll($rule)
}
[void]$privateKeyAcl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule(
  $identity, 'FullControl', 'Allow'
)))
[void]$privateKeyAcl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule(
  $system, 'FullControl', 'Allow'
)))
[IO.File]::SetAccessControl($ReleaseKeyPath, $privateKeyAcl)

$sshConfigPath = Join-Path $sshDirectory 'config'
$sshConfigContent = if (Test-Path -LiteralPath $sshConfigPath) {
  [IO.File]::ReadAllText($sshConfigPath)
}
else {
  ''
}
$aliasPattern = '(?m)^\s*Host\s+' + [regex]::Escape($SshAlias) + '\s*$'
if ($sshConfigContent -notmatch $aliasPattern) {
  $separator = if ([string]::IsNullOrEmpty($sshConfigContent) -or $sshConfigContent.EndsWith("`n")) {
    ''
  }
  else {
    [Environment]::NewLine
  }
  $sshBlock = @(
    "Host $SshAlias",
    "  HostName $SshHost",
    "  User $SshUser",
    "  IdentityFile $ReleaseKeyPath",
    '  IdentitiesOnly yes',
    ''
  ) -join [Environment]::NewLine
  $utf8NoBom = New-Object Text.UTF8Encoding($false)
  [IO.File]::AppendAllText($sshConfigPath, $separator + $sshBlock, $utf8NoBom)
}

[void](New-Item -ItemType Directory -Path $ReleaseRoot -Force)
[void](New-Item -ItemType Directory -Path $DesktopPath -Force)
$installedScripts = @(
  'WenyouRelease.Common.ps1',
  'Set-RainS3Credentials.ps1',
  'Initialize-WenyouReleaseSsh.ps1',
  'Invoke-WenyouAndroidRelease.ps1',
  'Publish-WenyouAndroid.ps1'
)
foreach ($script in $installedScripts) {
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot $script) -Destination $ReleaseRoot -Force
}

$configPath = Join-Path $ReleaseRoot 'release-config.json'
$temporaryConfig = "$configPath.tmp"
[ordered]@{
  schemaVersion = 1
  projectPath = $projectPath
  bashPath = [IO.Path]::GetFullPath($BashPath)
  gitSshDirectory = [IO.Path]::GetFullPath($GitSshDirectory)
  sshHost = $SshHost
  sshAlias = $SshAlias
  releaseKeyPath = $ReleaseKeyPath
  installedAtUtc = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json | Set-Content -LiteralPath $temporaryConfig -Encoding UTF8
Move-Item -LiteralPath $temporaryConfig -Destination $configPath -Force

foreach ($launcher in @('Wenyou-Release-Setup.cmd', 'Wenyou-Publish-Android.cmd')) {
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot $launcher) -Destination $DesktopPath -Force
}

Write-Host "Wenyou release tools installed in: $ReleaseRoot"
Write-Host "Desktop launchers installed in: $DesktopPath"
Write-Host 'Existing DPAPI credentials were preserved.'

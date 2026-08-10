[CmdletBinding()]
param(
  [string]$SshHost,
  [string]$SshAlias,
  [string]$SshDirectory = (Join-Path $env:USERPROFILE '.ssh'),
  [string]$ConfigPath = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\release-config.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'WenyouRelease.Common.ps1')

$config = Read-WenyouReleaseConfig -ConfigPath $ConfigPath
if ([string]::IsNullOrWhiteSpace($SshHost)) {
  $SshHost = $config.sshHost
}
if ([string]::IsNullOrWhiteSpace($SshAlias)) {
  $SshAlias = $config.sshAlias
}
$keyScan = Join-Path $config.gitSshDirectory 'ssh-keyscan.exe'
$keygen = Join-Path $config.gitSshDirectory 'ssh-keygen.exe'
$ssh = Join-Path $config.gitSshDirectory 'ssh.exe'
$knownHosts = Join-Path $SshDirectory 'known_hosts'
foreach ($tool in @($keyScan, $keygen, $ssh)) {
  if (-not (Test-Path -LiteralPath $tool -PathType Leaf)) {
    throw "Required SSH tool was not found: $tool"
  }
}

$existing = & $keygen -F $SshHost -f $knownHosts 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($existing -join ''))) {
  $scanFile = [IO.Path]::GetTempFileName()
  try {
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $scanLines = @(& $keyScan -T 10 -t ed25519 $SshHost 2>$null)
    $scanExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorAction
    if ($scanExitCode -ne 0) {
      throw "Unable to scan the SSH host key for $SshHost."
    }
    $hostKeyLines = @($scanLines | Where-Object { $_ -match '^[^#].*ssh-ed25519\s+' })
    if ($hostKeyLines.Count -ne 1) {
      throw "Expected exactly one ED25519 host key for $SshHost."
    }
    $hostKeyLines[0] | Set-Content -LiteralPath $scanFile -Encoding ASCII
    $fingerprintOutput = & $keygen -lf $scanFile
    if ($LASTEXITCODE -ne 0 -or $fingerprintOutput -notmatch 'SHA256:[A-Za-z0-9+/=]+') {
      throw 'Unable to calculate the scanned SSH host fingerprint.'
    }
    $scannedFingerprint = $Matches[0]

    Write-Host ''
    Write-Host "Scanned $SshHost ED25519 fingerprint: $scannedFingerprint"
    Write-Host 'On the VPS console run:'
    Write-Host '  ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub'
    $consoleValue = Read-Host 'Paste the VPS console SHA256 fingerprint here'
    if ($consoleValue -notmatch 'SHA256:[A-Za-z0-9+/=]+') {
      throw 'No SHA256 fingerprint was found in the pasted value.'
    }
    if ($Matches[0] -ne $scannedFingerprint) {
      throw 'Fingerprint mismatch. known_hosts was not changed.'
    }

    [void](New-Item -ItemType Directory -Path $SshDirectory -Force)
    $currentContent = if (Test-Path -LiteralPath $knownHosts) {
      [IO.File]::ReadAllText($knownHosts)
    }
    else {
      ''
    }
    $separator = if ([string]::IsNullOrEmpty($currentContent) -or $currentContent.EndsWith("`n")) {
      ''
    }
    else {
      [Environment]::NewLine
    }
    [IO.File]::AppendAllText(
      $knownHosts,
      $separator + $hostKeyLines[0] + [Environment]::NewLine,
      [Text.Encoding]::ASCII
    )
    Write-Host "Trusted ED25519 host key added to $knownHosts"
  }
  finally {
    [IO.File]::Delete($scanFile)
  }
}
else {
  Write-Host "$SshHost already exists in known_hosts."
}

$preflight = Invoke-WenyouSshPreflight -SshPath $ssh -SshAlias $SshAlias
if ($preflight.ExitCode -ne 0) {
  $preflight.Output | ForEach-Object { Write-Host $_ }
  throw 'SSH release preflight failed. Verify authorized_keys and the VPS sudo rule.'
}
Write-Host 'SSH release access is ready.'

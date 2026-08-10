Set-StrictMode -Version Latest

function Read-WenyouReleaseConfig {
  param(
    [string]$ConfigPath = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\release-config.json')
  )

  if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Release configuration was not found. Run Install-WenyouReleaseTools.ps1 first: $ConfigPath"
  }
  $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
  if ($config.schemaVersion -ne 1 -or
      [string]::IsNullOrWhiteSpace($config.projectPath) -or
      [string]::IsNullOrWhiteSpace($config.bashPath) -or
      [string]::IsNullOrWhiteSpace($config.gitSshDirectory) -or
      [string]::IsNullOrWhiteSpace($config.sshHost) -or
      [string]::IsNullOrWhiteSpace($config.sshAlias)) {
    throw "Release configuration is invalid: $ConfigPath"
  }
  if (-not (Test-Path -LiteralPath (Join-Path $config.projectPath 'pubspec.yaml') -PathType Leaf)) {
    throw "Configured mobile project was not found: $($config.projectPath)"
  }
  if (-not (Test-Path -LiteralPath $config.bashPath -PathType Leaf)) {
    throw "Configured Git Bash was not found: $($config.bashPath)"
  }
  return $config
}

function ConvertTo-WenyouGitBashPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = [IO.Path]::GetFullPath($Path)
  if ($fullPath -notmatch '^(?<drive>[A-Za-z]):(?<tail>\\.*)$') {
    throw "Only local drive paths can be converted for Git Bash: $fullPath"
  }
  $drive = $Matches.drive.ToLowerInvariant()
  $tail = $Matches.tail.Replace('\', '/')
  return "/$drive$tail"
}

function Get-WenyouPubspecVersion {
  param([Parameter(Mandatory = $true)][string]$ProjectPath)

  $pubspec = Join-Path $ProjectPath 'pubspec.yaml'
  $versionLine = Select-String -LiteralPath $pubspec -Pattern '^version:\s*(\S+)\s*$' | Select-Object -First 1
  if ($null -eq $versionLine -or $versionLine.Matches.Count -ne 1) {
    throw 'Unable to read the application version from pubspec.yaml.'
  }
  $fullVersion = $versionLine.Matches[0].Groups[1].Value
  if ($fullVersion -notmatch '^(?<name>[0-9A-Za-z][0-9A-Za-z._-]{0,63})\+(?<build>[1-9][0-9]*)$') {
    throw "Invalid pubspec version: $fullVersion"
  }
  return [pscustomobject]@{
    Full = $fullVersion
    Name = $Matches.name
    Build = [int]$Matches.build
  }
}

function Invoke-WenyouSshPreflight {
  param(
    [Parameter(Mandatory = $true)][string]$SshPath,
    [Parameter(Mandatory = $true)][string]$SshAlias
  )

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $output = @(& $SshPath -o BatchMode=yes -o ConnectTimeout=10 $SshAlias 'sudo -n /usr/local/sbin/wenyousite-promote-android --help' 2>&1)
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorAction
  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = $output
  }
}

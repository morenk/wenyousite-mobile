[CmdletBinding()]
param(
  [ValidateSet('BuildOnly', 'UploadOnly', 'Publish')]
  [string]$Mode = 'BuildOnly',
  [string]$VersionName,
  [int]$BuildNumber,
  [string]$ConfigPath = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\release-config.json'),
  [string]$CredentialStore = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\rains3-credentials.json'),
  [string]$SshTarget
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'WenyouRelease.Common.ps1')

function Unprotect-DpapiString {
  param([Parameter(Mandatory = $true)][string]$ProtectedValue)

  $secureValue = ConvertTo-SecureString $ProtectedValue
  $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureValue)
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
  }
}

$config = Read-WenyouReleaseConfig -ConfigPath $ConfigPath
$projectPath = $config.projectPath
$bashPath = $config.bashPath
if ([string]::IsNullOrWhiteSpace($SshTarget)) {
  $SshTarget = $config.sshAlias
}
$version = Get-WenyouPubspecVersion -ProjectPath $projectPath
if ([string]::IsNullOrWhiteSpace($VersionName)) {
  $VersionName = $version.Name
}
if ($BuildNumber -le 0) {
  $BuildNumber = $version.Build
}

$releaseScript = Join-Path $projectPath 'tool\release-mobile-from-local.sh'
if (-not (Test-Path -LiteralPath $releaseScript -PathType Leaf)) {
  throw "The mobile release script was not found: $releaseScript"
}

$bashArguments = @(
  (ConvertTo-WenyouGitBashPath $releaseScript),
  '--version', $VersionName,
  '--build', [string]$BuildNumber,
  '--platform', 'android'
)
switch ($Mode) {
  'BuildOnly' { $bashArguments += '--build-only' }
  'UploadOnly' { $bashArguments += '--upload-only' }
}

$accessVariable = 'WENYOU_RELEASE_S3_ACCESS_KEY_ID'
$secretVariable = 'WENYOU_RELEASE_S3_SECRET_ACCESS_KEY'
$sshVariable = 'WENYOU_RELEASE_SSH_TARGET'
$previousAccess = [Environment]::GetEnvironmentVariable($accessVariable, 'Process')
$previousSecret = [Environment]::GetEnvironmentVariable($secretVariable, 'Process')
$previousSsh = [Environment]::GetEnvironmentVariable($sshVariable, 'Process')
$accessKeyPlaintext = $null
$secretKeyPlaintext = $null

try {
  if ($Mode -ne 'BuildOnly') {
    if (-not (Test-Path -LiteralPath $CredentialStore -PathType Leaf)) {
      throw "RainS3 credentials are not configured. Run Set-RainS3Credentials.ps1 first: $CredentialStore"
    }
    $credentials = Get-Content -LiteralPath $CredentialStore -Raw | ConvertFrom-Json
    if ($credentials.schemaVersion -ne 1 -or
        [string]::IsNullOrWhiteSpace($credentials.accessKeyProtected) -or
        [string]::IsNullOrWhiteSpace($credentials.secretKeyProtected)) {
      throw "The RainS3 credential store is invalid: $CredentialStore"
    }
    $accessKeyPlaintext = Unprotect-DpapiString $credentials.accessKeyProtected
    $secretKeyPlaintext = Unprotect-DpapiString $credentials.secretKeyProtected
    [Environment]::SetEnvironmentVariable($accessVariable, $accessKeyPlaintext, 'Process')
    [Environment]::SetEnvironmentVariable($secretVariable, $secretKeyPlaintext, 'Process')
  }
  if ($Mode -eq 'Publish') {
    [Environment]::SetEnvironmentVariable($sshVariable, $SshTarget, 'Process')
  }

  Write-Host "Starting Android release: Mode=$Mode Version=$VersionName Build=$BuildNumber"
  & $bashPath @bashArguments
  if ($LASTEXITCODE -ne 0) {
    throw "The mobile release script failed with exit code $LASTEXITCODE."
  }
}
finally {
  [Environment]::SetEnvironmentVariable($accessVariable, $previousAccess, 'Process')
  [Environment]::SetEnvironmentVariable($secretVariable, $previousSecret, 'Process')
  [Environment]::SetEnvironmentVariable($sshVariable, $previousSsh, 'Process')
  $accessKeyPlaintext = $null
  $secretKeyPlaintext = $null
}

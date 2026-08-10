[CmdletBinding()]
param(
  [string]$CredentialStore = (Join-Path $env:LOCALAPPDATA 'WenyouSite\release\rains3-credentials.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-RequiredSecret {
  param([Parameter(Mandatory = $true)][string]$Prompt)

  $value = Read-Host -Prompt $Prompt -AsSecureString
  if ($value.Length -eq 0) {
    throw "$Prompt must not be empty."
  }
  return $value
}

function Protect-PrivateFile {
  param([Parameter(Mandatory = $true)][string]$Path)

  $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
  $system = ([Security.Principal.SecurityIdentifier]'S-1-5-18').Translate(
    [Security.Principal.NTAccount]
  ).Value
  $acl = [IO.File]::GetAccessControl(
    $Path,
    [Security.AccessControl.AccessControlSections]::Access
  )
  $acl.SetAccessRuleProtection($true, $false)
  foreach ($rule in @($acl.Access)) {
    [void]$acl.RemoveAccessRuleAll($rule)
  }
  $userRule = New-Object Security.AccessControl.FileSystemAccessRule(
    $identity, 'FullControl', 'Allow'
  )
  $systemRule = New-Object Security.AccessControl.FileSystemAccessRule(
    $system, 'FullControl', 'Allow'
  )
  [void]$acl.AddAccessRule($userRule)
  [void]$acl.AddAccessRule($systemRule)
  [IO.File]::SetAccessControl($Path, $acl)
}

$accessKey = Read-RequiredSecret 'RainS3 new Access Key (hidden input)'
$secretKey = Read-RequiredSecret 'RainS3 new Secret Key (hidden input)'
$credentialDirectory = Split-Path -Parent $CredentialStore
[void](New-Item -ItemType Directory -Path $credentialDirectory -Force)

$payload = [ordered]@{
  schemaVersion = 1
  accessKeyProtected = ConvertFrom-SecureString $accessKey
  secretKeyProtected = ConvertFrom-SecureString $secretKey
  savedAtUtc = [DateTime]::UtcNow.ToString('o')
}
$temporaryPath = "$CredentialStore.tmp"
$payload | ConvertTo-Json | Set-Content -LiteralPath $temporaryPath -Encoding UTF8
Move-Item -LiteralPath $temporaryPath -Destination $CredentialStore -Force
Protect-PrivateFile -Path $CredentialStore

Write-Host "RainS3 release credentials were protected with Windows DPAPI: $CredentialStore"
Write-Host 'No plaintext was persisted. Only this Windows user on this machine can decrypt the values.'

param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[0-9a-f]{40}$')]
  [string]$Revision
)
$ErrorActionPreference = 'Stop'
$advancedRoot = Split-Path -Parent $PSScriptRoot
$advancedSource = Join-Path $advancedRoot 'contracts/toolbox'
$advancedFiles = [ordered]@{
  'advanced-name-data.json' = 'src/lib/tools/advanced-name-data.json'
  'advanced-name-manifest.json' = 'src/lib/tools/advanced-name-manifest.json'
  'advanced-name-fixtures.json' = 'src/lib/tools/advanced-name-fixtures.json'
  'LICENSE.advanced-names.txt' = 'src/lib/tools/name-data/LICENSE.advanced-names.txt'
  'advanced-name-data-contract.md' = 'docs/modules/advanced-name-data-contract.md'
}
$advancedContents = [ordered]@{}
foreach ($entry in $advancedFiles.GetEnumerator()) {
  $startInfo = [Diagnostics.ProcessStartInfo]::new()
  $startInfo.FileName = 'ssh'
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
  $startInfo.ArgumentList.Add('-o')
  $startInfo.ArgumentList.Add('BatchMode=yes')
  $startInfo.ArgumentList.Add('-o')
  $startInfo.ArgumentList.Add('ConnectTimeout=10')
  $startInfo.ArgumentList.Add('wenyou-dev-vps')
  $startInfo.ArgumentList.Add("git -C /srv/wenyousite/wenyousite-frontend show ${Revision}:$($entry.Value)")
  $process = [Diagnostics.Process]::Start($startInfo)
  $contents = $process.StandardOutput.ReadToEnd()
  $process.WaitForExit()
  if ($process.ExitCode -ne 0) { throw "无法读取已提交进阶数据：$($entry.Value)" }
  $advancedContents[$entry.Key] = $contents
}
New-Item -ItemType Directory -Path $advancedSource -Force | Out-Null
$advancedMetadata = [ordered]@{}
foreach ($entry in $advancedFiles.GetEnumerator()) {
  $destination = Join-Path $advancedSource $entry.Key
  [IO.File]::WriteAllText($destination, $advancedContents[$entry.Key], [Text.UTF8Encoding]::new($false))
  $advancedMetadata[$entry.Key] = [ordered]@{ path = $entry.Value; sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$manifest = [ordered]@{ schemaVersion = 2; repository = 'https://github.com/morenk/wenyousite-frontend'; revision = $Revision; files = $advancedMetadata }
[IO.File]::WriteAllText((Join-Path $advancedSource 'source-advanced.json'), ($manifest | ConvertTo-Json -Depth 5) + "`n", [Text.UTF8Encoding]::new($false))
Push-Location $advancedRoot
try {
  & dart run tool/generate_advanced_name_data.dart
  if ($LASTEXITCODE -ne 0) { throw 'Dart 进阶词库生成失败' }
} finally { Pop-Location }

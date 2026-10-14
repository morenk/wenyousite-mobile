param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[0-9a-f]{40}$')]
  [string]$Revision
)
$ErrorActionPreference = 'Stop'
$historicalRoot = Split-Path -Parent $PSScriptRoot
$historicalSource = Join-Path $historicalRoot 'contracts/toolbox'
$historicalFiles = [ordered]@{
  'historical-name-data.json' = 'src/lib/tools/historical-name-data.json'
  'historical-name-manifest.json' = 'src/lib/tools/historical-name-manifest.json'
  'historical-name-fixtures.json' = 'src/lib/tools/historical-name-fixtures.json'
  'LICENSE.historical-names.txt' = 'src/lib/tools/name-data/LICENSE.historical-names.txt'
  'historical-name-data-contract.md' = 'docs/modules/historical-name-data-contract.md'
}
$historicalContents = [ordered]@{}
foreach ($entry in $historicalFiles.GetEnumerator()) {
  $startInfo = [Diagnostics.ProcessStartInfo]::new()
  $startInfo.FileName = 'ssh'
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
  $startInfo.ArgumentList.Add('wenyou-dev-vps')
  $startInfo.ArgumentList.Add("git -C /srv/wenyousite/wenyousite-frontend show ${Revision}:$($entry.Value)")
  $process = [Diagnostics.Process]::Start($startInfo)
  $contents = $process.StandardOutput.ReadToEnd()
  $process.WaitForExit()
  if ($process.ExitCode -ne 0) { throw "无法读取已提交历史数据：$($entry.Value)" }
  $historicalContents[$entry.Key] = $contents
}
New-Item -ItemType Directory -Path $historicalSource -Force | Out-Null
$historicalMetadata = [ordered]@{}
foreach ($entry in $historicalFiles.GetEnumerator()) {
  $destination = Join-Path $historicalSource $entry.Key
  [IO.File]::WriteAllText($destination, $historicalContents[$entry.Key], [Text.UTF8Encoding]::new($false))
  $historicalMetadata[$entry.Key] = [ordered]@{ path = $entry.Value; sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$manifest = [ordered]@{ schemaVersion = 1; repository = 'https://github.com/morenk/wenyousite-frontend'; revision = $Revision; files = $historicalMetadata }
[IO.File]::WriteAllText((Join-Path $historicalSource 'source-historical.json'), ($manifest | ConvertTo-Json -Depth 5) + "`n", [Text.UTF8Encoding]::new($false))
Push-Location $historicalRoot
try {
  & dart run tool/generate_historical_name_data.dart
  if ($LASTEXITCODE -ne 0) { throw 'Dart 历史词库生成失败' }
} finally { Pop-Location }

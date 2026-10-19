param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[0-9a-f]{40}$')]
  [string]$Revision
)
$ErrorActionPreference = 'Stop'
$fancyRoot = Split-Path -Parent $PSScriptRoot
$fancyDestination = Join-Path $fancyRoot 'contracts/toolbox'
$fancyFiles = [ordered]@{
  'fancy-data.json' = 'src/lib/tools/fancy-data.json'
  'fancy-manifest.json' = 'src/lib/tools/fancy-manifest.json'
  'fancy-fixtures.json' = 'src/lib/tools/fancy-fixtures.json'
  'fancy-source.ts' = 'src/lib/tools/fancy.ts'
  'fancy-data-contract.md' = 'docs/modules/fancy-data-contract.md'
  'LICENSE.fancy.txt' = 'src/lib/tools/LICENSE.fancy.txt'
  'LICENSE.fancy-public.txt' = 'public/licenses/fancy.txt'
}
$fancyContents = [ordered]@{}
foreach ($entry in $fancyFiles.GetEnumerator()) {
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
  if ($process.ExitCode -ne 0) { throw "无法读取已提交花体数据：$($entry.Value)" }
  $fancyContents[$entry.Key] = $contents
}
$fancyMetadata = [ordered]@{}
foreach ($entry in $fancyFiles.GetEnumerator()) {
  $destination = Join-Path $fancyDestination $entry.Key
  [IO.File]::WriteAllText($destination, $fancyContents[$entry.Key], [Text.UTF8Encoding]::new($false))
  $fancyMetadata[$entry.Key] = [ordered]@{
    path = $entry.Value
    sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
  }
}
$manifest = [ordered]@{
  schemaVersion = 1
  repository = 'https://github.com/morenk/wenyousite-frontend'
  revision = $Revision
  files = $fancyMetadata
}
[IO.File]::WriteAllText((Join-Path $fancyDestination 'source-fancy.json'), ($manifest | ConvertTo-Json -Depth 5) + "`n", [Text.UTF8Encoding]::new($false))
Push-Location $fancyRoot
try {
  & dart run tool/generate_fancy_data.dart
  if ($LASTEXITCODE -ne 0) { throw '花体数据生成失败' }
} finally { Pop-Location }

param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[0-9a-f]{40}$')]
  [string]$Revision
)
$ErrorActionPreference = 'Stop'
$toolboxRoot = Split-Path -Parent $PSScriptRoot
$toolboxSource = Join-Path $toolboxRoot 'contracts/toolbox'
New-Item -ItemType Directory -Path $toolboxSource -Force | Out-Null
$toolboxFiles = [ordered]@{
  'bilingual-name-data.json' = 'src/lib/tools/bilingual-name-data.json'
  'name-inspiration.json' = 'src/lib/tools/name-inspiration.json'
  'cn.json' = 'src/lib/tools/name-data/cn.json'
  'LICENSE.faker.txt' = 'src/lib/tools/name-data/LICENSE.faker.txt'
  'name-fixtures.json' = 'src/lib/tools/name-fixtures.json'
  'name-data-manifest.json' = 'src/lib/tools/name-data-manifest.json'
  'LICENSE.wenyou.txt' = 'src/lib/tools/name-data/LICENSE.wenyou.txt'
}
$toolboxMetadata = [ordered]@{}
foreach ($entry in $toolboxFiles.GetEnumerator()) {
  $startInfo = [Diagnostics.ProcessStartInfo]::new()
  $startInfo.FileName = 'ssh'
  $startInfo.UseShellExecute = $false
  $startInfo.RedirectStandardOutput = $true
  $startInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
  $startInfo.ArgumentList.Add('wenyou-dev-vps')
  $startInfo.ArgumentList.Add("git -C /srv/wenyousite/wenyousite-frontend show ${Revision}:$($entry.Value)")
  $process = [Diagnostics.Process]::Start($startInfo)
  $contents = $process.StandardOutput.ReadToEnd()
  $process.WaitForExit()
  if ($process.ExitCode -ne 0) { throw "无法读取已提交数据：$($entry.Value)" }
  $destination = Join-Path $toolboxSource $entry.Key
  [IO.File]::WriteAllText($destination, $contents, [Text.UTF8Encoding]::new($false))
  $toolboxMetadata[$entry.Key] = [ordered]@{ path = $entry.Value; sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$manifest = [ordered]@{ schemaVersion = 1; repository = 'https://github.com/morenk/wenyousite-frontend'; revision = $Revision; files = $toolboxMetadata }
[IO.File]::WriteAllText((Join-Path $toolboxSource 'source.json'), ($manifest | ConvertTo-Json -Depth 5) + "`n", [Text.UTF8Encoding]::new($false))
Push-Location $toolboxRoot
try {
  & dart run tool/generate_toolbox_data.dart
  if ($LASTEXITCODE -ne 0) { throw 'Dart 词库生成失败' }
} finally { Pop-Location }

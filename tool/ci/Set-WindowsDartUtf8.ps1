[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-DartUtf8Manifest {
  param([Parameter(Mandatory)][xml]$Manifest)
  $assemblyNamespace = 'urn:schemas-microsoft-com:asm.v3'
  $application = $Manifest.SelectSingleNode('/*[local-name()="assembly"]/*[local-name()="application"]')
  if ($null -eq $application) {
    $application = $Manifest.CreateElement('application', $assemblyNamespace)
    [void]$Manifest.DocumentElement.AppendChild($application)
  }
  $settings = $application.SelectSingleNode('*[local-name()="windowsSettings"]')
  if ($null -eq $settings) {
    $settings = $Manifest.CreateElement('windowsSettings', $assemblyNamespace)
    [void]$application.AppendChild($settings)
  }
  $codePage = $settings.SelectSingleNode('*[local-name()="activeCodePage"]')
  if ($null -eq $codePage) {
    $codePage = $Manifest.CreateElement('activeCodePage', 'http://schemas.microsoft.com/SMI/2019/WindowsSettings')
    [void]$settings.AppendChild($codePage)
  }
  $codePage.InnerText = 'UTF-8'
  return $Manifest.OuterXml
}

function Get-ExecutableCodeHashes {
  param([Parameter(Mandatory)][string]$Path)
  $bytes = [IO.File]::ReadAllBytes($Path)
  $pe = [BitConverter]::ToInt32($bytes, 0x3c)
  if ([BitConverter]::ToUInt32($bytes, $pe) -ne 0x4550) { throw 'Invalid PE executable.' }
  $count = [BitConverter]::ToUInt16($bytes, $pe + 6)
  $table = $pe + 24 + [BitConverter]::ToUInt16($bytes, $pe + 20)
  $hashes = [ordered]@{}
  for ($index = 0; $index -lt $count; $index++) {
    $section = $table + 40 * $index
    $flags = [BitConverter]::ToUInt32($bytes, $section + 36)
    if (($flags -band 0x20000020) -eq 0) { continue }
    $name = [Text.Encoding]::ASCII.GetString($bytes, $section, 8).Trim([char]0)
    $size = [BitConverter]::ToInt32($bytes, $section + 16)
    $offset = [BitConverter]::ToInt32($bytes, $section + 20)
    $code = [byte[]]::new($size)
    [Array]::Copy($bytes, $offset, $code, 0, $size)
    $hashes[$name] = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($code))
  }
  if ($hashes.Count -eq 0) { throw 'Executable has no code sections.' }
  return $hashes | ConvertTo-Json -Compress
}

# 点引入仅供验证纯 XML 转换和代码段摘要；实际工具修改只允许临时 GitHub Windows runner。
if ($MyInvocation.InvocationName -eq '.') { return }
if (-not $IsWindows -or $env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_OS -ne 'Windows') {
  throw 'UTF-8 tool configuration is restricted to GitHub Windows CI.'
}
$flutterRoot = [IO.Path]::GetFullPath($env:FLUTTER_ROOT)
$toolCache = [IO.Path]::GetFullPath($env:RUNNER_TOOL_CACHE).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if (-not $flutterRoot.StartsWith($toolCache, [StringComparison]::OrdinalIgnoreCase)) {
  throw 'Flutter SDK is outside the temporary runner tool cache.'
}
$kits = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
$mt = Get-ChildItem -Path (Join-Path $kits '*\x64\mt.exe') -File | Sort-Object FullName -Descending | Select-Object -First 1
if ($null -eq $mt) { throw 'Windows SDK manifest tool mt.exe is required.' }
$evidence = Join-Path $env:RUNNER_TEMP 'wenyou-dart-utf8'
New-Item -ItemType Directory -Path $evidence -Force | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)
foreach ($name in @('dart.exe', 'dartvm.exe', 'dartaotruntime.exe')) {
  $executable = Join-Path $flutterRoot "bin\cache\dart-sdk\bin\$name"
  if ((Get-AuthenticodeSignature -LiteralPath $executable).Status -ne 'NotSigned') {
    throw "Refusing to alter an Authenticode-signed or unverifiable SDK tool: $name"
  }
  $beforeHash = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash
  $beforeCode = Get-ExecutableCodeHashes -Path $executable
  $beforeManifest = Join-Path $evidence "$name.before.manifest"
  $afterManifest = Join-Path $evidence "$name.utf8.manifest"
  & $mt.FullName '-nologo' "-inputresource:$executable;#1" "-out:$beforeManifest"
  if ($LASTEXITCODE -ne 0) { throw "Cannot extract the original manifest: $name" }
  [xml]$original = [IO.File]::ReadAllText($beforeManifest)
  [IO.File]::WriteAllText($afterManifest, (ConvertTo-DartUtf8Manifest $original), $utf8)
  & $mt.FullName '-nologo' '-manifest' $afterManifest "-outputresource:$executable;#1"
  if ($LASTEXITCODE -ne 0) { throw "Cannot set the tool process code page: $name" }
  if ((Get-ExecutableCodeHashes -Path $executable) -cne $beforeCode) {
    throw "SDK executable code changed while setting its manifest: $name"
  }
  $afterHash = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash
  Write-Host "$name activeCodePage=UTF-8; executable code unchanged; before=$beforeHash after=$afterHash"
}
& (Join-Path $flutterRoot 'bin\cache\dart-sdk\bin\dart.exe') (Join-Path $PSScriptRoot 'check_windows_utf8.dart')
if ($LASTEXITCODE -ne 0) { throw 'Dart system encoding is not UTF-8 after manifest configuration.' }

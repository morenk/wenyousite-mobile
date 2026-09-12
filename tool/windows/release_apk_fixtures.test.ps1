Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Test-WenyouReleaseApk.ps1')

$workspace = Join-Path ([IO.Path]::GetTempPath()) ('wenyou-apk-test-' + [guid]::NewGuid())
[IO.Directory]::CreateDirectory($workspace) | Out-Null
$required = @(
  'lib/arm64-v8a/libapp.so',
  'lib/arm64-v8a/libflutter.so'
)
function Assert-Artifact {
  param([string[]]$Names, [bool]$Valid)
  $path = Join-Path $workspace ([guid]::NewGuid().ToString() + '.apk')
  try {
    $zip = [IO.Compression.ZipFile]::Open($path, [IO.Compression.ZipArchiveMode]::Create)
    try {
      foreach ($name in $Names) {
        $stream = $zip.CreateEntry($name).Open()
        try { $stream.WriteByte(1) } finally { $stream.Dispose() }
      }
    } finally { $zip.Dispose() }
    $accepted = $false
    try { Test-WenyouReleaseApk -Path $path | Out-Null; $accepted = $true } catch { }
    if ($accepted -ne $Valid) { throw "Unexpected artifact acceptance: expected $Valid, got $accepted" }
  } finally { Remove-Item -LiteralPath $path -ErrorAction SilentlyContinue }
}
try {
  Assert-Artifact -Names ($required + 'lib/arm64-v8a/libsqlite3.so') -Valid $true
  foreach ($abi in @('armeabi-v7a', 'x86_64', 'x86')) {
    Assert-Artifact -Names ($required + "lib/$abi/libsqlite3.so") -Valid $false
  }
  foreach ($missing in $required) {
    Assert-Artifact -Names @($required | Where-Object { $_ -ne $missing }) -Valid $false
  }
  Assert-Artifact -Names ($required + $required[0]) -Valid $false
  foreach ($removedFont in @(
    'assets/flutter_assets/NotoSansSC-Variable.ttf',
    'assets/flutter_assets/LXGWWenKaiLite-Medium.ttf',
    'assets/flutter_assets/Nunito-Variable.ttf',
    'assets/flutter_assets/WenyouGoldenText-Variable.ttf'
  )) {
    Assert-Artifact -Names ($required + $removedFont) -Valid $false
  }
  Assert-Artifact -Names ($required + 'assets/flutter_assets/fonts/MaterialIcons-Regular.otf') -Valid $true
  Write-Output 'Validated ARM64-only, required libraries, removed UI/test fonts and functional fonts.'
} finally { Remove-Item -LiteralPath $workspace }

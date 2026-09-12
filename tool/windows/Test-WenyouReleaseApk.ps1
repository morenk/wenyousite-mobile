[CmdletBinding()]
param([string]$ApkPath)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-WenyouReleaseApk {
  param([Parameter(Mandatory = $true)][string]$Path)

  $resolved = (Resolve-Path -LiteralPath $Path).Path
  $archive = [IO.Compression.ZipFile]::OpenRead($resolved)
  try {
    $native = @($archive.Entries | Where-Object { $_.FullName -match '^lib/[^/]+/[^/]+\.so$' })
    if ($native.Count -eq 0) { throw 'APK does not contain native libraries.' }
    foreach ($entry in $native) {
      if ($entry.FullName -notmatch '^lib/arm64-v8a/' -or $entry.Length -eq 0) {
        throw "Release APK must contain only non-empty ARM64 libraries: $($entry.FullName)"
      }
    }
    $required = @(
      'lib/arm64-v8a/libapp.so',
      'lib/arm64-v8a/libflutter.so'
    )
    foreach ($name in $required) {
      $entries = @($archive.Entries | Where-Object { $_.FullName -ceq $name })
      if ($entries.Count -ne 1 -or $entries[0].Length -eq 0) {
        throw "Release APK requires exactly one non-empty entry: $name"
      }
    }
    $forbiddenFonts = @(
      $archive.Entries | Where-Object {
        $_.FullName -match '(?i)(NotoSansSC|LXGW|WenKai|Nunito|WenyouGoldenText)'
      }
    )
    if ($forbiddenFonts.Count -ne 0) {
      $names = $forbiddenFonts.FullName -join ', '
      throw "Release APK contains removed UI or test fonts: $names"
    }
    $functionalFonts = @(
      $archive.Entries | Where-Object {
        $_.FullName -match '(?i)(MaterialIcons|KaTeX|\.otf$|\.ttf$)'
      }
    )
    return [pscustomobject]@{
      abi = 'arm64-v8a'
      nativeLibraryCount = $native.Count
      bundledUiFonts = 0
      functionalFontEntries = $functionalFonts.Count
      apkSize = (Get-Item -LiteralPath $resolved).Length
    }
  }
  finally { $archive.Dispose() }
}

if ($ApkPath) { Test-WenyouReleaseApk -Path $ApkPath | ConvertTo-Json -Compress }

[CmdletBinding()]
param(
  [string]$DeviceSerial,
  [ValidateRange(3, 10)]
  [int]$Runs = 3,
  [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
  throw 'Android 性能基准只允许在 Windows 本地开发机运行。'
}

$repository = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$flutterCommand = (Get-Command flutter -ErrorAction Stop).Source
$dartCommand = (Get-Command dart -ErrorAction Stop).Source
$gitCommand = (Get-Command git -ErrorAction Stop).Source
$adbCandidates = @(
  (Join-Path 'D:\sdk\android' 'platform-tools\adb.exe')
)
if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) {
  $adbCandidates += Join-Path $env:ANDROID_SDK_ROOT 'platform-tools\adb.exe'
}
if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
  $adbCandidates += Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
}
$adbCommand = $adbCandidates |
  Where-Object { Test-Path -LiteralPath $_ } |
  Select-Object -First 1
if ($null -eq $adbCommand) {
  $adbCommand = (Get-Command adb -ErrorAction Stop).Source
}

function Invoke-Adb {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)

  $result = & $adbCommand -s $DeviceSerial @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "adb 调用失败：$($Arguments -join ' ')"
  }
  return ($result | Out-String).Trim()
}

$deviceRows = & $adbCommand devices
if ($LASTEXITCODE -ne 0) {
  throw '无法读取 Android 设备列表。'
}
$onlineSerials = @(
  $deviceRows |
    Select-Object -Skip 1 |
    ForEach-Object {
      if ($_ -match '^([^\s]+)\s+device$') { $Matches[1] }
    }
)
if ([string]::IsNullOrWhiteSpace($DeviceSerial)) {
  if ($onlineSerials.Count -ne 1) {
    throw "未指定 -DeviceSerial 时必须恰好连接一台在线设备，当前为 $($onlineSerials.Count) 台。"
  }
  $DeviceSerial = $onlineSerials[0]
} elseif ($DeviceSerial -notin $onlineSerials) {
  throw "设备 $DeviceSerial 未在线。"
}

if ((Invoke-Adb @('shell', 'getprop', 'ro.kernel.qemu')) -eq '1') {
  throw '性能门禁必须在 Android 真机运行，不能使用模拟器。'
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $repository "build\performance\$timestamp"
}
$outputPath = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$rawReport = Join-Path $repository 'build\integration_response_data.json'

$displayDump = Invoke-Adb @('shell', 'dumpsys', 'display')
$refreshRateMatch = [regex]::Match(
  $displayDump,
  'mActiveRenderFrameRate=([0-9]+(?:\.[0-9]+)?)'
)
$refreshRate = if ($refreshRateMatch.Success) {
  [math]::Round([double]$refreshRateMatch.Groups[1].Value, 3)
} else {
  $null
}
$flutterVersion = (& $flutterCommand --version --machine | ConvertFrom-Json)
$metadata = [ordered]@{
  manufacturer = Invoke-Adb @('shell', 'getprop', 'ro.product.manufacturer')
  model = Invoke-Adb @('shell', 'getprop', 'ro.product.model')
  androidVersion = Invoke-Adb @('shell', 'getprop', 'ro.build.version.release')
  androidApi = [int](Invoke-Adb @('shell', 'getprop', 'ro.build.version.sdk'))
  primaryAbi = Invoke-Adb @('shell', 'getprop', 'ro.product.cpu.abi')
  refreshRateHz = $refreshRate
  flutterVersion = $flutterVersion.frameworkVersion
  dartVersion = $flutterVersion.dartSdkVersion
  renderer = 'Impeller (default enabled)'
}
$metadataPath = Join-Path $outputPath 'device.json'
$metadata | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metadataPath -Encoding utf8

Push-Location $repository
try {
  for ($run = 1; $run -le $Runs; $run++) {
    if (Test-Path -LiteralPath $rawReport) {
      Remove-Item -LiteralPath $rawReport -Force
    }
    Write-Host "`n==> Android Profile 性能采样 $run/$Runs"
    & $flutterCommand drive `
      --driver=test_driver/performance_test.dart `
      --target=integration_test/performance_test.dart `
      --profile `
      --no-dds `
      --device-id=$DeviceSerial
    if ($LASTEXITCODE -ne 0) {
      throw "第 $run 轮 Profile 性能采样失败。"
    }
    if (-not (Test-Path -LiteralPath $rawReport)) {
      throw "第 $run 轮未生成 $rawReport。"
    }
    Copy-Item -LiteralPath $rawReport -Destination (
      Join-Path $outputPath "run-$run.json"
    )
  }

  $profileApk = Join-Path $repository 'build\app\outputs\flutter-apk\app-profile.apk'
  if (-not (Test-Path -LiteralPath $profileApk)) {
    throw "未找到 Profile APK：$profileApk"
  }
  $installResult = Invoke-Adb @('install', '-r', $profileApk)
  if ($installResult -notmatch 'Success') {
    throw "Profile APK 安装失败：$installResult"
  }
  $profilePackagePath = Invoke-Adb @(
    'shell',
    'pm',
    'path',
    'site.wenyou.app.profile'
  )
  if (-not $profilePackagePath.StartsWith('package:')) {
    throw 'Profile 构建未以 site.wenyou.app.profile 安装。'
  }
  $sourceRevision = (& $gitCommand rev-parse HEAD).Trim()
  $summaryPath = Join-Path $outputPath 'summary.json'
  & $dartCommand run tool/evaluate_android_performance.dart `
    --input-dir $outputPath `
    --metadata $metadataPath `
    --source-revision $sourceRevision `
    --output $summaryPath
  if ($LASTEXITCODE -ne 0) {
    throw "60 Hz 性能门禁失败，详见 $summaryPath。"
  }
  Write-Host "`n性能采样完成：$summaryPath"
} finally {
  Pop-Location
}

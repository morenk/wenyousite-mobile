[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$taskOutput = Join-Path (Get-Location) '.dart_tool/rich-text-behavior/flutter-results.json'
# 本轮任何前置检查或测试失败都不能留下可冒充本轮成功的旧汇总。
if (Test-Path -LiteralPath $taskOutput) { Remove-Item -LiteralPath $taskOutput }
$taskChanges = @(git status --porcelain --untracked-files=normal)
if ($LASTEXITCODE -ne 0 -or $taskChanges.Count -gt 0) {
  throw '导出回执前必须提交当前变更，避免源码 SHA 与实际执行不一致。'
}
$taskRevision = (git rev-parse HEAD).Trim()
$taskTests = @(
  'test/features/editor/rich_text_behavior_contract_test.dart',
  'test/features/editor/rich_text_reader_behavior_test.dart',
  'test/features/editor/thread_compose_codec_exit_test.dart',
  'test/features/posts/rich_text_save_behavior_test.dart'
)
flutter test --no-pub "--dart-define=RICH_TEXT_SOURCE_REVISION=$taskRevision" @taskTests --reporter expanded
if ($LASTEXITCODE -ne 0) { throw '共享行为实测失败，不生成汇总回执。' }
$taskHash = (Get-FileHash contracts/rich-text-behavior-v1-fixtures.json -Algorithm SHA256).Hash.ToLowerInvariant()
$taskObservations = @()
$taskReport = $null
foreach ($taskGroup in @('editor', 'reader', 'save', 'close')) {
  $taskShard = Get-Content ".dart_tool/rich-text-behavior/$taskGroup.json" -Raw | ConvertFrom-Json
  if ($taskShard.sourceRevision -ne $taskRevision -or $taskShard.fixtureSha256 -ne $taskHash) {
    throw "回执分片来源不一致：$taskGroup"
  }
  $taskObservations += @($taskShard.observations)
  $taskReport = $taskShard
}
$taskKeys = @($taskObservations | ForEach-Object { "$($_.caseId)/$($_.stepId)/$($_.stage)" })
if (@($taskKeys | Select-Object -Unique).Count -ne $taskKeys.Count) { throw '回执出现重复检查点。' }
$taskReport.observations = $taskObservations
[IO.File]::WriteAllText($taskOutput, ($taskReport | ConvertTo-Json -Depth 60) + "`n")
Write-Output "已导出 $($taskObservations.Count) 条实测观测：$taskOutput"

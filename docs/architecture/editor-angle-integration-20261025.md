# PR #76 六项组合前的最新基线适配

状态：候选／待负责人验收。负责人本轮要求依次更新原 PR、整合最新 `dev`、完成检查后交付一个包含六项的组合验收 APK，先不合并。

## 基线与范围

- 原分支 `codex/20260929-editor-guard-diagnostics`，原提交 `d20e7fcad749d60987e7f84720a04aaf98c1364a`，Worktree 为 `D:\codex-worktrees\editor-guard-diagnostics\wenyousite-mobile`。
- 普通 merge `origin/dev@b7e1a4acf9433b38b29505834b5f1eea77598330`，保留历史、不强推。文档冲突逐块保留双方；源码自动合并后另外复核。
- 使用基线已提交的 Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`、API `5.44.0-dev.20261024.3` 和 Foundation `v7.6.0`，没有新增契约或依赖变化。
- 保留原尖括号解析、有效对齐元信息、严格保护和打开诊断；原精确触发输入、旧红证据与历史完整门禁见[历史记录](editor-angle-integration-20261021.md)，历史 APK 不代表此次源码。

## 后续字体功能适配

旧候选在两处只识别颜色：写回转义的 `color` 属性判断，以及打开内容的 `<span data-wenyou-color-v1=` 前缀判断。当前 `dev` 已将字体 v1/v2 与颜色放在同一个受控 span 中，因此写回同时识别真实 `font`，打开时使用共享的合法标签解析。受控标签合法性仍由现有契约解析器校验，不放宽任意 HTML 或实体标签保护。

新增 `test/features/editor/editor_angle_font_integration_test.dart`，独立断言纯字体规范源码、实体标签的可见文字、字体/颜色/粗体属性、输入、撤销、保存与重开。正文中的实体字体标签在真实字体旁仍必须保持字面文字，不能获得字体属性。

## 本轮失败记录与修正

- 在新字体回归中临时恢复普通 merge 后、尚未适配字体的两个写回文件，两项纯字体 v1/v2 均运行失败：正文被打开保护判为只读，属于真实断言失败而非编译错误。候选文件由 `finally` 按原字节恢复。日志 `build/editor-integration-20261025/font-old-red.log`，SHA-256 `D2FC1A3E7AA9850F71324E509F9F43CBF2A498D330B41BABF301E05AB304A74A`。
- 首轮只补写回字体条件时，23 文件定向结果为 517 通过／102 失败。原尖括号楼层回归通过，失败集中于字体路径；进一步确认打开保护仍只按颜色属性前缀识别 span。改为实际 HTML 消费范围内使用共享合法样式标签解析，保留未知／损坏 HTML 保护。日志 `build/editor-integration-20261025/focused.log`，SHA-256 `92CA32F03BE4BBE896629F367C119FDDA312784EAE8FE934CCCFE5653B2AFED2`。
## 检查和交付边界

最终检查脚本 `build/editor-integration-20261025/run-focused-retry1.ps1` 退出 0：23 文件 619 项通过，0 跳过／0 失败；全仓 1560 个 Dart 文件格式无变化；相对当前 dev 的全部 21 个差异 Dart 文件（含新测试）使用 `flutter analyze --no-pub --fatal-infos --fatal-warnings`，零问题；架构、23 模块文档及 diff 空白检查通过。

检查后的冻结树为 `981d8f9acdee51057201b049abdc3da107db8d9a`。最终提交只在该树上补充本记录的证据，不改应用或测试源码。最终日志 `build/editor-integration-20261025/focused-retry1.log`，SHA-256 `ACF7C112681A550B34D0BA7FF587A5D7A02E99BFC84070284A1D4E260CC0D335`。日志路径均相对本 Worktree，日志留本地，未将原楼层正文加入 Git。

实际定向命令为 `flutter test --no-pub --concurrency=1 --reporter expanded`，随后传入以下 23 个路径：

```text
test/features/editor/editor_angle_font_integration_test.dart
test/core/markdown/markdown_angle_text_test.dart
test/core/markdown/markdown_metadata_protocol_test.dart
test/core/markdown/markdown_inline_code_scanner_test.dart
test/core/markdown/markdown_inline_code_protection_test.dart
test/core/markdown/markdown_container_code_protection_test.dart
test/core/markdown/markdown_plain_text_preview_test.dart
test/core/markdown/markdown_text_color_test.dart
test/core/markdown/markdown_text_font_test.dart
test/core/markdown/markdown_text_font_v2_test.dart
test/core/markdown/markdown_link_identity_test.dart
test/core/markdown/markdown_delta_codec_test.dart
test/core/markdown/markdown_alignment_compatibility_test.dart
test/features/editor/editor_angle_integration_test.dart
test/features/editor/editor_open_diagnostics_test.dart
test/features/editor/editor_publish_preparation_test.dart
test/features/editor/editor_text_color_audio_integration_test.dart
test/features/editor/editor_text_color_roundtrip_test.dart
test/features/editor/editor_text_font_session_test.dart
test/features/editor/editor_text_font_web_interop_test.dart
test/features/posts/post_composer_angle_text_test.dart
test/features/posts/post_composer_open_diagnostics_test.dart
build/editor-integration-20261021/original_current_test.dart
```

最后一项复用本地保留的原 2813 字符／9 个居中块楼层测试，实际重新执行；文件及正文未提交。契约、生成 SDK、依赖锁与原生配置相对 `origin/dev` 均零差异。

本分支没有本轮独立完整门禁或新 APK；最终六项组合的完整 `npm run check:apk -- -TestConcurrency 1` 和 APK 以组合分支记录为准，不把历史完整门禁或本分支定向检查称作当前完整门禁。

未安装或启动应用，未做线上业务写入、合并、部署、发布或关闭原问题。负责人仍需复验原楼层输入与真机操作；自动化及模拟诊断不能替代负责人验收和真实 Sentry 收件证据。

# 主题帖字号七档细化验收记录

状态：2026-10-15 负责人验收通过，已授权合并与清理任务分支、临时工作树。此前五档实现已通过验收并合并 PR #95，本记录仅覆盖后续七档调整。

## 需求与行为

负责人确认使用 13、14、15、16、17、18、19 七档。默认 16 位于滑杆正中，左右各三格，逐格 1sp；设置入口、当前值和刻度统一显示数字，移除原来的大小档位名称。七个数字与可点击滑杆位置一一对齐，继续保留固定高度的即时预览、松手保存、恢复默认、保存失败回滚和重试。

设备偏好沿用 `reading.threadFont.v1`。旧 `small`、`standard`、`large` 分别保留 14、16、18；旧 `extraLarge`、`largest` 调整为新上限 19。读取兼容不主动改写；用户选择新值时保存新枚举，恢复默认仍移除覆盖。正文作用范围与系统文字缩放保持，不改正文内容、API、账号或草稿。

## 基线与目录

- Windows 工作树：`D:\codex-worktrees\mobile-thread-font-ticks\wenyousite-mobile`。
- 分支：`codex/20261015-thread-font-ticks`；从 `origin/dev` 的 `e923ea694eb2ac3410c25b861cec09fbb0c764e9` 创建。
- Foundation 只读缓存已 fetch tags，最新正式版 `v7.2.1` 与固定依赖一致；不变更依赖。
- Backend 只读镜像 `origin/dev`、已记录 revision 及本轮公网 `/meta` 都为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，API `5.36.0-dev.20261005.1`，没有接口契约变更。
- 沿用负责人本次字号反馈“不需要完整门禁”的要求，只执行直接相关检查和 Debug 构建，不执行全量门禁。

## 本地验证与交付

- `flutter analyze --no-pub`：通过，无问题。
- `flutter test --no-pub test/core/application/thread_font_preference_test.dart test/core/storage/shared_preferences_thread_font_store_test.dart test/features/settings/thread_font_settings_page_test.dart test/features/settings/thread_font_reading_scope_test.dart test/features/users/me_page_test.dart --update-goldens --concurrency 2`：状态／存储 8 项、阅读范围 3 项、个人区 51 项通过；字号页首轮 8 项通过、2 项失败，发现端点命中区问题。
- 修正端点命中区后，`flutter test --no-pub test/features/settings/thread_font_settings_page_test.dart --update-goldens --concurrency 2`：10 项全部通过。覆盖七档数值、默认居中、左右等距、逐刻度实际点击、拖动／保存／重试、读屏和系统大字。此前通过且未受此次轨道命中修订影响的 62 项不机械重跑。
- 明暗 320dp／600dp 字号页 Golden 与个人设置入口数字值基准已更新；已查看窄屏明暗及 600dp 浅色画面，数字与刻度对齐，默认居中，无溢出。
- 修改的 Dart 文件格式检查、`git diff --check` 和 `dart run tool/check_docs.dart` 通过。

日志原位于工作树 `build/thread-font-ticks-tests.log`、`build/thread-font-ticks-ui.log`、`build/thread-font-ticks-analyze.log` 和 `build/thread-font-ticks-apk.log`。合并清理前，四份日志及候选 APK 已归档到 `D:\code\wenyousite\recovery\thread-font-ticks-20261015-1b300347`，逐文件 SHA-256 与原件一致；`manifest.json` 记录原路径、归档路径、大小及摘要。

## Debug 安装

- `flutter build apk --debug --target-platform android-arm64 --no-pub`：通过，Gradle 225.3 秒；没有修改构建号。现有 Kotlin 插件兼容提醒未导致构建失败，不在本次调整范围。
- 版本 `0.9.0-debug`，versionCode `99`，applicationId `site.wenyou.app.debug`，仅 `arm64-v8a`。
- APK：`D:\codex-worktrees\mobile-thread-font-ticks\wenyousite-mobile\build\candidates\wenyou-thread-font-ticks-debug-99.apk`，`110316778` 字节。
- SHA-256：`5973f3a77743143d2a01dda6061b5d9ce408581969b6a2b2e8266a0dfb20fa8f`。
- 设备最初未连接，负责人随后连接 `4b9c39b5`（2509FPN0BC，ARM64）。安装前前台包为 `site.wenyou.app.debug`，核对与候选一致；没有活动 Flutter run 会话。
- `adb -s 4b9c39b5 install -r`：`Success`，未卸载、未清数据。安装后 `lastUpdateTime=2026-10-15 01:30:48`，设备 `base.apk` SHA-256 与候选完整一致。
- 无本任务可复用的 Flutter 会话，采用独立 APK 覆盖；未由代理启动应用、恢复登录或触发线上业务。API 仍为默认 `https://wenyou.site/api/v1`，由负责人手动打开“温油站 Debug”验收。
- 功能提交 `1b300347cf48c234c6c7b94bf1a2be7eec4908eb` 包含上述 APK 的全部应用源码；构建后仅补齐文档，没有修改应用源码。

## 真机验收步骤

1. 打开“温油站 Debug”，进入“我的 → 账号设置 → 偏好与提醒 → 主题帖字号”；游客由“我的 → 偏好”进入。
2. 恢复默认，确认数字 16 居中，左侧 13／14／15、右侧 17／18／19 等距。
3. 逐格滑动并返回主题，确认每次字号变化 1sp，预览、正文、楼层和回复一致，返回设置保留选择。
4. 检查原来选择 14／16／18 的用户保持字号，原 20／22 进入后为 19；恢复默认、重开应用和读屏增减正常。

## 负责人验收结果

2026-10-15，负责人在上述候选安装后回复“可以合并清理分支了”，确认本轮验收通过并授权合并、清理分支与临时工作树。此结果对应功能提交 `1b300347cf48c234c6c7b94bf1a2be7eec4908eb` 及上述 APK；负责人未另行提供逐项手测结果。

验收后仅更新文档，应用源码未变；沿用本轮不运行完整门禁的明确要求，不将此前未执行的完整门禁记为通过。

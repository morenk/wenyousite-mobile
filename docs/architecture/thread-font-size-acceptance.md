# 主题帖字号验收记录

状态：2026-10-15 负责人验收通过，已授权合并与清理任务分支。

## 目标与范围

按负责人要求，在个人偏好中增加主题帖内字号调整，并将默认正文由 17sp 调小一号至 16sp。采用五档滑杆（14／16／18／20／22sp）、即时预览、松手保存与恢复默认。设置行显示当前档位。沿用 Foundation body 字号、颜色、间距、设置组件与原 Markdown 排版；不新增全局字体规范。

影响子贴正文、主楼层、内嵌与独立楼中楼回复，以及身份卡引用的同一楼层原文。主题标题、作者信息、时间、工具栏、动态、私聊与编辑器不变；系统缩放继续应用。持久化仅保存设备字号枚举，不修改 API、正文或草稿。

## 基线与环境

- Windows：`D:\code\wenyousite\wenyousite-mobile`。
- 任务分支：`codex/20261014-thread-font-size`；基线 `60362e78b7c4f8c8362e5f3378c4cdcaba3dbeff`。
- Foundation 执行 `git fetch origin --tags`，最新正式 Tag `v7.2.1` 与 pubspec 固定版本一致；已阅读 CHANGELOG、Flutter 字号及无障碍契约。
- Backend 记录来源、只读镜像 `origin/dev` 与公网 `/meta` 均为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`、API `5.36.0-dev.20261005.1`，无契约差异。
- 起初 ADB 无设备；2026-10-15 负责人要求停止完整门禁、直接交付 Debug 安装后，识别设备 `4b9c39b5`（2509FPN0BC，ARM64），当前前台包为 `site.wenyou.app.debug`。没有本任务可复用的 Flutter 会话，采用独立 Debug 构建与覆盖安装。离线 Widget／Golden 不能代替真机验收。

## 验证记录

本轮新增测试覆盖偏好加载、缺省／坏值回退、恢复默认、保存失败回滚与重试、重复操作及销毁后完成、存储实例恢复、滑杆实时预览／松手保存／读屏增减、退出设置再进入、窄屏与大字体，以及真实主题详情和独立讨论的字号作用范围。

已实际执行：

- `flutter test --no-pub test/core/application/thread_font_preference_test.dart test/core/storage/shared_preferences_thread_font_store_test.dart test/features/settings/thread_font_settings_page_test.dart test/features/settings/thread_font_reading_scope_test.dart --concurrency 2`：19 项通过。覆盖状态、存储、预览和真实阅读范围。
- `flutter test --no-pub test/features/threads/thread_detail_page_test.dart test/features/posts/post_replies_page_test.dart test/features/posts/post_identity_profile_preview_test.dart test/features/posts/post_reading_quick_scroll_test.dart test/features/threads/thread_identity_card_content_test.dart test/features/users/me_page_test.dart --update-goldens --concurrency 2`：202 项通过，仅更新设置入口及正文 17 → 16sp 影响的基准。
- 固定预览高度以保持拖动滑杆位置稳定后，最终 `flutter test --no-pub test/features/settings/thread_font_settings_page_test.dart`：9 项通过，含真实拖动、位置不变、保存回滚、读屏、明暗 Golden 与 320dp 系统两倍字号。
- `dart run tool/check_architecture.dart`：通过。初次全量静态分析的 6 条 import 排序／新语法／弃用成员提示已调整；本轮未宣称最终全量静态分析通过。
- 完整入口 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure` 的首次生成阶段停滞，保留旧 `.dart_tool/build` 缓存后重启。2026-10-15 负责人明确要求“不需要完整门禁”，遂停止整个门禁，仅保留构建与安装；不宣称完整门禁通过。重新生成未留下生成客户端差异。
- 最终构建使用 `flutter build apk --debug --target-platform android-arm64`，不增加或修改构建号，不卸载旧 Debug 应用、不清数据。

本地日志：`build/thread-font-final-focused.log`、`build/thread-font-related.log`、`build/thread-font-ui-verified-after-stop.log`、`build/thread-font-debug-apk.log`。首次被停止的门禁日志为 `build/thread-font-full-gate.log` 与 `build/thread-font-full-gate-retry.log`。

## APK 与安装证据

- 2026-10-15 独立 Debug 构建退出 0；版本 `0.9.0-debug`，versionCode `99`，applicationId `site.wenyou.app.debug`，仅 `arm64-v8a`。
- 候选路径：`D:\code\wenyousite\wenyousite-mobile\build\candidates\wenyou-thread-font-debug-99.apk`；大小 `110312510` 字节。
- APK SHA-256：`1abf89ab9c00bfa40a7eb50f25e72c64753f1581319868053623e31fc50e106a`。
- 安装前设备前台即为 `site.wenyou.app.debug`；通过 `adb -s 4b9c39b5 install -r` 覆盖安装返回 `Success`，未卸载、未清数据。
- 安装后该包 `lastUpdateTime=2026-10-15 00:14:29`；设备内 `base.apk` 的 SHA-256 与候选完整一致。应用名称“温油站 Debug”。
- 本次没有热重载会话，采用新包覆盖安装；未由代理启动应用、恢复登录或触发线上业务。API 沿用默认 `https://wenyou.site/api/v1`，由负责人手动打开验证。
- 功能提交 `10fe127cdbb4a03c23fee83d41921013ff4aefdd` 包含本次 APK 的全部应用源码；构建后的变动仅为验收文档。现有 Kotlin 插件迁移／SDK XML 警告不在本轮改动范围。

## 负责人真机步骤

1. 打开候选 Debug 应用 `site.wenyou.app.debug`，首次阅读主题正文、楼层及回复，确认默认比原来小一号。
2. 在“我的 → 账号设置 → 偏好与提醒 → 主题帖字号”拖动五档，确认预览即时变化，松手后返回主题，正文、楼层、内嵌与独立楼中楼一致。
3. 检查主题标题、作者、时间、列表、动态、私聊及编辑器字号保持原样。检查带标题、引用、列表、链接、提及和骰子的正文排版与操作。
4. 退出设置再进入、关闭应用后重开、退出账号或切号，确认所选档位保留；游客可在“我的 → 偏好”进入同一设置。
5. 点击恢复默认，确认恢复 16sp；检查明暗模式、窄屏、系统大字体和 TalkBack 逐档增减，滑杆与恢复默认可达。

## 负责人验收结果

2026-10-15，负责人在安装上述 Debug 候选后回复“可以了，合并清理分支吧”，确认本功能验收通过并授权合并与分支清理。该确认对应功能提交 `10fe127cdbb4a03c23fee83d41921013ff4aefdd` 及上述 APK；未另行提供逐项手测结果。

沿用负责人本轮“不需要完整门禁”的明确要求，合并前只补充本验收记录及模块状态，不重跑完整门禁，不将已停止的门禁记为通过。验收后未修改应用源码，已安装 APK 与原测试证据继续对应同一实现。

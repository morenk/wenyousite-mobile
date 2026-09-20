# 设计统一后三批候选验收

日期：2026-09-20。状态：后三批候选已通过完整门禁与 Debug APK 构建，待负责人真机验收。

## 授权、基线与交付边界

负责人要求将[六类统一计划](design-unification-plan.md)剩余三个批次一同完成。本任务包含页面容器与错误重试、普通底部抽屉、内容时间呈现全部既定范围，不把第一批 PR #48 或副标题清理 PR #47 自动视为已验收。

分支 `codex/20260920-design-unification` 从最新 `origin/dev` 建立并 fast-forward 承接已提交的第一批。开始时重新 fetch Foundation tags，最新正式版已变为 `v7.1.0`，先以独立提交 `b0d645f6` 升级 Tag、锁文件及普通内容日期语义。已读取 CHANGELOG、格式契约、Flutter profile 与 mobile 呈现说明。后端已记录 revision、远端 `dev` 和公网 `/meta` 仍为 `4b133355c14198506e4a4380fd741cccd19d844d`，本次不修改 HTTP 契约或生成客户端。

## 要求与实现证据

| 类别 | 代码入口 | 可验证结果 |
| --- | --- | --- |
| 页面容器 | `wenyou_settings_body.dart`；外观、诊断、账号设置 | 同一响应式横向边距、Foundation 最大内容宽度、滚动、安全区和底部留白；不改个人主页联动滚动 |
| 错误与重试 | `WenyouSettingsFailure`；外观、省流量、后台提醒 | 统一错误横幅和重试动作；保存中禁用；省流量保留当前选择，后台提醒回滚并记住失败目标；读取重试只读；权限申请独立 |
| 抽屉 | `wenyou_sheet.dart`；正文草稿、云端主题草稿、订阅、主题设置选择 | 同一安全区、键盘避让、宽度与关闭入口；短内容收缩，长内容最多占可用高度九成；标题和操作可随内容滚动，列表保持 Sliver 构建 |
| 内容时间 | `wenyou_time_text.dart`、`wenyou_time_clock.dart`；用户最近回复、正文/主题草稿、楼层/回复及既有消费者 | 统一本地时间、72 小时边界、同年/跨年日期、完整日期读屏；保留子贴/楼层/回复对象上下文；共用前台分钟刷新源，恢复前台立即刷新 |

各模块业务状态不因抽屉统一而合并。关闭、系统返回和取消本身不创建写请求；已经由用户启用的正文自动保存继续遵循原编辑器会话规则。上传/正文编辑仍使用 `showWenyouComposerSheet`，其拖动、确认离开和键盘生命周期有独立需求，不机械替换。

## 精确时间例外清单

这些是 Foundation v7.1.0 的语义例外，不是独立格式规范：

- `login_sessions_page.dart`：登录、活动等安全时间，完整年月日及时分。
- `moderation_appeal_page.dart`：治理决定与申诉凭据到期，完整年月日及时分；到期提示补足日期。
- `wallet_page.dart`：账务流水，完整年月日及时分。
- `diagnostic_settings_page.dart`：诊断记录保留完整本地时间及既有秒/小数秒精度。
- 个人/公开资料加入日期、邀请页主题创建日期是日期型元信息，使用 `formatWenyouDate` 转本地日期。

普通内容不再在页面内使用 `DateFormat`。原始 API 时间戳、排序、过滤、凭据到期判断与存储值均未截断或迁移。

## 自动验证范围

本次包含依赖升级与共享时间刷新，并补充后台提醒的失败目标重试，最终候选按高风险流程运行 `npm run check:apk -- -TestConcurrency 2`。以下为直接相关测试入口；完整门禁还会执行全仓测试、静态分析、架构、文档、API 覆盖、契约生成一致性和 Windows 工具测试。

```text
test/core/widgets/wenyou_settings_body_test.dart
test/core/widgets/wenyou_sheet_test.dart
test/core/widgets/wenyou_time_text_test.dart
test/core/widgets/wenyou_time_clock_test.dart
test/core/widgets/wenyou_identity_formatting_test.dart
test/core/formatters/relative_time_test.dart
test/features/settings/
test/features/users/background_reminder_settings_panel_test.dart
test/features/users/me_page_test.dart
test/features/users/public_user_content_sliver_test.dart
test/features/users/public_user_page_test.dart
test/features/drafts/content_drafts_sheet_test.dart
test/features/editor/remote_thread_drafts_sheet_test.dart
test/features/social/thread_subscription_controls_test.dart
test/features/threads/thread_management_page_test.dart
test/features/posts/post_replies_page_test.dart
test/features/posts/post_reading_quick_scroll_test.dart
test/features/threads/thread_detail_page_test.dart
test/features/threads/thread_reading_quick_scroll_test.dart
test/features/direct_messages/direct_conversation_page_test.dart
test/features/social/bookmark_list_page_test.dart
test/features/moderation/
test/features/wallet/
test/tool/foundation_brand_assets_test.dart
```

自动测试覆盖 320/360/600dp、两倍字号、安全区、键盘、短内容收缩、长列表最后一项选择、关闭/系统返回空结果、只读/禁用、读取与保存重试、回滚与失败目标、日期阈值、跨年、本地时区、读屏上下文以及共享刷新源的前后台生命周期。1200dp 额外验证内容最大宽度。

开发反馈全仓测试发现 25 项旧日期 Golden、不再存在的正文草稿重复说明断言、品牌清单旧版本断言以及 1 项真实 GIF 解码时序失败。日期差异逐张核对后更新，包括收藏页管理面板后的日期背景；两倍字号窄屏下日期缩短后作者名获得更多空间。文案/版本断言已同步，未修改图片、网络或收藏业务逻辑。全部反馈原始日志保留在候选制品目录，最终结果以随后完整门禁为准。

## 完整门禁与候选制品

- `npm run check:apk -- -TestConcurrency 2` 退出码 0：4,669 项 Flutter 测试通过，18 项 Windows 工具测试通过；1 项显式 Sentry 实际收件测试未启用。应用与生成客户端全量分析零问题，格式、架构、21 个模块文档、API 覆盖、契约/公网兼容性和客户端重新生成一致性全部通过。
- 上述 GIF 测试原文件与品牌资源测试单独复测 14 项通过，随后完整门禁也全部通过，未修改动画实现或降低断言。正文草稿编辑器入口、私信、收藏和主题日期基线均在最终全仓运行中通过。
- 41 张既有 Golden 更新，另新增诊断页浅色/黑夜 2 张：其中 37 张由日期规则引起（含收藏管理面板的页面背景），4 张覆盖页面容器/抽屉；均已视觉复查并通过最终基线比较。
- APK：`D:/code/wenyousite/artifacts/design-unification-20260920/wenyou-debug-95.apk`，大小 `223465311` 字节。包名 `site.wenyou.app.debug`，应用名“温油站 Debug”，版本 `0.7.1-debug`，构建号 `95`，Debug 保留 ARM64、ARM32 和 x86_64。
- SHA-256：`fe7c5fb999d71a27cb278e32042076019e8c0675baed9fb8e0cef679bef9fbdd`。与此前候选构建号相同，必须用包名和摘要区分实际安装内容。
- 同目录 `check-apk.log`、`check-apk.exit.txt` 保留完整门禁结果，`development-full-tests.log` 保留开发反馈；各类定向复测日志与 `previews/` 保留视觉证据，`candidate.json` 绑定最终提交与 PR。
- 仅出现既有 KGP 插件迁移提示；未改变 Android 原生配置。完整门禁后只补充本记录等文档，应用源码与 APK 保持绑定。

## 负责人手测

1. 账号设置、外观、诊断分别检查浅色/黑夜与系统大字号，左右边距一致，所有末尾操作可滚到；个人主页页签联动保持。
2. 切换外观、省流量、后台提醒；可控的读取/保存失败场景下检查错误横幅、重试、回滚和按钮禁用；点击说明或申请权限不得意外切换设置。
3. 从实际编辑器打开正文草稿和云端主题草稿，键盘打开/关闭均可操作。验证查看、取消、系统返回不改正文；恢复/覆盖/删除仍需原确认，自动保存开启后关闭抽屉继续生效。
4. 检查少量和长列表的订阅抽屉，关闭不改订阅，明确切换后生效；切号后旧抽屉关闭。主题分区、招募、可见范围、发言权限的选择及取消保持原规则。
5. 最近回复、草稿、主题/动态/通知/私信时间符合相对时间和日期规则；切换本地时区、跨日期和恢复前台后检查。TalkBack 读出完整日期和内容上下文；登录、治理、账务、诊断记录保留精确时间。

本任务未操作真机，没有将 Widget、Golden、完整门禁或 APK 构建当作负责人验收。未合并、正式签名或发布。

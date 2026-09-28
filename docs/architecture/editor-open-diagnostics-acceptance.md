# 编辑器打开拦截漏报候选验收

状态：候选／待负责人验收。当前切片补充诊断，不宣称控制标记外露和尖括号误判已经修复。

## 原始问题与证据

- 负责人提供楼层 `cmulh9bx501937qm7tan1vyxs`、编辑回复截图及 Sentry 149987792。截图提示“当前格式组合暂时不能安全保存。／这段内容暂不支持编辑，原文已保留。”。
- 2026-09-29 只读读取该楼层 API，正文 version=1，创建与更新时间均为 `2026-09-28T16:44:18.713Z`。完整原文在 Windows 临时目录用于本地复现，不加入产品诊断、产品日志或仓库。
- 实际源码第 87、88 行如下；行间 LF、反斜杠、空格保持原样：

```markdown
[wenyousite-align-v1-center]: #
*<\<Y/N \>\>*
```

- 独立 Markdown 阅读解析得到斜体 `<<Y/N >>`，不是 HTML。现行 `MarkdownContent` 与 `MarkdownAlignmentContract` 的 `<[^>]*>` 判断把这一行当作不支持 HTML，使前一行居中标记失效。
- 用完整原文在与 `v0.8.0` 相同的编辑器实现中复现：仅上述两行被标记不支持；其他 8 个居中块有效；编辑会话只读，显示 1 个控制标记与转义原文，原始 Markdown 保留。仅在内存给第一个 `<` 补反斜杠后，整篇不再被拦截且可以编码。该对照是定位证据，未修改线上内容。
- 149987792 即 `WENYOUSITE-MOBILE-1K`，是 0.8.0+97 在 `2026-09-28T17:16:11.135Z` 的 `_ClientSocketException`，OS 错误码 110；无楼层 ID、无编码诊断，不能与本次格式拦截等同。
- 已证实漏报路径：`RichEditorSession._protectUnsupportedSource` 只设置只读和提示，`flush` 又直接返回，因此不会到达原有编码异常采集。

## 目标、范围与风险

补齐打开／恢复已有正文的兼容性拦截上报，沿用问题详情复制、发送开关、脱敏边界、保留期限和账号清理规则。固定区分不支持格式、缺失能力、未知 profile 和不满足无损要求；不采集正文、Delta、楼层／账号 ID，不用当前调用栈冒充异常栈。去重限当前编辑会话最近一次被拦截的正文与原因，不全局压制新发生的问题。

本次不修改 Markdown 解析、持久化格式、后端或 Foundation 契约，不替负责人修改原楼层。由于新增诊断操作类型进入本地记录和 Sentry 映射，采用完整门禁及 Debug 构建验证。负责人原场景、真机和真实 Sentry 收件保持独立验收。

## 契约与基线

- 基于 `origin/dev` `f551d3eb`，任务分支 `codex/20260929-editor-guard-diagnostics`。
- 本地、`origin/dev` 与公网 `/meta` 的 Backend revision 均为 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`，契约 `5.27.0-dev.20260927.1`，公网 Markdown v5；未出现需要同步的契约 revision 变化。
- 未涉及 Foundation 视觉实现或依赖升级。

## 自动验证

- 旧实现精确回归：`test/features/editor/editor_open_diagnostics_test.dart` 的“原楼层打开即拦截时上报”失败，实际 `diagnosticId=null`。本机证据 `%TEMP%/editor-open-before.log`。
- 候选定向回归：`flutter test --no-pub --reporter expanded test/features/editor/editor_open_diagnostics_test.dart test/features/posts/post_composer_open_diagnostics_test.dart test/core/diagnostics --concurrency=2`，37 项通过，1 项已有的真实 Sentry 收件测试按默认显式开关跳过。证据 `%TEMP%/editor-open-targeted-final.log`。覆盖真实楼层编辑入口复制、关闭保留原文、上报映射、重复加载去重、正文替换、正常／业务只读不误报、发送关闭与隐私白名单。最初 Widget 测试在清理阶段等待 fake async 任务而挂起，移除无资源测试对象的不必要异步等待后完整重跑通过；未修改产品逻辑来规避失败。
- 完整门禁 `npm run check:apk -- -TestConcurrency 2` 退出 0：格式、应用与生成客户端静态分析、架构、模块文档、API 覆盖、契约来源与重新生成一致性、公网只读兼容验证全部通过；Flutter 5,007 项通过，1 项既有真实 Sentry 收件测试跳过；Windows 工具 67 项通过；同一次门禁随后完成 ARM64 Debug 构建。
- 本地证据保留在任务工作区 `build/editor-open-diagnostics/before.log`、`targeted.log`、`check-apk.log`。应用源码检查完成后仅补充验收记录，不重跑同一应用源码的完整门禁。

## 候选安装包

- 绝对路径：`D:\codex-worktrees\editor-guard-diagnostics\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- `applicationId=site.wenyou.app.debug`，`versionName=0.8.0-debug`，`versionCode=97`，最低 API 26，仅 `arm64-v8a`；`aapt dump badging` 已核对，`apksigner verify` 退出 0。
- 大小：109,439,806 字节；SHA-256：`4e03573b3870c5d3eeb124f128b54d7bd45dffd4496b47f388526eb1f6973cd1`。
- 本次没有 ADB 安装、设备内 APK 哈希或持续 Debug 会话证据。该标准 Debug 构建未注入私有 DSN 或启用远程上报，只能验收本地诊断行为；不以本包或模拟发送测试宣称真实 Sentry 已收件。
- 构建保留现有 `flutter_image_compress_common` KGP 与 SDK XML 版本警告，但最终成功；本切片未升级依赖或改动原生工具链。

## 真机验收与未验证项

2026-09-29 ADB 无连接设备，既有调试会话均已停止，无可复用的活动会话。未安装或启动真机候选，未取得负责人验收。隔离开发预览本身禁用 Sentry，不能以预览的本地记录宣称线上收件通过。

1. 使用对应候选在只读访问原楼层的场景进入编辑，确认只读保护及原文保留，出现“复制问题详情”；不提交或改写线上帖子。
2. 复制详情，确认 `operation=editorOpen`、`stage=decode`、`diagnosticCode=markdown.open_unsupported_markdown`，没有正文、Delta、内容 ID 或账号信息。
3. 使用启用 Sentry 的验收构建，在负责人允许的环境核对同一问题编号的事件；关闭自动发送后只保留本地记录。
4. 重复加载同一份内容不增加重复记录；正常正文没有误报。关闭只读编辑器不保存安全字面化结果、不覆盖原文。

自动测试和候选构建不能代替上述验收；原控制标记问题继续待修复。

# Android 更新说明候选验收

状态：候选验证中／待负责人验收。组件与自动测试不替代真机、真实 API 或正式发布验收。

## 范围与事实源

- 在独立 Windows Worktree `D:\codex-worktrees\a384\wenyousite-mobile`、分支 `codex/20260927-mobile-release-notes` 开发；初始基线 `8be9ffb105e1ba2cc157084e6e7d1f058ced70d0`。
- 开始前 fetch Mobile 与 Foundation；最新正式 Foundation 为 `v7.2.1`，与 `pubspec.yaml`、锁文件一致，无依赖升级。展示补充文档以 Foundation 已提交 `d9001265030a52d5255c7cd52dc841833cc7afbb` 为参考，不消费未发布 Token。
- 初始契约记录与公网只读 `/meta` 均为 Backend `124fb4e8aa395440f7a2156de98b642ec87f7583`、HTTP 契约 `5.26.0-dev.20260922.3`。新 API 首次固定 `99b42dc0f7d25eeb6e49ee87441e206c77cce29a`，完整门禁使用连同受限发布 CLI 运维文档固定的 `72d3658d32a089fcfabdea30225d87b960033c5b`、契约 `5.27.0-dev.20260927.1`；门禁结束后按治理最终交接同步 `9e25b4562dfd9229b0d306b5374c018c3e43f65c`。此次仅来源 revision 改变，OpenAPI、生成 SDK 与应用源码不变。
- 不合并、不打正式 Tag、不发布、不上传正式包、不读取发布秘密、不占用其他任务的设备会话。

## 行为与风险

说明读取独立于启动与 APK 预检；仅精确匹配平台、版本名、构建号的目标显示说明。推荐横幅先查看完整内容，强制更新页直接阅读；游客与设置均可查看历史。下载前再读取有效策略，历史不能降级、任意 URL 安装或绕过强制门禁。iOS 原 TestFlight 保留。

本切片涉及契约、网络及发布工具，为高风险候选；最终必须执行统一 `npm run check:apk`。候选后端未部署导致公网来源检查失败时，使用既有 `-ContinueAfterFailure` 收集其余证据，明确报告非零结果，不放宽门禁。

## 开发检查与画面

定向测试位于 `test/features/app_shell/mobile_release_controller_test.dart`、`mobile_release_repository_test.dart`、`mobile_release_widgets_test.dart`、`mobile_update_controller_test.dart`、`mobile_update_service_test.dart` 及 `test/app_shell_test.dart`。覆盖精确身份、空态、失败重试、分页与游标失效、刷新保留、迟到结果、推荐／强制／忽略后的入口、下载目标复核与原安装链路。

`test/features/app_shell/goldens/mobile_release_light_360.png` 和 `mobile_release_dark_360.png` 是 360×800 的组件候选，示例文案仅供布局检查；两倍文字及长说明通过滚动可达性测试。另保留 HTML／Markdown 字面量的纯文本断言。后续已连接唯一 ARM64 设备 `4b9c39b5`（2509FPN0BC）。受控 Debug 启动、实际源码与画面证据将在本记录补充；在记录完成前不把 Golden 冒称真机或端到端完成。

## 本地门禁记录

最终应用源码运行 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，完整日志为 `build-release-full-gate.log`。严格聚合第一次发现两个问题：公网 `/meta` 尚未部署候选契约；新 Golden 已加载固定字体，但初始化写法不符合架构门禁要求。后者仅调整测试为标准 `setUpAll(loadDeterministicTestFonts)` 并另行预热 Android 主题，架构复验通过（`build-release-architecture-final.log`），补充全量静态分析也通过（`build-release-analyze-after-test-setup.log`）。未修改应用源码或放宽门禁，不机械重跑整轮。最终严格聚合退出码为 1，保留上述两项原始失败。其余步骤通过：OpenAPI 校验与生成一致性、固定契约、格式、应用／SDK 分析、21 个模块文档、API 覆盖、全量 Flutter `4959 passed / 1 skipped`（原有显式 Sentry live receipt 验收）、Windows 发布及 Debug 工具 `52/52`、ARM64 Debug APK 构建。最终9e25来源同步后另行执行契约来源与模块文档定向检查，并用 Git diff 与源码摘要确认消费者字节未变，不重复整轮。

本轮已检查的应用实现提交为 `e425c0785a3419d396c41d3b54ed5e8c574ef4ff`，`sourceDigest=f623265b0815ff4e6cb0843b99f55a3a16c7fb338fb4e4e7f478c17c1489aa35`。普通门禁 APK 保存于 `build/mobile-release-evidence/gate-app-debug.apk`，仅构建未安装，包名 `site.wenyou.app.debug`、显示名“温油站 Debug”、`0.8.0-dev.2-debug+97`、仅 `arm64-v8a`、109419506 字节；SHA-256 `1df0bb7a4726faf91512afd40e40cbeb7e8260398e3ccf7052ba2874ca7b4739`。后续真机使用带隔离预览配置的 Debug 会话，其安装摘要另记，不能混用。

## 合成隔离预览与发布工具

共享预览 `preview_705231a26b764b7cd53eed8e` 由治理持有隧道，Mobile 只借用。已使用本仓库 `verifyIdentity` 核验 Backend／媒体身份；生成 Dart SDK 真实只读访问列表、build 100 详情和缺失 build，分别验证公开快照一致及 HTTP 404／业务 40400。合成样本为 `0.0.0-preview.100+100`、revision 1；预览 Backend SHA 为 `77eb8324188cc0443407f13c27bc6bf355d7708a`（后续72d3658仅文档／fixture），证据 `build-release-preview-smoke.log`。

预览 `/meta` 的 Android minimum／recommended／updateUrl 均为空；真机可验证历史及详情，不代表推荐／强制／真实下载安装链路已验收。不构造安装对象，不放宽 APK 校验，不把公网作为回退。

`tool/windows/release_notes.test.mjs` 执行真实 Shell 参数解析及编排，以临时假的 SSH、npm、Flutter 与上传器覆盖：未确认／缺失／身份错误在构建前停止、skip-checks 不绕过、BuildOnly／UploadOnly 不晋级、上传后 revision 变化停止、成功传递原 revision、晋级失败非零且不自动恢复。既有上传身份、签名与摘要校验继续由 Windows 工具测试覆盖。本轮未正式签名、真实上传或晋级。JSON 构建摘要保存 `notesConfirmedRevision`；无预检的分段构建为 null。

## 负责人真机清单

1. 推荐版本横幅能看到版本与摘要，点“查看更新”能完整阅读，返回保持原页面；忽略后从游客“我的”或设置仍能进入历史。
2. 当前安装版准确标记；旧版没有说明显示空态，其他历史没有下载或降级入口。
3. 强制更新页长文可滚动，断网只使说明失败且可重试，不解除门禁；原下载进度、权限设置、安装器与失败重试保持可用。
4. 明暗主题、360 宽及系统大字体下，返回、完整文案和安装动作可达。安装后不自动弹窗。
5. 发布工具的真实预检与晋级由负责人另行授权；本次仅 fixture 测试，不能声称正式发布链路已运行。

## 审批核验

默认 Auto-review 偏好已传递；当前会话实际下发 `approval_policy=never`、`danger-full-access`，不是 `on-request + auto_review`。现有宿主工具没有修改当前会话的受支持入口，未修改全局设置或宣称自动审批已生效。此限制已交接治理。

# 应用内复制链接不反向提示：候选验收记录

状态：负责人已批准交付、合并与清理；本地检查及失败项补验完成，生产精确版本校验差异待负责人决定。更新日期：2026-10-05。

## 2026-10-05 合并准备

负责人在收到组合 Debug 候选后明确回复「可以合并清理分支了」，本轮据此准备 PR #78、#79、#81 的合并与任务清理。此处记录交付及合并批准，未提供额外的真机操作、设备或安装信息，不把批准补写成具体设备测试经过；iOS 仍未编译或设备验收。此前超链接与排版两项已明确真机通过，其证据仍由各自验收文档保存。

整合起点为 `origin/dev` 的 `6b72b332`，按 #78 → #79 → #81 堆叠，保留最新下载、讨论定位与私密邀请复用基线。邀请现在先等待设置保存并复核权限，每次 PUT 取得当前链接，然后调用共享复制端口；不恢复旧生成／重置面板。新增回归验证连续两次取得的当前邀请均进入共享端口，并保留上游的复制失败手动链接与账号、权限、页面边界测试。

### 最终集成检查

验证源码为组合提交 `1d2a731c26816db86f73698fce6f903ac29ed46d`，完整 tree `af1b5545c1d93e217e32d2d7489d40e278cde6c4`，与业务 PR #81 的 `c9f4909a` 完整树相同。北京时间 2026-10-05 06:06:59 至 06:46:56 执行一次 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`；命令总退出 **1**，不报告完整门禁通过。后续只追加本文等证据，不改变应用、原生或测试源码。

- OpenAPI、固定契约摘要、1171 文件格式、应用／生成客户端分析、架构、21 模块文档与 API 覆盖通过；Windows 发布／调试工具 **87/87** 通过。
- 全量 Flutter 原始结果 **5230 通过、1 跳过、1 失败**。失败为 `moment_animation_test.dart` 最后一例清理临时目录时 Windows `errno32` 占用，业务断言未失败；该测试、夹具与相关业务源码和 `origin/dev` 一致。门禁结束后串行重跑完整文件 **8/8 通过**（29 秒），未改断言或跳过；原遗留目录按精确登记清理成功。
- 跳过项是 `diagnostic_live_receipt_test.dart` 的「显式验收：Sentry 接收一条脱敏诊断」，沿用基线 `WENYOU_VALIDATE_SENTRY` 开关，本轮未开启外部 Sentry 真实发送。
- API `build_runner` 进程在原门禁中无 CPU／IO 进展而被定点终止，原阶段退出 -1。保留诊断并移走本 Worktree 的生成缓存后，独立 `npm run api:check` 补验退出 **0**，重新生成内容与提交完全一致；缓存处理是恢复措施，不断言为挂起根因。
- 仍失败的生产精确版本门禁：本地固定 API `5.32.0-dev.20261003.1` / Backend `3748cc8c85a73f400fa4e237a8d7dd6eecd1853e`，线上为 `5.33.0-dev.20261005.1` / `ff1a84178b37fabd7f8fd77e53989b4842b4d42f`。本轮与 `origin/dev` 的契约和校验工具相同，基线同样失败；未放宽校验、同步其他任务 RP 业务或伪报通过，等待负责人对这一具体版本匹配差异决定。
- Android Debug 构建成功（58.6 秒），包名 `site.wenyou.app.debug`，`0.8.0-debug / 97`，仅 `arm64-v8a`，v2 签名校验通过。APK `D:/codex-artifacts/editor-merge-20261005/wenyou-editor-integration-1d2a731c-debug.apk`，150339908 字节，SHA-256 `D6D1B3C1E4A26C8CBD1D9F1A901BBCF432CC90DAFB0A570FF445D2505DACEED1`；未安装、发布或部署，iOS 未编译或设备验收。

完整原始日志 `D:/codex-artifacts/editor-merge-20261005/mobile-check-apk.log`、`gate-result.json`、API 补验 `api-generation-recovery.log`、动画补验 `moment-animation-recheck.log` 及 APK／清理收据保留。此前因先核对生产漂移而在契约初期停止的入口保留为 `mobile-check-apk-interrupted.log`，当时未运行全量 Flutter 测试，不作为通过证据。最终复核 `origin/dev` 仍为 `6b72b332`；三 PR 保持 Draft，未合并、未清理其分支或 Worktree。

以下为 2026-10-01 候选历史证据，保留当时未完成项，不代表当前最终集成结果。

## 原问题与证据

负责人操作：在应用内复制楼层链接，切出应用准备分享，再返回。实际出现「是否前往」提示；期望本次自己复制的链接不反向提示，外部重新复制仍提示。

已证实的代码原因：旧提示组件在 `inactive` 时才尝试读取新剪贴板；初始 `_activeEntryToken` 为空会直接跳过，且失去焦点时原生读取可能不可用。显式链接复制入口未立即登记事件。

红绿回归：新测试使用真实共享链接复制按钮，分别写主题、子贴、楼层、回复、邀请的合法 URL，从空剪贴板开始，复制后立即失焦并禁用读取，再恢复。只将提示组件还原为 `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3` 的旧实现，其余测试装配保持候选连接，五项全部因出现导航弹窗失败；恢复候选后通过。该结果验证旧提示逻辑不消费复制收据，属于 Widget/平台端口模拟，不能替代 Android 原始场景真机验收。日志保存在任务 Worktree 的 `build/clipboard-origin-validation/old-prompt-red.log`。

## 实现与边界

- `core` 只提供显式链接复制端口，组合根连接应用壳协调器。主题／子贴 BODY、楼层、讨论主楼层、回复和邀请复制均接入；普通正文、选中文字、富文本剪贴板协议保持。最终集成的邀请入口遵循上方复用规则，旧生成面板仅属于最初候选基线。
- Android 与 iOS 的 `clipboard_navigation.writeText` 在一次原生调用中写入原文并返回事件。Android token 绑定系统 timestamp，本应用附规范 UUID marker 以证明回读归属；外部非法或过长 marker 按普通 timestamp 处理。iOS 使用 changeCount。
- Android 写入成功但瞬时无法回读版本时，返回 `android:own:<UUID>` 收据；首次快照的规范 marker 与文本 SHA-256 均匹配时，立即升级为带 timestamp 的完整事件，之后即使外部保留 marker、再次复制得到新 timestamp 也正常提示。
- 系统信息的极限：在上述首次回读完成前，外部应用若整份克隆原 `ClipData` 并保留随机 extras，无法绝对区分该克隆与自己刚写入的事件；普通外部重新复制文本不携带该 marker，仍正常提示。不永久按 URL 或 marker 屏蔽。
- 去重沿用 `clipboard_navigation.handled.v1`，只存事件与 SHA-256，不存 URL、邀请 token、坐标、账号或正文。复制失败不登记；落盘失败保留本进程收据，不把成功复制误报失败，也不宣称跨重启可靠保存。
- 同一协调器承接复制与弹窗决定；内存即时更新、落盘串行，旧存储读取、在途快照和旧弹窗决定均不能覆盖新复制。后台不启动扫描，不再在 inactive 推断复制来源。
- 未变更后端接口、路由、Foundation 或 Web；未调用业务 API 写入。iOS 只做兼容实现与 Dart 通道边界回归，Windows 未编译或真机验证 iOS。

## 验证范围

实际定向测试文件：

最终九个文件共 36 项通过；改动 20 个 Dart 文件格式检查零变更，架构检查通过，21 个模块文档检查通过。日志分别位于 `build/clipboard-origin-validation/final.log` 与 `architecture-final.log`；期间真实回复菜单新断言曾误用主题夹具 ID／短路由，核对原有链接生成规则后修正测试预期，生产 URL 格式未改。

- `test/features/app_shell/clipboard_navigation_coordinator_test.dart`
- `test/features/app_shell/clipboard_own_link_prompt_test.dart`
- `test/features/app_shell/clipboard_navigation_prompt_test.dart`
- `test/features/app_shell/device_clipboard_navigation_gateway_test.dart`
- `test/features/app_shell/handled_clipboard_navigation_store_test.dart`
- `test/features/threads/thread_copy_link_entry_test.dart`
- `test/features/posts/post_copy_link_entry_test.dart`
- `test/features/threads/thread_invitation_controls_test.dart`
- `test/core/widgets/wenyou_content_action_menu_test.dart`

覆盖空剪贴板、立即切出／不可读、反复恢复、重建容器模拟重启、外部同文新事件、无 timestamp 收据升级、实际页面入口、邀请两种复制、复制和存储失败、迟到读写和弹窗、后台扫描守卫、模态避让及准确路由。方法通道 mock 仅证明 Dart 参数与返回处理，不冒充原生系统验证；Android 构建证据见下方，设备行为仍待负责人复验。

按负责人本次明确要求，候选前不运行全量 Flutter 测试或 `npm run check` / `check:apk`；虽涉及原生与持久化，仍以本次用户明确批准的节奏执行：定向回归、静态分析和必要 Debug 构建，真机通过后、合并前再运行完整门禁。应用／生成客户端分析和 APK 已由治理任务在保留已验收编辑器功能的组合 Worktree 集中执行，本分支不重复构建。

## 组合 Debug 候选

2026-10-01 北京时间 03:13:03，组合提交 `0ae9ee32726788cea3056412ea709e3b8fef3c56` 的 `candidate:apk` 成功完成。该源码保留负责人已验收的 PR #78／#79，另加入本次 `e6427e36` 和导入排序修正 `1aa4facd`。editor 与 core/markdown 相对原验收组合 `7465c324` 零差异；组合与独立 PR #81 的应用源码仅三个既有 editor 文件不同。此前功能验收另由 `a30161d0`／`d2e72226` 记录，不代表本次剪贴板问题已验收。

- 12 个显式测试文件共 76 项通过：上述九个文件，另加 `test/features/editor/editor_link_insertion_test.dart`、`editor_alignment_toggle_test.dart`、`editor_toolbar_buttons_test.dart`。
- 应用与生成 API 客户端全量静态分析零问题；全仓 1144 个文件格式零变更；Android Debug 构建成功，构建阶段 63.6 秒。
- 源码摘要 `a8675b98ab5f13a1965f1717d71e5032841d80a337c2a2a6863ec20dc4775091` 在候选入口前后不变，组合工作区干净。
- APK：`D:/codex-artifacts/clipboard-origin-20261001/wenyou-clipboard-0ae9ee32-debug.apk`，150191687 字节，SHA-256 `B00A1536074A9268448AA007D6AF2E79FD88A479DBA5D4377B185426671D3A46`。
- 包名 `site.wenyou.app.debug`，显示名「温油站 Debug」，版本 `0.8.0-debug / 97`，仅 `arm64-v8a`，`debuggable`，APK v2 签名校验通过。
- 成功日志：`D:/codex-worktrees/editor-debug-candidate/clipboard-candidate-apk-retry.log`。首次入口仅因一个测试 import 排序 info 停止，修正后重新执行唯一入口；原日志 `clipboard-candidate-apk.log` 保留，没有把旧 APK 当作新候选。

此次仅交付 APK，未安装或启动设备：设备当前哈希 `fb2b248e…` 属于另一私帖分享 PR #80 候选，保留其验收现场。此包默认现有公网 API，属于独立 Debug 安装包而非隔离预览，未自动登录或业务写入。iOS 未编译或设备验收。PR #81 仍为 Draft，本次原问题待负责人真机验收，未运行全量测试、未合并、未部署。

## 真机复验步骤与交接

1. 打开本轮交付的温油站 Debug，复制一个楼层或回复链接，立即回桌面／其他应用后再返回，确认不弹导航提示。
2. 分别复制主题／子贴正文链接、讨论页主楼层和回复；已有私密邀请的再次复制应同样不提示。邀请生成与复制只在负责人手测或已核验隔离环境进行，自动化不向线上生成邀请。
3. 保留剪贴板划掉应用后重开，确认本次事件仍不提示；从其他应用重新复制完全相同地址返回，应正常询问。
4. 验证暂不、前往查看、重复恢复与其他弹窗退场后的行为，检查没有重复提示且路由准确。

独立分支从 `origin/dev` 的 `84d0a0d8` 创建，先复用契约同步 `7a73ca47`（等价于 `bcc29e01`），对应 Backend `21acf512` / API `5.28.0-dev.20260929.1`。治理任务通过 Git 把本次业务提交引入已验收编辑器组合候选；此任务不修改、合并或安装其他任务的候选。与私帖分享链接 PR #80 都涉及 invitation controls，后续整合必须保留本次 `navigationLinkWriterProvider` 接入并重验两种邀请复制入口。

Auto-review 默认偏好已传递；宿主协作工具没有审批参数或生效配置核验入口，实际 Auto-review 尚未设置／核验，不能将当前 never 配置视为 Auto-review。未合并、未部署、未安装设备。

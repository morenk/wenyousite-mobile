# 编辑器排版与选中态验收

> 历史验收记录：专用隔离开发预览已于 2026-10-10 退役，下文保留当时证据，不作为当前启动指南。当前流程见 [Debug 开发](../live-debug.md)。

## 范围与状态

状态：负责人真机验收通过／待合并前完整门禁。

按负责人要求，Web 与 Mobile 统一仅保留居中、居右图标，默认居左无需单独按钮，再次点击已选图标取消对齐。负责人查看首轮预览后追加选中态统一：Mobile 主栏与更多托盘的图标均对齐 Web 柔粉圆角底与深色图标，包括加粗、斜体、引用、列表、对齐和展开入口。本记录只覆盖 Mobile。独立任务分支为 `codex/20261001-mobile-alignment-toggle`，基线为 Mobile `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3`。

Foundation 只读镜像已 fetch tags，最新正式版本仍为 `v7.2.1`，与依赖锁定一致。按本次明确需求覆盖旧 Flutter profile 对三个选项的展示描述，继续复用既有语义图标、主题与命中区；不修改 Foundation 或 Markdown 存储协议。

复用独立契约同步 `bcc29e017c850a4794f437afad611c45eebcffe9`，本分支对应 `1cc2fd9e`，固定 Backend `21acf512285f2a21aaa831f960211780de73aafc`／`5.28.0-dev.20260929.1`；只新增兼容 nullable DTO 字段，不接入其他任务的界面。

## 行为与回归

- 默认左对齐、混合多段方向：两个图标都不选中；点击后将可对齐块统一为目标方向。
- 居中、居右可直接切换，再次点击已选方向恢复左对齐，保存去除隐藏 marker，保留文字与段落边界。
- 正文、H2/H3 与 Markdown v5 独立图片复用现有格式命令；列表、引用、分隔线、v4 图片等原禁用状态保持。
- 格式操作保持光标、正向／反向选区和撤销重做；不修改按钮以外的显式 `applyAlignment` 调用语义。
- 选中背景、前景复用 `accentedBackground/onAccentedBackground`，对应 Web `accent/accent-foreground`；圆角为 `radiusControl`，触控面积保持 48dp。图标继承 `IconTheme`，禁用优先显示 `mutedText` 并移除选中底色。
- 真实回复页面使用 stub repository 验证“居中 → 再点居中 → 发布”载荷与阅读字形左对齐，无线上业务写入。

## 首轮独立候选验证（历史阶段）

直接测试文件：

- `test/features/editor/editor_alignment_toggle_test.dart`
- `test/features/editor/editor_toolbar_buttons_test.dart`
- `test/features/editor/editor_toolbar_test.dart`
- `test/features/editor/editor_toolbar_history_test.dart`
- `test/features/editor/editor_alignment_compatibility_test.dart`
- `test/features/posts/post_replies_page_test.dart`
- `test/core/network/post_edited_time_contract_test.dart`

明暗托盘 Golden 使用 360dp 默认字号且加粗选中，以及 320dp／2× 字号且加粗、居中选中状态。图片位于 `test/features/editor/goldens/editor_more_tray_*.png`。实际检查结果随候选交付记录列出；Golden 是 Widget 渲染证据，不代表真机验收。

该阶段上述 7 个文件共 114 项通过（并发 2），包括 4 张 Golden 与真实回复页面的提交载荷／阅读字形检查。全仓 Dart 格式 1133 文件零变化；应用与生成客户端全量静态分析、架构、21 模块文档及固定契约来源检查通过。静态分析首次发现两个测试的旧图标类型 import 已无用途，移除后重新分析，不改应用源码。该阶段未完成完整 `npm run check`、Android 构建和设备验证。

独立候选的应用源码摘要为 `fd19fd7240ee12e7ff5662fc71038e52fb6e9370952afd92737784e57210a305`，由 `tool/dev/runtime.mjs` 的 `sourceEvidence` 计算；文档和测试 import 清理不改变该摘要。负责人查看两轮明暗预览，在第二轮选中态统一后明确“可以，交付候选”；当时仅确认视觉方向，真机交互仍待复验。

## 首轮候选的设备状态与复验清单（历史阶段）

首轮候选交付时，本机未连接 ADB 设备，未启动本任务 Debug 会话或生成替代 APK。当时列出以下复验清单；后续独立 APK 与负责人验收结果见下一节。

1. 在主题、楼层和楼中楼编辑器打开“更多”，确认只有居中、右对齐图标，明暗模式与窄屏下可触达。
2. 对正文、标题分别居中／居右，再次点击当前方向，确认回到左侧、光标与键盘保持。
3. 对混合多段选区点击某方向统一，再次点击取消；保存并重新打开后保持默认左对齐。
4. 验证 v5 单图片方向切换及反选，列表／引用的原禁用规则不变。

## 2026-10-01 组合 Debug 真机验收

负责人在 Xiaomi `2509FPN0BC`（设备 `4b9c39b5`）上测试组合 Debug APK 后，明确反馈“ok这两项功能我真人测试通过了”。本 PR 的双对齐反选与统一选中态通过负责人真机验收；另一项站内链接修复由 [Mobile #78](https://github.com/morenk/wenyousite-mobile/pull/78) 单独记录。此反馈不扩展为上述清单所有设备、字号或边界组合逐项人工通过的证明。

- 本 PR 业务提交：`6d7ccf96e5d29a0f44e133b923ce679637852fbd`；组合还包含 #78 的 `2da944875f73863521bd3c6b9e7af3ba594d5c90`，兼容契约 chore 仅引入一次。
- 组合源码：`7465c324ceb1a2ea834c8925934104a8ba1a0ab8`；应用源码摘要：`17e858811161bfb218bc0c014e3dfb6bfd2e1b828ad5270f77c4afc043123f06`。
- 包名：`site.wenyou.app.debug`；版本：`0.8.0-debug`／构建号 `97`；仅 `arm64-v8a`。
- APK SHA-256：`40E2B21BE2B128BEAC39FA54EAA5C603EC3EE1B909620038D2495B6CCC1011EA`；2026-10-01 02:34:22（北京时间）首次生成，设备安装更新时间为 02:35:34，设备内 APK 哈希与交付包一致。
- 交付文件：`D:/codex-artifacts/editor-ux-20261001/wenyou-editor-ux-7465c324-debug.apk`；安装核验证据：`D:/codex-artifacts/editor-ux-20261001/mobile-debug-install-receipt.json`。这些是本轮本地制品位置，不作为仓库依赖。

组合候选通过唯一快速入口 `candidate:apk`：全仓 Dart 格式检查 1136 文件零变化、应用与生成客户端全量静态分析零问题、以下 6 个文件共 109 项测试通过，随后 Debug APK 构建成功：

- `test/features/editor/editor_link_insertion_test.dart`
- `test/features/posts/post_hyperlink_edit_test.dart`
- `test/features/editor/editor_alignment_toggle_test.dart`
- `test/features/editor/editor_toolbar_buttons_test.dart`
- `test/features/editor/editor_toolbar_test.dart`
- `test/features/posts/post_replies_page_test.dart`

此前启动的 `check:apk` 按负责人“先别跑全量测试”要求中断，未进入全量 Flutter 测试，不能记为完整门禁通过。组合构建日志与中断记录保留在 `D:/codex-worktrees/editor-debug-candidate/`。该独立安装包沿用默认 API `https://wenyou.site/api/v1`，不是隔离预览；代理仅构建和安装核验，没有自动启动、登录或执行线上业务写入。

本次只补记验收文档，不修改应用或测试、不重新构建。负责人真机验收不等于合并授权；完整合并门禁仍待对最终整合源码执行，PR 保持 Draft，未合并、部署或正式发布。

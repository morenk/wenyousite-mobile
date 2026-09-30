# 编辑器排版与选中态候选

## 范围与状态

状态：视觉候选／待负责人验收。

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

## 候选验证

直接测试文件：

- `test/features/editor/editor_alignment_toggle_test.dart`
- `test/features/editor/editor_toolbar_buttons_test.dart`
- `test/features/editor/editor_toolbar_test.dart`
- `test/features/editor/editor_toolbar_history_test.dart`
- `test/features/editor/editor_alignment_compatibility_test.dart`
- `test/features/posts/post_replies_page_test.dart`
- `test/core/network/post_edited_time_contract_test.dart`

明暗托盘 Golden 使用 360dp 默认字号且加粗选中，以及 320dp／2× 字号且加粗、居中选中状态。图片位于 `test/features/editor/goldens/editor_more_tray_*.png`。实际检查结果随候选交付记录列出；Golden 是 Widget 渲染证据，不代表真机验收。

本轮上述 7 个文件共 114 项通过（并发 2），包括 4 张 Golden 与真实回复页面的提交载荷／阅读字形检查。全仓 Dart 格式 1133 文件零变化；应用与生成客户端全量静态分析、架构、21 模块文档及固定契约来源检查通过。静态分析首次发现两个测试的旧图标类型 import 已无用途，移除后重新分析，不改应用源码。完整 `npm run check`、Android 构建和设备验证不属于本次已完成证据。

最终应用源码摘要为 `fd19fd7240ee12e7ff5662fc71038e52fb6e9370952afd92737784e57210a305`，由 `tool/dev/runtime.mjs` 的 `sourceEvidence` 计算；文档和测试 import 清理不改变该摘要。负责人已查看两轮明暗预览，在第二轮选中态统一后明确“可以，交付候选”；仅确认视觉方向，真机交互仍待复验。

## 待负责人验证

本机未连接 ADB 设备，未启动本任务 Debug 会话或生成替代 APK。待设备及已核验隔离预览可用后，由当前任务按 `docs/live-debug.md` 启动持续 Debug。

1. 在主题、楼层和楼中楼编辑器打开“更多”，确认只有居中、右对齐图标，明暗模式与窄屏下可触达。
2. 对正文、标题分别居中／居右，再次点击当前方向，确认回到左侧、光标与键盘保持。
3. 对混合多段选区点击某方向统一，再次点击取消；保存并重新打开后保持默认左对齐。
4. 验证 v5 单图片方向切换及反选，列表／引用的原禁用规则不变。

本候选不代表负责人验收通过，不授权合并、部署或发包；反馈收敛及合并前依仓库规则补充完整门禁。

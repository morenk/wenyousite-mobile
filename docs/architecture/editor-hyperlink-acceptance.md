# 站内超链接候选验收

> 历史验收记录：专用隔离开发预览已于 2026-10-10 退役，下文保留当时证据，不作为当前启动指南。当前流程见 [Debug 开发](../live-debug.md)。

状态：负责人真机验收通过／原问题修复完成；尚未合并。治理任务 `01a0f31a-4eb8-7801-91c7-e39c854be53b`，Windows 独立分支 `codex/20261001-mobile-hyperlink`，基线 `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3`。

2026-10-01 负责人先确认明暗候选截图方向，随后在下述 Debug 包上明确反馈“这两项功能我真人测试通过了”，覆盖本项站内超链接修复及独立 PR #79 的排版与选中态调整。

## 真机验收通过

- 验收日期：2026-10-01；设备：Xiaomi 2509FPN0BC，Android API 36。
- 应用：`site.wenyou.app.debug`，`0.8.0-debug` / build `97`，ARM64；安装更新时间为北京时间 02:35:34，设备内 APK 哈希与交付包一致。
- 组合源码：`7465c324ceb1a2ea834c8925934104a8ba1a0ab8`，包含本 PR 的 `2da944875f73863521bd3c6b9e7af3ba594d5c90` 与 PR #79 的 `6d7ccf96e5d29a0f44e133b923ce679637852fbd`，兼容契约 chore 只引入一次。
- APK SHA-256：`40E2B21BE2B128BEAC39FA54EAA5C603EC3EE1B909620038D2495B6CCC1011EA`。
- 组合候选的格式、应用及生成 API 全量静态分析通过，以下六个文件共 109 项定向测试通过：`editor_link_insertion_test.dart`、`post_hyperlink_edit_test.dart`、`editor_alignment_toggle_test.dart`、`editor_toolbar_buttons_test.dart`、`editor_toolbar_test.dart`、`post_replies_page_test.dart`（分别位于 `test/features/editor/` 与 `test/features/posts/`）。`candidate:apk` 构建成功。
- 按负责人明确指示，完整门禁在全量 Flutter 测试之前中断，不宣称全量通过。合并前仍需验证最终集成源码；本次验收不包含合并、部署或正式发布授权。
- 负责人另报的“应用内复制链接后返回前台仍提示跳转”由独立任务处理，不改变本项已确认的验收结果。

## 原始反馈与复现边界

负责人反馈 Android 0.8.0 build 97 的主题详情编辑器插入站内楼层链接时出现“当前格式组合暂时不能安全保存”；没有主动加粗，普通外链不报错。诊断为 `editorEncode` / `markdown.document_roundtrip` / `MarkdownCodecException`，没有 API 响应。期望遵循 Web 现有规则：站内传送门使用粉色圆角底与门图标，普通外链保留下划线。

未获得原始目标 URL、完整草稿或设备操作录像。回归采用已提交 `internal-reference-v1-fixtures.json` 中的合法坐标与用户给出的操作语义；它证实同类入口缺陷，不冒称复现了该用户原始私人内容。

## 已证实原因和候选

工具栏旧实现先插入普通文字，再写 `link` 属性；保存后解码合法站内地址会得到 `wenyou_internal_reference` 原子节点，节点类型与可编辑语义发生变化，因此严格往返校验拒绝保存。字体粗重和下划线来自既有普通链接视觉，并非用户设置了粗体。

候选在同一工具栏入口复用现有站内粘贴解析与 Delta 原子节点，一次替换完成插入或选区转换；由已有编辑器 embed builder 和 Foundation `v7.2.1` surface 渲染。外链和 Codec 保持原行为，跨段和包含节点的选择无损拒绝，仍可重新选择普通文字。HTTP、Markdown 与 Foundation 链接契约不变；另行同步的可选 `editedAt` 契约与本问题无关，见[来源复核](hyperlink-contract-source-review.md)。

## 自动证据与视觉预览

- 旧生产实现：四种合法站内目标经实际工具栏插入后 `flush` 全部返回 false，错误与用户日志对应；真实回复页面无法显示传送门。没有放宽失败断言。
- `test/features/editor/editor_link_insertion_test.dart`：主题、子贴、楼层、带旧子贴坐标的楼层、楼中楼、邀请；空光标和反向选区、标签与周边文字、规范目标、节点无富文本属性、独立可编辑行、保存重开及一次撤销／重做。另核对普通外链下划线、跨段／原子选区拒绝、待应用粗体和链接不污染节点、空段和段落边界。
- `test/features/posts/post_hyperlink_edit_test.dart`：真实回复页面打开、输入、面板插入、保存、阅读、重新编辑；只用内存仓储。
- 320dp 明暗截图来自实际工具栏插入后的 Quill 和阅读组件：`test/features/editor/goldens/link_insertion_320_light.png`、`link_insertion_320_dark.png`。两态均复用既有 Foundation 表面，图标、可见文字、圆角和底色一致；人工已查看 Golden，但它不是设备截图。
- 直接相关回归：`test/features/editor/editor_toolbar_test.dart`、`editor_format_policy_test.dart`、`editor_selection_history_test.dart`、`editor_clipboard_test.dart`、`editor_embed_builders_test.dart`、`editor_wysiwyg_parity_test.dart`，以及 `test/core/markdown/markdown_delta_codec_test.dart`、`markdown_delta_semantic_safety_test.dart`。
- 上述 10 个测试文件合计 207 项通过，包含 20 项新增回归和明暗 Golden 比较；应用全量静态分析零问题，全仓 1134 个 Dart 文件格式零变更，架构、21 模块文档、`git diff --check` 通过。独立兼容契约的生成 DTO 全量静态分析、4 项可选字段兼容测试、固定来源与公网只读验证、API 覆盖 161/161 通过。

## 首轮候选阶段记录与复验步骤

首轮截图交付时 ADB 无连接设备，`dev:list` 无可复用活动会话，尚未构建或安装 APK。后续按负责人要求生成并安装上述独立 Debug 包，默认 API 为现有站点，不是隔离预览；代理未自动启动、登录或执行线上业务写入。Golden 与 Widget 断言没有代替负责人随后的明确真机验收。

交付的复验步骤为：在原主题详情打开编辑器，选择“你好”或空光标打开“更多 → 链接”，输入原站内楼层 URL；应立即呈现传送门，保存后阅读与再次编辑保持相同文字和目标。再检查普通外链仍有下划线且可保存，撤销／重做、前后正文、真正空行保持。负责人已明确本项功能真机通过；未授权合并、部署或清理分支。

候选阶段检查与集成门禁分开：已完成定向验证与 APK 构建，尚未运行全量 Flutter 测试；合并前对最终源码执行仓库完整门禁。

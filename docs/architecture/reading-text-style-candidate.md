# 阅读文字样式与排版候选

状态：候选／待负责人真机验收。自动检查不代表负责人验收通过。

## 本轮验收反馈：分享链接无法保存

负责人于 2026-11-01 21:04 的原设备反馈无法安全保存，原候选按“验收失败／继续排查”处理，未记录为修复完成。已补充分享链接入口候选，待负责人复验；此前四项文字修复和测试记录保留。

- 原始文字：`希尔薇`；链接输入：`https://v.douyin.com/QIwpF-JdM4A/ :6pm mDu:/ H@V.Yz 08/08`，保留原空格与字符。
- 设备诊断：`editorEncode`／`markdown.unsafe_link`，`MarkdownCodecException`，一行、3 个文字单元、1 个样式区间、0 个 embed；失败点 `markdown_delta_inline_encoder.dart` 的链接校验，尚未发出保存请求。
- 已确认根因：面板仅检查 URI 协议，允许整段分享口令成为普通 link 属性；Codec 拒绝含空格的目标。使用原文字与完整输入，空光标／选区两条路径在旧实现均失败，日志 `share-link-before.log`。不放宽 Codec 校验。
- 新候选仅在链接面板解析单个 HTTP(S) 网址，确认前显示将采用的地址；多网址、无效字符和不完整地址在写入正文前拒绝。普通正文粘贴、已有 Markdown 和已插入的错误链接不静默重写；已有错误链接可重新选择原文字，在链接面板再次设置后恢复保存。
- 历史样式核对：`2da94487`（PR #78）明确把合法站内链接转为传送门、普通外链保留下划线；本次抖音是外链，此规则保持。
- 新增原输入、当前错误链接修复恢复、确认前预览、非法输入无损拒绝及真实回复页保存／阅读／重开回归。测试使用内存仓储，未自动提交线上内容；负责人原主题详情的真机保存仍待复验。

本轮涉及链接表单行为，按普通中风险候选执行精确回归、直接受影响测试和全量静态分析；不将前轮纯样式定向检查视为本轮检查结果。

- 检查结果：213 项定向测试通过（以下前 3 个文件 40 项，后 5 个文件 173 项），全量应用静态分析零问题，6 个变更 Dart 文件格式、模块文档与 diff 检查通过。无 Codec、依赖或原生配置变更。
- 实际测试文件：`test/features/editor/editor_link_input_test.dart`、`test/features/editor/editor_link_insertion_test.dart`、`test/features/posts/post_hyperlink_edit_test.dart`、`test/features/editor/editor_toolbar_test.dart`、`test/features/editor/editor_format_policy_test.dart`、`test/features/editor/editor_selection_history_test.dart`、`test/core/markdown/markdown_delta_semantic_safety_test.dart`、`test/core/markdown/markdown_delta_codec_test.dart`。
- 日志：同一 artifacts 目录内 `share-link-before.log`（旧实现两项失败）、`share-link-after.log`、`share-link-regression.log`、`share-link-analyze.log`。工具栏超过 700 行，本轮把输入解析放入独立 `editor_link_input.dart`，未向工具栏继续堆叠解析职责。
- 原终端 67176 热重载时返回 `Lost connection to device`；附着原进程的尝试也失败，未将此记录为更新成功。负责人明确确认“内容已保存或无需保留，可以重启 Debug”后，才停止旧 Debug 进程并重新启动本任务，保留应用数据。
- 复验：选中文字“希尔薇”，打开“更多 → 链接”，粘贴完整分享文本，应先看到提取后的网址，再插入并保存；阅读与重开应保留文字和真实目标。已插入的旧错误链接也可在同一选区重新设置后恢复保存。
- 本轮源码提交 `06b31dad7c3cc8fb45134bcca01407c481061e54`，在原 `e3fb99a3` 候选上补充入口修复；仍包含最新 `dev@b9ec7403`。
- 2026-11-01 21:24，按负责人授权通过 `npm run dev -- -d 4b9c39b5 --no-pub --dart-define=API_BASE_URL=https://wenyou.site/api/v1` 重启并保留数据安装。包 `site.wenyou.app.debug`，版本 `0.11.0-debug`／101，仅 ARM64；设备更新时间 `2026-11-01 21:24:03`，本地 APK 与设备内 APK SHA-256 均为 `5215b3acad4dfd2a8c2b4864f0fc77380b147930188ad085dae5c76f12a57f24`。
- 会话 19705 启动并同步文件成功，随后 `r` 再次返回 `Lost connection to device`，不报告热重载成功。应用进程 32016 仍在，设备截图显示应用已进入主题详情；本次交付依据为包含上述源码的已安装 Debug APK，而不是失联会话。截图 `device-share-link-candidate.png` 与三份新增／修改应用文件的 `share-link-source-sha256.txt` 保存在前述 artifacts 目录。
- 本次 Debug 安装产物来自普通开发入口，不是正式发布，也未执行线上写入 E2E。负责人使用原输入的保存和样式复验仍待确认。

## 最新 dev 基线整合

- 按负责人要求更新到 `origin/dev@b9ec74038bd71c5563f4c97f3a2d5f9f3528b973`（PR #133）。在原任务分支合入最新 dev，保留已推送的候选历史，不修改 dev。
- 最新整合候选源码提交：`e3fb99a328adc475789ba0f879a95d41af677ecc`，已核验最新 dev 是该提交的祖先；后续仅补充此追溯记录。
- 保留最新 dev 的传送门紧凑高度、发布对齐投影、引用结束边界和字号统一，再叠加本任务四处修复。三个应用文件自动合并后逐项复核；变更记录冲突保留两侧条目。
- 本轮重新执行原 12 个相关测试文件，并追加传送门、引用边界、字号偏好与 Markdown 入口共 6 个文件；完整清单与结果位于 `D:\codex-artifacts\wenyousite-mobile\text-audit-20261101\latest-dev-test-paths.txt`、`latest-dev-tests.log`。
- 本轮 18 个文件、253 项定向测试全部通过；8 个受影响 Dart 文件格式与静态分析零问题，23 个模块文档检查及 diff 检查通过。提交前再次 fetch，最新 dev 仍为 `b9ec7403`。
- 追加的 6 个文件为 `test/features/editor/editor_portal_alignment_spacing_test.dart`、`test/features/posts/post_portal_alignment_test.dart`、`test/features/editor/editor_quote_exit_boundary_test.dart`、`test/features/posts/post_quote_exit_boundary_test.dart`、`test/core/application/thread_font_preference_test.dart`、`test/core/widgets/wenyou_markdown_test.dart`。
- 整合完成时设备曾断开；负责人重新连接后，已于 2026-11-01 21:03 更新最新基线候选并热重载。最新设备证据见下一节，首轮证据仅作历史保留。

## 最新基线 Debug 真机候选（2026-11-01 21:03）

- 交付源码：`e3fb99a328adc475789ba0f879a95d41af677ecc`，应用源码无未提交修改；更新前核对远端 dev 仍为 `b9ec7403`。253 项定向回归及静态分析结果绑定此源码，本轮仅补充设备记录。
- 设备 `4b9c39b5`（`2509FPN0BC`），包名 `site.wenyou.app.debug`，版本 `0.11.0-debug`／101；aapt 核验仅含 `arm64-v8a`。旧应用与调试进程已结束，使用本工作区普通 Debug 入口重新启动，保留应用数据。
- 启动命令：`npm run dev -- -d 4b9c39b5 --no-pub --dart-define=API_BASE_URL=https://wenyou.site/api/v1`；API `/meta` 可达且后端 revision 未变。
- 包更新时间 `2026-11-01 21:02:44`；本地 `build/app/outputs/flutter-apk/app-debug.apk` 与设备内 `base.apk` SHA-256 均为 `f0c26d7f6dbb5fa782ec2257569369df9a28f1d1e91d2444cce262d771f27544`。
- 本任务终端会话 67176，启动已包含最新源码；发送 `r` 后返回 `Reloaded 0 libraries in 1,658ms (compile: 123 ms, reload: 0 ms, reassemble: 107 ms)`，reassemble 成功。此会话供负责人继续真机验收。
- 已查看热重载后的首页截图，正常显示；文件 `D:\codex-artifacts\wenyousite-mobile\text-audit-20261101\device-latest-dev.png`。首页启动检查不替代四处文字问题的负责人验收，未自动发帖或发送私信。

下方首轮基线、测试数和真机记录保留为历史追溯，不作为本轮真机交付凭据。

## 范围与基线

- 分支：`codex/20261101-text-style-regressions`，起点 `origin/dev@faf3ed07`。
- 候选应用源码提交：`5595cbfedc29c6562d2658e7238f4932e6df0b8d`；之后仅补充本条追溯记录，应用源码未变，现有测试与 Debug 会话证据仍有效。
- Windows 工作区：`D:\code\wenyousite\wenyousite-mobile`。
- Foundation 已 fetch tags，最新正式版及锁定依赖均为 v7.6.0；已核对该版本 CHANGELOG 与系统文字缩放／Flutter 字体契约。
- 已记录后端、镜像 `origin/dev` 和公网 `/meta.buildSha` 均为 `19a6c4ed48829a781182527faaafce6e788e9e2e`；契约版本 `5.44.0-dev.20261024.3`，未发生漂移。
- 仅修改三个共享阅读组件的局部展示逻辑；未改转换、持久化、API、主题或依赖。影响范围通过调用方与真实阅读组件限定，按局部样式例外执行定向检查。
- `wenyou_markdown.dart` 超过 700 行，已评审本轮仅调整空段 builder 参数和注入现有样式；无新增职责，不为行数机械拆分。

## 原始复现与候选行为

本轮四个问题来自代码审查后的构造复现，不来自负责人私密帖子原文；对应输入和几何／样式断言已固化为精确回归。

1. 系统字号 2×，分别在 Markdown、动态／私聊纯文本阅读器呈现 `[入口](/threads/cmsewdo0h000x7qv6aa77ll1v)`。相同 17px 正文下，原纯文本入口字形高度约 98.46，Markdown 约 49.23。候选取消 WidgetSpan 内部的第二次缩放，保留外层缩放与点击语义。
2. `## 甲\n<br />\n## 乙`，系统字号 2×。原独立空段仍为 30.6dp，普通正文空行约 61.2dp。候选先按 TextScaler 缩放正文 fontSize，再乘行高，兼容非线性缩放。
3. 普通反引号代码与 `<span data-wenyou-color-v1="#D14343">` 包裹的同类代码比较：原着色代码从 14.96／1.7 变为 17／1.8。候选复用普通代码样式，仅覆盖指定颜色／字体并保留外层强调。
4. 普通外链与 `<span data-wenyou-font-v1="wenkai">[链接](https://example.com)</span>` 比较：原字体范围内链接退回正文颜色／w400。候选沿用链接颜色、w600 和下划线；显式 RGB 同时覆盖字色与下划线颜色，字体继续由运行时选择。

## 自动验证

- 原实现：四个精确回归全部失败；修改后四项全部通过。日志保留于 `D:\codex-artifacts\wenyousite-mobile\text-audit-20261101\fix-before.log` 与 `fix-after.log`。
- 新增组合测试包含 12 种写法，覆盖字体／颜色／两者、明暗主题和 14／19 正文字号；保留删除线与下划线叠加的独立语义断言。
- 缩放测试覆盖 1×／1.5×／2×、14／17／19 正文字号、非线性曲线、连续空段及长传送门窄屏折行。
- 真实入口覆盖 `ThreadSubthreadBody` 两种正文路径、`PostReadingBody`、`MomentDetailPage`、`MomentCommentBody`、`DirectMessageBubble` 收／发；主题和楼层额外核对阅读字号下的代码、字体链接与空段。
- 最终定向回归文件清单：
  - `test/core/widgets/reading_text_style_regression_test.dart`
  - `test/core/widgets/reading_text_style_combinations_test.dart`
  - `test/core/widgets/reading_text_scaling_test.dart`
  - `test/features/reading_text_entry_points_test.dart`
  - `test/core/widgets/wenyou_markdown_text_color_test.dart`
  - `test/core/widgets/wenyou_markdown_inline_code_layout_test.dart`
  - `test/core/widgets/wenyou_markdown_empty_paragraphs_test.dart`
  - `test/core/widgets/wenyou_internal_reference_text_test.dart`
  - `test/core/widgets/wenyou_markdown_inline_elements_layout_test.dart`
  - `test/core/widgets/markdown_font_paragraph_layout_test.dart`
  - `test/core/widgets/markdown_font_link_lifecycle_test.dart`
  - `test/features/settings/thread_font_reading_scope_test.dart`

最终定向回归 142 项通过（其中新增 50 项）；日志为 `candidate-tests-final.log`。两张 `markdown_text_color_320_{light,dark}.png` 已查看原图、候选及差异，变化来自彩色加粗文字恢复共享字距，更新后 Golden 通过。

受影响的 8 个 Dart 文件格式检查与 Flutter 静态分析通过、零问题；`npm run docs:check` 通过（23 个模块），`git diff --check` 通过。首次 Dart 分析未完成，已结束后改用 Flutter 分析入口；最终证据为 `flutter-analyze-final.log`。

## 首轮 Debug 会话（历史记录）

负责人已明确授权结束原“修复传送门发布后左对齐”任务的 Debug 会话并切换到本任务。切换时未发现仍连接设备的原 Flutter run／attach 进程，已停止旧 Debug 应用进程后使用本工作区启动普通 Debug，保留应用数据。

- 设备：`4b9c39b5`，型号 `2509FPN0BC`，`arm64-v8a`。
- 目标包：`site.wenyou.app.debug`，版本 `0.11.0-debug`，构建号 101。
- API：显式 `https://wenyou.site/api/v1`；启动前 `/meta` 可达。
- 入口：`npm run dev -- -d 4b9c39b5 --dart-define=API_BASE_URL=https://wenyou.site/api/v1`。
- 首轮会话终端：15990（目前已结束）；切换工作区后首次编译启动完成，再于 2026-11-01 19:33（北京时间）发送 `r` 热重载。
- Reload：`Reloaded 0 libraries in 2,112ms (compile: 141 ms, reload: 0 ms, reassemble: 130 ms)`。本次启动已包含候选代码，因此热重载无需重新加载库，reassemble 成功；不是把另一工作区的旧运行状态当作本候选。
- 设备包更新时间：`2026-11-01 19:32:32`。本地 `build/app/outputs/flutter-apk/app-debug.apk` 与设备内 `base.apk` 的 SHA-256 均为 `e451bb14e40627b7d066c1c7b69f057c4a3f0c1b33be05c10af69a49b536d6e3`。这是普通 Debug 启动产物，未另造发布包。
- 已查看设备首页截图，应用正常显示；截图仅证明启动画面，四个问题仍由负责人进入对应内容复验。启动时出现一次私聊未读 GET 网络失败日志，未更换 API，未发起业务写入。
- 相对基线唯一三个应用源码文件的 SHA-256 如下；其余应用源码、依赖和构建配置未修改。初装 APK 哈希不替代这份热重载源码记录。

| 文件（仓库相对路径） | SHA-256 |
| --- | --- |
| `lib/core/widgets/markdown_text_color_builder.dart` | `6d20e7d7c5fc7290e84240c7e9928efc02bfbc3d6e7289fd8a5184548e49490a` |
| `lib/core/widgets/wenyou_internal_reference_text.dart` | `18df7b07a833ec27376ad385afed60df97d4cfa325443bf5fbe6856ac9483228` |
| `lib/core/widgets/wenyou_markdown.dart` | `6bbb603c4e4edd975fb37ee6eef1195eebe30864ab4e6599749ecb493f059744` |

## 负责人真机验收步骤

1. 打开 `site.wenyou.app.debug` 对应 Debug 应用，进入含字体外链与着色代码的主题／子贴／楼层／独立讨论；比较添加字体或颜色前后的链接辨识度和代码尺寸。加粗、斜体、删除线叠加后仍应保留。
2. 将系统字号放大，查看两个标题之间的一个或多个空白行，空行应与正文空行保持相同缩放比例；恢复原字号后再次比较。
3. 分别在动态详情、评论、私聊收到／发出的消息查看传送门，标签不应额外膨胀；长标签可折行，点击仍打开目标，长按仍可打开原操作。
4. 复验明暗主题、窄屏和字体尚未加载／加载完成后的同一内容。代理不自动向线上发帖或发送私信，构造内容由负责人决定是否发布。

未验证项：负责人原设备上的上述视觉、交互及 TalkBack 实操；自动 Widget 测试不替代真机验收。未执行全量测试或独立候选 APK 流程，使用本任务持续 Debug 交付。

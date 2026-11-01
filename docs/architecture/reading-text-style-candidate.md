# 阅读文字样式与排版候选

状态：候选／待负责人真机验收。自动检查不代表负责人验收通过。

## 范围与基线

- 分支：`codex/20261101-text-style-regressions`，起点 `origin/dev@faf3ed07`。
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

## Debug 会话

负责人已明确授权结束原“修复传送门发布后左对齐”任务的 Debug 会话并切换到本任务。切换时未发现仍连接设备的原 Flutter run／attach 进程，已停止旧 Debug 应用进程后使用本工作区启动普通 Debug，保留应用数据。

- 设备：`4b9c39b5`，型号 `2509FPN0BC`，`arm64-v8a`。
- 目标包：`site.wenyou.app.debug`，版本 `0.11.0-debug`，构建号 101。
- API：显式 `https://wenyou.site/api/v1`；启动前 `/meta` 可达。
- 入口：`npm run dev -- -d 4b9c39b5 --dart-define=API_BASE_URL=https://wenyou.site/api/v1`。
- 会话终端：15990，保持运行供负责人验收；切换工作区后首次编译启动完成，再于 2026-11-01 19:33（北京时间）发送 `r` 热重载。
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

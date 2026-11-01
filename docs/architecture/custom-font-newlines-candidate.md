# 自定义字体换行与混排候选

状态：负责人验收通过／修复完成。日期：2026-11-01。

负责人对上一轮交付明确回复“验收通过，直接合并吧”。对应候选提交 `46b94038b87ff006481fc2b5de57016fcd787dfa`，APK SHA-256 为 `C7ACBB29598C758E02B878A9408A7BB53100E7F4F18BD6001E68DA98376EF604`；该确认完成本问题验收并授权合入 `dev`。不推断未提供的设备信息或额外逐项操作记录。

合并前同步 `origin/dev@36a76ab5` 的发布定位变更，代码无冲突，CHANGELOG 保留双方记录；本字体修复的应用实现没有追加修改。对整合后的最终源码执行一次 `npm run check -- -TestConcurrency 3`，结果在完成后追加。以下候选阶段记录保留其当时的证据边界。

## 原始反馈与复现边界

负责人提供两张私密楼层截图：编辑态中标题下方的“哈哈哈”和“姐姐”分行，存在多行留白；发布后两段文字挤在同一行，留白出现在错误位置。负责人确认操作顺序为先选择自定义字体再输入，两段之间连续按五六次回车，并反馈任意自定义字体均可触发；Web 没有该现象。

没有访问私密楼层，也没有取得原始 Markdown、字体版本 ID、键盘事件或完整编辑历史。离线样例使用截图中可见文字，分别覆盖 5 次和 6 次回车；不能把构造样例通过视为原私密楼层已验收。真实楼层页面测试的仓储、字体服务和本地文件存储均为测试替身，不向公网写入。

## 已证实原因与修正边界

- 阅读器的字体 builder 返回异步字体 Scope，上游 `flutter_markdown_plus 1.0.12` 只合并直接返回的 `Text`。同一段的字体片段、普通文本及换行因而分成多个 `Wrap` 子项：换行只影响自己的子项，不能把后一个字体片段推到下一行。
- 同一原因还会破坏字体片段与普通前后文的连续折行；修正同时保持混合片段的整段对齐。旧实现的 v1/v2 换行和长文本混排四项精确渲染回归均失败。
- 新的 `MarkdownFontInline` 保留受控字体片段，`mergeMarkdownFontInlines` 在块布局中合并同段文字与换行，使用一个段落字体 Scope 更新字体。标题、引用、列表、颜色、强调、链接和行内组件保留各自结构与样式。
- 字体需求按段落收集，沿用已有滚动释放、失败回退及注册预算；不扩大到整篇 Markdown，不改变保存协议、字体目录、字体资产或全局主题。可见性粒度从独立字体片段调整为同一段落：部分可见的长段落会请求段内字体所需字形，暂不逐行裁剪。
- 这是范围可确定的中风险阅读布局修正，候选采用全量静态分析、直接相关测试与独立 Debug APK。没有修改 Codec、网络、持久化或依赖；合并前仍需负责人验收及普通切片集成门禁。

## 基线

- 分支：`codex/20261101-custom-font-newlines`，起点 `origin/dev@13c95dd4`。
- 候选应用 `lib` Git 树对象：`8599597fcfb9c38845eb5d8c367ac097e6c120ab`；Android、依赖、版本与契约保持上述起点。
- Backend 记录、只读镜像 `origin/dev`、公网 `/meta` 的来源均为 `19a6c4ed48829a781182527faaafce6e788e9e2e`；API `5.44.0-dev.20261024.3`，本切片没有契约变化。
- 已在 Foundation 只读镜像执行 `git fetch origin --tags`，最新正式 Tag `v7.6.0` 与 `pubspec.yaml` 一致；已阅读 CHANGELOG 与字体／正文行高约束，没有依赖升级。

## 自动回归与候选证据

- `test/core/widgets/markdown_font_paragraph_layout_test.dart`：v1/v2、普通回车、连续空段、混合字体与普通文字连续折行，明暗主题、320dp、1×/2×字体、标题／引用／列表、颜色与强调。
- `test/core/widgets/text_font_render_scope_test.dart`：标题对齐与垂直度量、可见性及滚动、能力更新、冷加载、失败回退与关闭自定义字体。
- `test/features/posts/post_composer_font_newlines_test.dart`：真实楼层页面入口，先选字体再输入“哈哈哈”，逐次输入 5/6 个回车后输入“姐姐”；保存后核对阅读文字及空段，重开核对可编辑行数、标题和字体归属。
- 旧实现红灯日志：本地 `build/font-newline-investigation/old-regression.log`，四项渲染失败；按负责人确认输入顺序复跑 `old-confirmed-input-page.log`，v1/v2 × 5/6 次回车四项均在保存后阅读断言失败。相同页面测试在候选实现全部通过；最终检查及 APK 见下文。

探索测试中的原生 Markdown 行末双空格硬换行，属于固定 `markdown-v4-fixtures.json` 的 `space-hard-break` 不支持语法，会按既有规则显示字面源码。本次没有把它当成普通回车，也没有为了扩大渲染范围修改共享兼容规则。

### 安装包与证据

候选入口最终退出 0；同轮检查通过后构建 APK，未复用失败轮次产物。

- 应用：温油站 Debug，`site.wenyou.app.debug`，版本 `0.11.0-debug (101)`，最低 API 26，仅 `arm64-v8a`。
- 独立文件：`D:\dev-cache\artifacts\wenyousite-mobile\20261101-custom-font-newlines\wenyou-custom-font-newlines-c7acbb29598c.apk`。
- 大小：114368993 字节。
- SHA-256：`C7ACBB29598C758E02B878A9408A7BB53100E7F4F18BD6001E68DA98376EF604`；构建产物与独立副本均已校验。
- 同目录保留 `candidate-apk.log`、`candidate-test-paths.txt`、`old-regression.log`、`old-confirmed-input-page.log`、`confirmed-input-page.log`。
- 构建没有覆盖 API 定义，默认 API 为 `https://wenyou.site/api/v1`；未安装、未启动，也未自动执行线上写入。
- 没有执行全量 Flutter 集成门禁；这是普通中风险候选，负责人验收后、合并前按仓库规则运行最终源码的完整门禁。

### 独立候选实际测试路径

通过唯一入口 `npm run candidate:apk -- <以下路径> -TestConcurrency 2` 执行。全仓格式检查 1612 个文件零变化，应用与生成客户端全量静态分析零问题，以下 24 个文件共 425 项测试全部通过；模块文档检查与架构门禁也已通过。首轮候选入口被新增测试的一处字符串插值 lint 阻止，修正后重跑；未使用失败轮次的旧 APK。

- `test/core/widgets/text_font_render_scope_test.dart`
- `test/core/widgets/markdown_paragraph_spacing_test.dart`
- `test/core/widgets/markdown_font_paragraph_layout_test.dart`
- `test/core/widgets/markdown_font_link_lifecycle_test.dart`
- `test/core/widgets/markdown_alignment_spacing_test.dart`
- `test/core/widgets/wenyou_markdown_block_boundary_contract_test.dart`
- `test/core/widgets/wenyou_markdown_block_boundaries_test.dart`
- `test/core/widgets/wenyou_markdown_attention_boundary_test.dart`
- `test/core/widgets/wenyou_markdown_alignment_compatibility_test.dart`
- `test/core/widgets/wenyou_markdown_leading_whitespace_test.dart`
- `test/core/widgets/wenyou_markdown_inline_elements_layout_test.dart`
- `test/core/widgets/wenyou_markdown_inline_code_layout_test.dart`
- `test/core/widgets/wenyou_markdown_image_actions_test.dart`
- `test/core/widgets/wenyou_markdown_empty_paragraphs_test.dart`
- `test/core/widgets/wenyou_markdown_quote_overflow_test.dart`
- `test/core/widgets/wenyou_markdown_lifecycle_test.dart`
- `test/core/widgets/wenyou_markdown_test.dart`
- `test/core/widgets/wenyou_markdown_text_color_test.dart`
- `test/features/posts/post_composer_font_newlines_test.dart`
- `test/features/editor/editor_text_font_session_test.dart`
- `test/features/editor/editor_text_font_caret_test.dart`
- `test/features/editor/editor_range_font_integration_test.dart`
- `test/core/markdown/markdown_text_font_test.dart`
- `test/core/markdown/markdown_text_font_v2_test.dart`

## 负责人真机复验

当前 ADB 没有连接设备，没有启动 Debug 会话或安装应用。独立候选包必须打开 `site.wenyou.app.debug`（温油站 Debug）；正式包 `site.wenyou.app` 的原画面不会被这个候选更新。

1. 先在原私密楼层直接阅读，核对已有正文的“哈哈哈”和“姐姐”分行、留白位置；不要先改写原内容来掩盖阅读问题。
2. 打开编辑，先选任意字体，输入“哈哈哈”，分别连续按 5 次和 6 次回车，再输入“姐姐”。保存后核对空白行数量及位置，再重开编辑核对相同文字与行归属。
3. 同段中混用默认字体与两种自定义字体，加入长文字、粗体、颜色及居中／居右；检查窄屏折行、明暗模式和大字号。
4. 字体首次加载、离线回退、返回页面后重复检查，确保文字和换行仍完整。

自动测试和 APK 构建不能代替以上原机验收。候选交付时未标记完成；负责人于 2026-11-01 明确验收通过并授权合并，见本文开头。此次不发布或晋级版本。

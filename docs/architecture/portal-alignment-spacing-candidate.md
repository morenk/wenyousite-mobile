# 同行传送门对齐与行距候选

状态：候选修复，待负责人验收；完整门禁、APK 构建与包信息核验已通过。

## 原始现象与边界

2026-11-01 负责人提供编辑／发布两张截图：在居中正文同行加入传送门，编辑态仍居中，发布后该行居左；连续传送门行在编辑态背景紧贴，阅读态间距更大。截图可见「埃克塞丘」「拉奥提亚」「阿尔多沃」等正文。

预期：正文与同行传送门整体保持所选对齐，编辑与阅读的行距相符，连续背景之间保留间隔。操作顺序为正文居中、同行插入传送门、发布、查看正文。

原帖为私帖，负责人不提供链接；没有取得原始 Markdown、实际字体 ID、空格／换行字节或保存请求。测试采用独立构造文本，不将其视为原帖的精确输入或服务端存储证据；原场景仍需负责人复验。不自动执行公网写入。

后续反馈：负责人说明左／中／右对齐及任何字体均感觉编辑行距偏窄；明确要求编辑器跟随阅读字号，并把默认字号改为 15。

## 环境与范围

- Windows 独立 Worktree：`D:\codex-worktrees\portal-alignment-spacing\wenyousite-mobile`。
- 任务分支：`codex/20261101-portal-alignment-spacing`，起点 `origin/dev` 的 `36a76ab5`；最终检查期间同步到已验收字体修复合并后的 `78fd7883`。代码无冲突，CHANGELOG 保留两份记录。
- Foundation 已 fetch tags，最新正式版本仍为固定的 `v7.6.0`；已阅读 CHANGELOG、Mobile profile 与传送门／正文契约。
- 后端只读镜像 `origin/dev` 与公网 `/meta` 同为 `19a6c4ed48829a781182527faaafce6e788e9e2e`，API `5.44.0-dev.20261024.3`。
- ADB 初次检查没有已连接设备，无法启动真机 Debug 会话。

## 排查与验证

已证实的本地根因与修改：

1. 阅读器先将合法站内链接投影为内部 `[[wenyou-internal-reference:…]]`，再送入持久化 Markdown 对齐判定。内部占位被当成不支持的协议，导致整段丢失对齐。改为先解析原始对齐，再按段投影；索引仍在整篇内累加，未知协议判定不放宽，代码内链接继续按字面显示。原约 900 行的阅读入口同时按职责提取投影辅助文件。
2. 编辑传送门只有紧凑背景，阅读态另外保留 48dp 触控行盒；编辑态又在 WidgetSpan 和内部文字各缩放一次。两态现在共用行盒，内部文字只缩放一次，表面行高使用 Foundation 的 1.5；编辑态仍无导航行为。
3. 阅读页消费设备字号（旧默认 16，可选 13–19），编辑页固定 17。按本轮授权，编辑正文与派生标题／列表标记消费同一设备字号，默认改为 15。旧显式 `size15` 映射到当前 15 档，新增 `size16`，其他显式档位保持，不改变存储键或在读取时写盘。

大文件评审：阅读入口已将传送门投影提取为独立职责；主题创作页只增加现有字号 provider 接线，回复媒体测试文件只更新默认字号断言，均未扩大原职责或引入新的耦合，本轮保留既有结构。

原始构造回归在旧实现上 10 项失败：正文／H2／H3 的居中、居右共 6 项均退为左对齐；浅／暗、1x／2x 连续传送门 4 项背景间隙不足，1x 实测约 -0.36px。原系统字体同字号的左／中／右行距对照全部通过，因此没有给普通正文无依据地追加垂直间距。

直接相关验证路径（最终结果见下节）：

- `test/features/editor/editor_portal_alignment_spacing_test.dart`：原始 Markdown 保存／重开、真实字形几何、不同段链接索引；左／中／右、浅／暗、1x／2x、13／15／19 字号，普通正文与连续传送门行距比较。
- `test/features/posts/post_portal_alignment_test.dart`：本地 fake repository 的真实页面打开、文字输入、工具栏对齐与插入链接、提交、阅读、重开和改变设备字号；核对提交 Markdown、可见文字、单行块归属与对齐。
- 整合 `78fd7883` 后增加 `test/core/widgets/markdown_font_paragraph_layout_test.dart` 中字体 v1／v2 与同行传送门的居中／居右组合：可见文字、同段归属、至少 48dp 行距和整行几何对齐。该文件 27 项通过；上述两个传送门文件在整合后亦通过。字体运行时采用本地受控替身，不代表负责人实际字体分片的真机验收。
- `test/core/application/thread_font_preference_test.dart`、`test/core/storage/shared_preferences_thread_font_store_test.dart`、`test/features/settings/thread_font_reading_scope_test.dart`：默认值、旧值读取、失败／重试、各阅读入口与其他 UI 的边界。上述第一批合计 92 项通过；之后补充跨段链接索引回归。
- `test/features/editor/editor_embed_builders_test.dart`、`test/features/settings/thread_font_settings_page_test.dart`：直接受影响 Widget／Golden。已检查编辑传送门及设置页 320／600dp 明暗图，设置页旧“默认居中”断言按新默认 15 更新。
- 已执行的邻接回归：`test/core/widgets/wenyou_markdown_alignment_compatibility_test.dart`、`test/core/widgets/wenyou_markdown_inline_elements_layout_test.dart`、`test/core/widgets/wenyou_internal_reference_text_test.dart`、`test/core/widgets/markdown_alignment_spacing_test.dart`、`test/core/widgets/markdown_paragraph_spacing_test.dart`。首轮只有编辑传送门旧 32dp 行盒断言不符合新统一 48dp 行盒；已更新断言及对应 Golden，最终全量测试已覆盖。

视觉基线逐图核对范围：设置页 320／600dp 明暗、主题创作与回复编辑的首屏／键盘态、管理者阅读首屏，以及传送门编辑、阅读、输入草稿、私聊气泡、320dp 明暗插入对照和 360／600dp 富文本配对图。背景按 1.5 行高收紧，编辑行盒扩展到与阅读相同的最小尺寸；2x 配对图中的传送门文字不再重复放大。配对图原有的其他内联节点缩放与固定截图高度不作为本轮验收依据；连续普通文字与传送门行距另由几何测试核对。完整门禁第二轮中涉及旧传送门外观的 Golden 失败后，保留失败记录并以已核对的实际图更新基线，最终全量测试已重新覆盖这些基线。

由于本轮包括旧字号枚举读取映射，采用完整门禁和独立候选包，不套用局部纯样式例外。第二轮 `npm run check:apk -- -TestConcurrency 2` 的格式、全量分析、契约、架构、文档与覆盖检查通过，Flutter 测试为 8196 通过、1 按配置跳过、51 个旧视觉基线失败，未进入构建。失败图已逐图核对并更新；包括账号设置／游客入口中字号摘要从 16 到 15 的单字变化。之后的 4 并发门禁在约 3000 项通过、零失败时，因 `dev` 已合入负责人验收的字体换行修复而主动停止；整合已提交源码后重新验证，不把中止记录当成完整通过。最终验证结果见下节。API、依赖、生成客户端和 Markdown 写入协议不变。

## 最终本地验证

- 整合后的最终入口：`npm run check:apk -- -TestConcurrency 3`。
- 全仓格式、应用／生成客户端静态分析、架构、模块文档、API 覆盖、固定契约来源、公网只读兼容检查与生成一致性均通过。
- `test/` 全量 Flutter 测试 8278 项通过、1 项既有条件跳过（线上 Sentry 回执需显式启用）；Windows 工具测试 49／49 通过。
- 已逐图核对 65 张受默认 15 号与传送门行盒影响的既有基线，最终全量运行无 Golden 失败。应用只改动 8 个文件（含新提取的投影辅助文件），其余为测试与文档；依赖、锁文件和生成客户端无变化。
- ARM64 Debug 构建通过，最终门禁返回 0；`apksigner verify --verbose` 验证通过，使用 v2 签名。最终 ADB 检查仍没有设备，未安装候选。

## 候选安装包

- 应用源码提交：`a071b51f4f5dbe192e0debd5b678272e813b7bae`，基于已验收字体修复 `78fd7883`；之后仅补充本条证据，不改变已检查的应用源码和 APK。
- 应用：`温油站 Debug`，包名 `site.wenyou.app.debug`，版本 `0.11.0-debug`，构建号 `101`，仅 `arm64-v8a`，最低 API 26。
- 路径：`D:\codex-worktrees\portal-alignment-spacing\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 大小：114386325 字节；构建产物时间：2026-11-01 18:14:41（北京时间）。
- SHA-256：`A04C5CD9CC21908F16FCDFC82DB592A789BD7668EEB7F459188187DB9F8A0C10`。
- 构建未覆盖 API define，使用原默认 `https://wenyou.site/api/v1`；未启动真机会话、未执行线上写入 E2E。该包与正式应用数据独立，复验时应打开 `温油站 Debug`。

## 负责人复验

1. 进入主题帖字号设置，恢复默认应为 15；另选 13、19，阅读和编辑应同步变化，重开应用仍保留选择。
2. 在原私帖的同一段落依次选择左／中／右对齐，正文同行插入传送门；保存后整行方向应保持，重开编辑保持相同文字、行数与方向。
3. 连续三行加入传送门，比较编辑／阅读背景间隔；默认字体与此前使用的字体均检查，浅／暗及大字号检查不重叠、不重复放大。
4. 保留普通回车、真正空白行、H2／H3、列表以及传送门点击；编辑态传送门不导航，阅读态指向原目标。

未验证：原私帖完整输入、服务端保存链路、负责人实际字体资源、Android 真机画面与负责人验收。设备检查为空，未安装、未接管其他任务 Debug 会话，也未用 Widget／Golden 冒称原问题已修复。

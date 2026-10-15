# 编辑器区间读取候选

状态：候选／待负责人验收。关联 Sentry `WENYOUSITE-MOBILE-2W`，历史 `M/1Q` 仅作为相近调用路径参考；不关闭或合并 Sentry issue。

官方完整门禁：**待通过**。按 `AGENTS.md` 第 8 节，高风险候选必须在同一次官方完整门禁成功后构建 APK。以下 OOM 失败与分步补检结果分别保留，分步通过不替代 `npm run check:apk -- -TestConcurrency 1` 一次退出 0；等待独占构建资源后重跑官方入口，应用源码继续冻结。

## 问题证据与边界

- Sentry 调用链为 IME → `LiteralTextQuillController.replaceText` → 提及监听 → `Document.getPlainText` → `Line._getNodeText.substring`。
- 原始正文和完整输入法操作序列尚未取得。本轮构造一个带不同样式叶节点的 `a@b\n` 文档，并保留缩短前的光标坐标 `8`：旧实现稳定抛出 `RangeError (start): -1`；坐标 `80` 在查询窗口起点越界时抛出 `Null` 到 `Line` 的类型错误。光标 `-1` 的构造例在旧实现已不抛错。
- 这证明过期选区能触发相同提及读取路径，尚不能断言线上 `2W` 只由这一状态触发。Quill 固定提交保持 `c273155025d1255335a6dd3e6ecd3700d29f103e`，未升级依赖。
- 基线为 Mobile `d7168b61ea1b547e737585d2e9b250f1b3bd24e2`。治理任务只读核验 Backend `dev/origin/dev` 与公网 `/meta.buildSha` 均为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，API `5.36.0-dev.20261005.1`；HTTP、Markdown 和数据库契约不变。

## 候选行为

- 共用区间读取按 UTF-16 坐标保留文字、换行和单坐标 Embed；只复制涉及的叶节点片段，不经过剪贴板节点展开。UI 选区不能覆盖末尾保护换行，控制器内部结构替换可以显式包含该换行以保留块属性；起点不能在保护换行之后，终点不能超过文档长度。
- 负数、已超出当前正文、负长度和越过各调用方边界的范围返回失效，不裁剪到另一段正文。
- 正文控制器在 `replaceText` 的编辑事务之前校验，内部复用已读取的选区；后续分隔线结构保护也必须放在该前置校验之后，避免无效操作意外修正已有正文。
- 提及遇失效选区停止查询；正文与简短输入框的失效替换保持正文、选区和撤销历史；粘贴保留草稿并复用重新粘贴错误。链接托盘提交时再次核验已保留的选区与正文签名，缩短或同长度替换都不能误用原选区，过期时留在托盘提示重新选择。
- 保留现有无损保存门禁、草稿、附件以及业务写入行为，不混入尖括号保护、分隔线编码或工具栏布局候选。

## 自动检查

2026-10-16 短组合 5 个文件、62 个测试通过（`range-final-targeted.log`）。随后组合审查将范围校验前移到公开替换入口，并补充“无效范围加异常分隔线”和文末起点回归。最终应用源码冻结后，执行以下验证：

- `npm run check:apk -- -TestConcurrency 1` 的契约校验／来源／再生成一致性、公网只读兼容核验、1301 文件格式、应用和生成客户端分析、架构、23 个模块文档及 174/174 API 覆盖均通过；全量 Flutter 在 2343 项通过、1 项既有跳过后遇到宿主 Dart VM `allocation.cc:30 Out of memory`，加载 `startup_brand_test.dart` 时编译器退出。已核验并停止本任务挂起 runner，门禁最终退出 1（`range-check-apk.log`），不记为通过。
- 释放空闲构建资源后，单独执行 `flutter test --no-pub -j 1 --reporter expanded`：6607 项通过、1 项既有 Sentry 显式在线验收跳过、0 失败，退出 0，耗时 41 分 22 秒（`range-flutter-after-oom.log`）。该次覆盖最终前置校验、文末边界、异常分隔线、完整编辑器目录、真实编辑页关闭／返回及阅读生命周期。
- `npm run test:release-tool`：49 项通过、0 跳过、0 失败，退出 0（`range-windows-tools.log`）。
- `flutter build apk --debug --target-platform android-arm64`：退出 0，`assembleDebug` 耗时 209 秒（`range-apk.log`）。补检期间没有修改应用源码、测试或 Manifest；当时未重复已通过的静态步骤，原完整门禁仍为退出 1。后续须独占重跑官方入口取得一次退出 0。

分步构建 APK 位于 `D:\codex-worktrees\mobile-sentry-range\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，大小 110344514 字节；`aapt dump badging` 核验包名 `site.wenyou.app.debug`、版本 `0.9.0-debug`、构建号 `99`、ABI `arm64-v8a`。SHA-256 为 `DDB38636E2AAE62C4B411EF74B5A70F0BAC54C1FB86B68AAF3FD3AD8EB74B985`。构建完成于 2026-10-16 03:10（北京时间）；没有安装或启动该包，不据此宣称官方门禁已通过。

直接回归文件：

- `test/features/editor/editor_document_range_test.dart`：UTF-16 全子区间、跨行、不同样式、Emoji、提及与图片节点、空文档及文末、失效替换／粘贴、撤销重做。
- `test/features/editor/mention_suggestions_test.dart`：旧实现红灯的过期选区，真实 Flutter 文本输入通道组合输入、跨行与原子提及、保存重开及既有候选交互。
- `test/features/editor/editor_link_insertion_test.dart`：链接托盘选区过期与既有站内链接插入、撤销、保存重开。
- `test/features/editor/editor_alignment_compatibility_test.dart`：完整段落、跨段、图片及带对齐的剪贴板结构仍保留末行块属性；早期候选曾误拒绝覆盖保护换行的内部替换，已纠正调用边界并加入独立回归。
- `test/features/posts/post_composer_composing_close_test.dart`：真实帖子编辑页组合输入后，通过外部点击关闭和系统返回均未抛错，未发起业务更新请求。
- `test/core/widgets/wenyou_markdown_lifecycle_test.dart`：既有 10 项选择、跨段拖动、滚动及缓存卸载场景通过，未复现历史 `WENYOUSITE-MOBILE-11` 的未布局 RenderBox 错误。该组近期事件仅来自 `0.8.0`，本轮只记录观察结果，不修改阅读器或关闭该 issue。

短组合执行命令：`flutter test --no-pub -j 1 test/features/editor/editor_document_range_test.dart test/features/editor/editor_alignment_compatibility_test.dart test/features/editor/editor_link_insertion_test.dart test/features/posts/post_composer_composing_close_probe_test.dart test/core/widgets/wenyou_markdown_lifecycle_test.dart --reporter expanded`。执行后将 `post_composer_composing_close_probe_test.dart` 更名为 `post_composer_composing_close_test.dart`，内容不变；完整门禁使用正式文件名。

组合输入的组件测试曾在直接卸载仍持有输入连接的 Quill 组件时触发其 dispose → composingRange 通知 → setState 断言。组件测试按正常失焦流程收尾；另以上述真实页面关闭／返回测试复核，没有用测试收尾代替页面验证。尚未覆盖真机输入法或强制终止应用。

测试均为离线单元／Widget 场景；没有连接线上业务写入入口，没有安装或启动设备应用，也没有写入 E2E。

## 独立代码审查与组合边界

网络候选协作任务完成只读审查，未发现阻断：核对了 UTF-16 坐标、Embed 单 U+FFFC、失效范围不 clamp、公开 `replaceText` 事务前校验，以及链接托盘完整 Delta 签名校验。该审查没有运行合并后的候选，不能替代组合回归。

本候选 #103 与保存／分隔线候选 #100 没有硬依赖，各自在原始基线上独立验证。建议遵循本轮优先级，先合并 #103，再集成 #100；该顺序不代替负责人验收与明确的合并授权。

集成 #100 时，公开替换入口顺序必须为：范围校验 → 失效立即返回 → 同一 `history.record` 内执行 `_replaceLiteralText(selectedText: ...)` → `preserveEditorDividerBlocks`。范围校验始终位于历史事务和分隔线修复之前，同时保留 #100 在 `formatText`／`compose` 中的保护。应用源码、测试与 Manifest 在最终验证期间保持冻结；仅验收记录等文档更新不改变 APK 对应源码。

## 负责人复验

1. 打开发生过问题的原正文，按原输入法连续输入、替换组合词、快速移动光标和切换输入法；确认输入不中断，已有正文和样式保留。
2. 在跨段正文、Emoji、已有提及或图片后输入 `@` 和中文／Emoji 名称；确认候选搜索和插入位置正确，撤销重做正常。
3. 选择跨段正文进行普通替换，再保存并重开；核对文字、空段、样式和节点归属。
4. 打开链接托盘后改变正文，再尝试提交旧选区；确认不会替换其他文字，可以重新选择后完成操作。

负责人未明确验收前不标记修复完成；当前版本无复发也不替代原场景复验。PR #76、#98 与其他编辑器候选保持各自验收边界，合并时检查工具栏与会话文件的上下文冲突。与保存／分隔线候选合并时，共享 `replaceText` 方法须保留本轮事务前校验，再执行替换和结构保护；重点复验分隔线附近组合输入、提及、跨节点替换、撤销重做与结构粘贴。

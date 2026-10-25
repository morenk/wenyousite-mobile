# 编辑器区间读取候选

状态：候选／待负责人验收。关联 Sentry `WENYOUSITE-MOBILE-2W`，历史 `M/1Q` 仅作为相近调用路径参考；不关闭或合并 Sentry issue。

## 2026-10-25 六项组合验收前的基线整合

用户授权按 #101 → #103 → #100 → #76 → #104 → #92 推进，整合最新 `dev`、检查后交付一个包含六项的组合验收 APK，暂不合并。本 PR 仅处理 #103 的失效范围候选；组合源码的完整门禁和最终 APK 由治理任务统一记录。

- 从原 HEAD `29b3ea84f1aa980facca4797571aad307eb6a8a9` 普通合入 `origin/dev@b7e1a4acf9433b38b29505834b5f1eea77598330`，不 rebase 或强推。唯一文本冲突为 CHANGELOG，保留两侧历史记录。
- 继承最新字体 v1/v2、光标输入字体与颜色、粘贴完整文档签名、音频可逆投影、标题间距、相册与安全区行为。范围 guard 继续先于 `runEditCommand`／历史记录／音频投影；有效替换继续使用最新输入样式实现。未引入 #100 分隔线或 #76 HTML 解析候选。
- 契约继承 Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`、API `5.44.0-dev.20261024.3`、Foundation `v7.6.0`，本轮无契约或依赖变更。
- `editor_range_integration_test.dart` 在原 8 条音频边界回归中增加动态字体输入意图检查；`editor_range_font_integration_test.dart` 覆盖 v1/v2 的无效结构替换不污染待输入样式、真实粘贴入口保留来源字体及颜色、后续输入与撤销重做、保存重开，以及异步字体验证期间同长度样式变化拒绝迟到粘贴。预期文字与样式独立给定，不用 Codec 结果反推。
- 本分支执行精确回归、直接受影响测试和全部改动 Dart 文件的格式／分析、架构与模块文档检查；应用与生成客户端全量分析、全量测试、完整门禁和新 APK 在六项最终组合源码统一执行。本分支定向结果不冒充完整门禁，以下 10 月 21 日及 10 月 16 日完整门禁均属于历史源码。
- 宿主实际策略仍为 `approval_policy=never`、全访问；Auto-review 默认偏好已传递，但工具无受支持设置／核验入口，不能宣称已生效。原 Sentry 输入与真机顺序仍未取得，本轮不宣称原问题已修复。

改动范围静态检查通过：以相对 `origin/dev` 的全部存续 Dart 变更加新文件去重，涵盖原候选和本轮新增共 14 个文件。`dart format --output=none --set-exit-if-changed` 报告 14 文件、0 变化；`flutter analyze --no-pub --fatal-infos --fatal-warnings` 对该 14 文件报告零问题，耗时 121.1 秒。`dart run tool/check_architecture.dart` 与 `dart run tool/check_docs.dart` 均退出 0，23 个功能模块文档完整；架构检查保留既有超 700 行评审提醒，未放宽上限。本任务检查按单并发串行执行；观察到整机另有早先启动的其他任务测试进程，未接管或停止，不宣称整机独占。

本轮精确回归已通过：`editor_range_integration_test.dart` 与 `editor_range_font_integration_test.dart` 两文件共 12 项；另 21 文件 232 项通过，总计 23 文件 244 项。所有 Flutter 测试均以 `flutter test --no-pub -j 1 --reporter expanded` 执行，没有线上业务写入。另 21 文件为：

```text
test/features/editor/editor_document_range_test.dart
test/features/editor/mention_suggestions_test.dart
test/features/editor/editor_link_insertion_test.dart
test/features/editor/editor_alignment_compatibility_test.dart
test/features/editor/editor_alignment_clipboard_compatibility_test.dart
test/features/editor/editor_audio_projection_test.dart
test/features/editor/editor_audio_history_projection_test.dart
test/features/editor/editor_selection_history_test.dart
test/features/editor/editor_text_color_audio_integration_test.dart
test/features/editor/editor_text_color_caret_paste_test.dart
test/features/editor/editor_text_font_caret_test.dart
test/features/editor/editor_text_font_selection_test.dart
test/features/editor/editor_text_font_session_test.dart
test/features/editor/editor_text_font_interaction_test.dart
test/features/editor/editor_text_font_paste_scope_test.dart
test/features/editor/editor_dynamic_font_paste_test.dart
test/features/editor/editor_dynamic_font_toolbar_test.dart
test/features/editor/editor_clipboard_input_method_test.dart
test/features/editor/rich_editor_session_test.dart
test/features/editor/editor_atomic_clipboard_test.dart
test/features/posts/post_composer_composing_close_test.dart
```

反证在同一合并工作区只将两个控制器替换为 `origin/dev@b7e1a4ac`：Literal blob `70412def3ab5d214854753c4df019e441e274577`、Audio blob `d95f739ec8651839a89a40e01da37dce62c05fe8`。两文件共 12 项运行时，10 项失效范围用例发生 Quill 运行断言／区间错误，2 项已有异步签名保护用例通过；退出 1，不是编译失败。`finally` 按原字节恢复候选，Literal SHA-256 `85DBC67BC2773932D71423139392C79D7F50C3ABDC400288D427D81A25C9E352`、Audio `012F5CC5F47945236F511BD546A3F04A45076B5FFEDC493EA651E39F55679F96` 与替换前一致。首次尝试在 Windows `.bat` 中传入含 `|` 的 `--name` 正则，被命令解释器拆开，退出 255；该次未执行有效回归，不记为旧红，原日志保留后改为运行两份完整测试文件。

日志保留在 `D:\codex-worktrees\mobile-sentry-range\`：

| 日志 | 结果 | SHA-256 |
| --- | --- | --- |
| `range-new-regressions-old-dev-20261025.log` | 正则参数启动失败，退出 255，不计反证 | `42F9DC01BEE3FFE563ACAA3E66F280886E089823711C2B3E704032BDA4BC295C` |
| `range-new-regressions-old-dev-20261025-2.log` | 10 项旧红、2 项既有保护通过，退出 1 | `F029982F32D0A33F8480731710E9246A5810C0699028F13126DDC83F8DAA4D51` |
| `range-new-regressions-candidate-20261025.log` | 12 项通过，退出 0 | `169BDF42F3A60E5F5790A4DDC4467826101535F277BC0EE4D036FDE17053183E` |
| `range-related-tests-20261025.log` | 21 文件 232 项通过，退出 0 | `F8C2DD47760A0CB778087C142C757C0055F2DBF4E4AF44728663496A3AFAD8E3` |
| `range-changed-format-20261025.log` | 14 文件无格式变化，退出 0 | `96270A979B4BD53F90BC61DEF6839C6FB96DBBA459E1F873AAF4C9F481D988C7` |
| `range-changed-analyze-20261025.log` | 14 文件分析零问题，退出 0 | `0F5FA2048319FC3B2215A2E06389C9C407C156BE63C7AF37DEC292F0DF656AAD` |
| `range-architecture-20261025.log` | 架构检查通过，退出 0 | `D13E402F496ACACD5EF1AE27FB53B65D07B03EA7757214947C6A9F4B384C8C8C` |
| `range-docs-20261025.log` | 23 模块文档完整，退出 0 | `8AB319EBD2B97E58F95897DD563CEBE6B4B90F3716AEB8EB263C0149C35E9E35` |

## 2026-10-21 历史整合概述

2026-10-21 最新 `dev` 整合：**官方完整门禁已通过，待负责人验收**。本轮在原分支与 PR #103 继续整合，原 HEAD 为 `2407dadb0bae6add7e85c5d2dd1185a147c5ece0`，以普通 merge 合入 `6f0064507a77e2034250ee4fd9f1d382e0a063a9`；不改写已共享历史。最终冻结树为 `799355264b86fe2a3564923f5bc1e1073dde61f8`，同一次 `npm run check:apk -- -TestConcurrency 1` 于 06:04 完成并退出 0。执行后核对应用、测试、工具、原生配置、契约、生成客户端和依赖清单均与冻结树无差异，提交前仅补充结果文档；本轮提交 SHA 记录在 PR #103。下列 10 月 16 日结果仅为历史证据。

原候选官方完整门禁：2026-10-16 独占运行 `npm run check:apk -- -TestConcurrency 2`，同一次入口完成全量检查与 APK 构建，最终退出 0。运行时 HEAD 为 `ba4ff5384af0a362d909fd4ec69af83502a283a3`，与应用提交 `e7f895238e351498b85446e6cdfddc90339e98cf` 的差异仅为候选文档。以下首次 OOM 失败与分步补检历史分别保留；官方通过仍不替代负责人原场景验收。

## 最新 dev 整合

- 保留最新 `dev` 的文字颜色／输入色、链接来源身份、音频可逆投影、工具栏、错误 UI 与发布流程；本轮范围仍为安全读取和失效选区，不吸收其他未合并候选。
- `LiteralTextQuillController.replaceText` 先读取并验证范围，再通过最新 `runEditCommand` 保留输入色与统一历史事务，内部复用已读取的选中文本。后续分隔线保护仍须位于有效范围检查之后。
- 新增的 `AudioProjectedQuillController` 在最外层事务前复用相同范围判定；父控制器拒绝后不能继续执行音频投影。正常元数据更新、有效输入和原生撤销重做流程保持。
- 整合后会话文件达到 904 行并触发架构门禁，按职责将原有操作失败枚举／值类型移到 `rich_editor_operation_failure.dart`；会话保留兼容 export，错误种类、文案和调用接口不变，文件降至 890 行。
- 新增离线整合回归，构造音频元数据与视图尚未同步的真实投影输入，检查负数、保护换行后起点、超长范围及负长度均不改变正文、输入色、选区、已有 undo／redo 条目身份；显式投影后继续输入仍保留颜色和历史。8 项均完成旧红新绿，并再次通过最终全量门禁。
- 新基线保留 Backend 来源 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`、API `5.40.0-dev.20261018.1`、Foundation `v7.5.0` 及 Android `0.10.0+100`。治理任务只读核对公网 `/meta` 的 buildSha 与 API 版本一致、Markdown 契约为 5；本地来源仍以既有兼容范围检查，不倒退已合入契约。
- 宿主可见策略为 `approval_policy=never`、全访问；Auto-review 偏好已传递，但工具无受支持设置入口，不能记作 Auto-review 已生效。没有安装、启动、发布或部署；重型检查由治理任务串行安排。
- 保存候选协作任务已只读复核本轮整合，未发现确定阻断：音频与普通控制器的范围 guard 均先于最外层事务，正常内部替换复用已读选区，音频回归有真实投影差异、投影未触发、颜色和历史身份断言。此次审查未执行测试，也未将两个候选分支合并运行。

## 本轮检查与制品（2026-10-21）

- **新整合回归旧红新绿**：临时仅将音频控制器换回 `6f006450` 的实现，8 项均在非法输入后正文 Delta 被音频收缩／展开的断言处失败，退出 1；其余仍为候选源码。随后从已暂存候选恢复该文件并核对 SHA-256 一致。候选 11 个直接回归文件 131 项通过；类型拆分后的范围／音频／链接 3 文件 41 项通过。没有更改预期来消除失败，原 Sentry 真实输入缺失的边界仍保留。
- 第一轮官方入口在 API 生成器 `606 inputs: 1 skipped` 停滞，连续观察无日志更新、CPU 时间不增长；确认 AOT PID `28240` 的路径和父链属于本 Worktree 后停止该子进程，门禁退出 1。仅在本任务 `packages/wenyou_api` 运行原生 `dart run build_runner clean`（退出 0），没有删除共享缓存或停止其他任务进程。
- 第二轮官方入口通过契约、再生成一致性、格式及应用／生成客户端分析，因 `rich_editor_session.dart` 的 904 行超过 900 行而退出 1；按职责拆出既有失败类型至独立文件，保留兼容 export。保存候选任务只读复核枚举顺序、构造器、字段和导入兼容一致，无阻断。
- **第三轮官方入口退出 0**：契约来源、再生成一致性、公网只读兼容、1435 文件格式、两套分析、架构、23 个模块文档及 175/175 API 覆盖均通过；Flutter 全量 7336 项通过、1 项既有 Sentry 显式在线验收跳过、0 失败，耗时 45 分 22 秒；Windows 工具 49/49，0 跳过／失败；同一次入口构建 APK 耗时 157.1 秒，最终输出 `Wenyou mobile quality gate passed.`。构建保留既有 Kotlin 插件兼容警告，未改变依赖。

APK：`D:\codex-worktrees\mobile-sentry-range\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，大小 **112837782 字节**，产物时间 **2026-10-21 06:04:45（北京时间）**。`aapt dump badging` 核验 `site.wenyou.app.debug`／`0.10.0-debug`／build `100`／`arm64-v8a`，min SDK 26、target SDK 36。SHA-256：`A4906C37B1D58EBF68CDCFF362C1C9C26621DD72D8BE203E786B8E3AB5E02C16`；没有安装或启动。

日志均直接保留在产品 Worktree 外层 `D:\codex-worktrees\mobile-sentry-range\`：

| 日志 | 结果 | SHA-256 |
| --- | --- | --- |
| `range-integration-old-audio-20261021.log` | 旧音频外层 8 项失败，退出 1 | `18A24404659B649375898CDD01ED4F781AFE817B70CBF2A918785C301E8C4CC4` |
| `range-integration-targeted-20261021.log` | 11 文件 131 项通过 | `B7ED03E498FFD771054E1E8CFBB2A2EA31EB4663C7F2B009E91A639387BA5850` |
| `range-type-split-targeted-20261021.log` | 拆分后 3 文件 41 项通过 | `B6F9AE7231AC28B5E6497B40A4CFE422E9849D612CA86EB1F946CF221E215093` |
| `range-check-apk-dev-integration-20261021-1.log` | 生成缓存停滞，退出 1 | `7920023CF1BDBFC9C197A7E0EC0F56BD2E22B0DEB164B2C3A1892839922006CB` |
| `range-check-apk-dev-integration-20261021-2.log` | 文件规模门禁，退出 1 | `CC59769EB5DEB6FA11152A4B8D04FCC5270A5D8331BCC136DC23EE8C19F872D2` |
| `range-check-apk-dev-integration-20261021-3.log` | 官方入口退出 0，1834790 字节 | `D07CFA95D9C06932886CD06BDD5D23B5C120F4B39AAB7CA0ABBD11F6FCA07C69` |

本轮 Gradle 复用了其他任务已有 daemon `6548`。日志核验本路径 build `8b0c2306-93de-479d-9dd3-d82a5b10b261` 于 06:04:46 完成并进入 idle，且无活动 wrapper；按治理约束保留该 daemon 及既有 Kotlin 进程，未执行全局 stop。全部回归为离线单元／Widget，公网核验只读；未合并目标分支、部署发布、安装运行或关闭 Sentry。

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

## 原候选自动检查（2026-10-16）

2026-10-16 短组合 5 个文件、62 个测试通过（`range-final-targeted.log`）。随后组合审查将范围校验前移到公开替换入口，并补充“无效范围加异常分隔线”和文末起点回归。最终应用源码冻结后，执行以下验证：

- **官方重跑通过**：`npm run check:apk -- -TestConcurrency 2` 在同一次入口通过契约校验／来源／再生成一致性、公网只读兼容、格式、应用与生成客户端分析、架构、23 个模块文档和 174/174 API 覆盖；Flutter 全量 6607 项通过、1 项既有 Sentry 显式在线验收跳过、0 失败，耗时 24 分 25 秒；Windows 工具 49/49；随后 `assembleDebug` 构建 135.3 秒。日志最终为 `Wenyou mobile quality gate passed.`，命令退出 0。
- `npm run check:apk -- -TestConcurrency 1` 的契约校验／来源／再生成一致性、公网只读兼容核验、1301 文件格式、应用和生成客户端分析、架构、23 个模块文档及 174/174 API 覆盖均通过；全量 Flutter 在 2343 项通过、1 项既有跳过后遇到宿主 Dart VM `allocation.cc:30 Out of memory`，加载 `startup_brand_test.dart` 时编译器退出。已核验并停止本任务挂起 runner，门禁最终退出 1（`range-check-apk.log`），不记为通过。
- 释放空闲构建资源后，单独执行 `flutter test --no-pub -j 1 --reporter expanded`：6607 项通过、1 项既有 Sentry 显式在线验收跳过、0 失败，退出 0，耗时 41 分 22 秒（`range-flutter-after-oom.log`）。该次覆盖最终前置校验、文末边界、异常分隔线、完整编辑器目录、真实编辑页关闭／返回及阅读生命周期。
- `npm run test:release-tool`：49 项通过、0 跳过、0 失败，退出 0（`range-windows-tools.log`）。
- `flutter build apk --debug --target-platform android-arm64`：退出 0，`assembleDebug` 耗时 209 秒（`range-apk.log`）。补检期间没有修改应用源码、测试或 Manifest；当时未重复已通过的静态步骤。该分步结果不替代官方入口，之后已完成上述一次退出 0 的官方重跑。

官方完整日志保留在 Worktree 外层 `D:\codex-worktrees\mobile-sentry-range\range-check-apk-official-2.log`，大小 1580287 字节，SHA-256 为 `51E9079E19BD25799E6A6D2A81C40EF7B6A00A4FC6474379BABFF6C83EDEA641`；已核对其与产品 Worktree 根目录原日志哈希一致。上述首次失败、全量补检、Windows 工具、分步 APK 和短组合日志也已复制到同一外层目录，逐份核对一致。

官方门禁 APK 位于 `D:\codex-worktrees\mobile-sentry-range\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，大小 110344514 字节；`aapt dump badging` 核验包名 `site.wenyou.app.debug`、版本 `0.9.0-debug`、构建号 `99`、ABI `arm64-v8a`。SHA-256 为 `DDB38636E2AAE62C4B411EF74B5A70F0BAC54C1FB86B68AAF3FD3AD8EB74B985`。本次产物时间为 2026-10-16 05:11:21（北京时间），与此前 03:10 分步构建的 APK 哈希相同；没有安装或启动该包。

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

负责人未明确验收前不标记修复完成；当前版本无复发也不替代原场景复验。PR #76 与其他未合并编辑器候选保持各自验收边界；已合入 `dev` 的工具栏行为随本次基线保留。与保存／分隔线候选合并时，普通与音频控制器的公开 `replaceText` 入口均须保留本轮事务前校验，再执行替换、结构保护和音频投影；重点复验分隔线附近组合输入、提及、跨节点替换、撤销重做与结构粘贴。

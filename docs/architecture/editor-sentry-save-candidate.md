# Sentry 编辑保存候选

状态：候选修复／2026-10-25 整合最新 dev 后定向回归、差异范围分析及架构文档检查通过，待组合完整门禁与负责人验收。下列旧完整门禁和 APK 仅证明对应历史源码，不能用于本次组合验收。

## 2026-10-25 最新 dev 整合

- 原分支 `codex/20261015-sentry-editor-save` 从 `56946a2ca8c767b07b7e7e0e9c8d7da8cfc4d1c6` 普通合并 `origin/dev@b7e1a4acf9433b38b29505834b5f1eea77598330`，合并提交 `9801f91a2fcdcc17b1b78fc4f334c4d715127e47`。没有文本冲突，不吸收其他未合并候选。
- 完整保留 Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`／API `5.44.0-dev.20261024.3`／Foundation `v7.6.0` 及新 dev 的字体 v1/v2、结构化粘贴、标题间距、输入色、音频投影与原生撤销行为。
- 分隔线边界维护抽取纯 Delta 规范化：真实粘贴预检与控制器事务共用同一规则，先验证补齐边界后的长度和严格 Codec 结果，再提交输入；保存 Codec 本身仍拒绝非法 Delta。字体与颜色不会落到分隔线节点或行末，新文字保留输入样式，结构化粘贴保留来源样式。
- 结构诊断将纯字体样式计入既有 `codecStyledRuns`，不收集字体标识、颜色值、正文、节点或账号信息。
- 新组合回归覆盖字体 v1/v2、颜色、标题、分隔线旁输入／纯文本和本站结构化粘贴、单步撤销／重做、精确光标、独立阅读语义、保存重开；超限粘贴保持原内容和历史。音频投影回归增加字体与颜色组合。
- 新粘贴回归在合并提交 `9801f91a` 的原 `RichEditorSession` 下成功编译并真实执行，在 `operationFailure` 应为 null 的断言失败；`finally` 逐字恢复候选前后 SHA-256 均为 `A7AA2447A11BD798618356F0D65EDB05B9A23BC8E1E179CFE763BCA575747033`。日志 `D:/codex-worktrees/mobile-sentry-codec/20261025-old-paste-red.log`，SHA-256 `B23E28D9F75BE1F81D8A5F385AAFC0F5E660431B0FEC209891A1F0AB0B90E03F`；恢复证据为同目录 `20261025-old-paste-red-result.json`。
- 首轮 15 文件回归为 113 通过／4 失败：字体 v1/v2 的两类粘贴文字正确，但终点应为 8、实际 11。原因是 Quill 对整个 Delta 按一个 embed 计算额外选区补偿；控制器现将所有显式 Delta 统一恢复调用方已计算的终点，再由实际块补丁转换一次。保留原失败日志 `20261025-targeted.log`，SHA-256 `A4E711C2CF0EC1F5AC1749DA3836042E11F637093BE6EB6125B7E5204AB16CA9`。修正后新组合文件 8 项全部通过，再复验全部相关文件，不以首轮部分通过交付。
- 最终 18 文件定向回归单并发通过 168 项、0 失败，于北京时间 `2026-10-25T18:31:15+08:00` 结束。日志 `D:/codex-worktrees/mobile-sentry-codec/20261025-targeted-final.log`，SHA-256 `25E3E3A777B83F8F18239DD2217F3D0B8156300C902A4E326A28610D2F3A56CD`；原首轮失败及独立 8 项通过日志全部保留。
- 实际测试文件（完整路径清单同时保存在仓库外 `20261025-targeted-final-files.txt`）：`test/features/editor/editor_divider_editing_test.dart`、`test/features/editor/editor_divider_integration_test.dart`、`test/features/editor/editor_divider_font_integration_test.dart`、`test/features/posts/post_divider_edit_test.dart`、`test/core/diagnostics/codec_structure_diagnostics_test.dart`、`test/features/editor/editor_audio_history_projection_test.dart`、`test/features/editor/editor_link_continuation_test.dart`、`test/features/editor/editor_text_color_caret_test.dart`、`test/features/editor/editor_text_color_caret_paste_test.dart`、`test/features/editor/editor_text_color_audio_integration_test.dart`、`test/features/editor/editor_text_color_selection_test.dart`、`test/features/editor/editor_text_font_caret_test.dart`、`test/features/editor/editor_text_font_paste_scope_test.dart`、`test/features/editor/editor_dynamic_font_paste_test.dart`、`test/features/editor/editor_alignment_spacing_test.dart`、`test/features/editor/editor_block_boundary_persistence_clipboard_test.dart`、`test/features/editor/editor_clipboard_test.dart`、`test/features/editor/editor_enter_newline_test.dart`。
- 本次按治理调度只执行候选差异范围的格式／分析、架构／文档和上述直接回归；应用／生成客户端全量分析、契约再生成、全量测试及唯一验收 APK 由最终六项组合源码统一 `check:apk`。本分支没有生成本轮独立 APK，也不宣称已完成本轮完整门禁。
- `flutter pub get` 退出 0，依赖锁无漂移。全部 15 个相对 `origin/dev` 的候选差异 Dart 文件（含新文件）格式检查通过；`flutter analyze --no-pub --fatal-infos --fatal-warnings <15 files>` 零问题。`npm run architecture:check` 与 `npm run docs:check` 均退出 0，23 个模块文档完整，架构仅保留既有接近行数阈值的提醒；没有提高基线或添加豁免。对应日志均在上述仓库外目录：`20261025-analyze.log`（SHA-256 `9DD9F2CB79B34B70FBEFDC97AD5662A306FD9D900CF4DD0689176171E99EE317`）、`20261025-architecture.log`（`90A134CB32B232BCDFC956FB810E5D7C4DA73700A17FE4173D37F95C55426D0F`）、`20261025-docs.log`（`4306FD5BE4BF67BF7FE42C1C60B6C957DD05DDF0B848D3433803E8C16196CF1B`）。检查后只补充本文结果，应用与测试源码保持。
- 仍未取得关联 Sentry 事件的完整原始输入及负责人真机复验。所有新增回归是明确操作的本机构造场景，不能代替原问题验收；不安装启动 App、不写线上数据、不合并或发布。
- Auto-review 默认偏好已传递，但当前工具没有运行审批配置或核验入口；本子任务宿主为 `never`／`danger-full-access`，实际 Auto-review 尚未设置／核验。

## 范围与证据

- 原始基线为 `d7168b61ea1b547e737585d2e9b250f1b3bd24e2`；2026-10-21 在原分支 `codex/20261015-sentry-editor-save` 将 `origin/dev` 的 `6f0064507a77e2034250ee4fd9f1d382e0a063a9` 合入原候选，沿用 Draft PR #100，不改写共享历史。
- 本轮已验证应用合并提交为 `65d6fa3f1206711047937a3c684ba2b70d33be63`，双亲分别为原分支 `4a9f462e` 与上述 dev。它与门禁冻结 tree 的全树差异仅为 `docs/CHANGELOG.md`、本候选记录；随后文档提交只补充本 SHA，应用源码、测试与 APK 依据不变。最终文档 HEAD 在 PR 交付中单独列出。
- 历史已验证应用源码为 `965d09f2e92484b78f0f31360e9354e88996831d`，文档 HEAD 为 `4a9f462ed271264cd1656744819f57d9f9aa4998`。下述 2026-10-16 门禁及 APK 只证明旧源码，本轮整合后的应用必须重新验证。
- 关联 `WENYOUSITE-MOBILE-2J/1T`（`markdown.document_roundtrip`）、`1G/2A`（`markdown.divider_line`）与 `21`（`markdown.paragraph_alignment_conflict`）。这些事件没有原始正文、Delta 或完整操作序列，不能证明其精确触发条件。本候选不关闭它们。
- 已证实的本机操作：打开 `前文\n\n---\n\n后文`，在分隔线节点后输入文字、删去线前两次换行或线后两次换行，旧代码均产生 `divider_line`；全选跨线并应用 H2 则产生 `divider_attributes`。原有严格保存门禁正确阻断写入。
- 不吸收独立 PR #76 的尖括号／打开保护改动或其他未合并候选。最新 dev 的文字颜色、音频、工具栏、发布流程、错误 UI、依赖和契约均保留，本候选不另改 HTTP、Markdown 契约、数据库或线上数据。

## 实现与保留边界

- 控制器输入、格式和 compose 事务维护分隔线独占行，保留文字与非分隔线节点；选中节点本身仍可删除。补边界与原操作共同进入原生撤销记录，不在序列化后修改正文。
- 既有严格语义等价、块校验、读取列表结构校验保持。无损失败继续保留当前编辑内容及上次成功草稿。
- Codec 异常只附带结构计数与固定差异类别，不保存原始内容。明确机器码分组不受行号变化影响；未知异常仍按位置分组，事件堆栈始终保留。
- 分组键调整只影响新事件，首次发布可能形成新组，不迁移、合并或关闭历史 Sentry issue；仍按 release、机器码与事件时间关联核验。
- 与区间读取候选按 range → codec 合并；整合 `LiteralTextQuillController.replaceText` 时必须保留 range 在公开方法／编辑事务之前的合法性 guard。无效区间应在任何正文修改或分隔线维护前返回，不能把检查移回 `_replaceLiteralText` 内部而让外层维护仍执行。两项候选共享此控制器，不能机械覆盖任一方改动。

## 2026-10-21 整合记录

- 三处冲突：`literal_text_quill_controller.dart` 使用新 dev 的 `runEditCommand`，将分隔线维护与输入颜色状态、选区和撤销放在同一事务；`markdown_delta_codec.dart` 在诊断捕获范围内先展开音频视图，再执行原有严格往返与列表校验；`docs/modules/editor.md` 同时保留保存稳定性与音频失败恢复说明。
- 固定契约为 `backendRevision=6e00c4031a8f970609eef8cbf6fdefe3e6b12126`、`contractVersion=5.40.0-dev.20261018.1`；本机 `markdownContractVersion=4` 沿用最新 dev 的兼容要求，不回退契约或生成客户端。
- 新增分隔线与输入颜色、音频投影、同 URL 独立链接的组合回归：独立阅读断言检查文字、样式、链接数量及分隔线块；投影切换和撤销／重做核对完整 Delta 与精确选区，保存重开核对音频标签和样式。本轮结果见下，不沿用历史通过结论。
- 范围候选的独立只读互审未发现确定阻断。按审查建议将纯颜色文字计入既有 `codecStyledRuns` 数量，补充断言保证不采集颜色值或正文；结构字段仍仅允许固定计数和类别。
- 本轮准备：确认本工作树生成包旧缓存入口时间为 `2026-10-15T15:56:58Z` 且没有本包活动生成器后，在本包目录执行一次原生 `dart run build_runner clean`，退出 0；`flutter pub get` 与五个直接修改文件的格式化均退出 0，依赖锁无漂移。日志分别为工作树父目录的 `20261021-integration-clean.log`、`20261021-integration-pub-get.log`、`20261021-integration-format.log`。
- 资源等待：2026-10-21 06:03～06:09 检出外部正式门禁的分析链 `30616 → 29588 → 12188 → 18428 → 6868`，随后转入 `flutter test --concurrency=2`（`38796 → 23080`）；物理可用内存一度约 1.08 GiB，故未叠加本候选定向与完整门禁。父任务只读确认其属于其他工作树 `D:/codex-worktrees/1528/wenyousite-mobile`，本候选保留外部进程及原属其他任务的 Gradle／Kotlin `6548/35392`，等待父任务重新放行。本记录不作为测试通过证据。
- 2026-10-21 07:04 获得重型槽后执行仓库外脚本 `D:/codex-worktrees/mobile-sentry-codec/20261021-integration-old-red.ps1 -RunTests`，只把控制器临时换成上述 `6f006450` 的原始 Git blob，保留新音频／颜色 API 与候选诊断 API。四项回归均编译并执行，`flush` 的 `Expected: true / Actual: <false>` 断言失败：三项分隔线独占行、一项分隔线块格式冲突。`finally` 恢复与备份 SHA-256 同为 `9CEC1BE2B011EAC369769C387FC692E439FFCC07F9B55FDA5D575D3358F6E3B0`，暂存区未变。
- 旧红脚本完成测试与恢复后，结果解析遇到 Flutter 额外的无 `type` 进程事件而退出 1；原始失败保留。修正仓库外解析器后只读检查原日志，逐项确认四个业务失败与原因，无其他错误，不重跑测试或把编译错误计作旧红。原日志 `20261021-070456-old-red-machine.log` 的 SHA-256 为 `09E99C79239DA0D6A2029FCE0381DD64F8EF908E4B797CB5CBD7A4EA84110A27`，恢复证据为同目录 `20261021-070456-old-red-result.json`。
- 候选九文件定向回归 `flutter test --no-pub ... -j 1 --reporter expanded` 退出 0，共 64 项：四个候选文件共 17 项，另含音频投影历史、链接续写、输入色、音频颜色组合与范围改色的既有回归。日志 `20261021-integration-targeted.log` 的 SHA-256 为 `86673F83904C397AD6E3059FC1BCF6985FD1F755DF7DDED1C7401A81777C41FD`。
- 上述实际测试文件：`test/features/editor/editor_divider_editing_test.dart`、`test/features/editor/editor_divider_integration_test.dart`、`test/features/posts/post_divider_edit_test.dart`、`test/core/diagnostics/codec_structure_diagnostics_test.dart`、`test/features/editor/editor_audio_history_projection_test.dart`、`test/features/editor/editor_link_continuation_test.dart`、`test/features/editor/editor_text_color_caret_test.dart`、`test/features/editor/editor_text_color_audio_integration_test.dart`、`test/features/editor/editor_text_color_selection_test.dart`。
- 定向成功后冻结 tree `e44f072a2ed7bf6ae29807d7ec66329f06632c70`；覆盖应用、测试、原生、工具、契约与依赖的 Git blob 清单为 `20261021-integration-source-manifest.txt`，SHA-256 `2103B58EAC02803212587874A4DAB65AF1DA31E56DBF60C81C0933EB8C85C786`。门禁后重新导出该范围的清单，哈希完全相同；后续只补充文档。
- 统一 `npm run check:apk -- -TestConcurrency 1` 于 `2026-10-21T08:06:39+08:00` 退出 0：契约校验、固定来源与生成一致性、公网只读兼容检查、全仓格式、应用与生成客户端分析、架构、23 个模块文档和 API 覆盖均通过；Flutter 7325 项通过、1 项既有真实 Sentry 收件测试按显式配置跳过、0 失败，Windows 发布工具 49 项通过，ARM64 Debug APK 构建成功（144.6 秒）。本轮完整门禁没有失败或重跑。
- 完整日志 `D:/codex-worktrees/mobile-sentry-codec/20261021-integration-check-apk.log`，SHA-256 `5DB7D5DE6D08947B0809FC495F5B5AB496E5F3E70A28864441E1D690806B9FA9`；退出状态见同目录 `20261021-integration-check-apk-result.json`。生成客户端、契约和依赖锁相对本轮 dev 基线无候选增量，暂存及工作区 `git diff --check` 通过。
- 构建后未发现活动 Flutter 分析／测试／构建、生成器或 GradleWrapperMain，已向父任务释放本组重型槽；外部字体任务原有 Gradle daemon `33740` 保留，不执行全局停止。
- 交付记录补齐后，`npm run docs:check` 再次退出 0，23 个模块文档完整；此后仅补充提交 SHA 与已有测试路径等纯文本记录，不再运行 Dart／Flutter 工具链。
- PR #103 的非法范围保护仍需在最外层 `AudioProjectedQuillController.replaceText` 及 `LiteralTextQuillController.replaceText` 的事务前完成；本分支保留 dev 的投影实现，待按 range → codec 顺序整合，不提前吸收该候选。
- 父任务以共同基线 `6f006450` 对 #103 最终 `29b3ea84` 与本候选冻结 tree 做只读 merge-tree 预览，明确冲突为 `docs/modules/editor.md` 与 `LiteralTextQuillController.replaceText`。后续按 #103 → #100 集成时，必须先完成范围读取与空值返回，成功后才进入同一事务执行替换和分隔线维护；同时保留最外层音频控制器 guard。当前没有实际合入 #103，预览不能代替将来的组合回归。

## 2026-10-16 历史验证记录

- 旧实现：`editor_divider_editing_test.dart` 四项均在 `flush == true` 断言失败，实际分别为 `divider_line` 三项与 `divider_attributes` 一项。
- 定向 `flutter test --no-pub test/features/editor/editor_divider_editing_test.dart test/features/posts/post_divider_edit_test.dart test/core/diagnostics/codec_structure_diagnostics_test.dart -j 1` 已通过最初 11 项：包含上述四项旧红新绿、原生单次撤销／重做、空段／Emoji／粗体、实际回复页草稿／发布／重开及诊断隐私／分组。之后补充相邻分隔线、无效选区与引用隐藏分段三项，三文件共 14 项已随完整门禁全部通过。
- 2026-10-16 首轮 `npm run check:apk -- -TestConcurrency 1` 通过 OpenAPI、固定来源、再生成一致性、公网只读契约与全仓格式，应用分析因三条新 import 排序 lint 退出 1；已修正，保留原日志后从统一入口重跑。测试仅使用本机内存、离线 Fake Repository，不调用线上写入。
- 2026-10-16 第二轮 `npm run check:apk -- -TestConcurrency 1` 退出 0：契约、生成一致性、格式、应用与生成客户端分析、架构、模块文档和 API 覆盖均通过；全量 Flutter 测试 6601 项通过，1 项既有真实 Sentry 回执测试按显式配置跳过；新增 14 项回归均执行；Windows 发布工具 49 项通过；ARM64 Debug APK 构建成功。此结论仅适用于上述历史应用源码。
- 当时生成客户端、契约与两个依赖锁文件没有变更；`git diff --check` 通过。完整日志保存在本机 `D:/codex-worktrees/mobile-sentry-codec/check-apk-2.log`，SHA-256 `A74AEA13F72812B9A23C19F75AD47DB945E42BE2722C50F21B744F6E6ACB19C4`；首轮失败日志为同目录 `check-apk.log`，SHA-256 `90ABDD0FDE7C0A82509D2D87EC1A86E9D78777300ADDD7F3912227AFC72BE15D`。
- 真机、原 Sentry 事件精确输入与新 release 观察尚未完成；自动测试与构建不代替负责人验收。

## 2026-10-21 历史候选包（不用于 2026-10-25 组合验收）

- 路径：`D:/codex-worktrees/mobile-sentry-codec/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 实际包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`，构建号 `100`，ABI `arm64-v8a`，最低 Android API `26`（`aapt dump badging` 已核验）。
- 大小 `112839034` 字节，SHA-256 `CB40B6604F1E59FEEA9EC2EE01CCFE51725E7456DBCE4095BDD98F1EA42DB835`。
- 未安装、未启动应用；未执行线上业务写入或隔离写入 E2E，页面回归只使用本机 Fake Repository。原 Sentry 输入、负责人真机验收和新 release 发布后的 7 天观察仍待完成。

## 历史候选包元数据（不用于本轮整合验收）

- 历史输出路径与本轮相同，现已被本轮新包覆盖；以下只保留 2026-10-16 的元数据，不表示旧文件仍在该路径。
- 实际包名 `site.wenyou.app.debug`，版本 `0.9.0-debug`，构建号 `99`，ABI `arm64-v8a`（`aapt dump badging` 已核验）。
- 大小 `110352398` 字节，SHA-256 `DBAB9FB046CA154001D560A6FADFA81E44A02269A6060970EF9FAEC0C35CE024`。
- 未安装、未启动应用；未执行线上业务写入或隔离写入 E2E，页面回归只使用本机 Fake Repository。

## 负责人复验

1. 在实际使用的候选应用打开含分隔线的可编辑正文，在线前／后输入、删除边界、全选应用 H2／列表／引用，确认文字与分隔线各自保持完整。
2. 验证撤销、重做、关闭恢复草稿、保存与重新打开；继续检查已有空段、Emoji、图片和行内格式。
3. 如仍出现保存保护，复制问题编号与脱敏详情，并在独立沟通中给出可共享的原文和操作顺序；不将真实正文追加到自动诊断。

本子任务本轮开发上下文可见审批策略为 `never`、全访问，工具没有运行审批配置入口。治理核验父任务 turn_context `01a15a6d-7d01-7ce0-9841-d21461295583` 为 `approval_policy=never`、`approvals_reviewer=user`、`sandbox_policy=danger-full-access`；Auto-review 默认偏好已传递，但未启用，不能将该父任务记录冒充子任务设置成功。

# 标题对齐间距候选

状态：原候选已于 2026-10-24 通过负责人验收，已授权合并。验收对应 `a0865abe875c3d18151ffe3a0141adaf3ec58192` 与 APK SHA-256 `d1a5cb0002f0b45d20a7c2b2789a4854fdb2d4e8868a0f07bdb9e03cce264217`；后续集成检查见[集成验收记录](alignment-font-integration-acceptance.md)。下文保留原候选证据。治理任务 `01a164b8-84ac-7682-9e56-376901766b25`，Windows Worktree `D:/codex-worktrees/mobile-alignment-spacing/wenyousite-mobile`，分支 `codex/20261023-mobile-alignment-spacing`，基线 `6f006450`。

## 需求与复现边界

用户确认问题位于 Mobile，仅切换居中或居右应保留原有 H2/H3 行距。未提供原始帖子正文或设备录屏；以下为根据描述构造并通过 Widget 实际布局复现的输入，不能代替原场景验收。

输入为 `前文\n\n## 标题文字\n\n后文`（三级标题替换为 `###`），光标位于标题文字后切换对齐。旧实现 H2 文字顶部从 83 移到 67，后文顶部从 156 移到 136；H3 顶部从 79 移到 67，后文从 149 移到 133。标题文字本身行高分别保持 33、30，丢失的是 16/4 与 12/4 的上下留白。

同类阅读输入：`## **标题**文字` 和 `### *标题*文字`。旧实现多样式 TextSpan 根节点没有基础样式，固定 strut 回退到正文；H2 实测高度 33 变为 31，H3 从 30 变为 31。另有 `前文\n\n<br />\n\n## 标题文字\n\n<br />\n\n后文`，仅对齐标题时两侧各丢失 12dp 块间距。

## 实现与依赖

- Quill 对齐会把行放入 align 分组。固定上游补丁从当前行读取标题属性，保留完整标题间距；非标题继续使用原有引用、列表等分组间距规则。来源、完整清单和 SHA-256 见 `packages/flutter_quill/WENYOU_VENDOR.md`、`tool/vendor/flutter-quill.json`。同一 `tool/patches/flutter-quill-heading-spacing.patch` 另外登记两处参数类型、一个未使用参数及包发布截图元数据的静态兼容整理，保留上游 lint，不改变原生或运行依赖。从固定提交重新提取源码、统一 LF 并应用登记补丁后，270 个文件逐一与清单哈希完全一致。
- 阅读适配器按实际解析到的标题块指定基础 strut，包含 WidgetSpan 时继续放开真实组件高度。仅相邻边界确实是标题时保留空段旁的块间距。
- Foundation 固定 `v7.6.0`；行距实现不改变 Markdown 语义，无持久化数据迁移。2026-10-24 按负责人后续要求完整同步 API 5.43 契约，详见[兼容同步记录](alignment-contract-compatibility-sync.md)。没有启动应用、登录、线上写入或接管其他任务设备。

## 自动检查与画面

- `test/features/editor/editor_alignment_spacing_test.dart`：实际编辑布局，覆盖产品 H2/H3 单段切换与恢复、H2/H3/P 在同一对齐分组首中尾、长标题折行、粗斜体/代码/颜色、软换行、空段、引用与列表邻接、恢复居左、撤销重做、先对齐再设标题。旧实现两个基础标题复现失败；候选通过。另外直接构造 Quill 原生 header 1/4/5/6，连同产品 2/3 验证补丁全部分支；产品 Markdown 仍仅支持 H2/H3，不把其他级别当作可用协议。同一行组合标题、列表、引用会由 MarkdownDeltaBlockEncoder 明确拒绝，因此引用和列表仅验证合法相邻场景。工具栏由 alignment.canApply 禁用整块引用、列表与代码块对齐；代码块按 literal 行保留，本次代码覆盖指行内代码，不声称支持整块代码对齐。
- `test/core/widgets/markdown_alignment_spacing_test.dart`：阅读文字和实际字形垂直坐标，覆盖产品 H2/H3、前后正文或标题单独对齐、普通换行和显式空段、混合行内样式。独立空段 30.6dp 与 strut 栅格化 31px 的差异只容许 0.5px 位置舍入，不容许块间距变化；字形高度容差 0.001px。
- `test/features/editor/editor_alignment_spacing_golden_test.dart`：离线 Widget 明暗画面，每列宽 320dp，同一纵向起点并列左、中、右；使用确定性可读中文测试字体。截图位于同目录 `goldens/editor_alignment_spacing_320_light.png` 与 `dark.png`，不是手机实机截图。
- 已执行的相关阅读回归包括行内代码、行内组件、颜色、对齐兼容和引用溢出测试共 73 项。最终定向编辑、阅读、明暗 Golden、主题与品牌资源共 62 项通过；严格应用静态分析无问题。完整门禁与构建结果见下表。

完整门禁初轮因线上已是 API `5.43.0-dev.20261022.3`、本次基线 `6f006450` 固定 `5.40.0-dev.20261018.1` 而停止。随后按既有 `-ContinueAfterFailure` 收集检查，仍保留生产版本失配为真实失败。初次静态分析误纳入 `build/` 下的临时上游比较源码，已移入隐藏 `.dart_tool/alignment-evidence` 保留证据；同时清理新测试 lint 和上游静态兼容问题；当轮全测在 204 项通过时主动停止，避免在旧源码继续重复测试。最终源码严格静态分析（518.8 秒）和定向回归通过后，重新运行完整入口。没有为通过检查改写或跳过生产契约校验，也没有混入其他任务尚未合并的新协议。

唯一预期条件跳过是 `test/core/diagnostics/diagnostic_live_receipt_test.dart` 的“显式验收：Sentry 接收一条脱敏诊断”：标准入口未设置 `WENYOU_VALIDATE_SENTRY=true`，按原条件跳过，未发送真实诊断。此项与下述原场景真机未验收分开记录。未提交候选逐文件摘要保存在 `build/alignment-source-snapshot.json`，最终文档写完后计算，基线提交不代表当前候选源码。

## 2026-10-23 完整检查历史

该轮命令为 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`；日志为 `build/alignment-final-full-gate.log`。整体退出码 **1**，唯一失败为生产契约版本失配，没有跳过或改写判定。以下保留历史证据，不代表同步契约后的新候选。

| 检查 | 结果 |
| --- | --- |
| OpenAPI 校验、固定契约来源、生成客户端一致性 | 通过 |
| 生产契约兼容 | 失败：本次基线 API 5.40，实际服务 API 5.43；精确版本见上文与日志 |
| Dart 格式 | 1435 文件，0 修改 |
| 应用及生成 API 严格静态分析 | 通过；应用分析 269.7 秒 |
| 架构、第三方完整性、模块文档 | 通过；23 个功能模块文档完整 |
| Mobile API 范围覆盖 | 175/175，0 缺失，73 项按既有规则排除 |
| 全量 Flutter 测试 | 7365 通过，1 项预期条件跳过，0 失败；42 分 36 秒 |
| Windows 发布工具测试 | 49 通过，0 失败 |
| Android ARM64 Debug 构建 | 成功；253.4 秒。仅诊断构建，整体门禁未通过，尚不满足正式候选交付条件 |

诊断 APK：`build/app/outputs/flutter-apk/app-debug.apk`，包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`（versionCode `100`），112827002 字节，SHA-256 `b1c0bd973ea3dd7fb3fff6d7486752275e552b470303940b066a20e8e9fe6c64`。没有安装或启动；没有生成发布签名包。构建保留原依赖 `flutter_image_compress_common` 的后续 Kotlin Gradle Plugin 迁移提示，本次没有改原生配置。

## 原候选历史：2026-10-24 完整门禁与验收安装包

已按负责人要求完整同步 Backend `bc1135b72557eb6025a541dbd10119cf528ff989`／API `5.43.0-dev.20261022.3`，并保留旧端未声明字体能力的兼容边界。新入口为 `npm run check:apk -- -TestConcurrency 2`，日志 `build/alignment-contract-final-full-gate-2.log`；同次完整门禁与构建成功，退出码 **0**。此前因临时 Backend 测试夹具遗漏字体来源而失败的一轮记录保留，不与成功记录混同。

| 检查 | 本轮结果 |
| --- | --- |
| OpenAPI、固定来源、生成客户端一致性、严格生产兼容 | 通过；交付前再只读复核，线上 SHA/API 仍一致 |
| 格式、应用及生成 API 严格分析 | 通过；1436 文件零格式修改，应用分析 99.4 秒 |
| 架构、第三方完整性、文档 | 通过；23 个模块 |
| Mobile API 范围覆盖 | 175/175，零缺失；91 项范围外，含 12 个管理字体操作和 6 个待独立接入的公开字体操作 |
| Flutter 全量测试 | 7367 通过、1 项原条件跳过、零失败，53 分 06 秒 |
| Windows 工具全测 | 49 通过、零失败 |
| ARM64 Debug APK | 同次入口构建成功，318.5 秒 |

安装包固定保存为 `build/wenyou-mobile-alignment-20261024-9fb5ab4.apk`：应用名“温油站 Debug”，包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`／`100`，仅 `arm64-v8a`，155627312 字节。SHA-256 为 `d1a5cb0002f0b45d20a7c2b2789a4854fdb2d4e8868a0f07bdb9e03cce264217`。编译输入完整源码树为 `9fb5ab4f0e7c2c6b2504ea9bb5a736dcb26f50e1`，记录见 `build/alignment-contract-build-input.json`；交付记录补充后仅文档变化，不重建同源码 APK。

默认 API 为 `https://wenyou.site/api/v1`，并非隔离环境。没有自动安装或启动，没有线上业务写入。构建保留既有 Kotlin 插件迁移及 SDK XML 版本提示，不影响本轮成功结果。该交付时点仍待真机验收；随后负责人已于 2026-10-24 明确验收通过并授权合并。没有部署或正式发布。

## 原候选历史：负责人复验清单

在当前候选的手机编辑器打开原问题正文，分别选中 H2/H3，切换居中、居右、恢复居左，确认字号、行高、上下段距保持。再检查连续标题、空段、粗斜体/颜色/代码组合，并撤销重做；保存和重开由负责人在所选业务环境自行操作。以上是原交付时提供的复验清单；负责人随后明确验收通过。本次基线集成的自动检查另记，不增加真机操作声称。

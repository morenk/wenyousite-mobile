# PR #76 最新基线整合候选验收

状态：候选／待负责人验收。当前记录替代历史候选作为本轮交付入口；历史失败、测试和 APK 信息保留在[原始问题记录](editor-angle-text-acceptance.md)，不算本轮证据。

## 授权、工作区与基线

- 治理任务 `01a15a3d-934f-7763-92f6-8c70545426e3` 传递负责人授权：将原修复整合到最新 dev，解决冲突并完成检查，更新原 PR，先不合并。
- Worktree：`D:\codex-worktrees\editor-guard-diagnostics\wenyousite-mobile`；分支 `codex/20260929-editor-guard-diagnostics`；旧 HEAD `d2e8f617da41d6c69da4425d74db1084a8dca9a8`。使用 `git merge --no-commit --no-ff origin/dev` 保留历史，不 rebase／强推。
- 再次 fetch 后基线为 `6f0064507a77e2034250ee4fd9f1d382e0a063a9`；HTTP 契约 `5.40.0-dev.20261018.1`，Backend revision `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`，与只读公网 `/meta` 一致；部署 Markdown v5，颜色能力与音频准入信息已返回。
- Backend 只读镜像已 fetch 并读取固定版本。Foundation 只读镜像已 fetch tags：最新 `v7.6.0` 仅扩展 Web 取色入口，Mobile 规则保持。本轮明确不扩展依赖或视觉实现，按授权保留 dev 已提交的 `v7.5.0` 与锁文件；不修改 Backend／Web／Foundation 源码。
- 实际审批：本轮 rollout `turn_context`（turn `01a15a6c-f55d-7463-9663-7b4748f115e2`）为 `approval_policy=never`、`approvals_reviewer=user`、`sandbox_policy.type=danger-full-access`，来源为本任务 `rollout-2026-09-29T01-41-11-01a0e91b-3d37-7262-9097-b117179a8756.jsonl`。默认偏好已传递，实际 Auto-review 尚未设置／未生效；分派工具没有配置入口，不擅改全局设置。

## 原问题与冲突处理

原楼层精确片段仍为 `[wenyousite-align-v1-center]: #` 后接 `*<\<Y/N \>\>*`，独立阅读语义是居中斜体 `<<Y/N >>`。旧宽泛 HTML 正则会使正文误入只读并让有效标记退为字面；本轮在最新 dev 的对应转换文件上重新确认失败，没有只依赖 9 月日志。

- 四个源码冲突按职责整合：`markdown_alignment.dart`、`markdown_content.dart`、`markdown_delta_codec.dart`、`markdown_delta_inline_encoder.dart`；保留后续颜色、音频、链接来源和角色提及语义，不选择整侧文件覆盖。
- 行内保护仍按 Markdown 实际消费顺序排除链接目标／标题，代码定界复用最新 `MarkdownInlineCodeScanner`。首轮定向验证发现 md.CodeSyntax 对已转义前置反引号的限制与共享扫描器不一致；已修正适配层，保留原扫描器及其回归。
- 自查补齐 Setext 标题：ParagraphSyntax 已消费正文、等下划线建标题节点时返回 null，仍应记录该正文的行内范围。修正前真实 HTML 漏判和代码协议误判均已复现；修正不扩展标题能力。
- 有效颜色标签按现有颜色契约校验后排除普通 HTML 拦截；坏颜色、嵌套原始 HTML 仍保护。编码保留真实颜色，同时保证实体产生的可见标签文字不会变成颜色或 HTML。未改变颜色协议规则。
- 颜色链接的兼容源码与实体解码文字分别处理：`MarkdownDeltaRichLines` 给已解析的标签形可见文字标记字面来源，编码器保留未经字面转换且通过现有颜色契约的源码，避免把既有 title／相对链接保源策略改成转义输出；完整颜色标记作为实体文字时仍不变成真实样式。
- 摘要沿用 dev 新的结构化解析、颜色、身份映射与 Unicode 截断；只消费有效对齐元信息，无效定义转为字面，保留代码中的标记。
- RichEditorSession 自动合并保留音频投影与公共发布准备调用；打开拦截去重拆至 `EditorOpeningDiagnostics`，主文件维持 900 行且不增加架构豁免。诊断原因白名单、同会话去重与正文不上报不变。
- CHANGELOG 与 editor/posts/search/settings/threads 文档保留双方内容并更新当前事实；发布准备、后续功能和历史验收记录均保留。

## 本轮验证

所有日志位于本 Worktree 的 `build/editor-integration-20261021/`；自动化没有发帖、上传、删除等线上业务写入，没有安装应用、关闭 Sentry、部署或发布。

- `old-red.log`：在当前 Worktree 临时加载最新 dev 的五个转换文件，运行原角括号与协议元信息两个测试文件，20 项通过、47 项失败，测试命令退出 1。通过 `finally` 将候选源码逐字恢复并核对摘要，未修改其他 Worktree。
- `focused-first.log`：首轮 189 项通过、1 项共享扫描器边界失败，退出 1；失败日志保留，不放松原断言。
- `focused-scanner.log`：修正后代码／容器保护、原样例、元信息、整合组合及打开诊断 97 项通过，退出 0。
- 第一轮定向包含：`test/core/markdown/{markdown_angle_text,markdown_metadata_protocol,markdown_inline_code_scanner,markdown_plain_text_preview,markdown_text_color,markdown_link_identity}_test.dart`、`test/features/editor/{editor_angle_integration,editor_open_diagnostics,editor_publish_preparation}_test.dart`、`test/features/posts/{post_composer_angle_text,post_composer_open_diagnostics}_test.dart`。命令及结果保存在 `focused-final.log`。
- `focused-final.log`：191 项通过，退出 0。`analyze-initial.log`：首轮全量分析发现合并后的一个 import 排序提示，退出 1；已经按字母顺序整理，完整门禁再核验。
- 旧完整原文临时文件已不存在；本轮重新只读 GET 原楼层，返回仍为 version=1、2813 字符、9 个居中标记，含相同精确片段。完整内容仅存忽略的本机验证目录，不进入仓库或诊断。
- `setext-red.log`：新增 10 个 Setext 对照用例在修正前为 2 项通过、8 项失败，退出 1。首轮 `check-apk-01.log` 在客户端重新生成阶段主动停止，未作为最终门禁证据；其子进程均已结束，再以最终源码执行门禁。
- 最终补测还包含 `test/core/markdown/markdown_inline_code_protection_test.dart`、`test/core/markdown/markdown_container_code_protection_test.dart` 和本机 `build/editor-integration-20261021/original_current_test.dart`。全文测试对原文输入「确认」后保存重开，直接核对完整可见文字、全部字符的可见样式和 9 个居中块。
- `focused-setext-first.log` 保留 215 项通过、1 项临时全文测试失败：原断言要求输入后内部 Delta 分段与来源标记完全一致；实际文字和样式断言已通过。改为逐字符比较可见属性，不把合法的内部来源分段变化当成产品故障，产品源码未因此修改。
- `focused-setext-final.log`：Setext 修正阶段的全部定向及全文验证 216 项通过，退出 0；后续颜色保源回归修正另有新一轮证据。
- `check-apk-02.log` 在 API build_runner 首个生成步骤连续数分钟无进度，进程 CPU 基本不变；主动停止，不能算通过。确认仅本任务进程结束后，校验绝对路径并用官方 `dart run build_runner clean` 清理本 Worktree `packages/wenyou_api/.dart_tool/build` 中的旧生成缓存，退出 0（`api-cache-clean.log`），未删除源码或更改依赖。随后同一入口重新运行，日志 `check-apk-03.log`。
- `check-apk-03.log`：重新编译生成器后 API 生成一致性、固定／公网契约及格式检查通过；应用分析因新增 Setext 测试的一处多余插值花括号提示退出 1。只整理测试语法，产品实现不变；Setext 10 项独立复核记录在 `setext-final.log`，下一轮完整门禁另存 `check-apk-04.log`。
- `check-apk-04.log`：格式、应用／生成客户端分析、架构、文档、API 覆盖及契约校验全部通过。全量测试在 4,161 项通过、1 项跳过时发现颜色链接保源的 2 项失败，主动停止并保留日志，未构建 APK。`color-baseline.log` 用最新 dev 的五个转换文件复核对应两个测试文件，42 项通过后逐字恢复候选，确认是本轮新增转义引入的回归。修正时未改变这两项既有测试断言。
- `focused-color-final.log`：颜色保源修正后 470 项通过，退出 0。相比前轮，加入 `test/core/markdown/markdown_delta_codec_test.dart`、`test/core/markdown/markdown_alignment_compatibility_test.dart`、`test/features/editor/editor_text_color_audio_integration_test.dart` 和 `test/features/editor/editor_text_color_roundtrip_test.dart`，并增加完整颜色标记实体文字的普通／斜体两种回归；完整原楼层与实际页面保存重开也重新执行。
- `check-apk-05.log`：检查到全量测试 892 项通过、1 项跳过时，先停止门禁，再补充与本次来源标记直接相关的取消格式边界；未在运行期间修改验证输入。本轮不能作为最终门禁证据。
- `remove-format-red.log`：通过实际工具栏格式策略取消部分加粗正常，取消代码格式后保存失败（1 项通过、1 项失败）。代码内部的标签形文字也需保留字面来源，取消代码属性后才不会被当成真实颜色。最初测试误用了不存在的 Attribute.code，编译失败单独留在 `remove-format-compile-failure.log`，修正为实际 Attribute.inlineCode 后才记录上述产品回归。
- `focused-frozen.log`：集中修正后的同组定向与原楼层全文共 472 项通过，退出 0，包含两项通过工具栏取消格式再保存重开的回归。此后冻结应用源码、测试、契约、依赖和检查工具，再执行 `check-apk-06.log`。
- `check-apk-06.log`：全部前置检查通过；全量 Flutter 测试为 7,404 项通过、1 项跳过、1 项失败，门禁退出 1，未进入 Windows 工具测试和 APK 构建。唯一失败为 `test/features/thread_feed/controlled_cover_animation_test.dart` 的「可见即加载，资源就绪立即显示且完整保留首帧时长」：等待 150 毫秒解码后仍是上一帧。该文件和动画实现与最新 dev 无差异；保持冻结源码单独运行整个文件，`cover-animation-recheck.log` 为 12 项通过、退出 0。单次复核不能证明失败根因，不将它替代完整门禁结果；保留失败记录，再以仓库默认并发 1 执行 `check-apk-07.log`，减少资源争用，未改动动画代码或断言。
- 冻结 Git 树：`0b7b04c793852e380f1062b96185b4204a0b4330`，门禁结束后以该树核对除 `docs/**` 外的全部跟踪文件，确保补记记录没有改变验证输入。
- 新增组合回归直接核对文字、空段、居中／斜体／颜色属性和编辑行归属，覆盖实体标签、代码内协议示例、可信独占音频与相邻同 URL 双链接、身份摘要映射，以及公共发布准备的成功／保护阻止路径。实际楼层页面继续执行打开、输入、保存、重开；所有保存落在本地假仓储。
- `check-apk-07.log`：完整 `npm run check:apk -- -TestConcurrency 1` 于 2026-10-21 04:43（Asia/Shanghai）结束，退出 0。应用与生成客户端分析零问题，格式、架构、文档、API 覆盖、固定／公网契约及生成一致性均通过；Flutter 全量 7,405 项通过、1 项跳过，Windows 工具 49 项通过，ARM64 Debug APK 构建成功。跳过的是既有 `test/core/diagnostics/diagnostic_live_receipt_test.dart` 的显式 Sentry 收件验收，本轮没有开启真实发送。上一轮封面动画失败在本轮全量中通过；失败记录保留，不能据此断言已消除所有时序波动。

## 最终门禁与候选包

本轮应用源码提交为 `474285904863cd3380ee8f9f318928ccd06a4c7a`，是保留旧候选和最新 dev 双亲的 merge 提交；随后仅补充本记录中的提交号，不改变已验证源码。门禁及构建结束后，与冻结树 `0b7b04c793852e380f1062b96185b4204a0b4330` 比较除 `docs/**` 外全部跟踪文件，差异为零。远端 dev 再核验仍为 `6f0064507a77e2034250ee4fd9f1d382e0a063a9`；契约、生成客户端、依赖及架构豁免与该基线无差异。

- APK：`D:\codex-worktrees\editor-guard-diagnostics\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`
- 应用：`温油站 Debug`；包名 `site.wenyou.app.debug`；versionName `0.10.0-debug`；versionCode `100`；仅 `arm64-v8a`。
- 大小：112,839,242 字节；文件时间：2026-10-21 04:43:06 +08:00。
- SHA-256：`933BBF78565D29B92829AEAAE36B419D3981BC10E0E6E3DD3B59DD698FB63603`。
- `aapt dump badging` 与 `apksigner verify --verbose` 退出 0，v2 签名有效。本轮未安装；旧 9 月 APK 不作为本轮证据。
- 构建保留基线插件 `flutter_image_compress_common` 关于未来 Built-in Kotlin 兼容性的提示，本轮构建成功，没有扩大为依赖升级。
- 2026-10-21 04:43 本任务门禁及构建已结束，重资源执行槽已释放。

最终定向命令为 `flutter test --no-pub --concurrency=2 --reporter expanded` 加以下路径，472 项通过；`focused-frozen.log` 和完整门禁日志均对应同一冻结源码：

```text
test/core/markdown/markdown_angle_text_test.dart
test/core/markdown/markdown_metadata_protocol_test.dart
test/core/markdown/markdown_inline_code_scanner_test.dart
test/core/markdown/markdown_inline_code_protection_test.dart
test/core/markdown/markdown_container_code_protection_test.dart
test/core/markdown/markdown_plain_text_preview_test.dart
test/core/markdown/markdown_text_color_test.dart
test/core/markdown/markdown_link_identity_test.dart
test/core/markdown/markdown_delta_codec_test.dart
test/core/markdown/markdown_alignment_compatibility_test.dart
test/features/editor/editor_angle_integration_test.dart
test/features/editor/editor_open_diagnostics_test.dart
test/features/editor/editor_publish_preparation_test.dart
test/features/editor/editor_text_color_audio_integration_test.dart
test/features/editor/editor_text_color_roundtrip_test.dart
test/features/posts/post_composer_angle_text_test.dart
test/features/posts/post_composer_open_diagnostics_test.dart
build/editor-integration-20261021/original_current_test.dart
```

## 负责人复验与未覆盖项

本轮不安装或接管设备，未取得原手机场景验收或真实 Sentry 收件证据。标准 Debug 的本地诊断测试与模拟发送不能证明线上收件。

1. 负责人在本轮候选中只读打开原楼层，确认居中斜体 `<<Y/N >>`、有效标记隐藏、进入编辑不误入保护。
2. 在已核验的独立写入环境复制原输入，输入、保存并重开，核对空段、段落归属与样式；补验颜色、音频和相邻链接。
3. 对真实不支持的 HTML 核对原文保护、问题编号和复制详情；在启用 Sentry 的验收构建核对同一编号收件，关闭发送后仅保留本地记录。
4. 验收前保持候选状态，不合并到 dev/main，不关闭原问题。

# 尖括号误判与对齐标记外露候选验收

状态：候选／待负责人验收。继续同一楼层问题，保留此前打开拦截诊断；没有改写线上楼层、合并或发布。

## 原始输入与已证实根因

原始楼层为 `cmulh9bx501937qm7tan1vyxs`，只读取得 version=1 的完整 Markdown（2813 字符）。此前现场与 Sentry 区分见[诊断候选记录](editor-open-diagnostics-acceptance.md)。实际第 87、88 行为：

```markdown
[wenyousite-align-v1-center]: #
*<\<Y/N \>\>*
```

独立 Markdown 阅读语义是居中斜体 `<<Y/N >>`。旧实现把 `<[^>]*>` 视为 HTML，导致正文被误判不支持、前一行有效居中标记失效，阅读和编辑退回字面源码，编辑器进入只读保护。完整原文只在本机临时目录使用，不写入产品日志、诊断或仓库。

## 实现与覆盖范围

- 共用实际 Markdown 行内解析消费范围判断 HTML、行内代码和链接目标／标题；按原始偏移映射回行。标题、引用／列表容器、跨行代码与跨行 HTML 均纳入判断，删除两套独立尖括号正则和不一致的代码遮罩。
- 有效对齐标记只作为块属性，覆盖段落、H2/H3、Setext H2、LF／CRLF。保留文字、空格、斜体、空段和实际编辑行归属。
- 普通比较符、中文尖括号、奇偶反斜杠、HTML 字符实体、邮件／URI 自动链接、链接标题中的标签或协议示例不会仅因形似 HTML／协议而拦截。
- Delta 协议节点扫描也复用同一范围；链接目标／标题、URL 和代码里的骰子／提及示例不提升为活动节点，链接标题的示例不会占用正文真实骰子的身份。Quill 没有 title 字段，带 title 的普通链接仍按既有策略保留完整源码以免丢失元数据；不伪装成已支持所有链接富文本编辑。
- 从实体解码得到的 `<tag>`、注释及 `<br />` 是可见文字，保存不能重新解释为 HTML 或空段；整行兼容源码仍仅由原有块出口转义一次。
- 正文非空判断和紧凑摘要不吞掉普通尖括号。摘要只去掉生效的对齐标记，保留代码、转义、孤立或损坏协议的字面内容。
- 真实 HTML（标签、属性、注释、处理指令、CDATA、跨行标签）、不闭合代码外的 HTML、未知／损坏协议、对齐到不支持块等仍按契约保留并只读保护，上报白名单原因。保留这些字面标记是契约的数据保护，不能通过删除原文掩盖。

本次不新增 Markdown 能力、不更改后端或 Foundation 契约。链接标题的 HTML／协议检测修正不表示扩展 Quill 对所有链接元数据的编辑能力；最终语义校验仍保留。代码块、表格、第四层列表、损坏扩展节点等既有不支持状态不因这次修复变为可编辑。

仍可能看到类似控制符的来源必须区分：未知版本、孤立／错位标记和不支持的目标块属于受保护的旧源码；代码或转义中的标记属于可见字面文字；历史内容若已把标记作为转义正文保存，也不能仅凭长相自动删除。本次修正的是合法元信息被误判后外露，不执行历史数据清洗，不把所有含 `wenyousite-` 的用户文字隐藏。

另已核对编辑能力边界：未启用所需能力、未知 Markdown profile 或无法无损往返，也可能进入原文保护。这些路径分别记录 `missing-feature`、`unknown-profile`、`lossy-roundtrip`，不能与本次尖括号误判混为一类；既有能力缺失与错误原因白名单测试继续覆盖。

## 契约与风险

基线 `origin/dev=f551d3eb`；本地、远端记录及公网 `/meta` 的 Backend revision 均为 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`，契约 `5.27.0-dev.20260927.1`，公网 Markdown v5，无契约漂移。沿用 `codex/20260929-editor-guard-diagnostics` 与 PR #76 继续原问题。共享 Codec 影响多个创作入口，本次按高风险验证，完整门禁和 APK 完成后才交付候选。

## 自动验证与候选证据

- 旧实现回归日志：`build/editor-open-diagnostics/angle-before.log`。原片段的 unsupported 判定、普通尖括号、代码／标题范围、链接元信息、跨行 HTML 和非空判断存在失败；其中一个构造用例最初错误地把已闭合单反引号当作未闭合，已按独立 Markdown 语义修正，不算产品失败证据。
- 精确核心回归：`test/core/markdown/markdown_angle_text_test.dart`，预期取自原始输入与独立 Markdown 阅读解析，并直接断言可见文字、斜体、居中块归属、空行和保存重开；不用 Codec 输出反推预期。
- 真实页面回归：`test/features/posts/post_composer_angle_text_test.dart`，通过实际楼层长按编辑入口，阅读核对文字、斜体及居中，打开后在原片段中输入、保存到本地假仓储、重开，核对空段与样式且无误报。没有调用线上写接口。
- 原诊断用例改用真实 HTML，保留只读、复制、去重、发送开关及隐私断言；原片段正常编辑不再上报打开错误。
- 完整原文在本机 `build/editor-open-diagnostics/original_floor_test.dart` 复核，脚本不提交；精确片段与扩展边界测试可在仓库独立运行。
- 定向验证命令：`flutter test --no-pub test/core/markdown/markdown_angle_text_test.dart test/core/markdown/markdown_delta_codec_test.dart test/core/markdown/markdown_alignment_compatibility_test.dart test/features/posts/post_composer_angle_text_test.dart build/editor-open-diagnostics/original_floor_test.dart --concurrency=2 --reporter expanded`，257 项通过；日志 `build/editor-open-diagnostics/angle-final-focused.log`。完整楼层 9 个居中块有效，无保护／误报，目标文字和样式正确，保存重开 Delta 一致。
- 随后增加自动链接路径中的协议示例和跨行代码的非空判断；独立 `markdown_angle_text_test.dart` 最终 48 项通过，日志 `angle-url-scope.log`。前一轮全 Markdown 定向检查的两项裸 Delta HTML 规范拼写回归已修正，后续定向与完整门禁继续覆盖，没有放松其断言。
- 第一轮 `npm run check:apk -- -TestConcurrency 2` 在公网只读核验连接长期无结果后中止；原日志 `angle-check-apk.log` 保留。代理、直连与 Tailnet 的独立只读请求也超时，未修改系统代理或服务。
- 最终门禁使用同一入口加 `-ContinueAfterFailure` 收集完整结果，仅该子进程的 `NO_PROXY` 增加 `wenyou.site`；该参数不会把失败改成成功。最终记录见下文，原始日志保留。
- 公网核验明确输出连接超时后进程仍不退出，经父进程链核验后结束的仅是本任务该核验子进程，门禁保留失败并继续收集结果。
- 补充真实组件画面 `build/editor-open-diagnostics/angle-editor.png`，已查看：阅读与编辑均呈现居中斜体正文，无控制标记和错误提示，提交按钮可用。这是本地假仓储的 Widget 画面，不冒充原手机截图。生成画面的临时 Dart 脚本被全量分析纳入，产生两条 import 排序提示；仅整理该临时脚本导入后单独复跑全量分析，产品代码不变。
- 扩展检查确认旧节点扫描仍把链接标题／URL 里的未知骰子示例误判为节点；`metadata-atoms-before.log` 三项失败，修正范围消费后对应三项通过。最终新增 `test/core/markdown/markdown_metadata_protocol_test.dart` 覆盖合法与未知骰子、全体玩家提及、代码／链接／自动链接和真实正文节点。带 title 的三项测试最初误期望 Quill 丢弃标题后只显示标签，已按既有保留策略改为明确断言完整源码与 title 不丢失，同时独立核对阅读标签。
- 前一轮全量门禁在 2,966 项通过、1 项跳过时因上述新增修正主动停止，不能代表最终源码。最终精确命令：`flutter test --no-pub test/core/markdown/markdown_metadata_protocol_test.dart test/core/markdown/markdown_angle_text_test.dart test/core/markdown/markdown_inline_code_protection_test.dart test/core/markdown/markdown_container_code_protection_test.dart test/features/posts/post_composer_angle_text_test.dart build/editor-open-diagnostics/original_floor_test.dart --concurrency=2 --reporter expanded`，83 项通过，日志 `angle-final-regression.log`。最终源码完整门禁另存 `angle-check-apk-candidate.log`，不复用中途检查作为通过证据。
- 最终应用源码 SHA-256 摘要：`e8b1c286588ca6e7e5565dcef626e2b5bfa37a23596efe0dd748d956d05bdb48`，由仓库 `sourceEvidence` 按应用源码路径计算，包含本次尚未提交的修改。文档补记不会改变此摘要。
- 公网连接恢复后单独重跑原失败项 `npm run api:verify:production`，退出码 0；日志 `angle-public-recheck.log` 确认 API／契约包 `5.27.0-dev.20260927.1`、Backend revision `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`、部署 Markdown v5 及公开主题响应兼容。本次初始门禁的超时与非零退出仍保留，不改写成一次执行全部成功。
- 最终完整运行 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure` 返回 1，仅上述公网初次连接超时失败；其余格式、应用／生成客户端分析、架构、模块文档、API 覆盖、固定契约与生成一致性全部通过。Flutter 全量 5,075 项通过、1 项真实 Sentry 收件测试按默认配置跳过；Windows 工具 67 项通过、0 失败；同次 ARM64 Debug 构建成功。公网失败项已经单独复验通过，未为瞬时网络故障重复全部已通过的应用测试，也不声称该单次命令退出成功。
- 在最终应用源码上重新执行 `flutter test --no-pub build/editor-open-diagnostics/angle_screenshot_test.dart --concurrency=1 --reporter expanded`，1 项通过，日志 `angle-visual-final.log`；重新查看生成画面，文字、居中斜体、空段及可用的编辑状态正确，无控制标记或只读错误提示。

## 当前本地 Debug 包

- 路径：`D:\codex-worktrees\editor-guard-diagnostics\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 包名 `site.wenyou.app.debug`，应用名「温油站 Debug」，版本 `0.8.0-debug`，构建号 `97`；仅 `arm64-v8a`。
- 构建产物时间：2026-09-29 05:48:03（北京时间）；大小 `109439806` 字节；SHA-256 `53203937e29466ab1c01afe229677216394d5ea9e24c5e514f8394c5d89e08c2`。
- `apksigner verify --verbose` 通过，APK Signature Scheme v2、1 个签名者；同时核对包内 kernel 确实包含本次 `MarkdownInlineSource` 实现。
- 当前无 ADB 设备，未安装、未启动持续 Debug，也没有设备内 APK 哈希。负责人复验时应打开「温油站 Debug」，不能凭相同构建号把 Release／Profile 当成本候选。

## 真机步骤与未验证项

当前 ADB 未连接设备，未启动持续 Debug、安装 APK 或取得负责人验收。标准 Debug 未注入私有 Sentry DSN，不以本地记录和模拟发送宣称远程已收件。

1. 打开原楼层，确认目标位置显示居中的斜体 `<<Y/N >>`，无对齐控制标记或转义斜杠；长按进入编辑，不出现只读保护提示。
2. 在已核验的独立预览环境复制相同输入，编辑其中一字、保存并重开，核对全文空段、9 个居中块、标题和其余格式。线上原楼层只读复验，不由自动化写入。
3. 分别复核普通尖括号、实体标签文字、代码内协议示例，以及确实不支持的 HTML；正常正文不误报，不支持内容保留原文并可复制问题详情。
4. 用已启用 Sentry 的验收构建核对真实拦截的同一问题编号；开关关闭后只保留本地诊断。主题／子贴与搜索摘要补做真机冒烟。

自动检查及本地假仓储保存不能替代负责人对原问题的真机验收；未验收前不关闭原问题。

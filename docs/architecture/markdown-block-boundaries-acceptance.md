# 富文本块边界跨端候选验收

## 当前状态与范围

2026-09-11 后续授权：用户已明确授权本轮合并与部署，用于先在公网 Web 验证。Backend PR #17 合并为 `5b766305e21d2a39bd53bb0c3aacc05fad81152f` 后，Mobile 通过既有同步脚本更新来源元数据，契约内容不变。公网与 Mobile 合并结果见“合并来源同步与公网复核”。下述冻结候选及历史门禁记录保留原始 revision 和结果，不将合并授权视为负责人验收通过。

2026-09-11：候选实现／本地验证与 Debug APK 已交付／待负责人验收。任务分支 `codex/20260911-markdown-block-boundaries` 从 fetch 后的 `origin/dev`（`dbba204dd5d43252a400ff50a4db7348415d62f3`）建立，独立 Windows Worktree 为 `C:\Users\quhui\.codex\worktrees\202d\wenyousite-mobile`。已同步 Backend revision 2 并补充消费者实现与回归；原 revision 1 的 8 项空白行预期已在共享版本中修订。完整门禁仅公网部署 revision 检查失败，详见最终验证；不能视为原问题修复完成。

目标是统一已有 Markdown v5 对齐块边界并保护阅读、编辑、保存重开、草稿和剪贴板链路。不扩大格式或 URL 白名单，不迁移旧内容，不修改 HTTP 字段、字体、Foundation 视觉规范、摘要紧凑规则或段内粘贴继承目标段落对齐的行为。

已记录后端与公网 `/meta` 均为 `0ee2c0de1d9c570e495e778be6661b074b7a4bef`，HTTP 契约 `5.20.0-dev.20260909.1`，公网 Markdown v5。共享 fixture 锁定 Backend `a91cbb8b605223c596af299be22c5547f69e25b9`，v1 revision 2，SHA-256 `822509411fbf3379847a04ec64a4a32ddb1bb8fb96aecbf38b395b049134fda9`；这是未部署的任务契约，公网仍为前述 revision。

## 原始复现与独立证据

原楼层通过只读 GET `/api/v1/posts/cmtvt31qc00497qc2xwuu6ama` 取得。首个触发片段为 `经历：`、单 LF、`[wenyousite-align-v1-center]: #`、单 LF、H2 标题；marker 前没有空行。治理任务报告 Web 有一个 marker 泄漏；Mobile 原截图正常，不能把 Web 根因当作移动端已证实缺陷。

- 对原楼层完整正文执行现有 `MarkdownAlignmentContract.analyze`：32 个有效对齐块、0 个无效 marker。Codec issues 为空，Delta 正文无隐藏 marker。
- `wenyou_markdown_block_boundaries_test.dart` 保留相同字符／换行边界并用短目标正文替换标题，覆盖 center/right × P/H2/H3：验证源码位置、独立阅读块、实际样式和可见文字，无 marker 泄漏。6 个 Widget 回归在未修改生产实现时通过。
- 现有 `markdown_alignment_compatibility_test.dart`、`markdown_delta_alignment_compatibility_test.dart`、`markdown_v5_image_alignment_contract_test.dart` 共 114 个测试通过。
- 原截图第二幕后的手工空格排版片段，以原始正文截取首个 `﹁` 至 `﹂` 所在行：现有 Codec 编码结果与原文逐字符相等，issues 为空。该片段含行首／行中／尾部 ASCII 空格与 U+2060；原始间隔保持，未使用近似排版字符串替代。

原楼层全文和临时审计日志仅保留在本机临时目录／忽略的 `build` 目录，不提交完整用户正文。上述证据不代替真实页面编辑、真机视觉或负责人验收。

## 已证实差异与待交接语义

1. 直接分析 CRLF 的 `before\r\n[wenyousite-align-v1-center]: #\r\n## title` 时，分析器返回 0 个有效块；Codec 会先规范化，因此该路径仍正确。需要统一入口的换行语义。
2. `<div>` 与 `</div>` 之间的 marker 被分析器消费，Codec 给其中标题附加对齐。需按共享 fixture 保护多行 raw HTML。
3. 首尾各一个反引号、内容为 `before`、marker、`title` 三行的合法行内代码，在独立完整 Markdown AST 中是一个 code 节点；现有分析器却消费 marker，Codec 丢失该字面行。需保护跨行 code span。
4. 围栏和四空格缩进代码的已审计样例均未消费 marker。治理已明确：保护区外第 0 列的精确合法 marker 结束引用／列表 lazy continuation；显式引用或缩进 marker 仍为非法嵌套。等待 fixture 固定具体组合。

## 候选实现与自动证据

- 对齐分析、空段恢复和不支持语法判定复用实际 Markdown 块／行内 code 消费范围；URL 和 title 中的反引号不误配。代码保护只覆盖实际代码行，相邻合法 marker 仍独立生效；跨行 code 按 CommonMark 显示为一个 code span。
- 合法 marker 前的正文获得独立段落边界，避免保存时与对齐目标合并。CRLF 入口与 LF 统一，现有分隔线等价写法规范为 `---`。不扩大格式白名单。
- 跨行代码未修改时保留源码，Quill 插字产生的来源属性拆分按连续代码样式统一编码。纯文本复制识别 v5 图片对齐，隐藏 marker 和媒体地址不进入外部文本。
- 来源空格保护属性仅存在于内存；保存、草稿和剪贴板仍以 Markdown 为事实内容。原三列片段的行首、行中、行尾空格及 U+2060 保存严格逐字符相等；真实输入只增加对应字符。阅读断言按治理确认的 CommonMark 规则移除首个 U+2060 前 1～3 个段落缩进空格，U+2060 后的作者空格严格保留；未调整移动端布局。
- 真实楼层页 4 个编辑样例均覆盖打开、IME 输入、保存和三轮重开；另覆盖原始三列、单 LF 空格保护和 emoji／不换行空格／全角空格。使用真实 Drift 内存数据库验证快照写入、读取与编辑会话恢复，覆盖站内结构复制及外部纯文本降级。
- 对同一组 13 项真实页面／草稿／剪贴板测试，临时恢复 `8b6c9ec` 的旧生产文件后执行：2 通过、11 失败；finally 按原字节恢复候选。旧实现通过的 2 项是原三列片段与 emoji 原有行为，不能将其称为已修复。候选 13 项全部通过，日志分别为 `build/block-boundary-original-flow-failures.log` 与 `build/block-boundary-flows-2.log`。
- 扩展回归首轮 782 通过、9 失败：8 项为官方 revision 1 空白行预期，另 1 项为新增跨行 code 插字保存问题。随后修复此问题及代码相邻块范围，15 项精确回归通过（`build/block-boundary-code-ranges.log`）；完整门禁结果另记下文。
- 新契约有 208 项案例；支持路径逐项核对原始 marker/start/end 行号、可见行、块类型和对齐，再校验保存重开语义及第二次保存稳定。`serialized` 是合法参考，不强求跨端字节相等。真实 WenyouMarkdown 阅读覆盖 173 项后端合法案例及原三列片段。

## 跨行代码与相邻块的最小反例

下列使用 JSON 字符串表示精确输入，`\n` 表示单 LF。行号从 0 开始；代码内 LF 的可见语义为空格，代码外边界保持独立。

| 精确输入 | 预期可见行 | 逐行对齐 | marker/start/end |
| --- | --- | --- | --- |
| `"前文\n[wenyousite-align-v1-center]: #\n\u0060甲\n乙\u0060"` | `前文`、`甲 乙` | left、center | 1/2/3 |
| `"\u0060甲\n乙\u0060\n[wenyousite-align-v1-center]: #\n正文"` | `甲 乙`、`正文` | left、center | 2/3/3 |
| `"[wenyousite-align-v1-center]: #\n\u0060甲\n乙\u0060"` | `甲 乙` | center | 0/1/2 |
| `"\u0060甲\n乙\u0060 和 \u0060丙\n丁\u0060\n[wenyousite-align-v1-center]: #\n正文"` | `甲 乙 和 丙 丁`、`正文` | left、center | 3/4/4 |

候选开发中曾把整个原生 paragraph 作为跨行 code 合并范围，前两例让合法 marker 进入编辑文字。修正后只合并实际 code 占用行；同一行结束并再次开始的 code span 合并范围以保持一次正确解析。四例独立断言可见文字／对齐／保存重开；已交给治理并进入 Backend revision 2，共享消费结果已通过。

## 最终补充回归与验证边界

追加保存阻断前的相关回归 `build/block-boundary-final-focused.log`：433 项全部通过。`test/fixtures/markdown-block-boundary-mobile-output.json` 固定 208 份 Codec 输出、14 份真实楼层页面 IME 提交和 3 份真实 Quill 输入后会话 flush 输出，共 225 份；不包含完整原楼层正文。Backend 独立接受验证与最终统一门禁结果见下文。

- revision 2 的 208 项共享案例全部执行；结合精确边界、三类真实 Quill 容器输入与真实阅读共 404 项通过（`build/block-boundary-rev2-reader.log`）。
- 完全显式引用与缩进列表跨行代码、引用／列表嵌套围栏及缩进代码共 5 项负例，核对 marker 不被误报或消费、完整字面文字、代码／容器属性及保存稳定；结合原有格式策略共 16 项通过（`build/block-boundary-explicit-containers.log`）。保留旧列表 0～2 级可编辑能力，第 3 级仍按既有边界拒绝。
- Dart 7.3.1 引用收集器误把链接定义作为 lazy paragraph 中断；候选以实际前块类型与 `canEndBlock` 判断延续。保护器的包装语法经共享 Document 传入嵌套解析器，引用使用实际去前缀子行回调，列表只在原生已消费容器内顺序核验完整子行来源。标题／围栏后的 marker 不能被吸入引用。
- 阅读投影只把实际跨行 code span 内的 LF 变为空格，并消除该 span 的容器续行前缀，避免自定义空段语法打断代码。原持久化 Markdown 不受影响。文字断言遍历实际 Element、InlineSpan 与 WidgetSpan 子树，按显示顺序拼接且避免重复计数。
- `backtick-link-title-later-code` 与 `backtick-link-title-multiline-code` 维持原有 Mobile 链接 title 源码降级：严格验证完整原链接／title、对齐边界及保存重开；原文阅读按共享文字验证。本次不新增 title 编辑能力，也不删掉这两项。共享 `supported` 表示后端合法，不代表全部客户端都支持该链接元数据的富文本化。
- 首次统一门禁在 revision 1 上记录 8 项已知 fixture 失败及 1 项旧二级列表回归；后二者分别随 revision 2 同步与候选修正消除。另有临时 `build` 审计 Dart 文件的 19 项 lint 和测试 1 项花括号提示，已移走审计脚本并修正。全量测试报告到 2752 项通过后结果收集停滞数分钟，无 tester 且 runner/compiler CPU 不变，已核实 PID 后终止该停滞测试进程；该轮保留为失败记录，不能作为最终全绿证明。

共享序列化输出由测试写入 `build/mobile-block-boundary-serialized.json`，分别标记普通支持、既有 link title 降级和不支持源码降级；`editorLines` 是编辑器实际可见行。最终语料经 Git 交给 Backend 校验发布可接受性，不能以 Codec 自洽代替此证据。

公网 `/meta` 仍为 `0ee2c0d`，候选契约 `a91cbb8` 尚未部署，因此统一门禁的公网 revision 检查预计继续失败，必须单独记录。未安装 Android 候选包，未取得负责人原场景验收，Web → Android → Web 登录链路仍待手测；Widget/Drift/剪贴板替身不代替设备或线上验证。
## 保存阻断与最终收口补充

治理从 VPS 只读 Mobile 镜像取得 `db744dc` 的 225 份实际输出，使用 Backend 共用 validator 独立校验：224 份接受，唯一 `unsafe-target` 按 `unsafe-link`、第 3 行拒绝；14 份真实页面提交与 3 份真实 Quill flush 全部接受。该负例由 Codec 保留作为编辑源码，不是可发布保存结果，产物已显式标记 `expectedBackendAccepted: false` 及 `expectedError`。

针对该负例新增真实会话与楼层提交入口回归，在 `db744dc` 上 2 项均失败：flush 返回 true，页面确实调用了写仓储。候选追加 `MarkdownSubmissionGuard`，在会话发布 Markdown 之前遍历实际 AST，复用 `MarkdownContent.isSafeLink/isSafeImage` 拒绝不允许的 URL scheme；保留可修改正文，失败时不发布变更、不发送写请求。代码、完整转义字面文本及既有站内地址分别回归，不扩大白名单。原失败记录为 `build/block-boundary-unsafe-original.log`。

Backend `169b336` 独立确认：仅转义链接括号但保留裸 `ftp://example.com` 时，GFM 仍产生自动链接，仍应拒绝；裸 FTP 和显式 FTP 链接也拒绝。因此将最初错误的“部分转义即可通过”测试预期改为拒绝，另用编辑器现有完整标点转义的文本验证允许保留字面示例。未为测试放宽 URL 策略。

第二轮统一门禁 `build/block-boundary-final-check.log`：应用和生成客户端分析、格式、文档、架构、API 覆盖、生成一致性及 Windows 工具测试通过，Debug APK 构建成功；全量有 3 项失败，分别是旧引用布局 Golden 与运行中新增的 unsafe-target 两个旧行为断言。修正发生于本轮启动后，该轮不能代表最终 clean 候选。

已查看 Golden 的 master/test/maskedDiff：通用引用收集器使普通 lazy 正文进入旧引用布局。恢复既有阅读 QuoteLineSyntax，仅在源码保护中保留容器适配，并使用真实 code 范围的阅读投影；不更新旧 Golden。后续独立专项 `build/block-boundary-final-candidate-regression.log` 450 通过，仅上述部分转义预期失败；纠正后 `build/block-boundary-guard-golden-verified.log` 的 19 项（含真实 flush/不发写请求、旧 Golden 与安全正负例）全部通过。新增裸 FTP／HTTPS 数据点随最终稳定树全量覆盖。追加实现静态分析零问题（`build/block-boundary-guard-analyze.log`）。

最终统一门禁在追加提交后固定源码串行执行，前述运行中修改日志均作为过程证据保留。

## 最终冻结候选验证与安装包

2026-09-11 06:42～06:55（Asia/Shanghai），在干净代码提交 `05996c08bf4e8a4ea5ee34db12636523ebaf0336` 上串行执行 `npm run check -- -ContinueAfterFailure -BuildDebugApk`。完整日志为 `build/block-boundary-verified-check.log`；结束后确认源码、测试、Android 配置、依赖锁文件及生成客户端均无修改。后续提交仅补充本验证记录。

| 检查 | 最终结果 |
| --- | --- |
| OpenAPI 校验与客户端再生成一致性 | 通过，生成文件零差异 |
| Dart 格式、应用及生成客户端静态分析 | 通过，零分析问题 |
| 架构与模块文档 | 通过，21 个模块完整；未提高文件行数基线 |
| Mobile API 覆盖 | 154/154，0 遗漏；既有范围外 62 项 |
| 全量 Flutter 测试 | 2922 通过、1 跳过、0 失败，含原 Golden 与实际保存阻断回归 |
| Windows 发布工具测试 | 17/17 通过 |
| Debug APK | 构建成功，Gradle 38.3 秒 |
| 公网契约与兼容性检查 | 失败：本地来源 `a91cbb8`，公网 build 仍为 `0ee2c0d`；HTTP 同为 `5.20.0-dev.20260909.1`，公网 Markdown v5 位于现有支持范围 |

统一入口最终返回非零，仅上述公网 revision 一项失败；未跳过、放宽或修改校验器，也未部署后端。唯一跳过测试为既有 `diagnostic_live_receipt_test.dart` 的 Sentry 显式联网接收验收，默认未设置 `WENYOU_VALIDATE_SENTRY`；与本候选块边界回归无关。

治理任务在 VPS 只读 Mobile 镜像通过 `git fetch` 与 `git show 05996c08` 取得语料，由 Backend clean `169b336` 调用实际 `findUnsupportedMarkdownFormats` 独立审计：225 份中 224 接受，唯一 `unsafe-target` 按预期拒绝（`unsafe-link`，`startLine = endLine = 3`），预期偏差为 0；14 份真实页面保存及 3 份代码编辑保存全部接受。语料 Git blob SHA-256 为 `847e4e79675c20fbc26fabd91e4e1ec4977c96eccc51e7bc542bf1a3342a9c4f`。Windows CRLF 文件与 Git LF 文件规范化后逐字节相等；最终全量测试重新产出的 208/14/3 份 Markdown 及接受标记与已审计语料逐项一致。Backend validator 提交不改变 Mobile 的 fixture 来源锁定。

候选 APK 与上述源码提交对应，未安装、上传或正式发布：

- 路径：`C:\Users\quhui\.codex\worktrees\202d\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 应用：温油站 Debug；`applicationId = site.wenyou.app.debug`。
- 包内 `versionName = 0.7.0-dev.1-debug`、`versionCode = 94`；项目版本 `0.7.0-dev.1+94`。
- SHA-256：`766bb4ccd56082aa31bce67ded9d5b207ea5d4552ae780dd2a138b170a346f74`；大小 203,791,230 字节。
- `aapt dump badging` 核对最低 API 26、target API 36，Debug ABI 为 `arm64-v8a`、`armeabi-v7a`、`x86_64`。
- 评审入口：[候选 PR #26](https://github.com/morenk/wenyousite-mobile/pull/26)，目标 `dev`，保留 Draft；未合并。

## 后续验收条件

公网检查在 `tool/verify_production_api.dart` 中要求 `actualRevision == expectedRevision`，比较完整 SHA 精确相等，不比较祖先关系或契约内容哈希。因此仅部署 Backend 候选 `169b336` 或最终合并提交，不会使原来源固定为 `a91cbb8` 的检查自动通过。取得明确合并与部署授权后，须以实际已发布 Backend 的完整 SHA，通过既有 `tool/sync_backend_contract.ps1` 更新消费者契约来源元数据，核验共享契约字节及 Markdown v5 未变，再复跑公网检查与受影响门禁；若契约实际变化，按独立契约同步切片处理。本轮授权后的来源同步另记下节；原 `a91cbb8` 语料及独立验证产物保持溯源，不改写历史证据或校验器。

Backend revision 2 已由独立 chore `3a3d94b` 同步；自动验证已按上节记录。真机必须使用本候选 Debug APK，应用包名为 `site.wenyou.app.debug`，不能凭相同构建号认为其他包名已更新。若后续授权 ADB 安装，须核对实际复验包名、安装后更新时间及设备内 APK SHA-256。

负责人使用专用测试账号按顺序复验：

1. 阅读原楼层 `cmtvt31qc00497qc2xwuu6ama`，检查“经历：”后的居中 H2 及后续左／中／右块，没有隐藏 marker 泄漏。
2. 打开可编辑测试副本，检查原始三列手工空格、空白行、emoji 和各块归属；在指定文字中插入一个字符，保存并重开三次，确认仅输入处改变。
3. 验证跨行代码中的文字与 marker 保持代码样式；插字、保存、重开后不出现对齐跳变或保存失败。按上表检查代码前后的合法对齐块。
4. 检查草稿恢复；整篇站内复制保留结构，段内粘贴继承目标段落，外部纯文本不含隐藏 marker、媒体 URL 或节点身份。
5. 在 Web 与 Android 间进行双向打开／修改／重开，分别检查可见行、空段、样式、逐块对齐和手工空格；由负责人明确反馈通过或失败。

当前尚未安装或执行上述真机验收。候选交付不关闭原问题，负责人未回复不算通过。

## 合并来源同步与公网复核

当前来源更新为 Backend `8bf370f6ef5357535683aa6d3f8c03bd2d08d108`，包含发布权限修复；此前 `5b766305` 部署因权限故障回滚到 `0ee2c0d`，未据此合并 Mobile。按治理交接再次通过同一同步脚本、相同只读镜像及显式完整 SHA 导出，仍只有来源元数据变化；所有契约字节与块边界 fixture 哈希不变。运行时代码、834 项组合回归对应的测试实现及既有 APK 未改动，不重复全量测试或构建。公网健康确认后才执行精确来源检查及 PR 合并；前次同步与验证记录如下保留。

对 `8bf370f6` 来源复跑 OpenAPI 校验、`npm run api:check` 及 21 模块文档检查，全部通过；生成流程结束后确认生成客户端、源码、测试、Android 配置和依赖锁文件零差异，`git diff --check` 通过。日志为 `build/block-boundary-redeploy-source-check.log` 与 `build/block-boundary-redeploy-docs.log`。

按用户本轮明确授权，在原 Windows 任务执行 `pwsh -NoProfile -File tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Revision 5b766305e21d2a39bd53bb0c3aacc05fad81152f`，从已合并 Backend 重新导出。`contracts` 唯一差异为 `backend-contract.properties` 的来源 SHA；OpenAPI、所有共享 fixture、Markdown v5 图片对齐与空白行契约、契约 CHANGELOG 和移动端指南均无差异。块边界 fixture SHA-256 仍为 `822509411fbf3379847a04ec64a4a32ddb1bb8fb96aecbf38b395b049134fda9`。

本次只更新来源元数据和必要文档；225 份消费者审计语料保留生成时的 `a91cbb8` 来源，运行时代码、测试、依赖声明与 Android 配置不变。候选 APK 继续对应 `05996c08` 及其已记录哈希，不宣称针对新文档提交重新构建；本轮不安装或正式发布 Android 包。负责人尚未完成公网／真机验收，保留任务分支、Worktree、APK 与日志。

来源同步后 `npm ci`、OpenAPI 校验与 `npm run api:check` 通过，生成客户端及依赖锁文件零差异；21 模块文档检查通过，`contract_revision.test.mjs` 的固定来源导出／拒绝非 dev 祖先回归通过。记录为 `build/block-boundary-deployed-source-check.log`、`build/block-boundary-deployed-docs.log`、`build/block-boundary-deployed-tool-test.log`。公网部署确认及与并发合入 PR #25 的组合复核继续记录，不以历史 APK 代表后续组合源码。

随后正常合入 `origin/dev` 的 PR #25 合并提交 `e5d72c34c98e8764518cd6a26f2ff508ca29d6a6`；仅 CHANGELOG 顶部发生冲突，双方记录全部保留，动态图源码和负责人验收记录保持完整。既有 `flutter_cache_manager 3.4.2` 由传递依赖改为直接测试依赖，无版本变化。组合树 `flutter pub get`、全应用分析零问题（215.6 秒），834 项相关回归全部通过（48 秒），覆盖全部 core Markdown、来源兼容、真实编辑／保存／草稿／剪贴板、安全阻断、旧引用 Golden、图片查看器与动态图页面。日志为 `build/block-boundary-combined-check.log`；组合文档检查 21 模块通过。没有把两份历史候选 APK 作为组合安装包，也未重跑完整门禁或构建新 APK。

# 富文本块边界跨端候选验收

## 当前状态与范围

2026-09-11：候选实现／最终门禁复核中／待负责人验收。任务分支 `codex/20260911-markdown-block-boundaries` 从 fetch 后的 `origin/dev`（`dbba204dd5d43252a400ff50a4db7348415d62f3`）建立，独立 Windows Worktree 为 `C:\Users\quhui\.codex\worktrees\202d\wenyousite-mobile`。已同步 Backend revision 2 并补充消费者实现与回归；原 revision 1 的 8 项空白行预期已在共享版本中修订，网络依赖阻塞已解除。不能视为原问题修复完成。

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

最终相关回归 `build/block-boundary-final-focused.log`：433 项全部通过。`test/fixtures/markdown-block-boundary-mobile-output.json` 固定 208 份 Codec 输出、14 份真实楼层页面 IME 提交和 3 份真实 Quill 输入后会话 flush 输出，共 225 份；不包含完整原楼层正文，等待 Backend 共用 validator 独立接受验证。21 个模块文档门禁通过。最终统一门禁与 APK 复核继续执行。

- revision 2 的 208 项共享案例全部执行；结合精确边界、三类真实 Quill 容器输入与真实阅读共 404 项通过（`build/block-boundary-rev2-reader.log`）。
- 完全显式引用与缩进列表跨行代码、引用／列表嵌套围栏及缩进代码共 5 项负例，核对 marker 不被误报或消费、完整字面文字、代码／容器属性及保存稳定；结合原有格式策略共 16 项通过（`build/block-boundary-explicit-containers.log`）。保留旧列表 0～2 级可编辑能力，第 3 级仍按既有边界拒绝。
- Dart 7.3.1 引用收集器误把链接定义作为 lazy paragraph 中断；候选以实际前块类型与 `canEndBlock` 判断延续。保护器的包装语法经共享 Document 传入嵌套解析器，引用使用实际去前缀子行回调，列表只在原生已消费容器内顺序核验完整子行来源。标题／围栏后的 marker 不能被吸入引用。
- 阅读投影只把实际跨行 code span 内的 LF 变为空格，并消除该 span 的容器续行前缀，避免自定义空段语法打断代码。原持久化 Markdown 不受影响。文字断言遍历实际 Element、InlineSpan 与 WidgetSpan 子树，按显示顺序拼接且避免重复计数。
- `backtick-link-title-later-code` 与 `backtick-link-title-multiline-code` 维持原有 Mobile 链接 title 源码降级：严格验证完整原链接／title、对齐边界及保存重开；原文阅读按共享文字验证。本次不新增 title 编辑能力，也不删掉这两项。共享 `supported` 表示后端合法，不代表全部客户端都支持该链接元数据的富文本化。
- 首次统一门禁在 revision 1 上记录 8 项已知 fixture 失败及 1 项旧二级列表回归；后二者分别随 revision 2 同步与候选修正消除。另有临时 `build` 审计 Dart 文件的 19 项 lint 和测试 1 项花括号提示，已移走审计脚本并修正。全量测试报告到 2752 项通过后结果收集停滞数分钟，无 tester 且 runner/compiler CPU 不变，已核实 PID 后终止该停滞测试进程；该轮保留为失败记录，不能作为最终全绿证明。

共享序列化输出由测试写入 `build/mobile-block-boundary-serialized.json`，分别标记普通支持、既有 link title 降级和不支持源码降级；`editorLines` 是编辑器实际可见行。最终语料经 Git 交给 Backend 校验发布可接受性，不能以 Codec 自洽代替此证据。

公网 `/meta` 仍为 `0ee2c0d`，候选契约 `a91cbb8` 尚未部署，因此统一门禁的公网 revision 检查预计继续失败，必须单独记录。未安装 Android 候选包，未取得负责人原场景验收，Web → Android → Web 登录链路仍待手测；Widget/Drift/剪贴板替身不代替设备或线上验证。
## 后续验收条件

Backend revision 2 已由独立 chore `3a3d94b` 同步；最终运行消费者序列化接受验证并更新统一门禁结果。真机必须使用本候选 Debug APK，应用包名为 `site.wenyou.app.debug`，不能凭相同构建号认为其他包名已更新。

负责人使用专用测试账号按顺序复验：

1. 阅读原楼层 `cmtvt31qc00497qc2xwuu6ama`，检查“经历：”后的居中 H2 及后续左／中／右块，没有隐藏 marker 泄漏。
2. 打开可编辑测试副本，检查原始三列手工空格、空白行、emoji 和各块归属；在指定文字中插入一个字符，保存并重开三次，确认仅输入处改变。
3. 验证跨行代码中的文字与 marker 保持代码样式；插字、保存、重开后不出现对齐跳变或保存失败。按上表检查代码前后的合法对齐块。
4. 检查草稿恢复；整篇站内复制保留结构，段内粘贴继承目标段落，外部纯文本不含隐藏 marker、媒体 URL 或节点身份。
5. 在 Web 与 Android 间进行双向打开／修改／重开，分别检查可见行、空段、样式、逐块对齐和手工空格；由负责人明确反馈通过或失败。

当前尚未安装或执行上述真机验收。候选交付不关闭原问题，负责人未回复不算通过。
# 编辑器 Markdown ↔ Delta Codec

## 边界

后端 Markdown v3 是唯一持久化格式，Flutter Quill Delta 只存在于编辑会话内存。打开编辑器时由自研 Codec 按 `Markdown → MarkdownEditorDocument → Delta` 将完整快照解析为编辑状态；自动快照、云草稿、显式保存和提交前统一按 `Delta → MarkdownEditorDocument → Markdown` 重新序列化，再执行 Markdown v3 规范化、块结构等价与可见性检查。

不把 Delta JSON写入后端或云草稿，不把 `markdown_quill` 作为往返转换事实层。Flutter Quill 官方原生模型是 Delta 并推荐直接保存 Delta；温油站有既存 Markdown 契约，因此这种转换风险必须由本项目的黄金测试吸收。`markdown_quill` 当前不保留图片 alt，且输出转换仍有限，不能满足表情 title marker 和图片元数据无损往返。

## 协议映射

| Markdown v3 | Delta 内存节点 |
| --- | --- |
| 普通 Markdown | Quill 文本与受支持的行级/行内属性 |
| `[@名称](/users/id)` | 原子 `mention` inline embed；兼容模式可读为受保护 link span |
| `@全体玩家` | `mention` inline embed，kind 为 `all_players` |
| `[[dice:v1:nodeId:notation]]` | `dice` inline embed，保留版本、UUID 与 canonical notation；编辑态与阅读态均按正文基线排版，不建立独立行盒或卡片 |
| 带 `wenyousite-sticker:v1:` title 的图片 | `sticker` inline embed，保留 alt、URL 与 asset ID |
| 普通图片 | `wenyou_image` embed，保留 alt、URL 和可选 title |
| 独占 `<br />` | 空 Quill Paragraph；不得当作 HTML |
| 与相邻正文各隔一个空行的独占 `---` | 块级 `wenyou_horizontal_rule` embed；历史 `正文\n---` 是 Setext H2，其他 thematic break 写法继续保留源码 |

Embed payload 必须版本化且只包含序列化回 Markdown 所需的稳定字段。未知版本在编辑器中显示不可编辑的兼容占位，序列化时保留原始 token，禁止静默丢弃。

## 当前实现状态

`MarkdownEditorDocument` 类型化描述段落软换行、H2/H3、引用、列表项、分隔线、协议空段和兼容文本，并集中分配块边界。canonical writer 强制分隔线两侧各一个结构空行、段内软换行保持单 LF、用户空段保持独占 `<br />`；写出后重新解析并比较块结构，分隔线混入文字行、叠加标题/列表/引用或缺少终止换行时直接阻止保存。工具栏通过 `RichEditorSession` 的一次 Delta compose 插入分隔线，撤销只回退该事务。历史 `正文\n---` 由上下文解析为 H2 并在用户编辑保存后写成 `## 正文`，不批量迁移未编辑正文。

`MarkdownDeltaCodec` 已接入主题和帖子编辑器。`MarkdownRichLineDecoder` 先把可精确往返的粗体、斜体、删除线、行内代码、安全链接、二三级标题、引用和 0～3 级列表解析为不依赖 Quill 的中立行模型，Codec 再用未净化的候选编码结果验证其能回到完全相同的 canonical 输入后映射为 Delta 属性；出口净化不能参与这项能力证明。任务列表、表格、围栏代码、历史标题级别等尚未支持的结构在编辑会话中显示为可解释的源码文字；序列化时 `wenyou_literal_line` 会转义 Markdown 标点并提交为 Markdown v3 安全字面文本，因此它们不会作为原始不支持结构继续生效，也不属于源码无损提交。外部粘贴、键盘和 IME 写入的普通字符携带 `wenyou_literal_text`，Codec 先转义全部 ASCII Markdown 标点，再由完整 `encode` 出口统一识别并字面化漏网的不支持结构；只有已有受支持 Markdown 解码结果、工具栏属性和协议 embed 可以生成语义。已保存的安全转义在 decode 时拆成可见字符与最小 literal span，编辑器不显示反斜杠和 whitespace guard，重新 encode 仍得到相同安全表示。用户提及、全体玩家、骰子、表情、普通图片、独占 `<br />` 和精确 `---` 提升为稳定 embed 或行属性。未知骰子版本、非法/重复骰子、非法表情与非 HTTP(S) 图片使用保存原 token 的 `wenyou_compatibility` embed；未知/损坏 embed、未知属性、冲突块样式、危险链接或 retain/delete 操作会阻止序列化。

源码换行由 `wenyou_source_break` 区分 Quill 必需的末尾换行，空段由 `wenyou_empty_paragraph` 区分普通空行，确保 `<br />` 不被当作 HTML。解码时另用仅存在于会话内存的 `wenyou_source_separator` 标记已有 Markdown 的结构分隔；键盘、IME 或外部粘贴产生的新空行不得继承该标记。编码出口在 Delta 副本上按真实字符位置重组行元数据：已有结构分隔继续写普通空行，其余无块样式的空 Quill Paragraph 逐个写为独占 `<br />`，包括首部、尾部和连续空段；只有文档最后一个 Quill 换行按位置视为终止符，不信任换行规则复制的 `wenyou_source_break=false`。编辑页提供工具栏及 mention、dice、sticker、image、compatibility、horizontal-rule builder；分隔线只位于“更多”。编辑器剪贴板保存结构化选区和 Markdown 文本回退，Android `ClipDescription.extras` 同时保存随机 UUID marker；只有 marker、系统纯文本、十分钟时效和 `SessionScope` 全部匹配才恢复 Delta。匹配的复制载荷在每次粘贴时重建骰子 UUID，剪切载荷仅首次保留原 UUID；任一条件失配或载荷无法通过 Codec 安全编码时只按普通文本插入。所有外部文本粘贴都由 `RichEditorSession` 消费并统一换行，不再把普通文本、富剪贴板或无文本结果交回 Quill 默认路径。读取剪贴板前固定文档 generation、Delta 签名和选区；异步返回时任何一项变化都会拒绝旧操作。会话先在克隆 Document 上完成替换、编码和 10000 字符预检，通过后才一次写入真实文档，因此超限不会留下部分正文。系统剪贴板写入失败同步清除内部载荷；只读会话允许复制，但明确拦截剪切和粘贴。显式 `flush` 等待在途粘贴并每次从当前 Delta 编码，即使会话未标脏也不得复用旧 Markdown；主题发布、主题/子贴/帖子保存、五槽位云草稿和本地快照由此共用同一出口。仅上述明确支持且通过精确回编码验证的既有 Markdown 进入 WYSIWYG；外部或新输入文本始终保持字面语义。

`MarkdownEmptyParagraphs` 在阅读和编辑历史正文前统一恢复旧客户端写入的连续原始空行：段落之间的第一个空行仍是普通 CommonMark 边界，其余空行逐个转为独占 `<br />`；首部逐行恢复，尾部只忽略一个格式化换行。围栏代码、缩进代码和原始 HTML 块属于字面保护区，不参与推断。进入行式 Quill Codec 时再移除协议标记周围仅供 Markdown 分块的空白分隔，防止一个标记被额外解码成普通空行；下次编辑保存会写入相邻 canonical `<br />`，重复打开不再增减段数。该兼容只发生在读取路径，不批量改写后端正文。

## 往返不变量

1. 对白名单内结构，`decode(markdown) → encode(delta)` 经 Markdown v3 规范化后必须与 canonical 输入一致；对白名单外但可读取的结构，输出必须等于契约规定的安全字面化结果。
2. `encode(decode(canonical))` 必须幂等。
3. 提及 ID、显示名、骰子 nodeId/notation、图片 alt/title/URL 和表情 asset ID 必须逐字段无损；骰子前后文字与 Markdown 换行边界也必须保持原位。
4. 围栏代码、行内代码和反斜杠转义中的协议样式文字保持普通文本。
5. Delta 永不作为本地快照的权威格式；每次快照保存完整 Markdown，避免插件升级锁死数据。
6. 解码失败不得覆盖原草稿；可读取但不受支持的结构在本次编辑会话中保留可理解源码，保存时明确转为安全字面文本，不伪装成原结构无损往返。
7. 新增的 Quill 属性必须在序列化前通过白名单、组合与 URL 安全检查；无法证明无损时阻止快照和提交。
8. 骰子 copy-paste 必须为每个节点生成新 UUID；cut-paste 首次保留 UUID，重复粘贴转为 copy 语义；mention、sticker 等其他节点不改写身份字段。
9. 骰子计数与后端保持相同的代码围栏、成对行内反引号和奇偶反斜杠语义；未闭合行内反引号不遮蔽后续合法节点，长畸形输入不得因逐字符复制后缀而退化。
10. 公共编码出口不得产生 `MarkdownContent.unsupportedLineIndexes` 可识别的不支持结构；安全字面化结果重复 decode/encode 不得继续增加转义或空行。
11. 外部剪贴板文本不得因与内部回退文本相同而恢复 Delta；必须额外匹配 Android UUID marker 与当前登录会话作用域。
12. 粘贴在克隆文档上预检，文档或选区竞态、读取失败及序列化后超过 10000 字符都必须保持真实文档原子不变；保存必须等待在途粘贴完成。
13. 历史连续空行恢复后，每个额外空行必须对应一个 `wenyou_empty_paragraph`；协议标记周围的 Markdown 分块空行不得成为额外 Quill 段落，重新打开和保存不得改变空段数量。
14. 新建的普通空 Quill Paragraph 必须在键盘、IME、粘贴、草稿和发布共用的编码出口逐段转为 canonical `<br />`；已有 Markdown 的单个结构分隔保持原样，换行继承的末行属性不得吞掉中间或尾部空段。
15. 分隔线必须是独占块，canonical Markdown 两侧各保留一个结构空行；`正文\n---` 必须保持 H2 语义并写为 `## 正文`，结构重新解析不等价时不得覆盖任何草稿或发布正文。

## 测试门禁

- `contracts/markdown-v3-fixtures.json`、`contracts/markdown-v3-nodes-fixtures.json` 与 `contracts/markdown-editor-roundtrip-v4-fixtures.json` 的 canonical、visible、块语义和幂等用例全部通过，并固定粗体后普通软换行不被提升为段落分隔。
- 为普通 Markdown、用户提及、全体玩家、骰子、表情、普通图片、空段和代码转义维护双向 Codec 黄金用例。
- 历史空段覆盖首部、中部、尾部、CRLF、显式标记幂等及围栏/缩进代码/原始 HTML 保护；编辑后重开必须保持逐段计数。新建空段另覆盖连续回车、首尾空段、继承末行属性、外部粘贴、已有结构分隔编辑和实际帖子发布载荷。
- 每种自定义 embed 至少覆盖解析、编辑后序列化、未知版本保留和恶意 URL降级。
- 剪贴板覆盖同编辑器、跨编辑器、Android marker/会话匹配、多骰子、剪切后重复粘贴、普通文本回退、其他协议节点保持、只读拦截和系统写入失败清理。
- 外部普通文本覆盖 CRLF、受支持 Markdown、表格、HTML、任务列表及全部 Markdown v3 不支持 fixture；另覆盖手输/IME、历史转义显示、粘贴竞态、序列化超限、在途保存、H2/H3、加粗、未标脏和同一帧立即 flush。
- 分隔线覆盖文首、文尾、文字中间、当前行上方/下方、单步撤销、重开、真实发布载荷和非法混合 Delta；阅读态与编辑态都断言 `border` 语义色、1px/1dp 且无装饰。
- Flutter Quill 升级必须独立 `chore`，重新运行全部 Codec 黄金语料并人工冒烟 Android 输入、选择、撤销/重做和粘贴。

参考：[Flutter Quill](https://pub.dev/packages/flutter_quill)、[markdown_quill 限制](https://pub.dev/packages/markdown_quill)、[编辑器模块](../modules/editor.md)。

# 编辑器 Markdown ↔ Delta Codec

## 边界

后端 Markdown v3 是唯一持久化格式，Flutter Quill Delta 只存在于编辑会话内存。打开编辑器时由自研 Codec 将完整 Markdown 快照解析为 Delta；自动快照、云草稿、预览和提交前都把当前 Delta 重新序列化为完整 Markdown，再执行 Markdown v3 规范化与可见性检查。

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
| 独占 `---` | 块级 `wenyou_horizontal_rule` embed；其他 thematic break 写法继续保留源码 |

Embed payload 必须版本化且只包含序列化回 Markdown 所需的稳定字段。未知版本在编辑器中显示不可编辑的兼容占位，序列化时保留原始 token，禁止静默丢弃。

## 当前实现状态

`MarkdownDeltaCodec` 已接入主题和帖子编辑器。`MarkdownRichLineDecoder` 先把可精确往返的粗体、斜体、删除线、行内代码、安全链接、二三级标题、引用和 0～3 级列表解析为不依赖 Quill 的中立行模型，Codec 再验证候选能编码回完全相同的 canonical 输入后映射为 Delta 属性。任务列表、表格、围栏代码、历史标题级别等尚未支持的结构在编辑会话中显示为可解释的源码文字；序列化时 `wenyou_literal_line` 会转义 Markdown 标点并提交为 Markdown v3 安全字面文本，因此它们不会作为原始不支持结构继续生效，也不属于源码无损提交。用户提及、全体玩家、骰子、表情、普通图片、独占 `<br />` 和精确 `---` 提升为稳定 embed 或行属性。未知骰子版本、非法/重复骰子、非法表情与非 HTTP(S) 图片使用保存原 token 的 `wenyou_compatibility` embed；未知/损坏 embed、未知属性、冲突块样式、危险链接或 retain/delete 操作会阻止序列化。

源码换行由 `wenyou_source_break` 区分 Quill 必需的末尾换行，空段由 `wenyou_empty_paragraph` 区分普通空行，确保 `<br />` 不被当作 HTML。编辑页提供工具栏及 mention、dice、sticker、image、compatibility、horizontal-rule builder。仅上述明确支持且通过精确回编码验证的普通 Markdown 进入 WYSIWYG；其余结构保持可解释的源码显示，并在保存时安全字面化，不宣称任意 Markdown 都已所见即所得或能原样提交。

## 往返不变量

1. 对白名单内结构，`decode(markdown) → encode(delta)` 经 Markdown v3 规范化后必须与 canonical 输入一致；对白名单外但可读取的结构，输出必须等于契约规定的安全字面化结果。
2. `encode(decode(canonical))` 必须幂等。
3. 提及 ID、显示名、骰子 nodeId/notation、图片 alt/title/URL 和表情 asset ID 必须逐字段无损；骰子前后文字与 Markdown 换行边界也必须保持原位。
4. 围栏代码、行内代码和反斜杠转义中的协议样式文字保持普通文本。
5. Delta 永不作为本地快照的权威格式；每次快照保存完整 Markdown，避免插件升级锁死数据。
6. 解码失败不得覆盖原草稿；可读取但不受支持的结构在本次编辑会话中保留可理解源码，保存时明确转为安全字面文本，不伪装成原结构无损往返。
7. 新增的 Quill 属性必须在序列化前通过白名单、组合与 URL 安全检查；无法证明无损时阻止快照和提交。

## 测试门禁

- `contracts/markdown-v3-fixtures.json`、`contracts/markdown-v3-nodes-fixtures.json` 与 `contracts/markdown-editor-roundtrip-v2-fixtures.json` 的 canonical、visible 和幂等用例全部通过。
- 为普通 Markdown、用户提及、全体玩家、骰子、表情、普通图片、空段和代码转义维护双向 Codec 黄金用例。
- 每种自定义 embed 至少覆盖解析、编辑后序列化、未知版本保留和恶意 URL降级。
- Flutter Quill 升级必须独立 `chore`，重新运行全部 Codec 黄金语料并人工冒烟 Android 输入、选择、撤销/重做和粘贴。

参考：[Flutter Quill](https://pub.dev/packages/flutter_quill)、[markdown_quill 限制](https://pub.dev/packages/markdown_quill)、[编辑器模块](../modules/editor.md)。

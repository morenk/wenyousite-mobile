# 第一批共享操作矩阵提案：回车、空段与引用

状态：已汇总 VPS 首轮审查的提案／待正式契约切片。本文件列出已有证据和需要共享的操作，不改变正文协议，不是已发布 fixture，也不表示全部场景已实现或验收。

## 1. 复用方式

优先扩展现有 newline v1 revision 2 与 roundtrip v7，保留已有 ID 和含义。新增语义预期和操作序列是否使用既有文件扩展或新增关联 fixture，由后端契约切片决定；不能由移动端先发布平行事实源。

27 条普通正文 Enter 操作已经共享且移动端消费。本轮重点补齐既有本地回归的跨端映射及真实保存旅程，不重新制造一套相同的 Enter 用例。

## 2. 最小交接字段

| 字段 | 提案含义 |
| --- | --- |
| caseId / ruleId | 稳定用例编号与对应规则；旧 ID 不复用为不同预期 |
| source | 原始问题脱敏输入或规则推导；明确真实复现与构造样例 |
| baseline | 契约版本/revision、写入能力、各端源码版本 |
| initialMarkdown | 保留准确字符、空格、LF 和转义；不从截图反推源码 |
| selection | 块路径或唯一锚点及出现序号、anchor/focus、方向；不能只取重复文本首次 indexOf |
| operations | Enter、Shift+Enter、文本输入、删除、格式动作、撤销/重做等；注明 UI/IME/命令入口 |
| expected | 逐步文字、块归属、marks、空段、软换行、节点身份和选区；允许的规范化明确列出 |
| serialized | 正式契约定义的规范 Markdown；未决规则不自动生成答案 |
| journey | 本地重开、Web→后端→移动→后端→Web 及反向路径 |

位置编码需明确 UTF-16 code unit 与原子节点位置约定；emoji/组合字符的用户删除行为另按字素簇断言，不把平台内部 offset 直接当共同选区。语义摘要仅用于测试/诊断，不成为正文 API 或持久化字段。

## 3. 首批用例族与已有覆盖

| 提案 ID | 输入/操作与独立预期 | 移动端已有证据 | VPS 核验与补齐目标 |
| --- | --- | --- | --- |
| RTM-01 | 普通左/中/右对齐段首中尾 Enter；新段左对齐、旧段保留、光标紧接 LF | [27 条共享操作](../../test/features/editor/editor_manual_newline_alignment_test.dart) | 标记 Web/Backend 对应执行器，不重复新增 |
| RTM-02 | 连续 1～3 次 Enter 后续写；可见空段数量稳定，不并回上一段 | 同上及[普通回车](../../test/features/editor/editor_enter_newline_test.dart) | 核对首尾空段和两端保存旅程 |
| RTM-03 | 旧段内 LF、Shift+Enter、手动 Enter 混用；同段与新段对齐归属正确 | [正文边界](../../test/features/editor/editor_paragraph_boundary_test.dart) | 共享明确块结构，不只比较可见行 |
| RTM-04 | 引用两段间独占 `>`；同一引用内两个段落，不多可编辑空行 | [引用语义](../../test/features/editor/editor_quote_paragraphs_test.dart)、RT-04 原记录 | 将真实问题对应到跨端用例；负责人验收仍独立待确认 |
| RTM-05 | 引用 `> <br />`、引用外 `<br />`、首尾空引用；保持空段位置和引用归属 | [引用边界](../../test/features/editor/editor_quote_paragraph_boundaries_test.dart)、newline cases | 检查连续 Enter 不退出引用、显式取消引用 |
| RTM-06 | 引用中段首/中/尾输入和 Enter、退格合并；旧分段元数据不复制或残留 | [引用边界](../../test/features/editor/editor_quote_paragraph_boundaries_test.dart) | 补逐步选区、块结构与保存重开共同预期 |
| RTM-07 | 边界拆分后撤销/重做；一次操作回退对应内容、块属性及选区 | 正文与引用边界测试 | 明确事务边界，不要求各编辑器内部栈结构相同 |
| RTM-08 | 引用切标题/正文，普通段切引用；旧对齐/分隔属性不污染新块 | 引用边界与格式策略测试 | 把已定产品规则映射为命令矩阵；未定义组合先提决策 |
| RTM-09 | 已转义 `>`、代码中的标记、Tab/合法前导空格、Unicode 空白 | [引用语义](../../test/features/editor/editor_quote_paragraphs_test.dart) | 正向与字面反例成对发布，不能 trim 伪造一致 |
| RTM-10 | 重复“甲乙”段落中定位第二段，emoji/组合字符旁输入与删除 | 本轮未确认共同覆盖 | 使用无歧义选区，避免锚点匹配第一处掩盖错误 |
| RTM-11 | 完整段落跨站内粘贴到对齐段中，保留左右残段与粘贴块属性 | [对齐剪贴板](../../test/features/editor/editor_alignment_clipboard_compatibility_test.dart) | 先复用 clipboard v2 的入口与身份规则，补双向旅程 |
| RTM-12 | 保存/草稿/关闭重开及跨端反复保存；规范化后稳定 | [快照事务](../../test/features/editor/editor_snapshot_transactions_test.dart)及编码安全测试 | 核对真实 API 返回，不用本地 encode/decode 替代后端 |
| RTM-13 | 注入编码失败、后端拒绝及保存失败；禁止提交旧值，内容可恢复，重试使用当前有效正文 | 移动端有 flush/快照失败保护；未在本轮执行 | VPS 静态发现 Web bridge 异常只通知，父表单可能保留旧值；先验证故障注入，不声称真实数据丢失 |

测试存在不代表本轮执行过。VPS 已确认 RTM-01 的 27 条共同操作、v7 插入/删除样例和 clipboard 结构样例；完整撤销/IME/失败恢复/交叉保存尚未形成共同序列。RTM-02～12 的逐项远端本地测试映射由正式契约切片补充，不能直接标为缺失。列表、空对齐块的新行为与其他活跃任务对齐后再纳入，不能抢先改变其预期。

## 4. 必须分别报告的结果

1. 内容：逐字符文字、marks、链接、段落/引用归属、空段/软换行、节点身份。
2. 编辑：每步选区、可编辑行/块、一次撤销/重做的结果。
3. 保存：规范写法、后端返回、重复保存稳定性；失败不覆盖最后有效内容。
4. 阅读：无重叠/裁切、基线与块间距符合 Foundation；自动折行差异不算内容漂移。
5. 环境：源码、fixture revision、meta、APK 身份和测试入口；不能用相同构建号替代 APK 哈希。

## 5. 执行顺序与交付门槛

优先核对/补齐 Backend 与 Web newline 跨仓一致性清单，并验证 RTM-13 失败注入；再对照 RTM-01～09 已有回归，确定哪些需要共享化，补 RTM-10 的无歧义选区，RTM-11～12 连接真实跨端旅程。优先最小反例与真实原文，不先扩大为无限组合。

正式切片给每行补“已共有／仅某端／需补规则／待验收”状态及具体 commit。只有正式契约和独立预期落地后才开发缺口；Bug 候选必须完成旧实现失败、候选通过及负责人验收，不能以本表存在作为完成证据。

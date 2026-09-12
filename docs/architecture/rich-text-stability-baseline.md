# 富文本稳定性阶段 0 基线与问题台账

状态：Windows 与 VPS 首轮只读核验已汇总；阶段 0 审查完成，测试、跨端旅程及负责人待验收项仍按下表保留。核验时间为 2026-09-10 01:26～01:34（Asia/Shanghai），VPS 报告于 01:38 后取得。本页中的线上版本是当时快照，不保证后续仍相同。

## 1. 版本与环境证据

| 对象 | 本轮结果 | 证据与限制 |
| --- | --- | --- |
| 移动端集成基线 | `162aa62e2eeb7fddfdb90a1b3c480ed6c89917a0` | 本地 dev 与 fetch 后 origin/dev 一致；主工作区干净 |
| 本文任务分支 | `codex/20260910-rich-text-stability-plan` | 独立 Windows Worktree；仅文档计划与审查 |
| 已同步后端来源 | `3338028459561565c788d5236fb64db84a2ae538` | [同步元数据](../../contracts/backend-contract.properties)，不是本轮公网 SHA |
| 后端 origin/dev | `6bfb818df4ccf5333df7b62018a9f519d91e935b` | 后端只读镜像 fetch 后 git show；不修改镜像源码 |
| 公网后端 | `6bfb818df4ccf5333df7b62018a9f519d91e935b` | Windows GET `https://wenyou.site/api/v1/meta`，`code=0` |
| HTTP 契约 | `5.18.0-dev.20260905.1` | 本地来源与本次 meta 相同 |
| 正文能力 | 公网 Markdown 5；基础语料版本 4 | 同步脚本从 v4 基础/节点/往返语料写属性文件，线上检查另按客户端兼容集合判断运行 v5；两者不是同一个版本字段 |
| Android 更新策略 | recommendedBuild=93，minimumSupportedBuild=null | meta 快照；本轮未安装、下载或晋级 APK |
| Quill | Git 固定 `c273155025d1255335a6dd3e6ecd3700d29f103e` | [pubspec](../../pubspec.yaml)，含 Android IME 选区修复的依赖说明；未升级 |
| Foundation | 本地锁定 v6.9.0 | 仅记录当前依赖；本轮不做视觉实现，未宣称重新核验远端最新 Tag |
| Web 基线与部署 | `ae968c840264fb61ae9d2689f7c4a88d50a7cb0f` | VPS 主目录干净 dev；HEAD/origin/dev/联网 ls-remote 一致；current 的 release 元数据 SHA 相同，未验证浏览器实际加载资源 |
| Web 编辑器与阅读 | Milkdown 7.21.3、React Markdown 10.1.0、remark-gfm 4.0.1 | VPS 核对锁文件及安装版本；底层编辑使用 ProseMirror |

本轮已比较来源 `3338028` 与 fetch 后后端 origin/dev：OpenAPI、契约 CHANGELOG、v4 基础/节点、roundtrip v7、clipboard v2、v5 图片对齐、newline v1、push schema/fixtures 与移动指南均无 diff；对整个 contracts 与移动指南的 diff --stat 同样为空。因此目前证据是部署/来源 SHA 差异，并非正文契约内容漂移。本轮不顺手改写同步元数据，严格来源检查是否需要独立 chore 由后续契约切片处理。

版本字段证据：[同步脚本](../../tool/sync_backend_contract.ps1)从基础 fixture 和节点契约取得 markdownContractVersion；[公网检查](../../tool/verify_production_api.dart)分别核对来源 SHA、HTTP 版本与 `supportsMarkdown(actualMarkdown)`。基础语料 4 与运行能力 5 不构成本轮已证实缺陷，来源 SHA 不同仍不能冒称严格公网检查通过。

## 2. 已有共享语料

| 契约文件 | 版本与已读内容 | 本轮处理 |
| --- | --- | --- |
| [基础 Markdown](../../contracts/markdown-v4-fixtures.json) | version 4，34 cases | 保留 |
| [业务节点](../../contracts/markdown-v4-nodes-fixtures.json) | version 1，8 cases 与 identityRules | 保留 |
| [编辑往返](../../contracts/markdown-editor-roundtrip-v7-fixtures.json) | version 7，30 cases、48 editCases | 已有语料，不重复建设 |
| [换行](../../contracts/markdown-editor-newline-v1-fixtures.json) | version 1、revision 2，15 cases、27 editCases | 第一批直接复用 |
| [图片对齐](../../contracts/markdown-v5-image-alignment-fixtures.json) | fixture version 2、Markdown 5，8 cases | 区分文件版本与正文版本 |
| [剪贴板](../../contracts/editor-clipboard-v2-fixtures.json) | version 2，8 goldenCases，6 entryPoints | 已包含结构预期；后续连接完整旅程 |

这些计数描述文件内容，不代表本轮已运行或三端全部消费。移动端 [27 条操作执行器](../../test/features/editor/editor_manual_newline_alignment_test.dart) 已直接读取换行契约，并断言光标、文字、方向、序列化、续写与重开。

## 3. 原问题状态与范围

| ID | 问题或审查项 | 当前证据结论 | 下一步 |
| --- | --- | --- | --- |
| RT-01 | 手动 Enter 新段方向与额外段间距 | 2026-09-09 负责人通过；源码 `1fe9435`、APK `db2c8965…`，见[验收](editor-manual-alignment-acceptance.md) | 保留已完成结论；补跨端实际部署与双向旅程证据，不重新修复 |
| RT-02 | 空正文选择 H2/H3 报错 | 2026-09-09 负责人通过，见[验收](editor-empty-heading-acceptance.md) | 纳入对照回归，不能扩展为所有空格式组合均通过 |
| RT-03 | 引用标记拆分 | 原记录有负责人明确通过，见[引用记录](editor-quote-acceptance.md) | 保留通过结论 |
| RT-04 | 引用内部语法分隔显示多余空行 | 原文、候选回归已取得；独立记录仍待负责人验收 | 不用 RT-01 的通过自动覆盖；由原任务/负责人对应候选确认 |
| RT-05 | 行内代码、提及、表情阅读换行与基线 | 2026-09-09 汇总复验通过，见[汇总记录](mobile-regression-validation.md) | 转为已验收基线，不新增同名 Bug |
| RT-06 | 旧普通回车文档继续继承方向 | [旧回车记录](editor-newline-acceptance.md)与 revision 2/RT-01 的新规则不同 | 本轮加历史范围说明，防止旧表格作为新事实源；不删原验收历史 |
| RT-07 | 来源 SHA 与公网不同 | meta 已为 `6bfb818`；所列同步文件无差异 | 记录真实快照，独立考虑来源同步，不据此诊断 Codec Bug |
| RT-08 | 空格式块与列表语义 | 存在独立 Worktree 和未提交列表调查 | 不接管、不覆盖、不计入 dev 能力，等待已提交交接 |
| RT-09 | newline fixture 跨仓一致性门禁遗漏 | VPS 复核两仓门禁未发现等价逐字比较；同步脚本测试仅比较临时生成样本；当前真实文件一致 | 独立切片补检查并注入漂移验证；静态确认，未运行故障注入；不是已发生协议漂移 |
| RT-10 | Web 编码失败后提交旧表单值 | 静态链路存在异常通知与父表单状态分离；未证明正常操作可触发或实际数据丢失 | 先做失败注入，若证实再交付候选，禁止先标记修复完成 |

RT-04 保留原问题身份；未取得独立验收不算失败新发，也不算通过。本文没有新增 APK 构建、设备操作或真实内容写入。

## 4. 并行任务保护

核验时 `D:/code/wenyousite/.worktrees/mobile-empty-block-semantics` 位于 `codex/20260909-empty-block-semantics`，HEAD 为 `2a55ce0`，存在未跟踪的列表调查文档及测试。本任务只读状态，不读取未提交内容作为共同协议，不修改该目录。

另有 `mobile-thread-cover-playback` Worktree，保持不动。本任务在 `D:/code/wenyousite/.worktrees/mobile-rich-text-stability-plan` 写文档，主 checkout 保持 dev。

## 5. 已证实的结构事实与待验证假设

- 已证实：[Codec](../../lib/core/markdown/markdown_delta_codec.dart)打开路径先读取中立模型、再 toMarkdown、再处理行；[阅读组件](../../lib/core/widgets/wenyou_markdown.dart)有自身预处理和 Markdown 阅读路径。这是待评估的重复语义入口，不是新 Bug 根因结论。
- 已证实：已有段落、引用边界和撤销测试，不能称“只有往返测试”。见[正文边界](../../test/features/editor/editor_paragraph_boundary_test.dart)、[引用边界](../../test/features/editor/editor_quote_paragraph_boundaries_test.dart)。
- 已证实：[引用验收记录](editor-quote-acceptance.md)说明过首次解码错误仍可往返自洽；共同预期应补实际块归属与操作。
- VPS 已确认：Web 消费 27 条 newline 操作与 v7 编辑样例，后端主题/楼层/回复/子贴/云草稿共用 prepareMarkdownContent；共享操作尚不覆盖完整撤销/重做、IME、失败恢复及交叉保存序列。不能据此声称所有端都缺相应本地测试。
- 待验证：来源属性简化是否确实降低边界成本。不能以代码存在属性推断可删除，须先验证文字/marks/兼容语料。

## 6. VPS 交接证据

VPS 任务“审查富文本跨端契约与部署基线”的正式 ID 为 `01a08737-4535-7be2-84bf-30606248b401`。初次工具仅返回排队 ID，后从桌面任务路由日志定位正式 ID，并通过 wait_threads/read_thread 取得已完成报告；列表未显示不等于任务未执行。报告只读，不修改服务或契约，不运行测试、不读取用户正文。

VPS 的主要代码证据固定到当次 commit：

| 层次 | 入口及确认结果 |
| --- | --- |
| Web 初始化 | [milkdown-editor-host.tsx](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/src/components/editor/milkdown-editor-host.tsx#L565)：CrepeBuilder、prepareEditorMarkdown，移除手输 Markdown input rules |
| Web 操作 | [editor-plain-newline.ts](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/src/components/editor/editor-plain-newline.ts#L5)：正文 Enter 新段左对齐，引用换行，其他分支保留既有语义 |
| Web 写出 | [milkdown-markdown-codec.ts](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/src/components/editor/milkdown-markdown-codec.ts#L260)：serializeEditorMarkdown 统一规范化与白名单；异常 bridge 路径位于同文件约 378 行 |
| Web 阅读 | [markdown.ts](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/src/lib/markdown.ts#L189)、[markdown-content.tsx](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/src/components/thread/markdown-content.tsx#L417)：历史恢复、安全降级及原子/对齐插件，保留 skipHtml |
| 后端规范化 | [markdown-content.ts](https://github.com/morenk/wenyousite-backend/blob/6bfb818df4ccf5333df7b62018a9f519d91e935b/src/common/markdown-content.ts#L362)：prepareMarkdownContent，规范化后白名单检查；不全局 trim 或 Unicode 归一化 |
| 一致性清单 | [Backend](https://github.com/morenk/wenyousite-backend/blob/6bfb818df4ccf5333df7b62018a9f519d91e935b/scripts/check-doc-truth.ts#L103)、[Web](https://github.com/morenk/wenyousite-frontend/blob/ae968c840264fb61ae9d2689f7c4a88d50a7cb0f/scripts/check-doc-truth.ts#L313)：均未列入 newline fixture；17:39 UTC 补充审查未发现其他真实跨仓逐字核验 |

Web current 的 release 元数据 SHA 与基线一致，后端本机和公网 meta 相同。后端不可变 release 的 BUILD_SHA 文件受权限限制未读到，Web 进程 cwd 未独立核验；不因此扩大为“浏览器资源与服务构建完全验证”。现场服务均 active/running，本轮没有重启。

VPS 对六份正文/剪贴板 fixture 与 Web 副本逐字比较一致，OpenAPI 副本一致；Windows 的 newline/roundtrip 文件哈希也与交接一致：

```text
newline v1 revision 2: d3ec5d99eb6d7e258c97cae4caba5951067eb8f06a589fbbb2cb1022f6ba887a
roundtrip v7: 82d4218c9613f2d3404513b0e540f8d6dcc979c168fdca1acf3263d908e99bf6
```

后端 PR #5、Web PR #6 和治理 PR #6 均已合并，当前代码包含相关修复；PR 无后续评论/review 验收证据不推翻 Windows 已取得的负责人反馈，仍按 RT-01～05 分项记录。

## 7. 阶段 0 退出与未验证项

S0 已具备可追溯版本、链路、共享覆盖、已验收问题与并行任务边界，可以进入 S1/S2 的小切片。下一项优先确认/补齐 newline 一致性门禁及验证 RT-10 失败路径，而非重写已交付 Enter。

VPS 于 2026-09-09 17:39 UTC 补充核验：newline 本地行为测试和同步脚本测试不能替代真实跨仓一致性门禁；RT-10 最小故障注入应在 Crepe 成功初始化并同步正文 A 后，使下一次 serializerCtx 序列化抛错，再输入形成 B，验证真实父表单不会提交 A。不能在初始化就抛错，也不能使用 textarea 替身代替真实编辑 bridge。以上仍是下一切片的验证方案，本轮没有执行。

剪贴板继续按既有接收载荷规则处理：支持格式的接收端收到合法本站 v1/v2 envelope 并通过白名单后恢复结构（v1 不恢复对齐）；无有效载荷时降级为可见文字，合法单个站内 URL 保留传送门例外。不能只因 Web↔Android 就强制纯文本，也不因此新增跨端传输协议。

后续仍需：浏览器实际资源核验、专用账号双向保存、Android 输入法与候选安装包验收、RT-04 独立结论及列表任务已提交交接。这些属于后续验证或原任务工作，不伪装为 S0 已执行。当前只运行文档检查与差异审查，没有新增业务测试或 APK。

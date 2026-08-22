# 编辑器

状态：`in_progress`

## 1. 模块目标与非目标

基于 Flutter Quill 提供移动端富文本输入与工具栏，以自研 Markdown v3 ↔ Delta Codec 支持安全链接、图片、骰子、提及、协议节点和本地防丢。当前已交付创建主题编辑页、帖子/回复/子贴正文复用编辑器及对应发布主链；主题元数据和子贴目录由 threads 模块独立管理，正文预览仍待后续切片，V1 不离线自动发布。

## 2. 用户角色与使用场景

已登录用户在 `/compose/thread` 创建公开或私密主题，保存服务端主题草稿或发布；也可在主题详情和楼中楼创建或编辑普通帖子，有 capability 的楼主/协作者可编辑子贴正文。契约 4.14 后所有已建立会话的注册用户使用统一发布身份；游客由路由或写入口登录后回到原目标。

## 3. 页面、入口和导航关系

应用壳创建按钮进入 `/compose/thread`。创建页标题为“写主题”，页面加载当前用户的本地快照和动态分类；AppBar 只保留独立的“云端草稿”和紧凑高对比“发布”，云端草稿按钮下方以两项锚点气泡提供“保存 / 打开”，完整草稿列表仍使用可滚动 Sheet。标题下方固定分类、可见性和标签元信息栏，正文聚焦时标题收为单行，元信息在编辑器内局部展开。正文工具栏的“正文草稿”独立放在格式操作之后，不夹在样式按钮中间；窄屏空间不足时降为单独的工具行。发布成功后替换到 `/threads/:threadId`。主题详情和独立楼中楼使用可扩展 Bottom Sheet 创建或编辑楼层、回复与子贴正文：新建默认 56%，已有正文默认 82%，可在 42%～94% 间拖动；顶栏只承载关闭、目标和展开，发送固定在键盘工具栏右侧。编辑态和成稿态普通正文图片进入同一共享原图页。

## 4. 用户操作流程

主题标题字段始终显示“主题标题”标签，不以 placeholder 代替字段身份；正文编辑 Dock 的提示文字仍是短时创作入口提示。分类、可见性和标签选择态同时保留结构与字重线索，不只依赖颜色表达当前选择。

打开页面时以 JWT 的 `sub` 仅作本地账号分区，读取完整 Markdown 快照，再异步用 `usersGetMe` 和 `threadCategoriesList` 确认服务端身份与可用分类。首屏按标题 → 固定元信息栏 → 剩余正文画布 → 本地保存状态 → 键盘 dock 排列，正文不套装饰卡片或使用固定整机高度推算。编辑态正文统一为 17sp、1.8 行高，H2/H3、引用、行内代码、链接和协议节点保持与成稿等价的 WYSIWYG 层级。发布始终从紧凑顶栏提交。工具栏消费 Foundation v6.2.0：正文/H2/H3、粗体、斜体、图片和更多固定在主栏，发送场景最右固定发送；再按可用宽度和 48dp 最小命中区依次提升草稿、引用、分隔线和表情包，已提升动作不在“更多”中重复。标题选择与更多能力在编辑器内部展开，不打开独立格式 Bottom Sheet，也不横向滚动；链接就地输入，骰子使用“骰子数 / 面数 / 修正”三字段托盘、d4/d6/d8/d10/d12/d20/d100 快捷面数、实时 canonical 预览和范围校验。异步图片/表情/草稿返回后恢复选区、焦点和键盘。

在已有主题上下文输入 `@` 会于 180ms 防抖后读取关注用户和帖内标记玩家；继续输入非空用户名时，再合并服务端确认的全站用户名结果，主题关系候选优先且按稳定 ID 去重，关系外候选标记为普通用户。服务端确认楼主或协作者权限时额外展示 `@全体玩家`。候选以根浮层靠近软键盘展示，不参与主题或帖子正文布局；浮层宽度随 320～600dp 视口收束、总高最多 200dp 并在内部滚动，窄屏键盘态额外避开 48dp 格式工具入口。关闭或选择候选都把焦点还给正文且不改变画布尺寸和当前选区；选择后以原子 Quill embed 替换当前 `@关键词` 并补一个分隔空格，Codec 固定序列化为 `[@用户名](/users/:userId)` 或 `@全体玩家`。全新主题必须先保存为服务端草稿取得真实 `threadId`，否则浮层只说明前置条件且不发请求。

正文变化先留在 `RichEditorSession` 的内存 Delta，120ms 空闲后编码为 Markdown；保存、提交、切后台、暂停或离页前强制 flush，随后主题控制器再以 700ms 防抖写本地快照。骰子表达式和服务端结果在阅读态与 Quill 编辑态共用 `WenyouDiceNode`：作为与文字共享基线的无图标行内原子节点，已结算使用 accent/onAccent，待掷使用 warningSoft/warning，内部不换行或截断；已结算节点保留至少 48dp 命中区，可打开包含安全区后整体不超过视口 80% 的 Bottom Sheet，按服务端顺序展示逐骰、小计、非零修正和总计，并在关闭后恢复触发点焦点。插入时生成 UUID `nodeId`，三字段 canonical notation 与 Markdown v3 往返保持稳定。用户与全体玩家提及同样复用透明、无图标、品牌深色 600 字重原子文字，编辑态不导航且按 userId 无损往返；阅读态用户提及保留资料页导航与 48dp 命中区。引用使用正常字形、muted 表面、3px 主色标记和紧凑圆角；行内代码使用平台等宽字体、0.88em 字号和 0.35em 圆角，Flutter Quill 内边距按 Foundation v6.2.0 正式原生边界例外处理。帖子半屏编辑器打开后自动聚焦，新建从空白处开始，编辑或恢复已有正文时把光标放到文末；点击暗区或关闭按钮会立即收起并按目标保留页面内草稿，提交请求在途时则锁定关闭和系统返回，等待明确结果。主题与帖子共用的 `RichEditorSession` 把剪贴板钩子接入真实 `QuillRawEditor` 粘贴路径：剪贴板整体为合法主题、楼层、楼中楼、回复或邀请坐标时，立即以原子传送门替换当前选区；`wenyou.site`、`www.wenyou.site` 与相对坐标统一规范化为相对路径，同时含 `post` 与 `subthread` 时以 `post` 为准。已有选区作为名称，空选区使用“传送门”，名称中的反斜线和方括号在保存时按契约转义并在阅读时恢复。混合文本、非法坐标和站外链接继续交给 Quill 普通粘贴。编辑态传送门复用 Foundation 表面，以 alphabetic baseline 的 `WidgetSpan` 与前后文字同行且不触发导航，保存时稳定序列化为标准 Markdown 链接。

## 5. API operationId 与生成类型

- 页面引导：`usersGetMe`、`threadCategoriesList`。
- 当前创建与完整主题草稿链路：`threadsFindDrafts`、`threadsFindById`、`threadsCreate`、`threadsSaveAggregate`、`threadsRemove`，使用 `DraftThreadResponseDto`、`CreateThreadDto`、`SaveThreadAggregateDto`、`ThreadDetailResponseDto`。
- 图片链路：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 收藏表情读取由 stickers 模块的 `stickersGetCollection` 提供，编辑器只消费返回的资产 ID、URL 与标准 Markdown 语义。
- 正文草稿链路：`draftsFindAll`、`draftsSlotUsage`、`draftsFindById`、`draftsCreate`、`draftsUpdate`、`draftsRemove`。
- 当前帖子上下文：`postsCreate`、`postsUpdate`、`postsUpsertBody`、`usersMentionCandidates`、`usersSearch`；主题元数据与子贴目录端点由 threads 模块消费。
- 提及主要生成类型：`UsersMentionCandidates200Response`、`MentionCandidatesResponseDto`、`MentionCandidateDto`、`UsersSearch200Response`、`PostAuthorResponseDto`。

## 6. 状态模型和数据流

`ThreadComposeState` 分离加载阶段、账号/分类引导、表单字段、Markdown 正文、本地保存状态、当前服务端主题草稿版本、切换/保存/发布动作和失败反馈；`RemoteThreadDraftsState` 独立管理草稿摘要、刷新与删除，选择后由创作控制器读取完整详情。二者归属 `threads`。`PostComposerState` 单独管理短会话 Markdown、创建幂等确认、正文/帖子版本和云端冲突，不复用主题实体状态。主题创作、云端草稿和帖子编辑器以 `SessionScope(accountId, generation)` 隔离：Access Token 刷新保持控制器与当前内容，登录、退出、会话失效或切号才重建。两个创作控制器都只接收 Markdown，不持有 Quill Delta；Quill 生命周期、文档 revision 同步、格式错误、选区和图片/表情/骰子插入由公共 `RichEditorSession` 管理。主题端口位于 `threads/application`，提及与本地快照端口位于 `editor/application`，适配器由 `main.dart` 组合根绑定。图片上传进度、失败与取消由 media 的独立上传任务控制器管理。恢复五槽位正文或切换完整主题时递增文档 revision。`MentionCandidatesController(threadId)` 独立管理当前查询的 loading/ready/failed、候选和请求失败，以 generation 丢弃乱序响应；页面只读取光标前最多 26 个字符检测提及，仓储合并关系候选和最多 20 个全站结果。`MarkdownDeltaDocument` 返回内存 Delta 和兼容问题列表，未知或损坏协议节点锁定显示并保留原 token。

## 7. 鉴权、权限和隐私规则

路由和提交都要求会话，最终权限由服务端复核；契约 4.14 后发布资格不再包含邮箱验证状态。JWT 解码只用于本地快照分区，不能替代授权。提及候选只消费服务端 `usersMentionCandidates` 与 `usersSearch` 返回的可用用户；客户端不从本地关系猜测候选，也不依据本地角色自行开放 `@全体玩家`，后端在最终发帖时继续校验提及。草稿不保存 Token 或预签名 URL；图片 PUT 使用与主鉴权 Dio 分离的客户端，日志和错误反馈不暴露预签名查询参数。私密邀请 token 是访问凭据，除用户明确保存的正文或草稿外不得写入日志、诊断、分析事件或独立缓存，也不得用于预取私密主题元数据。外链仅允许 HTTP(S)/mailto，图片仅允许安全 HTTP(S)。

## 8. 本地存储、缓存及失效规则

`LocalEditorSnapshot` 按 `thread:new:<ownerId>` 覆盖保存完整 Markdown、表单元数据、远端版本和稳定创建请求 ID；Delta 不落库。`PendingCreateOperation` 保存主题创建的规范化载荷与 pending/sending/awaiting-confirmation 状态。发布确认后只删除当前账号关联的主题快照；服务端草稿保存后更新本地远端版本。楼层/回复编辑器只保留当前页面内存状态，长内容可由用户显式保存到五槽位云草稿。候选不持久化且 Provider 随主题编辑上下文释放；最终正文只保存规范提及节点，不保存候选关系标签或查询结果。

## 9. 加载、空数据、错误、重试和冲突状态

本地恢复失败不会覆盖原数据；离页前强制落盘失败时必须由用户明确选择留下或仍然退出，不能静默丢失。服务端主题草稿箱加载失败可重试，删除失败保留条目；切换前本机写盘失败或存在待确认创建时拒绝替换，详情错配/已发布/非本人/无默认子贴均 fail-closed。分类同步失败时本地编辑继续可用并提供重试。提及查询先显示加载，空结果明确说明，任一候选响应缺失或失败都展示稳定文案与请求 ID，并可按同一关键词重试；输入变化期间旧响应不能覆盖新候选。没有 `threadId` 时不请求主题候选或全站替代候选。Codec 遇到不支持属性或冲突格式时阻止保存；图片选择后先在通用取景窗口拖动、缩放或切换比例，确认后才上传，图片节点的替代文字固定为“图片”，不以描述表单打断创作；上传任务区分选择、准备、上传、确认、处理与失败，可取消，失败时可在当前页面直接重试同一裁剪文件。创建超时或 5xx 保留待确认记录；业务码 `40912` 清理冲突记录并生成新请求 ID。聚合失败保留本地与服务端草稿版本，不显示伪成功。五槽位恢复前读取单条最新版并确认替换；主题、帖子或正文更新收到 `40002` 时保留当前正文，读取最新版后再要求用户确认是否覆盖。帖子编辑器提交期间锁定关闭；未提交内容收起后保留在当前页面输入草稿。

## 10. 跨模块约束

Delta 仅存在页面内存，后端、服务端主题草稿和 Drift 都保存 Markdown v3。提及候选接口位于 users，但查询生命周期和插入行为由 editor 管理；帖子和主题页面只传真实 `threadId`。媒体上传任务生命周期属于 `media/application`；editor 页面不直接调用上传仓储或持有 Dio 取消令牌，只消费 `COMPLETED` 结果并插入正文。骰子结果只由服务端生成。五槽位正文草稿属于[草稿](drafts.md)模块，不等同于当前主题实体的未发布草稿。参见[Codec 架构](../architecture/editor-codec.md)和[持久化](../architecture/persistence.md)。

## 11. 测试场景与验收条件

- [x] Markdown v3 规范化/节点语料与编辑器往返 v2 语料、扩展节点字段及幂等全部通过。
- [x] 新建富文本属性、分隔线、图片与骰子安全编码；未知、危险和冲突内容不静默丢失。
- [x] 本地恢复、防抖落盘、切后台调用入口、账号隔离和发布后关联清理具备状态/数据库测试。
- [x] 创建草稿 → 聚合保存/发布传递规范化载荷、幂等键及全部乐观锁版本。
- [x] 创建结果不确定时保留原载荷，继续编辑后仍先确认原请求再聚合当前正文。
- [x] 真实页面覆盖本地恢复、主题标题持久字段标签、空表单拦截、图片插入、离页落盘失败确认和 360/400/600dp 布局。
- [x] 工具栏打开五槽位正文草稿，恢复只替换正文；创建、更新、删除、满额和冲突均有状态与页面测试。
- [x] 320/360/400/600dp 工具栏按 Foundation 顺序提升正文草稿、引用、分隔线和表情包；正文草稿保持独立入口，不夹在样式按钮中间，所有主栏动作保留 48dp 命中区且与“更多”去重。
- [x] 楼层、回复和子贴正文复用 Quill/Codec/图片/五槽位工具栏，覆盖幂等创建、继续编辑、版本冲突及 360dp 可扩展半屏画布；关闭与提交保持 48dp，恢复正文后光标位于文末。
- [x] 契约 4.14 移除本地邮箱验证资格判断，登录用户按统一注册用户身份保存草稿与发布。
- [x] 主题上下文提及覆盖关系候选与全站用户合并、防抖竞态、权限化全体玩家、空错重试、原子插入和无 `threadId` 降级。
- [x] 服务端完整主题草稿覆盖列表、详情二次读取、跨设备继续编辑、当前项保护、删除确认和 360dp 布局。
- [x] 360dp 文字优先视觉基线固定标题、元信息栏、剩余正文画布和键盘 dock；发布收进顶栏，云端草稿以单一 48dp 入口按需展开保存/打开。
- [x] 主题与帖子编辑器使用 17sp/1.8 长文样式；320/360/400/600dp 键盘态完整核心格式栏固定在键盘上方，IME 最终 inset 在首帧直接生效，不随系统键盘动画逐帧位移或缩放正文画布；标题和更多在编辑器内展开，焦点与选区不丢失，并有长文与键盘视觉基线。
- [x] 主题与帖子图片选择后先裁剪再上传，图片节点的替代文字统一为“图片”；Dock 核心按钮等分利用单行宽度，并在可扩展面板键盘收起时避开系统底部安全区。
- [x] `@提及` 候选在 320/360/400dp 键盘态使用不参与正文布局的限高浮层，避开格式工具入口，关闭/插入保持焦点和选区；2× 字号无溢出，并有独立视觉基线。
- [x] 阅读态与 Quill 编辑态的骰子表达式/结果共用 Foundation v6.2.0 无图标原子节点；三字段构建、常用面数、canonical 预览、UUID nodeId、48dp 命中区、整面板 80% 高度上限、逐骰明细、焦点恢复、混排、Codec 往返和 360dp 视觉基线均有回归。
- [x] Access Token 轮转保留主题/帖子编辑控制器、当前 Markdown 和待确认幂等键；切号推进会话代次并隔离旧账号内容。
- [x] 阅读态与编辑态提及共用透明无图标原子文字并保持 userId 往返；引用正常字形、3px 标记与 em 内边距，行内代码 0.88em 字号和 0.35em 圆角均有组件与样式回归。
- [x] 已有内容中可精确往返的粗斜体、删除线、行内代码、安全链接、H2/H3、引用和 0～3 级列表恢复为 Quill 属性。
- [x] 完整消费站内引用 fixture 的 8 个 `editorPasteCases`，合法主域名/`www`/相对主题与邀请坐标规范化为传送门，转义名称无损往返，非法邀请、混合文本和站外链接保持普通粘贴。
- [x] `QuillRawEditorState.pasteText` 真实入口可即时渲染并序列化站内传送门；编辑态与阅读态传送门都有 360dp 同行视觉基线。
- [x] 任务列表、表格、围栏代码、H1/H4+、显式硬换行、原始 HTML、未知协议和超过三层列表按 Markdown v3 契约显示为可读字面文本，不声称结构化 WYSIWYG 支持。

## 12. 已知限制和后续功能

任务列表、表格、围栏代码和无法证明精确往返的组合在编辑会话中显示为可理解源码，但保存时会转义为 Markdown v3 安全字面文本，不会把原始不支持结构原样提交。全新主题在首次服务端草稿保存前不能查询提及候选；正文预览与编辑撤销尚未完成。帖子待确认创建不会在进程终止后自动恢复；不做离线自动发送。

## 13. 最近审查的契约版本和后端提交

契约 `5.4.0-dev.20260821.1`；Markdown v3；后端 `78c3fcce4a78188079a1a28cbd07731ad74cba6f`；Foundation `v6.2.0`（`4ad1eb8`）。

## 14. 相关代码与架构文档

通用会话、工具栏、提及和快照端口：`lib/features/editor/`；跨 feature 只通过根级 `editor.dart` / `editor_persistence.dart` façade 消费。主题创作页面、控制器与 API 适配器：`lib/features/threads/`；帖子工作流：`lib/features/posts/`；普通 Markdown 中立解析与 Delta Codec：`lib/core/markdown/`；数据库：`lib/core/storage/app_database.dart`。参见[Codec 架构](../architecture/editor-codec.md)、[Foundation 实现审计](../architecture/foundation-compliance-audit.md)、[草稿](drafts.md)、[媒体](media.md)、[语义图标](../architecture/icons.md)、[Foundation v6.2.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.2.0/docs/platforms/mobile.md)。

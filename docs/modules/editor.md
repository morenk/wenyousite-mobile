# 编辑器

状态：`in_progress`

## 1. 模块目标与非目标

基于 Flutter Quill 提供移动端富文本输入与工具栏，以自研 Markdown v2 ↔ Delta Codec 支持安全链接、图片、骰子、提及、协议节点和本地防丢。当前已交付创建主题编辑页、帖子/回复/子贴正文复用编辑器及对应发布主链；主题元数据和子贴目录由 threads 模块独立管理，正文预览仍待后续切片，V1 不离线自动发布。

## 2. 用户角色与使用场景

已登录用户在 `/compose/thread` 创建公开或私密主题，保存服务端主题草稿或发布；也可在主题详情和楼中楼创建或编辑普通帖子，有 capability 的楼主/协作者可编辑子贴正文。邮箱未验证时仍可本地编辑和保存主题草稿，但不能发布；游客由路由或写入口登录后回到原目标。

## 3. 页面、入口和导航关系

应用壳创建按钮进入 `/compose/thread`。创建页标题为“写主题”，页面加载当前用户的本地快照、账号发布状态和动态分类；AppBar 只保留“云端草稿”和紧凑“发布”，云端入口按需展开“保存当前主题 / 打开云端草稿”，不在正文前或页面底部常驻整行按钮。邮箱未验证时可在页面内进入 `/me/security/verify-email?returnTo=/compose/thread`，验证返回后重新同步发布资格；发布成功后替换到 `/threads/:threadId`。主题详情和独立楼中楼以不可拖拽的全高编辑器创建或编辑楼层、回复与子贴正文：紧凑顶栏承载关闭、目标和提交，正文使用无卡片包裹的连续画布。编辑器正文图片可进入全屏查看页，系统返回、双击缩放、捏合和平移可用，未放大时可下滑关闭。

## 4. 用户操作流程

打开页面时以 JWT 的 `sub` 仅作本地账号分区，读取完整 Markdown 快照，再异步用 `usersGetMe` 和 `threadCategoriesList` 确认服务端身份、邮箱状态与可用分类。首屏按标题 → 主工具栏 → 随窗口高度在 340–560dp 间扩展的正文画布 → 本地保存状态排列；360×800dp 基线正文不少于 440dp，标题和正文不套装饰卡片。分类、可见性和标签折叠进“发布设置”，需要时再展开；发布始终从 48dp 紧凑顶栏提交。AppBar 云端入口先展开保存/打开两项触控目标：保存当前完整主题实体，或读取本人未发布主题摘要并在明确覆盖提示后恢复完整表单和全部版本。工具栏严格保持 Foundation v1.2.1 的正文/H2/H3、粗体、斜体、图片和更多；服务端开启表情能力时，宽屏工具栏与更多面板可从本人收藏插入规范 sticker 原子节点；更多面板还包含安全链接、行内代码、引用、列表、分隔线、骰子、正文草稿和删除线。“正文草稿”打开五槽位纯正文面板，与顶栏完整主题草稿入口保持分层。

在已有主题上下文输入 `@` 会于 180ms 防抖后读取关注用户和帖内标记玩家；继续输入非空用户名时，再合并服务端确认的全站用户名结果，主题关系候选优先且按稳定 ID 去重，关系外候选标记为普通用户。服务端确认楼主或协作者权限时额外展示 `@全体玩家`。选择候选后以原子 Quill embed 替换当前 `@关键词` 并补一个分隔空格，Codec 固定序列化为 `[@用户名](/users/:userId)` 或 `@全体玩家`。全新主题必须先保存为服务端草稿取得真实 `threadId`，否则候选区只说明前置条件且不发请求。

正文变化先把内存 Delta 编码为 Markdown。主题创建页 700ms 防抖写本地，并在切后台、暂停或离页前强制落盘；帖子全高编辑器打开后自动聚焦，新建从空白处开始，编辑或恢复已有正文时把光标放到文末；它不自动落地，但可手动存入五槽位正文草稿且有明确丢弃确认。主题首次保存或发布持久化规范化创建载荷与 `clientRequestId`，调用 `threadsCreate` 后再调用 `threadsSaveAggregate`。楼层/回复创建在当前编辑会话内固定 `clientRequestId`；响应不确定时先重试原载荷，即使用户继续编辑，也只在确认创建后用乐观锁更新当前正文。

## 5. API operationId 与生成类型

- 页面引导：`usersGetMe`、`threadCategoriesList`。
- 当前创建与完整主题草稿链路：`threadsFindDrafts`、`threadsFindById`、`threadsCreate`、`threadsSaveAggregate`、`threadsRemove`，使用 `DraftThreadResponseDto`、`CreateThreadDto`、`SaveThreadAggregateDto`、`ThreadDetailResponseDto`。
- 图片链路：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 收藏表情读取由 stickers 模块的 `stickersGetCollection` 提供，编辑器只消费返回的资产 ID、URL 与标准 Markdown 语义。
- 正文草稿链路：`draftsFindAll`、`draftsSlotUsage`、`draftsFindById`、`draftsCreate`、`draftsUpdate`、`draftsRemove`。
- 当前帖子上下文：`postsCreate`、`postsUpdate`、`postsUpsertBody`、`usersMentionCandidates`、`usersSearch`；主题元数据与子贴目录端点由 threads 模块消费。
- 提及主要生成类型：`UsersMentionCandidates200Response`、`MentionCandidatesResponseDto`、`MentionCandidateDto`、`UsersSearch200Response`、`PostAuthorResponseDto`。

## 6. 状态模型和数据流

`ThreadComposeState` 分离加载阶段、账号/分类引导、表单字段、Markdown 正文、本地保存状态、当前服务端主题草稿版本、切换/保存/发布动作和失败反馈；`RemoteThreadDraftsState` 独立管理草稿摘要、刷新与删除，选择后由创作控制器读取完整详情。`PostComposerState` 单独管理短会话 Markdown、创建幂等确认、正文/帖子版本和云端冲突，不复用主题实体状态。两个创作控制器都只接收 Markdown，不持有 Quill Delta；恢复五槽位正文或切换完整主题时递增文档 revision。`MentionCandidatesController(threadId)` 独立管理当前查询的 loading/ready/failed、候选和请求失败，以 generation 丢弃乱序响应；仓储先保留 following/player 关系候选，再合并最多 20 个全站结果，输入触发范围和原子替换仅存在于编辑器页面内存。`MarkdownDeltaDocument` 返回内存 Delta 和兼容问题列表，未知或损坏协议节点锁定显示并保留原 token。

## 7. 鉴权、权限和隐私规则

路由和提交都要求会话，邮箱验证及最终权限由服务端复核。`40107` 不清会话，仍允许编辑和保存草稿；进入验证页前强制落盘，返回后重新调用本人资料/分类引导，不直接改写本地验证布尔值。JWT 解码只用于本地快照分区，不能替代授权。提及候选只消费服务端 `usersMentionCandidates` 与 `usersSearch` 返回的可用用户；客户端不从本地关系猜测候选，也不依据本地角色自行开放 `@全体玩家`，后端在最终发帖时继续校验提及。草稿不保存 Token 或预签名 URL；图片 PUT 使用与主鉴权 Dio 分离的客户端，日志和错误反馈不暴露预签名查询参数。外链仅允许 HTTP(S)/mailto，图片仅允许安全 HTTP(S)。

## 8. 本地存储、缓存及失效规则

`LocalEditorSnapshot` 按 `thread:new:<ownerId>` 覆盖保存完整 Markdown、表单元数据、远端版本和稳定创建请求 ID；Delta 不落库。`PendingCreateOperation` 保存主题创建的规范化载荷与 pending/sending/awaiting-confirmation 状态。发布确认后只删除当前账号关联的主题快照；服务端草稿保存后更新本地远端版本。楼层/回复编辑器只保留当前页面内存状态，长内容可由用户显式保存到五槽位云草稿。候选不持久化且 Provider 随主题编辑上下文释放；最终正文只保存规范提及节点，不保存候选关系标签或查询结果。

## 9. 加载、空数据、错误、重试和冲突状态

本地恢复失败不会覆盖原数据；离页或进入邮箱验证前强制落盘失败时必须由用户明确选择留下或仍然退出，不能静默丢失。服务端主题草稿箱加载失败可重试，删除失败保留条目；切换前本机写盘失败或存在待确认创建时拒绝替换，详情错配/已发布/非本人/无默认子贴均 fail-closed。分类/账号同步失败时本地编辑继续可用并提供重试；已知未验证事实与提交返回 `40107` 都提供验证入口。提及查询先显示加载，空结果明确说明，任一候选响应缺失或失败都展示稳定文案与请求 ID，并可按同一关键词重试；输入变化期间旧响应不能覆盖新候选。没有 `threadId` 时不请求主题候选或全站替代候选。Codec 遇到不支持属性或冲突格式时阻止保存；图片可取消并区分准备、上传、确认、处理与失败。创建超时或 5xx 保留待确认记录；业务码 `40912` 清理冲突记录并生成新请求 ID。聚合失败保留本地与服务端草稿版本，不显示伪成功。五槽位恢复前读取单条最新版并确认替换；主题、帖子或正文更新收到 `40002` 时保留当前正文，读取最新版后再要求用户确认是否覆盖。帖子编辑器提交时锁定关闭，未提交变更离开前必须确认。

## 10. 跨模块约束

Delta 仅存在页面内存，后端、服务端主题草稿和 Drift 都保存 Markdown v2。提及候选接口位于 users，但查询生命周期和插入行为由 editor 管理；帖子和主题页面只传真实 `threadId`。媒体只有达到 `COMPLETED` 才能插入正文；骰子结果只由服务端生成。五槽位正文草稿属于[草稿](drafts.md)模块，不等同于当前主题实体的未发布草稿。参见[Codec 架构](../architecture/editor-codec.md)和[持久化](../architecture/persistence.md)。

## 11. 测试场景与验收条件

- [x] 两套 Markdown v2 黄金语料、扩展节点字段与往返幂等全部通过。
- [x] 新建富文本属性、分隔线、图片与骰子安全编码；未知、危险和冲突内容不静默丢失。
- [x] 本地恢复、防抖落盘、切后台调用入口、账号隔离和发布后关联清理具备状态/数据库测试。
- [x] 创建草稿 → 聚合保存/发布传递规范化载荷、幂等键及全部乐观锁版本。
- [x] 创建结果不确定时保留原载荷，继续编辑后仍先确认原请求再聚合当前正文。
- [x] 真实页面覆盖本地恢复、空表单拦截、图片插入、离页落盘失败确认和 360/400/600dp 布局。
- [x] 工具栏打开五槽位正文草稿，恢复只替换正文；创建、更新、删除、满额和冲突均有状态与页面测试。
- [x] 楼层、回复和子贴正文复用 Quill/Codec/图片/五槽位工具栏，覆盖幂等创建、继续编辑、版本冲突及 360dp 全高纯正文画布；关闭与提交保持 48dp，恢复正文后光标位于文末。
- [x] 未验证邮箱保留编辑/草稿能力，进入验证前落盘，成功返回后刷新服务端发布资格。
- [x] 主题上下文提及覆盖关系候选与全站用户合并、防抖竞态、权限化全体玩家、空错重试、原子插入和无 `threadId` 降级。
- [x] 服务端完整主题草稿覆盖列表、详情二次读取、跨设备继续编辑、当前项保护、删除确认和 360dp 布局。
- [x] 360dp 文字优先视觉基线固定标题和 440dp 正文画布先于发布设置；发布收进顶栏，云端草稿以单一 48dp 入口按需展开保存/打开，页面底部不再常驻两条整宽动作，发布设置默认折叠并可完整展开。
- [ ] 已有内容的完整普通 Markdown 富文本解码、预览和其他发帖上下文完成。

## 12. 已知限制和后续功能

普通 Markdown 解码仍以源码文本为主，当前工具栏创建的新格式可安全编码为 Markdown，但打开已有粗体、标题、列表时尚未全部还原成 Quill 属性。全新主题在首次服务端草稿保存前不能查询提及候选；正文预览和编辑撤销尚未完成。帖子待确认创建不会在进程终止后自动恢复；不做离线自动发送。

## 13. 最近审查的契约版本和后端提交

契约 `4.7.0-dev.20260811.1`；Markdown v2；后端 `143618951b0746b049f9d6ac9718b35e4139847d`；Foundation `v1.2.1`（`3efa0643cc629a51e0663b696bc241be581aef04`）。

## 14. 相关代码与架构文档

页面与状态：`lib/features/editor/`；媒体上传：`lib/features/media/`；Codec：`lib/core/markdown/markdown_delta_codec.dart`；数据库：`lib/core/storage/app_database.dart`。参见[Codec 架构](../architecture/editor-codec.md)、[草稿](drafts.md)、[媒体](media.md)。

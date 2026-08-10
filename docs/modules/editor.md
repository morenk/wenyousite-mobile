# 编辑器

状态：`in_progress`

## 1. 模块目标与非目标

基于 Flutter Quill 提供移动端富文本输入与工具栏，以自研 Markdown v2 ↔ Delta Codec 支持安全链接、图片、骰子、协议节点和本地防丢。当前已交付创建主题编辑页、帖子/回复/子贴正文复用编辑器及对应发布主链；主题元数据编辑、提及候选和预览仍待后续切片，V1 不离线自动发布。

## 2. 用户角色与使用场景

已登录用户在 `/compose/thread` 创建公开或私密主题，保存服务端主题草稿或发布；也可在主题详情和楼中楼创建或编辑普通帖子，有 capability 的楼主/协作者可编辑子贴正文。邮箱未验证时仍可本地编辑和保存主题草稿，但不能发布；游客由路由或写入口登录后回到原目标。

## 3. 页面、入口和导航关系

应用壳创建按钮进入 `/compose/thread`。页面加载当前用户的本地快照、账号发布状态和动态分类；发布成功后替换到 `/threads/:threadId`。主题详情和独立楼中楼以不可拖拽的全高底部编辑器创建或编辑楼层、回复与子贴正文。编辑器正文图片可进入全屏查看页，系统返回、双击缩放、捏合和平移可用，未放大时可下滑关闭。

## 4. 用户操作流程

打开页面时以 JWT 的 `sub` 仅作本地账号分区，读取完整 Markdown 快照，再异步用 `usersGetMe` 和 `threadCategoriesList` 确认服务端身份、邮箱状态与可用分类。工具栏提供正文/H2/H3、粗体、斜体、图片和更多；更多面板包含安全链接、行内代码、引用、列表、分隔线、骰子、正文草稿和删除线。“正文草稿”打开五槽位纯正文面板，页面底部“保存到服务端草稿”继续保存完整主题实体。

正文变化先把内存 Delta 编码为 Markdown。主题创建页 700ms 防抖写本地，并在切后台、暂停或离页前强制落盘；帖子底部编辑器不自动落地，但可手动存入五槽位正文草稿且有明确丢弃确认。主题首次保存或发布持久化规范化创建载荷与 `clientRequestId`，调用 `threadsCreate` 后再调用 `threadsSaveAggregate`。楼层/回复创建在当前编辑会话内固定 `clientRequestId`；响应不确定时先重试原载荷，即使用户继续编辑，也只在确认创建后用乐观锁更新当前正文。

## 5. API operationId 与生成类型

- 页面引导：`usersGetMe`、`threadCategoriesList`。
- 当前创建链路：`threadsCreate`、`threadsSaveAggregate`，使用 `CreateThreadDto`、`SaveThreadAggregateDto`、`ThreadDetailResponseDto`。
- 图片链路：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 正文草稿链路：`draftsFindAll`、`draftsSlotUsage`、`draftsFindById`、`draftsCreate`、`draftsUpdate`、`draftsRemove`。
- 当前帖子上下文：`postsCreate`、`postsUpdate`、`postsUpsertBody`；后续：`usersMentionCandidates`、`threadsUpdate`、`subthreadsCreate`、`subthreadsUpdate`。

## 6. 状态模型和数据流

`ThreadComposeState` 分离加载阶段、账号/分类引导、表单字段、Markdown 正文、本地保存状态、服务端主题草稿版本、提交动作和失败反馈。`PostComposerState` 单独管理短会话 Markdown、创建幂等确认、正文/帖子版本和云端冲突，不复用主题实体状态。两个控制器都只接收 Markdown，不持有 Quill Delta；恢复五槽位正文时只递增文档 revision。`MarkdownDeltaDocument` 返回内存 Delta 和兼容问题列表，未知或损坏协议节点锁定显示并保留原 token。

## 7. 鉴权、权限和隐私规则

路由和提交都要求会话，邮箱验证及最终权限由服务端复核。JWT 解码只用于本地快照分区，不能替代授权。草稿不保存 Token 或预签名 URL；图片 PUT 使用与主鉴权 Dio 分离的客户端，日志和错误反馈不暴露预签名查询参数。外链仅允许 HTTP(S)/mailto，图片仅允许安全 HTTP(S)。

## 8. 本地存储、缓存及失效规则

`LocalEditorSnapshot` 按 `thread:new:<ownerId>` 覆盖保存完整 Markdown、表单元数据、远端版本和稳定创建请求 ID；Delta 不落库。`PendingCreateOperation` 保存主题创建的规范化载荷与 pending/sending/awaiting-confirmation 状态。发布确认后只删除当前账号关联的主题快照；服务端草稿保存后更新本地远端版本。楼层/回复编辑器只保留当前页面内存状态，长内容可由用户显式保存到五槽位云草稿。

## 9. 加载、空数据、错误、重试和冲突状态

本地恢复失败不会覆盖原数据；离页强制落盘失败时必须由用户明确选择留下或仍然退出，不能静默丢失。分类/账号同步失败时本地编辑继续可用并提供重试。Codec 遇到不支持属性或冲突格式时阻止保存；图片可取消并区分准备、上传、确认、处理与失败。创建超时或 5xx 保留待确认记录；业务码 `40912` 清理冲突记录并生成新请求 ID。聚合失败保留本地与服务端草稿版本，不显示伪成功。五槽位恢复前读取单条最新版并确认替换；主题、帖子或正文更新收到 `40002` 时保留当前正文，读取最新版后再要求用户确认是否覆盖。帖子编辑器提交时锁定关闭，未提交变更离开前必须确认。

## 10. 跨模块约束

Delta 仅存在页面内存，后端、服务端主题草稿和 Drift 都保存 Markdown v2。媒体只有达到 `COMPLETED` 才能插入正文；骰子结果只由服务端生成。五槽位正文草稿属于[草稿](drafts.md)模块，不等同于当前主题实体的未发布草稿。参见[Codec 架构](../architecture/editor-codec.md)和[持久化](../architecture/persistence.md)。

## 11. 测试场景与验收条件

- [x] 两套 Markdown v2 黄金语料、扩展节点字段与往返幂等全部通过。
- [x] 新建富文本属性、分隔线、图片与骰子安全编码；未知、危险和冲突内容不静默丢失。
- [x] 本地恢复、防抖落盘、切后台调用入口、账号隔离和发布后关联清理具备状态/数据库测试。
- [x] 创建草稿 → 聚合保存/发布传递规范化载荷、幂等键及全部乐观锁版本。
- [x] 创建结果不确定时保留原载荷，继续编辑后仍先确认原请求再聚合当前正文。
- [x] 真实页面覆盖本地恢复、空表单拦截、图片插入、离页落盘失败确认和 360dp 布局。
- [x] 工具栏打开五槽位正文草稿，恢复只替换正文；创建、更新、删除、满额和冲突均有状态与页面测试。
- [x] 楼层、回复和子贴正文复用 Quill/Codec/图片/五槽位工具栏，覆盖幂等创建、继续编辑、版本冲突及 360dp 完整写入页面。
- [ ] 提及候选、已有内容的完整普通 Markdown 富文本解码、预览和其他发帖上下文完成。

## 12. 已知限制和后续功能

普通 Markdown 解码仍以源码文本为主，当前工具栏创建的新格式可安全编码为 Markdown，但打开已有粗体、标题、列表时尚未全部还原成 Quill 属性。提及插入、收藏表情、预览、编辑撤销和主题元数据编辑尚未完成。帖子待确认创建不会在进程终止后自动恢复；不做离线自动发送。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`；Foundation `v1.1.0`（`4974b09a29d5d1c9632f4b2683c8d36c9e3c69bd`）。

## 14. 相关代码与架构文档

页面与状态：`lib/features/editor/`；媒体上传：`lib/features/media/`；Codec：`lib/core/markdown/markdown_delta_codec.dart`；数据库：`lib/core/storage/app_database.dart`。参见[Codec 架构](../architecture/editor-codec.md)、[草稿](drafts.md)、[媒体](media.md)。

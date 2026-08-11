# 站内私聊

状态：`in_progress`

## 1. 模块目标与非目标

实现服务端 capability 控制的站内一对一私聊：会话、消息请求、历史与增量消息、首条消息、后续发送、接受/拒绝、归档、已读、撤回和未读角标形成完整移动闭环。当前不实现 FCM 后台送达、离线消息队列或本机私聊正文持久化；输入器已通过 stickers 模块选择收藏表情，消息图片或表情也可加入本人收藏。

## 2. 用户角色与使用场景

登录用户可从其他用户公开主页发起私聊，在通知页进入私信中心，处理收到的消息请求并查看会话。互相关注时首条消息直接建立会话，否则作为只能发送一次的消息请求；请求接收方接受后双方继续发送，拒绝会删除首条消息。游客和服务端未开放 capability 时只能看到安全收敛状态，不读取私聊数据。

## 3. 页面、入口和导航关系

私信中心使用受保护路径 `/messages`，也可作为底部“消息”分支内“私信”页签的嵌入内容；新私聊使用 `/messages/new/:userId`，会话使用 `/messages/:conversationId`。其他用户主页在确认当前登录身份且 capability 开启后展示“发私聊”。已有 ACCEPTED/PENDING 联系从新私聊页替换到原会话；DECLINED/CANCELED/UNAVAILABLE 按服务端 `canInitiate` 展示重新建立或受限说明，不猜测新目标。

## 4. 用户操作流程

中心按会话、请求、归档三类读取并游标分页；进入会话并行读取会话事实与首批消息，向上加载历史，每 8 秒用最后一条消息 ID 增量读取，显示到最新收到消息后标记已读。文本、一张图片或一个独占收藏表情发送前规范化载荷并生成 UUID v4；不明确失败保留同一 `clientRequestId` 供原请求重试。收到的请求图片默认隐藏，用户点按或接受请求后才加载，查看前也不显示收藏入口；拒绝需二次确认。已接受会话和发出的待处理请求可归档，自己十分钟内的消息可二次确认撤回，撤回待处理首条消息会取消请求并退出会话。

## 5. API operationId 与生成类型

- `directConversationsFindAll`、`directConversationsUnread`、`directConversationsFindByUser`、`directConversationsFindById`、`directConversationsMessages`。
- `directConversationsCreate`、`directConversationsSend`、`directConversationsHandleRequest`、`directConversationsArchive`、`directConversationsMarkRead`、`directMessagesRecall`。
- 新私聊对象资料复用 `usersGetUser`，图片选择与上传复用 media 模块的 `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 主要生成类型：`DirectConversationResponseDto`、`DirectMessageResponseDto`、`DirectConversationLookupResponseDto`、`DirectUnreadCountResponseDto`、`CreateDirectConversationDto`、`CreateDirectMessageDto`、`HandleDirectRequestDto`、`SetDirectConversationArchiveDto`、`MarkDirectConversationReadDto`、`DirectMessageRecallResponseDto`。

## 6. 状态模型和数据流

会话列表按 view 使用独立 autoDispose family；未读消息与待处理请求由进程内控制器每 30 秒读取。会话详情维护升序消息、历史 cursor、增量 anchor、单一写动作和失败草稿，轮询与写动作互斥合并，按 ID 去重并用 `createdAt + id` 排序；新私聊目标解析使用独立控制器文件但保持原 provider 接口。加载、提交与失败状态位于 application，domain 只保留业务模型和草稿校验。仓储拒绝重复 ID、异常游标、会话 ID/目标用户不匹配、撤回后仍携带正文/媒体、非安全 URL、状态与权限矛盾以及未读总数不一致；控制器额外确认每条消息包含当前会话的另一位参与者，异常时整页停止展示。接受、拒绝、已读和撤回成功后重新校准角标，角标刷新失败不回滚已确认的业务结果。

## 7. 鉴权、权限和隐私规则

三条路由都要求 authenticated，会话权限完全以服务端 `canSend/canAccept/canDecline/isBlocked` 和状态投影为准。客户端不记录完整私聊正文、图片预签名 URL、Token 或消息请求载荷；正文、失败草稿和上传中的媒体只存在于页面进程内。陌生请求图片在明确查看前不发起网络加载；撤回响应仍含正文或媒体时拒绝展示。`40107` 仅在接受请求或首条消息的可恢复状态引导邮箱验证，`40305/40306`、`40411/40412` 与 `40906`～`40909` 使用稳定业务提示。

## 8. 本地存储、缓存及失效规则

私聊正文、会话列表、未读数、失败幂等草稿和增量锚点不写 Drift、SharedPreferences 或文件；页面销毁、退出登录、切号或进程终止即释放。图片使用共享安全 HTTP(S) 缓存，上传源字节只在用户明确选择后的输入器生命周期内存在。回前台、进入中心、会话已读/请求处理/撤回和下拉刷新会重新读取服务端事实；应用终止后的失败首条消息不会后台自动重放。

## 9. 加载、空数据、错误、重试和冲突状态

能力未开放、中心为空、请求为空、归档为空、首屏失败、历史/列表分页失败、会话不可访问、发送受限和请求已取消分别展示。cursor 收到 `40007` 时从首页重载；加载更多失败保留既有内容与请求 ID。不明确创建或发送响应视为失败并保留稳定幂等键，不伪装成功；用户可用原请求重试或明确放弃。接受请求的邮箱验证错误保留首条消息，拒绝失败不删除本机显示，撤回超过十分钟在请求前本地拦截且仍以服务端结果为准。

## 10. 跨模块约束

capability 由 app 组合层从启动契约注入，前台生命周期由应用壳承接；入口由 notifications/users 提供，目标资料由 users 读取，图片上传由 media 完成，收藏选择与快速收藏由 stickers 提供，邮箱验证由 auth/settings 恢复。私聊 feature 不导入 app-shell 的具体 provider。视觉只复用 Foundation v1.1.0 的 Token、状态横幅、按钮和最小触控目标；会话是带分隔线的连续列表，未读通过角标表达，不用逐条面板制造卡片层级。私聊图片不得复用 Markdown 正文解析器；表情发送复用本模块 `stickerAssetId` 的独占消息约束。

## 11. 测试场景与验收条件

- [x] 11 个 Direct Messages operationId 的读取、写入、生成 DTO 和空响应均有仓储测试。
- [x] 三类会话、游标失效、历史/增量合并、已读校准、稳定幂等重试和请求处理均有控制器测试。
- [x] 撤回隐私、目标/参与者不匹配、重复消息、异常未读数和不安全媒体采用 fail-closed。
- [x] 中心、会话、新私聊的主路径、错误恢复与 360dp、400dp、600dp 布局通过 Widget 测试。
- [x] 私聊路由登录守卫、用户主页入口和 capability 关闭状态通过测试。
- [ ] 使用两个公网专用账号完成请求、接受、发送、图片、已读、归档和撤回真机联调。

## 12. 已知限制和后续功能

当前用前台 8 秒轮询读取新消息，不做 WebSocket、SSE、FCM 后台唤醒或系统通知；进程终止后依赖重新进入页面读取。输入器支持文本、单张图片与独占收藏表情；失败幂等草稿不跨重启保存，因此不明确失败后若用户终止应用，应先重新查看会话事实而不是生成新请求盲发。

## 13. 最近审查的契约版本和后端提交

契约 `4.5.2-dev.20260811.1`；Markdown v2；后端 `f99d59d832bb6136d6ff88f5142d1c5b6f9239d2`。

## 14. 相关代码与架构文档

代码入口：`lib/features/direct_messages/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[站内通知](notifications.md)、[用户与资料](users.md)、[媒体](media.md)和[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

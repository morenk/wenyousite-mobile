# 站内私聊

状态：`in_progress`

## 1. 模块目标与非目标

实现服务端 capability 控制的站内一对一私聊：会话、消息请求、历史与增量消息、首条消息、后续发送、接受/拒绝、归档、已读、撤回、收到消息举报和未读角标形成完整移动闭环。当前不实现 FCM 后台送达、离线消息队列或本机私聊正文持久化；输入器已通过 stickers 模块选择收藏表情，消息图片或表情也可加入本人收藏。

## 2. 用户角色与使用场景

登录用户可从其他用户公开主页发起私聊，在消息中心进入私聊页签，处理收到的消息请求并查看会话。互相关注时首条消息直接建立会话，否则作为只能发送一次的消息请求；请求接收方接受后双方继续发送，拒绝会删除首条消息。游客和服务端未开放 capability 时只能看到安全收敛状态，不读取私聊数据。

## 3. 页面、入口和导航关系

私聊列表的规范路径是底部“消息”分支内的 `/notifications?section=directMessages`；旧 `/messages` 兼容重定向到该地址。新私聊继续使用 `/messages/new/:userId`，会话继续使用 `/messages/:conversationId`。其他用户主页在确认当前登录身份且 capability 开启后展示“发私聊”。已有 ACCEPTED/PENDING 联系从新私聊页替换到原会话；DECLINED/CANCELED/UNAVAILABLE 按服务端 `canInitiate` 展示重新建立或受限说明，不猜测新目标。

## 4. 用户操作流程

私聊图片从相册选择后先进入单图裁剪，用户确认取景后才启动上传；裁剪关闭不改动当前文字、选区或焦点。

中心按会话、请求、归档三类读取并游标分页；进入会话并行读取会话事实与首批消息，时间线以最新消息为反向列表起点，首次进入或重新打开都直接停在最新消息，不恢复上一次历史阅读位置。使用最后一条已确认消息 ID 增量读取，显示到最新收到消息后标记已读。活跃会话常态每 8 秒同步，发送成功和回到前台后进入短周期追赶，退到后台暂停；轮询始终静默且不伪造在线、输入中或已读回执。发送会立即插入本地气泡并清空输入器，HTTP 成功按 `clientRequestId` 原位替换，失败只标记对应气泡且可复用原幂等键重试，不阻塞后续输入。会话与首条消息页面底部复用单体内联输入 dock：图片、收藏表情、可增长到五行的正文和发送同排，字数只在接近上限时出现；点击消息区或输入框外的其他区域会收起软键盘并退出输入焦点，当前文字仍保留在本页输入框内。收藏表情从按钮上方打开可滚动锚点面板，打开和选择期间保留输入焦点、选区与键盘。消息长按在气泡旁打开最多五列的图标操作气泡，复制、收藏、撤回、举报、验证、重试和删除按权限出现，超过五项自动换行；失败状态图标打开同一菜单。举报只出现在收到、未撤回且服务端已确认的消息上，提交目标是稳定 messageId；本人消息、乐观消息、失败消息和撤回消息都不显示。发送按钮按统一语义区分可用、处理中和不可用状态，避免把可发送状态误读为禁用；页面关闭 Scaffold 自动 inset，dock 按 `viewInsets` 一帧到达最终键盘位置，不播放位移动画。收到的请求图片默认隐藏，用户点按或接受请求后才加载，查看前也不显示收藏入口；拒绝需二次确认。已接受会话和发出的待处理请求可归档，自己十分钟内的消息可二次确认撤回，撤回待处理首条消息会取消请求并退出会话。

新私聊页同时读取已有会话事实和目标公开资料。只有 `isFollowing && isFollowedBy` 时显示“你们已互相关注”与直接建立文案；其他可发起用户才显示“这会先作为消息请求”。资料关系只用于发送前文案，新会话的 `ACCEPTED/PENDING` 最终仍以创建接口回包为准。复制、收藏表情、接受/拒绝请求、归档和撤回的短反馈使用 floating SnackBar，底部同时留出键盘、安全区和输入 dock 间距，不覆盖输入框。

## 5. API operationId 与生成类型

- `directConversationsFindAll`、`directConversationsUnread`、`directConversationsFindByUser`、`directConversationsFindById`、`directConversationsMessages`。
- `directConversationsCreate`、`directConversationsSend`、`directConversationsHandleRequest`、`directConversationsArchive`、`directConversationsMarkRead`、`directMessagesRecall`。
- 收到消息举报复用 reports 模块的 `reportsCreate`，目标类型固定为 `DIRECT_MESSAGE`。
- 新私聊对象资料复用 `usersGetUser`，图片选择与上传复用 media 模块的 `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 主要生成类型：`DirectConversationResponseDto`、`DirectMessageResponseDto`、`DirectConversationLookupResponseDto`、`DirectUnreadCountResponseDto`、`CreateDirectConversationDto`、`CreateDirectMessageDto`、`HandleDirectRequestDto`、`SetDirectConversationArchiveDto`、`MarkDirectConversationReadDto`、`DirectMessageRecallResponseDto`。

## 6. 状态模型和数据流

未读控制器只负责单次读取；应用壳在认证且前台时用唯一的 30 秒定时器统一触发通知、未读消息与待处理请求刷新，进入后台或退出登录立即停止。

会话列表按 view 使用独立 autoDispose family；未读消息与待处理请求由进程内控制器每 30 秒读取。会话详情维护升序消息、历史 cursor、服务端增量 anchor 与本地发送状态；本地消息使用 `optimistic:<clientRequestId>` 标识和 `sending / failed / sent` 状态，服务端回包原位替换，增量 anchor 永远跳过本地消息。历史分页、最近窗口刷新、增量轮询和乐观消息按 ID 去重并用 `createdAt + id` 排序，最近窗口对账不会丢弃已经加载的历史。会话列表的 `contentPreview` 直接消费服务端脱敏投影：站内传送门转为可读名称、邀请 token 转为“邀请传送门”并规范化空白；完整消息页和复制仍使用服务端返回的原始正文，客户端不从完整正文反推列表预览。私聊读写端口位于 `direct_messages/application`，API 适配器由 `main.dart` 组合根绑定，控制器不导入具体 data 仓储。图片选择、进度、失败、同文件重试和取消由 `media/application` 按输入器实例管理；私聊状态只接收上传完成后的 `mediaId`，不持有原始字节、Dio 取消令牌或预签名 URL。新私聊目标解析使用独立控制器文件并通过 `users/application` 公共端口读取目标资料，保持原 provider 接口且不依赖 users data。加载、提交与失败状态位于 application，domain 只保留业务模型和草稿校验。data 适配器拒绝重复 ID、异常游标、会话 ID/目标用户不匹配、撤回后仍携带正文/媒体、非安全 URL、状态与权限矛盾以及未读总数不一致；控制器额外确认每条消息包含当前会话的另一位参与者，异常时整页停止展示。接受、拒绝、已读和撤回成功后重新校准角标，角标刷新失败不回滚已确认的业务结果。

## 7. 鉴权、权限和隐私规则

三条路由都要求 authenticated，会话权限完全以服务端 `canSend/canAccept/canDecline/isBlocked` 和状态投影为准。客户端不记录完整私聊正文、图片预签名 URL、Token 或消息请求载荷；正文、失败草稿和上传中的媒体只存在于页面进程内。陌生请求图片在明确查看前不发起网络加载；撤回响应仍含正文或媒体时拒绝展示。举报由 reports 模块提交，后端再次复核当前用户确为消息接收者；举报表单和日志不复制完整私信正文。契约 4.14 后所有注册用户使用统一身份，私信写入不再检查邮箱验证状态。`40305/40306`、`40411/40412` 与 `40906`～`40909` 使用稳定业务提示。

## 8. 本地存储、缓存及失效规则

私聊正文、会话列表、未读数、失败幂等草稿和增量锚点不写 Drift、SharedPreferences 或文件；页面销毁、退出登录、切号或进程终止即释放。图片使用共享安全 HTTP(S) 缓存，上传源字节只在共享上传任务内短暂保留：失败时仅供当前输入器重试，取消、放弃、成功或页面释放都会清除。回前台、进入中心、会话已读/请求处理/撤回和下拉刷新会重新读取服务端事实；应用终止后的失败首条消息不会后台自动重放。

## 9. 加载、空数据、错误、重试和冲突状态

中心、请求与归档空态只陈述当前状态，不重复说明发起或下拉方式。

会话列表首次读取使用连续列表 Skeleton，会话详情首次读取使用详情结构 Skeleton；能力未开放、中心为空、请求为空、归档为空、首屏失败、历史/列表分页失败、会话不可访问、发送受限和请求已取消分别展示。cursor 收到 `40007` 时从首页重载；加载更多失败保留既有内容与请求 ID，并保持当前可见消息位置。不明确创建或发送响应视为失败并保留稳定幂等键，不伪装成功；失败状态和重试入口跟随对应气泡，输入器继续可用。用户阅读历史时新消息不抢滚动，只显示“新消息”浮标；接近底部或发送本人消息时自动跟随。接受请求失败保留首条消息，拒绝失败不删除本机显示，撤回超过十分钟在请求前本地拦截且仍以服务端结果为准。

## 10. 跨模块约束

会话与消息时间统一使用 Foundation 72 小时格式，并向辅助技术提供 `yyyy-MM-dd HH:mm` 完整时间；具名会话头像失败回退首字符，停用账号始终显示不可用身份图标。

capability 由 app 组合层从启动契约注入，前台生命周期由应用壳承接；入口由 notifications/users 提供，目标资料由 users 读取，图片上传只依赖 media application 端口和任务控制器，收藏选择与快速收藏由 stickers 提供，举报表单与提交由 reports 提供，auth 只提供统一登录会话。私聊 presentation 不导入 media data、reports data、Dio 或 app-shell 的具体 provider。视觉只复用 Foundation v6.2.0 的 Token、语义图标、状态横幅、按钮和最小触控目标；会话是带分隔线的连续列表，未读通过角标表达，不用逐条面板制造卡片层级。私聊图片不得复用 Markdown 正文解析器；表情发送复用本模块 `stickerAssetId` 的独占消息约束。

## 11. 测试场景与验收条件

- [x] 11 个 Direct Messages operationId 的读取、写入、生成 DTO 和空响应均有仓储测试。
- [x] 契约 `directMessagePreviewCases` 固定站内传送门名称、邀请 token 脱敏和空白规范化后的服务端预览，移动端只展示该安全投影。
- [x] 三类会话、游标失效、历史/增量合并、乐观发送、失败原位重试、前后台轮询、已读校准、稳定幂等键和请求处理均有控制器测试。
- [x] 图片选择后先裁剪再上传，失败保留正文、选区与焦点；同一裁剪文件重试、完成后才可发送、上传中取消均有页面回归测试。
- [x] 撤回隐私、目标/参与者不匹配、重复消息、异常未读数和不安全媒体采用 fail-closed。
- [x] 中心、会话、新私聊的主路径、错误恢复与 320dp、360dp、400dp、600dp 布局通过 Widget 测试；内联输入 dock 在 280–320dp 软键盘 inset 及 1.3/2.0 倍字体下保持可见且不重复避让，并在 IME 最终 inset 可用时一帧到位，不跟随系统键盘动画逐帧升降；点击消息区会失焦收起键盘但保留当前输入，360dp 键盘态与 600dp 最新消息底部对齐的分组气泡由 golden 固定。长会话首次进入直接显示最后一条，连续气泡、消息旁长按操作、保留键盘的收藏表情锚点面板、离底新消息浮标和历史锚点保持可操作。
- [x] 私聊路由登录守卫、用户主页入口和 capability 关闭状态通过测试。
- [x] 互关用户不再误显示消息请求提示；陌生人文案、服务端结果优先级与避让输入 dock 的浮动反馈均有 Widget 回归。
- [x] 收到且未撤回的服务端消息可提交 `DIRECT_MESSAGE` 举报；本人、失败与撤回消息无入口，目标 ID 与回跳路径有页面回归。
- [ ] 使用两个公网专用账号完成请求、接受、发送、图片、已读、归档和撤回真机联调。

## 12. 已知限制和后续功能

当前用前台自适应轮询读取新消息，不做 WebSocket、SSE、FCM 后台唤醒或系统通知；进程终止后依赖重新进入页面读取。后端未投影单条消息的送达、已读、输入中或在线状态，移动端只展示可证实的发送中、失败与服务端已确认，不绘制双勾或伪在线。输入器支持文本、单张图片与独占收藏表情；文本和表情可立即生成乐观气泡，图片因发送契约要求先取得 `mediaId`，上传期间以输入 dock 内的紧凑进度呈现，成功后才显示可发送附件。失败可重试同一文件；取消或失败都不会清空正文、选区和焦点。失败幂等消息不跨重启保存，因此不明确失败后若用户终止应用，应先重新查看会话事实而不是生成新请求盲发。

## 13. 最近审查的契约版本和后端提交

契约 `5.4.0-dev.20260821.1`；Markdown v3；后端 `5cad10cdfa05b04dbde8a44add8e7b89d20bdb6a`；Foundation `v6.2.0`（`4ad1eb8`）。

## 14. 相关代码与架构文档

端口、控制器与状态：`lib/features/direct_messages/application/`；API 适配器：`lib/features/direct_messages/data/`；页面：`lib/features/direct_messages/presentation/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[站内通知](notifications.md)、[用户与资料](users.md)、[媒体](media.md)、[社区举报](reports.md)、[语义图标](../architecture/icons.md)和[Foundation v6.2.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.2.0/docs/platforms/mobile.md)。

# 站内通知

状态：`in_progress`

## 1. 模块目标与非目标

实现消息中心中的通知列表、筛选、已读、删除、目标导航、独立未读角标和 Android 可关闭的后台系统顶栏提醒。V1 不接入 FCM；系统提醒来自仍存活 Flutter 进程中的 HTTP 尽力拉取，不是离线推送。

## 2. 用户角色与使用场景

登录用户查看与自己相关的通知并进入主题、楼层或用户目标；游客看到登录引导而非错误列表。

## 3. 页面、入口和导航关系

“消息”是底部主分支，规范路由使用 `/notifications`；“私聊”页签写入 `/notifications?section=directMessages`，旧 `/messages` 仅作兼容重定向。游客留在分支内看到登录引导并携带同一路径回跳。通知项按 `target.kind` 导航：主楼层使用 `/threads/:threadId?post=:postId`，楼中楼回复使用 `/threads/:threadId/posts/:parentPostId/replies?post=:postId`，thread 使用 `/threads/:threadId`，user 使用 `/users/:userId`，moment 使用 `/moments/:momentId`；动态评论目标附加 `?comment=:momentCommentId`，由详情重新读取权威上下文。未知类型、无目标和已删除目标只展示安全正文。

## 4. 用户操作流程

进入消息分支、回到前台及每 30 秒刷新通知与私聊未读事实；前台轮询由应用壳单一定时器统一调度。Android 后台尽力提醒登录后固定开启；离开前台先记录最新一页通知 ID 与内容指纹，随后在进程仍获系统调度时全程每 30 秒尽力拉取且不允许请求重叠。同一聚合通知的 `totalCount` 或摘要变化可再次提醒，历史基线不会补发；只有系统卡片提交成功后才更新内容指纹，接口或展示失败会在下一节拍重试。一次最多显示三条，更多时只显示消息中心汇总。消息中心顶层仍使用“通知 / 私聊”线性页签；通知内部的“全部 / 互动 / 订阅 / 系统”改为右对齐的紧凑筛选菜单，避免连续两层页签压缩列表视口。未读通知条目在尾部显示 8dp Foundation `destructive` 圆点，与普通品牌强调色明确区分；打开通知后乐观标记已读且不阻塞导航，支持确认后单条删除和按服务端全局事实执行全部已读。回复通知根据收件人与真实回复对象显示“回复了你”或“回复了用户名”，订阅者不会被误写为回复对象；缺少新字段的历史通知使用中性“回复了”。动态评论通知只传稳定 momentId/commentId；详情调用 `momentsCommentContext` 注入主评论和目标，不扫描评论分页，并把目标滚动到视口内。下拉刷新会并行校准列表与通知未读数，加载更多失败保留已加载内容。私聊角标由 direct-messages 独立读取，不并入通知筛选或“全部已读”；底栏角标只在展示层求和。

消息中心的“通知 / 私聊”除点按页签外，也支持在内容区左右滑动切换；内容按 Foundation standard 180ms 沿方向轻量入场，已访问栏目在消息页面生命周期内保持挂载，返回通知栏不重复读取首屏。切换继续写入规范 URL，短滑与首尾越界不改变栏目，减少动态效果时瞬时完成，私聊 capability 关闭时不会产生非法目标。

## 5. API operationId 与生成类型

- `notificationsFindAll`、`notificationsUnreadCount`、`notificationsSetReadStatus`、`notificationsRemove`、`notificationsMarkAllAsRead`。
- 主要生成类型：`NotificationResponseDto`、`NotificationPayloadResponseDto`、`NotificationTargetResponseDto`、`UnreadNotificationCountResponseDto`。

## 6. 状态模型和数据流

通知未读数是服务端事实；列表与角标共享 `notifications/application` 仓储端口但独立请求，`main.dart` 组合根绑定 API data 适配器。列表控制器按 Foundation 分组隔离游标并复用 `RequestEpoch` 丢弃筛选切换、刷新或首页重载前的迟到响应；加载更多按通知 ID 去重并保持已有顺序，写操作串行化。单条已读和全部已读先乐观更新列表与角标，失败恢复列表并重新请求未读数；删除成功后再移除条目，删除未读项同步递减角标。消息中心与后台轮询组合位于 `app_shell`；通知结构化文案、旧正文清洗和目标坐标是 `notifications/application` 的纯函数，可同时供页面与系统卡片复用，domain 仍只保存服务端事实。后台 poller 以候选批次携带下一份指纹，系统卡片成功后才提交；后台 epoch 在恢复前台时作废并清空基线，迟到响应不得显示或提交。未知枚举保留通用条目，不使整个列表反序列化失败。

## 7. 鉴权、权限和隐私规则

只允许当前账号读取；切号立即清缓存并停止上一会话的后台尽力检查。系统卡片正文只使用页面同源的安全摘要、合并空白并截断至 160 个 Unicode 字符；不附带完整 Markdown 图片地址。未知 target 不猜测导航，点击回退消息中心；系统卡片不自动标记已读，进入目标后仍以现有页面/API 行为为准。

## 8. 本地存储、缓存及失效规则

通知列表、后台基线和内容指纹只做 Riverpod/Dart 进程内状态；消息中心按需构建“通知 / 私聊”，已访问栏目在消息页面组件树内继续挂载，顶层栏目切换不释放通知列表。通知页离开组件树后列表可释放，退出登录后认证状态变化会停止应用壳轮询、清除后台偏好并清零角标，再次登录重新创建私有状态。进入分支、回前台、前台 30 秒轮询、已开启时的后台固定 30 秒尽力轮询和写操作负责校准。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

无通知与筛选空态只保留状态标题，不重复介绍通知类型或切换分类。全局未读数只用于页签、底栏与“全部已读”动作，不在分类条下误写为当前筛选的汇总。

首次读取以连续通知行结构 Skeleton 保持列表层级；登录引导、无通知、筛选为空、首屏失败、局部分页失败和目标已失效分开处理。加载更多遇到 `40007 INVALID_CURSOR` 时清空当前筛选的旧游标并从首页重载；其他分页失败保留已加载通知、游标和问题编号。动态评论上下文 404 时详情与普通评论继续可读，只提示“目标评论已不可见”且不重试；临时失败提供独立“重试定位”，不重新加载或清空详情。所有 API 错误保留安全用户文案与请求 ID；乐观已读/全部已读失败时回滚并提示，删除失败不移除条目。

Android 通知权限关闭时只提示用户前往系统设置开启，不把权限拒绝误报为状态读取失败。通知小图标由本地通知插件按资源名动态读取，正式构建必须显式保留该资源；初始化或平台状态读取真正异常时才显示后台提醒准备/状态读取失败，且不启动后台私有消息拉取。

## 10. 跨模块约束

有明确操作者的通知头像缺图时显示用户名首个可读字符，无操作者的系统通知保留事件图标；通知短时间向辅助技术提供完整时间。

导航遵循[导航](../architecture/navigation.md)，目标 API 才是权威；不依赖提醒到达保证。私聊入口、角标和正文归 [direct-messages](direct-messages.md)，通知模块不读取私聊正文。仓库持续固定 mobile push v1 Schema/样例，本地系统卡片使用独立严格 v1 JSON 且当前切片不启用 FCM 运行时、设备注册或 push capability。

## 11. 测试场景与验收条件

- [x] 列表、紧凑分类筛选、分页、单条/全部已读和删除通过仓储、控制器、页面与 360dp Golden 测试。
- [x] 分页按通知 ID 去重，失效游标从当前筛选首页恢复，筛选切换后的迟到响应和重复在途加载不会污染列表。
- [x] 未读角标在进入、30 秒轮询、回前台和操作后同步；通知条目使用 8dp danger 圆点，底栏计数使用 destructive/onDestructive 对比色，并有组件、页面与 360dp Golden 回归。
- [x] 主楼层、楼中楼回复、thread/user/moment 已知目标精确导航，删除目标和未知枚举安全展示。
- [x] 回复目标本人显示“回复了你”，主题订阅者显示“回复了用户名”，历史载荷中性降级；三种文案不改变楼中楼精确导航。
- [x] 退出会销毁私有轮询与列表状态，再次登录重新读取，不复用上一会话数据。
- [x] Android 后台首次基线不补发历史通知；全程 30 秒节拍、不重叠、生命周期取消和超过 10 分钟不降频有协调器回归。新 ID 与同 ID 聚合内容变化会提醒，接口或系统卡片失败不提交指纹并可重试，超过三条汇总，安全摘要、频道配置和严格点击载荷有单元回归。
- [x] Android 正式构建保留按名称动态读取的通知小图标；资源压缩不会再使启动初始化失败，通知权限关闭继续进入正常权限引导。
- [x] 私聊 capability 关闭时不创建页签；开启后“通知 / 私聊”同级展示、独立计数，底栏显示两者合计。
- [x] 私聊 capability 开启时，消息内容区左右滑动以 180ms 方向反馈在“通知 / 私聊”间切换并同步规范 URL，已访问通知栏保留且返回时不重复读取首屏；减少动态效果时不播放位移，能力关闭、短滑和边界滑动均不产生非法切换。
- [x] 主题帖子目标只短暂显示 1dp Foundation 淡粉边框，不铺底色、不展示“已定位到”成功说明；1.2 秒后按 slow motion 淡出，减少动态效果时直接复原。
- [x] 动态评论目标完整消费 `momentCommentNavigation`，区分主评论、楼中楼、墓碑主评论、404 与临时失败，并复用同一短时边框语义。
- [ ] 识别 `thread_collaborator_added/removed` 系统通知并进入对应主题；撤销通知触发成员与本人协作主题列表刷新。

## 12. 已知限制和后续功能

契约 5.12.2 的楼中楼管理者/订阅通知使用既有 `new_post` 类型和开放式 `new_reply` action；当前 formatter 不把未知 action 猜成结构化动作，而是安全显示服务端完整正文，导航仍由既有帖子目标处理。直接被回复者继续使用 `reply` 并显示真实回复对象；主题楼主收到 5.12.3 主楼层直接互动时，既有“回复了你”和互动分类自然生效。若要把 `new_reply` 改为客户端结构化文案，应另开通知行为切片。

V1 仅 API 拉取，不做 FCM、WebSocket、SSE、后台唤醒或后台角标实时保证；Android 系统通知权限只服务于登录后固定开启、全程 30 秒节拍的进程内尽力提醒，不提供应用内开关，不注册前台服务。Doze、厂商省电、断网或进程终止可能延迟/停止提醒，重新进入应用时仍由服务端列表校准；不申请电池优化豁免，也不据 mobile push 协议提前注册设备。契约 5.9 的协作者任免通知字段已进入生成客户端，但当前 formatter 与导航尚未识别这两类 action，需与协作主题列表和权限撤销刷新一起接入。契约 5.11 的通知目标 `state` 已进入生成客户端；服务端会把非 `ACTIVE` 目标降为不可导航的 `kind=none` 并强制已读，移动端尚未按 `CONTENT_DELETED`、`USER_DEACTIVATED` 和 `NO_TARGET` 分别展示历史态文案，该行为需在独立通知切片接入。

## 13. 最近审查的契约版本和后端提交

契约 `5.15.1-dev.20260903.1`；Markdown v5；后端 `6e153e036ef9e1b878a7e910f92aebfa1d4e04eb`；Foundation `v6.5.1`（`a9318b8`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/notifications/application/notification_repository_ports.dart`、`lib/features/notifications/application/notification_copy.dart`、`lib/features/notifications/application/notification_navigation.dart`、`lib/features/notifications/data/`、`lib/features/app_shell/application/background_online_poller.dart`、`lib/features/app_shell/presentation/app_scaffold.dart`、`lib/main.dart`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[动态](moments.md)、[站内私聊](direct-messages.md)。

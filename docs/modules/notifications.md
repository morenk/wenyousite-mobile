# 站内通知

状态：`in_progress`

## 1. 模块目标与非目标

实现消息中心中的通知列表、筛选、已读、删除、目标导航和独立未读角标。V1 不接入 FCM。

## 2. 用户角色与使用场景

登录用户查看与自己相关的通知并进入主题、楼层或用户目标；游客看到登录引导而非错误列表。

## 3. 页面、入口和导航关系

“消息”是底部主分支，路由继续使用 `/notifications`；游客留在分支内看到登录引导并携带同一路径回跳。登录后顶部把“通知 / 私信”作为同级页签并分别展示未读数，私信页签嵌入 direct-messages 列表而不叠加第二层页面壳。通知项按 `target.kind` 导航：post 使用 `/threads/:threadId?post=:postId`，thread 使用 `/threads/:threadId`，user 使用 `/users/:userId`，moment 使用 `/moments/:momentId`；未知类型、无目标和已删除目标只展示安全正文。

## 4. 用户操作流程

进入消息分支、回到前台及每 30 秒分别刷新通知与私聊未读事实；通知列表按六组筛选分页，打开后乐观标记已读且不阻塞导航，支持单条删除和全部已读。下拉刷新会并行校准列表与通知未读数，加载更多失败保留已加载内容。私聊角标由 direct-messages 独立读取，不并入通知筛选或“全部已读”；底栏角标只在展示层求和。

## 5. API operationId 与生成类型

- `notificationsFindAll`、`notificationsUnreadCount`、`notificationsSetReadStatus`、`notificationsRemove`、`notificationsMarkAllAsRead`。
- 主要生成类型：`NotificationResponseDto`、`NotificationPayloadResponseDto`、`NotificationTargetResponseDto`、`UnreadNotificationCountResponseDto`。

## 6. 状态模型和数据流

通知未读数是服务端事实；列表与角标共享仓储但独立请求。列表控制器按筛选隔离游标并以加载 epoch 丢弃过期响应；写操作串行化。单条已读和全部已读先乐观更新列表与角标，失败恢复列表并重新请求未读数；删除成功后再移除条目，删除未读项同步递减角标。私聊角标只在 capability 开启时消费 direct-messages 状态。通知与会话都使用扁平连续列表、分隔线和状态底色，不为每一条内容创建装饰卡片。未知枚举保留通用条目，不使整个列表反序列化失败。

## 7. 鉴权、权限和隐私规则

只允许当前账号读取；切号立即清缓存。未知 target 不猜测导航，不在通知预览显示额外私密正文。

## 8. 本地存储、缓存及失效规则

首版只做 Riverpod 进程内状态；通知页离开组件树后列表可释放，退出登录后认证状态变化会销毁未读轮询并清零角标，再次登录重新创建私有状态。进入分支、回前台、30 秒轮询和写操作负责校准。

## 9. 加载、空数据、错误、重试和冲突状态

登录引导、无通知、筛选为空、首屏失败、局部分页失败和目标已失效分开处理。所有 API 错误保留安全用户文案与请求 ID；乐观已读/全部已读失败时回滚并提示，删除失败不移除条目。

## 10. 跨模块约束

导航遵循[导航](../architecture/navigation.md)，目标 API 才是权威；不依赖推送到达保证。私聊入口、角标和正文归 [direct-messages](direct-messages.md)，通知模块不读取私聊正文。仓库持续固定 mobile push v1 Schema/样例，当前切片不启用 FCM 运行时。

## 11. 测试场景与验收条件

- [x] 列表、筛选、分页、单条/全部已读和删除通过仓储、控制器和页面测试。
- [x] 未读角标在进入、30 秒轮询、回前台和操作后同步，并有应用壳集成测试。
- [x] post/thread/user/moment 已知目标精确导航，删除目标和未知枚举安全展示。
- [x] 退出会销毁私有轮询与列表状态，再次登录重新读取，不复用上一会话数据。
- [x] 私聊 capability 关闭时不创建页签；开启后“通知 / 私信”同级展示、独立计数，底栏显示两者合计。

## 12. 已知限制和后续功能

V1 仅 API 拉取，不做 FCM、系统通知权限或后台角标同步；保留同步的推送协议产物供后续里程碑实现，不据此提前注册设备。动态通知只定位到动态详情，当前不把 `momentCommentId` 写入临时滚动路径；评论精确定位待后端与跨端路径形成稳定契约后独立接入。

## 13. 最近审查的契约版本和后端提交

契约 `4.5.2-dev.20260811.1`；Markdown v2；后端 `f99d59d832bb6136d6ff88f5142d1c5b6f9239d2`。

## 14. 相关代码与架构文档

代码入口：`lib/features/notifications/`；底栏角标与前台刷新入口位于 `lib/features/app_shell/presentation/app_scaffold.dart`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[动态](moments.md)、[站内私聊](direct-messages.md)。

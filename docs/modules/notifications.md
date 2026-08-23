# 站内通知

状态：`in_progress`

## 1. 模块目标与非目标

实现消息中心中的通知列表、筛选、已读、删除、目标导航和独立未读角标。V1 不接入 FCM。

## 2. 用户角色与使用场景

登录用户查看与自己相关的通知并进入主题、楼层或用户目标；游客看到登录引导而非错误列表。

## 3. 页面、入口和导航关系

“消息”是底部主分支，规范路由使用 `/notifications`；“私聊”页签写入 `/notifications?section=directMessages`，旧 `/messages` 仅作兼容重定向。游客留在分支内看到登录引导并携带同一路径回跳。通知项按 `target.kind` 导航：主楼层使用 `/threads/:threadId?post=:postId`，楼中楼回复使用 `/threads/:threadId/posts/:parentPostId/replies?post=:postId`，thread 使用 `/threads/:threadId`，user 使用 `/users/:userId`，moment 使用 `/moments/:momentId`；未知类型、无目标和已删除目标只展示安全正文。

## 4. 用户操作流程

进入消息分支、回到前台及每 30 秒刷新通知与私聊未读事实；前台轮询由应用壳单一定时器统一调度，退到后台或退出登录立即停止。通知筛选直接采用 Foundation 的“全部 / 互动 / 订阅 / 系统”分组，并与消息中心栏目、动态和首页分类复用纯文字、底部分隔线与短选中线的共享页签，不再使用独立 ChoiceChip 条。打开通知后乐观标记已读且不阻塞导航，支持确认后单条删除和按服务端全局事实执行全部已读。下拉刷新会并行校准列表与通知未读数，加载更多失败保留已加载内容。私聊角标由 direct-messages 独立读取，不并入通知筛选或“全部已读”；底栏角标只在展示层求和。

## 5. API operationId 与生成类型

- `notificationsFindAll`、`notificationsUnreadCount`、`notificationsSetReadStatus`、`notificationsRemove`、`notificationsMarkAllAsRead`。
- 主要生成类型：`NotificationResponseDto`、`NotificationPayloadResponseDto`、`NotificationTargetResponseDto`、`UnreadNotificationCountResponseDto`。

## 6. 状态模型和数据流

通知未读数是服务端事实；列表与角标共享 `notifications/application` 仓储端口但独立请求，`main.dart` 组合根绑定 API data 适配器。列表控制器按 Foundation 分组隔离游标并复用 `RequestEpoch` 丢弃筛选切换、刷新或首页重载前的迟到响应；加载更多按通知 ID 去重并保持已有顺序，写操作串行化。单条已读和全部已读先乐观更新列表与角标，失败恢复列表并重新请求未读数；删除成功后再移除条目，删除未读项同步递减角标。消息中心组合位于 `app_shell/presentation`，notifications 不反向导入 direct_messages；通知 domain 只保存服务端事实，结构化中文与旧正文清洗由 presentation formatter 负责。未知枚举保留通用条目，不使整个列表反序列化失败。

## 7. 鉴权、权限和隐私规则

只允许当前账号读取；切号立即清缓存。未知 target 不猜测导航，不在通知预览显示额外私密正文。

## 8. 本地存储、缓存及失效规则

首版只做 Riverpod 进程内状态；通知页离开组件树后列表可释放，退出登录后认证状态变化会停止应用壳未读轮询并清零角标，再次登录重新创建私有状态。进入分支、回前台、前台 30 秒轮询和写操作负责校准。

## 9. 加载、空数据、错误、重试和冲突状态

无通知与筛选空态只保留状态标题，不重复介绍通知类型或切换分类。全局未读数只用于页签、底栏与“全部已读”动作，不在分类条下误写为当前筛选的汇总。

首次读取以连续通知行结构 Skeleton 保持列表层级；登录引导、无通知、筛选为空、首屏失败、局部分页失败和目标已失效分开处理。加载更多遇到 `40007 INVALID_CURSOR` 时清空当前筛选的旧游标并从首页重载；其他分页失败保留已加载通知、游标和问题编号。所有 API 错误保留安全用户文案与请求 ID；乐观已读/全部已读失败时回滚并提示，删除失败不移除条目。

## 10. 跨模块约束

有明确操作者的通知头像缺图时显示用户名首个可读字符，无操作者的系统通知保留事件图标；通知短时间向辅助技术提供完整时间。

导航遵循[导航](../architecture/navigation.md)，目标 API 才是权威；不依赖推送到达保证。私聊入口、角标和正文归 [direct-messages](direct-messages.md)，通知模块不读取私聊正文。仓库持续固定 mobile push v1 Schema/样例，当前切片不启用 FCM 运行时。

## 11. 测试场景与验收条件

- [x] 列表、共享线性分类页签、分页、单条/全部已读和删除通过仓储、控制器、页面与 360dp Golden 测试。
- [x] 分页按通知 ID 去重，失效游标从当前筛选首页恢复，筛选切换后的迟到响应和重复在途加载不会污染列表。
- [x] 未读角标在进入、30 秒轮询、回前台和操作后同步，并有应用壳集成测试。
- [x] 主楼层、楼中楼回复、thread/user/moment 已知目标精确导航，删除目标和未知枚举安全展示。
- [x] 退出会销毁私有轮询与列表状态，再次登录重新读取，不复用上一会话数据。
- [x] 私聊 capability 关闭时不创建页签；开启后“通知 / 私聊”同级展示、独立计数，底栏显示两者合计。
- [x] 主题帖子目标只短暂显示 1dp Foundation 淡粉边框，不铺底色、不展示“已定位到”成功说明；1.2 秒后按 slow motion 淡出，减少动态效果时直接复原。
- [ ] 动态评论目标完整消费 `momentCommentNavigation`，区分主评论、楼中楼、墓碑主评论、404 与临时失败，并复用同一短时边框语义。

## 12. 已知限制和后续功能

V1 仅 API 拉取，不做 FCM、系统通知权限或后台角标同步；保留同步的推送协议产物供后续里程碑实现，不据此提前注册设备。后端契约已经提供稳定的 `momentsCommentContext` 与 `momentCommentNavigation` 黄金旅程；动态评论通知当前仍只进入动态详情，尚未接入移动端上下文预取、目标滚动和短时边框提示。该缺口应作为一个完整切片实现，不把 `momentCommentId` 直接拼进可能尚未加载的列表位置，也不扫描评论分页猜测位置。

## 13. 最近审查的契约版本和后端提交

契约 `5.7.0-dev.20260823.1`；Markdown v3；后端 `719c7e62aa744ad13a1257bb9cfb29147d55eabe`；Foundation `v6.3.0`（`73ed49e`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/notifications/application/notification_repository_ports.dart`、`lib/features/notifications/data/`、`lib/main.dart`；底栏角标与前台刷新入口位于 `lib/features/app_shell/presentation/app_scaffold.dart`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[动态](moments.md)、[站内私聊](direct-messages.md)。

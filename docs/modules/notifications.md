# 站内通知

状态：`planned`

## 1. 模块目标与非目标

实现通知列表、筛选、已读、删除、目标导航和未读角标。V1 不接入 FCM。

## 2. 用户角色与使用场景

登录用户查看与自己相关的通知并进入主题、楼层或用户目标；游客看到登录引导而非错误列表。

## 3. 页面、入口和导航关系

通知是底部主分支；列表项按 target.kind 导航；未知类型或无目标只展示安全正文。

## 4. 用户操作流程

进入和回前台刷新未读数；列表按筛选分页；打开可导航通知后标记已读；支持单条删除和全部已读。

## 5. API operationId 与生成类型

- `notificationsFindAll`、`notificationsUnreadCount`、`notificationsSetReadStatus`、`notificationsRemove`、`notificationsMarkAllAsRead`。
- 主要生成类型：`NotificationResponseDto`、`NotificationPayloadResponseDto`、`UnreadCountResponseDto`。

## 6. 状态模型和数据流

未读数是服务端事实；列表与角标共享仓储但独立请求。未知枚举保留通用卡片，不使整个列表反序列化失败。

## 7. 鉴权、权限和隐私规则

只允许当前账号读取；切号立即清缓存。未知 target 不猜测导航，不在通知预览显示额外私密正文。

## 8. 本地存储、缓存及失效规则

首版只做进程内缓存；回前台、网络恢复、写操作后刷新。退出清空列表和角标。

## 9. 加载、空数据、错误、重试和冲突状态

登录引导、无通知、筛选为空、局部分页失败和目标已失效分开处理；乐观已读失败时回滚并提示。

## 10. 跨模块约束

导航遵循[导航](../architecture/navigation.md)，目标 API 才是权威；不依赖推送到达保证。仓库持续固定 mobile push v1 Schema/样例，当前切片不启用 FCM 运行时。

## 11. 测试场景与验收条件

- [ ] 列表、筛选、分页、单条/全部已读和删除通过。
- [ ] 未读角标在进入、回前台和操作后同步。
- [ ] 已知目标精确导航，未知枚举安全展示。
- [ ] 切号不泄露上一账号通知。

## 12. 已知限制和后续功能

V1 仅 API 拉取，不做 FCM、系统通知权限或后台角标同步；保留同步的推送协议产物供后续里程碑实现，不据此提前注册设备。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.2`；Markdown v2；后端 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/notifications/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)。

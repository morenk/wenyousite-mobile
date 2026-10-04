# 帖内身份

状态：`in_progress`

## 1. 模块目标与非目标

为每个账号在每个主题提供一套头像、昵称及历史身份展示。每条新发言可选整套 RP 或站内身份；本期不提供多个角色，不改变账号权限和全站资料。

## 2. 用户角色与使用场景

楼主开启功能；楼主、协作者和已标记玩家可设置。普通读者可查看身份卡与站内账号，无设置权限。

## 3. 页面、入口和导航关系

主题设置提供开关；主题操作菜单及编辑器身份栏打开资料表单；帖内作者头像与结构化提及打开身份卡。

## 4. 用户操作流程

昵称和头像可分别留空。头像使用原裁切与 AVATAR 上传入口，保存仅写帖内资料。每条新发言默认有效 RP，否则站内身份；草稿保留选择。保存资料只影响后续发言，清除资料不清除旧快照。

## 5. API operationId 与生成类型

- `threadIdentitiesMine`、`threadIdentitiesFindUser` 返回 `ThreadIdentityStateDto`。
- `threadIdentitiesUpdate` 使用 `UpdateThreadIdentityDto`，独立清除标记和 version 防止误覆盖。
- `threadIdentitiesClear` 清除本人资料；`threadIdentitiesSetEnabled` 使用 `SetThreadIdentityEnabledDto` 设置主题开关。
- 作者消费可选 `RpIdentityResponseDto`，正文消费 `MentionIdentityDisplayDto`，所有 ID 保持账号含义。

## 6. 状态模型和数据流

domain 只包含不可变 RP 展示值、身份模式和更新输入。application ports 定义读取结果 `ThreadIdentityState` 及仓储；data 校验主题和账号范围、映射头像治理投影。presentation 持有未提交表单，失败时不丢失。组合根绑定生成 API 仓储。

## 7. 鉴权、权限和隐私规则

账号始终是提及、筛选、订阅、举报目标。服务端判定资格及可见性；卡片不得展示错主题／错账号结果。会话变化使旧表单失效。身份写入禁止自动重放，不修改站内头像。

## 8. 本地存储、缓存及失效规则

身份模块不单独持久化资料。读缓存绑定 viewerScope，保存或开关变化使阅读投影失效；编辑器的 mode/token 和未知结果载荷由 posts 的账号隔离草稿保存，不随阅读缓存销毁。

## 9. 加载、空数据、错误、重试和冲突状态

加载错误可重试；撤权后保留输入并禁用保存。并发更新失败重新读取资格/version，不覆盖未保存文本。发言的 `40011` 要求明确确认新身份，`40012` 提示重新选择提及；由 posts 负责重试状态。

## 10. 跨模块约束

通过 `identity_models.dart`、`identity_ports.dart`、`identity_mapping.dart`、`identity_widgets.dart` 分别开放领域、应用、映射和 UI 入口。模块只依赖 media，不反向依赖 threads/posts/social/search/notifications；业务账号动作由阅读范围回调提供。Foundation 样式依赖保持正式 `v7.2.1`。

## 11. 测试场景与验收条件

覆盖生成 API 的清除标记和禁重放、卡片历史／当前／ACCOUNT 区分、关闭投影、长昵称与 Unicode、窄屏大字及深浅色布局、资料变化和草稿冻结。人工检查身份选择、两种身份交替、撤权和真实头像裁切。候选尚待负责人验收，见 [验收记录](../architecture/rp-identity-acceptance.md)。

## 12. 已知限制和后续功能

每账号每帖一套身份；不提供匿名账号隐藏、多角色和旧发言换身份。头像治理移除优先于历史快照保留。未连接设备时自动测试不能代替真机验收。

## 13. 最近审查的契约版本和后端提交

OpenAPI `5.33.0-dev.20261005.1`；Backend `5ab9767ff8ddce917ddb2560ea655bb58a2408a3`。Markdown 结构化提及保持账号链接，显示通过 userId + 原标签映射；字段缺失沿用站内资料。

## 14. 相关代码与架构文档

- `lib/features/thread_identity/`；`lib/features/posts/application/post_identity_selection.dart`。
- [主题](threads.md)、[帖子](posts.md)、[兼容与弃用登记](../deprecation-register.md)。
- `contracts/thread-identity.md`、`contracts/thread-identity.v1.fixtures.json`。

# 社交关系

状态：`in_progress`

## 1. 模块目标与非目标

统一收藏、关注、订阅、点赞和拉黑的读写状态。当前已交付公开用户页关注与拉黑的可逆写入，以及公开/本人关注、粉丝和本人黑名单列表；V1 不包含收藏表情或推荐算法配置。

## 2. 用户角色与使用场景

游客与登录用户可从公开主页查看服务端允许的关注和粉丝列表；登录用户还可在他人公开主页管理关注与拉黑，并在“我的”查看本人关系和黑名单。本人主页不显示自我关系操作。

## 3. 页面、入口和导航关系

关系按钮位于 `/users/:userId`。公开统计进入 `/users/:userId/following` 与 `/users/:userId/followers`；“我的”通过 `/me/following`、`/me/followers` 和 `/me/blocks` 管理本人列表。收藏与订阅入口后续接入。

## 4. 用户操作流程

公开页先完成本人身份读取并排除自我目标，再显示关注与拉黑按钮。同一目标一次只允许一个关系写入；成功后切换服务端目标状态并同步本地粉丝数，失败保持旧状态。拉黑前说明对回复、通知和私聊的影响并二次确认；解除拉黑不重复确认。公开统计读取指定用户列表，本人入口使用本人专用端点；黑名单取消拉黑成功后才移除条目，失败保留原列表。服务端拉黑不会删除关注关系，客户端也不擅自联动。

## 5. API operationId 与生成类型

- `bookmarksFindAll`、`bookmarksCreate`、`bookmarksRemove`。
- `subscriptionsFindAll`、`subscriptionsCreate`、`subscriptionsRemove`。
- 已接入 `usersFollowFollow`、`usersFollowUnfollow`、`usersFollowBlock`、`usersFollowUnblock`。
- 已接入 `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers`、`usersFollowBlocks`。
- `threadsLike`、`threadsUnlike`。

## 6. 状态模型和数据流

`UserRelationTarget` 以目标 ID、服务端初始关系和粉丝数作为 family 键；写控制器保存 following、blocked、blockedBy、followerCount、唯一在途动作与局部反馈。`UserRelationListTarget` 区分公开用户和本人列表；列表控制器以加载 epoch 丢弃旧响应，黑名单另保存唯一在途用户和局部错误。两类状态均为 autoDispose，当前不建立跨列表事件总线。

## 7. 鉴权、权限和隐私规则

所有写操作和 `/me/*` 关系列表需要登录；游客进入本人列表先跳转登录并保留安全回跳目标。公开页用 `usersGetMe` 成功结果确认当前用户 ID，身份仍在加载或失败时不显示按钮。客户端不根据计数推断关系，不显示自我操作，也不允许游客读取黑名单或发写请求；公开关系列表仍以服务端权限投影为准。

## 8. 本地存储、缓存及失效规则

关系写状态和列表只存在于 autoDispose Provider；离页、退出或切号即释放。下拉刷新重新读取完整列表，公开资料刷新会用新的服务端关系快照建立状态；不持久化、不离线排队，也不把列表写进全局缓存。

## 9. 加载、空数据、错误、重试和冲突状态

在途时禁用同一组按钮并忽略快速重复操作；失败保留原关系、请求 ID 和再次点击重试能力。列表提供加载、空、失败、重试与下拉刷新；响应缺失不伪装成空列表，后发刷新胜过先发旧响应。取消拉黑串行执行，失败保留条目，成功后才原地移除。

## 10. 跨模块约束

users 页面只消费 social 的关系仓储、控制器和列表页；通知计数不因关系写入伪造。列表行只传稳定 userId 返回公开资料。拉黑不改写关注状态，关注只调整目标粉丝数，不改当前用户的关注数；跨页刷新仍以服务端为准。

## 11. 测试场景与验收条件

- [x] 关注/取消关注和拉黑/解除拉黑增删闭环通过，拉黑必须确认。
- [x] 快速重复点击只产生一个在途写请求，最终状态正确。
- [x] 关系失败保留原状态并显示请求 ID；关注成功同步目标粉丝数。
- [x] 公开与本人关注/粉丝投影映射正确，黑名单可恢复地取消拉黑。
- [x] 列表空错重试、旧响应竞态、稳定用户导航及 360/400/600dp 布局通过。
- [ ] 收藏、订阅与点赞闭环通过。
- [ ] 切号不泄露关系和拉黑列表。

## 12. 已知限制和后续功能

当前未建立跨页面关系事件总线，列表变化不会主动改写其他仍存活页面；收藏、订阅和点赞尚未接入。不做收藏表情、离线关系队列或推荐偏好；视觉动效后置。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/social/`，消费入口为 `lib/features/users/presentation/public_user_page.dart`。参见[主题](threads.md)、[用户与资料](users.md)。

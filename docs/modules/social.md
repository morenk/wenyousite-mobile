# 社交关系

状态：`in_progress`

## 1. 模块目标与非目标

统一收藏、关注、订阅、点赞和拉黑的读写状态。当前先交付公开用户页关注与拉黑的可逆写入；V1 不包含收藏表情或推荐算法配置。

## 2. 用户角色与使用场景

登录用户在他人公开主页管理关注与拉黑；游客只看到服务端公开计数，不触发身份或关系写请求。本人主页不显示自我关系操作。

## 3. 页面、入口和导航关系

当前关系按钮位于 `/users/:userId` 公开用户页；关注/粉丝列表、收藏/订阅和黑名单入口后续从用户页或“我的”进入。

## 4. 用户操作流程

公开页先完成本人身份读取并排除自我目标，再显示关注与拉黑按钮。同一目标一次只允许一个关系写入；成功后切换服务端目标状态并同步本地粉丝数，失败保持旧状态。拉黑前说明对回复、通知和私聊的影响并二次确认；解除拉黑不重复确认。服务端拉黑不会删除关注关系，客户端也不擅自联动。

## 5. API operationId 与生成类型

- `bookmarksFindAll`、`bookmarksCreate`、`bookmarksRemove`。
- `subscriptionsFindAll`、`subscriptionsCreate`、`subscriptionsRemove`。
- 已接入 `usersFollowFollow`、`usersFollowUnfollow`、`usersFollowBlock`、`usersFollowUnblock`。
- `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers`、`usersFollowBlocks` 后续接入列表。
- `threadsLike`、`threadsUnlike`。

## 6. 状态模型和数据流

`UserRelationTarget` 以目标 ID、服务端初始关系和粉丝数作为 family 键；控制器保存 following、blocked、blockedBy、followerCount、唯一在途动作与局部反馈。当前只在目标公开页生命周期内同步，不建立跨列表事件总线。

## 7. 鉴权、权限和隐私规则

所有写操作需要登录；公开页用 `usersGetMe` 成功结果确认当前用户 ID，身份仍在加载或失败时不显示按钮。客户端不根据计数推断关系，不显示自我操作，也不允许游客发写请求；拉黑列表仍只属于当前用户。

## 8. 本地存储、缓存及失效规则

关系只存在于公开页 autoDispose Provider；离页、退出或切号即释放。公开资料刷新会用新的服务端关系快照建立状态，不持久化或离线排队。

## 9. 加载、空数据、错误、重试和冲突状态

在途时禁用同一组按钮并忽略快速重复操作；失败保留原关系、请求 ID 和再次点击重试能力。四个端点由服务端幂等处理，客户端只在收到完整成功响应后更新，不把空响应当成功。

## 10. 跨模块约束

users 页面只消费 social 的关系仓储和控制器；通知计数不因关系写入伪造。拉黑不改写关注状态，关注只调整目标粉丝数，不改当前用户的关注数。

## 11. 测试场景与验收条件

- [x] 关注/取消关注和拉黑/解除拉黑增删闭环通过，拉黑必须确认。
- [x] 快速重复点击只产生一个在途写请求，最终状态正确。
- [x] 关系失败保留原状态并显示请求 ID；关注成功同步目标粉丝数。
- [ ] 收藏、订阅、点赞与关系列表闭环通过。
- [ ] 切号不泄露关系和拉黑列表。

## 12. 已知限制和后续功能

当前没有关注/粉丝与黑名单列表，也未建立跨页面关系事件总线；收藏、订阅和点赞尚未接入。不做收藏表情、离线关系队列或推荐偏好；视觉动效后置。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/social/`，消费入口为 `lib/features/users/presentation/public_user_page.dart`。参见[主题](threads.md)、[用户与资料](users.md)。

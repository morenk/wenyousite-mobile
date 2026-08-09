# 用户与资料

状态：`in_progress`

## 1. 模块目标与非目标

逐步实现用户主页、个人资料、隐私字段、创建/参与主题、最近回复、收藏、关注与粉丝列表。当前已提供可从搜索和 Markdown 站内链接进入的只读公开资料页与公开内容分区；账号安全写操作归 settings/auth。

## 2. 用户角色与使用场景

游客浏览服务端允许的公开资料和内容；登录用户额外查看响应中存在的关系状态。本人编辑资料和隐私设置尚未接入，“我的”分支后续提供本人专用入口。

## 3. 页面、入口和导航关系

公开用户主页使用稳定路径 `/users/:userId`，当前可从搜索结果和 Markdown 用户站内链接进入。创建、参与和收藏主题卡片进入 `/threads/:threadId`；最近回复进入 `/threads/:threadId?post=:postId` 并复用目标上下文定位。主题作者、提及、关系列表以及“我的”分支的本人资料入口后续统一复用稳定路径或专用本人页面。

## 4. 用户操作流程

按用户 ID 读取资料，展示头像、用户名、等级、简介、加入日期、关注/粉丝/收到加油统计，以及服务端返回的关系状态。资料成功后立即加载“创建”，参与、回复和收藏只在对应隐私字段允许时显示，并在首次切换时请求；主题列表沿不透明 cursor 加载更多，最近回复固定读取服务端最近 10 条。页面下拉刷新会重新读取资料与当前内容；注销账号显示收敛状态，不渲染旧资料。

## 5. API operationId 与生成类型

- 当前已接入 `usersGetUser`、`usersGetUserCreatedThreads`、`usersGetUserPlayedThreads`、`usersGetUserRecentReplies`、`usersGetUserBookmarks`。
- 主要生成类型：`PublicUserResponseDto`、`ThreadListItemResponseDto`、`RecentReplyResponseDto`、`BookmarkThreadResponseDto` 与 `ApiPaginationMeta`。
- `usersGetMe`、`usersUpdateMe`、`usersDeleteMe` 由后续本人资料与账号生命周期切片接入。
- `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers` 由 social 模块接入。

## 6. 状态模型和数据流

`PublicUserController` 以 userId 为 family 参数，资料与四个内容分区分别保存请求代次。主题分区各自维护 idle/loading/ready/failed、items、cursor、hasMore、加载更多和局部错误；回复分区无 cursor。慢响应、刷新前响应和失效 cursor 不得覆盖新状态。repository 将 API DTO 映射为公开资料、主题摘要和回复摘要展示模型，不与本人私有资料模型混用。

## 7. 鉴权、权限和隐私规则

“创建”遵循服务端的本人/他人可见性投影并始终显示入口；“参与”“回复”“收藏”分别只在 `showPlayerBadges`、`showRecentReplies`、`showBookmarks` 为真时显示和请求。字段缺失按不公开处理；接口仍是最终权限权威，切换页签后若隐私刚变化并返回 404，则收敛为未公开状态。公开页面不因本地登录状态猜测本人权限。

## 8. 本地存储、缓存及失效规则

头像走安全 HTTP(S) 图片缓存；资料与内容只存在于当前 autoDispose Provider 生命周期。当前不做离线或跨页面长时缓存；下拉刷新丢弃旧内容并重新读取资料和仍允许的当前分区，页面销毁、切号或权限变化不会保留私有列表。

## 9. 加载、空数据、错误、重试和冲突状态

资料加载、资料失败、404 与注销保持页面级状态。每个内容分区独立展示加载、空、未公开/404、普通错误、请求 ID、局部重试、加载更多和到底；加载更多失败保留已有卡片，`40007 INVALID_CURSOR` 丢弃旧页并从第一页恢复。当前没有编辑表单。

## 10. 跨模块约束

关系写操作由 social 管理；头像上传由 media；密码、邮箱、会话和注销由 settings/auth。搜索与 Markdown 只传 userId，资料页自行重新校验可见性，不复用搜索摘要当作资料事实。最近回复复用 threads 的帖子目标定位，Markdown 摘要走统一安全纯文本转换。

## 11. 测试场景与验收条件

- [x] 公开资料仅展示 `usersGetUser` 响应中允许的字段，非法头像 URL 不加载。
- [x] 加载、失败、请求 ID、重试、注销与 404 使用独立安全状态。
- [x] 360dp、400dp 与 600dp 公开资料布局有 Widget 测试。
- [x] 创建、参与、回复和收藏按隐私字段显示并惰性加载，关闭项不发请求。
- [x] 三类主题列表独立分页、按 ID 去重，cursor 失效从第一页恢复；最近回复使用精确帖子目标。
- [ ] 本人资料编辑、头像变化和重启后显示正确。
- [ ] 关注、拉黑与隐私变化后的跨页面缓存失效完成验证。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。当前公开资料页只读，不提供关注/拉黑按钮；用户动态、勋章、关注/粉丝列表和本人私密内容筛选后续接入。公开路由不会绕过关闭的隐私字段，本人完整内容由后续“我的”模块结合 `usersGetMe` 提供。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/users/`。参见[搜索](search.md)、[社交关系](social.md)、[设置](settings.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

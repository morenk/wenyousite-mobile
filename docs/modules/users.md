# 用户与资料

状态：`in_progress`

## 1. 模块目标与非目标

逐步实现用户主页、个人资料、隐私字段、创建/参与主题、最近回复、关注与粉丝列表。当前切片先提供可从搜索和 Markdown 站内链接进入的只读公开资料页；账号安全写操作归 settings/auth。

## 2. 用户角色与使用场景

游客浏览服务端允许的公开资料；登录用户额外查看响应中存在的关系状态。本人编辑资料和隐私设置尚未接入。

## 3. 页面、入口和导航关系

公开用户主页使用稳定路径 `/users/:userId`，当前可从搜索结果和 Markdown 用户站内链接进入。主题作者、提及、关系列表以及“我的”分支的本人资料入口后续统一复用该路径或专用本人页面。

## 4. 用户操作流程

按用户 ID 读取资料，展示头像、用户名、等级、简介、加入日期、关注/粉丝/收到加油统计，以及服务端返回的已关注、关注了你、拉黑和互动受限状态。页面只读并支持下拉刷新与错误重试；注销账号显示收敛状态，不渲染旧资料。

## 5. API operationId 与生成类型

- 当前已接入 `usersGetUser`，主要生成类型为 `PublicUserResponseDto`。
- `usersGetMe`、`usersUpdateMe`、`usersDeleteMe` 由后续本人资料与账号生命周期切片接入。
- `usersGetUserBookmarks`、`usersGetUserPlayedThreads`、`usersGetUserCreatedThreads`、`usersGetUserRecentReplies` 由公开内容 Tab 后续接入。
- `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers` 由 social 模块接入。

## 6. 状态模型和数据流

`PublicUserController` 以 userId 为 family 参数，管理 loading/ready/failed 与请求代次；repository 将 API DTO 映射为只包含公开展示字段的 `PublicUserProfileModel`。页面销毁后状态自动释放，不与本人私有资料模型混用。

## 7. 鉴权、权限和隐私规则

客户端只展示响应中存在的隐私字段，不以空值推断真实数据。切号清本人私有缓存；被拉黑关系按服务端可见性降级。

## 8. 本地存储、缓存及失效规则

头像走安全 HTTP(S) 图片缓存；资料只存在于当前 autoDispose Provider 生命周期。当前不做离线或跨页面长时缓存，下拉刷新重新读取服务端。

## 9. 加载、空数据、错误、重试和冲突状态

加载中展示进度；普通错误展示安全提示、请求 ID 与重试；404 只说明用户不存在或可能已注销；响应明确标记注销时展示收敛状态。当前没有内容 Tab 和编辑表单。

## 10. 跨模块约束

关系写操作由 social 管理；头像上传由 media；密码、邮箱、会话和注销由 settings/auth。搜索与 Markdown 只传 userId，资料页自行重新校验可见性，不复用搜索摘要当作资料事实。

## 11. 测试场景与验收条件

- [x] 公开资料仅展示 `usersGetUser` 响应中允许的字段，非法头像 URL 不加载。
- [x] 加载、失败、请求 ID、重试、注销与 404 使用独立安全状态。
- [x] 360dp、400dp 与 600dp 公开资料布局有 Widget 测试。
- [ ] 创建/参与/回复和关系列表独立分页。
- [ ] 本人资料编辑、头像变化和重启后显示正确。
- [ ] 关注、拉黑与隐私变化后的跨页面缓存失效完成验证。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。当前公开资料页只读，不提供关注/拉黑按钮，也不显示创建/参与主题、最近回复、收藏和勋章列表。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/users/`。参见[搜索](search.md)、[社交关系](social.md)、[设置](settings.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

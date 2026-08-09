# 用户与资料

状态：`in_progress`

## 1. 模块目标与非目标

逐步实现用户主页、个人资料、隐私字段、创建/参与主题、最近回复、收藏、关注与粉丝列表。当前已提供只读公开资料与内容分区，以及“我的”本人资料读取、用户名、简介和公开范围编辑；账号安全写操作归 settings/auth。

## 2. 用户角色与使用场景

游客浏览服务端允许的公开资料和内容；登录用户额外查看响应中存在的关系状态，并在“我的”管理服务端返回的本人私有资料与公开范围。

## 3. 页面、入口和导航关系

公开用户主页使用稳定路径 `/users/:userId`，可从搜索结果和 Markdown 用户站内链接进入。创建、参与和收藏主题卡片进入 `/threads/:threadId`；最近回复进入 `/threads/:threadId?post=:postId` 并复用目标上下文定位。本人资料使用主导航 `/me`，游客只看到登录入口；登录用户可从这里进入自己的公开主页进行公开视角预览。

## 4. 用户操作流程

公开页按用户 ID 读取资料，展示头像、用户名、等级、简介、加入日期、统计与关系状态；内容按隐私字段惰性请求并支持游标分页。“我的”读取邮箱验证、成长区间、温油与社交统计；用户名在独立编辑态按 2–24 位规则提交，简介和三项公开范围在同一表单只发送变化字段。所有保存采用响应中的服务端最终值；退出保持二次确认和本机后备。

## 5. API operationId 与生成类型

- 当前已接入 `usersGetUser`、`usersGetUserCreatedThreads`、`usersGetUserPlayedThreads`、`usersGetUserRecentReplies`、`usersGetUserBookmarks`、`usersGetMe`、`usersUpdateMe`。
- 主要生成类型：`PublicUserResponseDto`、`CurrentUserResponseDto`、`PrivateUserResponseDto`、`UpdateUserDto`、`ThreadListItemResponseDto`、`RecentReplyResponseDto`、`BookmarkThreadResponseDto` 与 `ApiPaginationMeta`。
- `usersDeleteMe` 由后续账号生命周期切片接入。
- `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers` 由 social 模块接入。

## 6. 状态模型和数据流

`PublicUserController` 以 userId 为 family 参数，资料与四个内容分区分别保存请求代次；`MeProfileController` 独立管理本人 loading/ready/failed、用户名或资料提交、局部失败和服务端回写。公开和私有 DTO 分别映射为不同展示模型，不互相复用；PATCH 响应没有社交计数时只更新私有可编辑字段并保留刚读取的计数。

## 7. 鉴权、权限和隐私规则

公开页的“创建”遵循服务端投影并始终显示入口；“参与”“回复”“收藏”分别只在三个公开字段为真时显示和请求，公开页面不猜测本人权限。`/me` 仅在认证状态下创建私有资料请求；游客、退出或会话失效不读取或保留私有字段。公开范围以 PATCH 响应为权威，关闭后公开页仍会重新按服务端权限读取。

## 8. 本地存储、缓存及失效规则

头像走安全 HTTP(S) 图片缓存；公开与本人资料分别只存在于当前 autoDispose Provider 生命周期，不写入 Drift 或 SharedPreferences。下拉刷新重新读取服务端；页面销毁、退出、切号或会话失效会释放本人资料和未提交表单。

## 9. 加载、空数据、错误、重试和冲突状态

公开资料和内容保持原有页面级与分区级空错恢复。本人资料加载失败可重试且仍保留安全退出；两类编辑防重复提交，未变化不发 PATCH，失败保留原资料、输入与请求 ID。用户名占用、7 天冷却和 429 以服务端为准。当前 `UpdateUserDto.bio` 不接受空字符串或 null，因此已有简介清空会在本地明确拦截，不伪装保存成功。

## 10. 跨模块约束

关系写操作由 social 管理；头像上传由 media；密码、邮箱、会话和注销由 settings/auth。搜索与 Markdown 只传 userId，资料页自行重新校验可见性，不复用搜索摘要当作资料事实。最近回复复用 threads 的帖子目标定位，Markdown 摘要走统一安全纯文本转换。

## 11. 测试场景与验收条件

- [x] 公开资料仅展示 `usersGetUser` 响应中允许的字段，非法头像 URL 不加载。
- [x] 加载、失败、请求 ID、重试、注销与 404 使用独立安全状态。
- [x] 360dp、400dp 与 600dp 公开资料布局有 Widget 测试。
- [x] 创建、参与、回复和收藏按隐私字段显示并惰性加载，关闭项不发请求。
- [x] 三类主题列表独立分页、按 ID 去重，cursor 失效从第一页恢复；最近回复使用精确帖子目标。
- [x] 本人资料读取、用户名/简介/公开范围更新、失败重试与服务端结果回写正确。
- [x] 游客不读取私有资料，本人资料与设置在 360dp、400dp、600dp 无布局溢出。
- [ ] 头像变化和重启后显示正确。
- [ ] 关注、拉黑与隐私变化后的跨页面缓存失效完成验证。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。当前公开资料页只读，不提供关注/拉黑按钮；“我的”尚不上传头像，也不管理密码、邮箱、终端或注销。用户动态、勋章、关注/粉丝列表和本人私密内容筛选后续接入；公开路由不会绕过关闭的隐私字段。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/users/`。参见[搜索](search.md)、[社交关系](social.md)、[设置](settings.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

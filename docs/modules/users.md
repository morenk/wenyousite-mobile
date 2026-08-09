# 用户与资料

状态：`in_progress`

## 1. 模块目标与非目标

逐步实现用户主页、个人资料、隐私字段、创建/参与主题、最近回复、收藏、关注与粉丝列表。当前已提供公开资料与内容分区、公开及本人关注/粉丝列表、登录用户对他人的关注/拉黑操作，以及“我的”本人资料、公开范围编辑和本人收藏管理入口；账号安全写操作归 settings/auth。

## 2. 用户角色与使用场景

游客浏览服务端允许的公开资料和内容；登录用户查看关系状态，在确认目标不是本人后可关注或拉黑，并在“我的”管理本人私有资料与公开范围。

## 3. 页面、入口和导航关系

公开用户主页使用稳定路径 `/users/:userId`，可从搜索结果和 Markdown 用户站内链接进入。关注和粉丝统计进入指定用户路径；本人资料使用主导航 `/me`，并提供 `/me/bookmarks`、`/me/following`、`/me/followers` 与 `/me/blocks`。创建、参与和收藏主题卡片进入 `/threads/:threadId`；最近回复进入带 `post` 查询的主题目标。

## 4. 用户操作流程

公开页按用户 ID 读取资料，展示头像、用户名、等级、简介、加入日期、统计与关系状态；内容按隐私字段惰性请求并支持游标分页。关注/粉丝统计读取对应关系投影并可继续进入用户资料。登录身份确认后，他人页可关注/取消关注，拉黑需确认，解除拉黑直接执行；关系成功同步按钮、标记和粉丝数。“我的”读取成长与统计，用户名、简介和三项公开范围只发送变化字段，并进入本人关系列表。

## 5. API operationId 与生成类型

- 当前已接入 `usersGetUser`、`usersGetUserCreatedThreads`、`usersGetUserPlayedThreads`、`usersGetUserRecentReplies`、`usersGetUserBookmarks`、`usersGetMe`、`usersUpdateMe`，并消费 social 的四个关系写入与五个关系列表端点。
- 主要生成类型：`PublicUserResponseDto`、`CurrentUserResponseDto`、`PrivateUserResponseDto`、`UpdateUserDto`、`ThreadListItemResponseDto`、`RecentReplyResponseDto`、`BookmarkThreadResponseDto`、`UserFollowRecordResponseDto`、`BlockedUserRecordResponseDto` 与 `ApiPaginationMeta`。
- `usersDeleteMe` 由后续账号生命周期切片接入。

## 6. 状态模型和数据流

`PublicUserController` 管理公开资料与四个内容分区；`MeProfileController` 管理本人资料和编辑。公开页用本人 ID 排除自我操作后，消费 social 的目标关系 family；关系状态独立串行化写入并在页内覆盖公开资料的关系标记与粉丝数。关系列表由 social 的独立 target family 管理，本人目标使用专用端点。公开、私有和关系列表 DTO 分别映射，不互相复用。

## 7. 鉴权、权限和隐私规则

公开内容和关系列表继续严格按服务端投影请求。关系按钮只在 authenticated 且 `usersGetMe.id != target.id` 时出现；身份加载失败宁可隐藏，不猜测自我关系。拉黑影响由服务端决定，客户端不会据此删除关注。游客、退出或会话失效不读取或保留本人关系和黑名单，也不触发关系写入。

## 8. 本地存储、缓存及失效规则

头像走安全 HTTP(S) 图片缓存；公开与本人资料、关系列表分别只存在于当前 autoDispose Provider 生命周期，不写入 Drift 或 SharedPreferences。下拉刷新重新读取服务端；页面销毁、退出、切号或会话失效会释放本人资料、关系状态和未提交表单。

## 9. 加载、空数据、错误、重试和冲突状态

公开资料和内容保持原有页面级与分区级空错恢复。关系列表提供加载、空、失败、请求 ID、重试和刷新，缺失关系投影会安全过滤；本人资料加载失败可重试且仍保留安全退出。两类编辑防重复提交，未变化不发 PATCH，失败保留原资料、输入与请求 ID。用户名占用、7 天冷却和 429 以服务端为准。当前 `UpdateUserDto.bio` 不接受空字符串或 null，因此已有简介清空会在本地明确拦截，不伪装保存成功。

## 10. 跨模块约束

关系写操作由 social 管理，users 只负责身份排除和展示同步；头像上传由 media；密码、邮箱、会话和注销由 settings/auth。搜索与 Markdown 只传 userId，资料页重新校验可见性。最近回复复用 threads 的帖子目标定位，Markdown 摘要走统一安全纯文本转换。

## 11. 测试场景与验收条件

- [x] 公开资料仅展示 `usersGetUser` 响应中允许的字段，非法头像 URL 不加载。
- [x] 加载、失败、请求 ID、重试、注销与 404 使用独立安全状态。
- [x] 360dp、400dp 与 600dp 公开资料布局有 Widget 测试。
- [x] 创建、参与、回复和收藏按隐私字段显示并惰性加载，关闭项不发请求。
- [x] 三类主题列表独立分页、按 ID 去重，cursor 失效从第一页恢复；最近回复使用精确帖子目标。
- [x] 本人资料读取、用户名/简介/公开范围更新、失败重试与服务端结果回写正确。
- [x] 游客不读取私有资料，本人资料与设置在 360dp、400dp、600dp 无布局溢出。
- [x] 他人页关注和拉黑可逆，自我页与游客不显示写操作，失败保留原关系。
- [x] 公开与本人关注/粉丝列表入口、稳定用户导航和窄屏布局通过。
- [ ] 头像变化和重启后显示正确。
- [ ] 关注、拉黑与隐私变化后的跨页面缓存失效完成验证。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。“我的”尚不上传头像或提供注销，密码、邮箱与终端已交由 settings/auth 的独立页面管理。用户动态、勋章、跨页面关系同步和本人私密内容筛选后续接入；公开路由不会绕过关闭的隐私字段。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/users/`。参见[搜索](search.md)、[社交关系](social.md)、[设置](settings.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

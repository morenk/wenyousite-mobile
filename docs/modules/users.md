# 用户与资料

状态：`in_progress`

## 1. 模块目标与非目标

逐步实现用户主页、个人中心、资料与设置、创建/参与主题、公开动态、最近回复、收藏、关注与粉丝列表。当前已提供公开资料与内容分区、用户动态入口、公开及本人关注/粉丝列表、登录用户对他人的关注/拉黑、加油和社区举报入口；“我的”主分支只承担本人摘要、成长统计和内容捷径，资料编辑与账号设置进入独立次级页面。

## 2. 用户角色与使用场景

游客浏览服务端允许的公开资料和内容；登录用户查看关系状态，在确认目标不是本人后可关注或拉黑，并在“我的”管理本人头像、主页背景、私有资料、公开范围和账号生命周期。

## 3. 页面、入口和导航关系

公开用户主页使用稳定路径 `/users/:userId`，可从搜索结果和 Markdown 用户站内链接进入。统计区的“动态”进入 `/users/:userId/moments`；关注和粉丝统计进入指定用户路径；非本人页顶栏提供加油与举报入口，登录身份确认目标非本人且服务端 capability 开启时，“发私聊”进入 `/messages/new/:userId`。本人中心使用主导航 `/me`，展示移动端主页背景、头像、简介、等级进度、统计和“我的动态 / 收藏 / 表情包 / 账号设置”等捷径；`/me/edit` 单独编辑双画幅主页背景、头像、用户名、简介和公开范围，`/me/settings` 汇总黑名单、登录终端、密码、邮箱、注销与退出。钱包、收藏和关系列表继续使用 `/me/wallet`、`/me/bookmarks`、`/me/following`、`/me/followers` 与 `/me/blocks`。创建、参与和收藏主题卡片进入 `/threads/:threadId`；最近回复进入带 `post` 查询的主题目标。

账号设置新增“治理决定与申诉”入口进入公开 `/appeals`；users 只负责可发现入口，列表、申诉正文与专用凭据均由 moderation 独立管理。

## 4. 用户操作流程

头像编辑区只保留标题与操作，不重复说明头像用途。

公开页按用户 ID 读取资料，移动端优先展示 `profileCover.mobile` 的 2:1 背景，缺失时回退根级 3:1 背景，再展示头像、用户名、等级、简介、加入日期、统计与关系状态；本人和他人主页共享全宽身份头。活动汇总独立请求 `usersGetUserActivitySummary`，展示动态、自建主题、参与主题和公开回复；隐私关闭的可空计数显示“未公开”，不会用零值伪装。公开内容使用等宽页签和单列全宽卡片，主题卡沿用主题列表的中文状态语义，不把接口分类 slug 当作用户可读类型；任何资料或内容面板都不得随文字长度收缩。内容按隐私字段惰性请求并支持游标分页。关注/粉丝统计读取对应关系投影并可继续进入用户资料。登录身份确认后，他人页可关注/取消关注，拉黑需确认，解除拉黑直接执行；关系成功同步按钮、标记和粉丝数；私聊入口只传稳定用户 ID，联系状态由 direct-messages 页面重读。“我的”先帮助用户判断“我是谁、我的内容在哪里”，编辑资料与高风险账号动作不与总览混排。用户名、简介和三项公开范围只发送变化字段；头像先经 media 完成上传，再用 `mediaId` 设置。主页背景从一张安全图片自动居中裁出 3:1 和 2:1 两份，分别上传成功后才一次提交两个 `mediaId`，移除时也同时清空双画幅；头像和背景移除都需二次确认。注销入口转交 settings/auth 完成不可逆确认和会话清理。

## 5. API operationId 与生成类型

- 当前已接入 `usersGetUser`、`usersGetUserCreatedThreads`、`usersGetUserPlayedThreads`、`usersGetUserRecentReplies`、`usersGetUserBookmarks`、`usersGetUserActivitySummary`、`usersGetMe`、`usersUpdateMe`、`usersSetAvatar`、`usersRemoveAvatar`、`usersSetProfileCover`、`usersRemoveProfileCover`、`usersDeleteMe`、`usersMentionCandidates`，并消费 moments 的 `userMomentsList`、reports 的 `reportsCreate` 以及 social 的四个关系写入与五个关系列表端点。
- 主要生成类型：`PublicUserResponseDto`、`CurrentUserResponseDto`、`PrivateUserResponseDto`、`ProfileCoverResponseDto`、`ProfileCoverVariantResponseDto`、`UserActivitySummaryResponseDto`、`SetProfileCoverDto`、`UpdateUserDto`、`SetAvatarDto`、`MentionCandidatesResponseDto`、`MentionCandidateDto`、`ThreadListItemResponseDto`、`RecentReplyResponseDto`、`BookmarkThreadResponseDto`、`UserFollowRecordResponseDto`、`BlockedUserRecordResponseDto` 与 `ApiPaginationMeta`。

## 6. 状态模型和数据流

`PublicUserController` 管理公开资料、活动汇总与四个内容分区；活动汇总拥有独立加载/失败状态，不阻塞资料和内容。`MeProfileController` 管理本人资料和编辑。公开资料、本人资料、头像与背景写入由 `users/application` 端口表达，`main.dart` 组合根绑定生成客户端 data 适配器；users 控制器与私聊目标解析都不直接导入 users data。头像/背景格式策略、相册端口和上传任务生命周期属于 `media/application`；`AvatarController` 与 `ProfileCoverController` 只映射共享上传状态，并编排写入/移除、取消和失败恢复，不导入 Dio 或 media data 实现。背景控制器顺序上传两个画幅，已完成的 `mediaId` 在设置失败时保留，重试不会重复上传；成功只把服务端背景和更新时间合并回本人资料。公开页用本人 ID 排除自我操作后，消费 social 的目标关系 family；关系状态独立串行化写入并在页内覆盖公开资料的关系标记与粉丝数。关系列表由 social 的独立 target family 管理，本人目标使用专用端点。公开、私有和关系列表 DTO 分别映射，不互相复用。

## 7. 鉴权、权限和隐私规则

公开内容、活动汇总和关系列表继续严格按服务端投影请求。关系按钮和私聊入口只在 authenticated 且 `usersGetMe.id != target.id` 时出现；私聊入口还要求 `meta.capabilities.directMessages`。身份或 capability 加载失败宁可隐藏，不猜测自我关系。拉黑影响由服务端决定，用户页不会据此删除关注或直接判断私聊历史。契约 4.14 不再存在未验证注册用户或写操作邮箱验证门槛；所有已建立会话的注册用户按同一身份规则操作，权限仍由各端点复核。游客、退出或会话失效不读取或保留本人关系、黑名单或媒体 ID，也不触发资料写入。头像与背景只接受安全 HTTP(S) 响应，文件字节和预签名 URL 不进入用户资料状态。

## 8. 本地存储、缓存及失效规则

头像与背景走安全 HTTP(S) 图片缓存；设置或移除成功主动淘汰旧 URL，本人页面立即采用服务端结果。公开与本人资料、活动汇总、关系列表分别只存在于当前 autoDispose Provider 生命周期，不写入 Drift 或 SharedPreferences；应用重启重新读取服务端，不保留陈旧本机媒体或统计事实。下拉刷新重新读取服务端；页面销毁、退出、切号或会话失效会释放本人资料、关系状态、待设置媒体 ID 和未提交表单。

## 9. 加载、空数据、错误、重试和冲突状态

公开资料、活动汇总和内容保持页面级与分区级空错恢复；活动汇总失败只隐藏四项计数并提供独立重试。关系列表提供加载、空、失败、请求 ID、重试和刷新，缺失关系投影会安全过滤；本人资料加载失败可重试且仍保留安全退出。资料、头像与背景写入互斥，未变化不发 PATCH，失败保留原资料、输入与请求 ID。媒体选择取消静默返回，上传可取消；头像设置失败只重试设置端点，背景则保留已完成的两个 `mediaId` 后原子重试，移除失败不清空旧图。用户名占用、7 天冷却和 429 以服务端为准。当前 `UpdateUserDto.bio` 不接受空字符串或 null，因此已有简介清空会在本地明确拦截，不伪装保存成功。

## 10. 跨模块约束

关系写操作由 social 管理，users 只负责身份排除和展示同步；温油余额、流水与用户加油由 wallet 管理，成功后 users 重读公开收款统计；社区举报由 reports 提交，users 只提供稳定公开 userId 并排除本人；私聊联系状态、权限和正文由 direct-messages 管理；头像上传由 media；密码、邮箱、会话和注销由 settings/auth。提及候选虽由 Users API 返回，但由 editor 按真实主题上下文管理输入、防抖、竞态和原子插入，users 页面不缓存或展示该隐私投影。注销后的公开身份、头像和内容归属严格采用服务端匿名化投影，不由客户端自行拼装。搜索、Markdown 和私聊入口只传 userId，目标页面重新校验可见性。最近回复复用 threads 的帖子目标定位，Markdown 摘要走统一安全纯文本转换。

## 11. 测试场景与验收条件

- [x] 公开资料仅展示 `usersGetUser` 响应中允许的字段，非法头像 URL 不加载。
- [x] 加载、失败、请求 ID、重试、注销与 404 使用独立安全状态。
- [x] 360dp、400dp 与 600dp 公开资料头、等宽页签和内容区固定占满可用内容宽度，不随用户名、简介或统计文本长度改变；本人资料头同样有精确宽度断言。
- [x] 创建、参与、回复和收藏按隐私字段显示并惰性加载，关闭项不发请求。
- [x] 三类主题列表独立分页、按 ID 去重，cursor 失效从第一页恢复；最近回复使用精确帖子目标。
- [x] 本人资料读取、用户名/简介/公开范围更新、失败重试与服务端结果回写正确。
- [x] 本人资料响应包含 `profileCover.mobile` 双画幅背景图时，生成客户端完整注册嵌套 DTO serializer，成功响应不会降级为“本人资料没有加载完成”。
- [x] 一张安全图片自动生成严格 3:1 与 2:1 画幅，双媒体上传后一次设置；取消、部分上传失败、设置重试、移除确认和缓存失效正确。
- [x] 公开主页优先显示移动端 2:1 背景并回退根级画幅；活动汇总独立加载，隐私字段显示“未公开”，失败可单独重试。
- [x] 本人页与公开用户页复用整宽资料头，统一 88dp 头像、等级与状态徽标、资料元信息和等宽统计入口；320/360/400/600dp 均占满可用内容宽度且不溢出。
- [x] 游客不读取私有资料，本人资料与设置在 360dp、400dp、600dp 无布局溢出。
- [x] “我的”是本人摘要与内容捷径，公开主页预览使用只读模式；`/me/edit` 和 `/me/settings` 分离资料编辑与账号安全操作。
- [x] 他人页关注和拉黑可逆，自我页与游客不显示写操作，失败保留原关系。
- [x] 公开与本人关注/粉丝列表入口、稳定用户导航和窄屏布局通过。
- [x] “我的”注销入口、确认链路、匿名保留说明与本机会话清理闭环通过。
- [x] 头像选择与格式拒绝、共享上传进度/取消、设置、二次确认移除、显式 URL 降级、缓存失效及重启后服务端恢复正确。
- [x] 私聊 capability 开启且目标非本人时展示稳定新私聊入口，关闭时不暴露入口。
- [x] 所有公开用户均可从稳定 userId 进入独立用户动态列表，不复制动态列表状态到用户资料控制器。
- [x] 非本人公开页进入用户加油，本人“我的”进入受保护钱包；成功后累计收到加油采用服务端投影。
- [x] 非本人、未注销的公开用户展示举报入口；游客保留完整登录回跳，本人页不暴露入口。
- [ ] 关注、拉黑与隐私变化后的跨页面缓存失效完成验证。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。头像当前不提供手动裁剪；主页背景使用自动居中裁剪，不提供交互式选框。密码、邮箱、终端与注销已交由 settings/auth 的独立页面管理。用户动态已由 moments 独立列表接入；勋章、跨页面关系同步和本人私密内容筛选后续接入，公开路由不会绕过关闭的隐私字段。

## 13. 最近审查的契约版本和后端提交

契约 `4.14.0-dev.20260815.1`；Markdown v3；后端 `9752c2289acb0db19af7d91d98978adb558991bf`。

## 14. 相关代码与架构文档

代码入口：`lib/features/users/application/user_repository_ports.dart`、`lib/features/users/data/`、`lib/main.dart`。参见[动态](moments.md)、[搜索](search.md)、[社交关系](social.md)、[温油钱包](wallet.md)、[社区举报](reports.md)、[治理决定与申诉](moderation.md)、[站内私聊](direct-messages.md)、[设置](settings.md)、[Foundation v2.4.2 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v2.4.2/docs/platforms/mobile.md)。

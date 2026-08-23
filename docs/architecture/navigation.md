# 导航

消息列表的规范入口是 `/notifications`；私聊页签使用 `/notifications?section=directMessages`，旧 `/messages` 只负责兼容重定向。`/messages/new/:userId` 与 `/messages/:conversationId` 仍分别承载新私聊和会话详情。

go_router 是唯一导航入口。`AppRouteLocations` 负责路径段与 `returnTo` 编码，页面使用命名路由或位置构造器，不直接拼接路径；`AppRouteAccessPolicy` 以纯 Dart 访问级别决定登录守卫，router 只负责组合与重定向。根级兼容检查先于业务路由；未知契约主版本进入升级提示页，网络失败进入可重试页。

Android 页面转场也只有一个实现边界：真实入栈与返回统一使用 Foundation standard 180ms 的水平位移，不叠加缩放、圆角、阴影或淡化。主分支壳切换和无来源栈的安全兜底保持瞬时；正文与动态全屏原图使用 Foundation fast 120ms 单一淡化，Bottom Sheet、Dialog 及帖子编辑器内部 Navigator 保持各自交互语义。系统开启“减少动态效果”时，上述路由时长全部降为零。页面不得自行构造 `MaterialPageRoute`、`PageRouteBuilder`、`CustomTransitionPage` 或 `NoTransitionPage`。

主导航使用保留状态的四分支壳：首页 `/home`、动态 `/moments`、消息 `/notifications`、我的 `/me`；底栏中央是粉色发布动作，不占用独立路由分支。全站搜索 `/search` 由首页和动态顶栏的搜索按钮进入。消息分支在 capability 开启时以“通知 / 私信”同级页签组合两类独立状态。`/me` 对游客提供登录入口，登录后展示本人摘要与内容捷径；`/me/edit` 编辑资料，`/me/settings` 汇总账号设置，并可进入 `/users/:userId` 预览自己的公开主页，或进入 `/me/bookmarks` 管理本人私有主题收藏夹，进入 `/me/following`、`/me/followers`、`/me/blocks` 管理关系；收藏夹筛选与移动只改变页面内状态，不产生临时子路由。用户还可通过 `/me/security/sessions`、`/me/security/password`、`/me/security/email`、`/me/security/delete-account` 管理登录终端、密码、更换邮箱与账号注销；这些私有路径与 `/compose/thread`、`/compose/moment`、`/threads/:threadId/manage`、`/join/:token` 一样，未登录时先去 `/auth/login?returnTo=...`。登录页、`/auth/register`、`/auth/forgot-password` 与 `/auth/reset-password` 透传同一个 `returnTo`；注册或登录成功后恢复原目标，重置密码成功则回登录页并保留目标。找回到重置只用路由内存 `extra` 传递规范化邮箱，不把邮箱、验证码或密码写入查询参数；重置页也允许独立进入并重新发码。改密和换邮箱成功会清除本机会话并进入 `/auth/login?returnTo=/me`。注销成功会归一为游客态并进入 `/home`，不返回或保留破坏性表单目标；远端已完成但本地清理失败时停留原页，只允许重试本机清理。会话失效时统一跳转登录页并保留安全的仓库内目标，但找回/重置公开路由保持可达；用户可重新登录或将 invalidated 状态归一为 guest 后返回首页。回跳只接受仓库内绝对路径并拒绝认证页自循环；主题、动态、楼层、用户、邀请和通知目标使用命名路由，禁止页面自行拼接不透明参数。

“表情包”使用受保护命名路由 `/me/stickers`，且只有 `meta.capabilities.stickers` 明确开启时才从“我的”、编辑器和私信输入器暴露入口。收藏 ID、资产 ID、导入 ID 与收藏夹版本都由服务端提供；路由只负责登录回跳，页面重新读取当前账号私有收藏，不把列表、图片 URL 或导入状态写入路径。

动态主分支使用 `/moments`，发现流公开，关注流在分支内为游客显示登录回跳。公开详情 `/moments/:momentId`、公开用户动态 `/users/:userId/moments` 只携带服务端稳定 ID；受保护的 `/compose/moment`、`/moments/:momentId/edit` 与 `/moments/bookmarks` 保留完整登录回跳。从信息流、通知、搜索或用户内容入栈进入动态详情时返回真实来源；直接以无来源栈路径进入详情时，系统返回和顶栏返回都回 `/moments`，不能结束 Android 应用进程。底栏中央发布动作在四个主分支中稳定打开“发布主题帖 / 发布动态”面板，当前首页或动态分支只改变推荐项。发布/编辑成功后失效信息流和详情，删除成功回动态分支；筛选、评论作者和 cursor 只存在页面状态。

公开主题详情使用命名路由 `/threads/:threadId`。首页和搜索主题卡片通过主题 ID 入栈进入该路由；系统返回时回到原分支，并保留分支状态。直接以无来源栈路径进入详情时，系统返回和顶栏返回都回 `/home`，不能结束 Android 应用进程。详情工具栏进入公开 `/threads/:threadId/search`，服务端以 OptionalAuth 复核当前主题访问权限，结果仍用稳定 post ID 回详情定位。详情页优先选择响应中的 `defaultSubthreadId`，子贴切换只更新正文与楼层数据源，不把子贴 ID 拼入临时页面路径。服务端 capability 允许时，详情进入受保护命名路由 `/threads/:threadId/manage`，标签、子贴目录和成员身份工作台分别使用 `/threads/:threadId/manage/tags`、`/threads/:threadId/manage/subthreads` 与 `/threads/:threadId/manage/members`；四条管理路由都保留完整登录回跳。保存、标签、目录或成员变更成功后返回详情并重读权威投影，删除成功进入 `/home`，未保存表单返回前要求明确放弃。

公开标签使用命名路由 `/tags/:tagId`。首页、主题详情和标签主题卡片只传服务端稳定标签 ID，页面重新读取 `tagsGetById` 事实并通过 `threadsFindAll(tagId)` 精确聚合公开主题；标签不存在、已停用或不可访问时不根据名称猜测替代目标。公开标签页不要求登录，进入其中的主题仍复用 `/threads/:threadId`。

私密邀请使用受保护命名路由 `/join/:token`，token 是 16 位不透明 base64url 值，只用于预览和幂等加入，不解析业务信息。游客进入时完整路径写入安全 `returnTo`，登录后恢复预览并由用户显式确认加入；契约 4.14 后不再存在登录后邮箱验证门槛。预览确认已加入或加入响应中的主题 ID 与预览一致后，替换到 `/threads/:threadId`。失效邀请回首页，不猜测主题 ID。V1 未配置 Android App Links，楼主复制的是 Web 同形链接，由 Web 负责外部落地；应用内路由先固定兼容边界。

0.3 的全站搜索页使用 `/search`，“动态 / 主题帖 / 楼层内容 / 用户”四个纯文字等宽 Tab 按需加载并在 360dp 全部可见。动态进入 `/moments/:momentId`，主题帖进入 `/threads/:threadId`，楼层内容进入同一主题详情的 `post` 定位。公开用户资料使用命名路由 `/users/:userId`；搜索用户结果和 Markdown `/users/{id}` 站内链接只传稳定用户 ID，由资料页重新读取权限与可见性。公开统计进入 `/users/:userId/following` 与 `/users/:userId/followers`，列表项再以 userId 返回同一资料路由。公开用户内容里的主题卡片继续进入 `/threads/:threadId`，最近回复则使用同一 `post` 查询参数约定，不建立用户页专属临时目标。

正文搜索结果与 post 通知目标使用 `/threads/:threadId?post=:postId`。`post` 是服务端稳定帖子 ID，不是本地页码：主题详情先读取帖子所属子贴；目标为楼中楼时再补取父楼层，然后自动切换子贴并将目标上下文置顶，其余已加载楼层保持服务端顺序。目标只显示 1dp Foundation 淡粉边框，不铺底色、不扩大到整组上下文，也不展示“已定位到”可见说明；边框在 1.2 秒后按 slow motion 淡出，减少动态效果时直接复原。无障碍定位提示可通过语义公告提供，不增加页面说明文字。目标不存在、无权访问或属于其他主题时显示安全错误，不猜测位置。

楼中楼使用公开命名路由 `/threads/:threadId/posts/:postId/replies`，其中 `postId` 必须是普通主楼层；可选 `?post=:replyId` 补取并强调首屏外回复。独立页重新校验楼层与主题关系，排序、作者筛选和 cursor 只作为页面状态，不写入临时路径。游客可阅读，发表入口在登录后恢复到同一路由。

通知导航只读取服务端 `target.kind` 与对应稳定 ID：post 进入上述精确位置，thread 进入主题详情，user 进入公开用户页，moment 进入 `/moments/:momentId`，none/unknown 不导航；服务端关联对象已删除时同样不导航。

站内私聊的新建页和会话详情使用受保护命名路由 `/messages/new/:userId` 与 `/messages/:conversationId`，游客访问时完整保留原目标进入登录。根路径 `/messages` 只是旧消息中心兼容入口，必须重定向到 `/notifications?section=directMessages`，不能作为第二个私聊列表事实源。通知页只导航到统一消息中心，用户主页只把稳定 userId 交给新私聊页；新私聊页通过 `directConversationsFindByUser` 决定替换到已有 ACCEPTED/PENDING 会话、允许重建或显示受限状态。会话 ID、消息 ID、cursor 和增量 after 都是不透明服务端标识，页面不从用户名、正文预览或关系标记推导目标。

V1 不配置 Android App Links。应用内部仍使用稳定路径，给后续深链留下兼容边界。Markdown 中的相对站内路径以及 `wenyou.site`、`www.wenyou.site` 绝对链接由移动端自动识别并交给应用路由；动态纯文本则严格按 `wenyousite-internal-reference` v1 只识别生产域主题、子贴、楼层、讨论和 `/join/:token` 私密邀请坐标，普通 Markdown 与外链保持字面文本。邀请能力、token 凭据边界与编辑器智能粘贴以 `contracts/internal-reference-v1-fixtures.json` 为事实源；阅读态已消费全部坐标与渲染用例，主题和帖子编辑器也已消费 `editorPasteCases`，仅当剪贴板整体为合法坐标时插入不导航的原子传送门。公开 `/appeals` 不要求普通会话，避免受处罚账号被守卫循环拦截；其专用凭据不进入其他路由。站内目标如果当前移动端没有对应页面，会保留在应用内并提示暂不支持。

参见：[应用壳](../modules/app-shell.md)、[认证](../modules/auth.md)、[动态](../modules/moments.md)、[主题与子贴](../modules/threads.md)、[标签](../modules/tags.md)、[楼层与回复](../modules/posts.md)、[站内私聊](../modules/direct-messages.md)。

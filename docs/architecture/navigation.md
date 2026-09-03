# 导航

消息列表的规范入口是 `/notifications`；私聊页签使用 `/notifications?section=directMessages`，旧 `/messages` 只负责兼容重定向。`/messages/new/:userId` 与 `/messages/:conversationId` 仍分别承载新私聊和会话详情。

go_router 是唯一导航入口。`AppRouteLocations` 负责路径段与 `returnTo` 编码，页面使用命名路由或位置构造器，不直接拼接路径；`AppRouteAccessPolicy` 以纯 Dart 访问级别决定登录守卫，router 只负责组合与重定向。根级兼容检查先于业务路由；未知契约主版本进入升级提示页，网络失败进入可重试页。

`app_router.dart` 只保留 router 生命周期、全局重定向和四组路由组合；主壳、认证、内容和账号路由分别位于 `lib/app/routes/`。拆分只改变组合边界，公开路径、命名、登录回跳、页面转场和分支保状态语义不变；生产组合测试必须能读取全部必需端口，防止新 provider 忘记在组合根绑定。

Android 页面转场也只有一个实现边界：真实入栈与返回统一使用 Foundation standard 180ms 的水平位移，不叠加缩放、圆角、阴影或淡化。主分支壳切换和无来源栈的安全兜底保持瞬时；正文与动态全屏原图使用 Foundation fast 120ms 单一淡化，Bottom Sheet、Dialog 及帖子编辑器内部 Navigator 保持各自交互语义。系统开启“减少动态效果”时，上述路由时长全部降为零。页面不得自行构造 `MaterialPageRoute`、`PageRouteBuilder`、`CustomTransitionPage` 或 `NoTransitionPage`。共享标准转场纳入[移动端性能基线](performance.md)的 60 Hz Profile 三轮门禁；Debug 目测不作为删除转场的依据。

主导航使用保留状态的四分支壳：首页 `/home`、动态 `/moments`、消息 `/notifications`、我的 `/me`；底栏中央发布是动作而非分支。左右滑动只作用于首页分类、动态“发现 / 关注”和消息“通知 / 私聊”等页面内部相邻栏目，不切换底部四个主分支；相邻栏目内容按 Foundation standard 180ms 沿切换方向轻量入场，页签与已访问栏目状态保持稳定，减少动态效果时瞬时完成。全站搜索 `/search` 由首页和动态顶栏进入。消息分支在 capability 开启时以“通知 / 私聊”同级页签组合两类状态，点按或内容区左右滑动都写入同一规范 URL；通知分类与私聊“会话 / 请求 / 归档”只改变页面筛选，不创建额外路由事实源。

`/me` 对游客提供登录入口，登录后展示本人摘要与“概览 / 动态 / 创建 / 参与”四个同级内容页签；`/me/edit` 编辑资料，`/me/settings` 独立汇总账号设置。`/me/bookmarks` 是统一收藏入口，直接展示当前类型默认夹，以“主题 / 动态”页签和收藏夹筛选器原地切换；旧 `/me/bookmarks/threads`、`/me/bookmarks/moments` 与 `/moments/bookmarks` 重定向到统一页，指定夹路径继续使用 `/me/bookmarks/threads/folders/:folderId` 或 `/me/bookmarks/moments/folders/:folderId`，旧 `/me/bookmarks/folders/:folderId` 兼容主题指定夹。关系入口使用 `/me/following`、`/me/followers`、`/me/blocks`。

账号安全使用 `/me/security/sessions`、`/me/security/password`、`/me/security/email`、`/me/security/delete-account`。这些私有路径与创作、管理和邀请路径一样，未登录时先进入带安全 `returnTo` 的登录页。登录、注册、找回和重置透传同一目标；找回到重置只用路由内存 `extra` 携带规范化邮箱，不把邮箱、验证码或密码写入查询参数。改密和换邮箱成功清除本机会话并要求重新登录；注销成功进入首页游客态。会话失效统一保留安全仓库内目标，回跳拒绝认证页自循环；业务目标使用命名路由，不由页面拼接不透明参数。

“表情包”使用受保护命名路由 `/me/stickers`，且只有 `meta.capabilities.stickers` 明确开启时才从“我的”、编辑器和私信输入器暴露入口。收藏 ID、资产 ID、导入 ID 与收藏夹版本都由服务端提供；路由只负责登录回跳，页面重新读取当前账号私有收藏，不把列表、图片 URL 或导入状态写入路径。

动态主分支使用 `/moments`，发现流公开，关注流在分支内为游客显示登录回跳。公开详情 `/moments/:momentId`、公开用户动态 `/users/:userId/moments` 只携带服务端稳定 ID；动态评论通知可使用 `/moments/:momentId?comment=:commentId` 携带服务端稳定评论坐标。详情按该坐标调用 `momentsCommentContext`，把返回的主评论与目标回复注入普通评论投影后直接滚动，不扫描评论或楼中楼分页猜测位置；只给目标评论显示 1dp Foundation 淡粉边框，1.2 秒后按 slow motion 淡出。404 保留动态与普通评论并提示目标不可见，临时失败只重试定位请求。受保护的 `/compose/moment`、`/moments/:momentId/edit`、动态收藏目录和指定夹路径保留完整登录回跳。从信息流、通知、搜索或用户内容入栈进入动态详情时返回真实来源；直接以无来源栈路径进入详情时，系统返回和顶栏返回都回 `/moments`，不能结束 Android 应用进程。底栏中央发布动作在四个主分支中稳定打开“发布主题帖 / 发布动态”面板，当前首页或动态分支只改变推荐项。发布/编辑成功后失效信息流和详情，删除成功回动态分支；筛选、评论作者和 cursor 只存在页面状态。

公开主题详情使用命名路由 `/threads/:threadId`。首页和搜索主题卡片通过主题 ID 入栈进入该路由；系统返回时回到原分支，并保留分支状态。直接以无来源栈路径进入详情时，系统返回和顶栏返回都回 `/home`，不能结束 Android 应用进程。详情工具栏进入公开 `/threads/:threadId/search`，服务端以 OptionalAuth 复核当前主题访问权限，结果仍用稳定 post ID 回详情定位。详情页优先选择响应中的 `defaultSubthreadId`，子贴切换只更新正文与楼层数据源，不把子贴 ID 拼入临时页面路径。服务端 capability 允许时，详情进入受保护命名路由 `/threads/:threadId/manage`，标签、子贴目录和成员身份工作台分别使用 `/threads/:threadId/manage/tags`、`/threads/:threadId/manage/subthreads` 与 `/threads/:threadId/manage/members`；四条管理路由都保留完整登录回跳。保存、标签、目录或成员变更成功后返回详情并重读权威投影，删除成功进入 `/home`，未保存表单返回前要求明确放弃。

公开标签使用命名路由 `/tags/:tagId`。首页、主题详情和标签主题卡片只传服务端稳定标签 ID，页面重新读取 `tagsGetById` 事实并通过 `threadsFindAll(tagId)` 精确聚合公开主题；标签不存在、已停用或不可访问时不根据名称猜测替代目标。公开标签页不要求登录，进入其中的主题仍复用 `/threads/:threadId`。

私密邀请使用受保护命名路由 `/join/:token`，token 是 16 位不透明 base64url 值，只用于预览和幂等加入，不解析业务信息。游客进入时完整路径写入安全 `returnTo`，登录后恢复预览并由用户显式确认加入；契约 4.14 后不再存在登录后邮箱验证门槛。预览确认已加入或加入响应中的主题 ID 与预览一致后，替换到 `/threads/:threadId`。失效邀请回首页，不猜测主题 ID。V1 未配置 Android App Links，楼主复制的是 Web 同形链接，由 Web 负责外部落地；应用内路由先固定兼容边界。

0.3 的全站搜索页使用 `/search`，“动态 / 主题帖 / 楼层内容 / 用户”四个纯文字等宽 Tab 按需加载并在 360dp 全部可见。动态进入 `/moments/:momentId`，主题帖进入 `/threads/:threadId`，楼层内容进入同一主题详情的 `post` 定位。公开用户资料使用命名路由 `/users/:userId`；搜索用户结果和 Markdown `/users/{id}` 站内链接只传稳定用户 ID，由资料页重新读取权限与可见性。公开统计进入 `/users/:userId/following` 与 `/users/:userId/followers`，列表项再以 userId 返回同一资料路由。公开用户内容里的主题卡片继续进入 `/threads/:threadId`，最近回复则使用同一 `post` 查询参数约定，不建立用户页专属临时目标。

正文搜索结果与 post 通知目标使用 `/threads/:threadId?post=:postId`。`post` 是服务端稳定帖子 ID，不是本地页码：主题详情先读取帖子所属子贴；目标为楼中楼时再补取父楼层，然后自动切换子贴并将目标上下文置顶，其余已加载楼层保持服务端顺序。目标只显示 1dp Foundation 淡粉边框，不铺底色、不扩大到整组上下文，也不展示“已定位到”可见说明；边框在 1.2 秒后按 slow motion 淡出，减少动态效果时直接复原。无障碍定位提示可通过语义公告提供，不增加页面说明文字。目标不存在、无权访问或属于其他主题时显示安全错误，不猜测位置。

楼中楼使用公开命名路由 `/threads/:threadId/posts/:postId/replies`，其中 `postId` 必须是普通主楼层；可选 `?post=:replyId` 补取并强调首屏外回复。独立页重新校验楼层与主题关系，排序、作者筛选和 cursor 只作为页面状态，不写入临时路径。游客可阅读，发表入口在登录后恢复到同一路由。

通知导航只读取服务端 `target.kind` 与对应稳定 ID：post 进入上述精确位置，thread 进入主题详情，user 进入公开用户页，moment 进入 `/moments/:momentId`，带 `momentCommentId` 时追加 `?comment=:commentId`，none/unknown 不导航；服务端关联对象已删除时同样不导航。

站内私聊的新建页和会话详情使用受保护命名路由 `/messages/new/:userId` 与 `/messages/:conversationId`，游客访问时完整保留原目标进入登录。根路径 `/messages` 只是旧消息中心兼容入口，必须重定向到 `/notifications?section=directMessages`，不能作为第二个私聊列表事实源。通知页只导航到统一消息中心，用户主页只把稳定 userId 交给新私聊页；新私聊页通过 `directConversationsFindByUser` 决定替换到已有 ACCEPTED/PENDING 会话、允许重建或显示受限状态。会话 ID、消息 ID、cursor 和增量 after 都是不透明服务端标识，页面不从用户名、正文预览或关系标记推导目标。

V1 不配置 Android App Links。应用内部仍使用稳定路径，给后续深链留下兼容边界。Markdown 中的相对站内路径以及 `wenyou.site`、`www.wenyou.site` 绝对链接由移动端自动识别并交给应用路由；动态纯文本则严格按 `wenyousite-internal-reference` v1 只识别生产域主题、子贴、楼层、讨论和 `/join/:token` 私密邀请坐标，普通 Markdown 与外链保持字面文本。应用冷启动或回前台发现剪贴板整体为其中任一合法坐标时先询问用户，确认后交给同一路由；混合文本、站外链接和同一剪贴板内容不触发或重复提示。邀请能力、token 凭据边界与编辑器智能粘贴以 `contracts/internal-reference-v1-fixtures.json` 为事实源；阅读态已消费全部坐标与渲染用例，主题和帖子编辑器也已消费 `editorPasteCases`，仅当剪贴板整体为合法坐标时插入不导航的原子传送门。公开 `/appeals` 不要求普通会话，避免受处罚账号被守卫循环拦截；其专用凭据不进入其他路由。站内目标如果当前移动端没有对应页面，会保留在应用内并提示暂不支持。

参见：[应用壳](../modules/app-shell.md)、[认证](../modules/auth.md)、[动态](../modules/moments.md)、[主题与子贴](../modules/threads.md)、[标签](../modules/tags.md)、[楼层与回复](../modules/posts.md)、[站内私聊](../modules/direct-messages.md)。

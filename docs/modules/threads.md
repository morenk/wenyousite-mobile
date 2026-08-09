# 主题与子贴

状态：`in_progress`

## 1. 模块目标与非目标

0.3 当前实现公开主题详情、子贴选择、Markdown 正文只读展示，以及点赞、收藏和两类订阅互动，并协调 posts 模块加载所选子贴的升序楼层。创建/编辑/删除、私密邀请和成员工作台后置；V1 不实现举报后台或子贴标签。

## 2. 用户角色与使用场景

游客和登录用户都能阅读公开主题、切换子贴、浏览楼层和查看喜欢数；游客点赞先登录，登录用户可点赞与收藏。普通登录用户还可订阅官方更新和已标记玩家发言；楼主/协作者自动收取更新，不显示订阅控件。成员参与、拥有者管理及私密邀请属于后续工作台切片。

## 3. 页面、入口和导航关系

首页和搜索主题卡片进入命名路由 `/threads/:threadId`；正文搜索结果使用 `/threads/:threadId?post=:postId` 复用同一详情页。游客从互动入口登录时保留完整主题与帖子目标。子贴切换同时控制正文与楼层数据源；工作台、成员页和邀请预览为后续二级路由。

## 4. 用户操作流程

调用主题详情接口加载元数据、标签、登录态互动与 capability 投影；按 `sortOrder` 排列子贴并加载对应正文/楼层。带 `post` 目标时解析所属子贴并展示上下文。点赞采用服务端计数，收藏按记录 ID 删除。普通登录用户并发读取本人订阅和成员候选：`THREAD` 切换官方更新，`USER` 在底部面板逐人管理已标记普通玩家。

## 5. API operationId 与生成类型

- 当前读取：`threadsFindById`、用于目标定位的 `postsFindById`；主题详情响应已经包含子贴集合、子贴正文、主题标签、统计和点赞状态、收藏状态、收藏记录 ID 等可选登录态投影，不额外请求子贴列表。
- 当前互动：`threadsLike`、`threadsUnlike`、`bookmarksCreate`、`bookmarksRemove`、`subscriptionsFindAll`、`subscriptionsCreate`、`subscriptionsRemove`、`threadMembersFindAll`。
- 主要生成类型：`ThreadDetailResponseDto`、`ThreadCapabilitiesResponseDto`、`SubscriptionResponseDto`、`CreateSubscriptionDto`、`ThreadMemberResponseDto`、`ThreadLikeResponseDto`、`BookmarkResponseDto`、`ThreadSubthreadResponseDto`。
- 后续写入与工作台：`threadsCreate`、`threadsUpdate`、`threadsRemove`、`threadsSaveAggregate`、`subthreadsCreate`、`subthreadsUpdate`、`subthreadsRemove`、`subthreadsReorder`、邀请和成员管理 operationId。

## 6. 状态模型和数据流

主题详情阶段、详情数据、选中子贴 ID 与当前楼层页分离，控制器丢弃过期请求；目标帖子由独立 FutureProvider 读取。点赞/收藏与订阅分别由 social 的 autoDispose family 管理；订阅列表和玩家候选并发加载，同一主题的官方/玩家订阅写入串行执行。身份变化重取详情投影并释放旧身份状态。

## 7. 鉴权、权限和隐私规则

公开详情使用 OptionalAuth，游客可读取，登录态附加字段缺失时安全降级。游客点赞只进入登录，收藏与订阅入口不显示。订阅用 capability 与当前角色识别自动接收更新的楼主/协作者并隐藏控件；USER 候选仅取已标记普通玩家并排除本人，服务端继续作最终权限校验。不可访问主题不泄露标题、成员、正文或缓存内容。

## 8. 本地存储、缓存及失效规则

详情、所选子贴、楼层、互动和订阅仅做 Riverpod 进程内状态；不写 Drift，不提供离线阅读或写入队列。返回首页时保留首页状态；离页、切号、权限变化、404 或 403 会释放或清除对应状态。

## 9. 加载、空数据、错误、重试和冲突状态

首次加载、重新加载、主题不可访问、无子贴和正文安全降级分别展示明确状态；目标定位另有完整空错重试。互动与订阅串行执行，空响应或缺失记录 ID 不伪装成功，失败保留旧状态与请求 ID。订阅初始读取可重试，玩家候选为空时省略入口；其他写入冲突和邀请失效状态后续接入。

## 10. 跨模块约束

正文按 Markdown v2 只读规则渲染，未知扩展节点安全降级；楼层由 posts 模块加载。点赞、收藏和订阅由 social 管理，threads 只提供详情 capability、当前成员与成员候选事实；编辑器写入后置。

## 11. 测试场景与验收条件

- [x] 首页卡片进入正确的公开详情，系统返回后首页已加载状态保持。
- [x] 默认子贴选择正确；切换子贴同步切换 Markdown 正文和对应楼层页。
- [x] 标题、作者、分类、状态、标签、统计与正文可安全展示，Markdown 未知骰子结果可降级。
- [x] 加载、重试、楼层错误和 404/无权限状态完整且不泄露私密信息。
- [x] 正文搜索目标能自动切换所属子贴并展示目标楼层或楼中楼上下文。
- [x] 点赞/取消点赞使用服务端计数，收藏/取消收藏使用稳定记录 ID，失败保留旧状态。
- [x] 游客互动登录回跳保留帖子目标，登录身份变化重取投影，登录态操作和 360/400/600dp 布局通过。
- [x] 两类订阅采用服务端记录 ID，候选/本人/管理者过滤、失败恢复及多宽度玩家面板通过。
- [ ] 后续单独接入创建编辑删除、邀请及成员管理。

## 12. 已知限制和后续功能

0.3 当前完成“详情 + 子贴正文 + 楼层分页/内嵌回复 + 搜索目标定位 + 点赞收藏订阅”；独立楼中楼页和内容写操作后置。0.4 继续补齐收藏管理等互动入口，0.5 接入编辑器与发布，0.6 完成工作台、成员和私密邀请；V1 不做举报管理和子贴标签。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/threads/`。参见[楼层与回复](posts.md)、[导航](../architecture/navigation.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

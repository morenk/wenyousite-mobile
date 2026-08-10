# 主题与子贴

状态：`in_progress`

## 1. 模块目标与非目标

当前实现公开主题详情、子贴选择、Markdown 正文展示、点赞/收藏/订阅互动、新建主题的本地恢复/服务端草稿/聚合发布，并让楼主或协作者添加和编辑子贴正文、管理已有主题元数据。楼主还可在二次确认后删除主题；私密邀请和成员工作台后置，V1 不实现举报后台或子贴标签。

## 2. 用户角色与使用场景

游客和登录用户都能阅读公开主题、切换子贴、浏览楼层和查看喜欢数；游客写操作先登录，登录用户可点赞、收藏、创建主题并按发言策略发表楼层。普通登录用户还可订阅官方更新和已标记玩家发言；楼主/协作者自动收取更新，可维护子贴正文、普通楼层、标题、分区和状态。只有楼主可修改可见范围并删除主题；成员角色调整及私密邀请属于后续工作台切片。

## 3. 页面、入口和导航关系

首页和搜索主题卡片进入命名路由 `/threads/:threadId`；正文搜索结果使用 `/threads/:threadId?post=:postId` 复用同一详情页，楼层卡片再进入 `/threads/:threadId/posts/:postId/replies`。详情 capability 对管理者开放受保护的 `/threads/:threadId/manage`，保存后返回并刷新详情，删除成功清栈回首页。应用壳创建按钮进入受保护路由 `/compose/thread`，发布确认后替换到新主题详情。游客从互动、发帖、创建或管理入口登录时保留完整目标。子贴切换同时控制正文与楼层数据源；成员页和邀请预览为后续二级路由。

## 4. 用户操作流程

阅读时调用主题详情接口加载元数据、标签、登录态互动与 capability 投影；按 `sortOrder` 排列子贴并加载对应正文/楼层。带 `post` 目标时解析所属子贴并展示上下文。点赞采用服务端计数，收藏按记录 ID 删除。普通登录用户并发读取本人订阅和成员候选；管理 capability 开放正文编辑与楼层管理，普通登录用户可从当前子贴发表楼层。

创建时先恢复按账号隔离的本地 Markdown 快照并加载动态分类；首次保存/发布用稳定 `clientRequestId` 调用 `threadsCreate` 建立未发布主题，再携带主题、默认子贴与正文版本调用 `threadsSaveAggregate`。保存保持 `published=false`，发布必须由响应明确确认 `published=true`。

管理已有主题时并发读取详情与动态分区，以 capability 和成员角色决定页面入口；更新只发送已变化字段并携带详情 `version`。协作者不发送可见范围字段，楼主删除必须再次确认且只有非空服务端响应才视为成功。表单变化后离页要求明确放弃。

## 5. API operationId 与生成类型

- 当前读取：`threadsFindById`、用于目标定位的 `postsFindById`；主题详情响应已经包含子贴集合、子贴正文 ID/版本、主题标签、统计、互动状态和 capability 等可选登录态投影，不额外请求子贴列表。
- 当前互动：`threadsLike`、`threadsUnlike`、`bookmarksCreate`、`bookmarksRemove`、`subscriptionsFindAll`、`subscriptionsCreate`、`subscriptionsRemove`、`threadMembersFindAll`。
- 主要生成类型：`ThreadDetailResponseDto`、`ThreadCapabilitiesResponseDto`、`SubscriptionResponseDto`、`CreateSubscriptionDto`、`ThreadMemberResponseDto`、`ThreadLikeResponseDto`、`BookmarkResponseDto`、`ThreadSubthreadResponseDto`。
- 当前创建写入：`threadsCreate`、`threadsSaveAggregate`，使用 `CreateThreadDto`、`SaveThreadAggregateDto` 和响应中的乐观锁版本。
- 当前已有主题管理：`threadsUpdate`、`threadsRemove`，使用 `UpdateThreadDto`、`ThreadDetailResponseDto`、`ThreadCapabilitiesResponseDto` 与 `MessageResponseDto`；动态分区继续使用 `threadCategoriesList`。
- 子贴正文与楼层写入由 posts 模块调用 `postsCreate`、`postsUpdate`、`postsUpsertBody`、`postsRemove`。
- 后续工作台：`subthreadsCreate`、`subthreadsUpdate`、`subthreadsRemove`、`subthreadsReorder`、邀请和成员管理 operationId。

## 6. 状态模型和数据流

主题详情阶段、详情数据、选中子贴 ID 与当前楼层页分离，控制器丢弃过期请求；目标帖子由独立 FutureProvider 读取。点赞/收藏与订阅分别由 social 的 autoDispose family 管理。创建状态由 editor 模块管理表单、本地快照、远端草稿版本、待确认幂等请求和提交动作。已有主题管理使用独立 autoDispose family，分离加载、保存、删除、普通失败和冲突最新版；身份变化会释放旧状态并切换本地分区。

## 7. 鉴权、权限和隐私规则

公开详情使用 OptionalAuth，游客可读取，登录态附加字段缺失时安全降级。游客点赞或发帖只进入登录，收藏与订阅入口不显示。订阅用 capability 与当前角色识别自动接收更新的楼主/协作者并隐藏控件；同一 capability 只用于显示正文、楼层和主题管理入口，服务端继续复核作者、管理者和发言策略。管理路由本身要求登录，更新和删除还要求邮箱已验证；协作者只能改标题、分区和状态，只有楼主可改可见范围和删除。USER 候选仅取已标记普通玩家并排除本人。不可访问主题不泄露标题、成员、正文或缓存内容。

## 8. 本地存储、缓存及失效规则

详情、所选子贴、楼层、互动、订阅和已有主题管理表单仅做 Riverpod 进程内状态，不提供离线阅读。创建主题把完整 Markdown、表单元数据和稳定创建请求写入 Drift；不保存 Delta，也不静默离线发布。发布确认后删除关联快照；已有主题表单不持久化，未保存变化离页时必须确认放弃。切号、权限变化、404 或 403 会释放对应会话内状态。

## 9. 加载、空数据、错误、重试和冲突状态

首次加载、重新加载、主题不可访问、无子贴和正文安全降级分别展示明确状态；目标定位另有完整空错重试。互动、订阅、楼层删除和主题管理写入串行执行，空响应不伪装成功，失败保留旧状态与请求 ID。创建主题结果不确定时保留原幂等载荷，聚合失败保留本地内容和远端版本。主题元数据收到 `40002`/HTTP 409 时读取最新版但保留本机表单，由用户选择采用云端或基于新 `version` 覆盖；`40107` 可先验证邮箱再继续。邀请失效状态后续接入。

## 10. 跨模块约束

正文按 Markdown v2 规则渲染，未知扩展节点安全降级；楼层由 posts 模块加载。点赞、收藏和订阅由 social 管理。创建写入由 editor 编排，threads 仓储只映射后端 DTO 和乐观锁版本；图片只有完成态公开 URL 能进入正文。

## 11. 测试场景与验收条件

- [x] 首页卡片进入正确的公开详情，系统返回后首页已加载状态保持。
- [x] 默认子贴选择正确；切换子贴同步切换 Markdown 正文和对应楼层页。
- [x] 标题、作者、分类、状态、标签、统计与正文可安全展示，Markdown 未知骰子结果可降级。
- [x] 加载、重试、楼层错误和 404/无权限状态完整且不泄露私密信息。
- [x] 正文搜索目标能自动切换所属子贴并展示目标楼层或楼中楼上下文。
- [x] 点赞/取消点赞使用服务端计数，收藏/取消收藏使用稳定记录 ID，失败保留旧状态。
- [x] 游客互动登录回跳保留帖子目标，登录身份变化重取投影，登录态操作和 360/400/600dp 布局通过。
- [x] 两类订阅采用服务端记录 ID，候选/本人/管理者过滤、失败恢复及多宽度玩家面板通过。
- [x] 创建主题严格执行“未发布草稿 → 聚合保存/发布”，传递动态分类、可见性、标签、正文和全部版本。
- [x] 创建请求超时可用原幂等键确认，发布成功进入新主题详情且只清理关联本地快照。
- [x] capability 投影开放添加/编辑子贴正文和管理者删除楼层；登录用户可从当前子贴发表楼层。
- [x] 管理者从详情进入受保护工作台；协作者字段约束、楼主可见性和删除权限与服务端一致。
- [x] 元数据更新只发送变化字段和当前版本；冲突保留表单并要求采用或覆盖最新版，离页防丢完整。
- [x] 删除区分已发布/草稿风险、二次确认、空响应失败与成功回首页，360/400/600dp 布局通过。
- [ ] 后续单独接入邀请及成员管理。

## 12. 已知限制和后续功能

当前完成“详情 + 子贴正文读写 + 楼层读写/楼中楼 + 搜索目标定位 + 点赞收藏订阅 + 创建发布 + 已有主题元数据管理/删除”。后续工作台继续完成成员和私密邀请。V1 不做举报管理和子贴标签。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

阅读与已有主题管理代码入口：`lib/features/threads/`；创建代码入口：`lib/features/editor/`。参见[编辑器](editor.md)、[草稿](drafts.md)、[楼层与回复](posts.md)、[导航](../architecture/navigation.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

# 动态

状态：`in_progress`

## 1. 模块目标与非目标

实现独立于主题帖的短内容动态：发现/关注/用户/收藏信息流、详情、纯文本发布编辑、最多九图、删除、点赞、收藏、两层评论、评论图片、收藏表情与社区举报。当前不把动态正文解析为 Markdown，不做视频、话题、离线发布或本机草稿。

## 2. 用户角色与使用场景

游客可浏览发现流、用户动态、详情与评论；登录用户额外查看关注流和本人动态收藏，发布、编辑或删除自己的动态，点赞/收藏，并发送纯文本、单图或单个收藏表情评论。服务端返回的 `canEdit`、`canDelete` 和评论 `canDelete` 是最终权限事实。

## 3. 页面、入口和导航关系

动态是五栏应用壳的 `/moments` 主分支，分为“发现”和“关注”。该分支悬浮按钮进入受保护的 `/compose/moment`；详情使用公开 `/moments/:momentId`，编辑使用受保护的 `/moments/:momentId/edit`，动态收藏使用受保护的 `/moments/bookmarks`，公开用户主页通过 `/users/:userId/moments` 读取该用户动态。全站搜索的动态 Tab 以稳定 momentId 进入同一详情；通知 moment 目标也只用服务端 `momentId` 进入详情。

## 4. 用户操作流程

发现流按热度读取，关注流按时间读取；下拉刷新回到首屏，接近底部或按钮加载下一游标。发布时输入 2～40 字标题、最多 1000 字纯文本，逐张上传最多九张已完成图片，可排序并选择其中一张作信息流封面；无图时由服务端返回确定性文字封面主题。编辑提交当前 `version`，删除需二次确认。

详情完整展示纯文本、不裁切图库和累计加油；非本人动态在顶栏进入 wallet 加油和举报。缩略图进入可返回/关闭、双击、捏合、平移、未放大下滑关闭的全屏原图路由。评论主列表默认最新，楼中楼默认最早，可按作者筛选；非本人且未删除的根评论与回复可举报。评论最多 500 字，可额外带一张图片，或只带一个收藏表情；图片和表情互斥，回复始终提交真实目标评论 ID。

## 5. API operationId 与生成类型

- 信息流与详情：`momentsList`、`momentsBookmarks`、`userMomentsList`、`momentsDetail`。
- 搜索读模型由 search 模块调用 `searchSearchMoments`，映射为同一 `MomentCard`。
- 内容写入：`momentsCreate`、`momentsUpdate`、`momentsRemove`。
- 互动：`momentsLike`、`momentsUnlike`、`momentsBookmark`、`momentsUnbookmark`。
- 评论：`momentsCommentAuthors`、`momentsCommentsList`、`momentsReplies`、`momentsCreateComment`、`momentsRemoveComment`。
- 社区举报：reports 模块调用 `reportsCreate`，分别提交 `MOMENT` 或 `MOMENT_COMMENT` 目标。
- 主要生成类型：`MomentCardResponseDto`、`MomentDetailResponseDto`、`MomentMediaResponseDto`、`MomentRootCommentResponseDto`、`MomentCommentResponseDto`、`MomentStickerResponseDto`、`CreateMomentDto`、`UpdateMomentDto` 与 `CreateMomentCommentDto`。

## 6. 状态模型和数据流

`MomentFeedController` 以 main/bookmarks/user target 隔离列表、游标、刷新、分页和单条互动写入；服务端计数与 active 状态覆盖本机卡片。`MomentDetailController` 并行读取详情、主评论和作者候选，独立保存主评论分页及每个根评论的楼中楼分页，并在写入后重新校准服务端投影。`MomentComposerController` 负责创建幂等键、编辑版本和删除确认结果，并拆入独立应用文件但保持 provider 接口；领域校验使用纯领域异常，网络与 feature 错误目录在仓储边界转换。搜索控制器独立保存关键词与搜索 cursor，但通过 `MomentSearchMapper` 输出同一领域卡片。仓储/映射器对 ID、枚举、数量、金额、层级、尺寸及 HTTP(S) URL fail-closed。

## 7. 鉴权、权限和隐私规则

发现、用户列表、详情与评论读操作允许游客；可选认证请求仍通过普通拦截器发送，以便登录用户取得 viewerLiked/viewerBookmarked 和权限投影。关注、收藏列表及所有写操作要求登录，游客从当前安全路径进入登录回跳。动态编辑/删除只消费服务端 capability；举报入口用同一 `canEdit` 排除本人动态，评论则用当前 JWT `sub` 做保守本人隐藏，最终目标可见性和本人关系都由服务端复核。客户端不猜测隐藏动态、评论或被拉黑关系。预签名 URL、图片字节、评论正文和幂等键不落日志或持久化。

## 8. 本地存储、缓存及失效规则

动态、评论、筛选、游标、上传进度和创建幂等键只保存在当前 Riverpod/页面生命周期，不写 Drift、SharedPreferences 或文件。创建/评论请求在结果不明确时保留同一 `clientRequestId`；服务端确认成功后才轮换。图片使用共享安全 HTTP(S) 缓存；发布、编辑、删除和通知返回后失效相关信息流/详情，重启后全部重读服务端事实。

## 9. 加载、空数据、错误、重试和冲突状态

发现、关注、收藏和用户信息流分别覆盖加载、空、首屏失败、刷新失败和分页失败；`40007` 丢弃失效 cursor 并回到首屏。详情区分不存在与网络失败，已加载内容刷新失败时继续保留可读事实。`40002` 编辑冲突保留本机输入并提供“读取最新版”；`40415` 收敛为动态或评论已不存在；不明确创建/评论失败保留原输入与同一幂等键。上传可取消，处理中禁止提交。

## 10. 跨模块约束

media 提供相册选择、预签名上传、确认和完成态轮询；stickers 提供用户私有收藏选择器；notifications 只传稳定 momentId；users 暴露公开用户动态入口；search 复用动态卡片但不持有动态详情或写入状态；wallet 维护动态加油幂等写入，成功后详情重读服务端累计值；reports 管理动态与评论举报的原因、详情、邮箱验证恢复和重复待处理收敛。动态正文和评论始终是纯文本，不进入 Markdown/Quill Codec。视觉只消费 Foundation v1.1.0 Token 与图片角色：信息流/搜索封面可 cover，详情/评论图 contain，所有裁切图必须能进入原图。

## 11. 测试场景与验收条件

- [x] 16 个 operationId 的分页、DTO、幂等、版本与删除确认有仓储测试。
- [x] 未知枚举、不安全 URL、重复 ID、异常计数/层级和图片/表情互斥采用 fail-closed。
- [x] 信息流 `40007` 重置、服务端互动计数、评论幂等重试、楼中楼分页/筛选和删除校准有控制器测试。
- [x] 发现/关注游客边界、纯文字发布、详情/评论和 360/400/600dp 布局有 Widget 测试。
- [x] 动态通知、用户动态、收藏、创建与编辑路由使用稳定 ID，并有导航/回归测试。
- [x] 全站动态搜索的短词、分页、失效 cursor、安全 DTO 映射和详情路由有自动测试。
- [x] 非本人动态可进入加油，累计金额保持十进制整数字符串且成功后重读详情。
- [x] 非本人动态、根评论与回复可举报；本人及已删除内容隐藏入口，游客保留完整登录回跳。
- [ ] 使用公网专用账号完成发现/关注、九图发布编辑、原图、点赞收藏、图片/表情评论和删除真机联调。

## 12. 已知限制和后续功能

相册当前一次选择并上传一张，不做并发九图选择；发布中的动态没有本机或云草稿，离页前尚未增加未保存确认。全屏图库具备规范核心手势，但暂不显示下载/分享入口。动态加油已由 wallet 接入；当前不在信息流卡片直接弹出写入，以详情作为稳定确认上下文。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2（动态正文不消费）；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`；Foundation `v1.1.0`（`4974b09a29d5d1c9632f4b2683c8d36c9e3c69bd`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/moments/`。参见[导航](../architecture/navigation.md)、[API 生成与覆盖审计](../architecture/api-generation.md)、[媒体](media.md)、[收藏表情](stickers.md)、[温油钱包](wallet.md)、[社区举报](reports.md)、[通知](notifications.md)与[用户](users.md)。

# 搜索

状态：`in_progress`

## 1. 模块目标与非目标

提供动态、主题帖、楼层内容、用户四个按需加载 Tab，以及主题详情内的楼层内容搜索入口，并让结果落到稳定的移动端详情目标。V1 不做搜索历史云同步或高级查询语法。

## 2. 用户角色与使用场景

游客和登录用户搜索服务端返回的公开资源；权限与可见性由服务端结果决定。搜索保留已注销楼主的公开历史主题与正文，与首页发现的主动过滤语义区分。

## 3. 页面、入口和导航关系

首页和动态顶栏的搜索按钮进入独立 `/search` 页面；它不占用底部导航分支。页面包含输入框和“动态 / 主题帖 / 楼层内容 / 用户”四个共享纯文字等宽内容页签，360dp 起全部可见且不横向滚动，只响应明确点按，不提供横滑换页。动态、主题帖、楼层内容和用户结果统一占满单列可用宽度，不得随标题、正文或用户名长度收缩；主题帖结果直接复用首页与标签页的整宽主题卡片，并完整呈现服务端投影的状态、作者等级、摘要、封面、标签、玩家/回复/加油计数与默认子贴活跃时间。动态结果进入 `/moments/:momentId`，主题帖结果进入 `/threads/:threadId`，标签进入 `/tags/:tagId`，用户结果进入 `/users/:userId`，楼层内容结果进入 `/threads/:threadId?post=:postId`。主题详情工具栏进入公开 `/threads/:threadId/search`，其楼层结果同样固定为单列全宽，并继续用稳定帖子 ID 回到同一详情定位目标上下文。

## 4. 用户操作流程

输入去首尾空白后提交；当前 Tab 立即请求，其他 Tab 首次切换才请求。新关键词递增请求代次并重置全部结果，晚返回的旧响应不可写回；动态、全站楼层内容和主题内楼层内容少于 2 个 Unicode 字符时给出本地提示且不发请求。动态和楼层内容支持显式加载更多。

## 5. API operationId 与生成类型

- 全站搜索：`searchSearch`、`searchSearchMoments`、`searchSearchThreads`、`searchSearchUsers`、`searchSearchPosts`。
- 主题内搜索：`threadSearchSearchPosts`。
- 主要生成类型：`SearchResultResponseDto`、`MomentSearchResponseDto`、`SearchThreadResponseDto`、`SearchUserResponseDto`、`SearchPostResponseDto`。

## 6. 状态模型和数据流

四个用户可见 Tab 独立保存 idle/loading/ready/failed 状态；动态和楼层内容额外保存不透明 cursor、hasMore、加载更多和局部错误。搜索仓储接口位于 `search/application`，`main.dart` 组合根绑定 API data 适配器，两个搜索控制器不直接导入 data。主题结果直接映射为 threads/core 的共享主题卡模型，只消费 `coverImages` 的唯一安全 HTTP(S) 首图，并保留搜索端点自己的相关度排序。控制器共享 query 与请求代次，只有最新代次可写回状态。`ThreadPostSearchController(threadId)` 隔离每个主题的关键词、分页和请求代次；所有列表按稳定 ID 去重。后端综合搜索读模型继续保留兼容映射，但移动端不把它暴露为结果类型或入口。

搜索结果不把 `categorySlug` 交给卡片。进程内共享的公开分类目录合并并发读取，卡片只接收强类型展示值；首次目录加载失败时显示“分类暂不可用”且不遮断搜索结果，下拉刷新或重试会同时刷新目录。

契约中的 `searchSearchThreads` 已支持可选 cursor/limit 和带 `meta` 的分页响应；当前移动端仓储仍使用 `Future<List<SearchThreadResult>> searchThreads(String query)`，省略 cursor/limit 并消费兼容首批结果，因此单个关键词最多读取服务端默认的 50 条主题结果。完成端口、控制器和页面的 cursor 分页前，本模块保持 `in_progress`。

## 7. 鉴权、权限和隐私规则

不缓存不可见资源；切换账号清空全部结果。公开分类固定匿名读取，动态与主题内搜索使用 OptionalAuth，以便服务端在不泄露私密事实的前提下返回登录态投影或校验私密主题访问。搜索词不持久化，日志不记录完整敏感关键词。

## 8. 本地存储、缓存及失效规则

只保留当前 Provider 生命周期内的 Tab/主题内搜索状态，不持久化搜索词与结果；下拉刷新当前范围，账号状态变化清空全部结果。

## 9. 加载、空数据、错误、重试和冲突状态

未输入时只展示搜索表单和结果 Tab，不再附加功能教学；无结果空态也只保留当前状态。

未输入、关键词过短、无结果、首次加载、加载更多和单 Tab 错误分别展示；首次加载使用结果列表结构 Skeleton，动态与两类正文加载更多失败保留已有结果与重试入口；`40007 INVALID_CURSOR` 丢弃当前分类旧列表并从第一页恢复。主题内结果若返回其他主题 ID、动态封面枚举/数量/URL 不安全、分页缺少 cursor 或同页重复 ID，均 fail-closed 而不导航到错误目标。

## 10. 跨模块约束

用户搜索结果头像缺图或加载失败时显示用户名首个可读字符，不使用无法区分具名用户的统一人物占位。

正文摘要按 Markdown 安全策略转为有限长度纯文本，保留图片与骰子的可理解语义；动态搜索 DTO 映射为 moments 共享卡片模型并复用 Foundation 图片呈现。结果只传稳定 ID，不携带服务端 DTO 跨页面。楼层定位由 threads 模块补取目标上下文，用户资料由 users 模块只读展示；编辑器提及只消费 `usersMentionCandidates` 的主题授权候选，不复用搜索页状态或全站用户搜索。

## 11. 测试场景与验收条件

- [x] 四个共享纯文字页签全部可见、仅点按并按需加载，动态/楼层内容分页不会触发其他页签请求。
- [x] 快速改词时旧响应不能覆盖新结果。
- [x] 动态、主题帖、用户和楼层内容结果使用稳定详情路径；楼层内容可切换子贴并补齐目标上下文。
- [x] 主题搜索只展示首图，超契约多图响应也不显示额外计数；已注销作者的公开历史结果不在客户端过滤。
- [x] 主题结果将 `DEDUCTION` 解析为“演绎”，目录失败与原始 slug 都有防泄露回归。
- [x] 主题详情进入主题内搜索，私密访问由服务端复核，跨主题结果被拒绝。
- [x] 未输入、关键词过短、空、错、重试、加载更多、竞态与无效 cursor 状态有自动测试。
- [x] 全站与主题内页面在 360dp、400dp、600dp 的布局和 48dp 主操作有 Widget 测试。
- [x] 动态、主题帖、楼层内容、用户及主题内楼层结果在 360dp、400dp、600dp 均占满内容列，不随文字长度改变宽度。
- [ ] 主题帖搜索显式传递 limit、消费不透明 cursor，并覆盖加载更多、局部失败和 `40007` 首屏恢复。

## 12. 已知限制和后续功能

不做语音搜索、云历史、结果离线缓存和全文高亮编辑。楼层内容结果通过目标楼层强调，不渲染后端 HTML 高亮片段；综合端点仅作为后端兼容读模型保留，移动端页面不请求或展示综合 Tab。主题帖搜索尚未接入 cursor 分页，当前省略参数的兼容调用最多返回 50 条。

## 13. 最近审查的契约版本和后端提交

契约 `5.14.1-dev.20260829.1`；Markdown v4；后端 `f16d6478764d205b2eea139819db2830f4a0c679`；Foundation `v6.3.0`（`73ed49e`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/search/application/search_repository_ports.dart`、`lib/features/search/data/`、`lib/main.dart`。参见[导航](../architecture/navigation.md)、[楼层与回复](posts.md)、[用户与资料](users.md)、[语义图标](../architecture/icons.md)、[Foundation v6.3.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.3.0/docs/platforms/mobile.md)。

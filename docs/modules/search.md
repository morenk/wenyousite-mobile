# 搜索

状态：`complete`

## 1. 模块目标与非目标

提供综合、动态、主题、用户、正文五个按需加载 Tab，以及主题详情内的正文搜索入口，并让结果落到稳定的移动端详情目标。V1 不做搜索历史云同步或高级查询语法。

## 2. 用户角色与使用场景

游客和登录用户搜索服务端返回的公开资源；权限与可见性由服务端结果决定。

## 3. 页面、入口和导航关系

底部搜索分支 `/search` 包含输入框和综合、动态、主题、用户、正文五个横向可滚动 Tab。综合结果提供三类摘要，动态结果进入 `/moments/:momentId`，主题结果进入 `/threads/:threadId`，用户结果进入 `/users/:userId`，正文结果进入 `/threads/:threadId?post=:postId`。主题详情工具栏进入公开 `/threads/:threadId/search`，结果继续用稳定帖子 ID 回到同一详情定位目标上下文。

## 4. 用户操作流程

输入去首尾空白后提交；当前 Tab 立即请求，其他 Tab 首次切换才请求。新关键词递增请求代次并重置全部结果，晚返回的旧响应不可写回；动态、全站正文和主题内正文少于 2 个 Unicode 字符时给出本地提示且不发请求。综合结果分别展示主题、用户、正文前两项并可转到完整分类；动态和正文支持显式加载更多。

## 5. API operationId 与生成类型

- 全站搜索：`searchSearch`、`searchSearchMoments`、`searchSearchThreads`、`searchSearchUsers`、`searchSearchPosts`。
- 主题内搜索：`threadSearchSearchPosts`。
- 主要生成类型：`SearchResultResponseDto`、`MomentSearchResponseDto`、`SearchThreadResponseDto`、`SearchUserResponseDto`、`SearchPostResponseDto`。

## 6. 状态模型和数据流

五个 Tab 独立保存 idle/loading/ready/failed 状态；动态和正文额外保存不透明 cursor、hasMore、加载更多和局部错误。控制器共享 query 与请求代次，只有最新代次可写回状态。`ThreadPostSearchController(threadId)` 隔离每个主题的关键词、分页和请求代次；所有列表按稳定 ID 去重。

## 7. 鉴权、权限和隐私规则

不缓存不可见资源；切换账号清空全部结果。公开分类固定匿名读取，动态与主题内搜索使用 OptionalAuth，以便服务端在不泄露私密事实的前提下返回登录态投影或校验私密主题访问。搜索词不持久化，日志不记录完整敏感关键词。

## 8. 本地存储、缓存及失效规则

只保留当前 Provider 生命周期内的 Tab/主题内搜索状态，不持久化搜索词与结果；下拉刷新当前范围，账号状态变化清空全部结果。

## 9. 加载、空数据、错误、重试和冲突状态

未输入、关键词过短、无结果、首次加载、加载更多和单 Tab 错误分别展示；动态与两类正文加载更多失败保留已有结果与重试入口；`40007 INVALID_CURSOR` 丢弃当前分类旧列表并从第一页恢复。主题内结果若返回其他主题 ID、动态封面枚举/数量/URL 不安全、分页缺少 cursor 或同页重复 ID，均 fail-closed 而不导航到错误目标。

## 10. 跨模块约束

正文摘要按 Markdown 安全策略转为有限长度纯文本，保留图片与骰子的可理解语义；动态搜索 DTO 映射为 moments 共享卡片模型并复用 Foundation 图片呈现。结果只传稳定 ID，不携带服务端 DTO 跨页面。楼层定位由 threads 模块补取目标上下文，用户资料由 users 模块只读展示；编辑器的全站 @ 用户补充使用独立 `usersSearch`，不复用搜索页状态。

## 11. 测试场景与验收条件

- [x] 五个 Tab 按需加载，动态/正文分页不会触发其他 Tab 请求。
- [x] 快速改词时旧响应不能覆盖新结果。
- [x] 综合、动态、主题、用户和正文结果使用稳定详情路径；正文可切换子贴并补齐目标上下文。
- [x] 主题详情进入主题内搜索，私密访问由服务端复核，跨主题结果被拒绝。
- [x] 未输入、关键词过短、空、错、重试、加载更多、竞态与无效 cursor 状态有自动测试。
- [x] 全站与主题内页面在 360dp、400dp、600dp 的布局和 48dp 主操作有 Widget 测试。

## 12. 已知限制和后续功能

不做语音搜索、云历史、结果离线缓存和全文高亮编辑。正文结果通过目标楼层卡片强调，不渲染后端 HTML 高亮片段；综合端点是后端兼容读模型，仅在综合 Tab 使用，分类 Tab 仍按需调用独立端点。

## 13. 最近审查的契约版本和后端提交

契约 `4.5.0-dev.20260809.1`；Markdown v2；后端 `437e76049a371ff8b6aee1b8a613dc864aa30f11`。

## 14. 相关代码与架构文档

代码入口：`lib/features/search/`。参见[导航](../architecture/navigation.md)、[楼层与回复](posts.md)、[用户与资料](users.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

# 搜索

状态：`in_progress`

## 1. 模块目标与非目标

提供主题、用户、正文三个按需加载 Tab，并让结果落到稳定的移动端详情目标。V1 不做搜索历史云同步或高级查询语法；动态搜索等动态详情模块具备后再接入，不提供无落点的占位 Tab。

## 2. 用户角色与使用场景

游客和登录用户搜索服务端返回的公开资源；权限与可见性由服务端结果决定。

## 3. 页面、入口和导航关系

底部搜索分支 `/search` 包含输入框和主题、用户、正文三个 Tab。主题结果进入 `/threads/:threadId`，用户结果进入 `/users/:userId`，正文结果进入 `/threads/:threadId?post=:postId` 并定位目标楼层或楼中楼上下文。

## 4. 用户操作流程

输入去首尾空白后提交；当前 Tab 立即请求，其他 Tab 首次切换才请求。新关键词递增请求代次并重置全部结果，晚返回的旧响应不可写回；正文少于 2 个 Unicode 字符时给出本地提示且不发请求。

## 5. API operationId 与生成类型

- 已接入 `searchSearchThreads`、`searchSearchUsers`、`searchSearchPosts`。
- `threadSearchSearchPosts` 留给后续主题内搜索入口，不由当前全站搜索页调用。
- 主要生成类型：`SearchThreadResponseDto`、`SearchUserResponseDto`、`SearchPostResponseDto`。

## 6. 状态模型和数据流

三个 Tab 独立保存 idle/loading/ready/failed 状态；正文额外保存不透明 cursor、hasMore、加载更多和局部错误。控制器共享 query 与请求代次，只有最新代次可写回状态，避免慢响应覆盖新搜索。

## 7. 鉴权、权限和隐私规则

不缓存不可见资源；切换账号清空全部结果。搜索词首版不持久化，日志不记录完整敏感关键词。

## 8. 本地存储、缓存及失效规则

只保留当前 Provider 生命周期内的 Tab 状态，不持久化搜索词与结果；下拉刷新当前 Tab，账号状态变化清空全部结果。

## 9. 加载、空数据、错误、重试和冲突状态

未输入、关键词过短、无结果、首次加载、加载更多和单 Tab 错误分别展示；正文加载更多失败保留已有结果与重试入口；`40007 INVALID_CURSOR` 丢弃旧正文列表并从第一页恢复。

## 10. 跨模块约束

正文摘要按 Markdown 安全策略转为有限长度纯文本，保留图片与骰子的可理解语义；结果只传稳定 ID，不携带服务端 DTO 跨页面。楼层定位由 threads 模块补取目标上下文，用户资料由 users 模块只读展示。

## 11. 测试场景与验收条件

- [x] 三个 Tab 按需加载，正文分页不会触发其他 Tab 请求。
- [x] 快速改词时旧响应不能覆盖新结果。
- [x] 主题、用户和正文结果使用稳定详情路径；正文可切换子贴并补齐目标上下文。
- [x] 未输入、关键词过短、空、错、重试、加载更多与无效 cursor 状态有自动测试。
- [x] 360dp、400dp 与 600dp 页面布局和 48dp 主操作有 Widget 测试。

## 12. 已知限制和后续功能

不做语音搜索、云历史和全文高亮编辑。当前没有动态 Tab；主题内搜索入口和独立回复详情后续按模块闭环接入。正文结果通过目标楼层卡片强调，不渲染后端 HTML 高亮片段。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/search/`。参见[导航](../architecture/navigation.md)、[楼层与回复](posts.md)、[用户与资料](users.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。

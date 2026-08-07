# 编辑器

状态：`planned`

## 1. 模块目标与非目标

基于 Flutter Quill 提供移动端富文本输入、选择、工具栏和预览，并用自研 Markdown v2 ↔ Delta Codec 支持提及、骰子、表情、图片、安全链接和本地防丢。V1 不离线自动发布。

## 2. 用户角色与使用场景

已登录且有权限的用户创建或编辑主题、子贴、楼层和回复；游客只安全渲染内容。

## 3. 页面、入口和导航关系

各创建/编辑入口复用同一编辑器壳，根据上下文配置字段和发布动作；预览是编辑器内切换页。

## 4. 用户操作流程

打开时把 Markdown v2 解析为仅内存 Delta；输入期间定时把 Delta 序列化回完整 Markdown 快照；提及、全体玩家、骰子、表情和图片使用版本化 embed；发布成功才清本地操作。

## 5. API operationId 与生成类型

- `usersMentionCandidates`、`postsCreate`、`postsUpdate`、`postsUpsertBody`、`threadsCreate`、`threadsUpdate`、`subthreadsCreate`、`subthreadsUpdate`。
- 生成类型按编辑上下文使用 `CreatePostDto`、`CreateThreadDto`、`CreateSubthreadDto` 等。

## 6. 状态模型和数据流

`EditorState` 包含上下文、内存 Delta、最新完整 Markdown、canonical 正文、可见性、元数据、快照状态和 `clientRequestId`；发布仓储只接收规范化 Markdown 载荷，Delta 不出编辑器边界。

## 7. 鉴权、权限和隐私规则

进入和提交都检查会话；草稿不得包含 Token 或预签名查询参数。原始 HTML 默认不渲染，外链按 scheme 白名单并要求用户确认。

## 8. 本地存储、缓存及失效规则

Drift 保存完整 Markdown 形式的 `LocalEditorSnapshot` 与 `PendingCreateOperation`，不保存 Delta 作为权威草稿。正文变化防抖保存；应用暂停立即保存；用户确认放弃或服务端确认后删除。

## 9. 加载、空数据、错误、重试和冲突状态

空白或不可见正文禁止发布；媒体处理中阻止插入；网络超时保留待确认状态；409 展示本地与服务端版本选择，不覆盖本地。

## 10. 跨模块约束

严格通过 Markdown v2 与 Codec 往返黄金语料；不依赖 `markdown_quill` 做事实转换；骰子结果只由服务端生成；媒体遵循[媒体](media.md)状态；参见[Codec 架构](../architecture/editor-codec.md)。

## 11. 测试场景与验收条件

- [ ] Markdown v2 canonical、visible、幂等以及 Markdown ↔ Delta 往返黄金语料逐条通过。
- [ ] mention、全体玩家、dice、sticker、image 与独占 `<br />` 元数据无损。
- [ ] 退出、崩溃恢复、切后台和弱网不丢编辑内容。
- [ ] 提及、骰子、图片和安全链接正确渲染与提交。
- [ ] 超时复用请求 ID，冲突时保留本地版本。

## 12. 已知限制和后续功能

不做离线自动发送；收藏表情属于 V1 非目标，但 Codec 仍无损保留服务端已有 sticker marker。视觉工具栏精修后置。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.1`；Markdown v2；后端 `4a9c9bbcf67d9419768675455980810e9765cdf1`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/editor/`、`lib/core/markdown/`。参见[Codec 架构](../architecture/editor-codec.md)、[草稿](drafts.md)、[媒体](media.md)。

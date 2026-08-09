# 编辑器

状态：`in_progress`

## 1. 模块目标与非目标

基于 Flutter Quill 提供移动端富文本输入、选择、工具栏和预览，并用自研 Markdown v2 ↔ Delta Codec 支持提及、骰子、表情、图片、安全链接和本地防丢。当前已交付扩展节点 Codec 引擎与完整契约黄金测试，编辑页面、普通 Markdown 富文本属性和发布编排继续实现；V1 不离线自动发布。

## 2. 用户角色与使用场景

已登录且有权限的用户创建或编辑主题、子贴、楼层和回复；游客只安全渲染内容。

## 3. 页面、入口和导航关系

各创建/编辑入口后续复用同一编辑器壳，根据上下文配置字段和发布动作；预览是编辑器内切换页。当前 `/compose/thread` 仍是创建入口占位，尚未接入编辑页面。

## 4. 用户操作流程

打开时先规范化 Markdown v2，再把提及、全体玩家、骰子、表情、图片和独占 `<br />` 解析为仅内存 Delta 协议；普通 Markdown 在首个引擎切片中以源码文本无损保留。序列化会规范骰子 UUID/表达式和表情 alt，未知版本、非法/重复骰子、非法表情及危险图片进入带原始 token 的只读兼容 embed；损坏或未知 Quill embed 直接拒绝保存，禁止静默丢正文。输入期间防抖快照、富文本属性、预览和发布动作后续接入。

## 5. API operationId 与生成类型

- `usersMentionCandidates`、`postsCreate`、`postsUpdate`、`postsUpsertBody`、`threadsCreate`、`threadsUpdate`、`subthreadsCreate`、`subthreadsUpdate`。
- 生成类型按编辑上下文使用 `CreatePostDto`、`CreateThreadDto`、`CreateSubthreadDto` 等。

## 6. 状态模型和数据流

当前 `MarkdownDeltaDocument` 包含仅内存 `Delta` 与兼容问题列表；`isSourceCompatible` 标记正文存在不能安全编辑但可无损保留的节点。五类可编辑 embed 都使用版本化 Map 载荷，空段与源换行使用私有行属性，`extractExtensionNodes` 为契约测试和后续编辑器工具栏提供稳定投影。完整 `EditorState` 后续再增加上下文、最新 Markdown、可见性、元数据、快照状态和 `clientRequestId`；发布仓储只接收规范化 Markdown 载荷，Delta 不出编辑器边界。

## 7. 鉴权、权限和隐私规则

进入和提交都检查会话；草稿不得包含 Token 或预签名查询参数。Codec 只把绝对 HTTP(S) 图片提升为可编辑节点，危险或相对图片地址保留为兼容节点；原始 HTML 默认不渲染，外链按 scheme 白名单并要求用户确认。兼容节点只允许原样序列化，不允许编辑器猜测或重建其内容。

## 8. 本地存储、缓存及失效规则

Codec 本身无持久化；Delta 只存在内存。后续由 Drift 保存完整 Markdown 形式的 `LocalEditorSnapshot` 与 `PendingCreateOperation`，不保存 Delta 作为权威草稿。正文变化防抖保存；应用暂停立即保存；用户确认放弃或服务端确认后删除。

## 9. 加载、空数据、错误、重试和冲突状态

Codec 解码正文时不因未知协议、非法/重复骰子、非法表情或危险图片丢失原 token，而是返回兼容问题列表；序列化遇到损坏载荷、非 insert Delta 或未知 embed 时抛出明确错误并阻止覆盖快照。空白或不可见正文禁止发布；媒体处理中阻止插入；网络超时保留待确认状态；409 展示本地与服务端版本选择，不覆盖本地。

## 10. 跨模块约束

严格通过 Markdown v2 规范化/可见性语料与扩展节点往返语料；不依赖 `markdown_quill` 做事实转换；骰子结果只由服务端生成；媒体遵循[媒体](media.md)状态；参见[Codec 架构](../architecture/editor-codec.md)。

## 11. 测试场景与验收条件

- [x] Markdown v2 canonical、visible、幂等以及 Markdown ↔ Delta 往返黄金语料逐条通过。
- [x] mention、全体玩家、dice、sticker、image 与独占 `<br />` 元数据无损，代码和转义边界不误解析。
- [ ] 退出、崩溃恢复、切后台和弱网不丢编辑内容。
- [ ] 提及、骰子、图片和安全链接正确渲染与提交。
- [ ] 超时复用请求 ID，冲突时保留本地版本。

## 12. 已知限制和后续功能

当前普通 Markdown 仍以源码文本进入 Delta，尚未映射为粗体、标题、列表等 Quill 富文本属性，也没有可操作编辑页、预览、自动快照或发布编排。不做离线自动发送；收藏表情属于 V1 非目标，但 Codec 仍无损保留服务端已有 sticker marker。视觉工具栏精修后置。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

Codec 入口：`lib/core/markdown/markdown_delta_codec.dart`；后续页面入口：`lib/features/editor/`。参见[Codec 架构](../architecture/editor-codec.md)、[草稿](drafts.md)、[媒体](media.md)。

# 表情包

状态：`in_progress`

## 1. 模块目标与非目标

实现服务端 capability 控制的用户私有表情收藏：面向用户的入口统一命名为“表情包”，支持读取收藏与最近使用、从相册/私聊/帖子导入、查询异步处理、完整排序、移除，以及在私信和 Markdown 编辑器中使用。当前不做本机表情包文件夹、离线收藏、第三方表情市场或后台通知。

## 2. 用户角色与使用场景

已登录用户可维护最多 200 个收藏表情，从本人相册上传图片，或收藏有权访问的帖子与私聊图片；随后在私信中作为独占消息发送，或插入主题、楼层、回复与子贴正文。游客和 capability 关闭状态不读取私有收藏。

## 3. 页面、入口和导航关系

“我的”在 capability 开启时提供受保护路径 `/me/stickers`。私信输入器、主题/帖子编辑器打开同一收藏选择面板；帖子正文图片轻触进入共享原图页后，从顶栏“图片操作”按需收藏，不在阅读画布上永久覆盖按钮；已明确展示的私聊图片继续提供快速收藏。陌生消息请求图片在用户点按查看或接受请求前不显示收藏入口。

## 4. 用户操作流程

管理页读取收藏夹版本、容量、收藏、最近使用和处理中任务。从相册选择一张图片后复用 media 预签名上传、确认与处理完成链路，再以稳定 UUID v4 导入；私聊和帖子来源直接提交稳定来源标识。PROCESSING 任务每 2 秒读取状态，完成或失败后重读收藏夹。排序必须提交当前版本和完整收藏 ID 列表；移除需二次确认。

## 5. API operationId 与生成类型

- `stickersGetCollection`、`stickersGetImport`。
- `stickersImportMedia`、`stickersImportDirectMessage`、`stickersImportPostImage`。
- `stickersReorder`、`stickersRemove`。
- 主要生成类型：`StickerCollectionResponseDto`、`UserStickerResponseDto`、`StickerAssetResponseDto`、`StickerImportResponseDto`、三种 Import DTO 与 `ReorderStickersDto`。
- 相册上传复用 `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。

## 6. 状态模型和数据流

`StickerCollectionController` 保存服务端收藏夹、唯一写动作、动作目标、失败幂等来源和后台处理轮询。它显式依赖 capability 的 scoped provider，确保 `WenyouApp` 内层覆盖服务端能力时控制器在同一作用域创建，不触发 Riverpod 依赖断言。仓储把生成 DTO 映射为独立领域模型，在 data 边界应用贴纸专属错误目录，并校验正整数版本/尺寸、连续位置、唯一 ID、安全 HTTP(S) URL、最近列表属于收藏和 pending 仅含 PROCESSING。导入 POST 成功后立即重读收藏；处理中任务完成后再次校准。

## 7. 鉴权、权限和隐私规则

七个端点均要求当前账号；客户端不猜测私聊参与权、帖子访问权、媒体所有权或表情资产权限，全部由服务端复核。收藏夹、最近使用和导入任务不跨账号共享。客户端不记录完整帖子图片 URL、预签名 URL、私聊正文或服务端处理失败详情；只按稳定 failureCode 显示安全文案。

## 8. 本地存储、缓存及失效规则

收藏、版本、最近使用、导入任务和幂等失败来源只保存在进程内 Riverpod 状态，不写 Drift、SharedPreferences 或文件。退出、切号或进程结束后释放；进入页面、打开选择器、发送表情、导入完成和下拉刷新都会重新采用服务端事实。图片只使用共享安全 HTTP(S) 缓存。

## 9. 加载、空数据、错误、重试和冲突状态

页面与选择器分别覆盖加载、空、首屏失败、局部失败、处理中、满额和 capability 关闭。导入不明确失败保留同一 `clientRequestId`，管理页可“使用原请求重试”；`40006`、`40413`、`40910` 显示固定安全提示。排序收到 `40911` 后丢弃本机顺序并重读，不覆盖其他设备的新版本。后台轮询短暂失败保留当前可用收藏。

## 10. 跨模块约束

media 负责相册图片安全上传；direct_messages 负责 `stickerAssetId` 独占载荷和消息展示；editor 只插入 Codec 已支持的 sticker embed；posts/threads 传入真实 postId 与 Markdown 图片 URL。视觉只使用 Foundation v1.3.1 Token、面板、状态和最小触控目标，不维护平行审美规范。

## 11. 测试场景与验收条件

- [x] 7 个 operationId 的生成 DTO、空响应和领域映射有仓储测试。
- [x] 异步状态轮询、完成刷新、稳定幂等重试和完整排序约束有控制器测试。
- [x] 不安全 URL、异常位置、最近列表越界与未知状态采用 fail-closed。
- [x] capability 关闭、应用内 scoped capability 覆盖、相册导入和 360/400/600dp 管理页布局有 Widget 测试。
- [x] 私信选择独占表情、图片快速收藏和陌生请求图片隐藏入口有集成 Widget 测试。
- [ ] 使用公网专用账号完成相册导入、帖子/私聊收藏、排序、删除、私信发送与编辑器发布真机联调。

## 12. 已知限制和后续功能

移动端相册入口当前一次选择一张，未实现 Web 的最多十张并发批量导入；动画只在发送或正文实际图片 URL 中播放，收藏网格使用缩略图。处理任务依靠前台轮询，不做后台通知；进程终止后重新进入即从服务端 pending 列表恢复观察。

## 13. 最近审查的契约版本和后端提交

契约 `4.8.0-dev.20260813.2`；Markdown v2；后端 `67c3c7bdee228b8d7c0c94ef39a08dc9d223fdbf`；Foundation `v1.3.1`（`7cf71327aaeee4f5e6baae069335c8a606f6a911`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/stickers/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[媒体](media.md)、[编辑器](editor.md)与[站内私聊](direct-messages.md)。

# 表情包

状态：`in_progress`

## 1. 模块目标与非目标

实现服务端 capability 控制的用户私有表情收藏：面向用户的入口统一命名为“表情包”，支持读取收藏与最近使用、从相册、私聊、帖子、动态正文和动态评论图片导入、查询异步处理、完整排序、移除，以及在私信和 Markdown 编辑器中使用。当前不做本机表情包文件夹、离线收藏、第三方表情市场或后台通知。

## 2. 用户角色与使用场景

已登录用户可维护最多 200 个收藏表情，从本人相册上传图片，或收藏有权访问的帖子、私聊、动态正文与动态评论图片；随后在私信中作为独占消息发送，或插入主题、楼层、回复与子贴正文。游客和 capability 关闭状态不读取私有收藏。

## 3. 页面、入口和导航关系

“我的”在 capability 开启时于资料卡底部显示“表情包”透明图标操作，进入受保护路径 `/me/stickers`；入口不再占用顶栏。私信输入器、主题/帖子编辑器打开同一收藏选择面板；面板内“收藏 / 最近”复用共享等宽内容页签，只响应点按，不再维护独立分段控件。帖子、动态正文、动态评论和私聊图片轻触进入共享原图页后，从顶栏“图片操作”按需收藏，不在阅读画布上永久覆盖按钮；已明确展示的私聊图片继续提供快速收藏。陌生消息请求图片在用户点按查看或接受请求前不显示收藏入口。

## 4. 用户操作流程

管理页读取收藏夹版本、容量、收藏、最近使用和处理中任务。从相册选择一张图片后进入单图准备，静态图确认取景、GIF 原样确认后由 media 共享任务以 `STICKER_SOURCE` 用途完成预签名上传、确认与完成态轮询；只有安全完成的 `mediaId` 才以稳定 UUID v4 导入。上传可取消，失败可在当前页面复用同一输入重试；私聊、帖子、动态正文和动态评论来源直接提交稳定来源标识。PROCESSING 任务每 2 秒读取状态，完成或失败后重读收藏夹。排序必须提交当前版本和完整收藏 ID 列表；移除需二次确认。

在 Markdown 编辑器中选择收藏表情时，工具栏先固定正文选区，选择完成后把资产 ID 与安全 URL 写入无富文本属性的原子节点；普通正文与表情允许同段混排并作为完整 Markdown 保存。私信仍使用 `stickerAssetId` 独占消息，不与正文混合。

## 5. API operationId 与生成类型

- `stickersGetCollection`、`stickersGetImport`。
- `stickersImportMedia`、`stickersImportDirectMessage`、`stickersImportPostImage`、`stickersImportMomentImage`、`stickersImportMomentCommentImage`。
- `stickersReorder`、`stickersRemove`。
- 主要生成类型：`StickerCollectionResponseDto`、`UserStickerResponseDto`、`StickerAssetResponseDto`、`StickerImportResponseDto`、五种 Import DTO 与 `ReorderStickersDto`。
- 相册上传复用 `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。

## 6. 状态模型和数据流

`StickerCollectionController` 保存服务端收藏夹、唯一写动作、动作目标、失败幂等来源和后台处理轮询。收藏表情端口位于 `stickers/application`，API 适配器由 `main.dart` 组合根绑定，控制器不导入具体 data 仓储。相册选择、上传阶段、进度、取消与同文件重试属于每个管理页实例独立的 `media/application` autoDispose 任务，不进入收藏夹状态；上传成功后才把 `mediaId` 交给 `StickerCollectionController`。它显式依赖 capability 和仓储的 scoped provider，确保 `WenyouApp` 内层覆盖服务端能力时控制器在同一作用域创建，不触发 Riverpod 依赖断言。data 适配器把生成 DTO 映射为独立领域模型，应用贴纸专属错误目录，并校验正整数版本/尺寸、连续位置、唯一 ID、安全 HTTP(S) URL、最近列表属于收藏和 pending 仅含 PROCESSING。导入 POST 成功后立即重读收藏；处理中任务完成后再次校准。

## 7. 鉴权、权限和隐私规则

九个端点均要求当前账号；客户端不猜测私聊参与权、帖子/动态访问权、评论作者拉黑关系、媒体所有权或表情资产权限，全部由服务端复核。收藏夹、最近使用和导入任务不跨账号共享。客户端不记录完整帖子图片 URL、预签名 URL、私聊正文或服务端处理失败详情；只按稳定 failureCode 显示安全文案。

## 8. 本地存储、缓存及失效规则

收藏、版本、最近使用、导入任务和幂等失败来源只保存在进程内 Riverpod 状态，不写 Drift、SharedPreferences 或文件。相册原始字节只在 media 上传任务内短暂存在，上传失败时仅供当前页面重试，成功、取消或页面释放后清除。退出、切号或进程结束后释放；进入页面、打开选择器、发送表情、导入完成和下拉刷新都会重新采用服务端事实。图片只使用共享安全 HTTP(S) 缓存。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

页面与选择器分别覆盖加载、空、首屏失败、局部失败、处理中、满额和 capability 关闭；管理页首屏使用列表结构 Skeleton，选择器保持适合弹层尺寸的紧凑加载反馈。上传失败在 media 任务中保留同一文件并明确“重试上传”；上传成功后的导入不明确失败则由 stickers 保留同一 `clientRequestId` 和来源，管理页可“使用原请求重试”。两类重试不重复前面已完成的阶段；`40006`、`40413`、`40415`、`40910` 显示固定安全提示。排序收到 `40911` 后丢弃本机顺序并重读，不覆盖其他设备的新版本。后台轮询短暂失败保留当前可用收藏。

## 10. 跨模块约束

本模块页面排版统一遵循[移动端视觉基线](../architecture/visual-baseline.md)中的 Foundation v6.8.0 语义文字角色，不自定义字号或直接依赖 Material 字体槽位。

media application 负责相册选择、格式校验、`STICKER_SOURCE` 用途和安全上传，stickers presentation 只消费完成的 `mediaId`，不导入 media data 或 Dio；direct_messages 负责 `stickerAssetId` 独占载荷和消息展示；editor 只插入 Codec 已支持的 sticker embed；posts/threads 传入真实 postId 与 Markdown 图片 URL；moments 分别传入动态/评论 ID 与图片 mediaId。视觉只使用 Foundation v6.8.0 Token、语义图标、面板、状态和最小触控目标，不维护平行审美规范。

## 11. 测试场景与验收条件

- [x] 9 个 operationId 的生成 DTO、空响应和领域映射有仓储测试；五种导入来源均固定 DTO 与幂等策略。
- [x] 异步状态轮询、完成刷新、稳定幂等重试和完整排序约束有控制器测试。
- [x] 不安全 URL、异常位置、最近列表越界与未知状态采用 fail-closed。
- [x] capability 关闭、应用内 scoped capability 覆盖、相册选图裁剪后导入、上传失败同裁剪文件重试、上传中取消和 360/400/600dp 管理页布局有 Widget 测试。
- [x] 相册导入上传固定传入 `STICKER_SOURCE`，静态图归一化为 WebP，GIF 原样校验且不进入裁剪。
- [x] 私信选择独占表情、图片快速收藏和陌生请求图片隐藏入口有集成 Widget 测试。
- [x] 私聊、动态正文与动态评论图片的共享原图页收藏入口均有集成 Widget 测试，并只对登录且 capability 开启状态出现。
- [x] 表情选择器“收藏 / 最近”使用共享点按页签，管理页首屏使用结构 Skeleton。
- [x] 回复、主题创建和主题正文管理的真实选择器链路覆盖正文与原子表情共同保存；待应用行内样式不会污染 embed，取消选择仍保留原选区和正文。
- [ ] 使用公网专用账号完成相册导入、帖子/私聊收藏、排序、删除、私信发送与编辑器发布真机联调。

## 12. 已知限制和后续功能

移动端相册入口当前一次选择一张，未实现 Web 的最多十张并发批量导入；动画只在发送或正文实际图片 URL 中播放，收藏网格使用缩略图。处理任务依靠前台轮询，不做后台通知；进程终止后重新进入即从服务端 pending 列表恢复观察。

## 13. 最近审查的契约版本和后端提交

契约 `5.16.0-dev.20260904.1`；Markdown v5；后端 `fb02efa2ea4f4fd8f9b793f6d4bbd9f9f74a2d7e`；Foundation `v6.8.0`（`196deaf`）。

## 14. 相关代码与架构文档

端口、控制器与状态：`lib/features/stickers/application/`；API 适配器：`lib/features/stickers/data/`；页面：`lib/features/stickers/presentation/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[媒体](media.md)、[编辑器](editor.md)与[站内私聊](direct-messages.md)。

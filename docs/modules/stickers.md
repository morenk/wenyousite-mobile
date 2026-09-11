# 表情包

状态：`in_progress`

## 1. 模块目标与非目标

实现服务端 capability 控制的用户私有表情收藏：面向用户的入口统一命名为“表情包”，支持读取收藏与最近使用、从相册、私聊、帖子、动态正文和动态评论图片导入、查询异步处理、完整排序、移除，以及在私信和 Markdown 编辑器中使用。当前不做本机表情包文件夹、离线收藏、第三方表情市场或后台通知。

## 2. 用户角色与使用场景

已登录用户可维护最多 200 个收藏表情，从本人相册上传图片，或收藏有权访问的帖子、私聊、动态正文与动态评论图片；随后在私信中作为独占消息发送，或插入主题、楼层、回复与子贴正文。游客和 capability 关闭状态不读取私有收藏。

## 3. 页面、入口和导航关系

“我的”在 capability 开启时于资料卡底部显示“表情包”透明图标操作，进入受保护路径 `/me/stickers`；入口不再占用顶栏。私信输入器、主题/帖子编辑器打开同一收藏选择面板；面板内“收藏 / 最近”复用共享等宽内容页签，只响应点按，不再维护独立分段控件。帖子、动态正文、动态评论和私聊图片轻触进入共享原图页后，从顶栏“图片操作”按需收藏，不在阅读画布上永久覆盖按钮；已明确展示的私聊图片继续提供快速收藏。陌生消息请求图片在用户点按查看或接受请求前不显示收藏入口。

## 4. 用户操作流程

管理页读取收藏夹版本、容量、收藏、最近使用和处理中任务。从相册选择一张图片后进入单图准备，静态图确认取景、GIF 原样确认后由 media 共享任务以 `STICKER_SOURCE` 用途完成预签名上传、确认与完成态轮询；只有安全完成的 `mediaId` 才以稳定 UUID v4 导入。上传可取消，失败可在当前页面复用同一输入重试；私聊、帖子、动态正文和动态评论来源直接提交稳定来源标识。PROCESSING 任务每 2 秒读取状态，完成或失败后重读收藏夹。管理页使用紧凑等宽图片网格，360/400dp 为五列，添加入口固定在首格；图片 contain 保持完整比例，不显示静态／动态分类或像素尺寸。长按表情抬起后随手指移动，跨格／跨行时其他表情滑动让位，靠近视口上下边缘自动滚动，松手后落位。原位放下、手势取消、拖到视口外放下、切入后台或布局尺寸改变均不提交。排序提交当前版本和完整收藏 ID 列表；正常界面隐藏删除按钮，顶栏“管理”展开各格移除入口，移除仍需二次确认。读屏提供向前／向后移动及移除操作。

在 Markdown 编辑器中选择收藏表情时，工具栏先固定正文选区，选择完成后把资产 ID 与安全 URL 写入无富文本属性的原子节点；普通正文与表情允许同段混排并作为完整 Markdown 保存。私信仍使用 `stickerAssetId` 独占消息，不与正文混合。

## 5. API operationId 与生成类型

- `stickersGetCollection`、`stickersGetImport`。
- `stickersImportMedia`、`stickersImportDirectMessage`、`stickersImportPostImage`、`stickersImportMomentImage`、`stickersImportMomentCommentImage`。
- `stickersReorder`、`stickersRemove`。
- 主要生成类型：`StickerCollectionResponseDto`、`UserStickerResponseDto`、`StickerAssetResponseDto`、`StickerImportResponseDto`、五种 Import DTO 与 `ReorderStickersDto`。
- 相册上传复用 `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。

## 6. 状态模型和数据流

`StickerCollectionController` 保存收藏夹、唯一在途写动作、动作目标、失败幂等来源和后台处理轮询。拖动落位立即更新共享收藏顺序并校准 position，后台串行保存；请求中允许继续拖动，只保留最新待保存顺序，下一请求使用上一次确认的版本。成功仅合并已确认版本，不回放旧顺序、不展示排序成功提示；管理页添加／移除成功也直接通过网格变化反馈，不插入成功横幅。排序期间阻止刷新和其他写操作，已在途的读取通过 epoch 失效，轮询不能覆盖乐观顺序；账号作用域销毁后丢弃迟到回调。收藏表情端口位于 `stickers/application`，API 适配器由 `main.dart` 组合根绑定，控制器不导入具体 data 仓储。相册选择、上传阶段、进度、取消与同文件重试属于每个管理页实例独立的 `media/application` autoDispose 任务，不进入收藏夹状态；上传成功后才把 `mediaId` 交给 `StickerCollectionController`。它显式依赖 capability 和仓储的 scoped provider，确保 `WenyouApp` 内层覆盖服务端能力时控制器在同一作用域创建，不触发 Riverpod 依赖断言。data 适配器把生成 DTO 映射为独立领域模型，应用贴纸专属错误目录，并校验正整数版本/尺寸、连续位置、唯一 ID、安全 HTTP(S) URL、最近列表属于收藏和 pending 仅含 PROCESSING。导入 POST 成功后立即重读收藏；处理中任务完成后再次校准。

## 7. 鉴权、权限和隐私规则

九个端点均要求当前账号；客户端不猜测私聊参与权、帖子/动态访问权、评论作者拉黑关系、媒体所有权或表情资产权限，全部由服务端复核。收藏夹、最近使用和导入任务不跨账号共享。客户端不记录完整帖子图片 URL、预签名 URL、私聊正文或服务端处理失败详情；只按稳定 failureCode 显示安全文案。

## 8. 本地存储、缓存及失效规则

收藏控制器直接依赖 `SessionScope`，不只监听是否登录；账号直接切换也重建私有收藏和导入任务，同账号 Token 刷新不重建。

收藏、版本、最近使用、导入任务和幂等失败来源只保存在进程内 Riverpod 状态，不写 Drift、SharedPreferences 或文件。相册原始字节只在 media 上传任务内短暂存在，上传失败时仅供当前页面重试，成功、取消或页面释放后清除。退出、切号或进程结束后释放；进入页面、打开选择器、发送表情、导入完成和下拉刷新都会重新采用服务端事实。图片只使用共享安全 HTTP(S) 缓存。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

页面与选择器分别覆盖加载、空、首屏失败、局部失败、处理中、满额和 capability 关闭；管理页首屏使用静态网格 Skeleton，选择器保持适合弹层尺寸的紧凑加载反馈。上传失败在 media 任务中保留同一文件并明确“重试上传”；上传成功后的导入不明确失败则由 stickers 保留同一 `clientRequestId` 和来源，管理页可“使用原请求重试”。两类重试不重复前面已完成的阶段；`40006`、`40413`、`40415`、`40910` 显示固定安全提示。排序失败立即回退到最近一次已确认顺序并清空待保存意图，仅显示失败提示；收到 `40911` 后在写锁内校准最新收藏夹，保留冲突提示，不覆盖其他设备的新版本。校准失败保留回退结果并允许显式刷新。后台轮询短暂失败保留当前可用收藏。

## 10. 跨模块约束

本模块页面排版统一遵循[移动端视觉基线](../architecture/visual-baseline.md)中的 Foundation v6.9.0 语义文字角色，不自定义字号或直接依赖 Material 字体槽位。

media application 负责相册选择、格式校验、`STICKER_SOURCE` 用途和安全上传，stickers presentation 只消费完成的 `mediaId`，不导入 media data 或 Dio；direct_messages 负责 `stickerAssetId` 独占载荷和消息展示；editor 只插入 Codec 已支持的 sticker embed；posts/threads 传入真实 postId 与 Markdown 图片 URL；moments 分别传入动态/评论 ID 与图片 mediaId。视觉只使用 Foundation v6.9.0 Token、语义图标、面板、状态和最小触控目标，不维护平行审美规范。

## 11. 测试场景与验收条件

- [x] 9 个 operationId 的生成 DTO、空响应和领域映射有仓储测试；五种导入来源均固定 DTO 与幂等策略。
- [x] 异步状态轮询、完成刷新、稳定幂等重试和完整排序约束有控制器测试。
- [x] 不安全 URL、异常位置、最近列表越界与未知状态采用 fail-closed。
- [x] capability 关闭、应用内 scoped capability 覆盖、相册选图裁剪后导入、上传失败同裁剪文件重试、上传中取消和 360/400/600dp 管理页布局有 Widget 测试。
- [x] 相册导入上传固定传入 `STICKER_SOURCE`，静态图归一化为 WebP，GIF 原样校验且不进入裁剪。
- [x] 私信选择独占表情、图片快速收藏和陌生请求图片隐藏入口有集成 Widget 测试。
- [x] 私聊、动态正文与动态评论图片的共享原图页收藏入口均有集成 Widget 测试，并只对登录且 capability 开启状态出现。
- [x] 表情选择器“收藏 / 最近”使用共享点按页签，管理页首屏使用网格 Skeleton。
- [x] 回复、主题创建和主题正文管理的真实选择器链路覆盖正文与原子表情共同保存；待应用行内样式不会污染 embed，取消选择仍保留原选区和正文。
- [x] 紧凑网格、跨行拖动及中间动画帧、连续排序串行保存、错误回退、刷新竞态、40911 校准、取消、边缘滚动、200 个收藏的图片挂载范围、销毁回调与减少动态效果有自动测试；360/400/600dp、黑夜大字管理态有 Golden。
- [x] 2026-09-11，负责人安装候选后确认表情网格与共享排序动画体验通过，并授权合并；未提供逐项手测日志或 Profile 帧时间采样，见[网格验收](../architecture/sticker-grid-acceptance.md)。
- [ ] 使用公网专用账号完成相册导入、帖子/私聊收藏、排序、删除、私信发送与编辑器发布真机联调。

## 12. 已知限制和后续功能

拖动反馈使用共享 `WenyouReorderFeedback` 和 Foundation 180ms 标准曲线，减少动态效果时取消抬起缩放和位移插值；不引入桌面图标持续摇晃。图片 Widget 在手势帧复用，抬起绘制沿用稳定 child 与独立 RepaintBoundary；离屏图片按视口缓冲范围释放，缩略图按格子尺寸解码。滚动 Ticker 仅在可滚动边缘启动，停在中间或到达尽头后不空转。自动 Golden 仅使用加载占位，不能替代真实图片和 Profile 真机流畅度验收。

移动端相册入口当前一次选择一张，未实现 Web 的最多十张并发批量导入；动画只在发送或正文实际图片 URL 中播放，收藏网格使用缩略图。处理任务依靠前台轮询，不做后台通知；进程终止后重新进入即从服务端 pending 列表恢复观察。

## 13. 最近审查的契约版本和后端提交

2026-09-11 列表契约候选同步：Backend `062412601b3a8dbf4f64494115a2445d312dd53d`，OpenAPI `5.20.1-dev.20260911.1`；新增 editor-list v1 revision 2，夹具最初固定于 `aa1bcbd4d087f03a17817e9eca8bcd1f92bb53da`。同时同步收藏夹计数按当前用户可见性统计的契约说明；字段形状、块边界 v1 revision 2 与既有消费代码保持；列表消费者及真机验收仍待完成，见[列表统一排查](../architecture/editor-list-unification-investigation.md)。

2026-09-11 合并来源同步：Backend `8bf370f6ef5357535683aa6d3f8c03bd2d08d108`，包含发布权限修复；通过既有脚本重新导出后仅来源元数据变化，OpenAPI、块边界 v1 revision 2 及其他共享契约字节不变。模块行为与候选验收状态保持，前次部署回滚、公网核验及安装包溯源见[块边界验收](../architecture/markdown-block-boundaries-acceptance.md)。

2026-09-11 契约来源登记：Backend `a91cbb8b605223c596af299be22c5547f69e25b9`，块边界 v1 revision 2。HTTP OpenAPI 未变化，本模块既有接口行为与验收状态保持；富文本消费者候选见[块边界验收](../architecture/markdown-block-boundaries-acceptance.md)。

2026-09-11 契约增量审查：同步 `5.20.0-dev.20260909.1`，后端及公网 `0ee2c0de1d9c570e495e778be6661b074b7a4bef`。新增可空 `coverMedia` 与 `previewVariants` 的生成模型；现有页面读取行为不变，封面播放消费留在独立切片。表情接口、正文语料及 Foundation v6.9.0 不变。下列历史审查记录保留其当时范围。

契约 `5.18.0-dev.20260905.1`；Markdown v5；后端 `3338028459561565c788d5236fb64db84a2ae538`；Foundation `v6.9.0`（`5888132`）。

本轮来源为已合并的 newline v1 revision 2 契约；HTTP 与其他契约不变，公网后端仍运行旧 revision。公网仍为 `e8d0fd6cb193ab5e9a1c2c51c03382ef300adc0c`，移动端对齐适配与跨端验收另行推进。

## 14. 相关代码与架构文档

端口、控制器与状态：`lib/features/stickers/application/`；API 适配器：`lib/features/stickers/data/`；页面：`lib/features/stickers/presentation/`。参见[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[媒体](media.md)、[编辑器](editor.md)与[站内私聊](direct-messages.md)。

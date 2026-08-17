# 媒体

状态：`in_progress`

## 1. 模块目标与非目标

提供正文、动态/评论、私聊、收藏表情、头像与主页背景的图片选择、交互式取景、预签名上传、确认、完成态轮询和安全查看。当前已完成主题与帖子编辑器图片、动态最多九图、评论单图、私聊单图、收藏表情导入、本人头像与双画幅主页背景设置/移除闭环；V1 不做视频、后台上传或离线上传队列。

## 2. 用户角色与使用场景

已登录用户从主题或帖子编辑器明确选择相册图片并插入正文，在表情包管理页上传图片并导入收藏，或在“我的”选择、取景、设置和移除头像与主页背景；所有可见用户可按安全 URL 加载正文图并进入全屏原图查看，头像按圆形 cover 角色展示。

## 3. 页面、入口和导航关系

`/compose/thread`，以及从 `/threads/:threadId` 主题详情或 `/threads/:threadId/posts/:postId/replies` 独立讨论打开的帖子编辑器，均由图片按钮打开系统相册；选择后直接上传，不展示描述或替代文字表单。上传完成后在当前光标附近插入块级图片节点，协议 alt 固定为“图片”。`/compose/moment` 可逐张加入最多九图并排序/选择封面，动态评论可加入一张图片且会清除已选表情；正文、动态与评论图片轻触进入全屏页。“我的” `/me/edit` 提供头像 1:1 取景，以及同一原图的电脑端 3:1、移动端 2:1 独立取景；已有头像和背景额外提供二次确认移除。Markdown 摘要和私信列表中的图片消息统一显示为 `[图片]`。

## 4. 用户操作流程

选择文件后先读取大小，拒绝空文件和超过 10MB 的内容；再结合声明类型、扩展名和头字节识别 JPG、PNG、GIF、WebP 或 AVIF。客户端调用 `mediaGetUploadUrl`，用独立且不携带 Bearer Token 的 Dio 对预签名 URL 执行 PUT，然后调用 `mediaConfirmUpload`。确认未完成时先等待 500ms，再最多轮询 `mediaGetMedia` 30 次；只有 `COMPLETED` 且公开 URL 为 HTTP(S) 时返回编辑器。

头像与背景原图收窄为 JPG、PNG、WebP，并以头字节拒绝伪装格式。原图只在当前取景会话内保留；头像生成 512 × 512 PNG，背景按两个独立归一化取景框生成 1920 × 640 和 1600 × 800 PNG，再进入共享媒体管线。头像完成后将 `mediaId` 交给 `usersSetAvatar`；双背景均完成后一次调用 `usersSetProfileCover`。设置成功只采用用户响应中明确给出的安全 HTTP(S) URL，不猜测派生路径；移除也只在服务端最终结果确认后更新页面。

## 5. API operationId 与生成类型

- 媒体管线：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 头像：`usersSetAvatar`、`usersRemoveAvatar`。
- 主页背景：`usersSetProfileCover`、`usersRemoveProfileCover`。
- 主要生成类型：`CreateUploadUrlDto`、`ConfirmUploadDto`、`MediaResponseDto`、`SetAvatarDto`、`SetProfileCoverDto`、`PrivateUserResponseDto`。

## 6. 状态模型和数据流

`MediaUploadInput` 只在当前进程持有文件名、声明类型和字节；`CropImageSource` 额外持有经方向校正的低分辨率预览及原图尺寸，`NormalizedCropRect` 只表达 0..1 范围内的取景区域。`MediaUploadProgress` 分为 preparing、uploading、confirming、processing，并可携带已发送/总字节；`UploadedEditorImage` 只暴露媒体 ID、安全公开 URL 和可选尺寸。主题、帖子、动态发布、动态评论、私聊输入器、表情包管理页、头像与背景流程按页面或业务实例创建 autoDispose 上传任务；任务在 `media/application` 统一管理状态、进度、失败信息和当前上传操作。相册选择、裁剪处理和上传由 application 声明端口，在组合根绑定到系统相册、背景输入校验、isolate 图片编码与 Dio adapter。`AvatarController` 和 `ProfileCoverController` 保留已确认的裁剪结果直到上传成功、取消或页面释放；设置端点失败继续保留已完成上传的 `mediaId`，重试不重新取景或重复已完成上传。

## 7. 鉴权、权限和隐私规则

申请与确认使用主 API 会话；对象存储 PUT 使用独立无鉴权客户端，避免向第三方地址发送 Token。预签名 URL 不写日志、数据库或 UI 错误详情；文件仅在用户明确选择后读取。公开图和上传地址都要求 HTTP(S)，头像额外排除 GIF/AVIF 与格式伪装；编码层仍防御性移除 Markdown alt 中协议不允许的换行和 `]`，当前编辑器 UI 固定使用“图片”且不接受用户描述输入。用户资料端点失败时保留已完成的媒体 ID，显式重试不重复上传。

## 8. 本地存储、缓存及失效规则

预签名 URL、文件字节和处理中状态不持久化。上传完成后只有公开 URL 随完整 Markdown 进入本地快照；头像媒体 ID 只在当前 autoDispose 状态中保留到设置成功或页面释放。头像设置/移除成功立即采用服务端结果并淘汰旧 URL 缓存；本人资料不持久化，应用重启后重新调用 `usersGetMe`。当前用户 DTO 未显式提供派生 URL，客户端安全降级到服务端头像原地址而不猜测路径。

## 9. 加载、空数据、错误、重试和冲突状态

用户取消选择或关闭取景窗口不提示错误；上传期间显示阶段和可用进度并允许取消。空文件、超限、未知类型与无法解码的图片在申请地址前拒绝；对象存储失败不会调用确认；确认缺失、处理失败和轮询超时都不写入业务内容。失败保留当前 Markdown 或已确认的裁剪结果，用户可直接重试；取消会清除重试输入。处理中禁止同时保存/发布，避免提交不存在的图片。头像上传失败复用 1:1 输出，设置失败保留媒体 ID 和请求 ID，并只重试 `usersSetAvatar`；背景按缺失画幅继续上传并在双 `mediaId` 完成后重试原子设置；移除失败保留当前图片。

## 10. 跨模块约束

只有 `COMPLETED` 资源能成为 `wenyou_image` 节点、动态/评论/私聊媒体 ID、收藏表情导入源、头像或背景候选；`media/application` 负责上传任务以及头像/背景的取景与裁剪契约，`media/presentation` 提供通用拖动缩放窗口，`media/data` 只负责系统选图和 isolate 解码编码。editor、moments、direct_messages 与 stickers 继续只消费完成媒体；users 只接收头像或双背景候选并负责资料端点和本人资料事实。正文、动态详情和评论图片遵循 Foundation 的 contain、不裁切、状态占位和全屏交互契约；动态信息流封面、背景和头像是允许 cover 裁切的角色，但动态封面必须可进入详情原图。

## 11. 测试场景与验收条件

- [x] 预签名 PUT、确认、轮询及完成后插入闭环通过。
- [x] 空文件、超限、未知类型在网络请求前拒绝。
- [x] 对象存储失败不确认，错误文本不暴露预签名查询参数。
- [x] 共享上传控制器覆盖进度、取消、失败、重试、迟到结果丢弃与页面释放；主题和帖子页面覆盖选择后直接上传、完成结果插入及固定图片节点，动态发布和评论覆盖失败重试、系统返回取消与完成媒体消费，私聊覆盖同文件重试、完成后发送和上传中取消，收藏表情覆盖同文件重试、取消不导入和完成后才进入导入端点。
- [x] 正文图片 contain 显示并支持全屏、捏合、双击、平移和未放大下滑关闭。
- [x] 头像格式策略、1:1 拖动缩放取景、共享上传进度/取消、设置/删除、显式 URL 降级、旧缓存失效和重启后服务端事实恢复完成。
- [x] 主页背景从同一原图独立调整 3:1 与 2:1 取景，严格尺寸输出、双上传断点重试、原子设置和同步移除完成。

## 12. 已知限制和后续功能

服务端用户 DTO 未提供 thumbnail/medium 字段，因此移动端只使用明确原地址。原图、预览、取景框与失败上传输入只在当前页面/autoDispose 生命周期内短暂保留，不写入本地快照或业务状态，也不提供后台队列；页面释放、主动取消或进程终止后需重新选择图片。相册权限由 `image_picker` 和 Android 系统能力管理。

## 13. 最近审查的契约版本和后端提交

契约 `5.0.0-dev.20260816.1`；Markdown v3；后端 `2fd8c979ef10c0e1dec3a3ca23b59d3b8f99c0ca`；Foundation `v5.1.0`。

## 14. 相关代码与架构文档

端口、头像格式策略、归一化取景模型与任务状态位于 `lib/features/media/application/`，系统相册、背景输入校验、isolate 图片处理与 Dio adapter 位于 `lib/features/media/data/`，通用取景窗口位于 `lib/features/media/presentation/`，组合根绑定位于 `lib/app/production_overrides.dart`；正文插入入口分别位于 `lib/features/threads/presentation/thread_compose_page.dart` 和 `lib/features/posts/presentation/post_composer_sheet.dart`，共同使用 editor 公共会话。头像与背景仓储及写入状态位于 `lib/features/users/`。参见[用户与资料](users.md)、[编辑器](editor.md)、[网络与会话](../architecture/networking.md)。

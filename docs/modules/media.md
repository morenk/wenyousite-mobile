# 媒体

状态：`in_progress`

## 1. 模块目标与非目标

提供正文、动态/评论与头像图片选择、预签名上传、确认、完成态轮询和安全查看。当前已完成创建主题编辑器图片、动态最多九图、评论单图及本人头像设置/移除闭环；V1 不做视频、后台上传或离线上传队列。

## 2. 用户角色与使用场景

已登录用户从主题编辑器明确选择相册图片并插入正文，或在“我的”选择、设置和移除头像；所有可见用户可按安全 URL 加载正文图并进入全屏原图查看，头像按圆形 cover 角色展示。

## 3. 页面、入口和导航关系

`/compose/thread` 工具栏的图片按钮打开系统相册，随后要求填写不依赖文件名的替代文字。上传完成后在当前光标附近插入块级图片节点。`/compose/moment` 可逐张加入最多九图并排序/选择封面，动态评论可加入一张图片且会清除已选表情；正文、动态与评论图片轻触进入全屏页。“我的” `/me` 本人总览提供选择/更换头像；已有头像额外提供二次确认移除。

## 4. 用户操作流程

选择文件后先读取大小，拒绝空文件和超过 10MB 的内容；再结合声明类型、扩展名和头字节识别 JPG、PNG、GIF、WebP 或 AVIF。客户端调用 `mediaGetUploadUrl`，用独立且不携带 Bearer Token 的 Dio 对预签名 URL 执行 PUT，然后调用 `mediaConfirmUpload`。确认未完成时先等待 500ms，再最多轮询 `mediaGetMedia` 30 次；只有 `COMPLETED` 且公开 URL 为 HTTP(S) 时返回编辑器。

头像选择收窄为 JPG、PNG、WebP，并以头字节拒绝伪装格式；同样完成媒体管线后，将返回的 `mediaId` 交给 `usersSetAvatar`。设置成功只采用用户响应中明确给出的安全 HTTP(S) 头像 URL；当前契约未提供派生尺寸字段时使用该显式地址，不拼接 thumbnail/medium。移除调用 `usersRemoveAvatar`，仅在服务端最终 `avatar=null` 后更新页面。

## 5. API operationId 与生成类型

- 媒体管线：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 头像：`usersSetAvatar`、`usersRemoveAvatar`。
- 主要生成类型：`CreateUploadUrlDto`、`ConfirmUploadDto`、`MediaResponseDto`、`SetAvatarDto`、`PrivateUserResponseDto`。

## 6. 状态模型和数据流

`MediaUploadInput` 只在当前进程持有文件名、声明类型和字节；`MediaUploadProgress` 分为 preparing、uploading、confirming、processing，并可携带已发送/总字节；`UploadedEditorImage` 只暴露媒体 ID、安全公开 URL 和可选尺寸。编辑器页面独立保存取消令牌与错误，不把上传中状态写入快照。`AvatarState` 区分 picking、uploading、setting、removing、failed；设置端点失败会保留已完成上传的 `pendingMediaId`，重试不重新选择或上传。

## 7. 鉴权、权限和隐私规则

申请与确认使用主 API 会话；对象存储 PUT 使用独立无鉴权客户端，避免向第三方地址发送 Token。预签名 URL 不写日志、数据库或 UI 错误详情；文件仅在用户明确选择后读取。公开图和上传地址都要求 HTTP(S)，头像额外排除 GIF/AVIF 与格式伪装；Markdown alt 会移除协议不允许的换行和 `]`。`40107` 保留已上传媒体并先引导验证邮箱。

## 8. 本地存储、缓存及失效规则

预签名 URL、文件字节和处理中状态不持久化。上传完成后只有公开 URL 随完整 Markdown 进入本地快照；头像媒体 ID 只在当前 autoDispose 状态中保留到设置成功或页面释放。头像设置/移除成功立即采用服务端结果并淘汰旧 URL 缓存；本人资料不持久化，应用重启后重新调用 `usersGetMe`。当前用户 DTO 未显式提供派生 URL，客户端安全降级到服务端头像原地址而不猜测路径。

## 9. 加载、空数据、错误、重试和冲突状态

用户取消选择不提示错误；上传期间显示阶段和可用进度并允许取消。空文件、超限和未知类型在申请地址前拒绝；对象存储失败不会调用确认；确认缺失、处理失败和轮询超时都不插入正文。失败保留当前 Markdown，用户可重新选择；处理中禁止同时保存/发布，避免提交不存在的图片。头像上传前失败要求重新选择，上传后设置失败保留媒体 ID 和请求 ID，并只重试 `usersSetAvatar`；移除失败保留当前头像，二次确认成功前不调用删除端点。

## 10. 跨模块约束

只有 `COMPLETED` 资源能成为 `wenyou_image` 节点、动态/评论媒体 ID 或头像候选；编辑器负责 alt、插入位置与最终 Markdown 快照，moments 负责纯文本动态与媒体顺序，users 负责头像端点和本人资料事实。正文、动态详情和评论图片遵循 Foundation 的 contain、不裁切、状态占位和全屏交互契约；动态信息流封面和头像是允许 cover 裁切的角色，但动态封面必须可进入详情原图。

## 11. 测试场景与验收条件

- [x] 预签名 PUT、确认、轮询及完成后插入闭环通过。
- [x] 空文件、超限、未知类型在网络请求前拒绝。
- [x] 对象存储失败不确认，错误文本不暴露预签名查询参数。
- [x] 页面覆盖系统选择抽象、替代文字、上传插入与取消状态。
- [x] 正文图片 contain 显示并支持全屏、捏合、双击、平移和未放大下滑关闭。
- [x] 头像设置/删除、显式 URL 降级、旧缓存失效和重启后服务端事实恢复完成。

## 12. 已知限制和后续功能

头像当前不提供手动 1:1 裁剪；服务端用户 DTO 未提供 thumbnail/medium 字段，因此移动端只使用明确原地址。失败上传不保留原文件做一键重试，也不提供后台队列；处理中断后需重新选择图片。相册权限由 `image_picker` 和 Android 系统能力管理。

## 13. 最近审查的契约版本和后端提交

契约 `4.5.0-dev.20260809.1`；Markdown v2；后端 `437e76049a371ff8b6aee1b8a613dc864aa30f11`；Foundation `v1.1.0`。

## 14. 相关代码与架构文档

代码入口：`lib/features/media/`；头像仓储与状态位于 `lib/features/users/`；页面插入与查看位于 `lib/features/editor/presentation/`。参见[用户与资料](users.md)、[编辑器](editor.md)、[网络与会话](../architecture/networking.md)。

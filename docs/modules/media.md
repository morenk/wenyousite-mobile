# 媒体

状态：`in_progress`

## 1. 模块目标与非目标

提供正文图片选择、预签名上传、确认、完成态轮询和安全查看。当前已完成创建主题编辑器的图片闭环；头像设置/删除和派生尺寸选择仍待后续切片。V1 不做视频、后台上传或离线上传队列。

## 2. 用户角色与使用场景

已登录用户从主题编辑器明确选择相册图片并插入正文；所有可见用户可按安全 URL 加载正文图并进入全屏原图查看。

## 3. 页面、入口和导航关系

`/compose/thread` 工具栏的图片按钮打开系统相册，随后要求填写不依赖文件名的替代文字。上传完成后在当前光标附近插入块级图片节点。正文图片轻触进入全屏页；头像设置入口后续接入。

## 4. 用户操作流程

选择文件后先读取大小，拒绝空文件和超过 10MB 的内容；再结合声明类型、扩展名和头字节识别 JPG、PNG、GIF、WebP 或 AVIF。客户端调用 `mediaGetUploadUrl`，用独立且不携带 Bearer Token 的 Dio 对预签名 URL 执行 PUT，然后调用 `mediaConfirmUpload`。确认未完成时先等待 500ms，再最多轮询 `mediaGetMedia` 30 次；只有 `COMPLETED` 且公开 URL 为 HTTP(S) 时返回编辑器。

## 5. API operationId 与生成类型

- 当前正文图片：`mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`。
- 后续头像：`usersSetAvatar`、`usersRemoveAvatar`。
- 主要生成类型：`CreateUploadUrlDto`、`ConfirmUploadDto`、`MediaResponseDto`。

## 6. 状态模型和数据流

`MediaUploadInput` 只在当前进程持有文件名、声明类型和字节；`MediaUploadProgress` 分为 preparing、uploading、confirming、processing，并可携带已发送/总字节；`UploadedEditorImage` 只暴露媒体 ID、安全公开 URL 和可选尺寸。页面独立保存取消令牌与错误，不把上传中状态写入编辑器快照。

## 7. 鉴权、权限和隐私规则

申请与确认使用主 API 会话；对象存储 PUT 使用独立无鉴权客户端，避免向第三方地址发送 Token。预签名 URL 不写日志、数据库或 UI 错误详情；文件仅在用户明确选择后读取。公开图和上传地址都要求 HTTP(S)，Markdown alt 会移除协议不允许的换行和 `]`。

## 8. 本地存储、缓存及失效规则

预签名 URL、文件字节和处理中状态不持久化。上传完成后只有公开 URL 随完整 Markdown 进入本地快照；当前图片组件使用 Flutter 网络图片缓存。头像缓存失效策略和派生图缓存后续实现。

## 9. 加载、空数据、错误、重试和冲突状态

用户取消选择不提示错误；上传期间显示阶段和可用进度并允许取消。空文件、超限和未知类型在申请地址前拒绝；对象存储失败不会调用确认；确认缺失、处理失败和轮询超时都不插入正文。失败保留当前 Markdown，用户可重新选择；处理中禁止同时保存/发布，避免提交不存在的图片。

## 10. 跨模块约束

只有 `COMPLETED` 资源能成为 `wenyou_image` 节点；编辑器负责 alt、插入位置与最终 Markdown 快照。图片展示遵循 Foundation 的 contain、不裁切、状态占位和全屏交互契约。头像接入仍由 users 模块触发。

## 11. 测试场景与验收条件

- [x] 预签名 PUT、确认、轮询及完成后插入闭环通过。
- [x] 空文件、超限、未知类型在网络请求前拒绝。
- [x] 对象存储失败不确认，错误文本不暴露预签名查询参数。
- [x] 页面覆盖系统选择抽象、替代文字、上传插入与取消状态。
- [x] 正文图片 contain 显示并支持全屏、捏合、双击、平移和未放大下滑关闭。
- [ ] 头像设置/删除、派生尺寸降级和重启后缓存失效完成。

## 12. 已知限制和后续功能

当前未实现头像、thumbnail/medium 派生 URL 选择、失败上传的原文件一键重试及后台队列。处理中断后需重新选择图片；相册权限由 `image_picker` 和 Android 系统能力管理。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`；Foundation `v1.1.0`。

## 14. 相关代码与架构文档

代码入口：`lib/features/media/`；页面插入与查看：`lib/features/editor/presentation/`。参见[编辑器](editor.md)、[网络与会话](../architecture/networking.md)。

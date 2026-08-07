# 媒体

状态：`planned`

## 1. 模块目标与非目标

实现图片选择、预签名上传、确认、状态轮询、派生图降级和头像。V1 不做视频上传或离线上传队列。

## 2. 用户角色与使用场景

登录用户向正文或头像上传图片；所有可见用户加载安全的缩略图、详情图或原图降级。

## 3. 页面、入口和导航关系

编辑器和头像设置调用统一选择/上传组件；媒体预览可全屏查看，不暴露对象存储内部键。

## 4. 用户操作流程

选择文件后校验类型/大小，申请 URL，直接 PUT，调用确认，轮询至 COMPLETED，再把 URL 插入正文或设置头像。

## 5. API operationId 与生成类型

- `mediaGetUploadUrl`、`mediaConfirmUpload`、`mediaGetMedia`、`usersSetAvatar`、`usersRemoveAvatar`。
- 主要生成类型：`CreateUploadUrlDto`、`ConfirmUploadDto`、`MediaResponseDto`。

## 6. 状态模型和数据流

上传状态为 selected、requesting、uploading、confirming、processing、completed、failed、cancelled；进度与业务状态分离。

## 7. 鉴权、权限和隐私规则

预签名 URL 查询参数不记录、不持久化、不上报；只允许用户明确选择的文件；展示端校验 URL scheme。

## 8. 本地存储、缓存及失效规则

完成资源由 cached_network_image 管理；预签名 URL 不缓存。头像变化使用户图片缓存失效；未完成上传只保留当前进程状态。

## 9. 加载、空数据、错误、重试和冲突状态

选择取消不报错；PUT 超时允许明确重试；处理中使用占位并轮询退避；派生 URL 缺失或加载失败按 thumbnail/medium/url 顺序降级。

## 10. 跨模块约束

只有 COMPLETED 资源能插入 Markdown；文件选择使用 image_picker/file_selector；编辑器负责最终正文快照。

## 11. 测试场景与验收条件

- [ ] 预签名 PUT、确认、轮询和完成插入闭环通过。
- [ ] 取消、超时、处理失败和派生图 null 均可恢复。
- [ ] 日志与数据库不出现预签名查询参数。
- [ ] 头像设置与删除在重启后正确显示。

## 12. 已知限制和后续功能

不做视频、后台上传和离线队列；相册权限按 Android 系统能力请求。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.1`；Markdown v2；后端 `4a9c9bbcf67d9419768675455980810e9765cdf1`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/media/`。参见[编辑器](editor.md)、[网络与会话](../architecture/networking.md)。

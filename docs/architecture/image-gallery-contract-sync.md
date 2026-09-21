# 图片图集候选契约同步

从 Backend 已提交 `1f6a65e15dd66f88841bc80502f726804a07fa99` 同步 OpenAPI `5.26.0-dev.20260922.3` 与 `gallery-image-occurrences.json`，使用标准生成入口重建 Dart 客户端。新增 `galleryList`、`GalleryPageDto`、`GalleryImageDto`；媒体展示复用既有 `MediaDisplay`，正式 Markdown 和上传 API 不变。

图库历史索引未就绪错误固定 `40926`；最初候选与注册暂停错误码碰撞已在后端修正，并有业务码唯一性回归。移动端没有手改生成枚举。

完整门禁发现诊断端点索引也依赖固定 OpenAPI，已使用既有生成器同步，并纳入 `api:generate` / `api:check`，避免契约更新后遗漏此生成产物。索引仅包含固定路由模板和 operationId，不新增用户路径或正文采集。

兼容快照同时带入 Backend 5.24/5.25 已有管理内容端点及移除粉丝端点。管理能力沿用 `admin_product` 排除；移除粉丝归关系管理独立任务，暂列 `planned_social`，该消费者功能合入即删除排除项，避免被重复计为已覆盖。本图集切片不实现社交管理。

此同步是候选依赖记录，不表示后端已经合并、迁移、历史回填或部署。移动端上线前必须先完成兼容后端迁移、回填校验；不能为消除契约版本差异而自行部署。

Foundation 使用最新正式 `v7.1.0`，前置同步记录见 [Foundation 同步](image-gallery-foundation-sync.md)。

# 私有 APK 下载契约同步

2026-10-03 从 Backend 已提交分支 `codex/20261002-download-gateway` 同步 `c7060867fc938e002a14bff596886aea83279b1c`，OpenAPI `5.30.0-dev.20261002.2`。首契约为 `3bd4633e1f647783030eb3db872442c8a64d6f07`；后续修正将 HEAD 显式声明在 GET 前并固定匿名认证语义。

同步使用 `tool/sync_backend_contract.ps1 -BackendPath <只读镜像> -Branch codex/20261002-download-gateway -Revision <完整 SHA>`，新增逐字导出的 `contracts/app-download-gateway.md`。SDK 仅通过固定 OpenAPI Generator `7.23.0`、规范化脚本及 build_runner 生成，不手改生成物。

新增匿名下载信息及固定构建 GET/HEAD，保留旧 `/meta` 字段。文件不是 JSON API：Mobile 保持独立下载 Dio 的 HEAD 与流式 GET，避免 SDK 整包缓冲；下载 JSON 属于 Web 公开页面，不替代 Mobile 的推荐／强制策略。因此 API 审计对三个新 operationId 明确登记消费者边界。文件 metadata 继续校验包名、版本、构建、长度和 SHA-256，原生签名校验保持；文件网关的 `private, no-store` 与存储源对象的 immutable 缓存策略分开。

Foundation 文档／25 个共享场景固定于 `6c3776dd7c2de1aacafe0f6403fbb3ea98c5fb0d`（PR #30），语义来源为 `docs/app-downloads.md` 与 `tests/app-download-semantics-fixtures.json`；不新增 DTO 或 Token，正式依赖仍为 `v7.2.1`。

此提交是契约同步，不证明网关运行时、受限 SSH 预热／晋级入口已实现或部署。2026-10-03 负责人修正凭据前提：可以复用已有存储凭据；上游已提交文档中的“独立只读凭据”要求等待 Backend 后续提交修订，Mobile 不在同步副本内私改。实际接入遵循新授权：只在显式预热／修复进程使用隔离配置，公开网关不得持有或继承凭据，不调整现有凭据权限。固定 APK 桶／路径及只调用读取操作是应用层限制，不能证明云端权限最小化，泄漏仍可能影响现有凭据原先授权的全部资源。

本次定向验证：OpenAPI validate 与 api:generate 成功；`app_download_contract_test.dart` 6 项通过，覆盖 nullable 状态、完整制品身份及匿名 HEAD/GET/Range；`contract_revision.test.mjs` 通过逐字来源同步和拒绝非祖先 revision；生成客户端全量分析零问题；API 覆盖 162/162、21 个模块文档检查通过。既有生成类型无变化，仅新增下载类型、导出、serializer 注册和三条诊断路由。此前应用完整门禁记录继续保留；最终接入后的必要门禁另行执行。

源码来源检查继续以本文件的候选 SHA 为事实，不为消除公网版本／SHA 差异而部署或伪造同步。最终发布工具集成、测试与云／设备未验证项见[交接记录](private-apk-download-acceptance.md)。

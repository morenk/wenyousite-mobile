# 更新说明契约同步

2026-09-27 在 Windows 独立任务分支同步 Backend 已合并、已部署提交 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`，契约 `5.27.0-dev.20260927.1`。标准同步脚本从后端只读镜像 fetch `origin/dev`，显式指定完整 revision 并核对祖先关系，不读取未提交源码。

兼容新增公开 `mobileReleasesList`、`mobileReleasesDetail` 和五个管理 operation；Android 公开说明包含平台、版本名、构建号、摘要、条目、revision 和首次发布时间。列表游标倒序，只返回已发布快照。管理编辑、确认和发布锁由 Backend 负责，移动端不承载管理 API。`/meta` 现有字段与更新策略不变，未新增 FCM 或 iOS 发布能力。

OpenAPI Generator 保持 `7.23.0`，生成客户端与诊断路由通过既有脚本更新。标准同步归一化两个既有重复 CSRF 参数，不手改 SDK。既有 Markdown 与移动推送 fixture 未发生语义变化；固定独立来源的列表与行内组合 fixture 保持原提交及 hash。媒体展示、V1 黄金 fixture 和 API coverage 的版本元数据随包更新。

当前严格 `api:verify:production` 已通过：公网 `/meta` 为上述已部署 SHA 与契约版本，Markdown v5 在客户端支持范围内，`GET /threads` 兼容检查通过。来源复核不代表负责人真机或真实 APK 发布验收。受限发布 CLI 运维文档按同一提交自动导出，保留 Windows 安装、DPAPI、主机指纹与密钥轮换步骤，并同步管理部署测试降权说明；禁止两端手工维护副本。

历史完整门禁使用候选 `72d3658d32a089fcfabdea30225d87b960033c5b`，随后固定至 `9e25b4562dfd9229b0d306b5374c018c3e43f65c`；当时公网仍为旧版本，聚合检查非零记录继续保留。本次同步相对9e25仅改变来源元数据和运维文档，OpenAPI、应用代码与依赖不变。复用同应用的全量测试与 APK 证据，并补齐已部署来源、契约校验、生成一致性与文档检查，详细日志及未验证项见[验收记录](mobile-release-notes-acceptance.md)。

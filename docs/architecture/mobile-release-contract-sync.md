# 更新说明契约同步

2026-09-27 在 Windows 独立任务分支同步 Backend 已提交候选 `72d3658d32a089fcfabdea30225d87b960033c5b`，契约 `5.27.0-dev.20260927.1`。来源分支为 `origin/codex/20260927-mobile-release-notes`；标准同步脚本显式传入该分支与完整 revision，只读取后端镜像的已提交 Git 对象。

兼容新增公开 `mobileReleasesList`、`mobileReleasesDetail` 和五个管理 operation；Android 公开说明包含平台、版本名、构建号、摘要、条目、revision 和首次发布时间。列表游标倒序，只返回已发布快照。管理编辑、确认和发布锁由 Backend 负责，移动端不承载管理 API。`/meta` 现有字段与更新策略不变，未新增 FCM 或 iOS 发布能力。

OpenAPI Generator 保持 `7.23.0`，生成客户端与诊断路由通过既有脚本更新。标准同步归一化两个既有重复 CSRF 参数，不手改 SDK。既有 Markdown 与移动推送 fixture 未发生语义变化；固定独立来源的列表与行内组合 fixture 保持原提交及 hash。媒体展示、V1 黄金 fixture 和 API coverage 的版本元数据随包更新。

这是候选契约同步，不代表后端部署或端到端验收。公开 `/meta` 仍为 `124fb4e8aa395440f7a2156de98b642ec87f7583`、`5.26.0-dev.20260922.3`，最终门禁须保留该差异的失败结果。本次已按同一已提交 SHA 同步受限发布 CLI 运维文档，保留 Windows 安装、DPAPI、主机指纹与密钥轮换步骤。运维文档从 Backend docs 自动导出，禁止两端手工维护副本。第二次同步未改变 OpenAPI 或生成客户端字节。

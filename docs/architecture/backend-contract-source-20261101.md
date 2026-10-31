# 2026-11-01 后端已部署来源核对

Mobile 起点 `51a5edee6b2864b580e713a6f88f43802d35da7a` 记录 Backend `d54313346681eae8f62584d63d07f3315e42381b`。只读镜像更新后的 `origin/dev` 与公网 `/meta.buildSha` 均为 `19a6c4ed48829a781182527faaafce6e788e9e2e`，API 均为 `5.44.0-dev.20261024.3`。

最初契约与指南比较无差异，但完整门禁要求部署提交精确匹配，因来源记录落后而失败。没有放宽这个检查。使用 `tool/sync_backend_contract.ps1 -BackendPath D:\code\wenyousite\references\wenyousite-backend -Revision 19a6c4ed48829a781182527faaafce6e788e9e2e` 完整导出并规范化；最终契约目录唯一 diff 为 `backend-contract.properties` 的 revision 一行。

OpenAPI、Markdown／剪贴板／图片／换行／推送与字体 fixture、契约 CHANGELOG、移动端指南均无变化；固定的列表与行内组合来源保持。按 OpenAPI Generator 7.23.0 重新生成并比较，客户端无漂移。没有 HTTP、DTO、存储或正文迁移。模块最近审查来源同步到上述提交，历史验收记录保留。

公网 Markdown 为 5，契约导出记录为 4；客户端既有兼容集合 `{3, 4, 5, 6}` 覆盖两者，不修改其声明。`audio_budget_contract_test.dart` 的精确来源断言同步到新提交，错误码、版本和序列化断言不变。全量门禁与独立 APK 随性能候选执行，来源同步以独立 `chore` 提交交付，不更改门禁实现。

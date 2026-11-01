# 2026-10-27 后端契约来源核对

本任务起点 Mobile `6601eea95ad783acf082f5ab6abc472b950b2488`，原来源 `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`；更新只读镜像后 `origin/dev` 与公网 `/meta.buildSha` 同为 `d54313346681eae8f62584d63d07f3315e42381b`，API 仍为 `5.44.0-dev.20261024.3`，公网 Markdown 为 5，客户端兼容范围覆盖它。

使用 `tool/sync_backend_contract.ps1` 完整同步该已提交来源，保留脚本固定的列表与行内组合 fixture 来源。OpenAPI、Markdown/剪贴板/图片/换行与推送 fixture、契约 CHANGELOG、移动端指南均无变化；实际 diff 为来源属性与 `dynamic-text-fonts.md` 的后端字体格式验证说明。没有 HTTP、DTO、存储或正文迁移。按固定生成器 7.23.0 重新生成并审查客户端，生成结果无行为变化；完整门禁结果随本轮候选记录。

Foundation 已从只读镜像 fetch tags，最新正式版本仍为 `v7.6.0`，`pubspec.yaml` 与锁文件匹配；已阅读对应 CHANGELOG 和受影响的平台/表单/无障碍契约。本轮不升级依赖、不修改其他仓库。

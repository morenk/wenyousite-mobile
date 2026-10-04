# 帖内 RP 身份契约同步

固定 Backend `473738d25405828932f2e307f38ff82bbf50c2a4`（任务分支 `codex/20261004-rp-identity-backend`），HTTP `5.33.0-dev.20261004.1`。这是未部署的兼容候选，不能据此宣称线上支持。

通过 `tool/sync_backend_contract.ps1` 导出机器契约、Markdown 语义和 `thread-identity.v1.fixtures.json`，以 OpenAPI Generator 7.23.0 重新生成 Dart SDK。新增五个身份端点，既有账号字段保持原义，帖子和候选的身份字段全部可选；新端消费缺失字段时沿用账号资料。Foundation 样式仍固定正式 `v7.2.1`，不引用未发布包。

本 chore 只更新生成客户端和固定来源。后续业务切片接入设置、身份卡、作者/提及显示、筛选、搜索和通知。写入仍按账号关联，发言快照与昵称独立；身份冲突保留草稿并重新确认，结果不明的创建重试继续冻结原 payload 与幂等键。完整约定见[后端身份契约](../../contracts/thread-identity.md)。

不得删除旧账号字段、普通提及、无 RP 写入兼容或历史媒体引用。交付包括 API 校验、生成差异审查及后续全量门禁；负责人交互与真机验收单独记录，合并和部署由负责人决定。

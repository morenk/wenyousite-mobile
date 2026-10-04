# 帖内 RP 身份契约同步

用户补充允许逐条选择 RP／ACCOUNT。增量契约为四种创建／首次 BODY 写入增加可选 `identityMode`，省略仍走旧确认协议；ACCOUNT 不受 RP token 或资格变化干扰，RP 必须具有有效资料和本人确认。未知结果重试冻结 mode、token、正文和 UUID；编辑旧正文不改变原身份。再次单独同步并生成，业务改动随后提交。

开发阶段固定 Backend `5ab9767ff8ddce917ddb2560ea655bb58a2408a3`（任务分支 `codex/20261004-rp-identity-backend`），HTTP `5.33.0-dev.20261005.1`。用户随后明确授权兼容后端部署；PR #43 合并后，通过正式同步入口将来源固定为 `ff1a84178b37fabd7f8fd77e53989b4842b4d42f`。机器契约与固定语料未变，身份文档补充全部实际发言者目录、首次 BODY 冲突和合成预览边界；公网版本验证单独记入[候选验收](rp-identity-acceptance.md)。

通过 `tool/sync_backend_contract.ps1` 导出机器契约、Markdown 语义和 `thread-identity.v1.fixtures.json`，以 OpenAPI Generator 7.23.0 重新生成 Dart SDK。新增五个身份端点，既有账号字段保持原义，帖子和候选的身份字段全部可选；新端消费缺失字段时沿用账号资料。Foundation 样式仍固定正式 `v7.2.1`，不引用未发布包。

本 chore 只更新生成客户端和固定来源。后续业务切片接入设置、身份卡、作者/提及显示、筛选、搜索和通知。写入仍按账号关联，发言快照与昵称独立；身份冲突保留草稿并重新确认，结果不明的创建重试继续冻结原 payload 与幂等键。完整约定见[后端身份契约](../../contracts/thread-identity.md)。

不得删除旧账号字段、普通提及、无 RP 写入兼容或历史媒体引用。交付包括 API 校验、生成差异审查及后续全量门禁；负责人交互与真机验收单独记录，合并和部署由负责人决定。

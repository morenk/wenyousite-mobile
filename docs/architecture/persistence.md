# 本地持久化

敏感会话只进入 `flutter_secure_storage`。SharedPreferences 只保存非敏感偏好。Drift 保存编辑器快照和未确认的幂等创建操作：

- `LocalEditorSnapshot`：编辑上下文、完整 Markdown 正文、元数据、稳定幂等键和更新时间；Quill Delta 不作为权威快照；
- `PendingCreateOperation`：操作类型、规范化载荷、稳定请求 ID、确认状态和更新时间。

主题创建页以 `thread:new:<ownerId>` 作为稳定本地 ID，字段变化 700ms 防抖 upsert，应用失活、暂停或离页前强制刷新。JWT `sub` 只用于本地账号分区，不能替代服务端授权。首次远端保存前先写 `PendingCreateOperation`；网络超时或 5xx 转为 `awaitingConfirmation` 并保留原规范化载荷，重试继续使用同一 `clientRequestId`。服务端确认创建后才清理待确认记录，确认发布后才删除关联快照。

用户主动放弃编辑时仍应二次确认并删除对应快照；当前页面尚未提供该入口。退出登录清除账号相关缓存，但不静默删除账号隔离的未发布本地草稿。账号注销同样不自动上传或删除这些草稿；由于原账号不可恢复，注销页必须明确告知草稿仍留在本机却无法再由原账号恢复，不能把保留文件误述为可恢复能力。

数据库迁移必须递增 schema 版本并带迁移测试。任何 Token、密码、验证码、完整隐私资料和预签名 URL都不得写入 Drift。

参见：[草稿](../modules/drafts.md)、[编辑器](../modules/editor.md)、[Markdown ↔ Delta Codec](editor-codec.md)。

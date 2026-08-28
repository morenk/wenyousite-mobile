# 本地持久化

敏感会话只进入 `flutter_secure_storage`。SharedPreferences 只保存非敏感偏好，以及动态编辑器中已完成媒体的公开 URL/尺寸、标题、正文、封面 ID、图片顺序和更新时间；不保存源图片、预签名 URL、Token 或提交幂等键。外观使用 `appearance.preference.v1` 保存显式的 `light` 或 `dark` 覆盖，跟随系统时移除该键，缺失或未知值都安全回退为跟随系统。Drift 保存主题编辑器快照和未确认的幂等创建操作：

- `LocalEditorSnapshot`：编辑上下文、完整 Markdown 正文、元数据、稳定幂等键和更新时间；Quill Delta 不作为权威快照；
- `PendingCreateOperation`：操作类型、规范化载荷、稳定请求 ID、确认状态和更新时间。

主题创建页以 `thread:new:<ownerId>` 作为稳定本地 ID，字段变化 700ms 防抖 upsert，应用失活、暂停或离页前强制刷新。JWT `sub` 只用于本地账号分区，不能替代服务端授权。首次远端保存前先写 `PendingCreateOperation`；网络超时或 5xx 转为 `awaitingConfirmation` 并保留原规范化载荷，重试继续使用同一 `clientRequestId`。服务端确认创建后才清理待确认记录，确认发布后才删除关联快照。

动态编辑页以 `moment.compose.draft.v1:new` 或稳定 momentId 作为本机键，字段变化 500ms 防抖覆盖。重新进入先明确询问恢复或放弃，离页前可保留并退出、放弃修改或继续编辑；发布、保存、删除或明确放弃后删除对应记录。该草稿仅用于防止页面级输入丢失，不是离线发件箱，也不会跨设备同步或后台重放。

用户主动放弃编辑时仍应二次确认并删除对应快照；当前页面尚未提供该入口。退出登录清除账号相关缓存，但不静默删除账号隔离的未发布本地草稿。账号注销同样不自动上传或删除这些草稿；由于原账号不可恢复，注销页必须明确告知草稿仍留在本机却无法再由原账号恢复，不能把保留文件误述为可恢复能力。

当前 Drift schema 为 v1；`test/fixtures/app_database/schema_v1.sql` 固定真实旧库结构，回归会从该快照打开并验证编辑快照、待确认创建记录及未知枚举降级。数据库迁移必须递增 schema 版本、显式编写 `onUpgrade` 并带上一版快照迁移测试；若存储版本高于当前实现或缺少迁移路径，必须失败而不得静默重建。任何 Token、密码、验证码、完整隐私资料和预签名 URL 都不得写入 Drift。

参见：[草稿](../modules/drafts.md)、[编辑器](../modules/editor.md)、[Markdown ↔ Delta Codec](editor-codec.md)。

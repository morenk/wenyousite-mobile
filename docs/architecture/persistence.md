# 本地持久化

敏感会话只进入 `flutter_secure_storage`。SharedPreferences 只保存非敏感偏好；旧无归属动态草稿保留但不读取。外观使用 `appearance.preference.v1` 保存显式的 `light` 或 `dark` 覆盖，跟随系统时移除该键，缺失或未知值都安全回退为跟随系统。Drift 保存按账号隔离的主题/动态快照和未确认的幂等创建操作：

- `LocalEditorSnapshot`：编辑上下文、完整正文、元数据、稳定幂等键和更新时间；主题保存完整 Markdown，动态保持现有纯文本/站内坐标语义，Quill Delta 不落盘；
- `PendingCreateOperation`：操作类型、规范化载荷、稳定请求 ID、确认状态和更新时间。

主题创建页以 `thread:new:<ownerId>` 作为稳定本地 ID，字段变化 700ms 防抖 upsert，应用失活、暂停或离页前强制刷新。JWT `sub` 只用于本地账号分区，不能替代服务端授权。首次远端保存前把当前快照与 `PendingCreateOperation` 原子提交；网络超时或 5xx 转为 `awaitingConfirmation` 并保留原规范化载荷，重试继续使用同一 `clientRequestId`。服务端确认创建后在同一事务保存远端关联并清理待确认记录，确认发布后才删除关联快照；提交从强制保存开始互斥，生命周期保存等待该次操作，不得在发布后复活旧快照。

动态快照使用 `moment:` 加上账号与 momentId 的 JSON 元组作为键，正文与图片元数据保存在现有 Drift v1 快照表。500ms 防抖、失活/暂停和离页保存串行提交；首次创建把快照与冻结载荷/UUID 原子写入两张现有表。待确认时不再接受内容编辑或丢弃，重开只恢复不发送，由用户重试原操作；成功后原子清除关联快照与待确认记录。旧 SharedPreferences `moment.compose.draft.v1:*` 不具备可验证账号归属，原样保留且禁止自动读取、恢复或迁移。这不是离线发件箱，不跨设备同步或后台重放。

用户主动放弃编辑时仍应二次确认并删除对应快照；当前页面尚未提供该入口。退出登录清除账号相关缓存，但不静默删除账号隔离的未发布本地草稿。账号注销同样不自动上传或删除这些草稿；由于原账号不可恢复，注销页必须明确告知草稿仍留在本机却无法再由原账号恢复，不能把保留文件误述为可恢复能力。

当前 Drift schema 为 v1；`test/fixtures/app_database/schema_v1.sql` 固定真实旧库结构，回归会从该快照打开并验证编辑快照、待确认创建记录及未知枚举降级。数据库迁移必须递增 schema 版本、显式编写 `onUpgrade` 并带上一版快照迁移测试；若存储版本高于当前实现或缺少迁移路径，必须失败而不得静默重建。任何 Token、密码、验证码、完整隐私资料和预签名 URL 都不得写入 Drift。

参见：[草稿](../modules/drafts.md)、[编辑器](../modules/editor.md)、[Markdown ↔ Delta Codec](editor-codec.md)。

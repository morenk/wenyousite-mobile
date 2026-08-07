# 本地持久化

敏感会话只进入 `flutter_secure_storage`。SharedPreferences 只保存非敏感偏好。Drift 保存编辑器快照和未确认的幂等创建操作：

- `LocalEditorSnapshot`：编辑上下文、完整 Markdown 正文、元数据、稳定幂等键和更新时间；Quill Delta 不作为权威快照；
- `PendingCreateOperation`：操作类型、规范化载荷、稳定请求 ID、确认状态和更新时间。

网络超时不删除待确认操作；服务端确认成功后才清理。用户主动放弃编辑时应二次确认并删除对应快照。退出登录清除账号相关缓存，但不静默删除未归属账号的本地草稿。

数据库迁移必须递增 schema 版本并带迁移测试。任何 Token、密码、验证码、完整隐私资料和预签名 URL都不得写入 Drift。

参见：[草稿](../modules/drafts.md)、[编辑器](../modules/editor.md)、[Markdown ↔ Delta Codec](editor-codec.md)。

# 草稿

状态：`in_progress`

## 1. 模块目标与非目标

提供本地自动快照、主题实体的未发布服务端草稿，以及后端五槽位正文草稿。当前完成前两者在创建主题场景的闭环；五槽位正文草稿列表、恢复、更新和删除仍待独立切片。V1 不做跨设备实时协作或后台自动发布。

## 2. 用户角色与使用场景

已登录用户创建主题时获得按账号隔离的本地防丢快照，可主动保存为服务端未发布主题。五槽位正文草稿后续用于跨设备手动保存和恢复纯正文内容。

## 3. 页面、入口和导航关系

`/compose/thread` 自动加载本地主题快照并显示本地保存状态；页面和工具栏可主动“保存到服务端草稿”。五槽位正文草稿的选择面板与独立入口尚未接入。

## 4. 用户操作流程

页面把内存 Delta 安全编码为完整 Markdown，字段变化后 700ms 防抖覆盖本地快照；应用暂停、失活或离页前立即刷新。本地快照不存在远端主题时，首次保存会持久化创建载荷并调用 `threadsCreate`，随后用 `threadsSaveAggregate` 保存当前字段和版本；后续保存直接聚合更新同一未发布主题。发布确认后删除关联本地快照。

五槽位正文草稿后续会先读取槽位用量和列表，再创建或携带版本更新；恢复时若本地和云端都变化，必须展示更新时间并由用户选择，禁止静默覆盖。

## 5. API operationId 与生成类型

- 当前主题实体草稿：`threadsCreate`、`threadsSaveAggregate`，使用 `CreateThreadDto`、`SaveThreadAggregateDto`。
- 后续五槽位正文草稿：`draftsFindAll`、`draftsCreate`、`draftsSlotUsage`、`draftsFindById`、`draftsUpdate`、`draftsRemove`。
- 相关生成类型：`DraftResponseDto`、`DraftSlotUsageResponseDto`、`CreateDraftDto`、`UpdateDraftDto`。

## 6. 状态模型和数据流

`ThreadComposeState.localSnapshotStatus` 区分 idle、saving、saved、failed；`ThreadRemoteDraft` 保存服务端主题、默认子贴和正文版本；`PendingCreateOperation` 区分 pending、sending、awaitingConfirmation。数据库存完整 Markdown 和表单元数据，不保存 Delta。五槽位列表后续以服务端为事实并映射为可恢复正文。

## 7. 鉴权、权限和隐私规则

服务端草稿必须登录。本地快照按 JWT `sub` 分区，但服务端仍是身份和权限事实；切号不会自动展示其他账号内容。Token、预签名 URL、验证码和密码不得进入草稿。退出登录不静默删除尚未发布的账号快照。

## 8. 本地存储、缓存及失效

`local_editor_snapshots` 以稳定 ID `thread:new:<ownerId>` upsert，保存上下文、Markdown、JSON 元数据、`clientRequestId` 和更新时间；`pending_create_operations` 保存操作类型、规范化载荷、状态和更新时间。服务端主题草稿确认后更新快照中的远端版本；发布确认后仅删除关联快照。五槽位云草稿后续只做当前会话缓存。

## 9. 加载、空数据、错误、重试和冲突

本地元数据无法识别时停止恢复且不覆盖原记录；写盘失败明确提示，离页时要求用户选择留下或承担风险退出。创建主题超时或 5xx 保留原规范化载荷和幂等键；用户继续编辑后重试仍先确认原创建，再聚合当前内容。`40912` 清理冲突待确认记录并生成新键。服务端保存失败不会删除本地副本。五槽位满额、云端删除和版本冲突 UI 尚待实现。

## 10. 跨模块约束

Markdown 规范化和可见性由编辑器保持，数据库规则见[持久化](../architecture/persistence.md)。主题实体草稿与后端 `/drafts` 五槽位正文草稿是不同资源，页面和文档不得混称。媒体只有完成后的公开 URL 能进入快照。

## 11. 测试场景与验收条件

- [x] 本地快照按稳定 ID 覆盖保存、读取和删除，进程重建后可恢复完整 Markdown 和表单元数据。
- [x] 字段变化防抖保存，生命周期和离页路径可强制刷新。
- [x] 待确认创建操作完整保存规范化载荷、稳定请求 ID 和确认状态。
- [x] 超时后继续编辑仍复用原请求确认，并用当前正文完成聚合。
- [x] 发布成功只清理关联本地主题快照。
- [ ] 五槽位创建、更新、删除、满额提示及本地/云选择完成。

## 12. 已知限制和后续功能

后端五槽位正文草稿尚未接入，因此当前工具栏保存的是主题实体的未发布草稿，不提供跨上下文正文槽位。尚无用户主动放弃并删除本地快照的入口、云端冲突对比或自动合并；不做后台发布。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

控制器和存储接口：`lib/features/editor/application/`、`lib/features/editor/data/editor_snapshot_store.dart`；数据库：`lib/core/storage/app_database.dart`。参见[编辑器](editor.md)、[持久化](../architecture/persistence.md)。

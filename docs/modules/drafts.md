# 草稿

状态：`in_progress`

## 1. 模块目标与非目标

提供按账号隔离的本地自动快照、主题实体的未发布服务端草稿，以及后端用户级五槽位正文草稿。当前三类草稿均已在创建主题场景形成手动可操作闭环。V1 不做跨设备实时协作、云端自动合并、后台自动发布或正文草稿后台自动保存。

## 2. 用户角色与使用场景

已登录用户创建主题时获得本地防丢快照，可主动保存为未发布主题实体；也可把当前纯正文保存到五个全局槽位，在另一设备或后续编辑会话中手动恢复。标题、分类、可见范围和标签不进入五槽位正文草稿。

## 3. 页面、入口和导航关系

`/compose/thread` 自动加载本地主题快照并显示本地保存状态。编辑器工具栏的“正文草稿”打开 90% 高度的五槽位面板；页面底部“保存到服务端草稿”继续保存包含完整表单的未发布主题实体。两类服务端草稿拥有不同文案和入口，不互相替代。

## 4. 用户操作流程

页面把内存 Delta 安全编码为完整 Markdown，字段变化后 700ms 防抖覆盖本地快照；应用暂停、失活或离页前立即刷新。本地快照不存在远端主题时，首次保存会持久化创建载荷并调用 `threadsCreate`，随后用 `threadsSaveAggregate` 保存当前字段和版本；后续保存直接聚合更新同一未发布主题。发布确认后删除关联本地快照。

打开正文草稿面板时同时读取列表和槽位用量。用户可让服务端自动选择下一空位，也可保存到指定空槽；占用槽位必须确认后携带当前版本更新，删除也必须确认。恢复前重新读取单条最新版；当前编辑器已有不同正文时，用户明确选择“覆盖并恢复”后才替换正文，标题、分类和标签保持不变。

## 5. API operationId 与生成类型

- 主题实体草稿：`threadsCreate`、`threadsSaveAggregate`，使用 `CreateThreadDto`、`SaveThreadAggregateDto`。
- 五槽位正文草稿：`draftsFindAll`、`draftsSlotUsage`、`draftsFindById`、`draftsCreate`、`draftsUpdate`、`draftsRemove`。
- 相关生成类型：`DraftResponseDto`、`DraftSlotUsageResponseDto`、`CreateDraftDto`、`UpdateDraftDto`、`DeleteDraftResponseDto`。

## 6. 状态模型和数据流

`ThreadComposeState.localSnapshotStatus` 区分 idle、saving、saved、failed；`ThreadRemoteDraft` 保存服务端主题、默认子贴和正文版本；`PendingCreateOperation` 区分 pending、sending、awaitingConfirmation。数据库只存完整 Markdown 和表单元数据，不保存 Delta。

`ContentDraftsState` 分离列表加载阶段、槽位用量、按槽位排序的领域草稿、当前写入/删除目标、动作反馈与版本冲突；`ContentDraftConflict` 同时保留刚读取的云端最新版和未提交的本机正文。服务端 DTO 不直接承担面板状态。

## 7. 鉴权、权限和隐私规则

两类服务端草稿都必须登录。本地快照按 JWT `sub` 分区，但服务端仍是身份和权限事实；切号会释放当前正文草稿状态，不展示其他账号内容。Token、预签名 URL、验证码和密码不得进入草稿。退出登录不静默删除尚未发布的账号快照。

## 8. 本地存储、缓存及失效规则

`local_editor_snapshots` 以稳定 ID `thread:new:<ownerId>` upsert，保存上下文、Markdown、JSON 元数据、`clientRequestId` 和更新时间；`pending_create_operations` 保存操作类型、规范化载荷、状态和更新时间。服务端主题草稿确认后更新快照中的远端版本；发布确认后仅删除关联快照。

五槽位列表只在当前面板会话内缓存，以服务端列表和槽位接口为事实；创建、更新和删除成功后立即更新本地列表，写入失败时尝试重新校准服务端槽位。关闭面板或身份变化后状态释放，不把云草稿复制进 Drift。

## 9. 加载、空数据、错误、重试和冲突状态

本地元数据无法识别时停止恢复且不覆盖原记录；写盘失败明确提示，离页时要求用户选择留下或承担风险退出。创建主题超时或 5xx 保留原规范化载荷和幂等键；`40912` 清理冲突待确认记录并生成新键。服务端保存失败不会删除本地副本。

正文草稿面板覆盖加载、失败重试、空槽、五槽满额、逐项处理中和成功/失败反馈。空正文和超过 10000 字符的正文不会发送。覆盖携带当前 `version`；收到 `40002 OPTIMISTIC_LOCK_CONFLICT` 时先读取最新版，保留本机待保存正文，再由用户二次确认是否覆盖。恢复也先读取最新版，禁止静默覆盖当前编辑器；删除失败保留原条目。

## 10. 跨模块约束

Markdown 规范化和可见性由编辑器与核心 Markdown 能力保持，数据库规则见[持久化](../architecture/persistence.md)。主题实体草稿与后端 `/drafts` 五槽位正文草稿是不同资源，页面和文档不得混称。媒体只有完成后的公开 URL 能进入任一快照；恢复正文不修改主题表单元数据。

## 11. 测试场景与验收条件

- [x] 本地快照按稳定 ID 覆盖保存、读取和删除，进程重建后可恢复完整 Markdown 和表单元数据。
- [x] 字段变化防抖保存，生命周期和离页路径可强制刷新。
- [x] 待确认创建操作保存规范化载荷、稳定请求 ID 和确认状态；超时后继续编辑仍复用原请求确认。
- [x] 发布成功只清理关联本地主题快照。
- [x] 五槽位列表与用量并发读取，六个 Drafts operationId 均由仓储测试固定。
- [x] 自动空位、指定空槽、版本更新、删除、满额和空正文状态完成。
- [x] 恢复前读取最新版并确认替换；`40002` 冲突保留本机正文并要求二次确认。
- [x] 五槽位面板覆盖加载、错误、成功反馈、删除确认和 360dp 无横向溢出。

## 12. 已知限制和后续功能

五槽位面板当前只从创建主题编辑器进入，尚未复用于楼层和回复编辑器；不提供 Web 端槽位 1 自动保存开关。云端冲突只支持“保留云端”或“用当前全文覆盖最新版”，不做逐段差异、合并和历史版本恢复。用户主动放弃并删除本地主题快照的入口仍待实现。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`；Foundation `v1.1.0`（`4974b09a29d5d1c9632f4b2683c8d36c9e3c69bd`）。

## 14. 相关代码与架构文档

五槽位正文草稿：`lib/features/drafts/`；主题创作控制器与存储：`lib/features/editor/application/`、`lib/features/editor/data/editor_snapshot_store.dart`；数据库：`lib/core/storage/app_database.dart`。参见[编辑器](editor.md)、[持久化](../architecture/persistence.md)。

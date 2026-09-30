# 兼容与弃用登记

## 私密邀请链接复用（候选／待负责人验收）

- 固定 Backend `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`／`5.29.0-dev.20261001.1`，新增消费 `threadsEnsureInviteLink`（PUT，200）。`threadsCreateInviteLink`（POST）及其 operationId 保留，仅在用户明确确认重置时调用，显式禁止自动重放。
- 旧客户端继续使用 POST 重置；新客户端获取失败不得回退 POST。必须先发布兼容 Backend，再发布消费者。服务端重置只使旧链接失效，不撤销既有成员；本切片不改 Schema、本地持久化或成员权限。
- 未删除接口、DTO 或兼容协议；回滚消费者可恢复旧入口，不能恢复已经重置的旧 token。Foundation 仅补共享交互文档，继续锁定正式 v7.2.1，不等待新包发布。
- 随契约生成同步的可选 `PostBaseResponseDto.editedAt` 保留兼容，不在本切片消费。检查和未覆盖项见[邀请候选验收](architecture/private-invite-reuse-acceptance.md)。

## 本人关注与粉丝管理

- 新增消费 `usersFollowRemoveFollower`；`UserFollowRecordResponseDto.viewerIsFollowing`、`viewerIsFollowedBy` 为可选，本人列表缺字段时展示关系暂不可用，不误判未关注，不允许未知状态写入。原公开/本人列表路径与原关注接口保留。
- 兼容后端已先行合并与部署，消费端已获负责人验收并授权合并 dev，尚未正式发布 Android；本候选来源已同步 Backend `92b030a81f8957386e324fed477bd1e46faf65ea` / `5.26.0-dev.20260922.3`（关系接口与此前 4850e2f 来源完全一致）。旧后端不能提供新管理能力，但原列表仍可读取；不逐行请求主页补投影。
- Foundation 锁定正式 v7.1.0；关系交互说明来自共享文档提交 `ba1e921212b908835734732f26e263203a8226c6`，无新增 Token、版本或 Tag。
- 不新增数据库或本地持久化，不删除兼容协议。回滚消费者恢复原页面与对应依赖；已发生的关系写入不会通过回滚客户端恢复。

## 兼容新增图集读取

- 本关系候选仅同步 `galleryList` 和生成类型，不改变既有图片查看入口；完整图集消费由独立媒体切片接入。管理端 `rememberDevice` 可选字段不改变 Mobile 认证流程。
- 不移除或清理旧协议；已有关系字段缺失兼容、未知结果只读核实和回滚边界保持。

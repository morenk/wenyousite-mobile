# 兼容与弃用登记

## 本人关注与粉丝管理

- 新增消费 `usersFollowRemoveFollower`；`UserFollowRecordResponseDto.viewerIsFollowing`、`viewerIsFollowedBy` 为可选，本人列表缺字段时展示关系暂不可用，不误判未关注，不允许未知状态写入。原公开/本人列表路径与原关注接口保留。
- 兼容后端先合并和部署，再发布消费端；本候选固定 Backend `ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a` / `5.25.0-dev.20260922.1`。旧后端不能提供新管理能力，但原列表仍可读取；不逐行请求主页补投影。
- Foundation 锁定正式 v7.1.0；关系交互说明来自共享文档提交 `ba1e921212b908835734732f26e263203a8226c6`，无新增 Token、版本或 Tag。
- 不新增数据库或本地持久化，不删除兼容协议。回滚消费者恢复原页面与对应依赖；已发生的关系写入不会通过回滚客户端恢复。

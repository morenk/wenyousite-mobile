# 主题与子贴

状态：`planned`

## 1. 模块目标与非目标

实现主题详情、子贴选择、创建/编辑/删除、点赞收藏订阅、私密邀请和成员工作台。V1 不实现举报后台或子贴标签。

## 2. 用户角色与使用场景

游客阅读公开主题；成员参与；拥有者和管理员维护主题、子贴、成员与玩家；受邀用户预览并确认加入私密主题。

## 3. 页面、入口和导航关系

主题详情从首页/搜索/用户页进入；子贴切换控制楼层源；工作台、成员页和邀请预览为二级路由。

## 4. 用户操作流程

加载主题与子贴，选择子贴后加载楼层；写操作按服务端权限显示；创建操作复用稳定 `clientRequestId`；邀请先预览再明确加入。

## 5. API operationId 与生成类型

- `threadsFindById`、`threadsCreate`、`threadsUpdate`、`threadsRemove`、`threadsSaveAggregate`。
- `subthreadsFindAll`、`subthreadsCreate`、`subthreadsFindById`、`subthreadsUpdate`、`subthreadsRemove`、`subthreadsReorder`。
- `threadsLike`、`threadsUnlike`、`threadsCreateInviteLink`、`threadsPreviewInviteLink`、`threadsJoinByInviteLink`。
- `threadMembersFindAll`、`threadMembersJoin`、`threadMembersUpdateMember`、`threadMembersExitMember`。

## 6. 状态模型和数据流

主题详情、当前成员身份、子贴列表和选中 ID 分离；写操作成功后按返回结果更新，权限变化触发详情失效。

## 7. 鉴权、权限和隐私规则

私密主题未授权时不显示标题、成员或缓存内容。所有管理按钮依据服务端成员角色与能力字段；客户端判断只用于隐藏 UI，不替代服务端鉴权。

## 8. 本地存储、缓存及失效规则

编辑快照和待确认创建存 Drift；详情进程内缓存。退出主题、被移除、切号或 403 时清除私密缓存。

## 9. 加载、空数据、错误、重试和冲突状态

主题不存在、无权限、已删除、无子贴、成员为空和邀请失效有专用状态。版本 409 保护本地正文并提示刷新；幂等键冲突停止自动重试。

## 10. 跨模块约束

正文使用编辑器与 Markdown v2；媒体必须 COMPLETED；社交状态由 social 仓储协调；楼层由 posts 模块加载。

## 11. 测试场景与验收条件

- [ ] 公开阅读、子贴切换、创建编辑删除闭环通过。
- [ ] 点赞、收藏、订阅状态可恢复且错误可重试。
- [ ] 私密邀请预览/确认、成员权限和退出流程正确。
- [ ] 超时重试复用幂等键，409 不丢本地编辑内容。

## 12. 已知限制和后续功能

0.3 先完成阅读，0.6 完成工作台与成员；V1 不做举报管理和子贴标签。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/threads/`。参见[楼层与回复](posts.md)、[编辑器](editor.md)、[持久化](../architecture/persistence.md)。

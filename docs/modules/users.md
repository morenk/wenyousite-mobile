# 用户与资料

状态：`planned`

## 1. 模块目标与非目标

实现用户主页、个人资料、隐私字段、创建/参与主题、最近回复、关注与粉丝列表。账号安全写操作归 settings/auth。

## 2. 用户角色与使用场景

游客浏览公开资料；登录用户查看关系和允许的扩展信息；本人编辑资料和隐私设置。

## 3. 页面、入口和导航关系

用户主页从搜索、主题作者、提及和关系列表进入；我的分支进入本人资料与编辑页。

## 4. 用户操作流程

按用户 ID 读取资料，按需加载主题/回复 Tab；本人编辑后更新缓存；关注列表进入其他用户页。

## 5. API operationId 与生成类型

- `usersGetMe`、`usersUpdateMe`、`usersDeleteMe`、`usersGetUser`、`usersSearch`。
- `usersGetUserBookmarks`、`usersGetUserPlayedThreads`、`usersGetUserCreatedThreads`、`usersGetUserRecentReplies`。
- `usersFollowFollowing`、`usersFollowFollowers`、`usersFollowUserFollowing`、`usersFollowUserFollowers`。

## 6. 状态模型和数据流

公共资料与本人私有资料使用不同展示模型；各内容 Tab 独立分页；关系变化只更新对应关系字段和计数。

## 7. 鉴权、权限和隐私规则

客户端只展示响应中存在的隐私字段，不以空值推断真实数据。切号清本人私有缓存；被拉黑关系按服务端可见性降级。

## 8. 本地存储、缓存及失效规则

头像走图片缓存；资料进程内按 ID 缓存。本人更新、关注变化、切号和返回前台使相关缓存失效。

## 9. 加载、空数据、错误、重试和冲突状态

用户不存在、资料受限、Tab 为空和分页错误独立展示；编辑失败保留表单；注销流程不在普通资料页误触。

## 10. 跨模块约束

关系写操作由 social 管理；头像由 media；密码、邮箱、会话和注销由 settings/auth。

## 11. 测试场景与验收条件

- [ ] 游客与本人看到的资料字段符合权限。
- [ ] 创建/参与/回复和关系列表独立分页。
- [ ] 资料编辑、头像变化和重启后显示正确。
- [ ] 切号、拉黑和隐私变化不泄露缓存。

## 12. 已知限制和后续功能

不做资料离线缓存、复杂勋章系统或后台用户管理。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.2`；Markdown v2；后端 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/users/`。参见[社交关系](social.md)、[设置](settings.md)。

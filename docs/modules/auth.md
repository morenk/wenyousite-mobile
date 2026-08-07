# 认证与账号生命周期

状态：`planned`

## 1. 模块目标与非目标

实现注册、登录、邮箱验证、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销。V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页可由受保护动作触发并保存原目标；注册采用验证码分步流程；安全设置进入密码、邮箱、会话和注销页。

## 4. 用户操作流程

登录/完成注册发送 mobile 头并原子保存双 Token；启动恢复安全存储；并发过期只刷新一次；退出先请求服务端，再无条件清理本地。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authVerifyEmail`、`authResendVerification`、`authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`UserSessionResponseDto`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated。认证仓储完成 DTO 映射，SessionController 负责安全存储和路由通知。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift 或 SharedPreferences。`40103` 至 `40106` 清会话；`40107` 进入邮箱验证状态。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。退出、注销、终端撤销或刷新失败立即删除；用户资料缓存按账号隔离。

## 9. 加载、空数据、错误、重试和冲突状态

表单防重复提交；429 展示冷却时间；弱网不自动重复发送验证码；退出即使服务端失败也完成本地退出。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。

## 11. 测试场景与验收条件

- [ ] 注册、登录、重启恢复和退出闭环通过。
- [ ] 并发 `40101` 只发起一次刷新并轮转双 Token。
- [ ] 撤销、锁定、注销和未验证邮箱进入正确状态。
- [ ] 密码重置、改密、改邮箱、终端查看与撤销可操作。

## 12. 已知限制和后续功能

不做第三方登录、生物识别登录和多账号切换；破坏性注销只用一次性测试账号验收。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.1`；Markdown v2；后端 `4a9c9bbcf67d9419768675455980810e9765cdf1`。

## 14. 相关代码与架构文档

计划代码入口：`lib/features/auth/`。参见[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

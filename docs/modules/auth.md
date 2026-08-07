# 认证与账号生命周期

状态：`in_progress`

## 1. 模块目标与非目标

实现注册、登录、邮箱验证、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销。当前已交付账号/密码登录、双 Token 安全落库、鉴权回跳、并发刷新与当前终端退出；V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页 `/auth/login` 可从“我的”或受保护动作进入，并通过 `returnTo` 保存仓库内目标；当前创建主题入口登录成功后恢复 `/compose/thread`。注册采用验证码分步流程；安全设置入口留给后续切片。

## 4. 用户操作流程

登录表单校验账号与密码，防止重复提交；`authLogin` 显式发送 mobile 头，响应必须同时含 access/refresh token 才原子保存并恢复目标。并发 `40101` 共享一次 `authRefresh`，双 Token 原子轮转后原请求只重放一次；再次过期进入失效登录页。用户从“我的”确认退出后调用 `authLogout` 撤销当前 refresh token，Access Token 已过期时先刷新再重试一次。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authVerifyEmail`、`authResendVerification`、`authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`UserSessionResponseDto`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated；`LoginState` 与 `LogoutState` 均为 idle、submitting、failed。认证仓储完成 `LoginDto` 与双 Token 映射，独立会话远端通过生成客户端处理 `RefreshDto`、`LogoutDto`，`SessionController` 串行发布安全存储与路由状态。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift 或 SharedPreferences。`40103` 至 `40106`、刷新失败或重放仍为 `40101` 时清会话；`40107` 进入邮箱验证状态。退出请求显式发送当前 access/refresh token，但日志不记录其内容。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。登录和刷新成功先完成安全存储写入再发布 authenticated 状态；服务端确认退出或明确返回会话失效后删除。瞬时退出失败保留会话供重试；用户明确二次确认“仅清除本机登录”时允许本地删除，并提示稍后检查服务端终端。用户资料缓存尚未接入。

## 9. 加载、空数据、错误、重试和冲突状态

登录与退出均防重复提交；`40110` 使用稳定的“账号或密码错误”提示。退出失败保留认证状态、展示安全的请求 ID并允许重试；仅本机退出需要单独风险确认。429 冷却和验证码弱网策略在注册切片实现。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。

## 11. 测试场景与验收条件

- [x] 账号/密码登录显式发送 mobile 头，双 Token 原子写入，创建入口鉴权回跳通过。
- [x] 重启恢复和当前终端服务端退出闭环通过，失败可重试或明确选择本机退出。
- [x] 并发 `40101` 只发起一次刷新并轮转双 Token，原请求最多重放一次。
- [ ] 注册闭环通过。
- [ ] 撤销、锁定、注销和未验证邮箱进入正确状态。
- [ ] 密码重置、改密、改邮箱、终端查看与撤销可操作。

## 12. 已知限制和后续功能

当前完成账号/密码登录、创建入口回跳、会话恢复/刷新及当前终端退出；注册、找回密码、邮箱/密码/终端管理和注销仍待后续切片。仅本机退出无法确认服务端 refresh token 已撤销，后续登录后应通过终端管理检查。不做第三方登录、生物识别登录和多账号切换；破坏性注销只用一次性测试账号验收。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.2`；Markdown v2；后端 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`。

## 14. 相关代码与架构文档

代码入口：`lib/features/auth/`、`lib/core/network/session_remote.dart`。参见[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

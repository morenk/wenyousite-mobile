# 认证与账号生命周期

状态：`in_progress`

## 1. 模块目标与非目标

实现注册、登录、邮箱验证、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销。本切片先交付账号/密码登录、双 Token 安全落库和鉴权回跳；V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页 `/auth/login` 可从“我的”或受保护动作进入，并通过 `returnTo` 保存仓库内目标；当前创建主题入口登录成功后恢复 `/compose/thread`。注册采用验证码分步流程；安全设置入口留给后续切片。

## 4. 用户操作流程

登录表单校验账号与密码，防止重复提交；`authLogin` 显式发送 mobile 头，响应必须同时含 access/refresh token 才原子保存并恢复目标。启动恢复、并发刷新和本地失效基线已存在；服务端退出与注册流程在后续切片接入。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authVerifyEmail`、`authResendVerification`、`authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`UserSessionResponseDto`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated；`LoginState` 为 idle、submitting、failed。认证仓储完成 `LoginDto` 与双 Token 映射，`LoginController` 串行提交，`SessionController` 负责安全存储和路由刷新。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift 或 SharedPreferences。`40103` 至 `40106` 清会话；`40107` 进入邮箱验证状态。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。登录成功先完成安全存储写入再发布 authenticated 状态；退出、注销、终端撤销或刷新失败立即删除。用户资料缓存尚未接入。

## 9. 加载、空数据、错误、重试和冲突状态

表单空值在本地拦截并防重复提交；`40110` 使用稳定的“账号或密码错误”提示，失败页可展示安全的请求 ID。429 冷却、验证码弱网策略和服务端退出在对应后续切片实现。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。

## 11. 测试场景与验收条件

- [x] 账号/密码登录显式发送 mobile 头，双 Token 原子写入，创建入口鉴权回跳通过。
- [ ] 注册、重启恢复和退出闭环通过。
- [ ] 并发 `40101` 只发起一次刷新并轮转双 Token。
- [ ] 撤销、锁定、注销和未验证邮箱进入正确状态。
- [ ] 密码重置、改密、改邮箱、终端查看与撤销可操作。

## 12. 已知限制和后续功能

当前仅完成账号/密码登录与创建入口回跳；注册、找回密码、退出、邮箱/密码/终端管理和注销仍待后续切片。不做第三方登录、生物识别登录和多账号切换；破坏性注销只用一次性测试账号验收。

## 13. 最近审查的契约版本和后端提交

契约 `3.0.0-dev.20260807.2`；Markdown v2；后端 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`。

## 14. 相关代码与架构文档

代码入口：`lib/features/auth/`。参见[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

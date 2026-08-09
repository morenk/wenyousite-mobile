# 认证与账号生命周期

状态：`in_progress`

## 1. 模块目标与非目标

实现注册、登录、邮箱验证、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销。当前已交付邮箱验证码注册、账号/密码登录、双 Token 安全落库、鉴权回跳、并发刷新、活跃终端管理与当前终端退出；V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页 `/auth/login` 可从“我的”或受保护动作进入，并通过 `returnTo` 保存仓库内目标；注册页 `/auth/register` 从登录页进入并继承同一安全目标。创建主题入口登录或注册成功后恢复 `/compose/thread`；“我的”通过受保护的 `/me/security/sessions` 进入登录终端管理。

## 4. 用户操作流程

注册第一步调用 `authRequestCode` 发送邮箱验证码，使用固定 60 秒重发冷却和响应中的有效期；429 按 `Retry-After` 禁用重试。第二步本地校验 6 位验证码、2–24 位用户名及 8–100 位字母数字密码，调用 `authVerifyAndComplete` 并显式发送 mobile 头，只有同时返回 access/refresh token 才建立会话并恢复目标。

登录表单校验账号与密码，防止重复提交；`authLogin` 显式发送 mobile 头，响应必须同时含 access/refresh token 才原子保存并恢复目标。并发 `40101` 共享一次 `authRefresh`，双 Token 原子轮转后原请求只重放一次；再次过期进入失效登录页。登录终端页调用 `authListSessions`，当前终端不可远程撤销，其他终端确认后调用 `authRevokeSession`。用户从“我的”确认退出后调用 `authLogout` 撤销当前 refresh token，Access Token 已过期时先刷新再重试一次。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authVerifyEmail`、`authResendVerification`、`authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`UserSessionResponseDto`、`SessionResponseDto`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated；`LoginState` 与 `LogoutState` 均为 idle、submitting、failed。`RegistrationState` 额外区分 email/verify 步骤、验证码请求/注册提交操作、有效期和重发剩余秒数。认证仓储完成 `RequestCodeDto`、`VerifyAndCompleteDto`、`LoginDto` 与双 Token 映射，独立会话远端通过生成客户端处理 `RefreshDto`、`LogoutDto`，`SessionController` 串行发布安全存储与路由状态。终端管理使用 settings 的 loading/ready/failed 状态和唯一在途撤销 ID，成功后按稳定终端 ID 原地移除。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift、SharedPreferences 或持久化注册状态；返回修改邮箱会清空验证码和密码输入。终端页只消费稳定 ID、平台、是否当前及时间字段，不读取已废弃的原始设备标识。`40103` 至 `40106`、刷新失败或重放仍为 `40101` 时清会话；`40107` 进入邮箱验证状态。退出请求显式发送当前 access/refresh token，但日志不记录其内容。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。登录和刷新成功先完成安全存储写入再发布 authenticated 状态；服务端确认退出或明确返回会话失效后删除。瞬时退出失败保留会话供重试；用户明确二次确认“仅清除本机登录”时允许本地删除，并提示稍后检查服务端终端。本人资料仅存在于 users 的当前 autoDispose 页面状态，不写入 Token 存储或持久化缓存。

## 9. 加载、空数据、错误、重试和冲突状态

注册、登录、当前终端退出与其他终端撤销均防重复提交；`40110` 使用稳定的“账号或密码错误”提示，`40111`～`40114`、`40901`、`40902` 分别显示验证码和账号占用专用提示。验证码请求成功后 60 秒内不可重发；`42900` 显示稳定限流提示，验证码场景再按 `Retry-After` 倒计时。终端读取和撤销失败均保留请求 ID，撤销失败不移除条目；当前终端退出失败保留认证状态并允许重试，仅本机退出需要单独风险确认。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)与[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。登录和注册复用面板、区块标题、状态提示和异步主按钮，业务页不得复制表单错误卡片或提交加载样式。

## 11. 测试场景与验收条件

- [x] 账号/密码登录显式发送 mobile 头，双 Token 原子写入，创建入口鉴权回跳通过。
- [x] 重启恢复和当前终端服务端退出闭环通过，失败可重试或明确选择本机退出。
- [x] 并发 `40101` 只发起一次刷新并轮转双 Token，原请求最多重放一次。
- [x] 邮箱验证码注册显式发送 mobile 头，双 Token 原子写入并恢复受保护目标。
- [x] 登录、注册在 360、400、600dp 宽度无溢出，保留 Widget Key、无障碍错误语义和 48dp 主操作。
- [ ] 撤销、锁定、注销和未验证邮箱进入正确状态。
- [x] 终端查看、隐私降级、当前终端保护、其他终端确认撤销和失败恢复可操作。
- [ ] 密码重置、改密和改邮箱可操作。

## 12. 已知限制和后续功能

当前完成邮箱验证码注册、账号/密码登录、创建入口回跳、会话恢复/刷新、活跃终端管理及当前终端退出，并将登录、注册和终端页接入 Foundation 主题与共享组件；找回密码、邮箱/密码修改和注销仍待后续切片。验证码有效期由服务端响应展示，应用退出或页面销毁后不持久化注册进度。仅本机退出无法确认服务端 refresh token 已撤销，后续登录后应通过终端管理检查。不做第三方登录、生物识别登录和多账号切换；破坏性注销只用一次性测试账号验收。

## 13. 最近审查的契约版本和后端提交

契约 `4.4.0-dev.20260809.1`；Markdown v2；后端 `0fb9d351e4344b0bdb347e5530278f02fd0a7418`。

## 14. 相关代码与架构文档

代码入口：`lib/features/auth/`、`lib/core/network/session_remote.dart`；终端管理位于 `lib/features/settings/`。参见[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)、[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

# 认证与账号生命周期

移动端刷新会话显式携带 `X-Client-Platform: mobile` 并消费轮换后的双 Token；网络或服务暂时不可用时保留本地会话，只有明确的 401 会话失效响应才要求重新登录。

状态：`in_progress`

## 1. 模块目标与非目标

实现注册、登录、邮箱验证、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销。当前已交付邮箱验证码注册、登录后邮箱验证、账号/密码登录、找回与重置密码、双 Token 安全落库、鉴权回跳、并发刷新、改密、换邮箱、活跃终端管理、当前终端退出与账号注销；V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页 `/auth/login` 可从“我的”或受保护动作进入，并通过 `returnTo` 保存仓库内目标；注册页 `/auth/register` 与找回页 `/auth/forgot-password` 从登录页进入并继承同一安全目标。找回页发送验证码后替换为 `/auth/reset-password`，邮箱仅通过内存路由数据传递，重置页也可独立进入并重新发送验证码。创建主题入口登录或注册成功后恢复 `/compose/thread`；重置成功只返回登录并继续保留原目标。“我的”通过受保护的 `/me/security/sessions`、`/me/security/password`、`/me/security/email`、`/me/security/verify-email` 与 `/me/security/delete-account` 分别进入终端管理、修改密码、更换邮箱、验证当前邮箱和账号注销。创建主题页遇到未验证事实或 `40107` 时先强制保存本地快照，再进入验证页；完成后返回并刷新发布资格。注销成功后统一进入 `/home` 游客态，不保留返回破坏性表单的目标。

## 4. 用户操作流程

注册第一步调用 `authRequestCode` 发送邮箱验证码，使用固定 60 秒重发冷却和响应中的有效期；429 按 `Retry-After` 禁用重试。第二步本地校验 6 位验证码、2–24 位用户名及 8–100 位字母数字密码，调用 `authVerifyAndComplete` 并显式发送 mobile 头，只有同时返回 access/refresh token 才建立会话并恢复目标。

登录表单校验账号与密码，防止重复提交；`authLogin` 显式发送 mobile 头，响应必须同时含 access/refresh token 才原子保存并恢复目标。并发 `40101` 共享一次 `authRefresh`，双 Token 原子轮转后原请求只重放一次；再次过期进入失效登录页。

忘记密码先规范化邮箱并调用 `authForgotPassword`，无论邮箱是否注册都只展示相同的安全提示；成功后进入重置页并开始固定 60 秒重发冷却，429 再按 `Retry-After` 延长。重置页本地校验邮箱、6 位数字验证码和 8–100 位字母数字密码，调用 `authResetPassword`；后端确认后所有 refresh 会话均被撤销，客户端不建立会话，只返回登录页提示使用新密码。失效会话可进入找回和重置公开路由，不会被守卫循环送回登录。

登录后邮箱验证页先调用 `usersGetMe` 读取当前邮箱与 `emailVerified`，不会相信页面参数。用户明确点击后才用当前邮箱调用公开的 `authResendVerification`；未知账号和已验证账号沿用后端同一反枚举响应，客户端只展示相同提示并执行固定 60 秒或 `Retry-After` 冷却。输入 6 位数字验证码后调用需鉴权的 `authVerifyEmail`，成功不刷新 Token，而是再次读取本人资料；仅确认 `emailVerified=true` 后才恢复原操作。

修改密码调用 `authChangePassword`；更换邮箱先调用 `authRequestChangeEmailCode`，再用 6 位验证码调用 `authVerifyChangeEmail`。两类凭据变更成功后后端都会撤销全部 refresh 会话，移动端随即原子清除本机双 Token 并进入带 `/me` 回跳的登录页。登录终端页调用 `authListSessions`，当前终端不可远程撤销，其他终端确认后调用 `authRevokeSession`。用户从“我的”确认退出后调用 `authLogout` 撤销当前 refresh token，Access Token 已过期时先刷新再重试一次。

账号注销页先明确告知不可恢复、所有终端失效、身份字段移除、已发布内容以“已注销用户”匿名保留，以及本地未发布草稿不会自动上传或删除且注销后无法由原账号恢复。用户必须输入固定短语“注销账号”并通过第二次破坏性确认，才调用 `usersDeleteMe`。后端确认后移动端只执行本机双 Token 清理并回到首页；若安全存储清理失败，状态机只允许重试本地清理，绝不再次调用注销端点。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authVerifyEmail`、`authResendVerification`、`authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- `usersDeleteMe`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`ForgotPasswordDto`、`ResetPasswordDto`、`MessageResponseDto`、`UserSessionResponseDto`、`SessionResponseDto`、`UsersDeleteMe200Response`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated；`LoginState` 与 `LogoutState` 均为 idle、submitting、failed。`RegistrationState` 额外区分 email/verify 步骤、验证码请求/注册提交操作、有效期和重发剩余秒数。`PasswordRecoveryState` 保存唯一在途动作、最近请求邮箱、重发秒数和安全错误；找回与重置页面复用同一个 autoDispose family，但不同路由种子不会共享密码或验证码。`EmailVerificationState` 分离本人事实加载、重发/验证唯一在途动作、冷却、请求 ID 和成功反馈；验证仓储同时映射 `usersGetMe`、`ResendVerificationDto` 与 `VerifyEmailDto`。认证仓储完成 `RequestCodeDto`、`VerifyAndCompleteDto`、`LoginDto` 与双 Token 映射，密码恢复仓储独立映射 `ForgotPasswordDto` 与 `ResetPasswordDto`；独立会话远端通过生成客户端处理 `RefreshDto`、`LogoutDto`，`SessionController` 串行发布安全存储与路由状态。终端管理使用 settings 的 loading/ready/failed 状态和唯一在途撤销 ID，成功后按稳定终端 ID 原地移除；改密使用 idle/submitting/failed，换邮箱状态额外保存 request/verify 步骤、当前动作、规范化目标邮箱和重发剩余秒数。`AccountDeletionState` 区分 idle、submitting、failed，并用 `remoteDeletionConfirmed` 固定远端已完成、本地待清理的单向边界。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift、SharedPreferences、查询参数或持久化认证状态；找回到重置只在内存路由数据中携带规范化邮箱，页面销毁即释放验证码和新密码。找回和验证邮箱重发成功文案必须保持反枚举，不根据邮箱是否存在或已验证做任何差异展示；验证页邮箱只来自鉴权后的本人资料并脱敏显示。离开换邮箱页会释放验证码、当前密码和目标邮箱，返回第一步会清空验证码。终端页只消费稳定 ID、平台、是否当前及时间字段，不读取已废弃的原始设备标识。`40103` 至 `40106`、刷新失败或重放仍为 `40101` 时清会话；`40107` 保留只读会话并引导邮箱验证，包括从注销页返回原目标。改密和换邮箱仅在后端确认成功后清本机会话；失败保留认证状态供用户修正。退出与注销请求都不记录凭据；注销页不持久化确认短语，也不承诺删除匿名保留的已发布内容或账号隔离的本地草稿。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。登录和刷新成功先完成安全存储写入再发布 authenticated 状态；服务端确认退出、凭据修改成功、账号注销或明确返回会话失效后删除。瞬时退出失败保留会话供重试；用户明确二次确认“仅清除本机登录”时允许本地删除，并提示稍后检查服务端终端。注销远端一旦成功即不可回滚，本地清理失败只重试安全存储与会话归一化，不重放 API。找回邮箱、验证码、新密码、邮箱验证冷却和本人账号安全表单仅存在于当前 autoDispose 页面状态，不写入 Token 存储或持久化缓存；应用终止后需重新进入流程。邮箱验证成功不撤销或改写现有 Token。

## 9. 加载、空数据、错误、重试和冲突状态

注册、登录、找回、重置、验证邮箱、改密、换邮箱、当前终端退出、其他终端撤销与账号注销均防重复提交；`40110` 使用稳定的“账号或密码错误”提示，`40116` 使用“当前密码不正确”，`40111`～`40114`、`40901`、`40902` 分别显示验证码和账号占用专用提示。验证码请求成功后 60 秒内不可重发；`42900` 显示稳定限流提示，验证码场景再按 `Retry-After` 倒计时。验证错误保留当前验证码供修正并展示请求 ID；验证响应缺少 `data` 或验证后本人资料仍未确认时不恢复发布资格。重置错误保留邮箱、验证码和新密码供当前页面修正，成功响应缺少 `data` 时不跳转登录、不伪装完成。终端读取和撤销失败均保留请求 ID，撤销失败不移除条目；任一凭据写入响应缺少必要 data 时不伪装成功。当前终端退出失败保留认证状态并允许重试，仅本机退出需要单独风险确认。注销失败保留确认短语、会话和请求 ID；`40107` 提供先验证邮箱入口。远端已注销但本地清理失败时只显示本机清理重试，不允许重新确认远端操作。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)与[Foundation v1.2.1 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.2.1/docs/platforms/mobile.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。登录和注册复用面板、区块标题、状态提示和异步主按钮，业务页不得复制表单错误卡片或提交加载样式。

## 11. 测试场景与验收条件

- [x] 账号/密码登录显式发送 mobile 头，双 Token 原子写入，创建入口鉴权回跳通过。
- [x] 重启恢复和当前终端服务端退出闭环通过，失败可重试或明确选择本机退出。
- [x] 并发 `40101` 只发起一次刷新并轮转双 Token，原请求最多重放一次。
- [x] 邮箱验证码注册显式发送 mobile 头，双 Token 原子写入并恢复受保护目标。
- [x] 登录、注册在 360、400、600dp 宽度无溢出，保留 Widget Key、无障碍错误语义和 48dp 主操作。
- [x] `40107` 保留只读会话，验证入口、反枚举重发、专用错误、服务端事实刷新和原目标恢复正确。
- [ ] 撤销与锁定进入正确状态。
- [x] 注销要求固定短语和二次确认，远端成功后清除本机双 Token，局部清理失败不会重放破坏性端点。
- [x] 终端查看、隐私降级、当前终端保护、其他终端确认撤销和失败恢复可操作。
- [x] 改密和改邮箱可操作，失败保留会话与请求 ID，成功后清除本机双 Token 并要求重新登录。
- [x] 找回及重置密码可操作，反枚举、重发冷却、错误恢复、全端退出提示及原目标回跳均固定。

## 12. 已知限制和后续功能

当前完成邮箱验证码注册、登录后邮箱验证、账号/密码登录、找回/重置密码、创建入口回跳、会话恢复/刷新、修改密码、更换邮箱、活跃终端管理、当前终端退出及账号注销，并将相关页面接入 Foundation 主题与共享组件。注册验证码有效期由服务端响应展示；验证当前邮箱按后端固定 15 分钟说明，忘记密码端点不返回有效期，客户端不猜测倒计时。应用退出或页面销毁后不持久化注册、验证、找回、换绑及注销确认进度。仅本机退出无法确认服务端 refresh token 已撤销，后续登录后应通过终端管理检查。不做第三方登录、生物识别登录和多账号切换；破坏性注销的端到端真机验收只允许使用一次性测试账号。

## 13. 最近审查的契约版本和后端提交

契约 `4.7.0-dev.20260811.1`；Markdown v2；后端 `143618951b0746b049f9d6ac9718b35e4139847d`。

## 14. 相关代码与架构文档

代码入口：`lib/features/auth/`、`lib/core/network/session_remote.dart`；登录后验证由 `email_verification_*` 仓储、状态机和页面承载，找回/重置由 `password_recovery_*` 承载，终端管理与注销由 `lib/features/settings/` 下的 `account_deletion_*` 等切片承载。参见[Foundation v1.2.1 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.2.1/docs/platforms/mobile.md)、[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

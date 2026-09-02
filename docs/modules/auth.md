# 认证与账号生命周期

移动端刷新会话显式携带 `X-Client-Platform: mobile` 并消费轮换后的双 Token；网络或服务暂时不可用时保留本地会话，只有明确的 401 会话失效响应才要求重新登录。

状态：`in_progress`

## 1. 模块目标与非目标

实现注册、登录、双 Token 轮转、找回/修改密码、改邮箱、会话管理、退出和注销，并为被暂停/封禁账号提供不依赖普通会话的申诉入口。当前注册在创建用户之前完成邮箱验证码校验，不再存在“已注册但邮箱未验证”的账号状态；已交付账号/密码登录、找回与重置密码、双 Token 安全落库、鉴权回跳、并发刷新、改密、换邮箱、活跃终端管理、当前终端退出与账号注销；V1 不接入第三方登录。

## 2. 用户角色与使用场景

游客注册或登录；已登录用户管理安全信息与终端会话；被锁定、注销或 Token 撤销的用户安全退出本地会话。

## 3. 页面、入口和导航关系

登录页 `/auth/login` 可从“我的”或受保护动作进入，并通过 `returnTo` 保存仓库内目标；注册页 `/auth/register` 与找回页 `/auth/forgot-password` 从登录页进入并继承同一安全目标。找回页发送验证码后替换为 `/auth/reset-password`，邮箱仅通过内存路由数据传递，重置页也可独立进入并重新发送验证码。创建主题入口登录或注册成功后恢复 `/compose/thread`；重置成功只返回登录并继续保留原目标。“我的”通过受保护的 `/me/security/sessions`、`/me/security/password`、`/me/security/email` 与 `/me/security/delete-account` 分别进入终端管理、修改密码、更换邮箱和账号注销。注销成功后统一进入 `/home` 游客态，不保留返回破坏性表单的目标。

登录页还常驻公开 `/appeals` 入口，使收到 `40108/40109` 的账号不需要先建立普通会话即可查看治理决定并申诉；登录与注册面板顶部统一显示 Foundation 48dp 装饰标识及相邻可见“温油站”名称，找回、重置和账号错误页不重复堆叠品牌。申诉页面的账号密码和专用凭据由 moderation 独立管理。

## 4. 用户操作流程

注册第一步调用 `authRequestCode` 发送邮箱验证码，使用固定 60 秒重发冷却和明确成功响应中的有效期。发码不自动重放；超时、断线、429 或 5xx 造成结果不明时，直接进入验证步骤并显示“邮件可能已发出”、60 秒冷却和请求 ID，不猜测有效期。第二步本地校验 6 位验证码、2–24 位用户名及 8–100 位字母数字密码，调用 `authVerifyAndComplete` 并显式发送 mobile 头，只有同时返回 access/refresh token 才建立会话并恢复目标。

登录表单校验账号与密码，防止重复提交；`authLogin` 显式发送 mobile 头，响应必须同时含 access/refresh token 才原子保存并恢复目标。并发 `40101` 共享一次 `authRefresh`，双 Token 原子轮转后原请求只重放一次；再次过期进入失效登录页。

忘记密码先规范化邮箱并调用 `authForgotPassword`，无论邮箱是否注册都只展示相同的安全提示；明确成功或发码结果不明都进入重置页并开始固定 60 秒重发冷却，后者保留请求 ID 并使用中性“可能已发出”文案。重置页默认以脱敏摘要展示刚发送的邮箱，并提供“修改邮箱”和紧凑重发入口；只有明确成功或结果不明时才收起邮箱编辑，明确失败继续保留当前编辑字段，且不会把旧邮箱的投递成功状态误显示给新邮箱。页面本地校验邮箱、6 位数字验证码和 8–100 位字母数字密码，调用 `authResetPassword`；后端确认后所有 refresh 会话均被撤销，客户端不建立会话，只返回登录页提示使用新密码。失效会话可进入找回和重置公开路由，不会被守卫循环送回登录。

修改密码调用 `authChangePassword`；更换邮箱先调用 `authRequestChangeEmailCode`，再用 6 位验证码调用 `authVerifyChangeEmail`。两类凭据变更成功后后端都会撤销全部 refresh 会话，移动端随即原子清除本机双 Token 并进入带 `/me` 回跳的登录页。登录终端页调用 `authListSessions`，当前终端不可远程撤销，其他终端确认后调用 `authRevokeSession`。用户从“我的”确认退出后调用 `authLogout` 撤销当前 refresh token，Access Token 已过期时先刷新再重试一次。

账号注销页先明确告知不可恢复、所有终端失效、身份字段移除、已发布内容以“已注销用户”匿名保留，以及本地未发布草稿不会自动上传或删除且注销后无法由原账号恢复。用户必须输入固定短语“注销账号”并通过第二次破坏性确认，才调用 `usersDeleteMe`。后端确认后移动端只执行本机双 Token 清理并回到首页；若安全存储清理失败，状态机只允许重试本地清理，绝不再次调用注销端点。

## 5. API operationId 与生成类型

- `authRequestCode`、`authVerifyAndComplete`、`authLogin`、`authRefresh`。
- `authChangePassword`、`authForgotPassword`、`authResetPassword`。
- `authRequestChangeEmailCode`、`authVerifyChangeEmail`、`authLogout`、`authListSessions`、`authRevokeSession`。
- `usersDeleteMe`。
- 主要生成类型：`AuthResponseDto`、`LoginDto`、`RefreshDto`、`ForgotPasswordDto`、`ResetPasswordDto`、`MessageResponseDto`、`UserSessionResponseDto`、`SessionResponseDto`、`UsersDeleteMe200Response`。

## 6. 状态模型和数据流

`SessionState` 为 guest、restoring、authenticated、invalidated；`LoginState` 与 `LogoutState` 均为 idle、submitting、failed。`RegistrationState` 区分 email/verify 步骤、验证码请求/注册提交操作、有效期和重发剩余秒数；只有 `authVerifyAndComplete` 同时完成验证码校验、创建用户并返回双 Token 后才建立注册用户会话。`PasswordRecoveryState` 保存唯一在途动作、最近请求邮箱、重发秒数和安全错误；找回与重置页面复用同一个 autoDispose family，但不同路由种子不会共享密码或验证码。登录/注册和密码恢复控制器只依赖 `auth/application` 端口，`main.dart` 组合根绑定 API data 适配器；适配器映射 `RequestCodeDto`、`VerifyAndCompleteDto`、`LoginDto`、`ForgotPasswordDto` 与 `ResetPasswordDto`。独立会话远端通过生成客户端处理 `RefreshDto`、`LogoutDto`，`SessionController` 串行发布安全存储与路由状态。终端管理使用 settings 的 loading/ready/failed 状态和唯一在途撤销 ID，成功后按稳定终端 ID 原地移除；改密使用 idle/submitting/failed，换邮箱状态额外保存 request/verify 步骤、当前动作、规范化目标邮箱和重发剩余秒数。`AccountDeletionState` 区分 idle、submitting、failed，并用 `remoteDeletionConfirmed` 固定远端已完成、本地待清理的单向边界。

## 7. 鉴权、权限和隐私规则

密码、验证码和双 Token 不进入日志、Drift、SharedPreferences、查询参数或持久化认证状态；找回到重置只在内存路由数据中携带规范化邮箱，页面销毁即释放验证码和新密码。注册和找回发码成功文案保持反枚举，不根据邮箱是否存在做差异展示。离开换邮箱页会释放验证码、当前密码和目标邮箱，返回第一步会清空验证码。终端页只消费稳定 ID、平台、是否当前及时间字段，不读取已废弃的原始设备标识。`40103` 至 `40106`、刷新失败或重放仍为 `40101` 时清会话；契约 4.14 已移除 `EMAIL_NOT_VERIFIED`，任何已登录注册用户都不再因邮箱状态进入只读会话。改密和换邮箱仅在后端确认成功后清本机会话；失败保留认证状态供用户修正。退出与注销请求都不记录凭据；注销页不持久化确认短语，也不承诺删除匿名保留的已发布内容或账号隔离的本地草稿。

`40108/40109` 不伪装登录成功，登录页明确引导到 moderation 的专用申诉通道；`40120` 属于申诉凭据而非普通会话，只能由 moderation 清除该临时凭据。

## 8. 本地存储、缓存及失效规则

双 Token 仅进安全存储；Access Token 可在内存缓存。登录和刷新成功先完成安全存储写入再发布 authenticated 状态；服务端确认退出、凭据修改成功、账号注销或明确返回会话失效后删除。瞬时退出失败保留会话供重试；用户明确二次确认“仅清除本机登录”时允许本地删除，并提示稍后检查服务端终端。注销远端一旦成功即不可回滚，本地清理失败只重试安全存储与会话归一化，不重放 API。注册、找回邮箱、验证码、新密码和本人账号安全表单仅存在于当前 autoDispose 页面状态，不写入 Token 存储或持久化缓存；应用终止后需重新进入流程。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

注册、登录、找回、重置、改密、换邮箱、当前终端退出、其他终端撤销与账号注销均防重复提交；`40110` 使用稳定的“账号或密码错误”提示，`40116` 使用“当前密码不正确”，`40111`～`40114`、`40901`、`40902` 分别显示验证码和账号占用专用提示。验证码请求成功后 60 秒内不可重发；`42900` 显示稳定限流提示，验证码场景再按 `Retry-After` 倒计时。注册或重置错误保留当前输入供修正并展示请求 ID；成功响应缺少必要 `data` 时不建立会话或跳转，不伪装完成。终端读取和撤销失败均保留请求 ID，撤销失败不移除条目；任一凭据写入响应缺少必要 data 时不伪装成功。当前终端退出失败保留认证状态并允许重试，仅本机退出需要单独风险确认。注销失败保留确认短语、会话和请求 ID；远端已注销但本地清理失败时只显示本机清理重试，不允许重新确认远端操作。

## 10. 跨模块约束

遵循[网络与会话](../architecture/networking.md)与[Foundation v6.5.1 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.5.1/docs/platforms/mobile.md)；所有受保护模块通过统一鉴权回跳，不自行读取 Token。登录、注册、找回与账号安全表单复用验证码字段、凭据校验策略、状态提示和异步主按钮，业务页不得复制输入约束、错误卡片或提交加载样式。

## 11. 测试场景与验收条件

- [x] 账号/密码登录显式发送 mobile 头，双 Token 原子写入，创建入口鉴权回跳通过。
- [x] 重启恢复和当前终端服务端退出闭环通过，失败可重试或明确选择本机退出。
- [x] 并发 `40101` 只发起一次刷新并轮转双 Token，原请求最多重放一次。
- [x] 邮箱验证码注册显式发送 mobile 头，双 Token 原子写入并恢复受保护目标。
- [x] 登录、注册、找回与重置在 320、360、400、600dp 宽度无溢出，输入框语义图标保持默认 20dp 并在 48dp 前缀区域居中，同时保留 Widget Key、无障碍错误语义和 48dp 主操作。
- [x] 登录与注册复用 Foundation 48dp 装饰品牌标识和可见名称，TalkBack 不重复朗读标识。
- [x] 契约 4.14 移除 `emailVerified`、登录后验证端点和 `EMAIL_NOT_VERIFIED` 分支；注册完成后直接按统一注册用户身份恢复原目标。
- [ ] 撤销与锁定进入正确状态。
- [x] 注销要求固定短语和二次确认，远端成功后清除本机双 Token，局部清理失败不会重放破坏性端点。
- [x] 终端查看、隐私降级、当前终端保护、其他终端确认撤销和失败恢复可操作。
- [x] 改密和改邮箱可操作，失败保留会话与请求 ID，成功后清除本机双 Token 并要求重新登录。
- [x] 找回及重置密码可操作，反枚举、脱敏邮箱摘要、修改邮箱、重发冷却、明确失败保留编辑态、错误恢复、全端退出提示及原目标回跳均固定。

- [x] 登录页对暂停/封禁账号提供公开申诉入口，`40108/40109` 与 `40120` 使用稳定且不混淆普通会话的提示。

## 12. 已知限制和后续功能

当前完成邮箱验证码注册、账号/密码登录、找回/重置密码、创建入口回跳、会话恢复/刷新、修改密码、更换邮箱、活跃终端管理、当前终端退出及账号注销，并将相关页面接入 Foundation 主题与共享组件。注册验证码有效期由服务端响应展示；忘记密码端点不返回有效期，客户端不猜测倒计时。应用退出或页面销毁后不持久化注册、找回、换绑及注销确认进度。仅本机退出无法确认服务端 refresh token 已撤销，后续登录后应通过终端管理检查。不做第三方登录、生物识别登录和多账号切换；破坏性注销的端到端真机验收只允许使用一次性测试账号。

## 13. 最近审查的契约版本和后端提交

契约 `5.15.0-dev.20260902.1`；Markdown v4；后端 `3f1cbd297f832803661078b1c5193c02a89167f4`；Foundation `v6.5.1`（`a9318b8`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/auth/application/auth_ports.dart`、`lib/features/auth/data/`、`lib/features/auth/presentation/auth_brand_header.dart`、`lib/main.dart`、`lib/core/network/session_remote.dart`；找回/重置由 `password_recovery_*` 承载，终端管理与注销由 `lib/features/settings/` 下的 `account_deletion_*` 等切片承载。参见[Foundation v6.5.1 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.5.1/docs/platforms/mobile.md)、[语义图标](../architecture/icons.md)、[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)。

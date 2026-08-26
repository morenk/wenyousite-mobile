# 温油钱包

状态：`in_progress`

## 1. 模块目标与非目标

实现登录用户的温油余额、累计收到加油、北京时间每日签到、收支流水，以及对用户、主题和公开动态的加油闭环。金额始终保留后端十进制整数字符串，不转为浮点数。本模块不提供充值、提现、用户间转账、平台账务管理或管理员流水。

## 2. 用户角色与使用场景

游客可在公开用户、主题和动态详情看到加油入口，点击后先登录并返回原目标；登录用户每天进入应用时自动签到一次，可在“我的温油”查看余额与收支，也可向非本人的可访问目标投入温油。流水按服务端投影分别保留投入金额与实际到账金额，客户端不自行计算。

## 3. 页面、入口和导航关系

“我的”资料卡把“温油”与“关注 / 粉丝 / 收藏”作为同级等宽入口，显示当前余额并通过受保护的 `/me/wallet` 进入钱包页；不单独增加余额说明条，也不会显示用户资料中的累计收到加油。页面流水中的主题、用户和动态目标分别回到 `/threads/:threadId`、`/users/:userId` 与 `/moments/:momentId`；签到流水没有目标跳转。公开用户、主题和动态详情在顶栏提供加油图标，自我目标隐藏。游客点击加油时使用当前稳定路径进入 `/auth/login?returnTo=...`。

## 4. 用户操作流程

登录会话恢复或新登录完成后，全局签到引导在本次进程内对当前会话调用一次签到端点；只有服务端返回 `claimedNow=true` 才提示本次获得的 1～3 升温油和经验，重复调用由北京时间日期键幂等。钱包页并发读取余额统计和流水，两部分独立失败、独立重试；下拉刷新重新读取两部分，流水按服务端不透明 cursor 加载更多。

加油弹窗默认 2 升，只接受不小于 2 且不超过 PostgreSQL bigint 上限的十进制正整数字符串。一次用户操作生成 UUID v4；网络或不明确失败后，以相同金额重试会复用原 `clientRequestId`，修改金额或成功后的下一次操作才生成新 ID。提交在途时禁用字段与按钮，并阻止 Android 系统返回关闭弹窗；只有结果明确后才恢复退出能力。成功只确认本次加油金额，不在弹窗或成功提示中解释抽成与到账；随后刷新付款人钱包、收款人公开统计及当前主题/动态详情。

## 5. API operationId 与生成类型

- 钱包与签到：`economyGetWallet`、`economyCheckIn`，使用 `WalletResponseDto`、`DailyCheckInResponseDto` 与 `ProgressionResponseDto`。
- 流水：`economyTransactions`，使用 `WalletTransactionResponseDto`、`WalletTransactionTargetResponseDto`、`PostAuthorResponseDto` 与 `ApiPaginationMeta`。
- 三类加油：`economyTipUser`、`economyTipThread`、`economyTipMoment`，使用 `TipRequestDto` 与 `TipResponseDto`。

## 6. 状态模型和数据流

`WalletController` 按当前会话 key 隔离余额、流水、首屏/刷新/分页和三类局部失败；“我的”温油统计和钱包详情观察同一实例的 `summary.balance`，余额加载或失败时显示占位而不回退累计收款。余额与流水并发加载，任一失败不会遮挡另一部分。`DailyCheckInController` 串行执行全局签到，启动组件按登录会话防止重复触发。`TipController` 按目标 family 隔离弹窗写入，保存待确认金额、稳定请求 ID、提交状态和失败详情。钱包仓储接口位于 `wallet/application`，`main.dart` 组合根绑定 data 适配器；data 边界应用钱包专属错误目录，把生成 DTO 映射为 feature 模型，并对金额、枚举、计数、目标、分页和安全头像 URL fail-closed。

## 7. 鉴权、权限和隐私规则

六个端点均要求登录；签到和加油写入还受后端写权限、频率和邮箱策略约束。客户端只用服务端详情中的本人标记隐藏自我目标，不自行授权可访问性；后端最终复核自我加油、拉黑关系、私密主题成员、已发布状态及公开动态。钱包、流水、付款后余额和请求 ID 不写日志。游客只看到入口，不会预读私有钱包；登录回跳不接受外部或认证循环地址。

## 8. 本地存储、缓存及失效规则

钱包、签到结果、流水、cursor 和加油待确认请求只存在于当前 Riverpod/弹窗生命周期，不写 Drift、SharedPreferences 或文件。退出、切号或会话失效后释放旧状态。签到成功失效本人资料、钱包和本人公开资料；加油成功失效钱包、目标用户资料及当前详情。提交在途时弹窗不能关闭，避免释放仍需确认的幂等状态；关闭已经明确失败的弹窗表示用户放弃该操作，重新打开会创建新的用户操作与请求 ID。

## 9. 加载、空数据、错误、重试和冲突状态

余额和流水分别覆盖加载、空、首屏失败、已加载后刷新失败、分页失败和请求 ID。`40007` 丢弃失效 cursor 并回到流水第一页。`40008` 提示整数与最低金额，`40307` 提示自我或互动限制，`40912` 要求废弃冲突幂等键并重新发起，`40913` 提示余额不足，`42900` 使用统一频率提示。加油空响应视为结果不明确并保留原请求重试；页面不根据本机 85% 计算伪造到账金额。

## 10. 跨模块约束

流水对手方具名头像缺图或加载失败时显示用户名首个可读字符；没有可用对手方身份时保留中性用户图标。

app-shell 只负责会话就绪后的签到触发与非阻断提示；wallet 通过 app 组合层的 `ProfileCacheInvalidator` 发布失效意图，不直接导入 users provider。users、threads 和 moments 只挂载目标入口并在成功后重读自身服务端投影。钱包流水目标导航复用这些模块的稳定路由。所有 UI 只消费 Foundation v6.3.0 Token、语义图标、全局主题和共享面板；精确金额字符串是 Wallet 与动态/主题/用户累计加油的共同约束。

## 11. 测试场景与验收条件

- [x] 六个 Wallet operationId 的路径、生成 DTO、分页和三类目标载荷有仓储测试。
- [x] 超过 JavaScript 安全整数的余额仍精确展示，不发生浮点转换或科学计数法。
- [x] 签到只在本次实际领取时提示，重复 Widget 构建不重复调用。
- [x] 签到和用户加油通过组合层精确失效本人或收款人的资料缓存。
- [x] 同金额失败重试复用 UUID，改金额和成功后的下一次操作轮换 UUID。
- [x] 加油提交中系统返回不会关闭弹窗或产生第二次请求；在途成功仍返回结果，不明确失败后的同金额重试复用原 `clientRequestId`。
- [x] 金额、小数、前导零、bigint 溢出、未知枚举、重复流水和缺失 cursor 均 fail-closed。
- [x] 余额/流水局部失败、分页、`40007` 恢复、三类业务错误和空响应有自动测试。
- [x] 钱包页在 360dp、400dp、600dp 展示长金额和流水无横向溢出。
- [x] “我的”温油统计与钱包详情共享余额事实；`receivedTipTotal` 与余额不同时仍只展示 `summary.balance`。
- [ ] 公网专用账号完成签到、三类加油、余额变化、实际到账和流水目标真机联调。

## 12. 已知限制和后续功能

当前不显示签到日历或连续签到，不提供手动补签。钱包只展示当前服务端支持的 `DAILY_CHECK_IN` 与 `TIP` 流水；新增流水类型会 fail-closed 并要求升级。签到短暂失败不会阻断启动，也不会在同一会话内后台循环重试；用户可重新登录或下次启动再次触发。正式晋级前仍需完成公网专用账号真机验收。

## 13. 最近审查的契约版本和后端提交

契约 `5.13.0-dev.20260826.1`；后端 `011eaf46954e204d492f3e17d887026fb4cf32d9`；Foundation `v6.3.0`（`73ed49e`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/wallet/application/wallet_repository_ports.dart`、`lib/features/wallet/data/`、`lib/main.dart`。参见[应用壳](app-shell.md)、[用户](users.md)、[主题](threads.md)、[动态](moments.md)、[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[API 生成和覆盖审计](../architecture/api-generation.md)与[主题帖测试审计](../architecture/thread-detail-test-audit.md)。

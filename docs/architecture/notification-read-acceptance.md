# 系统消息点击同步已读候选验收

状态：候选／待负责人验收，沿用 [PR #32](https://github.com/morenk/wenyousite-mobile/pull/32)，不合并或发布。

## 原始反馈与原因

负责人在上一候选上从通知栏或消息横幅点击后，可以进入对应消息界面，但通知中心对应条目没有标为已读。预期：点击该条系统通知视为打开该通知，通知中心和未读角标同步。源码证据：原 v1 点击载荷只含导航地址，不含站内通知 ID；处理器只刷新未读数再导航，没有调用 `notificationsSetReadStatus`。这不是后台消息未送达问题。

负责人另要求精简权限引导，只说明消息通知/悬浮通知，不说明系统提示音；声音配置本身不变。本轮安装按明确要求只执行 `adb install -r`，不追加包名、更新时间和 APK 哈希检查。

## 实现与兼容边界

- v1 JSON 增加成对的 notificationId/recipientId，来自通知 DTO 的 id/recipientUserId；严格校验类型及 ID 字符。旧无 ID 载荷仍可导航，但不从目标链接猜测通知条目。
- 点击立即交给现有路由鉴权，不等待读取计数或回执；登录恢复后核对接收账号，只调用对应条目的已读接口。错账号回消息中心且不写入；汇总不做全部已读；私聊仍由会话页处理。
- 新 application 服务不依赖通知列表已加载，合并同会话作用域/通知 ID 的在途请求；成功后重载缓存列表并保留原筛选、重读角标，失败保留真实状态和明确重试。请求完成、同步状态及重试都检查账号作用域。
- 冷启动等待认证恢复，未登录保留点击意图；迟到冷启动载荷不覆盖新点击。热通知事件主动请求一帧处理，避免页面静止时只登记帧尾回调而没有执行机会。
- 引导文案改为简短的开启消息通知/开启悬浮通知；设备级一次性记录、默认系统音、静音常驻及用户频道选择不变。

## 基线与验证

2026-09-13：Mobile origin/dev 仍为 e5eea0de；Backend 远端 dev、公网 /meta 和已记录来源均为 6fdfa00eaf1f3056ba30f2ffbc529d12eed1c823 / 5.22.0-dev.20260912.2，无接口契约变化。Foundation 只读缓存 fetch tags，继续锁定正式 v7.0.0；不升级依赖、不修改生成客户端。

针对性测试路径：

- `test/features/app_shell/background_notification_navigation_test.dart`
- `test/features/app_shell/background_online_poller_test.dart`
- `test/features/app_shell/background_online_reminders_test.dart`
- `test/features/app_shell/notification_permission_guidance_test.dart`
- `test/features/notifications/notification_controllers_test.dart`
- `test/features/notifications/notification_mutation_epoch_test.dart`

覆盖冷/热启动、通知中心缓存与角标、未加载列表、单条回执、重复点击、失败重试、未登录/错账号/在途切号、旧载荷/汇总/私聊以及精简文案。首轮热点击回归暴露帧尾调度/路由完成等待问题，已补主动请求渲染帧并等待路由解析；导航专项 7 项通过。最终相关回归、静态分析和 Debug 构建结果待补；不执行每轮全量测试，合并前再完成完整门禁。

## 负责人真机复验

1. 使用本候选中新收到的站内回复通知。先从顶部横幅点击进入对应内容，再返回通知中心，确认该条已读且角标更新，其他未读通知仍未读。
2. 再发一条，收起横幅后从通知栏点击，验证相同行为；分别覆盖应用在后台和进程冷启动。
3. 断网点击仍进入目标页；已读失败时出现重试入口，恢复网络重试成功后同步。不要把通知栏卡片自动消失当作服务端已读成功。
4. 私聊进入会话后的既有已读逻辑不变；汇总卡片只进入消息中心，不清空全部未读。旧候选已经发出的卡片不带 ID，仅保证原有跳转，需新消息验证本功能。
5. 权限引导只保留消息通知/悬浮通知的简短说明，不介绍系统提示音。已处理的一次性引导不会因更新文案而重新打扰。

尚未验证：上述真实设备操作，以及此前后台常驻候选仍待确认的 30 分钟/Doze 清单。安装成功不代替负责人验收。

## 本轮候选交付记录

- 构建源码提交：`5394c8d9495b185e1c307308299fed74f2014eb6`。后续提交仅补充追溯记录，不改变本轮 APK 对应源码。

- 上述六个测试文件共 48 项通过；最终保留筛选与回调格式调整后，导航专项 7 项再次通过。日志分别为 `build/notification-read-targeted-final.log`、`build/notification-read-navigation-final.log`。
- 全量应用静态分析发现一处回调 if 缺花括号的 lint，已修正；针对最终导航与已读服务文件的局部静态复查通过，No issues found，日志 `build/notification-read-analyze-final.log`。未重新运行全量测试。
- 最终 `flutter build apk --debug --no-pub` 成功，日志 `build/notification-read-build-final.log`。APK 位于 `D:\code\wenyousite\.worktrees\mobile-background-reminders\build\app\outputs\flutter-apk\app-debug.apk`；版本声明仍为 `0.7.0-dev.1+94`。
- 按负责人本轮明确要求，仅执行 `adb -s 4b9c39b5 install -r` 覆盖，返回 Success；未执行安装前后的包名、更新时间、设备 APK 哈希或签名检查，也未卸载、清除数据或修改系统权限。负责人应打开此前使用的“温油站 Debug”复验新收到的消息。
- 当前状态仍为候选／待负责人验收，完整门禁留在合并前。

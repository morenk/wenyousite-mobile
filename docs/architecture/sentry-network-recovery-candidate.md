# Sentry 后台网络恢复候选

状态：候选实现／官方完整门禁待通过／待负责人验收。关联 WENYOUSITE-MOBILE-14、W、2H；不关闭 Sentry 问题、不合并或部署、不安装真机。

本候选尚未满足 `AGENTS.md` 第 8 节“高风险候选使用 `npm run check:apk`，在同一次完整门禁成功后构建 Debug APK”的要求。现有首次失败、分项补检和独立 APK 构建均保留为证据，不能拼接宣称官方完整门禁通过。应用源码保持 `765778e4fbf2eeb2a1745560773628282b1eb66f`；等待独占工具槽后重新执行官方 `check:apk`，以实际退出 0 及同次 APK 结果更新状态。

## 事实与范围

- 用户确认 2026-10-14 14:00–17:00（北京时间）服务器厂商事故；按事件时间划分该窗口 83 条、恢复后 100 条，不关闭跨越窗口的整个 issue，不能从该窗口网络错误推断 Backend 缺陷。治理分析提供恢复后的 53 条后台 authRefresh 断网事件，仍需按新发布版本观察。
- Windows Mobile 基线 `d7168b61ea1b547e737585d2e9b250f1b3bd24e2`。治理任务只读核验固定后端 revision、公网 `/meta` 和 VPS `dev/origin/dev` 为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`；API `5.36.0-dev.20261005.1`，公网 Markdown v5；不修改契约、生成客户端、依赖或基础设施。
- 已证实的客户端行为：刷新已合并在途请求，但顺序失败后无冷却；后台读取每 30 秒继续发送。2H 的未知 HttpException 与长耗时尚未证明具体根因，Android 挂起可能计入耗时。

## 实现边界

- 当前进程内的会话持有共享恢复状态，后台协调器使用同一实例；进程重启后重新探测，不持久化冷却。确定的网络/5xx 采用 30、60、120、240、300 秒指数冷却，随机增加 0–10%，含抖动上限五分钟；原 30 秒定时器到期检查是否可工作，因此实际下一次探测还可能等待一个节拍。
- 只有显式自动请求意图受冷却门禁影响，普通前台操作与退出仍能立即尝试，先加入现有刷新 Future；成功才重置预算。同会话前台 GET/HEAD 的真实成功可解除已观察到的冷却，写入成功不重置预算，不新增业务写入重放。
- 前后台切换保留冷却；账号边界清空。票据使同一失败只计一次、旧成功不清除新失败、旧账号结果不污染新账号。保留原通知展示/提交去重和权限检查。
- 有效令牌下自动 GET/HEAD 的真实传输失败同样建立冷却；安全读取本轮失败后不再发网络重试，原始错误继续传给诊断，后续未发送的冷却拒绝不覆盖原始错误。普通前台安全读取仍沿用原有限重试策略。
- 前台定时未读组仅在所有启用分支明确成功时重置预算；Controller 跳过、在途、迟到和失败均返回非成功。单个健康端点不能清空其他失败分支的预算。
- 本轮自动意图仅接线后台提醒与应用壳未读初始化／定时刷新。私聊会话页的前台 2 秒追赶／8 秒增量轮询在后台原本会暂停，本轮未纳入共享冷却；上传和贴纸处理阶段轮询也不在本候选范围。
- 冷却拒绝是没有发请求的预期取消，不沿用旧 requestId 或异常，不进入诊断队列。无响应 Dio unknown + HttpException 纳入有界调度，但保留 unknown 来源、原因和原远程诊断，2H 现场仍待复验；普通 HttpException、契约解析、权限、存储和平台通知异常不计入网络冷却。

## 自动验证

- 旧实现回归（本次仅加测试，应用源码仍为上述基线）：执行 `flutter test -j 1 test/core/network/session_controller_test.dart test/features/app_shell/background_online_reminder_coordinator_test.dart`。`session_controller_test.dart` 的“瞬时刷新失败后连续自动请求不会再次调用刷新接口”连续五次自动 refresh 实际调用 5 次，期望 1；`background_online_reminder_coordinator_test.dart` 的“后台读取失败后跳过冷却期间节拍且前后台切换不解除冷却”失败后连续节拍实际 poll 2 次，期望 1。两条失败，其他 26 条通过；原始输出保留于本协作会话工具轨迹，当时未单独保存日志文件。这复现的是客户端无冷却行为，并不重建服务器事故现场。
- 新增注入覆盖 DNS/Socket、超时、502、失败递增/上限、成功重置、并行读取包装、手动提前尝试、singleflight、Token 保留、切号迟到结果、前后台切换、未知错误不归类、未发送拒绝无诊断、前台写入只发一次。
- 定向命令 `flutter test -j 1 test/core/network test/features/app_shell/background_online_reminder_coordinator_test.dart test/features/app_shell/background_online_reminders_test.dart test/features/app_shell/background_reminder_lifecycle_test.dart test/features/app_shell/background_reminder_runtime_test.dart`：114 项通过，退出 0。日志 `build/network-targeted.log` 的 SHA-256 为 `a152b72f896874ce4c7f8c362c64f82231c7be2a1b024840cdee476f1ec83604`。
- 完整入口 `npm run check:apk -- -TestConcurrency 1` 的首次运行退出 1：契约校验／再生成零差异、公网兼容性只读检查、全仓格式、应用与生成客户端分析、架构、模块文档和 API 覆盖均通过；全量 Flutter 为 6614 通过、1 项原有 Sentry 显式验收跳过、1 项文案静态检查失败。日志 `build/network-check-apk.log` 的 SHA-256 为 `7b544f777fda19553610024b9da84f89e2c68209a273e67e467d06c173b3aa8d`。
- 唯一失败是旧文案检查用 `ApiFailure\s*\(` 把新的无文案冷却取消也算作文案，粗计数由 418 变为 419。检查改用现有 analyzer 的 AST，覆盖普通／const／命名工厂／前缀调用和重定向的 `userMessage` 实参，排除声明、模式、注释和无文案错误；基线与本候选的实际文案调用均为 418，阈值不放宽。检查修正仅改测试，应用源码与上述全量行为回归一致；随后完成该静态检查、原入口未执行的 Windows 发布工具和独立 APK 构建。以下补检均为分项结果，不能替代尚待成功的官方 `check:apk`，也不将首次入口退出 1 写成退出 0。
- 检查修正独立提交 `2a5a9216348c80e9d3e41b3bf553da0f6d7fd786`。`flutter test --no-pub -j 1 test/user_facing_copy_test.dart`：6 项通过；两个变更测试文件的 `dart format --output=none --set-exit-if-changed` 与 `dart analyze --fatal-infos --fatal-warnings` 通过。最终定向日志 `build/network-copy-guard-final.log` 的 SHA-256 为 `b51b45b0ba85c7fc67fc2ce413d637b7e776139fa337ecae13413195e4e40907`。
- 补检 `npm run test:release-tool`：49 项通过、退出 0，日志 `build/network-release-tool.log`；使用本地隔离夹具，不执行真实发布。
- 补构建 `flutter build apk --debug --target-platform android-arm64`：退出 0，日志 `build/network-apk.log` 的 SHA-256 为 `58750f449653db020bab55ce4198648f9fc9c55a855baad10d9bfc846c1eebca`。产物 `build/app/outputs/flutter-apk/app-debug.apk` 为 110,352,442 字节，SHA-256 `c45262b748671ebaa626cb5673b782efdeace6696003486f4ac663f315331094`；`aapt dump badging` 核验包名 `site.wenyou.app.debug`、版本 `0.9.0-debug`／99、仅 `arm64-v8a`。构建使用默认 API `https://wenyou.site/api/v1`，该目标按线上保护；未安装、未启动应用，不能据本地构建声称数据隔离。
- 验收记录补齐后的 `npm run docs:check` 通过 23 个模块；生成客户端与锁文件均无差异。上述证据绑定应用源码 `765778e4fbf2eeb2a1745560773628282b1eb66f`，后续文档更正不改变应用源码及模块行为。
- 独立代码复核检查会话代次／票据、失败去重、旧成功不能清除新失败、singleflight、SafeRetry／noAutomaticReplay 和后台权限，未发现确定阻断；代码复核不代替真机验收。
- 所有故障注入使用内存 fake／Dio adapter，不连接线上、不写真实业务数据；没有运行写入 E2E，无新增隔离资源。

## 负责人真机清单

1. 在可核验的独立测试环境或负责人自行操作的设备上开启后台提醒，断网后留在后台，确认会话和草稿保留，读取逐步降频而非固定每次失败都再次续期。
2. 恢复网络，等待下一次可执行节拍，确认通知与私聊恢复读取；已有卡片不重复显示。实际后台调度受 Android/Doze 影响，不承诺精确秒数。
3. 冷却尚未结束时返回前台，明确重试读取、发帖或上传，确认可立即尝试；此前结果未确认的写入不得自动重发。
4. 在读取／续期在途时退出或切号，确认旧结果不会恢复旧账号或污染新账号；重新登录不继承前一账号冷却。
5. 对照新 release 的 Sentry 记录：维护窗口按事件时间独立归因，未知传输错误继续待核验；负责人通过后仍须记录候选 SHA 与验收结果。发布后 7 天观察仅作补充证据。

审批运行事实：Auto-review 默认偏好已传递，本宿主实际 `approval_policy=never`，没有受支持的配置入口可设为 `on-request/auto_review`；未宣称自动审查已生效。

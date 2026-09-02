# 应用壳

状态：`in_progress`

## 1. 模块目标与非目标

提供启动版本/兼容检查、全局亮色/黑夜主题、服务端 capability、Android 站内更新、iOS TestFlight 更新、四分支主导航、游客模式、全局网络/错误状态、统一发布入口、消息中心和 Android 后台尽力提醒。当前不实现 FCM 或 App Links；后台提醒只复用现有 HTTP API，不注册推送设备。

中央发布入口在所有主导航分支都显示“发布主题帖 / 发布动态”两个目标操作，不根据当前频道直接跳转，也不重复解释内容类型。

## 2. 用户角色与使用场景

游客可直接进入首页、搜索和外观设置；已登录用户额外使用通知、创作和个人功能。所有用户在启动时先恢复本机外观偏好，再确认当前构建仍受支持且服务端契约可兼容；推荐更新可以暂时跳过，强制更新不可绕过。

## 3. 页面、入口和导航关系

启动门禁包裹 `/home`、`/moments`、`/notifications`、`/me` 四个保状态分支，底栏固定为“首页 / 动态 / 发布 / 消息 / 我的”；中央粉色“发布”是动作而非分支，`/search` 由首页和动态顶栏进入，公开 `/appearance` 由游客“我的”和登录后的账号设置进入。系统启动层只承担 Flutter 第一帧之前不可避免的过渡，Android 与 iOS 均保持纯白底色，不显示标识或文案；从 Flutter 首帧开始使用已恢复或跟随系统解析后的主题，品牌加载页、系统状态栏和导航栏同步采用当前语义色。Android 冷启动的零尺寸预热帧只保留空白，拿到有效 viewport 后才构建品牌内容。四个分支与壳容器间瞬时切换并保留状态；Android 真实业务页入栈和返回由应用主题统一提供 180ms 水平位移，不缩放或淡化当前页。门禁先处理强制更新，再检查契约与 capability，最后处理推荐更新；Android 从 `/meta.mobileCompatibility` 的 HTTPS 地址在页内下载 RainS3 APK，验证后唤起系统安装器，iOS 外跳 TestFlight。任一主导航分支点击发布都会在按钮上方打开“发布主题帖 / 发布动态”两项锚点气泡，选择后进入受保护的 `/compose/thread` 或 `/compose/moment`；外部点击只关闭气泡，不触发底栏后方页面。入口统一朗读“发布内容”；游客登录或注册成功后恢复创建目标。登录用户的消息图标展示“通知未读 + 私聊未读/请求”的合计角标，进入分支与回前台时分别校准两类服务端事实；该角标使用 Foundation `destructive / onDestructive`，高 16dp、10sp 粗体等宽数字，超过 99 显示 `99+`，零值隐藏。消息中心的“通知 / 私聊”使用共享等宽内容页签，支持点按或在内容区左右滑动切换并通过规范 URL 保存栏目；横滑只作用于页面内部栏目，不切换底部主分支。

首页、动态与消息的相邻栏目内容统一按 Foundation standard 180ms 沿切换方向轻量入场，减少动态效果时瞬时完成；页签保持稳定，动态与消息按需构建并保留已访问栏目，避免切换时整页闪烁或重复读取。

手机 iOS 共享实现固定竖屏，iPad 保留系统多方向声明；当前只做应用名、相册用途文案、方向和本地化的静态兼容校验，不声称 iOS 签名或真机验收。

## 4. 用户操作流程

冷启动在创建应用根之前读取本地外观偏好；成功则直接使用保存模式，失败则首帧跟随系统并保留可重试提示。随后调用元信息接口并用 `versionCode` / `CFBundleVersion` 比较当前平台策略。低于最低构建时进入阻断页；低于推荐构建时可更新或“稍后再说”，同一目标构建只提示一次。版本允许后检查主契约 5 与 Markdown v3/v4、恢复会话并进入目标页。登录会话就绪后由 wallet 自动触发北京时间签到；应用保持前台时跨零点触发新日期检查，后台跨日则在首次恢复时补触发，只有本次真实领取才显示非阻断提示。回到前台时还会静默重查兼容信息，断网不打断正在使用的兼容客户端。Android 失去窗口焦点或进入后台时，Dart 与原生侧都把有效 IME 目标高度归零，不回退到可能仍残留键盘高度的引擎 inset；恢复或重新聚焦后先请求窗口重新应用 Insets，只以当前窗口焦点、Activity 生命周期和 IME 可见性共同确认的新高度避让页面。系统已经隐藏键盘时页面立即恢复完整高度，系统恢复键盘时仍保持输入区在键盘上方，不主动改变输入焦点、选区或未发送内容。

Android 登录会话固定开启后台尽力提醒，并在前台主动申请系统通知权限，不提供应用内开关。应用离开前台时先记录通知与私聊基线，再由仍存活且仍获系统调度的 Flutter 进程全程每 30 秒尽力检查，不创建前台服务或常驻运行通知。前一轮未完成时跳过当前节拍，不并发或排队；返回前台立即取消后台定时器并丢弃迟到结果，退出登录、任务被划掉或进程被系统回收后自然停止。系统通知权限或消息频道被关闭时不拉取消息，并在回到前台后明确提示到系统设置开启。

## 5. API operationId 与生成类型

- `metaGetMeta` → `MetaGetMeta200Response`、`ApiMetaResponseDto`、`MobileCompatibilityDto`、`MobilePlatformCompatibilityDto`。
- 后台在线提醒复用 `notificationsFindAll`、`notificationsUnreadCount`、`directConversationsUnread` 与按需 `directConversationsFindAll`，不新增服务端接口。

## 6. 状态模型和数据流

客户端兼容集合固定为 Markdown v3/v4；未知版本继续进入不可绕过的升级页。`AppCapabilities.markdownAlignment` 只在元信息明确声明 v4 时为真，主题与帖子只消费该纯 capability，不直接读取启动控制器；冷启动和回前台静默重查共用同一判定。

外观偏好状态包含当前选择、写入中、失败目标、读取失败和用户提示；应用根只观察当前选择并映射为 Flutter `ThemeMode.system/light/dark`，复用已缓存的亮/黑夜 `ThemeData`，在下一帧直接换主题而不创建根 `AnimatedTheme`，主题变化不进入业务控制器。启动状态为 checking、ready、recommendedUpdate、updateRequired、incompatible、failed；更新动作另有 idle、checking、downloading、verifying、installing、openingExternalPage、permissionRequired、installerOpened、externalPageOpened、failed。元信息映射为纯 `ContractInfo`，应用根通过 `AppCapabilities` 把 stickers、directMessages、pushNotifications 能力注入业务入口；入口默认关闭并只在服务端明确启用后创建，feature 不反向依赖 app-shell 控制器。元信息读取、更新执行与推荐更新忽略记录均由 `app_shell/application` 端口表达，`main.dart` 组合根绑定 data 实现；application 控制器不直接依赖 Dio、MethodChannel 或 SharedPreferences。签到状态由 wallet 独立管理，不进入启动兼容状态机。生成客户端负责 `/api/v1`；APK 使用不带认证拦截器的独立 Dio，避免向下载地址泄露 Token。

签到调度独立观察登录作用域与应用生命周期：服务端日期确认同日成功后不因 Widget 重建或重复恢复再次调用，前台只保留一个零点计时器和一个有限补试计时器；进入后台、退出或切号立即取消计时，重叠事件合并，旧作用域的迟到结果不进入当前账号。前台未读角标与后台提醒分别使用应用壳唯一计时器和后台协调器；前台按 30 秒校准角标，后台以固定 30 秒周期 Timer 尽力触发且不允许请求重叠。后台 poller 只保存当前后台时段的通知 ID/内容指纹、会话最后消息指纹和未读基线；每轮先生成候选批次，只有系统卡片全部提交成功后才原子更新指纹和计数，接口或卡片展示失败均保留旧基线供下一节拍重试。生命周期 epoch 使回前台后的 HTTP 结果不能再显示或提交；通知点击载荷是本地严格 v1 JSON，只允许通知目标、私聊会话和消息中心三类内部坐标，冷/热启动都先刷新权威未读事实，再交给现有路由鉴权。

全局 `WenyouInstantKeyboardInsets` 观察应用生命周期：Android 非 resumed 状态把有效底部高度固定为零，恢复后继续等待新的前台原生回调，后台迟到结果不会覆盖；iOS 等其他平台继续使用引擎 `MediaQuery`。`MainActivity` 从根视图实际应用的 `WindowInsetsCompat` 读取 IME 可见性和高度，只有 Activity 已恢复且窗口聚焦时才发布正值；IME 动画仍只发布最终目标，不转发逐帧进度，恢复和聚焦则先发布零值并请求重新分发 Insets。

现场诊断由编译期 `WENYOU_ENABLE_FIELD_DIAGNOSTICS` 控制且默认关闭；普通用户 Debug 与 Release 包不安装异常捕获、不显示右上角入口，也不调度帖子渲染事件或真实几何探针。需要异地排障时，从同一提交使用 `--dart-define=WENYOU_ENABLE_FIELD_DIAGNOSTICS=true` 生成专用 Debug 包，不维护会与主线漂移的诊断分支。启用后入口独立于具体业务页面和 Navigator；打开可复制原始物理窗口指标、逻辑 `MediaQuery`、帖子渲染事件、真实渲染树几何、Flutter/平台异常类型与最多 120 行堆栈。几何事件只使用固定节点名并记录尺寸、约束、屏幕坐标、可见比例、变换矩阵及滚动范围；非有限约束以字符串导出，保证 JSON 可复制。异常消息正文不会写入缓冲区；导出文本明确排除正文、内容 ID、账号、Token、私聊和请求 URL。缓冲区仅在当前诊断 Debug 进程内保留最近 40 条。Android Manifest 默认明确启用 Impeller，仅诊断构建可通过受校验的 Gradle 参数覆写为 Skia/OpenGLES，导出的 `renderer` 与 `rendererVariant` 可区分 A/B 包。

## 7. 鉴权、权限和隐私规则

Android Manifest 明确关闭全量备份，Android 11 及以下和 Android 12+ 备份/设备迁移规则均排除应用文件、数据库、SharedPreferences 和外部文件；会话、本地草稿与偏好不通过系统备份跨设备复制。

壳层不假定游客有写权限。升级与错误页不得展示 Token、响应正文或完整下载 URL。更新地址及重定向终点只接受 HTTPS。下载前 HEAD 与下载响应都必须具有 Android APK 类型、合理且一致的长度、`.apk` 附件名、`site.wenyou.app` 应用 ID、目标 `versionCode`、非空 `versionName` 和 64 位 SHA-256；文件字节再按声明哈希校验。Android 原生通道只接受应用 cache 的 `wenyou_updates/` 内 `.apk`，并在授权或打开安装器前通过系统 PackageManager 再校验包名、目标构建高于当前构建且签名与已安装应用相容；通过不可导出的 `FileProvider` 临时授予系统安装器只读权限，安装未知应用权限由系统设置页确认。

后台在线提醒只需要 Android 通知权限，不声明或启动前台服务，也不申请唤醒锁、开机启动、精确闹钟或忽略电池优化。应用初始化时显式创建 `wenyou_messages_v1` 高重要性消息频道，每轮同时校验全局通知权限与频道重要性；任一被关闭都不继续读取私有消息。系统权限关闭进入正常开启引导，只有插件初始化或平台读取真正异常时才提示状态读取失败。通知小图标按资源名动态读取，Release 构建必须显式阻止资源压缩删除它。站内通知系统卡片只使用现有安全摘要并截断；私聊卡片只显示对方用户名和“新私聊/新的私聊请求”，不读取或展示正文、图片地址、Token、请求 URL或 FCM token。未知或篡改的本地点击载荷回退消息中心，不自动标记已读。

## 8. 本地存储、缓存及失效规则

外观显式选择以 SharedPreferences 保存，跟随系统不保存覆盖值；偏好与账号无关且跨冷启动保留。契约结果只在本次进程缓存；每次冷启动和回前台重新检查。推荐更新仅把“已忽略的目标构建号”写入 SharedPreferences，新目标构建会再次提示。APK 以“目标构建 + 哈希前缀”暂存于应用 cache，先写 `.part`、通过长度与 SHA-256 后原子改名；新目标会清理旧 APK/partial，冷进程重新验证缓存，本次已验证文件只在内存记录并可供未知来源授权返回后直接继续。cache 可由系统清理；Token 仍由认证模块安全存储管理。

后台尽力提醒不保存应用内开关；消息指纹和基线只存在当前 Dart 进程，不持久化私有数据。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

检查期间显示明确进度；首次断网可手动重试，前台静默重查失败则 fail-open。Android 分别展示发布信息检查、下载进度、完整性校验和安装器打开状态；元数据缺失/错配、超限、哈希失败、包名/版本/签名失败均 fail-closed，partial 或不可信缓存会删除。拒绝未知来源权限、下载或安装器唤起失败均可重试；授权返回复用本次已验证 APK。强制更新和未知主版本不可绕过，推荐更新可跳过。

## 10. 跨模块约束

遵循[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[依赖边界与架构门禁](../architecture/dependencies.md)和[Foundation v6.8.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.8.0/docs/platforms/mobile.md)。app 组合层只连接 capability、全局外观与跨 feature 缓存失效等接口，不持有业务页面状态。亮色与黑夜只使用中央 `WenyouThemeTokens`、Foundation 语义色/等级/图标及全局 `ColorScheme`；图片内容与布局结构保持一致。原生图标与启动图只同步 Foundation 平台资产，Flutter 页面只消费 `WenyouBrandContract` 和 `WenyouBrandMark`；更新页复用中央 Token、语义图标、共享面板、状态横幅和 Foundation 最小触控目标的主按钮，以“当前构建 → 可用构建”作为版本识别元素。Android 竖屏优先；iOS 不下载 IPA，只交给 TestFlight。

## 11. 测试场景与验收条件

- [x] 冷启动兼容检查接受 Markdown v3/v4、拒绝更旧或未知版本；只有 v4 映射编辑器块对齐能力，v3 保持入口隐藏。
- [x] 兼容元信息进入四分支应用壳，游客无需登录。
- [x] 启动前恢复外观偏好，系统/亮色/黑夜可即时切换；游客公开可达，读写失败回退与重试完整。
- [x] 亮暗 ThemeData、系统栏、语义 Token 对比度及黑夜外观页具有自动化回归；原生静态启动层保持白色。
- [x] 主版本未知时只显示升级页；网络失败可重试且有请求 ID。
- [x] 低于最低构建时显示不可跳过的强制更新；低于推荐构建时可忽略并记住目标构建。
- [x] Android 更新覆盖 RainS3 HEAD/GET 元数据、长度、SHA-256、损坏缓存重下、原子落盘、未知来源权限复用与原生包名/版本/签名校验；异步原生异常映射为可操作错误；iOS 使用外部 TestFlight URL。
- [x] 会话失效进入带原因的登录页，并可回到游客首页。
- [x] 登录用户底栏以 Foundation danger 计数角标展示通知与私聊合计，零值隐藏、超过 99 显示 `99+`；可进入包含“通知 / 私聊”共享等宽页签的消息中心，点按或内容区左右滑动均以 180ms 方向反馈切换栏目、保持已访问内容与规范 URL，减少动态效果时瞬时完成。
- [x] 私聊 capability 映射到业务入口，登录用户回前台时同步私聊未读与请求角标。
- [x] Android 后台尽力提醒登录后固定开启并主动申请系统通知权限，不提供应用内开关；进程仍获调度时全程每 30 秒检查且不重叠，不显示常驻运行通知。首次基线不补发历史消息，通知聚合更新可识别，接口或系统卡片失败不推进基线，私聊正文不进入系统卡片，超过三条合并，返回前台/退出/划掉任务停止；Release 资源压缩保留动态通知小图标，权限关闭只进入正常开启引导。
- [x] 四分支使用 IndexedStack 保留页面状态；底栏中央发布动作在任一分支都先显示稳定类型选择，首页与动态顶栏可进入全站搜索。
- [x] Android 普通页面进入与返回只使用 180ms 水平位移，不叠加缩放或淡化；主分支和无来源栈兜底瞬时切换，减少动态效果时全部零时长。
- [x] 根主题切换不做全树插值；独立 Profile 包在 60 Hz 真机对外观、导航、动态流和 Markdown 时间线三轮采样并全部达到帧预算。
- [x] 登录会话就绪、前台跨过北京时间零点及后台跨日恢复后自动签到；同日重复构建/恢复不重复触发，临时失败只在前台有限补试，切号迟到结果不会污染新账号且失败不阻断应用壳。
- [x] Android 带键盘或不带键盘切到后台再返回时，即使 Flutter 引擎仍保留旧 `viewInsets`，后台与恢复等待期也保持零高度；后台迟到回调、仅失焦恢复和系统恢复键盘均不会留下空白或重复避让。
- [x] Xiaomi Android 16 真机通过公网契约检查、冷启动与进程存活冒烟。
- [x] 应用壳、启动状态在 360、400、600dp 宽度无溢出，关键控件满足 48dp 触控区。
- [x] Android adaptive/monochrome/legacy 图标与 iOS AppIcon 均与 Foundation v6.4.0 哈希一致；Android 12+、旧版 Android 和 iOS 系统启动层只显示纯白底色，Flutter 品牌首帧的整体居中、尺寸、文案、字体、实际可见最短停留时间、零尺寸预热帧和快速就绪切换均有回归。
- [x] Android 全量备份与设备迁移明确关闭；iOS 应用名、相册用途文案、iPhone 竖屏和应用本地化声明有静态回归。
- [ ] Android 8+ 模拟器通过启动冒烟。

## 12. 已知限制和后续功能

当前已完成构建策略门禁、全局亮色/黑夜外观、推荐更新忽略、Android RainS3 在线下载、双层完整性/身份校验与系统安装器、iOS TestFlight 外跳、本地一键发布入口和实验性后台在线提醒。Debug 构建使用独立 `site.wenyou.app.debug` 包名，Profile 性能构建使用 `site.wenyou.app.profile`，两者都避免占用正式更新链；完整门禁与发布入口均会核对线上契约、后端 revision 和 Markdown 版本。自动测试以伪 APK 固定下载与缓存状态机，Android 原生包解析、系统覆盖和后台尽力轮询仍需用 Android 8+ 真机完成最终验收；iOS 构建与上传必须在配置签名的 macOS 上执行。后台 30 秒节拍依赖当前 Flutter 进程与系统调度，留在最近任务不代表 Dart isolate 会持续运行；Doze、厂商省电、网络中断或进程终止都可能延迟/停止检查，不承诺实时送达。V1 不申请豁免、不做 App Links、FCM、WebSocket 或开机恢复。Profile 基线只覆盖固定离线关键交互，不能替代全部真实业务路径的人工手感验收。原生启动层在 Flutter 首帧前仍是静态白色。

## 13. 最近审查的契约版本和后端提交

契约 `5.14.1-dev.20260829.1`；Markdown v4；后端 `7ee9b68fac553d22949b8e699ceaf723774f593e`；Foundation `v6.8.0`（`196deaf`）。

## 14. 相关代码与架构文档

根 router 与签到生命周期分别位于 `lib/app/app_router.dart`、`lib/app/app_session_bootstrap.dart`，主壳、认证、内容和账号路由组位于 `lib/app/routes/`。

代码入口：`lib/app/app_theme.dart`、`lib/app/app_router.dart`、`lib/app/wenyou_app.dart`、`lib/core/application/background_online_reminders.dart`、`lib/features/app_shell/application/background_online_poller.dart`、`lib/features/app_shell/application/background_online_reminder_coordinator.dart`、`lib/features/app_shell/presentation/app_scaffold.dart`、`lib/features/app_shell/presentation/startup_gate.dart`、`lib/core/platform/android_background_notification_gateway.dart`、`lib/main.dart`、`android/app/src/main/`、`ios/Runner/Assets.xcassets/`、`test/features/app_shell/`、`integration_test/performance_test.dart`、`tool/windows/Measure-WenyouAndroidPerformance.ps1`、`tool/release-mobile-from-local.sh`。参见[设置](settings.md)、[私有发布运维](../../contracts/mobile-release-operations.md)、[Foundation v6.8.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.8.0/docs/platforms/mobile.md)、[移动端性能基线](../architecture/performance.md)、[语义图标](../architecture/icons.md)、[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[温油钱包](wallet.md)和[站内私聊](direct-messages.md)。

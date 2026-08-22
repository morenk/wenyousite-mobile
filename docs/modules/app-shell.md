# 应用壳

状态：`in_progress`

## 1. 模块目标与非目标

提供启动版本/兼容检查、服务端 capability、Android 站内更新、iOS TestFlight 更新、四分支主导航、游客模式、全局网络/错误状态、统一发布入口和消息中心。当前不实现 FCM、暗色主题或 App Links。

发布选择器只保留“发布主题帖 / 发布动态”两个目标操作，不重复解释内容类型。

## 2. 用户角色与使用场景

游客可直接进入首页和搜索；已登录用户额外使用通知、创作和个人功能。所有用户在启动时都要确认当前构建仍受支持且服务端契约可兼容；推荐更新可以暂时跳过，强制更新不可绕过。

## 3. 页面、入口和导航关系

启动门禁包裹 `/home`、`/moments`、`/notifications`、`/me` 四个保状态分支，底栏固定为“首页 / 动态 / 发布 / 消息 / 我的”；中央粉色“发布”是动作而非分支，`/search` 由首页和动态顶栏进入。门禁先处理强制更新，再检查契约与 capability，最后处理推荐更新；Android 从 `/meta.mobileCompatibility` 的 HTTPS 地址在页内下载 RainS3 APK，验证后唤起系统安装器，iOS 外跳 TestFlight。发布动作在按钮上方打开两项锚点气泡，选择受保护的 `/compose/thread` 或 `/compose/moment`；外部点击只关闭气泡，不触发底栏后方页面。当前首页/动态分支只改变推荐项，不改变按钮语义；游客登录或注册成功后恢复创建目标。登录用户的消息图标展示“通知未读 + 私聊未读/请求”的合计角标，进入分支与回前台时分别校准两类服务端事实。消息中心的“通知 / 私聊”使用共享等宽内容页签，只响应明确点按并通过规范 URL 保存栏目，不把横滑手势同时解释为切页。

## 4. 用户操作流程

冷启动调用元信息接口并用 `versionCode` / `CFBundleVersion` 比较当前平台策略。低于最低构建时进入阻断页；低于推荐构建时可更新或“稍后再说”，同一目标构建只提示一次。版本允许后检查主契约 4 与 Markdown v3、恢复会话并进入目标页。登录会话就绪后由 wallet 在本次进程内自动触发一次北京时间签到，只有本次真实领取才显示非阻断提示。回到前台时静默重查，断网不打断正在使用的兼容客户端。Android 进入后台时立即丢弃 Dart 侧缓存的 IME 目标高度；恢复或重新取得窗口焦点后，由原生活动在布局完成时回传当前真实键盘高度，避免旧键盘 inset 把页面下半部分持续挤出视口。

## 5. API operationId 与生成类型

- `metaGetMeta` → `MetaGetMeta200Response`、`ApiMetaResponseDto`、`MobileCompatibilityDto`、`MobilePlatformCompatibilityDto`。

## 6. 状态模型和数据流

启动状态为 checking、ready、recommendedUpdate、updateRequired、incompatible、failed；更新动作另有 idle、checking、downloading、verifying、installing、openingExternalPage、permissionRequired、installerOpened、externalPageOpened、failed。元信息映射为纯 `ContractInfo`，应用根通过 `AppCapabilities` 把 stickers、directMessages、pushNotifications 能力注入业务入口；入口默认关闭并只在服务端明确启用后创建，feature 不反向依赖 app-shell 控制器。元信息读取、更新执行与推荐更新忽略记录均由 `app_shell/application` 端口表达，`main.dart` 组合根绑定 data 实现；application 控制器不直接依赖 Dio、MethodChannel 或 SharedPreferences。签到状态由 wallet 独立管理，不进入启动兼容状态机。生成客户端负责 `/api/v1`；APK 使用不带认证拦截器的独立 Dio，避免向下载地址泄露 Token。

全局 `WenyouInstantKeyboardInsets` 观察应用生命周期，只在 resumed 状态接受 Android IME 目标高度；`MainActivity` 在 IME 动画端点、`onPostResume` 和窗口重新聚焦后统一发布根视图的当前 inset。

## 7. 鉴权、权限和隐私规则

壳层不假定游客有写权限。升级与错误页不得展示 Token、响应正文或完整下载 URL。更新地址及重定向终点只接受 HTTPS。下载前 HEAD 与下载响应都必须具有 Android APK 类型、合理且一致的长度、`.apk` 附件名、`site.wenyou.app` 应用 ID、目标 `versionCode`、非空 `versionName` 和 64 位 SHA-256；文件字节再按声明哈希校验。Android 原生通道只接受应用 cache 的 `wenyou_updates/` 内 `.apk`，并在授权或打开安装器前通过系统 PackageManager 再校验包名、目标构建高于当前构建且签名与已安装应用相容；通过不可导出的 `FileProvider` 临时授予系统安装器只读权限，安装未知应用权限由系统设置页确认。

## 8. 本地存储、缓存及失效规则

契约结果只在本次进程缓存；每次冷启动和回前台重新检查。推荐更新仅把“已忽略的目标构建号”写入 SharedPreferences，新目标构建会再次提示。APK 以“目标构建 + 哈希前缀”暂存于应用 cache，先写 `.part`、通过长度与 SHA-256 后原子改名；新目标会清理旧 APK/partial，冷进程重新验证缓存，本次已验证文件只在内存记录并可供未知来源授权返回后直接继续。cache 可由系统清理；Token 仍由认证模块安全存储管理。

## 9. 加载、空数据、错误、重试和冲突状态

检查期间显示明确进度；首次断网可手动重试，前台静默重查失败则 fail-open。Android 分别展示发布信息检查、下载进度、完整性校验和安装器打开状态；元数据缺失/错配、超限、哈希失败、包名/版本/签名失败均 fail-closed，partial 或不可信缓存会删除。拒绝未知来源权限、下载或安装器唤起失败均可重试；授权返回复用本次已验证 APK。强制更新和未知主版本不可绕过，推荐更新可跳过。

## 10. 跨模块约束

遵循[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[依赖边界与架构门禁](../architecture/dependencies.md)和[Foundation v6.2.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.2.0/docs/platforms/mobile.md)。app 组合层只连接 capability 与跨 feature 缓存失效等接口，不持有业务页面状态。更新页复用中央 Token、语义图标、共享面板、状态横幅和 Foundation 最小触控目标的主按钮，以“当前构建 → 可用构建”作为版本识别元素。Android 竖屏优先；iOS 不下载 IPA，只交给 TestFlight。

## 11. 测试场景与验收条件

- [x] 兼容元信息进入四分支应用壳，游客无需登录。
- [x] 主版本未知时只显示升级页；网络失败可重试且有请求 ID。
- [x] 低于最低构建时显示不可跳过的强制更新；低于推荐构建时可忽略并记住目标构建。
- [x] Android 更新覆盖 RainS3 HEAD/GET 元数据、长度、SHA-256、损坏缓存重下、原子落盘、未知来源权限复用与原生包名/版本/签名校验；异步原生异常映射为可操作错误；iOS 使用外部 TestFlight URL。
- [x] 会话失效进入带原因的登录页，并可回到游客首页。
- [x] 登录用户底栏展示通知与私聊合计角标，并可进入包含“通知 / 私聊”共享等宽页签的消息中心；页签仅点按切换并保持规范 URL。
- [x] 私聊 capability 映射到业务入口，登录用户回前台时同步私聊未读与请求角标。
- [x] 四分支使用 IndexedStack 保留页面状态；底栏中央发布动作在任一分支打开稳定类型选择，首页与动态顶栏可进入全站搜索。
- [x] 登录会话就绪后自动签到，同一会话重复构建不重复触发且失败不阻断应用壳。
- [x] Android 带键盘或不带键盘切到后台再返回时清除陈旧 IME 目标，后台迟到回调不会导致页面下半部分消失。
- [x] Xiaomi Android 16 真机通过公网契约检查、冷启动与进程存活冒烟。
- [x] 应用壳、启动状态在 360、400、600dp 宽度无溢出，关键控件满足 48dp 触控区。
- [ ] Android 8+ 模拟器通过启动冒烟。

## 12. 已知限制和后续功能

当前已完成构建策略门禁、推荐更新忽略、Android RainS3 在线下载、双层完整性/身份校验与系统安装器、iOS TestFlight 外跳和本地一键发布入口。Debug 构建使用独立 `site.wenyou.app.debug` 包名，避免调试签名占用正式更新链；完整门禁与发布入口均会核对线上契约、后端 revision 和 Markdown 版本。自动测试以伪 APK 固定下载与缓存状态机，Android 原生包解析和系统覆盖行为仍需用正式签名在 Android 8+ 真机完成最终验收；iOS 构建与上传必须在配置签名的 macOS 上执行。V1 不做 App Links、暗色主题与 FCM。

## 13. 最近审查的契约版本和后端提交

契约 `5.5.0-dev.20260822.1`；Markdown v3；后端 `15ed84d9000bf46989d18a18855c5950ba7f9b10`；Foundation `v6.2.0`（`4ad1eb8`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/app_shell/application/app_shell_ports.dart`、`lib/features/app_shell/data/`、`lib/main.dart`、`android/app/src/main/kotlin/site/wenyou/app/MainActivity.kt`、`test/features/app_shell/mobile_update_service_test.dart`、`tool/release-mobile-from-local.sh`。参见[私有发布运维](../../contracts/mobile-release-operations.md)、[Foundation v6.2.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.2.0/docs/platforms/mobile.md)、[语义图标](../architecture/icons.md)、[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[温油钱包](wallet.md)和[站内私聊](direct-messages.md)。

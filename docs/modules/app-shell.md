# 应用壳

状态：`in_progress`

## 1. 模块目标与非目标

提供启动版本/兼容检查、服务端 capability、Android 站内更新、iOS TestFlight 更新、五栏主导航、游客模式、全局网络/错误状态和分支创建入口。当前不实现 FCM、暗色主题或 App Links。

## 2. 用户角色与使用场景

游客可直接进入首页和搜索；已登录用户额外使用通知、创作和个人功能。所有用户在启动时都要确认当前构建仍受支持且服务端契约可兼容；推荐更新可以暂时跳过，强制更新不可绕过。

## 3. 页面、入口和导航关系

启动门禁包裹 `/home`、`/moments`、`/search`、`/notifications`、`/me` 五个保状态分支。门禁先处理强制更新，再检查契约与 capability，最后处理推荐更新；Android 在页内下载后唤起系统安装器，iOS 外跳 TestFlight。首页悬浮按钮进入受保护的 `/compose/thread`，动态分支进入受保护的 `/compose/moment`，其他分支不显示创建按钮；游客登录或注册成功后恢复创建目标。登录用户的通知图标展示服务端通知未读角标，进入分支与回前台时主动刷新；私聊 capability 开启时，回前台同时校准私聊合计角标。

## 4. 用户操作流程

冷启动调用元信息接口并用 `versionCode` / `CFBundleVersion` 比较当前平台策略。低于最低构建时进入阻断页；低于推荐构建时可更新或“稍后再说”，同一目标构建只提示一次。版本允许后检查主契约 4 与 Markdown v2、恢复会话并进入目标页。登录会话就绪后由 wallet 在本次进程内自动触发一次北京时间签到，只有本次真实领取才显示非阻断提示。回到前台时静默重查，断网不打断正在使用的兼容客户端。

## 5. API operationId 与生成类型

- `metaGetMeta` → `MetaGetMeta200Response`、`ApiMetaResponseDto`、`MobileCompatibilityDto`、`MobilePlatformCompatibilityDto`。

## 6. 状态模型和数据流

启动状态为 checking、ready、recommendedUpdate、updateRequired、incompatible、failed；下载动作另有 idle、downloading、permissionRequired、installerOpened、externalPageOpened、failed。元信息映射为纯 `ContractInfo`，应用根通过 `AppCapabilities` 把 stickers、directMessages、pushNotifications 能力注入业务入口；入口默认关闭并只在服务端明确启用后创建，feature 不反向依赖 app-shell 控制器。环境、更新服务、忽略记录与会话由 Riverpod 注入；签到状态由 wallet 独立管理，不进入启动兼容状态机。生成客户端负责 `/api/v1`；APK 使用不带认证拦截器的独立 Dio，避免向下载地址泄露 Token。

## 7. 鉴权、权限和隐私规则

壳层不假定游客有写权限。升级与错误页不得展示 Token、响应正文或完整下载 URL。更新地址只接受 HTTPS。Android 原生通道只接受应用 cache 的 `wenyou_updates/` 内 `.apk`，通过不可导出的 `FileProvider` 临时授予系统安装器只读权限；安装未知应用权限由系统设置页确认。

## 8. 本地存储、缓存及失效规则

契约结果只在本次进程缓存；每次冷启动和回前台重新检查。推荐更新仅把“已忽略的目标构建号”写入 SharedPreferences，新目标构建会再次提示。APK 暂存于应用 cache，可由系统清理；Token 仍由认证模块安全存储管理。

## 9. 加载、空数据、错误、重试和冲突状态

检查期间显示明确进度；首次断网可手动重试，前台静默重查失败则 fail-open。Android 展示下载进度，拒绝未知来源权限、下载或安装器唤起失败均可重试；已下载 APK 会复用于权限重试。强制更新和未知主版本不可绕过，推荐更新可跳过。

## 10. 跨模块约束

遵循[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[依赖边界与架构门禁](../architecture/dependencies.md)和[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)。app 组合层只连接 capability 与跨 feature 缓存失效等接口，不持有业务页面状态。更新页复用中央 Token、共享面板、状态横幅和 Foundation 最小触控目标的主按钮，以“当前构建 → 可用构建”作为版本识别元素。Android 竖屏优先；iOS 不下载 IPA，只交给 TestFlight。

## 11. 测试场景与验收条件

- [x] 兼容元信息进入五栏应用壳，游客无需登录。
- [x] 主版本未知时只显示升级页；网络失败可重试且有请求 ID。
- [x] 低于最低构建时显示不可跳过的强制更新；低于推荐构建时可忽略并记住目标构建。
- [x] Android 更新展示进度并处理未知来源权限/安装器反馈；iOS 使用外部 TestFlight URL。
- [x] 会话失效进入带原因的登录页，并可回到游客首页。
- [x] 登录用户底栏展示通知未读角标，并可进入 API 驱动通知列表。
- [x] 私聊 capability 映射到业务入口，登录用户回前台时同步私聊未读与请求角标。
- [x] 五分支使用 IndexedStack 保留页面状态，首页/动态悬浮按钮进入各自受保护创建入口。
- [x] 登录会话就绪后自动签到，同一会话重复构建不重复触发且失败不阻断应用壳。
- [x] Xiaomi Android 16 真机通过公网契约检查、冷启动与进程存活冒烟。
- [x] 应用壳、启动状态在 360、400、600dp 宽度无溢出，关键控件满足 48dp 触控区。
- [ ] Android 8+ 模拟器通过启动冒烟。

## 12. 已知限制和后续功能

当前已完成构建策略门禁、推荐更新忽略、Android HTTPS 下载与系统安装器、iOS TestFlight 外跳和本地一键发布入口。Android 仍需用正式签名在真机完成旧版覆盖安装验收；iOS 构建与上传必须在配置签名的 macOS 上执行。V1 不做 App Links、暗色主题与 FCM。

## 13. 最近审查的契约版本和后端提交

契约 `4.5.0-dev.20260809.1`；Markdown v2；后端 `437e76049a371ff8b6aee1b8a613dc864aa30f11`。

## 14. 相关代码与架构文档

代码入口：`lib/features/app_shell/`、`android/app/src/main/kotlin/site/wenyou/app/MainActivity.kt`、`tool/release-mobile-from-local.sh`。参见[私有发布运维](../../contracts/mobile-release-operations.md)、[Foundation v1.1.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v1.1.0/docs/platforms/mobile.md)、[导航](../architecture/navigation.md)、[网络与会话](../architecture/networking.md)、[温油钱包](wallet.md)和[站内私聊](direct-messages.md)。

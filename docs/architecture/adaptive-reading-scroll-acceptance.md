# 自适应阅读滑块验收

状态：移动端候选／待负责人验收。Foundation 已按负责人授权合并并发布正式 v7.2.0；新滑块已接入三个阅读页。未进行真机或 Profile 验收。

## 需求与验收范围

负责人明确要求把非交互进度提示与手动快翻合成一个滑块，取消主题详情和独立楼中楼右上角快翻按钮及局部操作卡。动态详情正文与当前展开评论采用同样交互；动态发现、关注及其他信息流不纳入。

慢读时细条不拦截正文；一次明确快滑后柔和展开，原手势继续滚动。下一次抓取按实际阅读位置开始，正文直接跟手；松手停止跟随，停稳后短暂停留、收细并淡出。数值、时序、颜色和可访问性以正式 Foundation v7.2.0 契约为唯一事实源，不在本文件另建视觉规范。

本需求按阅读交互改进实施，不把构造的长帖测试宣称为特定真实帖子的 Bug 复现。既有首次懒布局校正、末端跟随和取消行为继续回归，旧验收结果见[纵向快翻验收](vertical-quick-scroll-acceptance.md)。

## 环境与契约

- Windows 工作区：`D:\codex-worktrees\adaptive-reading-scroll\wenyousite-mobile`。
- 任务分支：`codex/20260926-adaptive-reading-scroll`；基线 `9108c6e57744999ae9c2de61e1c2290c8d1aea37`。
- 移动端候选源码提交：`99aa86728f94a280cc853770e5f81d12119207a3`；[PR #66](https://github.com/morenk/wenyousite-mobile/pull/66) 已推送为 Draft，目标 `dev`，待负责人验收。后续仅补充本条追溯记录，应用源码与已验证 APK 一致。
- 基线 Foundation v7.1.2；本轮 fetch 正式 Tag 后，以独立 `chore`（`7115dc3b`）固定 v7.2.0 及锁文件，主题和原生品牌清单版本断言同步。品牌资产 SHA-256 全部保持，旧快翻 API 完整兼容。
- [Foundation PR #20](https://github.com/morenk/wenyousite-foundation/pull/20) 已合并；[v7.2.0 Release](https://github.com/morenk/wenyousite-foundation/releases/tag/v7.2.0) 为正式非预发布版本，合并与 Tag peeled SHA 均为 `a6f4e2d3487ac058872a44013ffb4e7fd587d11e`。schemaVersion 保持 3，新能力独立位于 `experiences.adaptiveReadingScroll.mobile`。VPS 生成、完整门禁、包检查及 GitHub quality 通过；远端任务分支、临时 Worktree 已核验清理。
- 后端记录与 2026-09-26 公网 `/meta` 一致：`5.26.0-dev.20260922.3`、`124fb4e8aa395440f7a2156de98b642ec87f7583`。本需求不修改 API、分页策略或持久化。
- 原主工作区及其未跟踪 `artifacts/` 未修改。尚未操作真机或创建长期 Debug 进程。

## 已执行的开发检查

新实现：速度采样器、显隐计时和共享几何长帖回归共 37 项通过；自适应交互、共享组件及 Foundation 版本／品牌资产回归共 43 项通过。三个实际页面的快滑、避让、分页和既有定位均已执行；320／360／400／600dp、动态双倍字号、共享组件明暗主题及四态 Golden 已生成并检查，未替代真机体验。

新用例文件：

- `test/core/widgets/reading_scroll_velocity_tracker_test.dart`
- `test/core/widgets/reading_scroll_visibility_test.dart`
- `test/core/widgets/reading_adaptive_scroll_test.dart`
- `test/features/moments/moment_reading_quick_scroll_test.dart`

保留并更新：`test/core/widgets/reading_quick_scroll_test.dart`、`test/features/threads/thread_reading_quick_scroll_test.dart`、`test/features/posts/post_reading_quick_scroll_test.dart`、`test/features/moments/moment_comment_target_page_test.dart`。依赖检查：`test/app/app_theme_test.dart`、`test/tool/foundation_brand_assets_test.dart`。

新增迟到深链回归先在接入前置作用域修正前失败：手动停在 403.2dp，迟到评论使其跳到 1412dp。修正为上下文尚在请求时也建立定位作用域，保留后续抓取／正文手势的解除决定；修正后该文件 10 项全部通过。此为构造的独立回归，不宣称来自某个负责人真实帖子的输入。

主题详情与独立楼中楼的完整页面回归共 127 项通过，更新移除顶栏按钮后受影响的 Golden：

```powershell
flutter test --no-pub test/features/threads/thread_detail_page_test.dart test/features/posts/post_replies_page_test.dart --update-goldens --concurrency 2 --reporter expanded
```

本轮统一入口 `npm run check:apk -- -TestConcurrency 2` 最终退出码 0，完整门禁及 Android Debug 构建通过。全仓格式、应用与生成客户端静态分析、架构、21 个模块文档、API 覆盖、契约校验和客户端再生成一致性通过。Flutter 全量测试 4,914 项通过，1 项按既有开关跳过：`test/core/diagnostics/diagnostic_live_receipt_test.dart` 的真实 Sentry 接收验收仅在显式设置 `WENYOU_VALIDATE_SENTRY` 时运行。Windows 工具测试 47 项通过。未通过跳过测试取得任何诊断平台接收证据。完整日志保留在任务工作区 `artifacts-reading-check-apk.log`；第一次尝试因 README 版本标记未同步在架构检查停止，修正后执行了上述完整门禁。

以下为实施前基线，保留用于区分证据：

2026-09-26，未接入页面的独立速度采样器及既有滑块基线共 32 项通过：

```powershell
flutter test --no-pub test/core/widgets/reading_scroll_velocity_tracker_test.dart test/core/widgets/reading_quick_scroll_test.dart --concurrency 2 --reporter expanded
```

其中新采样器 9 项覆盖持续时间／距离／速度同时成立、上下对称、短抖动、慢读、视口归一化、反向重新累计、不同采样间隔、停顿／取消和异常时间戳。既有 23 项仍验证旧按钮交互，不能作为新页面行为通过的证据。

上述两个新增 Dart 文件的针对性 `flutter analyze --no-pub` 零问题；这不是全量静态分析或候选门禁结果。

三个实际页面的旧交互／定位基线另有 16 项通过，含四种屏宽、首次长首楼、定位遮罩、评论上下文、不可见目标及重试：

```powershell
flutter test --no-pub test/features/threads/thread_reading_quick_scroll_test.dart test/features/posts/post_reading_quick_scroll_test.dart test/features/moments/moment_comment_target_page_test.dart --concurrency 2 --reporter expanded
```

## 待执行的页面与真机验收

- 主题详情、独立楼中楼与动态详情分别验证一次快滑唤醒、停稳后容易抓住、抓取无跳位、反向跟手、松手不继续跑；顶栏没有快翻按钮，滑块没有操作卡。
- 同一条长帖首次进入、中段抓取、图片延迟撑高、分页追加、按住末端、离开末端、取消及再次抓取均保持位置连续；不把当前已显示范围冒充全文。
- 慢读、短抖动、反向折返、程序定位、横向轮播、刷新回弹不误唤醒；淡出／收细中再次快滑连续展开。
- 深链聚焦未完成时不抢导航；开始手动阅读后迟到定位不拉回。切换子贴、筛选、排序、账号，打开编辑器、键盘、覆盖路由和释放页面均清理旧动作。
- 正文点击回复、选字、头像、链接、图片、轮播、底部发表和系统返回手势保持可操作；仅展开滑块的局部命中区接管拖动。
- 320／360／400／600dp、双倍字号、明暗主题、减少动态效果、TalkBack 和键盘分别检查；动态信息流保持原样。
- Golden 固定细态、展开中间态、展开态、拖动态；真机 Profile 连续快滑和拖动需单独采样，未实测不宣称性能通过。

## 候选制品与负责人结果

移动端候选版本：`0.8.0-dev.2+97`。2026-09-26 Windows 本地统一门禁构建完成，负责人真机结果仍待确认。

- APK：`D:\codex-worktrees\adaptive-reading-scroll\wenyousite-mobile\build\candidates\wenyou-0.8.0-dev.2+97-adaptive-reading-debug.apk`。
- 大小：109,285,760 字节。
- SHA-256：`00534DEADAFD879394BF69F4F42A9B2AA66C61472CBC3EC05DDA5529D5CAFC9A`。
- `aapt dump badging` 核验：包名 `site.wenyou.app.debug`，应用名“温油站 Debug”，实际 `versionName=0.8.0-dev.2-debug`、`versionCode=97`、`sdkVersion=26`、仅 `arm64-v8a`。
- APK 由同一次完整门禁直接构建；构建后仅补充验收文档和提交追溯，不修改应用源码。候选未安装、未上传发布；线上推荐版本保持 build 96。

`npm run dev:status` 返回当前 Worktree 会话为 stopped，没有获授权且可复用的 Debug 会话；本轮未启动调试、安装 APK 或操作真机。

在取得负责人明确反馈前，始终保持候选／待验收。自动检查、Golden 和 APK 构建不替代手感验收。

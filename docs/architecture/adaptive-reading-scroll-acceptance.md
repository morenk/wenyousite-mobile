# 自适应阅读滑块验收

状态：负责人验收通过。2026-09-27 治理协调任务传达负责人明确回复“滑块验收过了可以直接合并分支并清理”，本批贴边、无底衬、1 秒时序、灵敏度及楼中楼组底色反馈获验收。最终完整门禁已通过，按授权合并 PR #66；工作区和分支暂保留，等待治理核验主工作区同树并完成正式签名 Release 测试包归档后再清理。Profile 未实测，不宣称性能验收通过。

## 2026-09-27 反馈收尾与集成

- 原工作区 HEAD 为 `488b4c391c85f06550ea77b1d44e0383506e877d`。整合前已备份 tracked 二进制补丁和未跟踪 `reading_scroll_spec.dart`，目录为 `D:\code\wenyousite\artifacts\mobile-adaptive-reading-scroll\20260927-025217`；补丁 SHA-256 为 `DDCA92578F8ADDAB7747F974148156929FD0EF5B2F9C443B5D6BDB234E26FBC0`，其他文件摘要见该目录 `sha256.json`。
- 本轮直接回归覆盖速度采样、显隐时序、共享交互与几何、楼中楼组样式及三个实际页面：`reading_scroll_velocity_tracker_test.dart`、`reading_scroll_visibility_test.dart`、`reading_adaptive_scroll_test.dart`、`reading_quick_scroll_test.dart`、`wenyou_discussion_reply_card_test.dart`、`thread_reading_quick_scroll_test.dart`、`post_reading_quick_scroll_test.dart`、`moment_reading_quick_scroll_test.dart`、`moment_comment_target_page_test.dart`，共 75 项通过，日志 `feedback-regression.log`。
- 已核验移动端记录、Backend 只读镜像 `origin/dev` 与公网 `/meta` 的来源均为 `124fb4e8aa395440f7a2156de98b642ec87f7583`，API 为 `5.26.0-dev.20260922.3`，公网 Markdown v5。只执行线上只读核验。
- 本批只纳入滑块与楼中楼组底色及最新 `origin/dev`；旧 Tab 全宽筛选行和 PR #68 不在范围内。集成保留已合并的图片定位、个人主页与目标过渡。已以合并提交 `2ca241db` 整合 `origin/dev=9a595a8857a0451e038b0c6c82e2f3b0ecbaacf9`；主题详情 84 项回归通过，冲突 Golden 按完整界面重新生成并复核。
- 本轮不启动或重启真机、安装或构建 APK。正式签名 Release 测试包由治理任务在完成交接后统一构建，旧 build 97 的 APK 哈希不代表当前源码。
## Foundation 7.2.1 迁移

本轮在只读镜像执行 `git fetch origin --tags`，确认最新正式 Tag `v7.2.1` 解析为 `c7729bc9e28c608c6c3a76cdc088e3c5b6a5a663`。阅读 CHANGELOG 和 Flutter profile 后，独立 chore 升级 `pubspec.yaml`、锁文件、版本断言及当前说明。已移除的 `WenyouReadingQuickScrollContract`、`WenyouAdaptiveReadingScrollContract` 与 `actionReadingQuickScroll` 不再被应用、测试或工具消费；颜色、圆角、字体和无障碍基础继续来自通用主题。完整门禁通过，源码绑定与交接见下节。

## 最终完整门禁与构建交接

2026-09-27，在本 Windows Worktree 执行 `npm run check -- -TestConcurrency 2`，退出码为 0。完整门禁绑定应用源码提交 `9b6cb303dc59ec1efaf3d7563a70dc6198ec2a81`（树 `090a171df233d1802bc9cfa7a1fa367b1ca31e58`）；之后仅补充本文及 CHANGELOG，不改变应用、测试、依赖或工具。

- 格式、应用与生成客户端全量静态分析、架构、21 个模块文档、API 覆盖、契约校验和客户端再生成一致性全部通过。
- Flutter 全量回归 4,941 项通过，1 项显式跳过：`test/core/diagnostics/diagnostic_live_receipt_test.dart` 的 Sentry 在线收件验收，本轮未开启真实接收测试。
- Windows 发布工具测试 47 项全部通过。完整日志在上述独立证据目录 `final-check.log`，文件摘要与合并交接记录另存 `evidence-sha256.json`、`handoff.json`。
- 图片查看器、个人主页及讨论目标过渡的应用源码与已合并 `origin/dev` 一致；本任务相对 `dev` 未改动开发工具，不纳入 PR #68 或旧 Tab 全宽筛选行。
- 负责人已明确验收滑块及本批反馈并授权合并 `dev`。Profile 帧时间未实测；自动测试与 Golden 不作为性能验收。
- 本轮版本仍为 `0.8.0-dev.2+97`。治理任务将在主工作区 `dev` fast-forward 后核验与本任务最终源码树一致，复用同应用源码的完整门禁，以 build-only 入口构建正式签名 Release 测试包。当前不构建、不安装、不上传、不发布、不打应用 Tag。
- 本任务工作区和分支保留，等待治理完成构建与制品归档后再清理。旧 `99aa8672` 的 Debug APK 已另存独立证据目录 `historical-build97-debug.apk`，SHA-256 为 `00534DEADAFD879394BF69F4F42A9B2AA66C61472CBC3EC05DDA5529D5CAFC9A`；它仅为历史候选，不代表最终源码。

## 2026-09-26 真机反馈批次（历史记录）

- 负责人要求直接 ADB 覆盖安装，明确免去额外核验；`adb install -r` 返回 `Success`，目标为下方记录的 build 97 Debug APK。
- 原始反馈：在已安装候选的主题正文快滑时，滑块偏入正文；预期细态紧贴页面右侧边缘，快滑才向左小幅让位并变大。负责人另要求正文停稳后的展开等待由 1.5 秒缩为 1 秒。
- 已证实根因：可见滑块居中于 48dp 命中区，命中区又叠加右侧手势避让与间距。360dp 构造回归中，细条右端实际为 329dp（无手势边距）或 305dp（24dp 手势边距），两项旧实现回归均失败；这与真机“偏入正文”反馈相符。
- 修正将绘制位置与命中区分开：细态贴页面右侧安全边缘，仅展开态向左应用既有 `edgeGap`；48×64dp 命中区仍避开系统手势，纵向中心及阅读位置不变。动画期间正文不重建。新几何两项通过，后续去底衬、1 秒等待及显隐连续性合并验证后，共享组件与时序回归 40 项通过，三个实际页面回归 11 项通过；相关明暗四态及页面 Golden 同步。
- 当前 Worktree 原无托管 Debug 会话；按本轮热重载授权，通过 `flutter attach` 连接设备 `4b9c39b5` 的 `site.wenyou.app.debug`。初次同步未替换已运行库，不能算生效；随后实际热重载 1/4573 个库，VM 源码核验 `collapsedCenterX` 已载入，Android PID 始终为 15535。截图确认展开态位于右缘内侧约 8dp；未热重启、未重装本轮修改。会话保留用于继续反馈。
- 负责人继续要求去掉白色底衬并优化动效：普通状态仅绘制滑块本体，保留键盘焦点轮廓；显现／消失从当前透明度接续，形变和透明度反向时按剩余距离缩短本段时长，没有回弹或拖动追赶。参考 [Apple Motion HIG](https://developer.apple.com/design/human-interface-guidelines/motion) 的简短、精确、可中断反馈原则；本实现不宣称复刻苹果系统曲线。
- 本轮实际再热重载 15/4573 个库及后续 1 个库，PID 与阅读页保留。VM 对象直接核验当前 `ReadingScrollVisibility.expandedHold` 为 1,000,000 微秒，即 1 秒。设备退到后台时同步曾等待，恢复同一 Activity 后完成；未重启进程。
- 负责人纠正边界后，[Foundation PR #21](https://github.com/morenk/wenyousite-foundation/pull/21) 已关闭，未合并、未打 Tag。滑块控制器和绘制已解除 `WenyouAdaptiveReadingScrollContract` 依赖，改为移动端 `ReadingScrollSpec`；1 秒等待、贴边、无底衬与连续动画由本仓库维护，不再有临时参数覆盖或发布阻塞。已正式发布的 Foundation v7.2.0 历史保持，仅作为通用主题依赖继续使用。
- 灵敏度反馈：负责人表示快速滑动有时不唤醒。构造 64ms 上／下短快滑在旧门槛下均失败；调整为最近 100ms 内至少 40ms、40dp、平均速度达到 `max(550dp/s, 0.8 × 视口高度/s)` 后通过，稍轻的同向快滑也通过。保留短抖动、反向、慢读、惯性、程序／布局滚动排除。尚未采集负责人的原始手势轨迹，不能断言所有漏判都由同一原因导致。
- 同批预览反馈：主题楼层内的楼中楼预览及动态评论内的嵌套回复移除横向分隔线；随后按负责人要求移除左侧引导线，保留 12dp 外缩进与 12dp 内缩进，以 Foundation 明暗主题 `softPanel` 整组底色及共享圆角表达层级，单条回复保持透明。独立楼中楼详情的回复分隔、动态顶层评论边界及分页／展开方式保持。共享组件明暗主题 2 项回归通过，实际热重载 2/4574 个库；等待负责人观察本轮背景效果。
- 下方完整门禁及 APK 哈希只对应原候选 `99aa8672`，不代表本轮热重载源码已通过完整门禁；反馈批次尚未收敛，不机械重建 APK。

本反馈批次的直接检查：

- 参数移入移动端后，`reading_adaptive_scroll_test.dart`、`reading_quick_scroll_test.dart`、`reading_scroll_velocity_tracker_test.dart`、`reading_scroll_visibility_test.dart`、`moment_comment_target_page_test.dart` 与 `post_reading_quick_scroll_test.dart` 共 63 项通过。
- 最新预览组底色：`test/core/widgets/wenyou_discussion_reply_card_test.dart` 明暗主题 2 项、`test/features/threads/thread_detail_page_test.dart --plain-name 楼中楼` 7 项、`test/features/moments/moment_comment_target_page_test.dart --plain-name 楼中楼` 2 项通过。分别覆盖共享底色与缩进、预览入口及点击、动态目标回复展开与定位。
- 以上为开发反馈检查，预览组明暗实机观感及原滑块手感仍待负责人确认。

## 需求与验收范围

负责人明确要求把非交互进度提示与手动快翻合成一个滑块，取消主题详情和独立楼中楼右上角快翻按钮及局部操作卡。动态详情正文与当前展开评论采用同样交互；动态发现、关注及其他信息流不纳入。

慢读时细条不拦截正文；一次明确快滑后柔和展开，原手势继续滚动。下一次抓取按实际阅读位置开始，正文直接跟手；松手停止跟随，停稳后短暂停留、收细并淡出。交互数值与时序以移动端 `ReadingScrollSpec` 为唯一入口，状态与可访问性由共享阅读组件维护；通用颜色和样式使用应用主题，不在页面复制参数。

本需求按阅读交互改进实施，不把构造的长帖测试宣称为特定真实帖子的 Bug 复现。既有首次懒布局校正、末端跟随和取消行为继续回归，旧验收结果见[纵向快翻验收](vertical-quick-scroll-acceptance.md)。

## 环境与契约

- Windows 工作区：`D:\codex-worktrees\adaptive-reading-scroll\wenyousite-mobile`。
- 任务分支：`codex/20260926-adaptive-reading-scroll`；基线 `9108c6e57744999ae9c2de61e1c2290c8d1aea37`。
- 移动端候选源码提交：`99aa86728f94a280cc853770e5f81d12119207a3`；[PR #66](https://github.com/morenk/wenyousite-mobile/pull/66) 已推送为 Draft，目标 `dev`，待负责人验收。这是原已安装 APK 的源码；本轮后续热重载修正另述，不把原 APK 哈希用于新源码。
- 基线 Foundation v7.1.2；本轮 fetch 正式 Tag 后，以独立 `chore`（`7115dc3b`）固定 v7.2.0 及锁文件，主题和原生品牌清单版本断言同步。品牌资产 SHA-256 全部保持，旧快翻 API 完整兼容。
- [Foundation PR #20](https://github.com/morenk/wenyousite-foundation/pull/20) 已合并；[v7.2.0 Release](https://github.com/morenk/wenyousite-foundation/releases/tag/v7.2.0) 为正式非预发布版本，合并与 Tag peeled SHA 均为 `a6f4e2d3487ac058872a44013ffb4e7fd587d11e`。schemaVersion 保持 3，新能力独立位于 `experiences.adaptiveReadingScroll.mobile`。VPS 生成、完整门禁、包检查及 GitHub quality 通过；远端任务分支、临时 Worktree 已核验清理。
- 后端记录与 2026-09-26 公网 `/meta` 一致：`5.26.0-dev.20260922.3`、`124fb4e8aa395440f7a2156de98b642ec87f7583`。本需求不修改 API、分页策略或持久化。
- 原主工作区及其未跟踪 `artifacts/` 未修改。初始构建阶段未操作真机；后续安装与热重载遵循负责人明确指令。

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
- APK 由同一次完整门禁直接构建；构建后仅补充验收文档和提交追溯，不修改应用源码。候选随后按负责人明确要求 ADB 覆盖安装；本轮热重载后的源码与该 APK 不同，未上传发布，线上推荐版本保持 build 96。

首次交付时 `npm run dev:status` 为 stopped；后续收到明确的安装与热重载指令，已执行 ADB 安装并连接本任务 Debug 应用，详见上方反馈批次。托管工具仍报告 stopped，因为此次复用的是 Flutter attach 会话；不能把它报告为隔离预览会话。

在取得负责人明确反馈前，始终保持候选／待验收。自动检查、Golden 和 APK 构建不替代手感验收。

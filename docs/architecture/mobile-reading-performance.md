# 阅读性能后续切片

状态：开发候选，完整 Windows 门禁通过，离线 Profile 与负责人真机验收待完成。负责人已授权六项优化，当前在 `codex/20261101-mobile-reading-navigation` 分支推进；不包含合并或正式发布授权。手机保留已通过原发布场景验收的 PR #130 安装包，后续源码不冒充该包内容。

## 当前行为与边界

- 发布、数字跳转和最新发言共用 `DiscussionNavigation` 的请求代次；同目标同范围在途请求复用，新目标取消旧结果的应用。最新发言在原详情页定位，保留单次“回到刚才”，不另建历史栈。
- 搜索／通知的帖子坐标先核对归属，然后直接读取真实目标窗口；子贴坐标直接选择对应子贴，避免默认首屏的多余读取。目标归属读取失败仍呈现原坐标重试入口，不回退到别的正文。
- 发布目标布局完成后后台刷新详情统计，不阻塞正文或连续第二次发布，不推导计数。统计有独立代次，同时绑定当前窗口请求代次；迟到旧统计不可覆盖新导航。普通预取与统计可以并行，撤权会使所有旧正文读取失效并清空窗口。
- 回复定位补齐在途状态、目标 ID／窗口包含关系校验及 403 撤权处理。自动定位失败停止；显式重试仍只读，不重新提交内容。
- 所谓取消是失效晚响应，不声称已经物理中断底层 HTTP。`40010` 清作者筛选的既有规则和权限核验保留。

## 六项范围与验收安排

| 范围 | 当前进度 | 必须验证 |
| --- | --- | --- |
| 统一定位入口和非阻塞统计 | 实现、直接回归及完整门禁通过，待真机验收 | 首次／连续发布、数字、搜索、通知、最新发言、跨范围、失败重试 |
| 阅读锚点 | 字符锚点及自动布局保持已实现，直接回归通过 | 前插裁剪、图片字体迟到、长楼层文字位置、用户拖动优先 |
| 内容重量缓存 | 权重窗口与展示尺寸解码已实现，直接回归通过 | 120 项上限、长文／媒体预算、可见与选择保护、反向游标、解码图片内存 |
| 长文解析复用 | 正文 State 复用 AST，355 项阅读回归通过 | 数据／语义变化失效，样式变化复用，选择复制与音频语义无回退 |
| 方向／速度／等待感知预取 | 有界提前与折返取消已实现，直接回归通过 | 目标优先、慢网、快速折返、无重复请求和裁剪往返 |
| 回到刚才 | 最新发言复用单书签；主楼／回复返回已接入字符锚点 | 跨窗口、长段落、字体改变、返回原筛选与文本位置 |

共享核心变化按高风险在最终源码上执行 `npm run check:apk`，再交负责人验收。开发批次先运行直接相关测试；不在每个局部保存后重复全量门禁。最终需要合成千层、20 分钟连续阅读和折返的离线 Profile 记录，记录请求数量／耗时、帧、RSS、监听及图片缓存；不把 Windows Mock 数字冒充手机测量，不自动向公网发帖或上传。

## 缓存与预取边界

- 窗口继续保留 120 条硬上限；额外按 UTF-16 正文／标签字节和每媒体 1 KiB 元数据估算内容重量，超过 1 MiB 时从阅读方向反侧整页裁剪。至少保留三页，避免长层频繁反复读取，因此这是软预算，不能称为实际堆或图片内存硬上限。可见页仍优先保护，游标仍使用真实页边界；选字和抽屉保护沿用页面现有应用条件。
- 13,400 字符合成楼层由最多 120 条降为三页 60 条；短回复仍可保留 120 条。预算是基于前期 AST 保留量测量选择的初始值，最终实机趋势仍需核对；不会把 DTO 字符估算冒充 AST 或 RSS。
- 正文有可靠尺寸的图片按实际布局尺寸与设备像素比解码；未知尺寸旧图片只限制解码宽度，极端长图不能据此宣称总内存硬上限。原图查看入口保留。
- 预取继续单请求串行，两侧都接近时跟随实际阅读方向；距离阈值从基础两屏按速度和最近一次等待扩展，最多四屏，另保留窗口边缘五条的触发条件。响应超过两秒退回两屏，主动定位沿用页面 readiness／控制器代次优先。折返后旧方向结果禁止应用，这是逻辑取消，不声称中断 HTTP。裁剪被保护拒绝后，同一楼层内像素抖动不会重下同页。
- `discussion_window_prefetch_test.dart` 新增三个行为回归：旧实现像素抖动重复读取、两侧优先方向错误、没有有界速度提前均失败（`reading-prefetch-behavior-baseline.log`；旧构造器仅增加未使用时钟参数以保持测试可编译）。新实现与 `discussion_window_test.dart`、`test/features/posts/discussion_window_controller_test.dart`、`markdown_image_decode_budget_test.dart`、`discussion_image_geometry_test.dart` 共 25 项通过（`reading-budget-prefetch-final.log`）。
- 图片测试使用 Mock HTTP／内存文件缓存，但由 Flutter 实际解码 4096×3072 PNG：旧实现占 50,331,648 字节，新实现 360 逻辑像素、DPR 2 的展示不超过 1,555,200 字节，卸载正文后活动图像监听归零。磁盘缓存／本地 HTTP 定时器混入早期测量的挂起记录不作为通过证据；首次联合 baseline 的预取部分编译失败也不作为行为证据。

## Profile 执行入口与当前状态

离线脚本 `integration_test/reading_profile_test.dart` 使用真实主题阅读页面与 1,200 层合成仓储；本机 HTTP 只供应合成 PNG，HTTP guard 拒绝设备外请求。按间隔采集 build/raster 帧分位、RSS、活动图片、已挂载锚点和有监听器的 Riverpod provider 数量；最后一项不是全进程订阅数量。原图、Markdown 和输入均为合成内容，不读取真实帖或执行业务写入。

运行命令：`flutter drive --driver=test_driver/reading_profile_test.dart --target=integration_test/reading_profile_test.dart --profile --no-dds --device-id=4b9c39b5 --dart-define=READING_SECONDS=1200`。驱动超时为 30 分钟，覆盖 20 分钟实际阅读及启动／收尾。

2026-11-01 已构建 ARM64 `site.wenyou.app.profile`／`0.11.0-profile (101)`，签名验证通过，SHA-256 `54608BFDD43BEEA9310ECC65F6E96E735E28240AE8F6FC852E12E3859306F9EC`。首次安装被 Android 拒绝（`INSTALL_FAILED_USER_RESTRICTED`），当前没有 Profile 测量结果；已请负责人允许 USB 安装。原 Debug 包更新时间仍为 07:21:36，不受此次 Profile 安装影响。包与日志归档在 `D:\codex-artifacts\wenyousite-mobile\reading-profile-20261101`。首次使用 20 分钟默认驱动的构建已中止并改为独立 30 分钟驱动，未冒称完成实测。

全量静态分析发现构造器初始化、导入排序和测试非空断言三处规范问题，修正后受影响文件分析零问题。最终 Profile 包重新构建并校验，SHA-256 `6E14766BCE8780B89B839451A9EBF80C6735DF76973402DEEA3ACA87B7A7E7B8`，应用 `lib` tree 为 `4fd7ee29261bb0c0e1670a16d61c8a30e282f33d`，Android tree 为 `948213a0815ae4c46530b60cb3ff4c3799605213`。初版包另存为 `app-profile-before-lint.apk`，当前待安装包为 `app-profile.apk`，70,185,192 字节；完整门禁已通过，仍无手机测量结果。Android 的 USB 安装许可尚待负责人处理，不重复尝试或绕过设备拒绝。


## 已执行证据

- 最终 `npm run check:apk -- -TestConcurrency 3` 返回 0（`reading-final-gate-complete.log`）：Flutter 8,180 项通过、1 项既有 Sentry 联网验收跳过，Windows 工具 49/49；格式、应用与生成客户端静态分析、架构、23 个模块文档、API 覆盖、契约校验／再生成一致性和公网只读契约检查均通过，ARM64 Debug 构建成功。应用源码与上述 `lib`／Android tree 一致；后续验收文档更新不改变此证据。
- Debug 候选归档：`D:\codex-artifacts\wenyousite-mobile\reading-navigation-4fd7ee29\app-debug.apk`，`site.wenyou.app.debug`／`0.11.0-debug (101)`，114,374,101 字节，SHA-256 `E1BBF3E10F3D80B72E3FD593D187AEA7B1A346640F7155FF271B58E167405FFD`。仅 ARM64、最低 API 26，APK v2 签名通过，证书 SHA-256 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`。此包未安装，手机 Debug 仍为 PR #130 已验收包。
- 门禁首次产物为 157,831,429 字节，ZIP 有约 43 MB 增量空洞；保留为 `app-debug-incremental.apk`。只删除当前 Worktree 两个生成 APK 输出文件，以完全相同 `flutter build apk --debug --target-platform android-arm64` 参数重新打包，未改变应用源码、依赖或 Android 配置，也未重复全量测试。重打包后 733 个 ZIP 条目数量与未压缩长度不变；`kernel_blob.bin` 的构建字节与压缩长度有变化，不声称两个 APK 二进制相同。构建日志与比较结果同目录归档，当前交付哈希以上述紧凑包为准。
- 全量回归曾暴露 `thread_detail_stack_test.dart` 的旧夹具：带 `postId` 的窗口仍返回 `target: null`，被未改动的 `mapDiscussionWindow` 精确目标校验拒绝。已核对 Backend `19a6c4ed` 的 `docs/discussion-navigation.md`：精确响应 target 非空。按该独立契约改为随请求返回 `target.id / number`，并加强整栈断言为所属子贴一次窗口、准确 `postId`、不读默认子贴；应用源码未因此调整。该文件 6 项重跑通过（`reading-stack-fixture-recheck.log`），原失败轮次保留，随后完整门禁通过。


- `WenyouMarkdownBody` 通过上游公开 `MarkdownBuilder` 构建组件，同一组节点同时用于块分类与显示，不再二次解析。缓存仅属于正文 State；正文或语法语义版本变化失效，主题／字号／字体变化只重建显示组件，链接手势随构建释放。未修改或复制第三方源码。
- 图片引用定义存在的正文才额外解析引用映射，判断涵盖引用／列表内定义；多对齐片段的图片前缀索引和段间距分类仅在正文准备时计算，避免每次样式变化重复计算前缀。
- `markdown_parse_reuse_test.dart` 旧实现首次解析两次、预期一次而失败（`reading-parse-baseline.log`）；新实现同正文一次，字号更新不重解析，正文／语义变化重新解析。`test/core/widgets/` 中全部名称含 `markdown` 的测试及 `reading_gallery_occurrences_test.dart`，共 355 项通过（`reading-parse-after.log`，实际文件清单归档为 `reading-parse-test-files.txt`）；相关文件静态分析零问题（`reading-parse-analyze.log`）。
- 本批不将正文拆成懒构建段落：当前选择、复制和引用需要连续可选择文本，单纯隐藏屏外段落会改变选择语义。先消除重复解析、控制窗口内容量，并在最终 Profile 中评估首次长文布局；不声称缓存能消除首次解析／布局开销。
- 阅读书签额外保存已布局段落的指纹、重复次序、字符位置和相对视口偏移，不保存正文或持久化进度。内容不再匹配时回退楼层偏移；字体／图片布局变化优先保留同一字符，手指或滑块接管时停止补偿。不会为寻找书签创建屏幕外正文。
- 已揭开的目标不再因后到布局重复对齐到楼层顶部。返回主楼／回复时，先用原 ID 读取真实窗口，再在目标已布局时根据文本书签求偏移；恢复原筛选范围的既有行为不变。
- `reading_text_anchor_test.dart` 中，旧实现图片长高、字号变化两例均失败（`reading-text-anchor-baseline.log`）；实现后图片、字号、返回原字符和手指接管通过。扩大至 `reading_quick_scroll_test.dart`、`reading_adaptive_scroll_test.dart`、`discussion_target_cover_test.dart`、`wenyou_discussion_scroll_policy_test.dart`、`discussion_navigation_test.dart` 共 52 项通过（`reading-anchor-regression.log`）。原前插／裁剪与真实主楼／回复编号返回组合另有 13 项通过（`reading-anchor-return.log`）。
- 锚点批次受影响文件 `dart analyze --fatal-infos` 零问题（`reading-anchor-analyze-final.log`）。控制器接近维护提醒行数，文本遍历与字符匹配已独立在 `reading_text_anchor.dart`，未机械迁移为 `part`；原滚动状态机和布局适配继续由控制器维护。
- `thread_publish_locate_flow_test.dart` 新增慢统计回归：旧页面显示楼层后未发起详情刷新，`reading-metadata-baseline.log` 断言失败；实现后验证先显示、两次连续发布互不等待、真实计数更新及旧统计拒绝覆盖。
- `discussion_navigation_test.dart` 覆盖 ID 请求复用、新旧结果竞争和失败重试，并保留原 ID／偏移／筛选返回测试。
- `discussion_window_controller_test.dart` 新增回复延迟回归：旧实现 20 次调度产生 20 次目标读取（`reading-reply-baseline.log`）；实现后只读一次，429 后停止，显式重试成功。
- `thread_detail_controller_test.dart` 覆盖后台统计期间预取继续，以及统计撤权后迟到正文不能回填。
- 入口扩大回归 `thread_detail_page_test.dart`、`thread_deleted_target_test.dart`：95 项通过（`reading-entry-window-recheck.log`）；直接窗口、编号和发布组合 `discussion_window_controller_test.dart`、`discussion_number_page_test.dart`、`thread_publish_locate_flow_test.dart`：22 项通过（`reading-unified-window.log`）。
- `thread_latest_real_window_test.dart`：四种视口／字体组合通过（`reading-latest-window.log`）。目标窗口的 Mock 游标显式覆盖还有下一页的场景，继续核验揭开后的普通预取错误只在列表提示。
- 首批直接受影响 Dart 文件静态分析零问题（`reading-navigation-final-analyze-recheck.log`）；用户接管取消导航后重跑发布与导航 14 项全部通过（`reading-user-navigation-recheck.log`）；23 个模块文档检查通过。完整门禁与 APK 证据见本节最终记录，后续真机验收仍未完成。
- 初次开发检查存在源文件修改与编译交叠导致的无效编译记录，保留 `reading-metadata-before.log`、`reading-metadata-after.log`，不将其作为旧行为失败证据；可靠旧行为证据以上述 `baseline` 命名的固定源码运行记录为准。

Backend `origin/dev`、已记录 revision 和公网只读检查一致：`19a6c4ed48829a781182527faaafce6e788e9e2e`，API `5.44.0-dev.20261024.3`。Foundation 已 fetch tags，最新正式版本仍为已锁定的 `v7.6.0`。本切片不更改跨端协议或视觉 Token。

Windows Dart JIT 的先期合成 Markdown 基线保存在 `D:\codex-artifacts\wenyousite-mobile\reading-benchmarks`：13,400 字符／200 段单次解析中位 18,917 μs；53,600 字符／800 段中位 68,593 μs。保留 120 份 13,400 字符 AST 的进程 RSS 增量约 58.6 MB。这些数字仅说明重复解析与保留量值得控制，不是 Android 帧性能，也不能直接当作 DTO 缓存的内存大小。

## 后续候选负责人手测清单

本清单对应本分支最终候选，不以 PR #130 已通过的原 APK 代替新版本验收。完整门禁、APK 哈希和安装身份核验完成后，才将新 Debug 包交负责人执行：

1. 在原场景首次发布、连续第二次发布；均定位到新楼层，随后详情计数更新，不等待统计才能继续阅读。
2. 从通知、搜索、楼层编号和最新发言进入同一讨论，核对实际目标与筛选；定位失败只重试读取，不重新发表。
3. 长楼层中部跳到远处，再“回到刚才”，核对原范围和原段文字。改变字号后再次验证；正在拖动时不能被校正拉走。
4. 混排长文与图片向前／向后翻页，等图片出现；前插和窗口裁剪后正在读的文字应保持位置，选字／编辑抽屉期间不裁剪。
5. 慢网、断网、快速折返时仍可阅读已有正文；错误可显式重试，不自动循环定位或连续请求同一页。

20 分钟离线 Profile 只验证合成负载，不代替负责人对真实阅读手感及业务场景的验收。Web 适用性另见 [交接说明](mobile-reading-web-handoff.md)。

# 阅读性能后续切片

状态：负责人真机验收通过，完整 Windows 门禁与 20 分钟离线 Profile 通过；2026-11-01 负责人明确授权合并 PR #131。当前分支为 `codex/20261101-mobile-reading-navigation`，实际合并状态以 PR 为准；本次不包含正式发布。此次真机确认针对后续 Debug 候选，独立于 PR #130 的原场景验收。

## 负责人验收结果

2026-11-01，负责人针对 15:22:22 更新的“温油站 Debug”明确反馈“没问题了”。本次询问与确认覆盖：连续两次发布均正常定位；长文跳转后“回到刚才”返回原文字；图片出现及向前／向后翻页时阅读位置稳定。按该范围记录真机验收通过，不把未单独反馈的矩阵项扩写为人工逐项复验。

对应候选记录提交 `e3a365ca58329c459c80be1e85beff417a4ac4e7`，应用 `lib` tree `4fd7ee29261bb0c0e1670a16d61c8a30e282f33d`，Debug APK SHA-256 `E1BBF3E10F3D80B72E3FD593D187AEA7B1A346640F7155FF271B58E167405FFD`。本次只更新验收文档，复用同一应用源码的完整门禁、构建和 Profile 证据，不重复运行应用测试或重建。已测得的 244.066 ms 单帧构建峰值仍保留为后续优化项，验收通过不抹去该限制。

## 合并前整合验证

2026-11-01 负责人明确授权合并 PR #131 后，整合 `origin/dev@78fd7883535c528ec8030540687a779e6cccd79c`（PR #132 自定义字体换行与混排修复）。唯一冲突为 CHANGELOG，保留双方记录；正文解析复用与字体段落合并实现自动合并后已审查。整合后应用 `lib` tree 为 `6c49332c30ca6f6d5dabc15e66f483e80b8cae0c`，Android tree 仍为 `948213a0815ae4c46530b60cb3ff4c3799605213`。

整合源码执行 `npm run check:apk -- -TestConcurrency 3`，退出码 0：Flutter 8,208 项通过、1 项既有 Sentry 条件跳过，Windows 工具 49/49；格式、全量静态分析、架构、23 个模块文档、API 覆盖、契约及生成一致性全部通过，ARM64 Debug 构建成功。归档目录 `D:\\codex-artifacts\\wenyousite-mobile\\pr131-integration-20261101` 保存完整门禁日志、APK 与历史工作区证据。

整合 APK 为 `site.wenyou.app.debug`／`0.11.0-debug (101)`，114,379,841 字节，SHA-256 `509496E7B188BA3CCDEF5CF002B2DC699501D8529B6CB766F21AA50D012FECB8`；仅 ARM64、最低 API 26、v2 签名通过。此包未安装，前述真机验收与 20 分钟 Profile 仍绑定原 `4fd7ee29` 候选，不以原测量冒充整合包的手机测量。门禁结束后只补充文档，不改变已验证应用源码。

## 当前行为与边界

- 发布、数字跳转和最新发言共用 `DiscussionNavigation` 的请求代次；同目标同范围在途请求复用，新目标取消旧结果的应用。最新发言在原详情页定位，保留单次“回到刚才”，不另建历史栈。
- 搜索／通知的帖子坐标先核对归属，然后直接读取真实目标窗口；子贴坐标直接选择对应子贴，避免默认首屏的多余读取。目标归属读取失败仍呈现原坐标重试入口，不回退到别的正文。
- 发布目标布局完成后后台刷新详情统计，不阻塞正文或连续第二次发布，不推导计数。统计有独立代次，同时绑定当前窗口请求代次；迟到旧统计不可覆盖新导航。普通预取与统计可以并行，撤权会使所有旧正文读取失效并清空窗口。
- 回复定位补齐在途状态、目标 ID／窗口包含关系校验及 403 撤权处理。自动定位失败停止；显式重试仍只读，不重新提交内容。
- 所谓取消是失效晚响应，不声称已经物理中断底层 HTTP。`40010` 清作者筛选的既有规则和权限核验保留。

## 六项范围与验收安排

| 范围 | 当前进度 | 必须验证 |
| --- | --- | --- |
| 统一定位入口和非阻塞统计 | 实现、直接回归及完整门禁通过，连续发布已获负责人确认 | 首次／连续发布、数字、搜索、通知、最新发言、跨范围、失败重试 |
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

## Profile 执行入口与当前结果

离线脚本 `integration_test/reading_profile_test.dart` 使用真实主题阅读页面与 1,200 层合成仓储；设备本机 HTTP 只供应合成 PNG，HTTP guard 拒绝设备外请求。当前仅在测试 binding 登记模拟输入客户端，仍点击真实编号／返回入口，不测原生 IME。帧调度为 `fullyLive`，交互按请求完成、实际目标和遮罩状态确认，不等待全局永久空闲。

运行入口：`flutter drive --driver=test_driver/reading_profile_test.dart --target=integration_test/reading_profile_test.dart --profile --no-dds --device-id=4b9c39b5 --dart-define=READING_SECONDS=1200`。本轮为避免重复安装，以 ADB 安装并核对设备哈希后启动独立 Profile，再以 `--use-existing-app` 连接；驱动超时 30 分钟，并在失败时保存部分数据。没有启动正常应用入口或执行业务写入。

2026-11-01 15:00:56 至约 15:20:58 完成测量，进程退出码 0、`All tests passed`。设备 `2509FPN0BC`，Android 16，1200×2608／DPR 3，ARM64。测量 APK 为 `site.wenyou.app.profile`／`0.11.0-profile (101)`，SHA-256 `948B7DC0D213B74DE7900CB9B65B4B52D7A68E7A7D05A9841A22FEAA88C8101A`；15:00:55 安装、设备内哈希一致、签名通过。归档目录：`D:\codex-artifacts\wenyousite-mobile\reading-profile-20261101`，包含 APK、`measured-run-identity.json`、原始 `measured-response.json`、`measured-summary.json` 和各次失败／构建日志。应用 `lib` tree 为 `4fd7ee29261bb0c0e1670a16d61c8a30e282f33d`，Android tree 为 `948213a0815ae4c46530b60cb3ff4c3799605213`，与完整门禁及 Debug 候选相同。

| 实测项目 | 结果 |
| --- | --- |
| 时长／循环／采样 | 1,202 秒／382 轮／38 个采样窗口 |
| 窗口请求 | 174 次，最高并发 1；其中 22 次模拟断网失败 |
| 精确跳转／返回 | 64 次各通过；每次目标读取一次，返回楼层一致，偏移最大差约 1 逻辑像素 |
| 图片请求／活动监听 | 146 次本机合成图片请求；采样活动图片最多 2，离页后 0 |
| 已挂载阅读锚点／provider | 采样锚点最多 10，离页断言为 0；有监听器的 Riverpod provider 始终为 5，不代表全进程订阅数量 |
| RSS | 首次 338.37 MiB、末次 339.92 MiB，采样范围 330.76～382.43 MiB |
| RSS 前／后五分钟中位 | 352.16／343.96 MiB，本轮未观察到持续增长趋势，不等于无限时长无泄漏证明 |
| 图片缓存 | 采样峰值 97.57 MiB；这是 Flutter 图片缓存统计，不能当作进程图片总内存 |
| build 窗口 P95 | 38 个窗口 P95 的中位 2.385 ms，最大 3.127 ms |
| raster 窗口 P95 | 38 个窗口 P95 的中位 1.684 ms，最大 1.938 ms |
| 单帧峰值／超阈值 | build 最大 244.066 ms，77,340 个采样帧中约 0.390% 超过 16.67 ms；raster 最大 10.812 ms，无帧超过 16.67 ms |

帧 P95 不是把全部帧汇总后得到的全局 P95；77,340 是采样窗口累计帧数，最后不足一个采样周期的帧未计入该统计。16.67 ms 是分析阈值，不代表手机全程使用固定刷新率。单帧构建峰值已证实，未记录对应调用栈，不能直接断言是某一解析或布局函数造成；本轮不宣称长文完全无卡顿。没有同条件旧版手机基线，不给出性能改善百分比；初次长文解析／布局仍有成本，进一步缩短峰值是剩余优化项。

测量结束已停止独立 Profile 进程。15:22:22 已保留数据覆盖安装下节 Debug 候选，设备内 SHA-256 与归档一致，代理未自动启动；随后负责人真实阅读与发布场景验收通过，范围见上节。完整手测清单见文末。

## 已执行证据

- 2026-11-01 下午负责人连接手机后，原 Profile 包成功安装，设备内 SHA-256 与 `6E14766B…7E7B8` 一致；USB 安装阻塞解除。首次运行停在全局 `pumpAndSettle` 等待，未产出采样，主动停止并保留日志，不计入 20 分钟测量。测试随后改为自然帧调度、有时限的交互等待与目标状态校验，并保存失败时的部分数据。
- Profile 试跑进一步暴露测试输入问题：默认 integration binding 不登记模拟键盘，`tester.enterText` 使用 `-1` client ID，而 Flutter `text_input.dart` 只在 Debug 断言路径接受该 ID，因此 Profile 中输入未生效、按钮仍禁用、目标请求为零。先前补输入后等待的尝试未解决，失败记录保留。测试专用 binding 显式登记模拟输入，使用真实 client ID；仍点击真实编号按钮并核验目标与返回，不将此脚本当作原生键盘验收。此轮只更改 `integration_test`／驱动，应用 `lib` 与 Android 配置未改。
- 随后返回校验曾在预期第 3 层时读到第 6 层；把书签取值移至点击时点后仍失败，未据此认定应用修复完成。进一步发现等待函数会在旧窗口仍可见时通过条件，再固定等待 250 ms 后不复查新请求／新遮罩。改为同时确认仓储在途请求归零、实际目标条目已布局、输入与遮罩均消失，并连续三次检查。`test/features/threads/thread_reading_profile_return_test.dart` 使用相同长短文夹具、DPR 3，新增组合 Widget 回归通过（楼层与偏移），但它与手机系统字体不同，不冒充原场景复现证据。修正后的手机首轮目标读取、返回和采样于 15:01 正常通过；完整 20 分钟结果见上节。
- 原验收候选的 `npm run check:apk -- -TestConcurrency 3` 返回 0（`reading-final-gate-complete.log`）：Flutter 8,180 项通过、1 项既有 Sentry 联网验收跳过，Windows 工具 49/49；格式、应用与生成客户端静态分析、架构、23 个模块文档、API 覆盖、契约校验／再生成一致性和公网只读契约检查均通过，ARM64 Debug 构建成功。应用源码与上述 `lib`／Android tree 一致；后续验收文档更新不改变此证据。
- Debug 候选归档：`D:\codex-artifacts\wenyousite-mobile\reading-navigation-4fd7ee29\app-debug.apk`，`site.wenyou.app.debug`／`0.11.0-debug (101)`，114,374,101 字节，SHA-256 `E1BBF3E10F3D80B72E3FD593D187AEA7B1A346640F7155FF271B58E167405FFD`。仅 ARM64、最低 API 26，APK v2 签名通过，证书 SHA-256 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`。此包已于 2026-11-01 15:22:22 保留数据安装至 Debug，设备内哈希一致；代理未自动启动，后续已由负责人验收通过。
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
- 首批直接受影响 Dart 文件静态分析零问题（`reading-navigation-final-analyze-recheck.log`）；用户接管取消导航后重跑发布与导航 14 项全部通过（`reading-user-navigation-recheck.log`）；23 个模块文档检查通过。该批次当时尚未完成真机验收，后续确认范围见开头验收结果。
- 初次开发检查存在源文件修改与编译交叠导致的无效编译记录，保留 `reading-metadata-before.log`、`reading-metadata-after.log`，不将其作为旧行为失败证据；可靠旧行为证据以上述 `baseline` 命名的固定源码运行记录为准。

Backend `origin/dev`、已记录 revision 和公网只读检查一致：`19a6c4ed48829a781182527faaafce6e788e9e2e`，API `5.44.0-dev.20261024.3`。Foundation 已 fetch tags，最新正式版本仍为已锁定的 `v7.6.0`。本切片不更改跨端协议或视觉 Token。

Windows Dart JIT 的先期合成 Markdown 基线保存在 `D:\codex-artifacts\wenyousite-mobile\reading-benchmarks`：13,400 字符／200 段单次解析中位 18,917 μs；53,600 字符／800 段中位 68,593 μs。保留 120 份 13,400 字符 AST 的进程 RSS 增量约 58.6 MB。这些数字仅说明重复解析与保留量值得控制，不是 Android 帧性能，也不能直接当作 DTO 缓存的内存大小。

## 负责人手测清单与覆盖边界

本清单对应本分支最终候选，不以 PR #130 已通过的原 APK 代替新版本验收。完整门禁、Profile、APK 哈希和安装身份核验已完成；负责人本次确认的具体范围见开头验收结果，其余条目保留为回归清单：

1. 在原场景首次发布、连续第二次发布；均定位到新楼层，随后详情计数更新，不等待统计才能继续阅读。
2. 从通知、搜索、楼层编号和最新发言进入同一讨论，核对实际目标与筛选；定位失败只重试读取，不重新发表。
3. 长楼层中部跳到远处，再“回到刚才”，核对原范围和原段文字。改变字号后再次验证；正在拖动时不能被校正拉走。
4. 混排长文与图片向前／向后翻页，等图片出现；前插和窗口裁剪后正在读的文字应保持位置，选字／编辑抽屉期间不裁剪。
5. 慢网、断网、快速折返时仍可阅读已有正文；错误可显式重试，不自动循环定位或连续请求同一页。

20 分钟离线 Profile 只验证合成负载，不代替负责人对真实阅读手感及业务场景的验收。Web 适用性另见 [交接说明](mobile-reading-web-handoff.md)。

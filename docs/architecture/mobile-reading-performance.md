# 阅读性能后续切片

状态：开发中，尚未交付后续真机候选。负责人已授权六项优化，当前在 `codex/20261101-mobile-reading-navigation` 分支推进；不包含合并或正式发布授权。手机保留已通过原发布场景验收的 PR #130 安装包，后续源码不冒充该包内容。

## 当前行为与边界

- 发布、数字跳转和最新发言共用 `DiscussionNavigation` 的请求代次；同目标同范围在途请求复用，新目标取消旧结果的应用。最新发言在原详情页定位，保留单次“回到刚才”，不另建历史栈。
- 搜索／通知的帖子坐标先核对归属，然后直接读取真实目标窗口；子贴坐标直接选择对应子贴，避免默认首屏的多余读取。目标归属读取失败仍呈现原坐标重试入口，不回退到别的正文。
- 发布目标布局完成后后台刷新详情统计，不阻塞正文或连续第二次发布，不推导计数。统计有独立代次，同时绑定当前窗口请求代次；迟到旧统计不可覆盖新导航。普通预取与统计可以并行，撤权会使所有旧正文读取失效并清空窗口。
- 回复定位补齐在途状态、目标 ID／窗口包含关系校验及 403 撤权处理。自动定位失败停止；显式重试仍只读，不重新提交内容。
- 所谓取消是失效晚响应，不声称已经物理中断底层 HTTP。`40010` 清作者筛选的既有规则和权限核验保留。

## 六项范围与验收安排

| 范围 | 当前进度 | 必须验证 |
| --- | --- | --- |
| 统一定位入口和非阻塞统计 | 首批实现及直接回归通过，尚待最终门禁 | 首次／连续发布、数字、搜索、通知、最新发言、跨范围、失败重试 |
| 阅读锚点 | 字符锚点及自动布局保持已实现，直接回归通过 | 前插裁剪、图片字体迟到、长楼层文字位置、用户拖动优先 |
| 内容重量缓存 | 待实现 | 120 项上限、长文／媒体预算、可见与选择保护、反向游标、解码图片内存 |
| 长文解析复用 | 正文 State 复用 AST，355 项阅读回归通过 | 数据／语义变化失效，样式变化复用，选择复制与音频语义无回退 |
| 方向／速度／等待感知预取 | 待实现 | 目标优先、慢网、快速折返、无重复请求和裁剪往返 |
| 回到刚才 | 最新发言复用单书签；主楼／回复返回已接入字符锚点 | 跨窗口、长段落、字体改变、返回原筛选与文本位置 |

共享核心变化按高风险在最终源码上执行 `npm run check:apk`，再交负责人验收。开发批次先运行直接相关测试；不在每个局部保存后重复全量门禁。最终需要合成千层、20 分钟连续阅读和折返的离线 Profile 记录，记录请求数量／耗时、帧、RSS、监听及图片缓存；不把 Windows Mock 数字冒充手机测量，不自动向公网发帖或上传。

## 已执行证据

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
- 最终直接受影响 Dart 文件静态分析零问题（`reading-navigation-final-analyze-recheck.log`）；用户接管取消导航后重跑发布与导航 14 项全部通过（`reading-user-navigation-recheck.log`）；23 个模块文档检查通过。完整统一门禁、后续 APK 与后续真机验收尚未执行。
- 初次开发检查存在源文件修改与编译交叠导致的无效编译记录，保留 `reading-metadata-before.log`、`reading-metadata-after.log`，不将其作为旧行为失败证据；可靠旧行为证据以上述 `baseline` 命名的固定源码运行记录为准。

Backend `origin/dev`、已记录 revision 和公网只读检查一致：`19a6c4ed48829a781182527faaafce6e788e9e2e`，API `5.44.0-dev.20261024.3`。Foundation 已 fetch tags，最新正式版本仍为已锁定的 `v7.6.0`。本切片不更改跨端协议或视觉 Token。

Windows Dart JIT 的先期合成 Markdown 基线保存在 `D:\codex-artifacts\wenyousite-mobile\reading-benchmarks`：13,400 字符／200 段单次解析中位 18,917 μs；53,600 字符／800 段中位 68,593 μs。保留 120 份 13,400 字符 AST 的进程 RSS 增量约 58.6 MB。这些数字仅说明重复解析与保留量值得控制，不是 Android 帧性能，也不能直接当作 DTO 缓存的内存大小。

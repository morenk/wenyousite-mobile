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
| 阅读锚点 | 继续实现 | 前插裁剪、图片字体迟到、长楼层文字位置、用户拖动优先 |
| 内容重量缓存 | 待实现 | 120 项上限、长文／媒体预算、可见与选择保护、反向游标、解码图片内存 |
| 长文解析复用 | 已定位重复解析入口，待实现 | 数据／语义变化失效，样式变化复用，选择复制与音频语义无回退 |
| 方向／速度／等待感知预取 | 待实现 | 目标优先、慢网、快速折返、无重复请求和裁剪往返 |
| 回到刚才 | 最新发言已复用现有单书签，长段落恢复待实现 | 跨窗口、长段落、字体改变、返回原筛选与文本位置 |

共享核心变化按高风险在最终源码上执行 `npm run check:apk`，再交负责人验收。开发批次先运行直接相关测试；不在每个局部保存后重复全量门禁。最终需要合成千层、20 分钟连续阅读和折返的离线 Profile 记录，记录请求数量／耗时、帧、RSS、监听及图片缓存；不把 Windows Mock 数字冒充手机测量，不自动向公网发帖或上传。

## 已执行证据

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

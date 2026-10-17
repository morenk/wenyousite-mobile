# 主题与动态紧凑底栏

状态：视觉候选／待负责人真机验收。

## 范围与来源

- 主题详情把加油从更多菜单移到回复框左侧，与喜欢、收藏、订阅并排；本人主题仍不提供自赏入口。没有其他操作的私密读者不显示空更多菜单。
- 动态详情把点赞、收藏、加油从正文末尾移到同款固定底栏；右侧为“回复一下”，移除独立评论图标与悬浮发表按钮。评论总数仍在评论排序行，回复入口保留完整评论计数语义。动态不新增订阅。
- 共享底栏外壳与浅色输入外观，保留系统安全区、48dp 最小命中区及原权限、登录、在途和业务回调。动态禁止新互动时仍可撤销已有点赞／收藏，本人加油累计保持只读。正文、API、存储、编辑器与原生配置未修改。
- Windows 独立 Worktree：`D:/codex-worktrees/mobile-compact-bottom-actions/wenyousite-mobile`，分支 `codex/20261018-compact-bottom-actions`。
- 从已更新的 `origin/dev` `60a118084f680c270f0e05e6acb02659ee23d399` 创建，纳入已验收颜色 PR #106 的已提交依赖 `20445a215e0690037344d817670d43ea6016aa95`。本 PR 先以该任务分支为比较基线，仅呈现新布局差异；依赖仍需另行获准合并。
- Foundation fetch 后正式最新仍为 `v7.5.0`；锁定 `fef249d8856f5ed08f55eab69a2a2ed01b2742ce`。固定 Backend `08bbf5dbcd791270764fc2152fe9b61f683d7fa1`／API `5.39.0-dev.20261017.1`，本轮只读 `/meta` 核验 `buildSha` 与契约版本，未改变运行配置或消费者契约。
- Auto-review 偏好已传递；本任务实际宿主为 `approval_policy=never`，工具无审批配置入口，未设置或宣称启用 `auto_review`。

## 离线验证

全部使用 fake repository／离线 Widget，未对真实服务执行业务写入。

定向测试范围：

- `test/features/threads/thread_detail_bottom_bar_test.dart`
- `test/features/threads/thread_detail_page_test.dart`
- `test/features/threads/thread_reading_quick_scroll_test.dart`
- `test/features/social/thread_interaction_actions_test.dart`
- `test/features/moments/moment_detail_interaction_bar_test.dart`
- `test/features/moments/moment_pages_test.dart`
- `test/features/moments/moment_reading_quick_scroll_test.dart`

上述 7 文件共 172 项通过。覆盖 320／360dp 明暗与 1.5 倍字底栏图片、320dp 两倍字无溢出、加油只读／本人隐藏／原回调、游客登录、不可互动时撤销已有关系、空更多菜单，以及 320／360／400／600dp 两倍字快翻避让、末端可达、评论编辑器开关与目标定位。大额计数使用 Foundation 紧凑值，完整精确值保留在语义树；极窄与两倍字回复文案允许省略，按钮完整语义不截断。

组件图片位于 `test/features/threads/goldens/thread_bottom_bar_*` 和 `test/features/moments/goldens/moment_detail_bottom_bar_*`；对应详情与快翻整页 Golden 已更新并审图。它们是实际 Widget 渲染，不代表真机画面或负责人验收。23 个模块文档检查、架构检查与格式检查通过。首轮独立分析发现测试文件 3 条 import 顺序提示，已修正并保留日志；官方候选入口复核全仓 1407 文件格式无变化、应用与生成 SDK 分析零问题、上述 172 项定向测试及 Golden 全部通过。

稳定候选冻结 3180 个源码、测试和构建输入（文档不计入），SHA-256：`8b12eb3fd7ac35cb7a355f7d1d9aec2ae42c6e82cd02dc5816a627ca581d5834`。本机清单：`.dart_tool/compact-bottom-actions-frozen-inputs.json`。

## Debug 候选

官方 `npm run candidate:apk -- <上述七个测试文件> -TestConcurrency 2` 完整成功，候选构建前后 3180 输入复核零漂移。安装包：

- 文件：`D:/codex-artifacts/compact-bottom-actions/wenyou-compact-bottom-actions-0.9.0-debug-99-589fcadb.apk`。
- 大小：112813318 bytes。
- SHA-256：`589fcadb932ec0093da5748f5f789102b3b923d1659a24c3d3fd508aaa1560d0`。
- 包：`site.wenyou.app.debug`，应用名“温油站 Debug”，版本 `0.9.0-debug`、构建 99，仅 `arm64-v8a`；aapt 包身份核验和 apksigner 签名验证通过。
- 本机日志：`.dart_tool/compact-candidate-apk.log`。已有 flutter_image_compress_common 插件产生未来 Kotlin 迁移提示，不影响本轮构建；本切片不升级依赖。
- 本实现任务不接管设备；ADB 覆盖安装与设备内哈希由治理任务核验记录。本文不把构建成功视为已安装或真机验收通过。

## 待验收

负责人在本任务候选 Debug 中手动查看主题与动态底栏，确认窄屏／大字观感、点加油进入原面板、回复后返回阅读和系统安全区。真实环境自动化只读；登录、加油、点赞、收藏、发表评论等真实写入由负责人自行操作。未自动启动 App 或接管其他设备调试会话。

本轮为普通展示切片：候选使用官方 `candidate:apk` 精准测试入口；全量集成门禁留在负责人验收通过后、合并前执行。没有批准即不合并或部署。

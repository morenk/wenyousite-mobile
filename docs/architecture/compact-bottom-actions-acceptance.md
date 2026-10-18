# 主题与动态紧凑底栏

状态：Debug 候选已覆盖安装，继续同批热重载布局反馈／待负责人真机验收。

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

## 治理任务安装核验

2026-10-18 06:28:09（Asia/Shanghai），治理任务在负责人已连接并手动打开的 Xiaomi 2509FPN0BC（设备 `4b9c39b5`）上完成 `adb install -r`，返回 `Success`。安装源为应用提交 `886296204afd4c31d7549c1d5679655f22cb63e2` 的上述 APK；`site.wenyou.app.debug` 更新时间、`0.9.0-debug`／99 身份均已核验，设备内 `base.apk` SHA-256 与候选 `589fcadb932ec0093da5748f5f789102b3b923d1659a24c3d3fd508aaa1560d0` 完全一致。

此前尝试连接现有进程但未发现 VM 服务，等待 attach 已停止，没有热重载生效。安装前只读确认停留在“我的”页，未打开编辑器；本次不卸载、不清数据，草稿和应用数据保留，未由 agent 自动启动 App 或执行业务写入。设备临时截图已删除，本机截图和调试日志不提交。安装回执保存在 `D:/codex-artifacts/compact-bottom-actions/install-20261018.json`。

负责人已获知需重新手动打开“温油站 Debug”查看主题及动态底栏；安装成功不代表验收通过。PR #107 保持 Draft，依赖 #106，尚未合并。

## 横向压缩反馈候选

负责人要求进一步压缩左侧操作，为回复输入留出宽度，并允许千位计数使用 k。本轮保持相同 Worktree 与 PR，不重新构建或安装 APK：共享底栏两侧改为 8dp，主题移除输入前额外 4dp 间隔；动态由固定 64dp 槽改为内容自适应且至少 48dp，输入前保留 4dp 留白。SafeArea、大屏最大内容宽度、权限与业务回调不变。

主题底栏喜欢和动态底栏三类计数局部使用 k／m 等短值，千位以下保持原整数，完整数值仍在无障碍语义中；不改变列表等其他场景的 Foundation 格式。动态计数不再缩放字体。确定性字体、普通字号下，320／360dp 主题回复区从 100／140dp 增至 112／152dp，动态示例（12,345 点赞、67 收藏、123,000 升）增至约 151.8／191.8dp。

本轮格式化边界与主题／动态底栏 3 个文件共 32 项定向测试及 Golden 通过；覆盖明暗、320／360dp、1.5 倍字，以及 320dp 两倍字同时显示 9.9k／999k／9.9m 时回复仍至少 48dp、计数不缩小且无溢出。新增图片为 `test/features/moments/goldens/moment_detail_bottom_bar_320_large_counts.png`。极窄场景回复文字可省略，完整操作语义保留。

最终应用源码为 `904c98870d30541f2d9af133a54f05cb9afba4da` 加本轮未提交布局修改，724 个 `lib/` 文件的 SHA-256 清单摘要为 `a8adaa37c1c0d69701406da6e5bedf4404aef9a992a58c61b46b17ff5487758e`，本机清单 `.dart_tool/compact-spacing-source.json`，测试日志 `.dart_tool/compact-spacing-feedback-final.log`。此摘要仅覆盖应用源码，不等同于首次 APK 的构建输入摘要。治理任务独占设备调试并记录实际 reload 回执；热重载画面不能以先前安装包哈希代替源码身份。本轮组件图片已审阅，整页 Golden 和最终交付门禁待视觉反馈收敛后更新，不以之前 172 项通过代表本轮完整检查。

2026-10-18，治理任务已将上述 `a8adaa37` 源码热重载至本任务 Xiaomi 设备 `4b9c39b5`：`fullRestart=false`、返回 `code=0`，`Reloaded 2 of 4782 libraries`，耗时 2631ms；原进程 PID 23771 保持，没有重新安装或重启。负责人手动重开后连接的调试会话仍由治理任务独占。只读截图当时仍在首页，主题与动态底栏实际真机画面待负责人进入页面验收；未执行业务写入。回执 `D:/codex-artifacts/compact-bottom-actions/reload-spacing-20261018.json`，私有日志和调试连接信息不提交。

收尾静态检查发现并删除一条已不再使用的 Foundation import，执行与布局逻辑未变。清理后的最终 `lib/` 清单摘要为 `7127877e71319c7518ce84dc397e5c8edd7caf443f122640e28cab561f0325b8`；同 8 个变更 Dart 文件格式检查零改动、定向分析零问题，23 个模块文档检查通过。分析日志 `.dart_tool/compact-spacing-analyze.log`。未重新构建或安装，未提交或推送本轮未收敛反馈。

## 数字下置反馈候选

负责人在查看他人主题后明确要求数字放到图标下方。本轮仍沿用原 Worktree、PR 与治理任务控制的热重载会话，不构建 APK、不安装、不逐轮推送。所有主题详情入口共用唯一底栏；他人普通登录用户显示喜欢、收藏、订阅、加油四项，本人隐藏加油，自动更新身份隐藏订阅，并非遗漏另一套页面布局。

主题喜欢数与动态三类计数改为图标下置数字。底栏专用共享内容保留同高计数行，主题无数字的收藏、订阅、加油仍与喜欢图标对齐。仅底栏开启 `stackSupporting`，其他互动控件仍为原有横向排布。数字继续 k／m 紧凑格式且不缩字；相邻数字至少 8dp 空隙，长数字自然扩展自身宽度。每个点击目标仍至少 48dp 且不重叠，保持完整标签、禁用、在途和重试语义。

普通字号和 1.5 倍字的操作行仍为 48dp。他人主题四项原本已占 192dp，本轮普通数值下不再额外节省横向宽度；320／360dp 回复入口仍为 112／152dp。收益来自长计数不再与图标累加宽度。动态普通示例三项收敛至各 48dp，320／360dp 回复入口为 156／196dp。两倍字组件操作行实际为 57dp（主题图片含 16dp 安全区共 73dp），允许回复文案省略，数字保持正常缩放。

6 个直接相关测试文件共 62 项通过，包含底栏、计数边界、互动控件默认横排、订阅失败重试与提交中禁用。新增断言覆盖他人四图标中心对齐、命中区不重叠、数字位于图标下方，以及 320dp 两倍字三组四字符数字间距。首次新增订阅重试测试暴露外层语义标签为空，已改为共享按钮最外层完整按钮语义后复验通过；未放宽断言。日志 `.dart_tool/compact-count-below-final-verified.log`。12 个变更文件静态分析零问题，最终语义与测试补充后的 4 文件复核亦零问题。

实际 Widget 图片包括 `test/features/threads/goldens/thread_bottom_bar_320_light_normal.png`、`thread_bottom_bar_320_other_large_counts.png`，以及 `test/features/moments/goldens/moment_detail_bottom_bar_320_light_normal.png`、`moment_detail_bottom_bar_320_large_counts.png`。明暗、320／360dp、大字组件均已更新并审图；整页 Golden 和合并前完整门禁仍待本批视觉收敛后执行。

本轮应用 725 个 `lib/` 文件摘要为 `996138d46680e98d639fc978e2bfce468b4fae96c4b36a431b755397c52b65c2`，基于 `904c9887` 加同批未提交修改，清单 `.dart_tool/compact-count-below-source.json`。治理任务负责记录该版本的实际热重载与真机反馈，不以自动测试或前次热重载代替本版验收。

治理任务已将 `996138d4` 热重载到原设备会话：`fullRestart=false`，返回 `code=0`，`Reloaded 22 of 4783 libraries`，耗时 2710ms，原进程 PID 3090 保持。只读真机画面确认约 400dp 浅色他人主题中数字位于爱心下方、四图标对齐，原阅读位置保留；没有重装、热重启或业务写入。回执 `D:/codex-artifacts/compact-bottom-actions/reload-count-below-20261018.json`，含用户内容的截图只在忽略的私有目录保存，不提交。动态真机与整体观感仍待负责人反馈。最终 13 文件格式检查零改动、23 模块文档检查通过。

## 真实零值与加油累计反馈候选

负责人要求没有数量时显示 0。本阶段先使用已有真实统计：主题喜欢与加油累计、动态喜欢／收藏／加油均保留真实 0，并与非零值一样显示在图标下。主题加油使用 `detail.tipTotal`，视觉短值与动态一致，读屏保留完整累计升数；现有加油流程成功回调已经刷新详情，不新增业务写入或额外计数更新请求。

现行主题 DTO 尚无收藏总数、订阅人数，相关入口继续空行占位，不把缺失数据或当前用户的布尔状态伪装为 0／1。负责人随后已选择补齐后端真实总数，由治理任务推进 Backend 契约；Mobile 等待后端稳定提交再同步，不提前修改或猜测 DTO。该后续属于契约变更，将执行相应完整门禁，本段纯展示阶段不重新构建 APK。

本阶段 50 项底栏／订阅定向测试及 Golden 通过，新增真实零值对齐断言；5 个变更文件定向静态分析零问题。主题组件图 `test/features/threads/goldens/thread_bottom_bar_320_zero_counts.png` 显示真实喜欢 0／累计加油 0、缺统计处为空；动态 `test/features/moments/goldens/moment_detail_bottom_bar_320_zero_counts.png` 覆盖暗色两倍字三项真实 0，已审阅。应用 725 个 `lib/` 文件摘要 `c98a9ef9776e098bcbcd9ea5bb10167ed351257e97631971afa370e53d70800d`，清单 `.dart_tool/compact-zero-counts-source.json`；测试与分析日志 `.dart_tool/compact-zero-counts-test.log`、`.dart_tool/compact-zero-counts-analyze.log`。等待治理任务实际 reload 与负责人反馈，不自动构建、安装或推送。

治理任务已将 `c98a9ef9` 热重载到原会话，返回 `code=0`，`Reloaded 22 of 4783 libraries`，耗时 2167ms，PID 3090 保持。只读真机截图确认他人主题喜欢非零、累计加油真实 0 均位于图标下且对齐；回执 `D:/codex-artifacts/compact-bottom-actions/reload-zero-counts-20261018.json`。契约同步前的本机可回滚阶段保存在 `D:/codex-artifacts/compact-bottom-actions/zero-counts-checkpoint`：基准 `904c9887` 的二进制补丁 SHA-256 为 `b3e05355f74bcb8cb5b93835dca76d75cb0763fb147f669a36e6e0215d2c5fb1`，另有 7 个新增文件及校验清单。该本机恢复材料不提交、不跨主机传播，也不代替后续 Git 契约交接。

## 屏幕右下圆角反馈候选

负责人反馈动态阅读页的“回复一下”入口右下角贴屏幕边缘。只读截图矩形画布内仍有约 8dp 右边距，没有看到布局越界；治理任务进一步读取设备显示信息确认实体底部圆角半径 170px、density 3（约 56.67dp），系统底部导航安全区为 48px（16dp）。原先仅依赖系统安全区，回复框的外接右下角落在本机实体圆角之外，屏幕截图本身不会反映硬件裁角。

共享 `WenyouReplyActionBar` 在系统 SafeArea 内增加 `space12` 底部留白，额外叠加而非与系统 inset 取最大值。左右仍各 8dp，主题／动态回复区宽度不变，48dp 命中区不缩小。普通操作行加留白为 60dp，再叠加系统安全区；大字按实际内容高度增长。没有修改原生圆角接口或为全设备硬编码半径。两页均由 Scaffold 扣减实际底栏高度，快翻避让沿用现有几何测量，不追加正文末尾补偿。

42 项共享栏／主题／动态定向测试及 Golden 通过；新几何回归组合 320／360／400dp、系统 bottom inset 0／16／34dp、普通／两倍字、三／四入口，验证右边界、额外底距、回复宽度及最小点击区。仅在本次设备对应 16dp inset 时额外校验 170px 圆角范围，不将本机圆角当作其他设备保证。4 个变更文件分析零问题、格式零改动。新增 400dp 明暗组件图片位于既有 Golden 目录，已审阅。

本轮 725 个 `lib/` 文件摘要为 `52cc5aba8387225741772b8c488a41dc2192a1717365540fd32c956a6c70b4e6`，清单 `.dart_tool/compact-rounded-corner-source.json`，检查日志 `.dart_tool/compact-rounded-corner-test.log` 和 `.dart_tool/compact-rounded-corner-analyze.log`。源码冻结供治理任务热重载，先确认本次圆角修复，再接入已提交的后端统计契约；未构建、安装或推送。

治理任务已热重载 `52cc5aba`：`fullRestart=false`、`code=0`，`Reloaded 1 of 4783 libraries`，1844ms，PID 3090 保持。负责人已手动切至他人主题，只读实机画面确认回复框上移 12dp、宽度不变，当前矩形边框位于本机 170px 物理圆角范围内。回执 `D:/codex-artifacts/compact-bottom-actions/reload-rounded-corner-20261018.json`，含用户内容的私有截图不提交；该观察不代替负责人整体视觉验收。23 模块文档检查通过，后续契约接入仍等待 Backend 稳定提交。

2026-10-18，负责人对 `52cc5aba` 本轮圆角候选明确反馈“完整显示，留白合适”，主题／动态共享底栏的底部圆角与留白问题验收通过。此结论仅闭合本次布局问题；主题收藏／订阅真实统计契约仍待实现，最终完整门禁与合并审批尚未完成，不扩大为整个 PR 已可合并。

## 待验收

负责人在本任务候选 Debug 中手动查看主题与动态底栏，确认窄屏／大字观感、点加油进入原面板、回复后返回阅读和系统安全区。真实环境自动化只读；登录、加油、点赞、收藏、发表评论等真实写入由负责人自行操作。未自动启动 App 或接管其他设备调试会话。

早期纯展示候选使用官方 `candidate:apk` 精准测试入口；后续新增可选统计契约，最终候选改为完整 `check:apk` 门禁。没有批准即不合并或部署。

### 早期横向压缩阶段进程与画面复核

随后设备上的原进程退出，当前 App PID 变为 3090；治理任务未启动或重启 App，重新 attach 至用户当前进程。首次重连 reload 返回 0 libraries，不能证明布局已更新；将本轮 5 个变更源码文件标记为需增量编译（仅更新时间，不改变内容）后，再次执行 `fullRestart=false`，返回 `code=0`、`Reloaded 5 of 4782 libraries`，耗时 2288ms。最终画面绑定 `7127877e71319c7518ce84dc397e5c8edd7caf443f122640e28cab561f0325b8`，该阶段早于后续数字下置和圆角修复，不代表最终源码。

只读截图确认主题详情浅色底栏的左右边距缩小、回复输入框实际变宽，设备视口 1200×2608px／约400dp；页面和阅读位置保留。动态详情真机、深色及大字实际画面仍待负责人验收，离线组件覆盖不替代真机验收。私有截图不提交。调试会话仍连接当前进程；退出重开会恢复安装包源码，需要重新连接并重载。

## 真实收藏与官方订阅人数接入候选

独立契约 chore `bec8d24f` 固定 Backend `da68203a494c6d0f6d377c23399390c2cee397f3`／API `5.40.0-dev.20261018.1`，生成可选整数 `bookmarkCount`／`subscriberCount`。详情 GET 是权威来源；旧响应缺失不显示伪造的 0，真实零值显示 0。计数与图标上下对齐，k／m 短数只影响底栏视觉，读屏仍包含完整人数；官方订阅不混入 USER 玩家发言订阅或自动更新通知。

收藏确认增删或显式官方订阅成功后，由页面调用 `refreshActionCounts` 只读 GET 并只补回这两个数字；不改变 family 参数，不覆盖当前点赞／收藏投影，保留楼层窗口与阅读位置。取消选择、写入失败和 USER 订阅不触发该刷新；取消已有收藏或官方订阅成功仍刷新真实总数。独立读取代次丢弃较旧响应，页面／会话切换仍受既有请求边界保护；读取失败保留旧数，成功仅清除该读取产生的错误，避免抹去分页失败。权限失效仍按原有受限内容流程处理。

新统计属于契约候选，需最终部署 SHA 对齐和完整 `check:apk`，不能以早期纯展示测试或已验收圆角画面替代。当前设备仍使用已验收的 `52cc5aba` 热重载源码，生成 SDK 后本任务未自行重新启动、安装或控制设备。

本阶段 46 项数据／并发／互动回归通过，随后 118 项共享输入／主题组件／整页／主题和动态快翻回归通过并更新 Golden；24 个变更 Dart 文件静态分析零问题。中间宽度依据实际文字测量显示“回复”，两字也放不下才显示 Foundation 回复图标，完整 Tooltip 和无障碍名称仍是“回复一下”；不缩小用户字号。普通 320dp 四图标与回复宽度保持，极端两倍字四项大数也有明确入口。日志 `.dart_tool/action-counts-behavior-final.log`、`.dart_tool/action-counts-responsive-final.log`、`.dart_tool/action-counts-analyze-final.log`。首次整页回归发现旧“100万”预期已按本批 1m 规则更新；第一次静态检查的多余 import 已移除，不隐藏失败记录。最终完整门禁尚未运行。

最后复核补齐订阅不确定写入后的“刷新结果”：显式只读确认成功、同会话与同控制器且仍在页面时刷新真实总数；加载失败或离页不触发，不重放订阅写入。23 项订阅定向测试通过，覆盖普通/紧凑两入口成功恢复、失败与离页，写入次数始终为一次。日志 `.dart_tool/action-counts-recovery-test.log` 与 `.dart_tool/action-counts-recovery-analyze.log`。本轮应用源码摘要更新为 `37f9cc9d9e2cc3863d72a016d35e380ac1896517b9ce21b9445dee86d58cd645`（725个lib文件），取代统计实现的前一冻结值。

## 最终完整门禁与候选 APK

2026-10-18，在已批准部署的 Backend PR #55 最终提交 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126` 上完成公网只读契约核验，API `5.40.0-dev.20261018.1` 与本机固定来源精确一致。最终执行 `npm run check:apk -- -TestConcurrency 2` 返回 0；OpenAPI、来源、重新生成 SDK 一致性、格式、App／SDK 全量分析、架构、23 模块文档、严格 API 覆盖均通过。移动范围 175／175，无遗漏，另 73 项按既有排除登记保留。

全量 Flutter 测试 7242 项通过、1 项既有跳过，耗时 24 分 44 秒；49 项 Windows 发布工具测试通过，无失败或跳过。随后 Debug APK 构建成功，Gradle 用时 187.3 秒。已保留生成器 builder、插件 Kotlin Gradle 和 SDK XML 版本等非阻断提示，没有为本轮改动构建依赖或放宽检查。前两轮来源登记／旧版本断言失败及修复记录保留在[契约同步记录](thread-action-counts-contract-sync.md)，不以失败轮次代替本次完整绿色结果。

最终应用仍为 725 个 lib 文件摘要 `37f9cc9d9e2cc3863d72a016d35e380ac1896517b9ce21b9445dee86d58cd645`，逐文件核验与冻结清单完全相同。构建时提交基准 `5b9187516736e20f777abacfea2509ae0150dba6` 加本次业务、测试和文档修改；后续交付提交仅记录这些已检查的修改。生成 SDK 与契约来源独立提交，Foundation 维持正式 v7.5.0。

- APK：`D:/codex-artifacts/compact-bottom-actions/wenyou-compact-counts-0.9.0-debug-99-cb237f57.apk`，112813318 字节。
- SHA-256：`cb237f577c2fed80299462f41f957049d58aac19b02863a80569331580af0744`。
- 包身份：`site.wenyou.app.debug`，`0.9.0-debug`／99，只有 `arm64-v8a`。
- 完整日志：`.dart_tool/action-counts-full-check-apk-verified.log`；同名副本及 `action-counts-candidate-20261018.json` 位于上述本机产物目录，不提交日志或安装包。

Mobile 实现任务未安装或启动 App，由治理任务独占设备并另行记录安装。真实收藏／官方订阅总数、成功增删后的刷新、动态实机和极窄大字号回复兜底仍待负责人验收；已接受的圆角／留白结论不扩大到这些新增状态。PR #107 保持 Draft，仍依赖未合并的 #106，不自动合并、发布或部署。

# 花体字扩充与起名时间排序验收

状态：2026-10-15 负责人确认“可以了 合并分支即可”，已真机验收通过；完整门禁发现项已按下述基线复现和补检闭合，可按授权合并，不部署。以下开发阶段记录保留，安装与验收结果见末节。

## 范围与数据边界

- 工具标题改为“花体字”，沿用离线输入、结果选择、完整复制与失败恢复流程。无新接口、输入持久化、账号权限或产品字体资产。
- 清单固定 Web `de1fb888dc830e19f3d93d53c0aa391067391449`，49 款分为字体、符号字形、文字特效、边框装饰；补齐伪草书、伪哥特／怪异、故障、气泡伪体、部首、诅咒、上下单点及 Zalgo。全部预览为 `Hello Wenyou`，样式名与实际字形分行显示。两端保留各自既有默认（Mobile 粗体／Web 花体）。
- `source-fancy.json`、Web manifest 六个文件摘要及生成常量一致，352 固定向量全部通过；独立保留 `d40d0b7893cc04badc89a97b23745ce12e531284` 的 240 个 v1 向量和旧八个文字工具花体向量。生成数据 `--check` 已接入常规 `fancy_styles_test.dart`，后续完整门禁会检查来源漂移。
- 六国史实参考选项按 `period.from`、`period.to` 升序，同期保留原序；文学创作、底层词库、默认风格和随机消耗保持。只排序 UI 使用的副本。
- Windows 独立 Worktree：`D:\codex-worktrees\toolbox-fancy-expansion\wenyousite-mobile`，分支 `codex/20261015-toolbox-fancy-expansion`，基线 `e923ea69`。
- Foundation 已 fetch 并核对最新正式 Tag `v7.2.1` 与锁定版本一致。公网只读 `/meta` 的契约版本 `5.36.0-dev.20261005.1` 与 Backend `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045` 一致。

## 回归与画面

时间排序使用六国逐项审阅的固定 ID 序列。临时还原旧 UI 的直接词库顺序后，中国控件回归明确失败：首项为明代而非魏晋；恢复候选后六国模型和 Widget 的 12 项通过。显示顺序变化不改进阶生成器；原 245 个随机输出/消耗向量继续作为回归。

最终 v2 的 `fancy_styles_test.dart` 共 595 项通过，包含 352 新版和 240 旧版固定向量、全部预览的实际转换、输入／输出上限与来源摘要。`fancy_widget_test.dart` 的 11 项覆盖四类数量与默认、切换清结果、中文／复合字符完整复制，以及八张分类、两张 Zalgo 结果图；失败的旧分类默认及重复文本定位已修正，只重跑失败项。`toolbox_page_test.dart` 仅重跑“花体默认粗体有样例”，检查默认与超限粘贴；`text_tool_state_visual_test.dart` 仅更新四张受影响花体页面。时间排序的 16 项（含四张 Golden）在前一批通过，排序实现未再变化；四张工具目录 Golden 仅标题变化。

定向 `dart analyze` 检查本轮花体转换器、选择器、面板、生成脚本、测试与测试字体 helper，无问题；Dart 变更文件格式与 `git diff --check` 检查通过。此前 v1 阶段工具箱目录运行曾出现 765 通过、4 失败，失败均为 `toolbox_entry_test.dart` 的游客“我的”页旧 Golden 缺少基线已合并的主题帖字号行。临时还原全部产品改动为 HEAD 后，`游客工具箱入口视觉 400_light` 仍相同失败，已恢复候选源码；没有覆盖或修复这些无关 Golden。最终 v2 按负责人要求未再扩大目录回归。

离线 Golden 覆盖 400dp 亮色与 320dp 双倍字号暗色，原生花体页面和时间顺序另覆盖两种宽度全部明暗组合；实际路径位于 `test/features/toolbox/goldens/`。已目视 `fancy_symbol_400_light.png`、`fancy_effect_320_2x_dark.png` 与 `fancy_zalgo_result_320_2x_dark.png`，真实字形可读，Zalgo 上下标记和相邻两行未裁切。治理代理也查看两张代表图，未发现布局阻塞；这不代替负责人验收。

新花体与排序截图单独加载十三个有许可的测试字体子集，覆盖数学字母、彝文、加拿大原住民音节、希腊／西里尔、部首及扩展 B 的 𠘨；原全局 Golden 基线字体不变。来源及 SHA-256 见 `test/support/fonts/toolbox-font-source.json`。它们不声明为应用资源，也不进入 APK；测试字体覆盖不能证明 Android 系统字形相同。

## 开发阶段未覆盖项

最初开发候选时 `adb devices -l` 无已连接设备，没有可接管的本任务 Debug 会话；当时只做离线组件验证，没有启动 App 或执行线上业务写入。负责人要求“任何全面测试都放在最后合并分支时进行”，开发阶段因此只运行定向检查。随后按负责人要求构建并安装下列 Debug 候选，安装入口曾启动的全量分析已按反馈节奏中止，不记作通过。iOS 仍未覆盖，测试字体也不证明所有 Android 设备具有相同字形。

负责人复验：进入“花体字”，切换四分类和样式，特别检查伪字形、部首、上下单点与 Zalgo 的实际系统字体；输入中文、英文、数字、Emoji、重音及多行结果，复制到其他应用核对。在起名页展开进阶，检查六国历史从早到晚，切换文学后保持原风格顺序。

默认 Auto-review 偏好已传递；宿主无设置/核验入口，实际运行策略为 `never`，不能当作已启用 Auto-review。此能力限制不扩大合并和发布权限。

## Debug 安装与负责人验收

- 已验收应用源码 `466277914096014b797a2db7f8496516dc066fb4`，构建时工作树干净，Debug ARM64 构建成功。
- 设备 `4b9c39b5`（2509FPN0BC），应用 `site.wenyou.app.debug`／温油站 Debug，版本 `0.9.0-debug+99`。
- 本地 APK 与设备内 `base.apk` SHA-256 均为 `788e709c91b4047e2f15eb5bddde25a5e5027bfb3cabea7eefb4fc6b6e775b80`。`adb install -r` 成功，安装后 `lastUpdateTime=2026-10-15 01:51:36`；未卸载或清数据。已验收 APK 保存为治理工作区 `.artifacts/toolbox-fancy-expansion/accepted-app-debug-46627791.apk`，摘要复算一致。
- 代理未自动启动应用；API 保持 `https://wenyou.site/api/v1`，由负责人手动打开验收。证据位于治理工作区 `D:\code\wenyousite\.artifacts\toolbox-fancy-expansion\adb-install.json`。
- 负责人随后回复“可以了 合并分支即可”，确认本轮验收通过并授权合并；未另行提供每个字形、复制或滚动步骤的单项结论。

## 合并前集成

更新远端后，将 `origin/dev` 的已验收七档字号基线 `387ba054643459d45ebe9d1e9b50eba23b4b979e` 正常合入任务分支，保留提交历史。仅 CHANGELOG 的并行新增记录发生冲突，两批记录均保留。工具箱应用源码未因基线合并改变；已安装 APK 对应上面的验收源码，不冒称是合并后所有应用源码的构建。

已核对“我的”页主题帖字号入口是此前已验收行为，默认数值 16 与当前七档设置一致；最小更新四张游客工具入口旧 Golden，不跳过断言或改变产品行为。合并阶段检查应用／测试源码为 `dc72287dae3b501df6178f4e0b25375868584e98`。

执行唯一完整入口 `npm run check -- -TestConcurrency 2 -ContinueAfterFailure`，首次退出码为 1，完整执行全部步骤，不能记作一次全绿：

- OpenAPI 校验、固定来源验证、API 客户端再生成一致性、公网只读契约与 Markdown 兼容均通过；生成 API 和诊断路由无漂移。
- 1,298 个 Dart 文件格式检查无变化；生成 API 包全量分析、架构边界、23 个模块文档和 API 覆盖检查通过。
- 应用全量分析只有忽略目录 `build/check_fancy_regex.dart` 中两条 `avoid_print`，这是本任务开发期的临时正则探针。探针已移到工作树外，移动前后 SHA-256 一致，未修改产品代码或 lint。
- 全量 Flutter：6,583 通过、4 失败、1 跳过。失败仅为 `thread_reading_quick_scroll_test.dart` 的 320／360／400／600dp 四张旧 Golden；全部失败的 master/test/diff 图已保存到工作树外。该测试及其行为断言未被削减。
- 唯一跳过项是仓库既有 `diagnostic_live_receipt_test.dart` 的“显式验收：Sentry 接收一条脱敏诊断”，仅显式设置 `WENYOU_VALIDATE_SENTRY` 并提供独立 DSN 才执行。本轮未开启真实 Sentry 写入，也未新增 skip。
- Windows 发布工具测试 49／49 通过，未构建或重装 APK。

原始日志保存于治理工作区 `.artifacts/toolbox-fancy-expansion/mobile-integration-check.log`，开发记录、失败图和字体生成脚本在同目录 `mobile-evidence/`。已通过且源码未变的步骤不重复执行。

基线复现：完整入口结束后，将全部 `lib` 临时恢复为 `origin/dev` 的 `387ba054643459d45ebe9d1e9b50eba23b4b979e`，核对应用源码、线程测试和全局测试字体与该基线无差异，再运行完整快翻测试文件。结果为 2 通过、4 个相同 Golden 失败；四个宽度的实际 PNG SHA-256 与首次完整门禁输出完全一致。`finally` 已恢复候选应用源码，应用差异为空。复现日志为 `mobile-quick-scroll-baseline.log`，四组图片在 `mobile-evidence/quick-scroll-baseline/`，逐图等价记录为 `quick-scroll-pixel-equivalence.json`。

旧图最后更新早于已验收的字号提交 `10fe127cdbb4a03c23fee83d41921013ff4aefdd`；该提交明确将主题正文与楼层默认由 17sp 调至 16sp，当前基线仍采用 Foundation body 16sp。已目视 320／400／600dp 实际图，正文行高缩短但控件结构、快翻轨道与底部操作没有裁切或溢出。仅校正四张 Golden，未修改产品源码、断言、测试条件或 skip；原文件六项补检全部通过，日志为 `mobile-quick-scroll-corrected.log`。

应用全量分析按入口原参数 `flutter analyze --fatal-infos --fatal-warnings` 补检，退出码 0、无问题（160.5 秒），日志为 `mobile-analysis-recheck.log`。同一应用源码的检查缺口已闭合：首次完整入口仍明确保留退出码 1，快翻六项与应用全量分析的补检均为 0，其余步骤沿用完整入口通过结果。之后只校正测试截图与验收文档，没有因测试基准校正而重建或重装已验收 APK。

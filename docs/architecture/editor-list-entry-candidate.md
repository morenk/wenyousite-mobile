# 编辑器工具栏布局候选

状态：前次真机验收未通过，修正候选／待负责人复验。日期：2026-10-16。沿用 [PR #98](https://github.com/morenk/wenyousite-mobile/pull/98)。

## 范围与来源

- 从已更新的 `origin/dev` `d7168b61ea1b547e737585d2e9b250f1b3bd24e2` 创建 `codex/20261015-hide-list-entries`。
- Worktree：`D:\codex-worktrees\mobile-hide-list-entries\wenyousite-mobile`；只修改 Windows Mobile。
- “偏好 → 编辑器工具栏”直接模拟真实工具栏，分别配置主栏、展开栏顺序；鼠标直接拖动、触屏长按拖动完成排序／换栏，保留恢复默认。游客与登录用户均可设置。
- 共享工具栏隐藏无序／有序列表入口，列表不进入可选项。表情包保留，主题创作、帖子、回复和子贴共用布局；受限能力及缺少表情回调的动作继续隐藏。
- 保留格式策略、Markdown ↔ Delta 编解码、历史列表编辑与阅读、站内结构化粘贴，以及既有不支持结构的源码保护；不迁移或清理历史内容。
- Foundation 固定正式版 `v7.2.1`，复用 48dp 命中区、设置组件、主题和语义图标，不增加依赖。
- 本任务起始只读核对 Backend `origin/dev`、本仓库来源及公网 `/meta.buildSha` 均为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，契约 `5.36.0-dev.20261005.1`、Markdown 5。本切片无契约变化，APK 下载由另一任务处理。

## 布局与持久化

未自定义时继续使用原主栏、草稿分隔线、窄屏草稿独占行和宽屏引用／表情包提升规则。四张原默认工具栏 Golden 在新实现下直接对比通过，未更新其像素基线。

自定义后主栏按用户顺序取可放下的项目，溢出项目按原顺序排在已指定展开项之前；变宽后恢复主栏意图，不修改保存配置。“更多／收起”固定可达；即使场景原先没有更多能力，自定义移入展开栏的可用工具也能访问。展开栏可滚动，不以裁掉动作解决空间不足。

SharedPreferences `editor.toolbar.layout.v1` 只保存版本和两组稳定 ID，不含账号或正文，不请求 API。网页与 App 各自保存本机偏好，不做账号或跨端同步。启动前加载并注入 Riverpod；保存中禁止重复操作，失败回滚并可重试原目标。恢复默认删除覆盖键，重启仍为默认；未知版本或损坏值回退默认，读取不主动改写，重复与未知工具 ID 被规整，缺失工具归展开栏。

音频仅为后续实现预留稳定 ID `audio`，默认归展开栏。本候选没有音频占位按钮，不实现上传、录音、播放器或音频契约。

设置画布复用 editor 公共按钮、图标与托盘样式，直接用 `WenyouEditorCapabilities.resolveToolbar` 与真实编辑器共用能力、容量和默认规则。按实际安全区宽度显示带更多／发送按钮的常用编辑器，只有一套共用设置。实际主题与回复继续读取同一份偏好，按各自固定按钮自然适配。工具栏上下直接贴合，工具栏及空栏不显示分组标题或操作说明；工具栏外仅保留恢复默认。主栏无横滚，溢出项真实进入展开托盘，默认草稿独立行及行内分隔线照实显示。

打开与改变宽度不会写偏好；首次实际移动从当前可见主栏／展开分配开始，满主栏末端插入将原末项实时让入展开。未显示能力保留原组和相对顺序。保存后用相同解析得到相同分配，不再出现二次隐藏或交换。拖动子组件参照 `StickerReorderGrid`：临时布局实时腾位，固定逻辑槽位命中，稳定工具 ID 位移动画；跨栏只移动占位，活动手势留在原组。抬起与回落使用共享 `WenyouReorderFeedback`，起拖提供轻触感；边缘滚动按距离和帧时间推进，停在中间或尽头不空转。

拖动及落位期间固定托盘高度，不在起拖时追加尾格；落位完成后再平滑调整高度。落点使用最终逻辑槽位，快速松手从实际抬起比例退回，取消／越界／系统中断还原原顺序。鼠标按住移动即拖动，触屏长按，触屏短划不会误拖；收起状态起拖自动展开。松手才保存一次，保存期间阻止新操作但保持图标外观；失败沿原偏好控制器回滚与重试。

设置页无选中态及可见调整操作区，读屏以非视觉语义操作排序／换栏；更多和发送固定不可拖动。减弱动画时保留完整操作。设置图标不弹悬停提示，避免提示浮层跨栏重挂载。独立拖动子组件及稳定版本 key 支持局部热重载初始化，不需要应用热重启。

## 开发验证边界

依据负责人最新要求及[治理规范 PR #26](https://github.com/morenk/wenyousite-workspace/pull/26)（`1e1948f103290b1ea9f83f86524845062db3fbbb`），仅执行直接相关测试及改动文件检查；未运行全量测试、全量分析、完整门禁或 API 再生成。本轮拖动修正不重建／重装 APK；此前已按用户明确要求构建安装 `7997bfba` 的 Debug 包。完整检查仅在负责人明确授权合并时执行。

提交前再次核对：仓库没有 `.github/workflows`，远端 `gh workflow list --all` 为空，未配置 `core.hooksPath`；此次提交、推送及 draft PR 不自动触发全量 CI。组件验证使用 Fake Repository；真机由用户手动打开后 attach，不自动登录、启动或写入公网业务数据；起始公网核对仅公开 `/meta` GET。本轮不属于写入 E2E。

## 定向检查

最新反馈阶段同时修正“设置能放更多、实际会折叠”及多余文案。最终 `editor_toolbar_settings_page_test.dart` 22 项与 `editor_toolbar_preview_parity_test.dart` 8 项全部通过，8 张设置 Golden 非更新比较通过。对照以整个工具栏统一坐标捕获真实组件：320／360dp、默认／全部主栏自定义、对齐与表情能力开关，比较主栏和展开栏全部图标位置／尺寸／分组、固定按钮、默认草稿行及两组相对位置，覆盖原先分组标题造成的间隙。其中 4 项比对预览与带发送按钮的真实工具栏，另 4 项确认主题／回复实际工具栏消费同一 Provider 偏好且不改写。日志 `.buildlog/editor-toolbar-shared-preview-final.log`。

满主栏末端插入、独立草稿中心起拖／落位后无空行、未显示能力顺序保留、改宽度不保存均有回归。共享解析提取后的 `editor_toolbar_test.dart`、`editor_toolbar_custom_layout_test.dart` 31 项通过，四张旧运行时 Golden 不变（`.buildlog/editor-toolbar-resolve-regression.log`），删文案阶段未重复运行。七个改动 Dart 文件定向分析首轮发现测试文件 3 条 info，修正后两文件补析通过；最终删文案相关 3 文件分析时发现空栏 Semantics 误加 const，编译／分析失败；移除后热重载成功，画布单文件补析 No issues found（`.buildlog/editor-toolbar-shared-preview-corrected-analyze.log`），另外两测试文件无问题。格式与 diff 检查通过，文件均低于 900 行。

本轮第一阶段从 `7997bfba2b0756047593ccbee2581013389de782` 继续处理负责人“UI／UX 不够丝滑，请参考表情包拖动”的验收失败反馈，先改设置画布及测试。该阶段设置页 18 项通过，含六张明暗静态／拖动 Golden 非更新比较、快速松手不补满抬起、最终槽位落位、临时腾位不保存、取消、起拖触感、减弱动画、收起自动展开、跨栏手势与托盘高度稳定，以及原本机保存和错误恢复覆盖。日志：`.buildlog/editor-toolbar-sticker-feel-final-compare.log`。三个改动 Dart 文件定向分析通过；最后测试 fixture 调整单独补析。

本轮首轮 7 过 6 失败，原因是旧“插入线前”预期与新槽位语义不符、Ticker 首帧未推进以及托盘 1px 高度差；已修正。补充快松手用例时曾缺少回落时钟首帧，后续真实阴影 fixture 恢复时机及减弱动画断言也已纠正；失败日志均保留，最终 18 项全部通过。四张原运行时默认工具栏 Golden、账号页、列表底层能力及表情功能源码均未改变。

前次简化反馈从 `038ae0e6faf2815bc75c609b9009c00489ad3bf4` 继续，仅改设置页交互及其测试。最终 `flutter test --no-pub test/features/settings/editor_toolbar_settings_page_test.dart` 13 项通过，包含鼠标无需长按即可拖放、触屏横滑不误拖、取消与点击不写入、非视觉读屏排序／换栏、空栏、落点、边缘滚动、失败重试、2× 字号及四张明暗窄屏 Golden 非更新比较。两个改动 Dart 文件分析 No issues found，格式零变化，`git diff --check` 通过。日志：`.buildlog/editor-toolbar-drag-only-final.log`、`.buildlog/editor-toolbar-drag-only-final-analyze.log`。

前次失败与补验如实保留：首轮遗漏 `CustomSemanticsAction` import，测试编译与分析失败；补齐后更新图片运行 11 过 2 失败，发现鼠标悬停提示浮层随图标换栏重挂载触发 Flutter 布局断言，下一测试受其遗留异常影响。移除额外提示层后，上述 13 项及分析全部通过；失败日志为 `.buildlog/editor-toolbar-drag-only-first.log`、`.buildlog/editor-toolbar-drag-only-analyze.log`、`.buildlog/editor-toolbar-drag-only-update.log`。本轮仅更新四张设置页 Golden，账号页与实际编辑器工具栏 Golden 未改。

前次图标摆放反馈从 `707a40e3b7d92ba4837b13c108b0885006a17e7b` 继续，只修改设置交互、editor 公共组件导出和该设置页测试。设置页 12 项通过，包含四张 320／360dp 明暗 Golden 非更新对比、2× 字号、连续操作、读屏真实 tap、拖放落点、空主栏／展开栏、边缘滚动、取消不写入及失败重试。三个改动 Dart 文件分析 No issues found，格式零变化、差异检查通过。日志：`.buildlog/editor-toolbar-visual-layout-second.log`、`.buildlog/editor-toolbar-visual-layout-analyze.log`。首轮 8 过 4 失败：发现 Tooltip 长按抢占拖动和测试错误读取 RawTooltip 为 IconButton；均已修正，首轮日志保留。此次只更新四张设置页图，账号页和运行时工具栏 Golden 不变。

以下是前一布局功能阶段的检查记录，未因本次设置页反馈重复执行无变化的检查：

| 范围 | 结果及日志 |
| --- | --- |
| 布局模型、偏好控制器、SharedPreferences、实际自定义工具栏、设置页 | 最终 26 项通过；覆盖两区排序、能力过滤、各种容量不丢失动作、窄屏溢出、默认恢复、重新初始化、保存／读取失败恢复、拖动及真实读屏节点 tap、2× 字号滚动、8 张新 Golden 非更新比较；`.buildlog/editor-toolbar-layout-new-final.log` |
| 上述新增测试及旧工具栏、格式策略、回复空块草稿／重开 | 8 个有效文件共 67 项通过，原默认 Golden 不变；该次命令另误列不存在的 `editor_history_test.dart`，因此整条命令退出 1，不记作命令成功；`.buildlog/editor-toolbar-layout-targeted.log` |
| 纠正历史测试路径 | 正确 `editor_toolbar_history_test.dart` 2 项通过，覆盖分隔线重做最终选区和等长表情替换选区；`.buildlog/editor-toolbar-layout-history.log` |
| 账号设置入口及布局 | 定向名称 `账号设置` 17 项通过；宽度基线 6 项非更新对比通过；`.buildlog/editor-toolbar-settings-entry-compare.log`、`.buildlog/editor-toolbar-settings-width-compare.log` |
| 改动文件静态分析 | 20 个 Dart 文件首轮仅测试集合写法 1 条 info，修正后对 5 个最后调整文件补析为 No issues found；其余 15 文件无问题。日志 `.buildlog/editor-toolbar-layout-final-analyze.log`、`.buildlog/editor-toolbar-layout-final-followup-analyze.log` |
| 格式、差异、文件规模 | 20 个改动 Dart 文件格式检查零变化，`git diff --check` 通过，未超出 900 行边界 |

最初开发期的编译变量遮蔽、import 排序、过时拖动回调及读屏测试节点／句柄释放问题已修正，原失败日志保留。不同轮次的测试数有重叠，不相加冒充独立覆盖总数。

前一列表隐藏切片 `7a4298040f54b006fccb82720ee093a27ac056c9` 的列表兼容专项 486 项通过；随后 `2f2180af1a4ef114b72fb189b8f6b4027c4a7448` 修正 Golden fixture 缺少 `onInsertSticker` 的问题，应用中的表情包从未删除。上述历史检查不冒充本次布局扩展后的完整检查。

## 离线画面

以下实际 Widget Golden 已逐张查看，未见裁切或溢出。自定义设置与工具栏使用同一配置，表情回调已启用；列表及未实现音频无入口。新设置图只展示工具栏拖放区域，没有选中态或可见调整操作条；这些局部候选不是真机截图。治理任务已交叉审阅代码及画面，不代替负责人视觉验收。

| 视口与字号 | 自定义工具栏及展开栏 | 同一配置的偏好页 |
| --- | --- | --- |
| 320dp，亮色，工具栏 2×／设置 1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_320_light.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_320_light.png) |
| 320dp，暗色，工具栏 2×／设置 1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_320_dark.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_320_dark.png) |
| 360dp，亮色，1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_360_light.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_360_light.png) |
| 360dp，暗色，1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_360_dark.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_360_dark.png) |

新增默认真实预览：[320 亮](../../test/features/settings/goldens/editor_toolbar_default_320_light.png)、[360 暗](../../test/features/settings/goldens/editor_toolbar_default_360_dark.png)。

新增拖起／腾位截图：[320 亮](../../test/features/settings/goldens/editor_toolbar_drag_320_light.png)、[320 暗](../../test/features/settings/goldens/editor_toolbar_drag_320_dark.png)，使用实际阴影渲染。工具栏截图 360dp 高，新偏好图 640dp 高。设置页另有 320dp、640dp 高、2× 字号明暗拖放换栏与目标自动可见测试。

原默认对照保持：[360 亮](../../test/features/editor/goldens/editor_more_tray_360_light.png)、[360 暗](../../test/features/editor/goldens/editor_more_tray_360_dark.png)、[320 亮 2×](../../test/features/editor/goldens/editor_more_tray_320_light_2x.png)、[320 暗 2×](../../test/features/editor/goldens/editor_more_tray_320_dark_2x.png)。账号设置因增加“编辑器工具栏”一行，更新其 8 张明暗／宽度基线，原资料编辑页 Golden 字节不变；代表画面为[360 亮](../../test/features/users/goldens/account_settings_light_360.png)和[320 暗 2×](../../test/features/users/goldens/account_settings_320_2x_dark.png)。

本次关键应用源码 SHA-256：

- `editor_toolbar_layout.dart`：`1076f3c5daa67f57444e6fbcec3dbcfd670cb32ea01c8eb77925891a45af00e2`。
- `editor_toolbar_preference.dart`：`c8fe907d6f5cd4e1288e2795194b25e6b1050501517f0fc9d06bce3027d4e422`。
- `editor_toolbar.dart`：`6f8ab5da2f6f696ac536a98fd3571469a0dfc02415eb07270f5a74310d4570a8`。
- `editor_more_tray.dart`：`0ef6a1ef3c27b81763c74447fc59647097f44a9bcd266331084ef385336daf2d`。
- `editor_toolbar_settings_page.dart`：`60473813c1c473999dd522e223a27eca11eaf8530249fb94c567c2d6c8c719df`。
- `editor_toolbar_arrangement.dart`：`429710b3b17a1a4ae04f2c830173c4da9c88acee1c5a912a78ace0f59a6d8508`。
- `editor.dart` 公共组件导出：`0369b0db11684b63f7107f86da570e28faba7b885e6514e525901e32fb08e326`。

## Debug 反馈记录

用户明确要求 ADB 安装热重载后，`7997bfba` Debug 包经 ADB guard 覆盖安装到设备 `4b9c39b5`，包名 `site.wenyou.app.debug`，更新时间 `2026-10-15 23:40:24`；本地与设备 APK SHA-256 同为 `f4a330b4ca1833fa7e2311b39760771a78db33f8bcf0753658d223d0495c7630`。保留登录和草稿，未卸载／清数据。API 显式为真实公网 `https://wenyou.site/api/v1`；确认普通登录键存在，且启动会自动签到，因此由用户手动打开后 attach。

本轮首次复用会话 `72051` 执行 r 成功：`Reloaded 8 of 4722 libraries in 70,507ms`（compile 984ms／reload 898ms／reassemble 534ms）。随后应用进程退出、连接丢失；设备仍在线。应用重开后需重新 attach 并 r 当前源码，初装 APK 不包含本轮新拖动。未自动 run、R、导航或业务写入。后续 `37900` attach 曾返回 `Reloaded 0 libraries in 2353ms`，随后连接丢失但设备 PID 14511 仍存在；不将 r0 当作最终画面已更新。旧 DDS 认证路径失效且日志已无服务公告，用户再次手动退出重开后，原等待会话 `82684` 连接新 PID 17574。首次实际加载 5／4723 库用时 3504ms，卸载初装旧设置 State 时出现一次 `_edgeScrollTimer` getter 查找失败；下一次纯 r 为 0 库／1713ms，异常未重现，未加入迁移兼容代码或执行 R。

最后移除模式切换和空栏文字后，最终源码 `Reloaded 8 of 4723 libraries in 2092ms`（compile 213ms／reload 349ms／reassemble 242ms），无新运行异常。会话 `82684` 继续保留，可通过该会话发送 `r`；API 和设备均保持上述值。空栏 Semantics 曾误加 const 导致一次重载编译失败，修正后的成功结果才对应最终源码。

组合的“读取运行时 Script 源码并截图”命令被宿主策略拒绝，仅返回 `blocked by policy`；没有绕过或重试受阻动作。因此证据为源码内容摘要、设备 PID、实际库加载／重组输出和离线 Golden，不声称已读取设备源码哈希或实看最终手机画面。最新详细记录在 `.buildlog/editor-toolbar-debug-session.md`，负责人触感复验仍待完成。

## 待负责人验收

1. 从偏好进入工具栏设置，跨组移动、重排，打开编辑器并展开工具栏；返回页面和重启 App 后确认顺序保留，恢复默认后重启仍为默认。
2. 明暗主题、窄屏及大字号下检查主栏、展开栏、拖动落点、鼠标直接拖动与触屏长按；确认表情包可用，共用预览与带发送的真实编辑器相同，主题／回复使用同一份偏好，打开页面不改保存配置，固定控件不能拖动。
3. 打开已有列表正文并编辑、保存、重开，确认原列表语义保留。真实业务写入由负责人手动执行，自动化仅用离线 Fake Repository。

未覆盖真机软键盘、系统读屏及负责人实际历史帖子；离线 Golden 和语义断言不能代替人工验收。本候选不声称已验收或可合并，未合并或部署；仅执行明确授权的 Debug 安装与热重载。

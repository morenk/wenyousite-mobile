# 设置精简与设计统一排查

日期：2026-09-20。状态：候选／待负责人验收。

## 本次范围与依据

负责人要求排查移动端各自实现的冗余设计，并删除冗余副标题，尤其是个人设置页全部副标题。本次以源码为依据检查 `lib/features` 与 `lib/core/widgets` 的设置行、区块说明、选项、弹层、状态反馈和时间展示；不把源码检查当作全应用真机视觉验收。

视觉事实源仍为 Foundation 正式 Tag `v7.0.0`。本次已在只读缓存执行 `git fetch origin --tags`，确认没有更新正式版，并阅读该版本 CHANGELOG、Flutter profile 和受影响契约；不新增颜色、字号或间距规范。

## 已实现的精简候选

- 个人设置所有导航入口统一为 `WenyouSettingsLink`：名称、可选当前值、前进箭头；没有副标题参数。黑名单、终端、密码、邮箱、申诉、注销、外观、故障诊断和系统通知入口采用同一组件。注销保留危险色，原导航与鉴权保持。
- 外观当前值放在同一行，删除三种外观选项的解释句；选中标记仍保留。
- 删除设置入口“修改后所有终端需要重新登录”“查看近 30 天决定与申诉进度”“不可恢复；已发布内容会匿名保留”和“管理消息弹窗”等副标题。对应实际操作页仍呈现安全后果和规则。
- 删除“当前会话”重复区块标题、资料编辑“主页公开内容”的解释、添加背景“选择图片后可调整取景”的解释。
- 后台提醒、省流量、自动诊断通过同一 `WenyouSettingsToggle` 的说明按钮按需查看。耗电、划掉停止、封面静态、诊断隐私和记录期限保留；弹窗支持滚动、关闭和系统返回。点击说明不切换设置，也不触发授权或远端请求。
- 删除通知权限行重复的“也可在系统设置中开启”；保留未授权状态、申请权限、系统设置入口和失败恢复。

代码入口：[`wenyou_settings_row.dart`](../../lib/core/widgets/wenyou_settings_row.dart)、[`me_page.dart`](../../lib/features/users/presentation/me_page.dart)、[`appearance_settings_page.dart`](../../lib/features/settings/presentation/appearance_settings_page.dart)、[`background_reminder_settings_panel.dart`](../../lib/features/users/presentation/background_reminder_settings_panel.dart)、[`diagnostic_settings_page.dart`](../../lib/features/settings/presentation/diagnostic_settings_page.dart)。

## 剩余应统一的设计

以下是已确认的源码分歧，尚未在本候选中迁移。建议依次收敛；不是新增一份与 Foundation 并行的视觉规范。

| 优先级 | 分歧与具体位置 | 影响与建议 |
| --- | --- | --- |
| 高 | [主题管理 `_ThreadSettingRow`](../../lib/features/threads/presentation/thread_management_settings_sections.dart)仍独立固定 56dp 行高、45% 屏宽的值区域和单行截断；个人设置使用本次共享行 | 同属设置项，却各自决定当前值布局。下一批将设置行统一到一个入口，支持主题权限长值、禁用/只读状态、两倍字号；不复制近似组件。 |
| 高 | [主题管理 `_showChoiceSheet`](../../lib/features/threads/presentation/thread_management_settings_sections.dart)、[外观 `_AppearanceOption`](../../lib/features/settings/presentation/appearance_settings_page.dart)各自用 ListTile 和勾选图标表达选择，已有[共享 `WenyouSelectionRow`](../../lib/core/widgets/wenyou_selection_menu.dart) | 选中底色、文字、留白和无障碍维护分散。统一选择行呈现与语义；单选、多选、即刻应用与确认应用仍由各业务持有。 |
| 中 | [正文草稿抽屉](../../lib/features/drafts/presentation/content_drafts_sheet.dart)和[主题云草稿抽屉](../../lib/features/threads/presentation/remote_thread_drafts_sheet.dart)重复 90% 高度、安全区与拖柄；[订阅抽屉](../../lib/features/social/presentation/thread_subscription_controls.dart)另设 72% 且外层安全区配置不同 | 统一底部抽屉容器的高度策略、键盘避让、安全区和关闭入口。业务内容、草稿恢复、订阅状态不合并，也不认为所有弹层必须同高。 |
| 中 | [外观偏好失败](../../lib/features/settings/presentation/appearance_settings_page.dart)使用 `WenyouStatusBanner`，同页省流量失败和[后台提醒失败](../../lib/features/users/presentation/background_reminder_settings_panel.dart)使用普通 ListTile | 同类“保存失败＋重试”缺少一致状态层级。复用现有横幅和动作布局；保留各设置的读取失败、保存失败及回滚差异。 |
| 中 | [故障诊断](../../lib/features/settings/presentation/diagnostic_settings_page.dart)直接铺 ListView，[外观](../../lib/features/settings/presentation/appearance_settings_page.dart)使用 `WenyouPageBody`，[账号设置](../../lib/features/users/presentation/me_page.dart)另有 `_MePageList` | 诊断缺少共享内容宽度容器，设置页底部留白与横向边距入口分散。统一配置页容器并验证 320/360/600dp；个人主页 NestedScrollView 有联动需求，不能机械替换。 |
| 中 | [公开用户最近回复](../../lib/features/users/presentation/public_user_content.dart)直接拼接 `DateFormat`，而[主题卡](../../lib/features/thread_feed/presentation/thread_feed_card.dart)使用 `WenyouTimeText` | 同类内容元信息分裂为固定日期和 Foundation 时间格式，前者也没有显式 `toLocal()`。应统一消费共享时间组件与完整时间朗读；登录终端、安全记录等确需绝对时间的场景继续保留明确例外。 |

此前已统一的普通确认框、异步按钮、分页反馈、页签、Snackbar、主题卡和图片呈现不重复列为本次新发现。确认框内业务专属表单、危险动作确认短语、草稿持久化策略和权限判断也不应因“统一外观”而合并。

## 未删除的信息

本次“删除副标题”针对常驻设置入口和重复解释，不按 Dart 参数名盲删。标签描述是用户内容；用户名下的等级、收藏夹计数、搜索结果数量、邀请创建日期是实际数据；验证码投递状态、密码约束、权限限制和注销后果是完成操作所需的信息。上述内容仍保留，个人设置入口本身不再显示任何副标题。

## 验证与待验收

本次是展示与文案调整，未修改 Provider、存储、鉴权、网络、权限申请或 Android 原生代码。因起始契约来源落后于已部署提交，先独立同步契约来源及说明，确认生成客户端无差异；最终运行 `npm run check:apk -- -TestConcurrency 2` 成功，包含契约/公网核验、生成一致性、格式、应用与生成客户端全量分析、架构、模块文档、API 覆盖、全量测试和 Debug APK 构建。

直接受影响测试：

- `test/features/settings/`：外观切换、省流量、诊断说明、复制/清除，以及账号安全原流程。
- `test/features/users/me_page_test.dart`：资料入口、资料操作、设置不依赖资料请求、320/360/400/600dp、两倍字号及浅色/黑夜 Golden。
- `test/features/users/background_reminder_settings_panel_test.dart`：说明不改变开关、拒绝后重试授权、系统设置跳转、两倍字号及非 Android 隐藏。
- `test/core/widgets/wenyou_settings_typography_test.dart`：共享设置字体作用域。

Golden 更新包括外观黑夜、资料编辑浅色/黑夜，以及新增账号设置浅色/黑夜。账号设置 Golden 使用测试环境的无后台服务入口；Android 后台提醒单独由上述 Widget 测试覆盖，最终以 Android 候选页面为准。

负责人手测：

1. 打开“我的 → 账号设置”，确认所有入口无副标题，“外观”的当前值、危险色和箭头清楚，进入密码、邮箱、终端、申诉页面仍正常。
2. 点击后台提醒说明，关闭后确认开关值没有变化；手动切换后检查保存与系统通知设置入口。拒绝权限时确认“申请权限”可用。
3. 在外观页切换三种模式，确认无重复说明；查看省流量说明后确认值不变，再手动切换验证。
4. 在资料编辑页检查公开内容与背景入口，确认无重复解释、保存与取消可用。
5. 在诊断页打开说明，核对隐私与保留期限仍可查阅，关闭后发送开关不变；仅使用测试记录验证复制、清除。
6. 用系统大字号及浅色/黑夜检查设置长标题与说明弹窗，无截断、溢出或不可点击操作。

没有复用中的 Debug 会话，本次未操作真机。自动测试、Golden 和 APK 构建不代表负责人验收通过；未授权合并或发布。

## 候选制品与实际验证结果

- 46 项直接相关 Widget/Golden 测试通过；最终完整门禁 4,630 项 Flutter 测试通过、18 项 Windows 工具测试通过。唯一跳过项为 `test/core/diagnostics/diagnostic_live_receipt_test.dart`，需要显式启用 `WENYOU_VALIDATE_SENTRY` 的实际收件验收，本切片未启用。
- 应用与生成客户端静态分析零问题；契约与公网一致、重新生成 SDK 无差异。完整门禁和 APK 绑定本次最终应用源码，之后仅补充交付记录不重复应用门禁。
- APK：`D:/code/wenyousite/artifacts/settings-subtitles-20260920/wenyou-debug-95.apk`。包名 `site.wenyou.app.debug`，显示名“温油站 Debug”，版本 `0.7.1-debug`，构建号 `95`，大小 `223438669` 字节。
- SHA-256：`019239c6701d6ab74d1cebe630ca4028e0fe82736da96a15101b5f7d200e72df`。
- 完整日志为同目录 `check-apk.log`，针对性测试为 `targeted-tests.log`；提交号、包摘要和未验收状态写入同目录 `candidate.json`，浅色/黑夜预览同时保留。
- 任务分支：`codex/20260920-settings-subtitles`；已完成独立契约来源提交 `4dc221e2`，界面提交由候选清单记录。尚未安装真机或取得负责人验收，未合并或发布。

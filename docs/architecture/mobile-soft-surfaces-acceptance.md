# Android 首批轻表面视觉候选

> 历史验收记录：专用隔离开发预览已于 2026-10-10 退役，下文保留当时证据，不作为当前启动指南。当前流程见 [Debug 开发](../live-debug.md)。

状态：2026-10-07 负责人明确表示“可以合并分支并准备发布正式版”，本批视觉验收通过，进入完整门禁与合并阶段。实际 Flutter Widget/Golden 已渲染，独立 Debug APK 已按负责人要求 ADB 安装；随后按明确授权直接连接既有开发后台启动持续 Flutter Debug，顶部页签与消息页已热重载。已取得本批观感验收与合并授权；正式上传和晋级不在本轮“准备”范围。

## 授权与开始条件

负责人授权：浏览和设置使用浅灰紫底色衬托白色内容，阅读、写作正文保持白色；个人中心、设置首页、主题设置等密集管理页保留简洁分组和明确入口，不增加副标题。楼中楼样式完全保持，不增加每层楼的回复按钮。

本轮只读核实依赖任务“统一链接样式并修复移动端”对应三个 PR 已合入 `dev`：

| PR | 实际合并提交 |
| --- | --- |
| [#78](https://github.com/morenk/wenyousite-mobile/pull/78) | `6d7bc8524faf3baaafac5b39ed80a9f026496692` |
| [#79](https://github.com/morenk/wenyousite-mobile/pull/79) | `9580efe72a3743c61cbc2ca386f7920a6e158b83` |
| [#81](https://github.com/morenk/wenyousite-mobile/pull/81) | `03adc6a1e07af2c0b72fb51da24c506ae5558aac` |

更新远端后逐一确认三者为 `origin/dev` 祖先。从 `03adc6a1e07af2c0b72fb51da24c506ae5558aac` 创建独立 Worktree `D:/codex-worktrees/mobile-soft-surfaces/wenyousite-mobile`，分支 `codex/20261007-mobile-soft-surfaces`。仅用于等待合并的 `automation` 已暂停，未改变其他任务的跟进或清理。

## 实现边界

- Foundation 已 fetch 正式 tags，最新为 `v7.2.1`，Mobile 已锁定同版本；读取该版本 CHANGELOG 与受影响视觉规范。本轮复用既有 `softPanel`、`panel`、`background`、线性图标、间距及圆角，不升级依赖，不修改或发布 Foundation。
- 浏览底色明确用于首页、动态发现／关注与独立用户动态列表、标签主题、全站／主题内搜索结果、收藏和公开用户页。浅色页底使用 `softPanel`，内容沿用 `panel`；黑夜页底保持 `background`。全局 Scaffold 默认值保持，因此阅读和写作正文不会随浏览页变色。
- 横滑内容背景跟随所属 Scaffold；没有单独指定页面底色时继续使用主题默认值。手势判定、动画、分类和分页均保持。
- 个人区与主题管理保留已有白色分组、整行点击和必要箭头；设置语义图标使用统一柔和底托。个人工具保留原横排。主题标题输入恢复输入边界，长标签作为当前值完整换行。
- 仅增加帖内身份设置开关的既有语义图标，不改身份或权限业务。保留原自动保存、跳转、危险确认、错误、校验和必要提示。
- 本轮不重构消息页面；后续共用页签外观调整也应用于消息等已有消费者。搜索行为、发布流程、主导航、阅读、编辑器或楼中楼保持；没有接口、存储、权限、原生配置和生产业务写入。

已记录 Backend revision、只读镜像 `origin/dev` 与公网只读 `/meta` 均为 `a624bed0eb2b118701bd593fbce2aabf3dea7321`，契约版本 `5.36.0-dev.20261005.1`；无需契约同步。

## 画面与检查

实际页面 Golden 使用测试仓储和确定性测试字体，不是生成图或真机截图。正文／编辑器仍由原组件负责，没有改成模型示例里的偏色阅读区。

| 页面 | 证据 |
| --- | --- |
| 首页，360dp 浅色 | [画面](../../test/features/home/goldens/home_soft_surfaces_360_light.png) |
| 首页，320dp 黑夜 | [画面](../../test/features/home/goldens/home_soft_surfaces_320_dark.png) |
| 动态，320dp 浅色／黑夜 | [浅色](../../test/features/moments/goldens/moment_soft_surfaces_320_light.png)／[黑夜](../../test/features/moments/goldens/moment_soft_surfaces_320_dark.png) |
| 个人中心，360dp 浅色 | [画面](../../test/features/users/goldens/me_page_360_light.png) |
| 账号设置，360dp 浅色／黑夜 | [浅色](../../test/features/users/goldens/account_settings_light_360.png)／[黑夜](../../test/features/users/goldens/account_settings_dark_360.png) |
| 主题设置，360dp 浅色 | [画面](../../test/features/threads/goldens/thread_management_flat_360_light_1x.png) |
| 主题设置，320dp 黑夜两倍字号 | [画面](../../test/features/threads/goldens/thread_management_flat_320_dark_2x.png) |

首版（独立 APK）源码身份由已提交开发工具的 `sourceEvidence` 读取：基线 `03adc6a1e07af2c0b72fb51da24c506ae5558aac`，候选应用源码摘要 `0d557fff6f408eb216ed6ff772ad7721c595334b89dc98d4400ebfc1296e7b62`。这是工作区源码摘要，不是 APK 或已加载设备画面的证明。

验证结果：

- 全量静态分析 `flutter analyze --no-pub` 零问题。首次发现一个因图标容器断言更新而遗留的 unused import，删除后复测通过。
- 定向 Widget/Golden 检查覆盖以下 27 个文件、347 项测试。组合运行原始结果为 346 通过、1 失败；唯一失败来自新增主题切换测试未等待 MaterialApp 测试动画完成，补上 `pumpAndSettle` 后该文件 10 项全部通过。未改产品逻辑或放宽颜色断言，也没有在修正测试时序后机械重复其他已通过测试。
- 管理子范围首轮另有旧“标题必须无边框”断言，与本次授权的输入边界不符；更新后 8 文件 131 项通过，后续组合复测同样通过。
- `dart run tool/check_architecture.dart`、`dart run tool/check_docs.dart`、改动 Dart 格式检查与 `git diff --check` 均通过。
- `app_theme.dart`、posts、editor、主题阅读、动态详情／创作、消息页面、依赖和契约无 diff；动态创作既有 Golden 未变化。读取、导航、保存、权限和隔离测试使用测试替身，没有访问线上业务写入接口。

本轮定向命令为 `flutter test --concurrency=2 --reporter expanded` 加以下文件；Goldens 更新后复测不带 `--update-goldens`：

```text
test/app/app_theme_test.dart
test/core/widgets/wenyou_filter_controls_test.dart
test/core/widgets/wenyou_settings_row_test.dart
test/core/widgets/wenyou_settings_body_test.dart
test/core/widgets/wenyou_settings_typography_test.dart
test/features/home/home_page_test.dart
test/features/moments/moment_pages_test.dart
test/features/moments/moment_bookmark_folder_page_test.dart
test/features/search/search_page_test.dart
test/features/search/thread_post_search_page_test.dart
test/features/tags/tag_threads_page_test.dart
test/features/social/bookmark_list_page_test.dart
test/features/social/bookmark_folder_management_page_test.dart
test/features/social/own_relation_lists_page_test.dart
test/features/users/public_user_page_test.dart
test/features/users/me_page_test.dart
test/features/users/me_page_visual_test.dart
test/features/users/background_reminder_settings_panel_test.dart
test/features/settings/appearance_settings_page_test.dart
test/features/settings/diagnostic_settings_page_test.dart
test/features/settings/settings_failure_retry_test.dart
test/features/threads/thread_management_page_test.dart
test/features/threads/thread_management_flat_layout_test.dart
test/features/threads/thread_management_visual_test.dart
test/features/threads/thread_management_autosave_test.dart
test/features/threads/thread_management_invite_copy_test.dart
test/features/notifications/notifications_page_test.dart
```

复测命令为 `flutter test test/core/widgets/wenyou_filter_controls_test.dart --reporter expanded`。本机原始日志保存在此 Worktree 的 `.dart_tool/soft-surfaces-tests.log`、`.dart_tool/soft-surfaces-filter-retest.log` 和 `.dart_tool/soft-surfaces-analyze.log`，不提交日志。

视觉反馈收敛后才执行仓库最终完整门禁、提交、推送和 PR；尚未合并、发布或部署。

## 首次候选的实时预览边界（历史）

- 首次视觉候选检查时 `adb devices -l` 无已连接设备；随后负责人要求 ADB 安装，设备连接与包身份已按下节核验。
- 本任务 `dev:status` 为 `stopped`；`dev:list` 无活动冲突，五个历史会话均已停止，未接管其他任务。
- VPS 默认隔离快照目录未找到北京时间 2026-10-07 的当天已校验快照，仅有历史日期。旧 consumer 的持久化 `ready` 不作为存活证明，也没有用旧快照或公网代替。
- Backend 已提交预览协议 `bc00ae8a86ba35fe9f1b2aad942db59477496cb9` 与 Mobile 固定记录一致；实际 CLI 仍使用动态 API／媒体端口，不能假定固定端口能力已上线。
- 具备设备与当天隔离快照后，重新核验 Backend PostgreSQL、Redis、上传／媒体、会话密钥及关闭外部副作用的环境身份，导出 consumer，再以本任务 `dev:start` 启动持续 Debug 会话，后续展示修改使用 `dev:reload`。

协作已传递 Auto-review 默认偏好；当前子代理入口没有审批配置参数或受支持设置入口，因此实际审批配置尚未设置／核验。完全访问或 `approval_policy=never` 没有被当作 Auto-review。

## 2026-10-07 独立 APK 与 ADB 安装

负责人明确要求“adb安装一下”后，核对唯一设备 `4b9c39b5`（`2509FPN0BC`，`arm64-v8a`）及会话登记，无其他活动 Debug 或 Flutter 会话占用。

- 使用 `npm run candidate:apk -- <上述 27 个测试文件> -TestConcurrency 2`。全仓格式、应用与生成 SDK 静态分析、347 项相关测试均通过，ARM64 Debug 构建成功。日志：`.dart_tool/soft-surfaces-candidate-apk.log`。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，110000002 字节，应用名称“温油站 Debug”，包名 `site.wenyou.app.debug`，版本 `0.8.0-debug`，构建号 `97`。APK 元数据与签名校验通过。
- SHA-256：`731f005feb3a26989c00623bb06a67bee9908a2d06e3203972de4f875def7275`。
- 安装前后候选源码摘要均为 `0d557fff6f408eb216ed6ff772ad7721c595334b89dc98d4400ebfc1296e7b62`，与前述视觉候选一致。
- `adb -s 4b9c39b5 install -r <APK>` 返回 `Success`。设备内 `base.apk` SHA-256 与本机构建完全一致；包管理器记录 `lastUpdateTime=2026-10-07 05:21:00`。
- 正式包 `site.wenyou.app` 仍为 `0.8.0 / 97`，更新时间保持 `2026-09-28 03:34:31`。没有卸载或清除应用数据。

本次仅按要求构建、安装独立候选，没有自动打开 App、登录或执行线上业务写入。APK 使用既有默认 API 配置，不是已核验隔离预览会话；当天隔离快照仍是持续 Debug 预览的未满足条件。安装成功不代替负责人的视觉与交互验收，未运行最终集成门禁、提交 PR、合并或发布。

## 2026-10-07 顶部内容页签微调

负责人确认范围为“顶部内容页签”，并批准按建议实施、热重载；沿用本任务和 Worktree。

- 移除贯穿分隔线，品牌选中线固定为 24×2dp 圆角短线，选中／未选中字重为 600／400；字体角色、48dp 命中区、等宽／溢出横滑、内容横滑和选中语义保持。
- 页面页签默认延续所属 Scaffold，首页与动态保持柔和页底；个人主页显式延续资料区 panel，私人工具与页签之间也不再绘制分隔线。面板内页签默认透明，以继承所在表面。
- 动态加载和内容列表顶部间距统一为 8dp。底部主导航、阅读／创作与楼中楼没有调整。
- 共用组件覆盖既有搜索、消息、收藏、个人关系和表情页消费者，不重构这些页面的业务流程。

应用源码摘要：`d116f78fa6c7d84d83ec0b04e09120060ea8eaba21a61f398128229b7f154207`。这是本次页签候选，与前一节已安装 APK 的源码不同；没有把初装 APK 的哈希当作本次画面证据。

已查看首页和个人中心的实际 Widget/Golden，覆盖浅色、黑夜、320dp 窄屏及两倍字号；新增共享页签两种表面在 320dp 明暗主题下的基线。Golden 使用测试数据，不代表手机当前画面。

`flutter analyze --no-pub` 零问题；以下 15 个文件以 `flutter test --concurrency=2 --reporter expanded` 正常比较基线，共 295 项全部通过，未使用更新基线参数复测。日志为 `.dart_tool/soft-tabs-tests.log` 和 `.dart_tool/soft-tabs-analyze.log`。

```text
test/core/widgets/wenyou_filter_controls_test.dart
test/features/home/home_page_test.dart
test/features/moments/moment_pages_test.dart
test/features/users/me_page_visual_test.dart
test/features/users/me_page_test.dart
test/features/threads/thread_management_flat_layout_test.dart
test/features/threads/thread_management_visual_test.dart
test/features/threads/thread_management_page_test.dart
test/features/social/bookmark_list_page_test.dart
test/features/notifications/notifications_page_test.dart
test/features/search/search_page_test.dart
test/features/users/public_user_page_test.dart
test/features/social/own_relation_lists_page_test.dart
test/features/stickers/sticker_collection_page_test.dart
test/features/stickers/sticker_reorder_grid_test.dart
```

首次请求热重载时，本任务无持续 Debug 会话，历史登记均已停止。已核验的管理快照入口为 root 所有的已合并版本 `144a19585261bfce8330eb4c9cbe8f61d7eb4bb7`，启用记录限定 `existing-backup-only`；当天没有源逻辑备份，不能改用旧快照或公网。现有 `wenyousite-postgres-logical-backup.service` 支持手动运行，但会在线 pg_dump、上传异地备份并执行既有本地 7 天保留策略，曾向负责人请求提前执行一次的具体授权；随后负责人明确要求“不用隔离环境，直接开始”，因此本任务取消该备份请求，改为直接连接既有开发后台建立 Flutter Debug 会话。没有运行备份服务或改动凭据；这项明确授权仅用于本轮开发反馈，不修改仓库通用预览规则。

## 2026-10-07 直接调试与消息页追加

负责人明确指令“不用隔离环境，直接开始”，随后追加“消息页也要调整”。这两项指令覆盖本任务此前的等待隔离快照和消息页排除项；仅改变本批开发反馈范围，不改通用治理规则，不执行线上备份或部署。

消息中心、游客引导和独立私聊列表复用浏览页背景；通知与会话行使用连续的 panel 表面，只有列表首尾圆角，内部分隔线缩进，没有逐行卡片或永久阴影。信息、未读、删除确认、筛选、分页和懒构建保持；私聊正文／输入区及楼中楼保持原样。

- 定向检查：`test/features/notifications/notifications_page_test.dart`、`test/features/direct_messages/direct_messages_page_test.dart` 正常 Golden 比较和交互测试共 29 项全部通过。原有通知明暗 320dp 两倍字号基线已更新，新增私聊 360dp 普通字号及 320dp 两倍字号明暗基线。日志 `.dart_tool/soft-messages-tests.log`。
- 静态检查初次发现一处分支缺少花括号；补齐花括号，不改变条件或返回值。日志 `.dart_tool/soft-messages-analyze.log` 保存修正后的复测结果。
- Native Flutter machine 会话使用本任务临时启动脚本 `.dart_tool/direct-debug.mjs`，直接连接 `https://wenyou.site/api/v1`，没有传入或伪造隔离 preview defines。通用 `dev:start` 保持只支持隔离描述，不改仓库工具契约。
- 设备 `4b9c39b5`，包 `site.wenyou.app.debug`；首次启动使用已核验 ADB guard，保留应用数据，安装更新时间 `2026-10-07 05:47:13`。初装设备 APK SHA-256 为 `a8e76263c432392b2282bb8588e519b03aa95a2de88430f2cea397b8dd6200a7`。
- 会话 appId 为 `7631fa6a-75a3-41c4-8565-6e4a6cab505c`。最终成功 reload 于北京时间 `2026-10-07 05:52:20` 返回 `code=0`（Reloaded 1 of 4689 libraries）；当前加载源码摘要为 `bfc551e8370521ebac5a2e426b59b45899c7c6849993cccc8c44c060635936e8`。设备进程仍为 `24609`，没有为后续微调重新安装。
- 本机私有会话事件保存在 `%LOCALAPPDATA%/Wenyou/direct-debug/ea80649f1c810b541e4b/events.jsonl`，记录进程、设备、工作目录、加载摘要和 reload 结果。反馈期间会话持有设备锁并使用已有 Job Object 保护；负责人授权合并后，于北京时间 2026-10-07 05:59:30 正常停止并释放设备锁，进入正式包准备。
- 热重载后的只读设备截图为 `.dart_tool/ui-review/02-after-reload.png`。截图时负责人正在主题管理权限弹层，未自动关闭或替用户切页；消息页明暗窄屏效果以实际 Widget/Golden 辅助核查，负责人可在手机打开消息分支查看。没有自动执行通知已读／删除、消息发送或设置修改，未把静态 Golden 当作真机观感验收。

消息页画面：[通知](../../test/features/notifications/goldens/notification_tabs_360.png)、[私聊浅色](../../test/features/direct_messages/goldens/direct_list_soft_light_360_1x.png)、[私聊窄屏黑夜两倍字号](../../test/features/direct_messages/goldens/direct_list_soft_dark_320_2x.png)。

## 负责人验收与合并授权

负责人在上述热重载候选上明确授权合并，绑定源码摘要 `bfc551e8370521ebac5a2e426b59b45899c7c6849993cccc8c44c060635936e8`。后续仅提高正式版本号并补全发布记录；独立正式签名包仍需按发布流程核验，不把 Debug 验收写成正式制品已测试。只读协作审查未发现必须修复的问题。

发布版本 `0.9.0+98` 的最终完整门禁已通过：Flutter 5,437 项通过、1 项原有显式外部诊断跳过，Windows 发布工具 88 项全部通过，其余契约／静态／文档检查通过。全量检查发现的旧图标强转断言和四张标签弹层旧背景基线已经修正、逐张查看并复测；没有改变负责人已确认的应用行为。失败与复测、最终源码摘要详见[发布准备](mobile-0.9.0-release-preparation.md)。

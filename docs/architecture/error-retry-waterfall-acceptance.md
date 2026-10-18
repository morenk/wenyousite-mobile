# 错误重试与动态瀑布流统一验收

## 状态与范围

2026-10-18 视觉候选／待负责人验收。此任务统一读取失败的公共表达与装配，以及动态列表和动态收藏的瀑布流布局。不改变网络重试、分页状态机、接口、写入逻辑、Markdown、编辑器或依赖版本；不合并、不发布。

- Worktree：`D:\codex-worktrees\ea98\wenyousite-mobile`。
- 分支：`codex/20261018-error-retry-waterfall`。
- 最终修改后应用文件集合 SHA-256：`282e726d6a09ce1d1f3a75aef4604184d4bbf41dc1c94c20c76951b7ec84010a`（23 个 lib 文件，按仓库相对路径排序，依次串联路径、换行及文件原始字节）。精确提交 SHA 见 PR 和交付消息。
- 起点：更新后的 `origin/dev`，`185b72f2d72affce2ecb3dd6a75535bc5f1a1875`。
- Foundation：执行只读镜像 `git fetch origin --tags`，最新正式 Tag 仍为 `v7.5.0`，与 pubspec 固定版本一致。已读该 Tag 的 CHANGELOG、元素及 `foundation.v1.json` 反馈／集合契约；保留 `moments-feed: two-column-waterfall`、8dp 卡间距及平台主题。没有新增用户列数设置。
- Backend：固定 revision、只读镜像 `origin/dev` 和公网只读 `/meta.buildSha` 均为 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`，契约均为 `5.40.0-dev.20261018.1`，无需同步。
- 审批来源：当前任务的宿主运行上下文显示 `approval_policy=never`、`sandbox_mode=danger-full-access`、文件系统 unrestricted、网络 enabled；未提供 `resolvedApprovalsReviewer`。默认偏好已传递，实际 Auto-review 配置尚未设置／核验，现有工具没有支持的设置入口；没有修改全局配置，也不将 never 当作 Auto-review。

## 实现与迁移清单

`WenyouRetryFailure` 复用 `UserFacingFailure`、`WenyouFailureView` 与主题语义图标，整页内容使用描边重试，局部内容使用文字重试。重试标签和回调显式配对，不借用登录／复核等业务恢复标签。问题编号、业务文案、图标和忙碌禁用状态保留；取消错误不创建错误面板。`WenyouPageFailureState` 和 `WenyouLoadMoreControl` 也使用同一装配，页面继续拥有滚动与布局容器。

| 页面 | 迁移内容 |
| --- | --- |
| home/home_page | 首屏及刷新／分页局部错误；首屏 FilledButton 改为 OutlinedButton |
| search/search_page、thread_post_search_page | 全站与主题内首屏搜索失败 |
| threads/thread_member_management_page、subthread_management_page | 管理读取失败，保留权限提示与 PageBody；子贴管理统一描边重试 |
| moments/moment_feed_page、moment_bookmark_folder_page | 首屏失败；共用瀑布流布局及加载骨架 |
| app_shell/bookmark_folder_catalog_page | 收藏目录首屏及刷新失败 |
| direct_messages/direct_conversation_page、new_direct_conversation_page | 会话／联系状态读取失败，保留 404 文案及图标 |
| moderation/moderation_appeal_page | 治理决定读取失败；凭据检查和申诉提交保持原流程 |
| settings/login_sessions_page | 登录终端读取失败 |
| social/bookmark_list_page、user_relation_list_page | 收藏与关系首次读取、收藏分类与列表局部失败 |
| stickers/sticker_collection_page | 收藏表情首次读取失败 |
| users/me_page、public_user_content | 本人资料、编辑前资料与公开内容读取失败，保留隐私变更提示 |
| wallet/wallet_page | 余额、流水首次读取与余额刷新失败，保留独立容器 |

`MomentWaterfallSliver` 集中列数策略、按可用 sliver 宽度计算的边距、600dp 内容上限、间距、稳定 Key 索引与跨列 footer。`MomentWaterfallLoadingSliver` 复用该布局及原动态骨架，收藏加载从普通列表骨架统一为瀑布流骨架。业务卡片仍是 `MomentWaterfallCard`；点赞、收藏管理、导航、刷新、预加载与 footer 内容由原页面提供。保留页面和条目原 Key 值、卡片顺序、页面滚动恢复及不同 footer 底距。

合理保留：

- 邀请失效返回首页、主题／动态不存在时不提供重试、标签管理 403 不提供重试、楼中楼按条件提供恢复等业务分支保留原专用状态。
- 登录引导、隐私／权限说明、业务为空或无搜索结果不并入读取失败。
- 写入确认、结果不明、知道了／清除错误、多动作冲突及编辑器／草稿发布相关状态不迁移。
- `WenyouFailureBanner` 继续服务于没有统一重试动作或提供其他业务 action 的场景。
- 钱包等复合面板和页面滚动容器继续由业务页面持有，不强制共用一个 PageBody。

## 自动验证与画面

新增定向测试：

- `test/core/widgets/wenyou_retry_failure_test.dart`：权限与重试配对、取消隐藏、问题编号、语义标签、48dp 触控、320/360dp 明暗及 1x/2x 字号，共 8 张失败／分页 Golden。
- `test/features/moments/moment_waterfall_sliver_test.dart`：单双列配置下重排／删除／追加保留条目状态及回调、footer 在所有卡片之后跨列，320/360dp 明暗两倍字号分页及加载骨架，共 8 张 Golden。

第一批定向回归通过 128 项，实际命令：

```powershell
flutter test --no-pub --concurrency=2 test/core/widgets/wenyou_retry_failure_test.dart test/features/moments/moment_waterfall_sliver_test.dart test/core/widgets/wenyou_pagination_test.dart test/features/home/home_page_test.dart test/features/search/search_page_test.dart test/features/search/thread_post_search_page_test.dart test/features/threads/thread_member_management_page_test.dart test/features/threads/subthread_management_page_test.dart test/features/moments/moment_pages_test.dart test/features/moments/moment_bookmark_folder_page_test.dart
```

其中现有真实页面覆盖加载、空态、失败恢复、刷新、分页、滚动回收、点赞与收藏管理回调。该批后仅继续迁移收藏目录／收藏列表／余额局部读取失败装配，及治理决定首屏读取失败装配，并清理静态分析报告的 import 与语法风格；最终源码以完整门禁结果为准。

Golden 首次生成过程中曾因测试语义句柄在 teardown 才释放触发测试框架检查失败，已在测试结束前显式释放，随后上述定向回归全部通过。未更新任何既有 Golden 基线。

截图路径均在当前 Worktree：

- `test/core/widgets/goldens/retry_failure_{320|360}_{light|dark}_{1|2}x.png`
- `test/features/moments/goldens/waterfall_retry_{320|360}_{light|dark}.png`
- `test/features/moments/goldens/waterfall_loading_{320|360}_{light|dark}.png`

截图为离线组件实际渲染，代理已查看代表性的明暗、两倍字号和骨架画面；不是设备截图或负责人验收。瀑布流新增测试中的有状态卡片用于验证布局身份，真实 `MomentWaterfallCard` 的已有整页 Golden 另由页面测试验证。

最终完整门禁命令：`npm run check -- -TestConcurrency 2`，退出码 0。OpenAPI、固定契约来源、再生成一致性、公网只读兼容、格式、应用与生成包全量静态分析、架构、文档及 API 覆盖全部通过；Flutter **7258 通过／1 条件跳过**，Windows 工具测试 **49/49 通过**。既有 Golden 无差异，接口、依赖锁文件及生成客户端零漂移。

本地完整日志：`D:\codex-worktrees\ea98\wenyousite-mobile\.dart_tool\task-evidence\error-retry-waterfall\check.log`，SHA-256：`d0f1939a6ecb91c05a21ec5f8988b94dac2c5c57b869c3c9e8fb0873aa5c3552`；同目录 `targeted.log` 为 128 项定向回归日志。日志目录被 Git 忽略，保留在本任务 Worktree，不包含在 PR 中。唯一已有跳过项是 `test/core/diagnostics/diagnostic_live_receipt_test.dart`，需要显式 `WENYOU_VALIDATE_SENTRY` 才执行真实诊断回执验证；本轮未开启该外部写入验证。

## 真机候选与负责人步骤

初次提交时没有连接设备，仅完成离线组件和页面验证。负责人随后连接设备并要求热重载验收；2026-10-18 23:35 已完成以下补充，视觉候选仍待负责人验收：

- 应用源码提交：`d9eb2be6d6c8431c6615f5a2f48ecdceab63aaf3`，应用文件摘要与上文一致；后续仅调整文档，未改应用代码。
- 设备：`4b9c39b5`／`2509FPN0BC`，ARM64；目标为 `site.wenyou.app.debug`，版本 `0.9.0-debug`、versionCode `99`，与正式包数据独立。
- 在本 Worktree 执行 `npm run dev -- -d 4b9c39b5 --machine`，经过 ADB guard 覆盖安装成功，未卸载或清数据。设备包更新时间为 `2026-10-18 23:30:34`。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，112823010 字节；本机与设备内 base.apk SHA-256 一致：`9080f7acafc4ad2f621ac5802553f3522e87d229059a6d19cd5011bdd2093339`。此哈希标识首次安装包，热重载画面另按源码及会话记录。
- 初始 run 安装后连接断开，应用仍运行；使用 `flutter attach -d 4b9c39b5 --app-id site.wenyou.app.debug --machine --no-dds` 成功重新接入，无重复构建或安装。应用 PID `5162`、宿主 Flutter PID `34224`、终端会话 `37362`、machine appId `6db93dcf-e892-484c-89cc-8c74572f07a8`（均为此次记录时值）。
- machine `app.restart(fullRestart:false)` 返回 `code:0`／`Reloaded 0 libraries`，耗时 53803ms（compile 49470ms、reassemble 116ms）。源码无新增变化，因此 0 个库重载属于成功；会话保持连接以供后续展示调整。
- 实际 API 为默认 `https://wenyou.site/api/v1`，没有自定义 Dart defines。按负责人本次明确要求，普通 Debug 的登录恢复和自动签到不再作为启动、复用或热重启的检查／审批条件；产品启动逻辑未修改，代理未自动执行发帖、上传、删除等业务写入 E2E。
- 设备画面和结构化记录保留在被 Git 忽略的 `.dart_tool/task-evidence/error-retry-waterfall/device-after-reload.png` 与 `debug-session.json`；画面含设备个人信息，不提交。代理查看当前页面仅证明候选运行，不替代负责人对下列场景的验收。

普通 Debug 规范同步更新了 `AGENTS.md` 和 `docs/live-debug.md`，`npm run docs:check` 与 `git diff --check` 通过。仅文档变化不重复执行已通过的应用完整门禁。

1. 首页、全站搜索、主题内搜索和成员／子贴管理制造读取失败，核对状态、问题编号与原重试目标；恢复后原筛选和页面可继续使用。
2. 已有内容时触发刷新或分页失败，确认内容保留、不会静默重复请求；重试忙碌时不能重复触发。
3. 动态发现／关注／用户动态和动态收藏检查双列顺序、连续上下滚动、下拉刷新、分页尾部跨列，以及点赞／打开详情／收藏管理入口。
4. 明暗模式、320/360dp 与两倍字号核对错误换行、按钮完整可点、分页 footer 无裁切；TalkBack 检查错误与动作名称。
5. 本轮仅视觉候选，负责人明确反馈前不得记为视觉验收通过或可合并。

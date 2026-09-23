# 本人关系管理候选验收

状态：候选／待负责人验收。仅 Windows Mobile；治理任务 `01a0c4bb-9204-7662-93c3-648b8fa03f59`。分支 `codex/20260922-mobile-relations-management`，基线 `c5ba6668`。

## 最终集成候选

本轮锁定 Mobile `origin/dev` 的 `536bc30652dd5d40eff9df90b2602e7c56f5e580`，普通合并提交及最终应用源码为 `fbddcf1436426dcc7796377be89b5162e3a112ec`。该基线在前一候选验证期间合入能力修复；真实文本冲突仅 CHANGELOG 和 21 模块的契约记录，保留双方说明。契约与生成客户端逐字节相同，无需再次生成。自动合并的 API 清单去除重复项，已消费的移除粉丝继续计入覆盖，不退回计划排除。

关系、会话核心与受控弹层代码无冲突；直接调用交集是举报说明按 Unicode code point 计数、共享 SnackBar 的构造提取。整合其他输入、草稿和评论附件修复后，对同一最终树重新运行完整 `npm run check:apk -- -TestConcurrency 4`，**exit 0**（`build/relations-536-final-gate.log`）：Flutter **4734 项通过、1 项既有真实 Sentry 回执验收跳过、零失败**，Windows 发布工具 **18 项通过**；格式、双 analyze（零问题）、架构、21 模块文档、API scope 159/159、契约、生成一致性及生产精确来源检查全部通过，APK 构建成功。

运行期间本机发生长时间暂停，测试 elapsed 从约 5 分钟跃升至 946 分钟以上；原因未据此断定。恢复后原进程与测试计数继续推进，无 TimeoutException 或测试失败，保留原运行完成结果，不把显示的 elapsed 表述为持续计算时长。Gradle 构建 304.2 秒，既有 Kotlin 插件和 SDK XML 工具版本提示未影响成功结果。

当前 APK：`build/app/outputs/flutter-apk/app-debug.apk`，**223,911,942 字节**，SHA-256 **`2292997BEFBC3271E309497746DA5D7184BD4D2EBCB644CC4242143B1B529EAC`**。包名 `site.wenyou.app.debug`，版本 `0.7.1-debug` / `95`，minSdk 26 / targetSdk 36，默认 API `https://wenyou.site/api/v1`。固定 Backend `92b030a81f8957386e324fed477bd1e46faf65ea` / `5.26.0-dev.20260922.3`、正式 Foundation v7.1.0；说明性关系规范引用 `7263db135530326ac42b206eeffbf6f179513a91`。尚未安装、发布或通过负责人真机验收。

最终 `536bc306` 集成树的 12 张亮暗、关注／粉丝／菜单、390dp 正常字与 320dp 双倍字截图再次以正常 Golden 比较通过（`build/relations-536-screenshots.log`），与 `build/relations-compact-v2-{list|following|sheet}-{light|dark}-{1x|2x}.png` 无像素差异，没有更新基准。测试中文字体不打包产品，截图不替代真机验收。

前一 `8A363` APK 已另存 `build/relations-candidate-8A363.apk`，其通过证据仅覆盖当时的 `78224480` 基线；以下记录均保留历史含义，当前候选以本节为准。后续验收文档提交不改变已构建的应用源码。

## 历史开发基线整合候选

2026-09-23 在原分支普通合并 `origin/dev` 的 `78224480bcb95aa0af88b06820fcfa7f671c936d`（合并提交 `e8eeda1b`），保留紧凑关系管理并整合已合入的设计统一。回复时间沿用新共享组件，避免重复读屏日期；72 小时与未来日期边界测试保留。关系菜单入口复用新增 `showWenyouSheet`，继承宽度、安全区、键盘和高度约束，固定会话与受控路由关闭逻辑不变。

正式脚本从只读 Backend 镜像同步并生成 `92b030a81f8957386e324fed477bd1e46faf65ea` / `5.26.0-dev.20260922.3`（独立提交 `21e07128`）。新增图集读取与管理端记住设备类型，关系接口及投影保持；不在本候选接入图集功能，不改 Backend。Foundation fetch 后最新正式 Tag 仍为 v7.1.0，依赖不变；说明性关系规范最新整合提交为 `7263db135530326ac42b206eeffbf6f179513a91`，交互文档与此前 `d96520b` 一致。

日期、时间组件、关系页面和举报定向 36 项通过；契约校验、固定来源、21 模块文档与 API scope 159/159 通过。整合后 12 张关系截图使用正常比较模式通过（`build/relations-resume-screenshots.log`），与下述 v2 PNG 无像素差异，未更新 Golden。

最终完整入口 `npm run check:apk -- -TestConcurrency 2` **exit 0**（`build/relations-resume-final-v2-gate.log`）：格式、应用和生成包 analyze（零问题）、架构、文档、API 覆盖、契约及再生成一致性全部通过；生产只读核验直接匹配精确 `92b030a81f8957386e324fed477bd1e46faf65ea` / `5.26.0-dev.20260922.3`、部署 Markdown 5 与 `GET /threads`。Flutter **4710 项通过、1 项既有真实 Sentry 收件验收跳过、零失败**；Windows 发布工具 **18 项通过**，Debug APK 构建成功。

前一轮 `build/relations-resume-final-gate.log` 在新增图集端点诊断索引校验失败后主动终止，未完成门禁，不冒充全绿。随后运行仓库 `tool/generate_diagnostic_routes.dart` 并格式化，生成差异仅新增 `galleryList` 一条诊断映射；定向 9 项通过（`build/relations-resume-diagnostic-recovery.log`），最终完整运行包含该恢复回归。该修正不接入图集业务。

新版候选 APK 为 `build/app/outputs/flutter-apk/app-debug.apk`，**223,908,489 字节**，SHA-256 **`8A36344C5F754FC605E70E1E4EADB2583EC2CD6A666E3AE33DD4E1C5D4A2499F`**。`aapt` 核实 `site.wenyou.app.debug`、`0.7.1-debug` / `95`、minSdk 26 / targetSdk 36；默认连接 `https://wenyou.site/api/v1`，未传入覆盖地址。仍为待负责人真机验收的 Debug 候选，未安装或发布；既有 Kotlin 插件迁移提示不影响构建。本包替代下文旧 AF780 APK，旧运行与手测证据只保留历史含义。

## 历史紧凑列表修订候选

本轮按 Foundation 关系体验文档候选 `d96520b` 实现紧凑扁平列表；正式依赖仍为 v7.1.0，Backend 仍锁已部署 `4850e2f456ccc452c763853641e3b2136901e237`。下面历史卡片 APK 与第二行描边截图已被本轮设计替代，不作为新界面的验收依据。

- 返回与数量页签同顶栏；40dp 头像、body 中等昵称、caption 等级、昵称起细分隔线。正常行约 65dp，无卡片阴影；长名省略保留完整语义，大字空间不足时自然增高、操作换行，命中区至少 48dp；主／状态按钮在实际 Semantics 树中包含用户名与动作，处理中保留目标。
- 关注／回关使用等宽 filled，已关注／互相关注使用等宽 tonal；状态和更多打开同一菜单。菜单有完整身份、拖柄及关闭，依次为 capability 私聊、条件取消关注、条件移除粉丝、拉黑、举报；先关菜单再进入已有流程。
- 关注和移除只改变选定方向；拉黑不删除关注，以服务端可见性为准。未知拉黑读取 projection.isBlocked，不凭行消失判断；共享行锁覆盖拉黑，visibility 不清空锁，旧读取不能覆盖新核实。
- 菜单和确认有同步关闭守卫，仅撤下所属路由；切号清除旧目标上下文。共享举报表单与控制器按会话隔离，迟到回调不能以新账号提交或显示旧成功。三个浮层都从打开入口传入固定 SessionScope，覆盖路由已 push 但首帧尚未构建就切号的边界；旧实现已用确定性举报回归复现失败，修订后菜单、两种确认及举报均通过。

Widget 使用 10 条模拟用户与系统现有中文字体，覆盖 390dp 正常字和 320dp 双倍字、亮暗列表及菜单：`build/relations-compact-v2-{list|following|sheet}-{light|dark}-{1x|2x}.png`。图为 Flutter 测试渲染，不代表 Android 真机验收；产品未捆绑测试字体。

本轮最终应用源码执行 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，日志为 `build/relations-session-final-gate.log`。OpenAPI、固定来源、客户端再生成一致性、格式、应用与生成包静态分析（零问题）、架构、21 个模块文档及 API 覆盖均通过；Flutter 全量 **4667 项通过、1 项既有跳过、零失败**，Windows 发布工具 **18 项通过、零失败**，Debug APK 构建成功。跳过项是未启用的真实 Sentry 回执验收，不执行线上写入。

完整调用保留 **exit 1**：唯一失败是 VPS 短暂不可达期间的生产契约检查 `HandshakeException: Connection terminated during handshake`；未改写原日志。公网恢复后，同一应用源码独立运行 `npm run api:verify:production` **exit 0**，日志 `build/relations-session-production-recovery.log` 核实 API/bundle `5.25.0-dev.20260922.1`、精确 buildSha `4850e2f456ccc452c763853641e3b2136901e237`、部署 Markdown 5 和 `GET /threads` Schema 兼容。这是原完整运行与同源码补验的组合证据，不声称原调用全绿。

最终定向会话、菜单、确认、控制器和共享按钮回归 **56 项通过**（`build/relations-session-final-focused.log`）。旧举报实现的“路由已打开但首帧未构建就切号”确定性回归先失败（`build/relations-session-first-frame-before.log`），修订后与另外三个关系浮层首帧回归通过。最终 12 张截图以正常 Golden 比较方式复核通过（`build/relations-compact-screenshot-verification.log`），未在复核时更新基准。

新版 Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`，**223,879,501 字节**，SHA-256 **`AF780B67AFBAFAFEB79868E130E7ECA80499B9DB034C68DA38A67CA7FFAF5371`**。`aapt dump badging` 核实包名 `site.wenyou.app.debug`、版本名 `0.7.1-debug`、构建号 `95`。构建未传入 `API_BASE_URL`，默认连接 `https://wenyou.site/api/v1`；这是待负责人真机验收的 Debug 候选，不是正式发布包。既有插件 Built-in Kotlin 迁移警告不影响构建。未自动安装、线上写入或发布 APK；后续仅文档补充不改变本 APK 的应用源码。

## 历史首轮依赖与实现

- Foundation 正式 v7.1.0（`dcf75d385e39cc0c55d550a6f35921cd9a7aa508`）；共享体验文档 `ba1e921212b908835734732f26e263203a8226c6` 仅作为说明，不直接消费未发布代码。
- Backend 当前固定 PR #26 合并提交 `4850e2f456ccc452c763853641e3b2136901e237`，API `5.25.0-dev.20260922.1`；原候选 `ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a` 的契约字节不变。来源均经只读 Git 镜像与正式同步脚本记录，原候选客户端由 OpenAPI Generator 生成，不手改生成类型。
- 本人双列表共用行锁、双向投影与写入世代，成功才更新；移除粉丝保留反向关注。三个列表动作复用现有 outlined 按钮，Mobile 操作区第二行靠右；不新增 Token。

## 历史首轮自动检查与构建

执行完整高风险入口 `npm run check:apk -- -ContinueAfterFailure`，不绕过生产契约比对。本地仓储、控制器和 Widget 写入全部使用模拟数据，公网仅读取 `/meta` 与契约；没有线上登录或业务写入。

- OpenAPI 校验、固定来源、客户端重新生成一致性、格式、应用／生成包静态分析、架构、21 个模块文档及 159 个消费操作覆盖检查通过；Windows 发布工具 18 项通过。
- 完整 Flutter 运行记录为 4620 项通过、1 项跳过、28 项失败，日志 `relations-final-gate.log` 如实保留，没有改写为全绿。失败包含诊断端点索引 1 项、Foundation 日期迁移的 25 个 Golden 用例（37 张图片）、运行起点早于修复的同帧双击 1 项（随后在新进程两次通过），以及新增旧式失败文案构造 1 项。
- 已使用仓库生成器同步诊断索引；37 张 Golden 逐张查看差异（包含收藏管理面板遮罩后的日期背景），仅日期移除时分（320dp 双倍字收藏行因此有空间显示更多姓名），没有借机修改页面设计。新的进程使用正常比对模式统一复跑全部 7 个失败文件，163 项通过，日志 `relations-final-recovery.log`；另一次整个 social 目录 158 项通过，日志 `relations-social-final.log`。
- 最后移除旧式异常文案构造，保留原始失败分类和请求编号，展示通过 `UserFacingFailure`；不明状态仍由共享 `unconfirmed` 驱动只读刷新与写入禁用。最终 controller／page／文案门禁 23 项通过，日志 `relations-final-copy-social.log`。
- 首轮公网只读检查未通过：期望 API `5.25.0-dev.20260922.1`／`ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a`，实际 API `5.24.0-dev.20260920.1`／`adf8139ff75da3168435f6d58ce4f134f5dcbb6a`，Markdown 5 在支持范围内。这是该轮的发布前阻塞，后续精确来源同步与核验结果见下方“历史兼容后端来源复核”；原日志不改写为通过。

统一恢复命令为 `flutter test --no-pub --concurrency=1`，参数依次为 `test/core/diagnostics/diagnostic_enrichment_test.dart`、`test/features/direct_messages/direct_conversation_page_test.dart`、`test/features/posts/post_reading_quick_scroll_test.dart`、`test/features/social/bookmark_list_page_test.dart`、`test/features/social/own_relation_lists_page_test.dart`、`test/features/threads/thread_detail_page_test.dart`、`test/features/threads/thread_reading_quick_scroll_test.dart`。最终源码 `flutter analyze --no-pub --fatal-infos --fatal-warnings` 零问题，`dart run tool/check_architecture.dart` 通过；最终格式及文档检查复验通过。APK 摘要见下文。

## 历史首轮 APK 与 Widget 渲染证据

最终 Debug 候选由 `flutter build apk --debug --no-pub` 从最终源码构建成功。路径 `build/app/outputs/flutter-apk/app-debug.apk`，183,495,226 字节，SHA-256 `A240C77F8ABE6E71979BC7AE198BB96CFA226B9FD4CC8E0EEC5A4EAB238F8E91`。`aapt dump badging` 确认包名 `site.wenyou.app.debug`、版本名 `0.7.1-debug`、构建号 `95`；未安装到设备。构建仍提示既有插件 Built-in Kotlin 迁移警告，未影响本次 Debug 构建。

应用源码提交为 `6cf95dcca4bad5be2fbd2a30c31e50ac79104322`；其后交付文档补充不改变 APK 源码。本次构建未传入 `API_BASE_URL`，默认连接 VPS 公网开发 API `https://wenyou.site/api/v1`，仍为待负责人验收的 Debug 候选而非正式发布包。该环境自动化仅允许只读；若需要代理执行关系写入联调，须先验证独立隔离后端身份，再使用对应 API 地址重新构建并另记候选 SHA-256。负责人在兼容后端部署核验完成后可使用本 APK 手动验收，这不等于授权代理在线写入或安装设备。

`build/relations-ui-followers.png` 来自最终共享页签与描边按钮 Widget，PNG SHA-256 为 `5524A09A17B82F75D5F51D429DC8CB62193326D0D0550671FCD5FD52BA88EAED`。仅测试从 Windows 现有 `msyh.ttc` 加载中文字体，产品不捆绑字体；该图用于布局/样式审查，不等于 Android 字形或真机验收。包含回关与互关两种行，另外 Widget 回归验证 320dp 双倍文字、长姓名与亮暗模式不溢出、操作区不少于 48dp。

## 负责人手动验收清单

- 兼容后端部署与生产来源核验完成后，负责人使用本 Debug 候选手动验收；核对包名 `site.wenyou.app.debug`，本任务不自行安装或操作设备。代理若需自动化写入测试，仍只允许身份已核验的独立隔离环境。
- 从“我的”的关注/粉丝与自己的公开主页进入；初始页签正确，切换后各自位置保留。查看他人列表没有管理按钮，旧链接和返回行为正常。
- 单向与互关分别取消：关注页移行；粉丝页保留并变回回关。回关变互关；移除粉丝仅移出粉丝页，自己的关注保留，取消确认不写入。
- 互关用户在两个页签打开状态或更多，确认菜单顺序及取消／移除均存在；私聊 capability 关闭时入口隐藏。拉黑确认取消无写入，确认后只改变可见性，已有双向关系不删除；从其他入口解除后重新进入菜单可再次管理。
- 菜单、移除／拉黑确认及举报期间切号，旧弹层关闭；快速双击关闭不退出列表，异步完成不关闭后来打开的页面。
- 返回本人主页、本人公开主页和对方主页，核对数量与关系状态。失败留行及确认框；断网或超时仅刷新核实，不自动重复写；快速点击、切换页签与切号不污染状态。
- 亮色/黑夜、长姓名、小屏和双倍字体下检查等宽主／tonal 状态按钮、底部菜单、触控区域、按钮换行、读屏对象名、焦点返回、系统返回与安全区。Widget 渲染仅辅助审查，不能替代真机验收。

## 发布边界

Mobile 交付到分支、提交与 PR；未合并 Mobile、发布 Tag、部署 Mobile 或安装 APK。合并和发布需遵守治理门禁，真机验收未完成。

生产契约检查按精确 `buildSha` 比较；本次已用正式脚本同步 PR #26 合并提交 `4850e2f456ccc452c763853641e3b2136901e237`。部署完成后仍须独立核验生产来源，不能仅凭契约字节一致推断上线成功。

## 历史兼容后端来源复核

已从只读 `origin/dev` 用 `tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Branch dev -Revision 4850e2f456ccc452c763853641e3b2136901e237` 同步。Backend 两个提交的 `contracts` 目录无差异；Mobile OpenAPI SHA-256 为 `1CF55F50091E14B4118C12355D6DFC82AD90752DBAB3FEC7F246894CC8351BC9`，与原候选一致。生成客户端、`lib`、Android/iOS 配置和 `pubspec` 无差异，既有 APK 的 SHA-256 仍为 `A240C77F8ABE6E71979BC7AE198BB96CFA226B9FD4CC8E0EEC5A4EAB238F8E91`，无需重建，可继续作为真机验收候选。

管理入口完成兼容后端部署后，Mobile 独立运行 `npm run api:verify:production` 通过：API/bundle `5.25.0-dev.20260922.1`，精确 buildSha `4850e2f456ccc452c763853641e3b2136901e237`，部署 Markdown 5 在支持范围内，`GET /threads` Schema 兼容。随后固定契约来源检查与 21 个模块文档检查再次通过，日志分别为 `relations-merged-production-check.log`、`relations-merged-source-check.log`、`relations-merged-docs-check.log`。原生产来源阻塞已解除；本次仅修改来源与文档，不重建 APK、不重复无源码变化的全量测试，也不替代负责人真机验收。

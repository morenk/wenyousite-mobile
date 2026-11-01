# 创作可靠性验收与合并记录

## 现场与边界

日期：2026-10-27。任务独立 Worktree 为 `D:\codex-worktrees\c98b\wenyousite-mobile`，初始 detached HEAD 与更新后的 `origin/dev` 同为 `6601eea95ad783acf082f5ab6abc472b950b2488`，初始工作区干净；编辑前建立 `codex/20261027-compose-reliability`。未接管主 checkout、其他任务或设备会话。

治理要求已读取 `D:\code\wenyousite\AGENTS.md`、`docs\task-dispatch.md`、`docs\live-development-preview.md` 和本仓 `AGENTS.md`。默认偏好已传递，实际 Auto-review 审批配置尚未设置／核验：宿主提供的有效策略为 `never`、文件系统无限制，当前工具无受支持的审批配置入口，未发现 `resolvedApprovalsReviewer=auto_review` 生效证据；不能把该策略称作“帮我批准”。

用户设备 HONOR NTH-AN00、Android 14／API 34、正式包 `site.wenyou.app`、`0.11.0+101`。参考图片保留在仓库外的 `D:\dev-cache\tmp\codex-clipboard-066839bc-5016-40b1-a9ce-d31639d54134.jpg` 与 `codex-clipboard-6e1a130c-8553-4473-a3c1-148062056d8a.jpg`，不把用户草稿或图片提交到 Git。

| 子项 | 原始步骤与现象 | 当前状态 |
| --- | --- | --- |
| A 标题输入 | 正文已有文字和一张图，点击“一句话说明这个主题”输入框无反应；画面同时有“正在准备发布选项…”与“草稿已保存” | 本批负责人验收通过 |
| B 系统返回 | 唯一导出记录是 `flutterError`／`StateError`，堆栈指向 go_router delegate 空 `matches.last`；当时的完整返回操作顺序未知 | 空配置机制已离线复现并防护；本批负责人验收通过 |
| C 动态发布 | 一张图、标题和正文，点击发布后提示“发布失败，请重试。问题环节：本机处理”，按钮仍为“发布” | 本批诊断交付验收通过；原始具体根因未定位 |

原始文字、图片原件、输入法、显示缩放、键盘实际高度及故障操作顺序尚未完整取得。截图仅呈现部分输入，离线构造样例不能证明用户旧数据库故障。记录 `7e6ba20c-b704-4a52-aed6-2b81898b0cb3` 的默认 `stage=request`、`responseReceived=false` 与路由名不能证明动态创建是否发送请求，也不是动态提交堆栈；三个现象没有被合并成同一根因。

## 候选行为

A：键盘缩小页面不再隐藏标题和元信息子树。标题、状态与发布元信息共用有界滚动区域，短屏标题收为单行；正文、格式栏、取色及标签仍可操作。取色期间继续让出上部空间，不让隐藏输入框维持焦点。分类加载只限制发布资格，不阻止恢复草稿后的标题输入。已评审原页面超过 700 行的职责：本轮保留页面已有输入／生命周期协调，未机械迁移到 `part`，没有新增业务层耦合。

B：`WenyouRouterDelegate` 在应用 Router 边界接管系统 `popRoute`。未初始化时消费返回；正常 Navigator、Shell、弹层、PopScope 和根路由 `onExit` 保留原优先级。等待退出期间配置变化则结束旧返回；连续返回合并为同一在途操作。没有升级 go_router、修改第三方源码、捕获通用 StateError 或绕过草稿退出保护。诊断路由为空时清空旧名称。

C：动态创建／普通编辑每次明确提交创建独立诊断尝试，同一编辑会话 UUID 关联多次尝试。阶段覆盖 `encode → localSave → requestReady → request → response → decode → localCleanup → complete`；失败后的本地补偿为 `confirmationSave`。`requestReady` 仅表示将调用仓储，不能证明网络已经发出；`request/response` 由真实网络拦截器记录。清理重试只标记 `localCleanup` 与 `resultConfirmed=true`，不伪造本次收到网络响应。失败保留实际阶段、捕获栈、响应与请求元信息，补偿失败另留类型／脱敏源码坐标，同一次失败只产生一个问题编号。错误区显示该编号并可复制详情，沿用现有导出、持久化、自动发送和清除／切号边界。关闭发送后只在本机保留。

诊断不记录标题、正文、图片或本机路径、账号、凭据、请求／响应载荷及签名 URL。原保存队列、原子待确认快照、owner 与稳定 `clientRequestId` 保持；提交前失败不发送，未知结果不后台重发，已确认成功但清理失败在原页面只重试本地清理。补偿失败不覆盖首个失败证据。不迁移、不清理用户数据。

动态创作页同样超过 700 行，已评审本次职责：页面只增加现有错误区域的编号和复制动作；阶段、失败关联及幂等协调保留在控制器，未把诊断编排加入页面，也没有为行数机械搬移代码。

## 验证记录

- 精确回归：`test/features/editor/thread_compose_title_keyboard_test.dart` 在旧实现的 360×720／DPR 1／键盘 360dp 场景失败，标题不可见；候选覆盖 320×568、360×720、1／1.5／2 倍字、亮／暗、高键盘开关、标题→标签→正文→标题、恢复草稿与分类慢加载。
- 路由：`test/app/wenyou_router_delegate_test.dart` 同一测试确认上游原 delegate 在空配置抛 `StateError`，应用边界通过；覆盖 Shell、正常多层、弹层、PopScope、异步配置清空／重定向和连续返回。不是原手机操作序列的复现。
- 存储与诊断：`test/features/moments/moment_persistence_test.dart` 注入首次落盘、旧待确认冲突、响应后清理、补偿保存故障；确认草稿／原载荷／幂等 ID、发送开关、同编号、脱敏与去重。仅注入故障，不声称复现用户数据库根因。
- 真正 Dio／固定生成客户端离线链路：`test/features/moments/moment_submit_diagnostics_test.dart` 使用内存 HTTP adapter，验证 201 解析失败与 503 响应，收到响应不误记为未响应，明确重试保持幂等 ID。没有访问线上写接口。
- 直接影响检查另含 `test/app/app_router_test.dart`、`test/features/editor/thread_compose_page_test.dart`、`test/features/editor/thread_compose_text_color_test.dart`、`test/features/moments/`、`test/core/diagnostics/`。
- Windows 完整门禁 `npm run check:apk -- -TestConcurrency 2` 已退出 0：格式、应用与生成客户端全量分析零问题；契约校验／再生成一致性、公网只读兼容、架构、模块文档及 API 覆盖通过；Flutter **8,107 项通过、1 项跳过**（真实 Sentry 收件须显式开启），Windows 工具 **49 项通过**；同次门禁成功构建 ARM64 Debug APK。构建有既有 `flutter_image_compress_common`／`photo_manager` 的 Kotlin 迁移提示，未影响当前构建，本轮不升级依赖。

完整门禁前两次停止记录：第一次为 23 个模块文档缺少已同步的新来源 SHA，已补齐第 13 节；第二次在全量测试发现 `test/core/network/audio_budget_contract_test.dart` 硬编码旧来源，已同步为相同新 SHA。它们均属来源同步遗漏，未修改应用源码或放宽检查；随后重新从统一入口执行。

截图为离线 Widget 渲染，位于 `test/features/editor/goldens/compose-title-keyboard-*`，不含真实键盘或用户图片，不能替代 HONOR 真机视觉验收。ADB 初查无设备，未启动／接管 Debug、未安装、未清数据。构建默认 API 为公网 `https://wenyou.site/api/v1`；由负责人自行启动，代理未触发启动自动签到或业务写入，也未执行任何线上发布／上传／云草稿保存 E2E。

标准 `check:apk` Debug 构建未显式开启 `WENYOU_ENABLE_ERROR_REPORTING`，本机诊断可导出，不能声称本候选已向真实 Sentry 收件。发送开关和同编号发送已用离线发送器验证，手机实际收件仍待明确构建配置与负责人验证。

## 制品与源码绑定

- 独立候选：`D:\dev-cache\candidates\20261027-compose-reliability\wenyou-compose-reliability-ddfc3876-debug.apk`，114,345,005 bytes；来自本 Worktree 同次门禁成功的 `build/app/outputs/flutter-apk/app-debug.apk`。
- APK SHA-256：`ddfc3876b87ce0670ecb4e33e0ff8a0c926fe6badae9f9c4e1f90d07fea239c4`。
- `aapt dump badging` 核验：`site.wenyou.app.debug`、`0.11.0-debug`／versionCode `101`、标签“温油站 Debug”、minSdk `26`、targetSdk `36`、仅 `arm64-v8a`。`apksigner verify --verbose` 退出 0，v2 签名有效。
- 构建前后 Git 可见应用源码清单（`lib`、`android`、`pubspec.yaml/lock`、`packages/wenyou_api`、`packages/flutter_quill`，2,400 文件）SHA-256 同为 `5473cf146f28d1cd7712f7e844d7292f939839f4efe28778b524807511465681`；清单保留于 `D:\dev-cache\tmp\compose-candidate-source-final.txt`。门禁日志为 `D:\dev-cache\tmp\compose-check-apk.log`，前两次停止日志另存，未覆盖失败证据。
- 构建后 ADB 仍无设备，未安装、未启动、未取得设备内 APK 哈希；不能把本地包校验写成手机已更新。
- 候选应用源码提交：`a7586612595c63969dc18a32153a669181cd00af`；`lib` Git tree 为 `6fe09215831788daa8957cab24cf2aae54d18d86`，`android` 为 `948213a0815ae4c46530b60cb3ff4c3799605213`。独立来源同步提交为 `de054d60`。提交后工作区干净，任务分支已推送。
- 中文 Draft PR：[Mobile #126](https://github.com/morenk/wenyousite-mobile/pull/126)，目标 `dev`。本次后续只补交付证据，不修改应用源码、不重复相同源码门禁；无负责人验收，不标记可合并。任务 Worktree／分支／候选文件保留，未合并、发布、部署或归档。

## 负责人复验清单

1. 在 HONOR 原场景记录输入法、显示缩放、字号、键盘高度与时间；正文有文字和图片时点击标题，确认键盘打开后可继续输入。标题、标签、正文来回切换，再收起／打开键盘并恢复草稿；分类等待时标题仍可编辑。补查暗／亮及短屏大字。
2. 确认工具栏展开、弹层、返回确认与草稿保存按原顺序关闭；快速连续返回和前后台恢复不产生新的空路由错误，不丢编辑内容。
3. 负责人可在 Debug 手动重建相同标题、正文和图片；若失败，复制新问题编号，按阶段、请求编号及响应证据定位。它与原正式包旧数据的对应关系仍需核实；直接验证原旧数据需负责人安排保留该数据的后续候选。未具备对应证据时继续排查，不关闭原动态问题。
4. Debug 候选包为 `site.wenyou.app.debug`，与用户正式包数据独立。Debug 新草稿成功不能证明正式包旧数据问题解决；本任务不卸载、不覆盖清理正式包。需要正式数据验证时由负责人安排后续候选。

缺少负责人对 A／B／C 的明确结果，均不记“修复完成”或“可合并”。暂不合并、发布、部署或清理本任务现场。

## 2026-10-29 负责人验收及集成

负责人在治理 chat `01a178f1-8818-7da2-b289-5f3fd2ee356f` 明确回复“验收通过，合并到dev然后清理分支”。本轮据此记录 PR #126 的标题输入、系统返回和动态诊断候选验收通过，授权合入 `dev` 并在核验后清理该任务分支和临时 Worktree。用户未补充本次验收机型、包摘要及逐步操作记录，本记录不补造这些细节。原始动态具体异常仍未取得，诊断交付通过不等同于旧数据根因已定位。

验收对应已交付实现 `a7586612595c63969dc18a32153a669181cd00af`／交付记录 `ddd537cfdbb4076a4c1c32c4f6c03cf0398133bb`，独立 APK 及摘要见上文。上文“待验收、未合并”等描述是 2026-10-27 候选时点的历史状态，以本节后续记录为准。

最新 `origin/dev` 为 `7f0c6417b4d140167ae64b3ec5a32d2f5b701759`，已含主动更新检查和空回复提示。合入任务分支时冲突仅为 CHANGELOG 与 23 个模块的同一 Backend 来源说明，保留双方行为、记录与链接；本任务已验收的应用代码无冲突修改。集成提交为 `5298f3d54109ef7580688f7278dd82e2520e1ea2`。

最终集成源码完整执行 `npm run check:apk -- -TestConcurrency 2`，退出 0；Flutter **8,134 项通过、1 项条件收件测试跳过**，Windows 工具 **49 项全部通过**，静态分析、契约、文档、架构及 API 覆盖均通过，同次构建 ARM64 Debug APK 成功。插件 Kotlin 迁移和 Android SDK XML 版本提示未影响本次构建。集成 diff 自查无新增问题；没有线上写入 E2E，未安装、启动、发布或部署应用。

- 验证源码：`lib` tree `d04adcb9e90b5048a141fb21ee715bcfd88b4940`，`android` tree `948213a0815ae4c46530b60cb3ff4c3799605213`；构建前后源码清单一致，清单 SHA-256 为 `f7b5c24c17f0000fe58a47a0a56370d7728618b15439916a1140bf51edab5f9f`。后续只补本文档，不重复应用门禁。
- 集成 APK：`D:\dev-cache\candidates\20261029-compose-reliability-integration\wenyou-compose-integration-0133ba7f-debug.apk`，114,345,005 bytes，SHA-256 `0133ba7f13b91c6b1e5d8fe28ed8001953f01b57873f37cfded31b22bb587c8d`。原已验收候选 APK 仍独立保留。
- 完整日志、源码清单、制品摘要和合并清理审计保留在 `D:\dev-cache\candidates\20261029-compose-reliability-integration`，位于待清理 Worktree 外。完整日志 SHA-256 为 `9e58266808a6586bb01a76faca31be83bc1d37306f22f181522d9cbf149fd27e`。
- 按负责人授权合并 PR #126 后，核验远端 `dev` 保留完整任务提交、任务分支没有新增提交、工作区干净且无使用中的进程，再清理本任务本地／远端分支和临时 Worktree；实际结果记录在外部 `merge-cleanup-record.json`，不归档 chat。

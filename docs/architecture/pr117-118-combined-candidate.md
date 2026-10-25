# PR #117 与 #118 组合测试候选

状态：原组合APK／待负责人真机验收。后续圆圈视觉反馈已由负责人明确授权修改后合并，见下节；不发布。原同包检查／APK证据仍固定到3d95ca49，不代替原手机场景验收。

## 相册圆圈视觉反馈

2026-10-25 用户对比新截图中本应用的大实心白圆与QQ半透明小圆，要求缩小并半透明，修改后直接合并分支，明确“跳过冗余测试”。本轮复用原Worktree／分支，只调整 `PhotoSelectionMark` 的视觉圆径28→24dp（直径减14.3%）；未选使用现有panel色alpha0.24、已选使用primary色alpha0.82，边框／序号主题色不变，外层minimumTouchTarget继续48dp，语义及交互不改。

检查范围遵从本次用户指令：相关格式、变更文件静态分析、现有 `test/features/media/photo_selection_page_test.dart` 的8项页面用例；首次更新明／暗／320dp两倍字Golden并自看，整合最新dev后正常验证同8项。两次分别用于更新快照和验证整合结果，不重跑562／7798项或完整门禁，不构建APK，不启动真实App。Foundation只读fetch tags确认最新正式仍v7.6.0、与依赖一致；不引入新依赖。审批配置事实沿用下节说明，未设置／核验Auto-review。

本轮开始时HEAD为1dd08c97；fetch发现origin/dev已到 `e32870272a611a94a0a22e90bf5dce280c671150`（PR #116），其增量无lib／原生／依赖／生成SDK运行代码变化。先提交本样式，再普通merge该dev提交到任务分支，保持最新 Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`／API `5.44.0-dev.20261024.3` 来源；下文33574ae7／.2是原合包历史。执行子任务只提交推送，最终PR与合入dev由治理任务执行，不改写分支历史。

本轮日志在 `build/photo-mark-visual-evidence/`：相关格式1文件零修改（format.log），变更文件analyze零问题（analyze.log）；首次 `--update-goldens` 的8项全部通过（7秒，golden-update.log）。实际更新 `test/features/media/goldens/photo-picker-{light,dark,narrow-large}.png` 三张，已逐张查看：底图颜色／明暗分界可穿过未选圆圈，选中序号清楚，320dp两倍字无溢出；相册下拉的三张Golden字节未变。预览确认、返回取消及权限恢复复用既有行为断言，不添加镜像实现测试。整合后8项正常验证结果另补。

无新真机画面；原 `app-debug-64e0a53c3ad3.apk` 不包含本轮24dp／半透明样式，不能作为新样式产物。

## 固定来源与范围

- 治理 chat：`01a16e35-9e1e-7841-afb6-e7e3bbb3217d`；唯一执行子 agent：`investigate_replies_resume`。
- Windows Worktree：`D:\codex-worktrees\mobile-117-118-test-20261025\wenyousite-mobile`；分支 `codex/20261025-mobile-117-118-test`，从本轮已更新的 `origin/dev=8ab9f1bdb031290d89d6e093177b0ecb6a680fa4` 建立。
- PR #117 固定 `be89da38c14f71d202a5ac59225f5858c9708a38`；PR #118 固定 `746e6bdd4360f356cebee1cef14e423b1737910b`。先快进到 #117，再仅在本测试分支合入 #118，保留两条提交父链。原 PR、原 Worktree 及 dev 不修改，不创建第三个功能 PR。
- 组合应用／测试提交：`3d95ca4902c6816e47e3d411025abb524ab51857`，两个直接父提交恰为上述 #117／#118 SHA。APK构建后提交同一冻结应用树；随后仅补此源码身份文档，不改变应用、测试或APK。只推送本独立测试分支供追溯，不自动创建PR。
- 应用源码相对 #117 仅新增 #118 的 `post_repository.dart` 四能力 record/select；测试夹具与组合用例、本文及模块链接可增加。无额外生产改动；依赖、原生、生成客户端、上传／HTTP 协议均沿用 #117。
- 契约来源以 #117 已提交记录为准：Backend `33574ae73d88123aa216a93f9cc81eab60fb9ee9`／API `5.44.0-dev.20261024.2`。其与 #118 原固定 `31f39ff3` 机器契约零差异；不引入之后的新字体协议。来源复核见[原记录](compose-gallery-contract-source-sync.md)。
- Auto-review 默认偏好已传递，实际未设置／核验。当前宿主 `approval_policy=never`、unrestricted，工具无支持的审批配置入口；不能称为 Auto-review 已生效。

## 保留的问题事实

#117 首轮 fd3a19181808 已被负责人明确验收失败：主题图片和头像入口无反应且无权限申请。第二轮已证实首次 Android inset 改变包装层会销毁宿主／路由树；固定候选稳定 GlobalKey 与宿主绑定，仍待原手机复验。旧失败与反证不被本次自动通过覆盖，见[相册候选](compose-gallery-candidate.md)。

#118 原操作为楼中楼读到第14条，切应用后重新加载回顶；已证实同值新元信息重建整个能力对象，经帖子仓库连带重建讨论控制器、清空窗口／锚点。最小候选只观察实际使用的四布尔能力；每次恢复仍查更新，真实能力变化及切号／可见性失效仍刷新。原手机系统、后台时长与进程回收未有日志，不声称已真机复现。见[保位候选](post-replies-resume-candidate.md)。

## 新组合回归与验证选择

`test/features/media/photo_selection_replies_resume_test.dart` 使用同一个真实 WenyouApp／appRouter／StartupController／productionProviderOverrides／能力映射／生成客户端／帖子仓库容器，只替换网络、原生权限、通知和内存存储 IO，不覆盖 postRepository。先加载40条回复、读到 reply-14 中段，真实路由压入资料页并点击头像控件打开图库；图库打开中收到首次 Android inset=0，再 paused/resumed 收到同值新 ContractInfo。断言同图库 State、账号／session scope、更新检查次数增加与原生权限重查、宿主仍绑定；取消并返回后断言同仓库／controller／窗口、同可见 ID 与1px内条目偏移、无 loading／额外帖子请求、无上传和HTTP写请求。原生权限明确模拟 denied，不访问真实图库。

新增夹具选项默认仍保留原 ReadyStartup 行为，仅本组合用例启用真实启动链；复用 #118 的假传输与阅读书签辅助，不创建平行实现。两份独立候选的417／175项只作历史，本次在组合源码重跑实际路径的去重并集，另明确包含安全区／回复栏回归；media目录包含新组合用例。

开发夹具失败单独保留：首次编译引用不存在的 SessionScope.userId；修正为 accountId 后，完整 App 的 AppLifecycleListener 报 paused→resumed 直跳不合法。新用例改为平台合法的 inactive→hidden→paused→hidden→inactive→resumed，未删异常检查或改生产实现，随后单用例7秒通过。两次夹具失败分别在证据目录 `combined-regression.log`、`combined-regression-lifecycle-fixture-failure.log`，通过记录 `combined-regression-pass.log`；它们不计为产品旧实现反证，原两 PR 已有的有效旧失败记录继续保留。

风险按已批准的中风险组合候选处理：相对 #117 不新增依赖／原生／上传协议，增量只收紧 feature provider 依赖。使用 `candidate:apk` 的全仓格式、应用与生成包全量静态分析、下列28路径及同次ARM64 Debug构建；另补架构和模块文档检查。完整全量门禁留待负责人验收后、合入 dev 前，不把历史7798／49项称为本次组合通过。

```text
test/features/media
test/core/widgets/wenyou_instant_keyboard_insets_test.dart
test/app_shell_test.dart
test/app/app_session_bootstrap_test.dart
test/features/posts/post_composer_opening_test.dart
test/features/posts/post_composer_insertion_test.dart
test/features/editor/thread_compose_page_test.dart
test/features/moments/moment_comment_attachment_lifecycle_test.dart
test/features/direct_messages/direct_conversation_page_test.dart
test/features/stickers/sticker_collection_page_test.dart
test/features/users/avatar_controller_test.dart
test/features/users/profile_cover_controller_test.dart
test/features/threads/thread_identity_editor_lifecycle_test.dart
test/features/threads/thread_identity_profile_editor_test.dart
test/features/posts/post_replies_resume_test.dart
test/features/posts/post_replies_page_test.dart
test/features/posts/post_controllers_test.dart
test/features/posts/post_repository_test.dart
test/features/posts/discussion_window_controller_test.dart
test/features/posts/discussion_number_page_test.dart
test/features/posts/post_replies_target_geometry_test.dart
test/features/posts/post_reply_visibility_stack_test.dart
test/features/posts/post_identity_composer_lifecycle_test.dart
test/features/posts/post_thread_context_ports_test.dart
test/core/network/session_controller_test.dart
test/app/production_overrides_test.dart
test/app/visibility_cache_invalidation_test.dart
test/features/posts/compose_safe_area_reply_bar_test.dart
```

## 独立产物与运行记录

本轮 `npm run candidate:apk -- <上述28路径> -TestConcurrency 2` 已通过全仓1548个Dart文件格式零修改、应用全量analyze零问题（281.6秒）及生成包全量analyze零问题；组合源码上 **562项Flutter测试全部通过**（4分1秒，0失败）。新增跨项用例另先单独通过。架构检查通过，23模块文档检查通过；没有重新执行历史7798项全量／49项工具门禁。

主日志：Worktree 下 `build/combined-117-118-evidence/candidate-apk.log`，SHA-256 `3ba15647aa885cdd38bd64d5ee065f509ede54bef12e696fc70bae0ca568eb6b`；精确命令路径为同目录 `test-paths.txt`，架构／文档日志为 `architecture-check.log`、`docs-check.log`。本轮应用源码清单 SHA-256：`69bf7da7a6a3c51caa24d9306c4e4ec8435a6bf2b3d80757f575fcd563225574`；lib tree：`140bd9dc984548bf86c752786463b72bb070e5e4`。清单定义沿用 #117：`git ls-files -s -- lib android ios assets packages contracts tool pubspec.yaml pubspec.lock package.json package-lock.json` 的 UTF-8、LF输出并保留末尾换行，原件 `application-source-manifest.txt`。构建后 `application-source-manifest-after.txt` 完全同摘要，应用源码无 unstaged 差异；不含文档、测试或构建产物，测试归属由本整合提交追溯。

同次 ARM64 Debug 构建成功，Gradle328.9秒，入口退出码0。保留既有插件KGP与SDK XML警告，未改依赖／SDK／门禁。原始 `build/app/outputs/flutter-apk/app-debug.apk` 与独立稳定副本 `build/candidates/pr117-118/app-debug-64e0a53c3ad3.apk` 均为114292149字节，SHA-256均为 `64e0a53c3ad33fcb09ee0b698014767474edc38bba61ff17a11e382cbe289ae4`。原两份 APK 不作为本轮合包产物，新包未安装、启动或上传。

`aapt` 核验“温油站 Debug”、`site.wenyou.app.debug`、`0.10.0-debug`／100、minSdk26／targetSdk36；aapt及ZIP原生目录均仅arm64-v8a。`apksigner verify` 通过，v2=true、1个签名者，证书SHA-256仍为 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`，与两份原候选相同。最终清单含READ_MEDIA_IMAGES、READ_MEDIA_VISUAL_USER_SELECTED、READ_EXTERNAL_STORAGE上限32和既有WRITE_EXTERNAL_STORAGE上限28，无视频／定位权限；其他权限保持原候选。完整身份／权限／签名证据为同证据目录的 `apk-identity.json`、`apk-badging.log`、`apk-permissions.log`、`apk-signature.log`。

CHANGELOG整合标记曾因LF／CRLF替换不匹配残留在暂存区，提交前已按行精确清除，保留两侧完整条目；全仓宽搜索仅有字体许可证的4条合法等号下划线，精确标记搜索为空，staged／unstaged `git diff --check` 通过。日志 `conflict-marker-scan.log`／`exact-conflict-marker-scan.log`；最终23模块文档检查再次通过。这是文档整合检查修正，不影响已冻结应用清单或APK。

默认 API 仍为 `https://wenyou.site/api/v1`，属于真实环境。代理仅执行离线 fake IO，不安装／启动真实 App，不接管设备，不上传 APK或执行业务写入 E2E；启动自动签到交由负责人自行运行。本轮无真实手机画面或权限回调证据。

## 同包手测清单

1. 按新 APK SHA-256 确认“温油站 Debug”已替换正确包；包名／相同 versionCode 不足以区分不同候选。进入主题正文编辑并完全展开、展开字体列表，检查状态栏、短屏、键盘和选区；楼中楼共享回复底栏与末条可见。
2. 按[相册18入口矩阵](compose-gallery-candidate.md#全部业务选图入口的离线覆盖矩阵)逐项点击，确认只在打开图库时申请图片权限；覆盖允许、拒绝、部分授权、设置恢复／撤销、系统备用、取消重开、跨相册顺序／上限、GIF 与原裁剪用途。首次键盘／inset在图库打开前与打开中都测试。
3. 楼中楼读到第14条中段→切其他应用→返回，确认可见回复、段落内位置与窗口不闪回首屏；复验倒序、作者筛选、更多分页、深链／数字跳转后继续阅读及“回到刚才”。
4. 读到14条后打开头像或正文图库→切应用→返回→取消图库，确认选择页／账号正确、取消无上传、返回仍在原段。切换账号／退出／会话失效应关闭旧图库并刷新讨论，不保留旧账号窗口；同账号Token轮换保留当前内容。
5. 断网或慢 meta 检查时仍可读；必要更新／强制升级保留。内容删除／权限变化按既有刷新规则处理。系统杀进程后的重开不属于本次进程内保位承诺；不新增持久化阅读进度。原设备、真实权限、厂商inset、实际图片／GIF／裁剪和后端更新策略均待负责人验收。

# 编辑器安全区、楼中楼回复栏与应用内相册候选

本文保留 PR #117 独立分支／APK 的来源和失败历史；用户授权的 #117＋#118 同包验收另见[组合候选记录](pr117-118-combined-candidate.md)，不改写下述独立候选事实。

状态：第二轮候选／待负责人验收。首轮 fd3a19181808 已明确验收失败；新 a87f51a93c5e 包完成自动候选验证，尚未获得负责人原场景通过，不关闭原问题。

2026-10-25 负责人原始反馈：“上传图片的入口点了都没有反应呢，不管是主题帖上传图片还是上传头像，没有反应，点了也没有跳出权限申请”。确认应用为本次“温油站 Debug”候选，非旧包；保留该 APK、此前完整门禁和截图证据，沿用本任务、分支和 PR #117 排查真实应用装配链。该反馈不被记作权限拒绝或用户取消。

## 第二轮装配入口排查

已证实的装配原因：Android MainActivity 在初始化／窗口同步时发送 keyboardInsetTargetChanged（含0）。原 WenyouInstantKeyboardInsets 首次收到目标值会新增 MediaQuery 层，原 PhotoSelectionHost 位于其内，旧宿主晚 dispose 会无条件把共享 coordinator.presenter 清空，导致后续端口返回 null，权限页根本没有 init。首轮宿主测试使用简化 MaterialApp 并直接调用 coordinator，遗漏这条真实应用生命周期。

旧实现真实入口证据：D:/dev-cache/tmp/mobile-gallery-entry-old-exact.log，配套测试原件 mobile-gallery-entry-old-exact-test.dart。使用 WenyouApp、真实 appRouter 与完整 productionProviderOverrides，仅替换 IO；主题图片与头像按钮先各打开一次后取消，再模拟原生首次 inset=0，二次真实点击均失败：期望（图库数1，累计权限请求2，presenter已绑定true），实际（0，1，false）。两项均失败，符合负责人无反应／无权限请求的现象。无真实 App 启动、图库读取或上传。

最小方案仅修改 lib/app/wenyou_app.dart、lib/app/photo_selection_host.dart、lib/features/media/application/photo_library_ports.dart：宿主移到键盘包装层外；App State 内稳定 GlobalKey 搬移包装内路由子树，保留打开中的图库／编辑会话；解绑只释放自身 presenter；未绑定／Navigator未就绪走既有失败处理，不伪装取消。只外移宿主的中间版本在“图库打开中收到首次inset”回归中仍会丢页，已保留失败日志并据此增加稳定Key。没有修改全局键盘组件、原生、权限、依赖、上传／裁剪协议或楼中楼恢复逻辑。

治理侧已审查实际生产改动范围，批准按中风险装配生命周期修复使用 candidate:apk 定向回归＋全量静态分析，另补架构／文档检查；不复用首轮APK，不将既有30分钟完整测试当作新源码检查通过。所有图片入口的矩阵、最终运行结果与新APK见以下第二轮记录。

最终夹具反证：仅临时替换上述三个文件为 cf03a48a 原字节来源，4项真实 App 测试全部失败（首次inset在图库关闭后／打开中，分别覆盖主题图片和头像）；旧宿主晚解绑测试也失败，实际 presenter=null。随后逐文件按保存字节恢复，并核对SHA-256一致。日志为 D:/dev-cache/tmp/mobile-gallery-final-fixture-old-entry.log（SHA-256 aeea5c8cd1fb3e0c572b2b945221d5a4be5a29ed2b6feaba78ac2510a4091457）与 mobile-gallery-final-fixture-old-binding.log（2f5af18c4edb69b8fa4ffb470854ac78a5b77e2423f6fdf74bc20179dba916e2）。首次反证启动曾被 Windows bat 的正则管道参数解析中断，未计作测试失败证据；以上为随后真实运行的5项失败。

候选对应38项定向测试通过，日志 D:/dev-cache/tmp/mobile-gallery-all-entries-pass.log；包含下表18入口、4项真实App生命周期、4项宿主与12项控制器测试。首次inset在图库已打开时到达、后续280/0开关均保持页面；取消后两次重开验证不遗留busy。权限调用只在图库打开时发生，参数仅图片且mediaLocation=false；所有取消均断言没有上传调用或HTTP写请求。绑定交错、Navigator未就绪、换号迟到文件结果、权限撤销等原测试保留。开发中夹具的账号来源、必填字段、磁盘IO与私聊轮询清理问题已收敛，未关异常断言、未关业务轮询。

## 全部业务选图入口的离线覆盖矩阵

矩阵搜索了 lib 下所有 pickFromGallery／pickManyFromGallery／pickAvatarFromGallery／pickProfileCoverFromGallery、pickEditorImages、pickAndCropEditorImages 与 pickAndUpload 调用点。三种生产选择端口、coordinator、PhotoSelectionHost、DevicePhotoLibrary、WenyouApp 与真实 appRouter 均未替换；仅模拟原生权限IO、网络、通知和本地存储，避免读取真实图库或磁盘草稿。表中“路由”13项从真实业务路由和实际控件打开；“共享表单”5项在同一真实App宿主下直接挂载产品表单，再点击真实图片控件，未覆盖其上游菜单导航／授权，不能将其外推为全链路真机验收。

| 入口 | 实际路由／操作 | 层级 | 自动结果 |
| --- | --- | --- | --- |
| 主题新建正文 | /compose/thread → 图片 | 路由 | 通过 |
| 主题已有正文编辑 | /threads/thread-1 → 更多 → 编辑正文 → 图片 | 路由 | 通过 |
| 新发楼层 | 主题详情 → thread-floor-compose → 图片 | 路由 | 通过 |
| 新发楼中楼回复 | 楼中楼详情 → post-reply-compose → 图片 | 路由 | 通过 |
| 动态新建 | /compose/moment → 添加图片 | 路由 | 通过 |
| 动态编辑 | /moments/moment-1/edit → 添加图片 | 路由 | 通过 |
| 动态评论 | 动态详情 → 评论底栏 → 图片 | 路由 | 通过 |
| 私聊 | /messages/conversation-1 → 图片 | 路由 | 通过 |
| 收藏表情相册上传 | /me/stickers → stickers-add-gallery | 路由 | 通过 |
| 添加本人头像 | /me/edit → 添加头像 | 路由 | 通过 |
| 已有头像二级更换 | /me/edit → 头像 → 更换 | 路由 | 通过 |
| 添加主页背景 | /me/edit → 添加主页背景 | 路由 | 通过 |
| 已有背景二级更换 | /me/edit → 背景 → 更换 | 路由 | 通过 |
| 帖内身份新建头像 | showThreadIdentityEditor(identityId=null) → 选择帖内头像 | 共享表单 | 通过 |
| 帖内身份编辑头像 | showThreadIdentityEditor(identityId=role) → 选择帖内头像 | 共享表单 | 通过 |
| 正文新建／子贴正文新建模式 | PostComposerKind.upsertBody(postId=null) → 图片 | 共享表单 | 通过 |
| 楼层正文编辑 | PostComposerKind.editPost(root) → 图片 | 共享表单 | 通过 |
| 回复正文编辑 | PostComposerKind.editPost(reply-own) → 图片 | 共享表单 | 通过 |

矩阵执行文件为 test/features/media/photo_selection_all_entries_test.dart；App首次inset与打开中生命周期为 photo_selection_app_entry_test.dart，夹具为 photo_selection_app_fixture.dart。四种 PostComposerKind 均有图片控件覆盖；上游身份菜单授权、编辑／引用目标、裁剪、用途、数量上限继续关联既有 thread_identity_picker／editor_lifecycle／profile_editor、post_composer_opening／insertion、media 与 avatar／profile_cover 回归。本轮实际执行文件以新候选命令清单为准，不将未重复的文件算作本轮通过。

未发现绕过三端口的其他业务 image_picker 调用；SystemEditorImagePicker 仅供明确选择系统备用与 lost-data 恢复。通用 MediaUploadTask.pickAndUpload 当前没有业务页面调用点。阅读态保存／收藏已有网络图片、表情URL导入和剪贴板恢复不打开本地图库，不在本轮改动中冒充新选图入口。图库全部实际授权／原手机场景仍由负责人真机复验。

## 第二轮候选验证与 APK

2026-10-25，按治理侧批准的中风险装配修复路径执行 `npm run candidate:apk -- <以下14个路径> -TestConcurrency 2`，日志 D:/dev-cache/tmp/mobile-gallery-retry-candidate-apk-final.log，退出码0。全仓1545个Dart文件格式零修改，应用与生成客户端全量静态分析零问题，417项相关Flutter测试全部通过（已包含上述38项），随后同次入口ARM64 Debug构建成功（Gradle69.2秒）。另补18入口用途／上限断言并在相同应用源码上复跑矩阵通过，日志 mobile-gallery-entry-purpose-caps.log；这是同一18行矩阵，不重复计为独立入口或唯一用例数。

- test/features/media
- test/core/widgets/wenyou_instant_keyboard_insets_test.dart
- test/app_shell_test.dart
- test/app/app_session_bootstrap_test.dart
- test/features/posts/post_composer_opening_test.dart
- test/features/posts/post_composer_insertion_test.dart
- test/features/editor/thread_compose_page_test.dart
- test/features/moments/moment_comment_attachment_lifecycle_test.dart
- test/features/direct_messages/direct_conversation_page_test.dart
- test/features/stickers/sticker_collection_page_test.dart
- test/features/users/avatar_controller_test.dart
- test/features/users/profile_cover_controller_test.dart
- test/features/threads/thread_identity_editor_lifecycle_test.dart
- test/features/threads/thread_identity_profile_editor_test.dart

架构检查通过，日志 D:/dev-cache/tmp/mobile-gallery-entry-architecture.log；最终模块文档复查23项通过（mobile-gallery-retry-docs-final.log）。新增用途／上限断言后，该文件格式零修改、单文件静态分析零问题（mobile-gallery-retry-final-format.log、mobile-gallery-entry-purpose-analyze.log）。候选入口第一次在新增测试的5处导入／排序lint失败，未进入构建（mobile-gallery-retry-candidate-apk.log）；已修正，未放宽门禁。先行窄范围分析的相同5项也只作为失败记录保留。本轮未重跑完整7798项或Windows工具49项，不能把首轮历史结果称为新源码的完整门禁。

新应用源码清单SHA-256：`d46f1fa10fe898aab85f8f8de096308bbaf170388fa6bb12f777bab00da0a4f2`，lib tree：`3716e1db41c85238e44274f0bca256e956d701f1`。清单定义与首轮相同，原件 mobile-gallery-retry-source-manifest.txt；构建后再次计算完全一致，运行源码无未暂存差异。治理侧还独立比较了APK kernel：新包含 `_keyboardContentKey` 和未绑定宿主错误，旧fd3包均无，确认新修复实际编入。

新稳定副本：`D:/codex-worktrees/d5c9/wenyousite-mobile/build/candidates/compose-gallery/app-debug-a87f51a93c5e.apk`，114283017字节；SHA-256 `a87f51a93c5e5664417563dbfa7110731226bffe4a42701f5da7ac42d32b28ea`。aapt确认“温油站 Debug”、`site.wenyou.app.debug`、`0.10.0-debug`／100、minSdk26、targetSdk36；aapt与ZIP原生目录均只有arm64-v8a。apksigner验证通过，v2=true，证书SHA-256仍为 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`。最终权限无视频或定位。

新元数据独立保存于 D:/dev-cache/tmp/mobile-gallery-retry-apk-identity.json，badging／permissions／signature证据同前缀另存。fd3稳定副本再次核对仍为原SHA-256，未覆盖旧失败证据。新包未由代理安装或启动，未读取真实图库、未做业务写入E2E；默认API仍为 https://wenyou.site/api/v1。负责人应安装a87新包再验全部入口，不能仅凭相同构建号判断更新。

首轮14张组件截图的图片选择页与编辑器呈现代码未在本轮改变；它们仍只说明离线布局，不替代新入口的实际运行或负责人真机验收。本轮新增证据为真实装配点击、生命周期和参数断言，不冒称原机画面已验证。

## 范围与原始场景

用户报告：主题帖编辑器完全展开（含字体列表）进入状态栏；楼中楼详情回复按钮与子贴输入栏不一致；各厂商系统选图不一致，希望默认最近图片、下拉切相册。用户选择应用内统一选择器，允许按需申请读取照片，拒绝后保留系统入口。

原始操作为进入主题帖正文编辑、完全展开、展开字体列表；预期标题、关闭和列表避开状态栏。原手机 inset 与该异常的实际屏幕尚未取得，因此离线回归使用真实 ThreadDetailPage → 编辑正文 → upsertBody → 嵌套编辑宿主，覆盖大 top inset、短屏和键盘；不会把合成 inset 等同原设备复现。参考图片仅提供相册交互方向，无业务指令。

已证实代码事实：共享弹层原 useSafeArea=false 会移除后代顶部 padding；字体弹层虽然 useSafeArea=true，也无法恢复该继承值。旧回复入口为悬浮 WenyouComposerAction。候选仅在主题／帖子编辑入口统一提供顶部安全区内的约束；展开、拖动和工具栏维持既有比例，键盘只作为最终可见高度上限避让一次；楼中楼直接使用 WenyouReplyActionBar／WenyouReplyFieldAction，阅读 body 已由 Scaffold 缩短，取消额外底栏扣减和悬浮按钮尾部占位。

不修改字体契约、下载缓存、Markdown、Backend／Web／Foundation 源码或上传协议；不新增视频、拍照或原图模式。

## 来源与工作区

- Windows Worktree：`D:\codex-worktrees\d5c9\wenyousite-mobile`，宿主生成时为 detached HEAD，无临时分支；本任务保留目录。
- 分支：`codex/20261024-mobile-compose-gallery`，编辑前 fetch，起点 `8ab9f1bdb031290d89d6e093177b0ecb6a680fa4`，不接管其他字体任务。
- 治理 chat：`01a16e35-9e1e-7841-afb6-e7e3bbb3217d`。已显式读取治理 AGENTS、task-dispatch、live-development-preview 及本 Worktree AGENTS。
- Foundation 只读镜像执行 fetch origin --tags，最新正式 Tag `v7.6.0`，与 pubspec 固定一致；已读 CHANGELOG 和相关图片／平台契约，不改依赖版本。
- 起点固定 Backend `31f39ff317e56d6eb49b4c5e60ecdb93dfc9ec06`／API `5.44.0-dev.20261024.2`。开始读取镜像 origin/dev 的 OpenAPI／CHANGELOG，并读公网 meta：API 版本一致，运行 buildSha `33574ae73d88123aa216a93f9cc81eab60fb9ee9`。完整门禁的精确来源检查发现旧登记与已部署 SHA 不同，经只读验证两提交是直接父子且机器契约零差异，独立 chore 17d62e2f 已同步33574ae7及导出运维说明，46708399 同步原来源的精确测试断言；见[来源同步](compose-gallery-contract-source-sync.md)。本轮不改变 HTTP 契约。
- 审批默认偏好已传递，实际 Auto-review 配置尚未设置／核验。当前宿主指令实际为 `approval_policy=never`、文件权限 unrestricted；工具无支持的当前 chat 审批设置入口，未核验 `resolvedApprovalsReviewer=auto_review`，不能把 never 等同 Auto-review。

## 相册实现与边界

`photo_manager` 精确锁定 3.12.0。应用层 PhotoSelectionCoordinator 注入展示能力，应用路由上方 PhotoSelectionHost 持有稳定宿主；数据层不持页面 BuildContext。生产三类端口全部绑定 UnifiedImagePicker，保留 EditorImagePicker／MultiEditorImagePicker／RecoveryAwareEditorImagePicker、AvatarImagePicker、ProfileCoverImagePicker 和 MediaUploadInput。

默认最近图片、创建时间倒序四列，顶部相册下拉显示封面、名称与可访问数量；点图片预览，点标记按顺序编号。跨相册保留选择；支持预览已选，空选禁用确定；调用方保留单选、剩余张数与原裁剪规则。窄屏大字底部按钮允许换行。图库按 80 张分页，网格按需解码缩略图；预览读取按原比例请求的较大缩略图，不批量读原件。确认后才串行取得文件，不提前上传或重编码。

Android 8–12 声明 READ_EXTERNAL_STORAGE maxSdk32；13 使用 READ_MEDIA_IMAGES；14+ 声明 READ_MEDIA_VISUAL_USER_SELECTED。Android 8–9 保留既有保存图片使用的存储权限组；不申请视频、音频或定位。部分授权有“选择更多照片”；拒绝或永久拒绝保留系统选择及设置。返回前台刷新权限和可访问列表；文件删除、权限撤销、图库加载／分页失败均可恢复。iOS 权限说明与部分授权可兼容，未做 iOS 编译／真机验证。

Android 文件通过不要求原始位置元数据的 getFile(isOrigin:false) 读取；photo_manager 3.12.0 的 AndroidQDBUtils／ScopedCache 普通路径是内容流复制，避免 API29 setRequireOriginal。GIF 字节不重编码；Apple 使用原件。现有 10MB、格式、取景和上传归一化规则保持。预览缩略图按方向校正后的比例请求，iOS 使用 fit，展示 contain。

返回／取消不上传；未确认应用内选择仅存内存，重启不恢复提交。系统备用入口才沿用上下文与 retrieveLostData，恢复后仍由用户确认。防重复打开；切号关闭图库并丢弃迟到文件结果。相册名称、ID、文件路径、文件名和图像不进入诊断日志。

入口覆盖：主题／帖子正文、动态发布与编辑、动态评论、私聊、收藏表情、本人头像、帖内身份头像、主页背景；均保持原用途与裁剪策略。

依赖与权限依据：[photo_manager 官方说明](https://pub.dev/packages/photo_manager)、[Android 部分照片授权](https://developer.android.com/about/versions/14/changes/partial-photo-video-access)。

## 验证与离线画面

旧实现对照：临时加载基线 8ab9f1bd 的四个安全区／回复布局文件，运行同一真实入口回归，4 项均失败；大 inset 编辑器 top=48 <280，短屏 top=34.08 <96，嵌套字体列表 top=224 <280，旧回复页不存在共享底栏。随后按原字节恢复候选，候选四项通过。仅替换这四个文件，不改其他任务或历史。精确最终源码身份和 APK 见后节。新增测试路径：

- `test/features/posts/compose_safe_area_reply_bar_test.dart`：主题详情正文真实入口、完全展开、嵌套字体列表、280／96dp top inset、短屏、键盘开关、选区和内容保留；回复底栏、末条可见。
- `test/features/media/photo_selection_controller_test.dart`：顺序、上限、跨相册、分页、失败重试、权限刷新与撤销、删除、迟到分页、防重入与各用途。
- `test/features/media/photo_selection_page_test.dart`：预览、取消、确认、部分／拒绝／受限授权、设置和备用系统入口，明暗／窄屏两倍字号 Golden。
- `test/features/media/photo_selection_host_test.dart`：三类生产端口、路由刷新、切号时丢弃未完成文件结果。
- `test/features/media/device_photo_library_test.dart`：只请求图片、无位置请求、Android 文件策略、GIF 原字节、大小与删除、预览比例。
- `test/features/media/local_photo_thumbnail_test.dart`：损坏缩略图解码失败显示原地重试，重试成功恢复图像。

直接受影响的既有回归路径：`test/features/moments/moment_comment_attachment_lifecycle_test.dart`、`test/features/posts/post_composer_text_color_test.dart`、`test/features/posts/post_edited_time_widget_test.dart`、`test/features/posts/post_reading_quick_scroll_test.dart`、`test/features/posts/post_replies_page_test.dart`；另执行 `test/core/network/audio_budget_contract_test.dart` 与 `test/user_facing_copy_test.dart`。最终完整入口执行整个 `test/`，不以这些定向结果替代全量门禁。

Golden 位于 `test/features/media/goldens/photo-{picker,albums}-{light,dark,narrow-large}.png`；使用确定性的有色横竖合成测试图，明暗背景用于检查标记对比；预缓存图片解码后截图，不读取用户图库。离线画面只作组件验证。

## 负责人真机复验清单

1. 打开候选 Debug 应用 `site.wenyou.app.debug`，在原主题正文编辑中完全展开、拖动、打开字体列表；状态栏／刘海下标题与列表可见。打开／关闭键盘，收起后重开，确认内容、草稿、选区可继续使用。
2. 对照主题详情子贴入口与楼中楼底栏；游客登录回跳、指定目标／引用／RP 身份、草稿、切号、定位中禁用、最后一条与定位目标均正常。
3. Android 8–12、13、14+ 分别核验完整、部分、拒绝、永久拒绝；部分授权添加照片、设置恢复与撤销后回前台刷新。系统备用取消／确认和 Activity 回收恢复不自动上传。
4. 各图片入口逐一确认单选／剩余上限、跨相册顺序、点击预览、选择标记、预览已选和零选择；取消无上传。用本人明确操作验证原头像／背景／正文／表情裁剪与动态／评论／私聊无裁剪，GIF 动画、格式及 10MB 限制保持。
5. 验证空图库、分页失败／恢复、选择后删除文件、权限中途撤销；明暗、窄屏、大字号和横竖图预览保持可用。
6. 冷启动后未先开键盘时直接点图片；再从正在输入的编辑器点图片、处理系统授权并返回，确认图库不丢失，取消后还能再次打开。五项共享表单还需从真实菜单进入复验：新建／编辑帖内身份头像、正文／子贴正文新建、楼层编辑和回复编辑。已有权限时可不再弹授权框，但仍应打开图库；拒绝时应显示系统备用和设置入口。

治理边界：AppSessionBootstrap 有自动签到，无法把真实环境启动认定只读。本轮不自动启动／接管设备 Debug，不读取真实图库、不执行线上上传写入 E2E；交付独立候选由负责人启动。本任务未授权合并、发布、部署或清理其他 Worktree。

## 额外离线画面与边界

编辑器与字体列表各三张 Golden：360×800 明色、top inset 280dp、1倍字；320×800 暗色、top inset 280dp、2倍字；320×568 明色、top inset 96dp、1倍字。文件为 test/features/posts/goldens/compose-{expanded,fonts}-{800-light,800-dark-narrow,568-light}.png。楼中楼底栏为 reply-bar-light.png（360×800，1倍字）和 reply-bar-dark-narrow.png（320×800，1.5倍字），末条在底栏上方可见。上述 top inset 是明确的压力测试输入，不代表真实设备状态栏尺寸；字体列表使用离线固定测试目录和测试字体子集，不下载真实字体，少数字形占位不能作为生产字体缺字结论。

补图时确认基线既有的全局 WenyouAnchoredActionBubble 在1.5倍字号显示两行标签时，72dp固定动作高度导致8px溢出；对应组件本轮没有改动。按本轮范围保留该独立限制，正常字号完成真实“编辑正文”入口后再对编辑器施加2倍字号；编辑器与字体列表的异常断言仍完整保留，未吞布局错误。此入口菜单的大字号限制不宣称已修复。

完整门禁历史：第一次在生成客户端归一化因 Windows errno1224 失败，原脚本安全重试成功；第二次生成客户端零diff，但因已部署Backend SHA不一致失败。二者均不计作通过，未改门禁脚本、未批量停止进程、未重置生成目录。来源对齐后使用同一 npm run check:apk -- -TestConcurrency 2 再跑完整入口。
## 首轮源码自审与身份（保留历史）

首轮 Codex 源码自审涵盖生产三类选图端口接入、data 无 BuildContext、账号结果边界、系统备用及 lost-data、取消不上传、GIF／文件名与延迟读取、错误恢复、Foundation图标与语义样式、生成客户端零漂移、敏感材料和无关修改；但遗漏真实 Android inset 对宿主／路由树生命周期的影响，不能覆盖后续负责人失败结果。较长的 PostRepliesPage 只替换底部入口并保持原导航／目标／草稿状态机，未扩大职责，不机械搬移其余逻辑。全局操作菜单保持原样。

首轮失败候选应用源码清单 SHA-256：77a373b93c2b74a110eb7d5f2f7c251a8b2264d97445659ff750a3b038520273；lib Git tree：7c102301239c2f393bb6a4cbb8b5ed4736acf1ed。清单定义为 git ls-files -s -- lib android ios assets packages contracts tool pubspec.yaml pubspec.lock package.json package-lock.json 的 UTF-8 输出，以 LF 逐行连接并保留末尾换行；不含文档、截图和构建产物。清单原件保存于 D:/dev-cache/tmp/mobile-gallery-application-source-manifest.txt；新候选另行计算，不复用此身份。

来源对齐后的第一次重跑因新增测试的一处单级联写法 lint 失败（应用代码无问题），已修正测试写法；这次失败同样不计作完整门禁通过。随后 D:/dev-cache/tmp/mobile-gallery-check-apk-final-2.log 的全量测试结果为7786通过、1跳过、12失败，未进入 Windows 工具测试和 APK 构建，不能算完整通过。12项分别为旧来源精确断言、动态评论横屏高度、9张受影响Golden和旧 ApiFailure 构造预算。

全量回归收敛：共享弹层改为可选 useSafeArea（默认false），仅 PostComposerLauncher 显式true，恢复动态评论原横屏键盘高度。MomentComment附件生命周期与真实编辑安全区共17项通过。编辑器保留原extent比例与单次键盘高度上限，不按键盘缩小后的面积再次缩放；正文颜色／编辑时间／阅读滑块相关19项及360dp独立讨论1项、受影响Golden已重新验证，原布局、滚动、选区与内容断言保留。照片读取的本地失败改用 PhotoLibraryFailure 类型；旧 ApiFailure 构造预算418与原门禁均未放宽，用户文案4项及架构／格式复查通过。

## 首轮完整门禁与失败候选 APK（保留历史证据）

2026-10-25，在上述应用源码清单上执行原入口 `npm run check:apk -- -TestConcurrency 2`，退出码0，完整日志 `D:/dev-cache/tmp/mobile-gallery-check-apk-delivery.log` 最后为 `Wenyou mobile quality gate passed.`。

- OpenAPI 校验、精确来源、API 再生成零差异、公网只读兼容检查通过；格式1542文件零修改，应用与生成客户端静态分析零问题，架构、23模块文档和175/175已纳入 Mobile API 覆盖检查通过。
- 全量 Flutter：7798通过、0失败、1项原条件跳过，运行29分44秒。跳过为 `test/core/diagnostics/diagnostic_live_receipt_test.dart` 的真实 Sentry 接收验收，未启用 `WENYOU_VALIDATE_SENTRY`，不发送真实事件。
- Windows 工具：49通过、0失败、0跳过；同一次入口随后完成 ARM64 Debug 构建（Gradle 471.6秒）。构建保留插件 KGP 和 SDK XML 版本警告，未更换 SDK、插件版本或放宽门禁。
- 生成后再次核对应用源码清单 SHA-256 仍为 `77a373b93c2b74a110eb7d5f2f7c251a8b2264d97445659ff750a3b038520273`，运行代码无未暂存差异。

首轮失败候选稳定副本：`D:/codex-worktrees/d5c9/wenyousite-mobile/build/candidates/compose-gallery/app-debug-fd3a19181808.apk`（原输出 `build/app/outputs/flutter-apk/app-debug.apk`）；114283017字节，SHA-256 `fd3a191818080b7e3ec1a1a1666cf6c932a64e38bdd683c92319a8d2177af80d`。该目录被 Git 忽略，APK 不提交源码仓库，不将其作为新候选。

`aapt dump badging`：名称“温油站 Debug”，applicationId `site.wenyou.app.debug`，versionName `0.10.0-debug`，versionCode `100`，minSdk26、targetSdk36；`aapt` 与 ZIP 原生库目录均确认只含 `arm64-v8a`。`apksigner verify --verbose --print-certs` 通过（v2=true，1个 Android Debug 签名者，证书SHA-256 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`）。最终清单包含图片和部分照片权限，没有视频或定位权限；保存图片原 WRITE_EXTERNAL_STORAGE maxSdk28 保持。

首轮产物、签名和权限证据分别保存于 `D:/dev-cache/tmp/mobile-gallery-apk-identity.json`、`mobile-gallery-apk-signature.txt`、`mobile-gallery-apk-permissions.txt` 与 `mobile-gallery-apk-badging.txt`。代理交付时未安装或启动、未核验设备内APK哈希；随后由负责人安装并明确验收失败，见顶部记录。设备安装记录不能用本机文件哈希代替。

本次构建未传入 `API_BASE_URL`，按 `AppEnvironment.fromDefines` 的默认值使用 `https://wenyou.site/api/v1`；未静默切换其他地址。该 App 的自动签到启动行为是本轮不自动启动、交由负责人手动运行的原因。

## 新反馈的独立待处理问题

治理侧在冻结候选后转述负责人新反馈：楼中楼切到后台再回前台会重载并丢失滚动位置。该问题已独立交付[草稿PR #118](https://github.com/morenk/wenyousite-mobile/pull/118)（应用bc3c6efe，HEAD746e6bdd，175项候选检查通过，仍待负责人验收）。本分支不包含该修复；两份Debug APK来自各自分支，应分别用于相册与后台恢复验收，不能用其中一包代表另一改动已验证。两包applicationId相同，安装会替换当前Debug包；本轮不进行合并或自动安装。

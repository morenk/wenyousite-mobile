# 编辑器安全区、楼中楼回复栏与应用内相册候选

状态：自动候选验证通过，待负责人原场景真机验收。自动检查和离线截图不代表验收通过。

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

治理边界：AppSessionBootstrap 有自动签到，无法把真实环境启动认定只读。本轮不自动启动／接管设备 Debug，不读取真实图库、不执行线上上传写入 E2E；交付独立候选由负责人启动。本任务未授权合并、发布、部署或清理其他 Worktree。

## 额外离线画面与边界

编辑器与字体列表各三张 Golden：360×800 明色、top inset 280dp、1倍字；320×800 暗色、top inset 280dp、2倍字；320×568 明色、top inset 96dp、1倍字。文件为 test/features/posts/goldens/compose-{expanded,fonts}-{800-light,800-dark-narrow,568-light}.png。楼中楼底栏为 reply-bar-light.png（360×800，1倍字）和 reply-bar-dark-narrow.png（320×800，1.5倍字），末条在底栏上方可见。上述 top inset 是明确的压力测试输入，不代表真实设备状态栏尺寸；字体列表使用离线固定测试目录和测试字体子集，不下载真实字体，少数字形占位不能作为生产字体缺字结论。

补图时确认基线既有的全局 WenyouAnchoredActionBubble 在1.5倍字号显示两行标签时，72dp固定动作高度导致8px溢出；对应组件本轮没有改动。按本轮范围保留该独立限制，正常字号完成真实“编辑正文”入口后再对编辑器施加2倍字号；编辑器与字体列表的异常断言仍完整保留，未吞布局错误。此入口菜单的大字号限制不宣称已修复。

完整门禁历史：第一次在生成客户端归一化因 Windows errno1224 失败，原脚本安全重试成功；第二次生成客户端零diff，但因已部署Backend SHA不一致失败。二者均不计作通过，未改门禁脚本、未批量停止进程、未重置生成目录。来源对齐后使用同一 npm run check:apk -- -TestConcurrency 2 再跑完整入口。
## 源码自审与身份

本任务已完成 Codex 源码自审：生产三类选图端口统一接入、data 无 BuildContext、应用宿主与账号结果边界、拒绝权限系统备用及 lost-data、取消不上传、GIF／文件名与延迟读取、错误恢复、Foundation图标与语义样式、生成客户端零漂移、无敏感材料与无关修改。较长的 PostRepliesPage 本次只替换底部入口并保持原导航／目标／草稿状态机，未扩大职责，不机械搬移其余逻辑。全局操作菜单保持原样。

候选应用源码清单 SHA-256：77a373b93c2b74a110eb7d5f2f7c251a8b2264d97445659ff750a3b038520273；lib Git tree：7c102301239c2f393bb6a4cbb8b5ed4736acf1ed。清单定义为 git ls-files -s -- lib android ios assets packages contracts tool pubspec.yaml pubspec.lock package.json package-lock.json 的 UTF-8 输出，以 LF 逐行连接并保留末尾换行；不含文档、截图和构建产物。清单原件保存于 D:/dev-cache/tmp/mobile-gallery-application-source-manifest.txt。生成／来源已核对，最终 APK 后再次复核清单不变。

来源对齐后的第一次重跑因新增测试的一处单级联写法 lint 失败（应用代码无问题），已修正测试写法；这次失败同样不计作完整门禁通过。随后 D:/dev-cache/tmp/mobile-gallery-check-apk-final-2.log 的全量测试结果为7786通过、1跳过、12失败，未进入 Windows 工具测试和 APK 构建，不能算完整通过。12项分别为旧来源精确断言、动态评论横屏高度、9张受影响Golden和旧 ApiFailure 构造预算。

全量回归收敛：共享弹层改为可选 useSafeArea（默认false），仅 PostComposerLauncher 显式true，恢复动态评论原横屏键盘高度。MomentComment附件生命周期与真实编辑安全区共17项通过。编辑器保留原extent比例与单次键盘高度上限，不按键盘缩小后的面积再次缩放；正文颜色／编辑时间／阅读滑块相关19项及360dp独立讨论1项、受影响Golden已重新验证，原布局、滚动、选区与内容断言保留。照片读取的本地失败改用 PhotoLibraryFailure 类型；旧 ApiFailure 构造预算418与原门禁均未放宽，用户文案4项及架构／格式复查通过。

## 最终完整门禁与候选 APK

2026-10-25，在上述应用源码清单上执行原入口 `npm run check:apk -- -TestConcurrency 2`，退出码0，完整日志 `D:/dev-cache/tmp/mobile-gallery-check-apk-delivery.log` 最后为 `Wenyou mobile quality gate passed.`。

- OpenAPI 校验、精确来源、API 再生成零差异、公网只读兼容检查通过；格式1542文件零修改，应用与生成客户端静态分析零问题，架构、23模块文档和175/175已纳入 Mobile API 覆盖检查通过。
- 全量 Flutter：7798通过、0失败、1项原条件跳过，运行29分44秒。跳过为 `test/core/diagnostics/diagnostic_live_receipt_test.dart` 的真实 Sentry 接收验收，未启用 `WENYOU_VALIDATE_SENTRY`，不发送真实事件。
- Windows 工具：49通过、0失败、0跳过；同一次入口随后完成 ARM64 Debug 构建（Gradle 471.6秒）。构建保留插件 KGP 和 SDK XML 版本警告，未更换 SDK、插件版本或放宽门禁。
- 生成后再次核对应用源码清单 SHA-256 仍为 `77a373b93c2b74a110eb7d5f2f7c251a8b2264d97445659ff750a3b038520273`，运行代码无未暂存差异。

候选稳定副本：`D:/codex-worktrees/d5c9/wenyousite-mobile/build/candidates/compose-gallery/app-debug-fd3a19181808.apk`（原输出 `build/app/outputs/flutter-apk/app-debug.apk`）；114283017字节，SHA-256 `fd3a191818080b7e3ec1a1a1666cf6c932a64e38bdd683c92319a8d2177af80d`。该目录被 Git 忽略，APK 不提交源码仓库。

`aapt dump badging`：名称“温油站 Debug”，applicationId `site.wenyou.app.debug`，versionName `0.10.0-debug`，versionCode `100`，minSdk26、targetSdk36；`aapt` 与 ZIP 原生库目录均确认只含 `arm64-v8a`。`apksigner verify --verbose --print-certs` 通过（v2=true，1个 Android Debug 签名者，证书SHA-256 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`）。最终清单包含图片和部分照片权限，没有视频或定位权限；保存图片原 WRITE_EXTERNAL_STORAGE maxSdk28 保持。

产物、签名和权限证据分别保存于 `D:/dev-cache/tmp/mobile-gallery-apk-identity.json`、`mobile-gallery-apk-signature.txt`、`mobile-gallery-apk-permissions.txt` 与 `mobile-gallery-apk-badging.txt`。未安装 APK、未启动应用、未核验设备内 APK 哈希，负责人应打开本候选的“温油站 Debug”复验；安装记录不能用本机文件哈希代替。

本次构建未传入 `API_BASE_URL`，按 `AppEnvironment.fromDefines` 的默认值使用 `https://wenyou.site/api/v1`；未静默切换其他地址。该 App 的自动签到启动行为是本轮不自动启动、交由负责人手动运行的原因。

## 新反馈的独立待处理问题

治理侧在冻结候选后转述负责人新反馈：楼中楼切到后台再回前台会重载并丢失滚动位置，已另开只读排查。本候选不包含该修复，不扩大当前修改或声称该场景已通过；本轮的底栏／安全区／相册验收与此问题分别记录。

# 正文音频候选验收

状态：Mobile 离线功能与视觉候选，待负责人真机及跨端验收，未合并。治理已确认兼容 Backend PR51 部署至 1aa8655f；Mobile 不以安装成功认定完整链路验收通过。以下构建与检查按批次保留，不混用旧 APK 和新源码。

## 来源与范围

Windows Worktree：`D:\codex-worktrees\mobile-audio-upload\wenyousite-mobile`，分支 `codex/20261016-audio-upload`。从更新后的 origin/dev `17631a2c` 创建，保留楼层编辑时间上游变更；依赖 [PR #98](https://github.com/morenk/wenyousite-mobile/pull/98)，其未合并前本 PR 不标可合并。按顺序 cherry-pick -x：7a429804→859df35b、2f2180af→f9b8bfd5、707a40e3→9124dc6b、038ae0e6→9eabe65d、7997bfba→4ce2e2b7、b2b8ce58→74bdc7d1。旧工具栏 Worktree 未混入音频源码。

契约固定 Backend cb44acaeb7fbc735fb569276aef00435bf24efe5／API 5.37.0-dev.20261016.1，见[来源](audio-contract-source.md)。正式 Foundation v7.3.0 锁定 a582d6ec498e26f30739d8bf6995f9613e26eb4d，独立升级提交 a7b85f59。file_selector 1.1.0（BSD-3-Clause）、just_audio 0.10.6、audio_session 0.2.4（MIT）；Android minSdk 26／iOS 13 不抬升，没有麦克风／后台播放服务权限。

## 行为与边界

- 仅文件上传。Android SAF 后台 64 KiB 缓冲复制、30 MiB 实际预算、异步取消并清自有缓存；兼容端 file_selector。选择器接受同格式 MIME alias，最终仍限制 MP3/M4A/WAV/OGG/FLAC、最多十分钟；内容验证与唯一 MP3 副本由后端负责。
- 私有草稿保存文件、阶段和 mediaId，显式继续才续传；系统选择期间后台切换保留选择，离开编辑目标／账号取消。处理终态失败提供重新选择，已完成结果可在新上传关闭时恢复。未完成本机标记禁止发表／云草稿写入。
- 新上传以原文件名为标签；编辑态与阅读态共享播放器，不新增正文预览入口。顶层独占无 title 链接命中可信 mediaAudios 才升级；外链、行内、列表／引用、代码、同 URL 两个独立链接保持普通语义。标签 marks 保留，内部 link identity、音频视图及编码来源不写入 Markdown。
- 点击才请求，全局单活动；暂停／恢复进度，离页／后台／音频中断 stop 终止加载缓冲。不预加载、自动恢复、录音或后台播放。有效历史投影播放独立于上传开关。
- 音频默认展开，有能力可拖入常用栏；主题／回复一套 App 本机偏好，网页单独设置。关闭能力隐藏但保留排序。
- 沿用图片公开 URL 资产语义，已知 URL 不随帖子权限撤销，不宣称私有流式鉴权。

## 实际定向检查

按用户明确要求未执行全量测试、全量 analyze、npm check/check:apk/candidate:apk；未写公网数据，未执行 Mobile 写入 E2E。

- `.buildlog/audio-related-final.log`：15 文件首次 89 通过／2 失败；修正新增 audio 的旧期待，收窄同 URL 独立 link 边界并让普通单样式链接沿用原编码。原组合回归断言没有放宽。
- `.buildlog/audio-canonical-final.log`：受影响 4 文件 36 项全部通过，覆盖原失败及 1,024 种组合。其余已通过项未机械重跑，最终这 15 文件共 91 项均有通过证据。
- `.buildlog/audio-foundation-upgrade-test.log`：主题／品牌 11 项通过。`.buildlog/audio-copy-check.log`：纯 JVM 流复制 6 项通过（精确预算、超限、空文件、复制前／中取消、提供者异常）。首次 Kotlin 编译缺 reflect，修正本地类路径后通过。
- `.buildlog/audio-analyze-final.log`：所有改动／新增非生成 Dart 文件定向分析 No issues found；最后 codec 两文件 `.buildlog/audio-canonical-analyze.log` 同样通过。格式限定改动文件。四份契约按既有同步器的重复参数去重规则与固定 Git 来源比对通过：`.buildlog/audio-contract-final.json`；直接原字节比较失败的原因即该既有规范化，不更改协议。
- 前期 fixture 路径／字段、SemanticsHandle 清理及测试字体缺字均已修复补验，原失败日志保留。测试字体只用于 Golden，不向产品增加字体资源。

实际 Flutter 路径：

```text
test/core/markdown/markdown_audio_projection_test.dart
test/core/markdown/markdown_inline_combination_test.dart
test/features/editor/editor_pending_audio_document_test.dart
test/features/editor/editor_pending_audios_test.dart
test/features/editor/editor_pending_images_test.dart
test/features/media/audio_meta_test.dart
test/features/media/audio_upload_repository_test.dart
test/features/media/audio_playback_test.dart
test/features/media/system_audio_file_picker_test.dart
test/features/media/pending_media_file_store_test.dart
test/features/threads/thread_compose_models_test.dart
test/core/widgets/wenyou_audio_player_test.dart
test/features/settings/editor_audio_toolbar_test.dart
test/features/settings/editor_toolbar_preview_parity_test.dart
test/core/application/editor_toolbar_layout_test.dart
```

## 离线画面

正文和工具栏覆盖 320／360 dp 亮／暗，真实容量、固定按钮、表情包、能力隐藏与拖动归属有 Widget 对照。画面经交叉审阅无可见溢出，仍待负责人真机验收。

- `test/core/widgets/goldens/audio_body_320_light.png`、`audio_body_320_dark.png`、`audio_body_360_light.png`、`audio_body_360_dark.png`
- `test/features/settings/goldens/editor_audio_320_light.png`、`editor_audio_320_dark.png`、`editor_audio_360_light.png`、`editor_audio_360_dark.png`

新增正文样式反馈已收敛为淡边界、圆形 accent 播放按钮和对齐的细轨道／等宽时长；直接 Widget 6 项复验含轨道上下 20dp 的真实点击及拖动 seek，四张正文 Golden 更新，二倍字号不溢出。`.buildlog/audio-refined-ui-final.log`、`audio-refined-ui-analyze-fixed.log` 记录补验（首次一条 import 排序 info 已修正）；未改播放逻辑。

## 原生构建与待验收

### 编辑态／保存／原名／拖动批次（当前候选）

- `test/features/editor/editor_audio_projection_test.dart`、`editor_audio_widget_test.dart`、`editor_pending_audio_document_test.dart`、`editor_pending_audios_test.dart`，`test/core/widgets/audio_save_button_test.dart`、`audio_player_interaction_test.dart`、`wenyou_audio_player_test.dart`，`test/features/media/audio_download_test.dart` 共 **82 项通过**；最终比较日志 `.buildlog/audio-wysiwyg-save-final.log`。包含真实 Quill 选块删除／撤销重做、前后输入、剪切移动、跨会话失信降级、上传删除／撤销后不复活、滚动后的命中、滑块拖出边界及保存按钮不改选区、不提前请求媒体。
- 新文件名含方括号、括号、星号、反引号与尖括号，按 literal 来源安全往返；旧默认占位可从本机附件补名，自定义名称与 marks 保留。全粗标签仅在可信音频视图的编码路径保持外层 link；普通链接的既有规范断言不放宽。早期测试使用默认 encodeHtml 导致标签比较成实体、单一 marks 被分成多个 Text 节点的断言均已按真实语义修正。
- 真正的密集 pointer move 在 buffering 更新后仍可拖动，Slider.value 每次随手指变化，静态标题／播放按钮 Widget 实例不变，移动期间 seek 为零、松手一次提交。两倍字体轨道不足时将时间移下，标题整体仍可见，播放／保存／轨道 48dp 命中保持。
- `test/features/posts/post_audio_submission_test.dart` 用实际 PostComposerSheet、隔离内存仓储与 mock 音频完成结果覆盖空正文完成立即发送、音频加文字、恢复文档与空／未完成拒绝。用例通过恢复待处理媒体身份后显式 retry 走 `_run`，代码核对新选文件也走同一完成回调；这不是系统选择器或真实上传链路。与 `test/core/markdown/markdown_delta_semantic_safety_test.dart`、`test/features/editor/editor_inline_combination_cross_test.dart` 的最终独立组 **21 项全过**，日志 `.buildlog/audio-submit-codec-final.log`。临时只移除最终同步行的对照 `.buildlog/audio-post-without-sync.log` 为 **3 过 1 失败**：恢复场景没有请求；同步后通过。正常单音频在对照仍通过，不能据此唯一解释负责人原 postCreate／encode／validation 报错，原场景继续待真机复验。没有线上写入测试。
- 改动 Dart 30 文件分析先修正所有 info；`.buildlog/audio-wysiwyg-save-analyze-final.log` 仅余三个测试文件导入顺序，最终 `.buildlog/audio-wysiwyg-save-analyze-imports.log` 对该三文件 **No issues found**。其余 27 文件无问题；格式仅覆盖改动文件。没有全量测试、全量分析或门禁。
- Android 保存复用 `BoundedAudioCopy`；`.buildlog/audio-save-copy-check.log` 为 JVM 6 项通过（成功、预算、空、取消、提供者异常），原生通道编译由冻结源码后的一次 Debug 构建验证。iOS UIDocumentPicker 仅静态审查，Windows 无 Xcode 编译；没有新增插件或权限。系统提供者不支持删除时尝试截断并记录安全诊断，真实系统保存／取消待负责人手测。
- 最终图片 `test/features/editor/goldens/audio_editor_{320|360}_{light|dark}{_200}.png`、`audio_editor_selected_360_light.png`；阅读／三状态在 `test/core/widgets/goldens/audio_body_*`、`audio_states_*`。全部含右侧保存图标，明暗窄屏、200% 与选中边框经交叉查看，仍为候选。
- 当前没有可控热重载会话；旧 exec32990 已 Lost connection。未安装、未启动、未重启用户手机。WYSIWYG 本身为 Dart 代码，重进编辑目标会初始化控制器；此次新增原生保存需要新 APK，不能用旧包热重载冒充原生保存可用。

本批源码冻结后单次执行 `flutter build apk --debug --target-platform android-arm64 --dart-define=API_BASE_URL=https://wenyou.site/api/v1`，exit 0，Gradle assembleDebug 420.1 秒。日志 `.buildlog/audio-wysiwyg-save-debug-build.log`；没有调用全量门禁或额外重复构建。新增 Android 保存通道已通过本次原生编译，既有图片插件 KGP 与 SDK XML 警告保留，不误记为新功能失败。

- APK 对应源码 `4008ddbb9297ba0c1ba927d0abd82011877bd4a3`，Git tree `96ef8e133d679efc20acd9a868d1cb8bc1c6a35e`。后续仅补本文档，不能把文档提交当作重新构建的源码版本。
- 产物 `D:\codex-worktrees\mobile-audio-upload\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，154,807,167 字节；SHA-256 `643e213d386b95ed63ffb136c8b4ce49a3244eda337bd2718f6b090480ea8423`。本路径覆盖此前旧 APK，下文旧摘要仅作历史记录。
- aapt 和 APK 条目共同核验仅 `arm64-v8a`；包名 `site.wenyou.app.debug`，温油站 Debug，`0.9.0-debug (99)`，minSdk 26／targetSdk 36。无麦克风权限；原有权限未因音频保存扩张。新包体积增大不代表多 ABI，旧包已覆盖，未对旧包逐项体积归因。
- API 为 `https://wenyou.site/api/v1`，属于真实公网数据。仅构建和只读产物检查，按本轮要求没有安装、启动、热重启、热重载或操作设备；真实保存与本次编辑交互仍待负责人验收。
- 机器可读摘要 `.buildlog/audio-wysiwyg-save-artifact.json`，包元数据 `.buildlog/audio-wysiwyg-save-badging.log`。PR #102 保持 Draft；源码提交含 `[skip ci]`，推送后的 Actions run 列表为空。

### 后续播放器交互批次

本批只修改播放器组件与测试，未改变 API、存储、Markdown、插件或 Foundation 版本。固定渐变、180ms 背景／边界、120ms 图标与内部 96% 按压、4→6dp 实心进度圆点均沿用既有主题；48dp 命中保持。拖动期间和本轮 seek 确认前锁定本地目标，连续 seek 串行、三秒兜底释放，取消／失败／失焦／切换目标清理；等宽时间预留固定宽度。减少动态关闭缩放、过渡及 Slider ticker，离屏仅停视觉而不停止音乐。

- `test/core/widgets/audio_player_interaction_test.dart` 与 `test/core/widgets/wenyou_audio_player_test.dart` 共 21 项通过；`.buildlog/audio-interaction-final-update.log` 和 `audio-interaction-final-compare.log` 分别记录 Golden 更新与最终比较。覆盖真实按压完成值 0.96、48dp 命中、实际键盘／读屏 adjust、媒体事件／旧 seek 完成、取消／失败／超时／切换、暂停／结束、减少动态、离屏／后台与加载状态。
- 三个改动 Dart 文件定向分析：`.buildlog/audio-interaction-analyze-clean.log` 为 No issues found；前次 `audio-interaction-final-analyze.log` 的两条测试 API 弃用 info 已改用 `TickerMode.valuesOf(...).enabled` 消除。不运行全量测试、全量分析或门禁。
- 早期两项测试失败分别为取到多个 ScaleTransition、取到 Slider 外层语义容器；限定内部动画与实际可调语义节点后补验。读屏 Slider 回调未为测试额外扩张；语义句柄清理亦已修正。最初使用管道正则参数的 Windows Flutter 命令未执行测试，改为单项名称后继续。原日志保留，不把失败命令记为通过。
- `test/core/widgets/goldens/audio_states_{320|360}_{light|dark}.png` 为同段正文 idle／playing／dragging 三状态对照，另有 `_200.png` 四张长标题二倍字号图。拖动在首帧后等待 180ms 再截取，实测半径 6 与正常 4；移除默认 thumb 阴影，保留品牌实心圆点。画面经交叉审阅，仍为离线候选，未获得负责人真机交互验收。
- 本批设备无在线连接，未启动、安装或热重载，也未重建 APK。下面 b9e857e9 的 APK 只包含此前静态样式，**不含本批播放器交互**，不能用该产物冒充最终源码。

### 此前集中原生构建

插件／原生变更已集中生成一次 ARM64 Debug APK，命令 `flutter build apk --debug --target-platform android-arm64 --dart-define=API_BASE_URL=https://wenyou.site/api/v1`，exit 0，454.8 秒；没有调用包含全量检查的候选脚本。日志 `.buildlog/audio-debug-build.log`，构建时源码干净。

- 应用源码 `b9e857e94676b68c1cbef628d28adbf0b6af63c0`，Git tree `e3222baafdcf920301237f4b6a65605744613742`；该产物早于上述交互批次。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，112,652,030 字节；SHA-256 `f173861b8dd0f88bd2588523b7fe3d308568763403824a2959a2af5c8e0a2818`。
- aapt 核验 `site.wenyou.app.debug`／温油站 Debug／0.9.0-debug (99)，仅 arm64-v8a，minSdk 26／targetSdk 36。无 RECORD_AUDIO；原有非音频前台服务权限保留，本轮没有新增音频后台播放服务。构建含已有图片插件 KGP 与 SDK XML 兼容提示，不影响本次成功。
- API 明确为 `https://wenyou.site/api/v1`，按公网数据保护。构建前及结束时 `adb devices -l` 均无在线设备，因此未安装、未启动、未热重载、未修改设备数据，也未停止或接管旧工具栏会话；不以旧 APK 或旧画面冒充本次音频候选。
- 产物明细 `.buildlog/audio-debug-artifact.json`；[Draft PR #102](https://github.com/morenk/wenyousite-mobile/pull/102) 依赖 #98。未触发 GitHub 自动 run。

不能把旧工具栏包的热重载当音频原生验证；不自动启动或热重启登录应用，避免自动签到。iOS 原生编译、真实文件提供者／音频焦点／Range 播放未在 Windows 验证。

后端兼容发布后由负责人手动验证五种文件、超限／取消、草稿重开显式继续、失败重新选择、链接编辑发表、点击播放／拖进度、后台／离页／耳机中断、双播放器互斥与旧链接兼容。线上自动化只读；写入 E2E 另用已核验隔离环境。

Auto-review 默认偏好已传递，宿主无设置入口实际 never，未宣称已配置。音频提交使用 [skip ci]；仓库无 Actions workflow，不恢复或修改共享 CI 设置。

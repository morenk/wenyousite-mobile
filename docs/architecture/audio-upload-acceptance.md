# 正文音频候选验收

状态：离线功能与视觉候选，待负责人真机及跨端验收。未合并、未部署；后端未开放 audioUpload 时新上传入口隐藏属于预期，不能据安装成功认定完整链路可用。

## 来源与范围

Windows Worktree：`D:\codex-worktrees\mobile-audio-upload\wenyousite-mobile`，分支 `codex/20261016-audio-upload`。从更新后的 origin/dev `17631a2c` 创建，保留楼层编辑时间上游变更；依赖 [PR #98](https://github.com/morenk/wenyousite-mobile/pull/98)，其未合并前本 PR 不标可合并。按顺序 cherry-pick -x：7a429804→859df35b、2f2180af→f9b8bfd5、707a40e3→9124dc6b、038ae0e6→9eabe65d、7997bfba→4ce2e2b7、b2b8ce58→74bdc7d1。旧工具栏 Worktree 未混入音频源码。

契约固定 Backend cb44acaeb7fbc735fb569276aef00435bf24efe5／API 5.37.0-dev.20261016.1，见[来源](audio-contract-source.md)。正式 Foundation v7.3.0 锁定 a582d6ec498e26f30739d8bf6995f9613e26eb4d，独立升级提交 a7b85f59。file_selector 1.1.0（BSD-3-Clause）、just_audio 0.10.6、audio_session 0.2.4（MIT）；Android minSdk 26／iOS 13 不抬升，没有麦克风／后台播放服务权限。

## 行为与边界

- 仅文件上传。Android SAF 后台 64 KiB 缓冲复制、30 MiB 实际预算、异步取消并清自有缓存；兼容端 file_selector。选择器接受同格式 MIME alias，最终仍限制 MP3/M4A/WAV/OGG/FLAC、最多十分钟；内容验证与唯一 MP3 副本由后端负责。
- 私有草稿保存文件、阶段和 mediaId，显式继续才续传；系统选择期间后台切换保留选择，离开编辑目标／账号取消。处理终态失败提供重新选择，已完成结果可在新上传关闭时恢复。未完成本机标记禁止发表／云草稿写入。
- 编辑态是普通可编辑链接，阅读态才是播放器，不新增正文预览入口。顶层独占无 title 链接命中可信 mediaAudios 才升级；外链、行内、列表／引用、代码、同 URL 两个独立链接保持普通语义。标签 marks 保留，内部 link identity 不写入 Markdown。
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

插件／原生变更已集中生成一次 ARM64 Debug APK，命令 `flutter build apk --debug --target-platform android-arm64 --dart-define=API_BASE_URL=https://wenyou.site/api/v1`，exit 0，454.8 秒；没有调用包含全量检查的候选脚本。日志 `.buildlog/audio-debug-build.log`，构建时源码干净。

- 应用源码 `b9e857e94676b68c1cbef628d28adbf0b6af63c0`，Git tree `e3222baafdcf920301237f4b6a65605744613742`；后续记录提交不改变应用源码。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，112,652,030 字节；SHA-256 `f173861b8dd0f88bd2588523b7fe3d308568763403824a2959a2af5c8e0a2818`。
- aapt 核验 `site.wenyou.app.debug`／温油站 Debug／0.9.0-debug (99)，仅 arm64-v8a，minSdk 26／targetSdk 36。无 RECORD_AUDIO；原有非音频前台服务权限保留，本轮没有新增音频后台播放服务。构建含已有图片插件 KGP 与 SDK XML 兼容提示，不影响本次成功。
- API 明确为 `https://wenyou.site/api/v1`，按公网数据保护。构建前及结束时 `adb devices -l` 均无在线设备，因此未安装、未启动、未热重载、未修改设备数据，也未停止或接管旧工具栏会话；不以旧 APK 或旧画面冒充本次音频候选。
- 产物明细 `.buildlog/audio-debug-artifact.json`；[Draft PR #102](https://github.com/morenk/wenyousite-mobile/pull/102) 依赖 #98。未触发 GitHub 自动 run。

不能把旧工具栏包的热重载当音频原生验证；不自动启动或热重启登录应用，避免自动签到。iOS 原生编译、真实文件提供者／音频焦点／Range 播放未在 Windows 验证。

后端兼容发布后由负责人手动验证五种文件、超限／取消、草稿重开显式继续、失败重新选择、链接编辑发表、点击播放／拖进度、后台／离页／耳机中断、双播放器互斥与旧链接兼容。线上自动化只读；写入 E2E 另用已核验隔离环境。

Auto-review 默认偏好已传递，宿主无设置入口实际 never，未宣称已配置。音频提交使用 [skip ci]；仓库无 Actions workflow，不恢复或修改共享 CI 设置。

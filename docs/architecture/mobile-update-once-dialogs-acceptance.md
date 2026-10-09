# 更新前与升级后一次说明弹窗候选验收

> 历史验收记录：专用隔离开发预览已于 2026-10-10 退役，下文保留当时证据，不作为当前启动指南。当前流程见 [Debug 开发](../live-debug.md)。

状态：重复空说明弹窗已于 2026-09-28 负责人验收通过，当前新源码相关门禁已通过，按负责人最新指令准备合并；原候选验收失败记录保留。此记录对应移除“查看更新”及历史模块后的新交互，不以原历史页验收、旧 APK 或旧热重载摘要代表本轮。

## 2026-09-28 真机重复弹窗反馈

负责人反馈当前安装包每次退出重新进入都会显示“当前安装版本”，并明确已经点击“知道了”（原询问误称“关闭”，按实际按钮更正）。预期为同一已安装 build 的完整说明只展示一次，实际为重进重复。原候选为 `site.wenyou.app` / `0.8.0+97`，设备安装核验 SHA-256 `b3ebe7b5d0a0bd7d7c64963e59967e83ab3485813479bc6583b7191b5e63f245`；此次退出方式与设备当前身份仍待补充，不能用旧安装记录代替本次现场核验。

治理已冻结正式合并、Tag、上传与晋级；通知和基础路径的既有通过结果保留，一次说明明确验收失败。负责人随后明确正文为“此版本暂无更新说明”，与只读公开详情 Android 97 返回 404 对应：旧实现在完整说明取得前就打开安装版弹窗，缺失／失败不消费待提示，点“知道了”只关闭路由，跨进程再次展示相同空壳。正文和代码路径已对应，退出方式和现场存储仍未独立采集，不据此声称已完成真机修复验收。

候选仅调整安装版说明的展示时机：先读取并校验完整说明，暂不可用时保留待提示且不打开空壳，下一安全前台重新请求；成功后重新确认安装身份，再以同一完整内容快照打开弹窗，避免重新请求退为空／错。仍由正文实际可见后记账，存储 schema、tracker、账号与退出清理、推荐和强制下载机制不变。不得把加载失败改记为已读、修改本机偏好或清数据掩盖。

## 重复弹窗候选检查（2026-09-28）

应用摘要 `97d738e4f52fbb630ebc9df03da80c0508fbcd9e79cc78e5c7af69dc72e4622f`。仅三个展示文件变化，未改存储、协议、原生、依赖或版本；按普通展示时机 Bug 执行候选检查，后续合并范围以负责人最终“只验收相关改动的门禁，然后合并”指令为准。旧源码 `2415d20c` 实际执行“暂无说明 → 知道了 → 销毁并重建 ProviderScope → 重开”，在第二次发现弹窗而失败；另有缺失、断网两个旧源码失败用例。原日志均保存，未改测试预期迎合实现。

`npm run candidate:apk -- test/features/app_shell -TestConcurrency 2` 退出 0，全仓格式、应用与生成 API 全量静态分析通过，指定目录 117 项通过，Debug ARM64 构建 80.0 秒；另执行 `flutter test --no-pub test/app_shell_test.dart --concurrency 2 --reporter expanded`，34 项通过。当前目录测试含精确原操作、冷启动／前后台、缺失／失败后的真正重新请求、内容恢复后一次记账、后台／模态／卸载／强制抢占、安装身份改变、不匹配说明、原下载和明暗／长文／大字号 Golden。文档 21 模块及架构检查通过，原 Golden 未修改。

证据独立保存于 `D:\code\wenyousite\artifacts\mobile-release-notes-20260927\formal-0.8.0-97\once-repeat-fix-v1`，不覆盖父目录原失败 APK。Debug 候选 `wenyou-0.8.0-debug-97-candidate.apk`，109,419,846 bytes，SHA-256 `96c6d3489d3a20865a609d505554cc61de9c310d3a6e8c12adc0d25384b4da7a`；这是候选门禁制品，尚未安装或启动隔离 Debug。正式签名候选将使用原 BuildOnly 入口并复用本次候选检查，不声称完成新源全量门禁；实际提交、签名与设备哈希另行登记。候选检查阶段 ADB 未连接；后续签名、覆盖安装与负责人通过结果见下一节。

## 重复弹窗候选签名与覆盖安装

新应用提交 `4362a1739411ca314ab0032279efd780206341ad`，上述源码摘要保持。当前签名候选位于独立 `once-repeat-fix-v1/wenyou-0.8.0-97.apk`，`site.wenyou.app` / `0.8.0` / 97，33,610,393 bytes；SHA-256 `401dae520edeadaa51fda47e7556bedb2604b007ecb1e023f5d64eae22643e87`，原证书 `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839`。原 BuildOnly 脚本复用本轮候选检查构建 217.9 秒并退出 0，完成 ARM64／字体／16KB 对齐与验签；签名材料、key.properties 和私有诊断配置前后哈希一致。此处尚未执行新源完整发布门禁，不能引用旧 f69 源码门禁代替。

治理独立预检仍绑定 Android / 0.8.0 / 97 / confirmedRevision 1，保存 `preflight-governance.json`；BuildOnly 原 manifest 的 `notesConfirmedRevision: null` 不改写。2026-09-28 03:14:20 设备 `4b9c39b5` 保数据覆盖安装成功，设备内 base.apk SHA-256 与新签名候选完全一致；原首次安装时间仍为 `2026-09-13 06:16:06`，未卸载、清数据或由代理打开公网应用。证据 `device-formal-installed.json`、`signed-source.json` 及日志位于该独立目录，父目录原问题 APK 保留。

负责人于 2026-09-28 明确答复“两种重进都不再弹，原问题验收通过”：正式“温油站”（`site.wenyou.app`，非 Debug）在返回桌面再进入、划掉后台再打开两条原路径均不再弹“此版本暂无更新说明”。结果绑定上述新签名候选和设备内同一哈希。完整说明恢复后的真正一次展示已有自动回归，正式文案尚未公开时不能声称该路径已经真机验证。负责人随后明确要求“只验收相关改动的门禁，然后合并”，因此通过本任务执行会话停止刚启动的完整 `check:apk`（退出 1，尚未到全量测试，不算完整通过）。本次合并依据为已完成的 151 项定向／集成测试、双静态／格式、文档／架构、受影响本地门禁工具回归和明确真机通过；不再等待全量或 GitHub CI。

## 初始实现范围与事实源

- 任务分支：`codex/20260927-update-once-dialogs`，基于 `origin/dev` `c1976815762545afb7d646868ba39a122f44e890`；本轮未合并、未发布。
- 版本仍为 `0.8.0-dev.2+97`，Foundation 固定正式 `v7.2.1`；已 fetch 正式 tags，无更新 Tag。
- 交互依据：[Foundation 文档提交 72d4785](https://github.com/morenk/wenyousite-foundation/blob/72d4785860d96ff0e2b336bc3f0f355ff908f77e/docs/mobile-releases.md)，仅文档变化，不依赖未发布的包。
- Backend 已部署契约来源 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`，OpenAPI `5.27.0-dev.20260927.1`。Backend 文档候选 `3624a5723f40358a6a637999004d0a50a63e615f` 未改 HTTP 或生成 SDK，本轮不重新生成。
- 已部署公开列表／详情、后台记录、历史数据、发布门禁和生成 SDK 保留；移动端仅停止历史浏览消费，`mobileReleasesList` 登记到本地 API 排除清单。

## 当前行为

推荐直接显示有效目标的完整人工摘要和所有纯文本条目，保留下载／安装与“暂不更新”；可遮罩或系统返回关闭。旧推荐忽略记录继续生效。同一平台/build 的完整内容实际可见后即保存一次记录，不依赖关闭动作，revision 修订不会重弹。

强制更新优先撤下普通弹窗，由启动门禁的不可关闭弹窗接管。返回、点外部、说明失败和任何一次记录均不能进入应用；APK 未就绪时保留原等待与重查机制。更新动作仍复核 `/meta` 与 APK 元数据，目标变化时刷新或退出过期提醒，不使用说明里的 URL。

升级后只读取实际安装的平台、版本名和 build：可信本机旧 build 上升显示“已更新”；无基线但 Android 有有效覆盖安装时间时只说“已安装当前版本”。系统时间来自既有 `package_info_plus` 的 PackageManager 字段，先与原生版本/build 精确匹配，无插件或原生配置变化。首次安装时间相同、缺失、非正数、逆序或身份不符时保守建立基线。

安装基线、待提示和前／后已展示记录分别保存。记录与账号无关，退出、切号、重建和同 build 重装不会清除。跨版只提示当前安装版，降级不补播旧版。首次迁移不能证明旧 build，也可能由同 build 覆盖触发一次；清数据可能保留系统安装时间，不能承诺跨清数据或卸载去重。

显示顺序为强制、升级后、推荐。安装版完整说明尚不可用时安静保留待提示，不弹出加载／空／错误壳，下一安全前台再读，也不阻挡有效推荐。升级后关闭后不会立即接弹，下一次安全前台先重新评估推荐；推荐与强制仍保留原说明“重试”及下载动作。排队、加载、错误、后台响应、强制遮挡与未完成入场动画均不消耗已展示记录。写入串行；失败保留进程收据并于后续观察补写，磁盘保存失败不冒称跨进程去重成功。

独立详情页、历史控制器、历史分页仓储、设置及游客入口已移除。旧 `/mobile-releases` 和 `/mobile-releases/:build` 只安全返回 `/me`。iOS 沿用 TestFlight 提示／忽略和动作，不增加 Android 说明或升级后功能。

## 自动检查与组件证据

实际执行路径：

- `test/features/app_shell/mobile_update_notice_tracker_test.dart`：安装基线、迁移原因、跨版／降级、前后独立去重、旧忽略、读写失败与串行竞争。
- `test/features/app_shell/mobile_update_notice_store_test.dart`：SharedPreferences 往返／损坏记录、原生与插件身份核验及安装时间边界。
- `test/features/app_shell/mobile_release_repository_test.dart`、`mobile_release_controller_test.dart`：公开请求策略、准确版本、404／错误、iOS 拒绝。
- `test/features/app_shell/mobile_release_widgets_test.dart`：一次提醒、优先级、失败恢复、强制替换 Navigator、旧请求、安装身份变化、前后台、入场打断、原下载动作、iOS 和 Golden。
- `test/app_shell_test.dart`、`test/features/app_shell/`：原启动、推荐、强制、等待、剪贴板及应用壳回归；旧地址安全回退。
- `test/features/users/me_page_test.dart`、`me_page_visual_test.dart`：游客与账号设置入口移除后的布局和明暗／窄屏 Golden。

核心第一批 35 项通过；扩大后的首轮 187 项通过、5 项失败，涉及 iOS 测试缺新偏好端口以及剪贴板测试缺导航可见性观察者。修正注入并保留生产剪贴板的安全机会重试后，相同路径 192 项全部通过（`build-update-dialog-verified-tests.log`）。

组件 PNG 位于 `test/features/app_shell/goldens/mobile_notice_{before,after}_{light,dark}_360.png` 及 `mobile_notice_large_text_360.png`。已实际查看，360 宽无横向溢出，两倍字号正文可滚动、关闭可达。这些是 Widget 构造数据，不能代替真实 API、真机覆盖安装或负责人验收。

第一批组件交接副本：`D:\code\wenyousite\artifacts\mobile-release-notes-20260927\once-dialog-components-v1`；`source.json` 摘要 `35d6a954fa71f935aea0efbbbf3698b7f70ce4549eb7830c735503d17dc3ce4f`，仅对应当时组件候选。后续逻辑修改须以最终源码摘要为准。

本轮按负责人要求使用针对性测试、全量静态分析和持续 Debug 候选反馈；不因每次展示调整机械执行全量 Flutter 或构建 APK。完整集成门禁与负责人验收仍是后续合并边界，既有完整门禁不能代表已修改的当前应用源码。

## 字号反馈与最终检查

负责人反馈“更新文案字体太大”后，摘要和全部条目从 Foundation 已发布 body（16sp、1.6 行高）改为 compactBody（14sp、1.45 行高）；更新前、更新后和强制说明共用，标题／版本／按钮与系统字号缩放保持。主预览采用自然样本文案，HTML／Markdown 字面量验证仍留在功能测试。

第二批组件保存在 `D:\code\wenyousite\artifacts\mobile-release-notes-20260927\once-dialog-components-v2`，保留 v1；视觉源码摘要 `bc87bfd484456912dd977c2e72f8767a126d96a510011a091e5de649593fc1dd`。18 项说明 Widget／Golden 通过（`build-update-dialog-visual-v2.log`），已查看明暗、窄屏和大字号滚动后的画面；治理已转交负责人，尚未获得验收通过。

最终自查补充 SharedPreferences 先更新缓存再报告写入失败的边界：保留待补写标记，即使下次读到相同缓存也真正重试落盘。安装记录／存储 15 项通过（`build-update-dialog-storage-retry.log`）；新增强制说明失败不解除阻断的精确 Widget 用例 1 项通过（`build-update-dialog-forced-error.log`）。此次补充未改变已查看的字号画面，不为同源视觉调整重复全量 Flutter 或 APK。

应用候选提交 `856850698009c6375b8e84993ff7f25ad00bb9f7`；提交后源码摘要 `1d022bdcfde494dca63652f67350fb68de28d891820d653e03d0da60ffc31be0`。提交前检查摘要 `bf25ae0a16fafde1e637338984584c3e588dffa24fc3a6c38aeb6e31752c6888` 包含已删除历史页的占位；按相同文件清单复算完全一致，应用字节未因提交变化。摘要均来自 `tool/dev/runtime.mjs::sourceEvidence`，本段后续只补充文档。应用全量分析、生成 SDK 分析均零问题；全仓 Dart 格式 1123 文件零变更；模块文档、架构及 API 范围审计通过（161/161，0 missing）。架构检查中发现的原始 route 字符串、提示分类与共享弹窗边界已按既有规则修正，未添加豁免或扩大行数基线。契约、生成客户端、依赖、版本与 Android／iOS 文件均无 diff。

## 长说明滚动反馈

负责人询问长文案上下滑动后，在同一 PR #73 追加固定底部操作：共享 NoticeDialog 增加 primaryAction，下载／安装按钮与关闭固定；状态、进度和长错误留在可滚动正文内，不以压缩或限制系统字号缩放取得空间。强制弹窗仍不提供关闭，不改变更新资格及安全校验。

第三批组件目录为 `D:\code\wenyousite\artifacts\mobile-release-notes-20260927\once-dialog-components-v3`，v1/v2 保留。源码摘要 `dd344c357d298cd79170e8b444eba76b17345738de7eeed331a076375384883c`；`mobile_release_widgets_test.dart` 22 项全部通过（`build-update-dialog-scroll-v3.log`）。新增推荐／强制／升级后三个 320×568、两倍字号用例均实际向下拖动至第12条，再向上回到摘要，断言底部按钮矩形位置不变且可点击；推荐和强制点击后调用原更新服务，强制系统返回仍不能放行。对应 `mobile_notice_long_{recommended,required,after}_320_2x.png` 已实际查看，未发现布局溢出；长按钮文案允许自然换行，未裁切或缩小系统文字。

本批只重复上述直接受影响 Widget/Golden 和必要静态、格式／文档检查，不重跑已通过的192项或构建APK。第三批为最新应用源码候选，前两批检查仍按各自源码与范围保留，不冒充真机或负责人验收。静态检查仅发现共享主按钮插槽的 null-aware 元素风格提示，按既有规则改为等价语法后应用全量分析零问题（`build-update-dialog-scroll-v3-final-analyze.log`）；4个受影响Dart文件格式零变更、文档检查通过。此等价语法修订后的最终源码摘要为 `7c47cf812d2f127ff386a30d8abcf9bd3aaa371d3b7ad26d8ab5c48f80d72d10`，不改变已查看的v3画面与22项行为证据。

## 隔离环境与真机边界

已读本任务 consumer 并再次通过 API／media 身份验证：run `preview_705231a26b764b7cd53eed8e`，API 35293、media 36911。带正确预览身份头读取已发布 Android build 97 返回 200，版本名 `0.8.0-dev.2-debug`、revision 1，摘要及两条内容明确“隔离预览样本”。该样本由 Backend 任务写入；既有 build 100 与三项 meta 更新策略保持，未晋级或上传 APK。

`adb devices -l` 当前没有连接设备，历史 Debug 会话均非活动；未安装、卸载、清数据或伪造升级记录。只有设备恢复并核对实际包名／版本／安装时间后，才能启动本任务隔离 Debug 并补充 loadedSource、runId、设备、画面和负责人结果。

再次带本批次身份头读取 `/meta` 已核验：隔离预览 Android 的 minimumSupportedBuild、recommendedBuild、updateUrl 均为 null。正式公网才推荐 build 96，而本任务 Debug 为 97；合成 build 100 没有真实已验证 APK。因此推荐和强制的真实 API→APK→系统安装全过程本轮尚未覆盖，只提供明确标记的 Widget 状态验证，不修改安全校验或伪造 APK 元数据来制造覆盖。

## 负责人手测清单

1. 连接 ARM64 真机，确认打开的是 `site.wenyou.app.debug` 对应的“温油站” Debug 应用；复用本任务 consumer，通过 `dev:start` 启动持久会话并记录实际版本、安装时间与 loadedSource。
2. 无本机新记录且系统显示覆盖安装时，确认“已安装当前版本”只显示实际 Debug 97 的两条隔离说明，没有下载或历史入口；关闭、前后台、重开、登录／退出后不重弹。
3. 确认首页、设置和游客“我的”没有“查看更新”或“更新说明”历史入口；原任务恢复正常。明暗、大字号、长说明的关闭和滚动可用。
4. 有真实较低旧 build 基线的合法升级另行验证“已更新”，不可改本机偏好制造升级。验证断网／说明缺失不弹安装版空壳但保留待提示，恢复后的下一次安全前台可展示完整说明。
5. 推荐与强制的完整安装链需有独立且符合原校验的真实目标 APK 后验证；强制返回／遮罩／失败不能绕过。未具备该条件前保留为未验证。

未取得负责人对本轮交互的明确验收通过。现有组件审阅、自动检查与原候选验收互不替代。

## 正式版本候选准备

2026-09-27 负责人指定 `0.8.0+97` 正式版本并在后台确认文案。上文 dev.2 版本、组件和无设备记录按当时证据保留；当前版本准备、完整门禁、签名包和连接设备的后续结果统一追加到 [0.8.0 发布验收](mobile-0.8.0-release-acceptance.md)。版本调整不自动将本轮或旧问题标记为负责人验收通过。

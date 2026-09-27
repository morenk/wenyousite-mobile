# 更新前与升级后一次说明弹窗候选验收

状态：候选／待负责人验收。此记录对应移除“查看更新”及历史模块后的新交互，不以原历史页验收、旧 APK 或旧热重载摘要代表本轮。

## 范围与事实源

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

显示顺序为强制、升级后、推荐。升级后关闭后不会立即接弹，下一次安全前台先重新评估推荐；失败待提示在后续机会或本弹窗“重试”恢复，不在同一次机会循环。排队、加载、错误、后台响应、强制遮挡与未完成入场动画均不消耗机会。写入串行；失败保留进程收据并于后续观察补写，磁盘保存失败不冒称跨进程去重成功。

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

最终应用源码摘要：`bf25ae0a16fafde1e637338984584c3e588dffa24fc3a6c38aeb6e31752c6888`（使用 `tool/dev/runtime.mjs::sourceEvidence`，提交号见任务分支交付）。应用全量分析、生成 SDK 分析均零问题；全仓 Dart 格式 1123 文件零变更；模块文档、架构及 API 范围审计通过（161/161，0 missing）。架构检查中发现的原始 route 字符串、提示分类与共享弹窗边界已按既有规则修正，未添加豁免或扩大行数基线。契约、生成客户端、依赖、版本与 Android／iOS 文件均无 diff。

## 隔离环境与真机边界

已读本任务 consumer 并再次通过 API／media 身份验证：run `preview_705231a26b764b7cd53eed8e`，API 35293、media 36911。带正确预览身份头读取已发布 Android build 97 返回 200，版本名 `0.8.0-dev.2-debug`、revision 1，摘要及两条内容明确“隔离预览样本”。该样本由 Backend 任务写入；既有 build 100 与三项 meta 更新策略保持，未晋级或上传 APK。

`adb devices -l` 当前没有连接设备，历史 Debug 会话均非活动；未安装、卸载、清数据或伪造升级记录。只有设备恢复并核对实际包名／版本／安装时间后，才能启动本任务隔离 Debug 并补充 loadedSource、runId、设备、画面和负责人结果。

当前真实预览推荐 build 96，而本任务 Debug 为 97；合成 build 100 没有真实已验证 APK。因此推荐和强制的真实 API→APK→系统安装全过程本轮尚未覆盖，只提供明确标记的 Widget 状态验证，不修改安全校验或伪造 APK 元数据来制造覆盖。

## 负责人手测清单

1. 连接 ARM64 真机，确认打开的是 `site.wenyou.app.debug` 对应的“温油站” Debug 应用；复用本任务 consumer，通过 `dev:start` 启动持久会话并记录实际版本、安装时间与 loadedSource。
2. 无本机新记录且系统显示覆盖安装时，确认“已安装当前版本”只显示实际 Debug 97 的两条隔离说明，没有下载或历史入口；关闭、前后台、重开、登录／退出后不重弹。
3. 确认首页、设置和游客“我的”没有“查看更新”或“更新说明”历史入口；原任务恢复正常。明暗、大字号、长说明的关闭和滚动可用。
4. 有真实较低旧 build 基线的合法升级另行验证“已更新”，不可改本机偏好制造升级。验证断网／失败关闭后保留待提示，恢复后可重试。
5. 推荐与强制的完整安装链需有独立且符合原校验的真实目标 APK 后验证；强制返回／遮罩／失败不能绕过。未具备该条件前保留为未验证。

未取得负责人对本轮交互的明确验收通过。现有组件审阅、自动检查与原候选验收互不替代。

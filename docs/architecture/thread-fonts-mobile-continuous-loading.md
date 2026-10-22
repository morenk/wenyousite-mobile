# 正文字体持续加载设计与验证

状态：原公网候选字体入口验收失败，沿用原问题、任务分支与 PR #114 提供光标输入候选，待负责人复验。此前固定28款实验及隔离候选仅属于历史证据，不能代替当前动态系统验收。

## 动态字体生产接入（候选，待真机验收）

### 光标选字体与面板即时反馈（2026-10-22，候选／待负责人验收）

原候选 APK `118d16a503e8bbcdbdeee2ace14d1aee5639801fe0951ea45f8ebb951db0f4f8` 收到“点击字体文案，没有反应”；负责人补充“不选中正文也能直接选择字体，然后输入正文”。记录为验收失败／继续排查。旧入口 `canSelect` 和 `EditorTextFontPolicy.apply` 均拒绝折叠光标，已证实交互缺口；另发现目录请求在弹层前等待，没有即时反馈，且连续点击没有互斥保护。没有把未提供的网络超时认定为负责人原场景的独立根因。

候选支持空正文及有效光标先选字体，再对后续普通文字应用。输入、IME 组合替换、换段保持临时字体，主动移位、历史操作、只读与替换文档清除；恢复默认明确移除字体属性。选择本身不改正文、草稿或撤销栈。纯文本粘贴在验证前加入当前输入样式，结构化粘贴保留来源字体，后续手输仍沿用光标设置。有选区保持原范围更新、跳过换行和原子节点的既有语义。

字体面板立即打开并显示加载；失败可原地重试，取消／退出忽略迟到请求；连续点击只产生一个面板。选择前恢复入口光标，再设置新输入字体，避免 finally 恢复旧快照覆盖新选择；取消恢复原选区、焦点及未落字字体，文档变化时不回放陈旧选区。

`editor_text_font_caret_test.dart` 的三项初始回归在旧实现均失败（`.dart_tool/font-caret-before.log`）。新增真实 T 的空正文、连续点击、慢请求、失败重试、取消时临时移位、退出后请求完成及 IME 输入，保留原字体范围／双倍字号测试并补动态版本光标输入与保存；首次9项定向检查通过（`.dart_tool/font-picker-preview.log`）。320px 明暗图是离线 Widget 组件图，不能证明 Android 字形、键盘或负责人验收。

本轮只读 `/meta` 已变为 `5.43.0-dev.20261022.3`／Backend `1902aa4f844f47e3b867806ec7d6fe845b02f267`，v2 read/write 均开启；后端只读镜像中，本地契约 pin `62a0313` 与部署提交的 `contracts/` 无差异。此前“公网缺少字体能力”的结论只适用于下方13:34历史观测；没有把 buildSha 不同描述为精确部署门禁通过。Foundation fetch 后最新正式 Tag 仍为 v7.6.0，依赖保持固定。

最终 `npm run candidate:apk -- <下列20个测试文件> -TestConcurrency 2` 成功：1510个文件格式无变化，应用和生成客户端全量分析零问题，239项测试通过，ARM64 Debug 构建成功（`.dart_tool/font-picker-candidate.log`）；架构及23模块文档检查通过。没有重跑不受影响的全仓 Flutter 测试，原任务全量检查历史结果仍保留下文。

新公网候选为 `build/dynamic-font-public-candidate/wenyou-font-caret-debug-dd14d5a9f9d8.apk`，156064698字节，SHA-256 `dd14d5a9f9d8b348bf319b2af9e2439574177a83136604c9029acd90b3158653`；包名 `site.wenyou.app.debug`，0.10.0-debug／100，仅arm64-v8a，APK v2签名通过。2080文件应用摘要 `1acccc5267506e31992ac27d38392ff8839092b23ecf7e70d7e553613121f232` 构建前后完全相同。本次正式候选入口没有传入 API override，使用已核对的 AppEnvironment 公网默认值；打包 kernel 包含 `https://wenyou.site/api/v1`，不含原38876地址。没有将此前显式 defines 的哈希复用到本次默认配置。

原包及配置分别保留；本次证据为 `.dart_tool/font-picker-candidate-config.json`、`font-picker-candidate-source.json`、`font-picker-candidate-signature.log`、`font-picker-candidate-badging.log`。离线组件图为 `.dart_tool/font-picker-caret-preview/font-picker-light.png` 与 `font-picker-dark.png`，测试使用完整系统字体显示目录文案，不作为实际自定义字体字形证据。

本轮候选门禁显式指定以下20个文件（均位于 `test/features/editor/`）：

- `editor_atomic_clipboard_test.dart`
- `editor_clipboard_input_method_test.dart`
- `editor_dynamic_font_list_test.dart`
- `editor_dynamic_font_paste_test.dart`
- `editor_dynamic_font_toolbar_test.dart`
- `editor_enter_newline_test.dart`
- `editor_selection_history_test.dart`
- `editor_text_color_caret_paste_test.dart`
- `editor_text_color_caret_test.dart`
- `editor_text_color_caret_widget_test.dart`
- `editor_text_color_multiline_input_test.dart`
- `editor_text_font_caret_test.dart`
- `editor_text_font_interaction_test.dart`
- `editor_text_font_paste_scope_test.dart`
- `editor_text_font_picker_test.dart`
- `editor_text_font_selection_test.dart`
- `editor_text_font_session_test.dart`
- `editor_text_font_web_interop_test.dart`
- `editor_toolbar_history_test.dart`
- `text_font_write_capability_test.dart`

负责人复验：打开新公网 Debug，在主题空正文依次点 T → 字体 → 任一可用字体，输入中／日／英文字并换段；确认无需先选中正文。随后恢复默认继续输入、主动移位、撤销／重做，检查已有文字不被批量修改；选中已有部分文字更换字体后保存重开，检查范围和其他格式；取消选择后继续输入确认字体保持。真实 Android 键盘、字形与以上原操作仍待负责人验收，未自动安装、启动、登录或写入公网。

### 公网直连候选与旧服务兼容（2026-10-22 13:34，历史候选）

负责人要求直接连接 `https://wenyou.site/api/v1` 的 Debug，不使用电脑转发。北京时间13:34只读 GET `/meta` 返回200/code0，契约 `5.40.0-dev.20261018.1`、build `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`、Markdown5，Android minimumSupportedBuild为null、recommendedBuild为100；缺失字体v1/v2 capability。本地仍锁定正式同步的5.43.0-dev.20261022.3，未伪造或降级契约。

精确部署一致性工具要求契约版本与buildSha完全相同，因此公网差异仍不通过；App的运行时判断不同：`AppEnvironment.supportsContract` 接受主版本5，支持Markdown3/4/5/6，`StartupController` 仅在契约不支持、Markdown不支持或达到强制升级条件时阻止进入。build100没有强制或推荐升级。缺失字体能力按false处理，隐藏字体选择入口；这不等于公网已经上线动态字体。

实际兼容缺陷由源码及本地序列化复现确认：公网build的 `src/main.ts` 启用 `whitelist:true/forbidNonWhitelisted:true`，5.40的正文DTO没有 `textFontVersion`；原任务源码无条件发送2，包括普通文字。新回归在旧实现对无能力和仅v1能力均失败（`.dart_tool/dynamic-font-public-old-regression.log`），没有通过公网写入触发。候选在五个仓储九条写入路径按capability选择2/1/null，普通文本保留原样；含v1/v2真实字体源时仍在网络前拒绝不支持的写入，保持草稿及原文。动态、评论和私聊继续使用原有不支持字体的剪贴板投影，未新增字体字段。

第一轮直接相关检查75项通过（`.dart_tool/dynamic-font-public-regression.log`）：`test/features/editor/text_font_write_capability_test.dart`、`thread_compose_repository_test.dart`，`test/features/drafts/content_draft_repository_test.dart`，`test/features/posts/post_repository_test.dart`，`test/features/threads/thread_management_repository_test.dart`、`subthread_management_repository_test.dart`、`thread_detail_stack_test.dart`，`test/core/markdown/text_font_write_guard_test.dart`、`markdown_text_font_v2_test.dart`，`test/core/config/app_environment_test.dart`，`test/features/auth/login_controller_test.dart`，`test/mobile_update_test.dart`，`test/features/media/audio_meta_test.dart`。所有请求均在本地夹具截获，未在公网登录、发帖或上传。

公网原始meta另固定为只读夹具，经真实生成解码器和StartupController复验为 `ready`/guest、无升级提示且四项字体能力均false；`test/features/app_shell/public_meta_compatibility_test.dart` 与 `test/features/editor/editor_atomic_clipboard_test.dart` 共7项通过（`.dart_tool/dynamic-font-public-meta-projection-test.log`）。补齐主题创建/聚合/管理的原文保护后，`test/features/editor/text_font_write_capability_test.dart` 和 `editor_dynamic_font_paste_test.dart` 共9项通过（`.dart_tool/dynamic-font-public-guards.log`），覆盖published/disabled/withdrawn/unknown状态及保存重开。格式1507文件无变化、架构及23模块文档通过。

最终应用全量静态检查零问题（378.6秒，`.dart_tool/dynamic-font-public-analyze.log`）；公网APK构建成功（214.3秒，`.dart_tool/dynamic-font-public-build.log`）。本轮只改变字段能力协商，按负责人明确要求收敛定向验证，没有重复整套全量测试；公网精确部署契约差异仍保持失败边界。

公网独立产物为 `build/dynamic-font-public-candidate/wenyou-public-debug-118d16a503e8.apk`，156098772字节，SHA-256 `118d16a503e8bbcdbdeee2ace14d1aee5639801fe0951ea45f8ebb951db0f4f8`。包名 `site.wenyou.app.debug`，名称“温油站 Debug”，0.10.0-debug／versionCode100，仅arm64-v8a，APK v2签名有效。2079文件应用摘要 `d8e1ef174458f07894cb3500017f0728aaf4eebb56268afe0954a72ac58933e1`，构建前后逐文件复核一致。唯一显式编译配置 `API_BASE_URL=https://wenyou.site/api/v1`（UTF-8无换行），defines SHA-256 `e2edbb34f8ed93a972e33149e08e4e7f8f4f66e21981310e3cea625c6a38839a`；没有测试凭据或电脑转发依赖。元数据位于 `.dart_tool/dynamic-font-public-candidate-config.json`，源码清单 `dynamic-font-public-source.json`，签名/包信息证据 `dynamic-font-public-signature.log`、`dynamic-font-public-badging.log`。

原隔离APK `dd42b0a...` 及其配置保持原样，新公网包单独记录，不安装、不启动、不清手机数据。普通登录和实际使用仍待负责人自行安装复验，不能用本地mock登录替代真机验收。公网缺少字体能力时不能验收自定义字体；该能力需兼容后端正式上线后再复验，当前任务未执行部署。

### 最终契约与 T 面板补验（2026-10-22，待真机验收）

契约已固定 Backend `62a0313a75c85e42dfa39cd09b7cc90ae5c34186`／HTTP `5.43.0-dev.20261022.3`，独立同步提交 `2cbe2417`。本次增量仅扩展审计动作和目标枚举、补充运行说明；字体正文与资源协议不变。OpenAPI 校验、正式再生成、生成客户端分析及契约来源核对通过，API 覆盖检查通过。未部署公网。

T 面板复用现有入口，精简常驻提示、显示当前／默认字体、混合选区与历史选择状态；取消工具后保留选区、焦点和输入样式。Foundation 远端正式最新 Tag 仍为 v7.6.0，已核对对应变更说明。`.dart_tool/dynamic-font-final-focused-r2.log` 18项通过，路径：`test/features/editor/editor_dynamic_font_toolbar_test.dart`、`editor_text_font_picker_test.dart`、`editor_dynamic_font_list_test.dart`、`test/tool/font_acceptance_probe_test.dart`、`test/core/network/audio_budget_contract_test.dart`、`dynamic_font_numeric_contract_test.dart`。此前新夹具的异步等待、滚动后未 pump 及生成途中编译失败记录保留，不充作产品通过证据。

真实产品的[连续验收步骤与只读观察器](../../tool/font_acceptance/README.md)已准备：绑定 APK/进程/VM 身份、持续拒绝重载或断连，采集实际 PSS/RSS、VM 内存、原生注册账本及画面，业务操作仍经真实编辑器和 Android 系统剪贴板完成。桌面 Dart VM 夹具只验证观察器协议，不替代 Android 产品。观察器全量静态检查零问题，日志 `.dart_tool/font-acceptance-final-analyze.log`。

最终 loopback 候选已于 Windows 构建（39.7秒，`.dart_tool/dynamic-font-final-loopback-build.log`），应用提交 `d804dcd75ff3842b2b0f6d65cd026f30dae8cc37`：

- APK：`build/dynamic-font-v2-candidate/app-dynamic-font-v2-final-dd42b0a44c89-debug.apk`，156057342字节，SHA-256 `dd42b0a44c89fcfc79c90a1599b90022d64ae2ee1664671c3de77f6ec92233e5`。
- 包名 `site.wenyou.app.debug`，名称“温油站 Debug”，`0.10.0-debug`／versionCode 100，仅 `arm64-v8a`，APK v2签名验证通过；签名及包信息日志为 `.dart_tool/dynamic-font-final-signature.log`、`dynamic-font-final-badging.log`。
- 2079文件应用源码摘要 `3193e41271a95ae880e4db63dda0ebe3fa65775e236c4b0ece96952fb607827f`，构建前后逐文件复核未变化；清单 `.dart_tool/dynamic-font-final-source.json`。再生成一致性通过（`.dart_tool/dynamic-font-final-generation-check.log`），没有手改生成文件。
- 编译字符串 `API_BASE_URL=http://127.0.0.1:38876/api/v1`（UTF-8无换行），defines SHA-256 `e56725816143f5dca48f183bb1941c4e6d79f9d3a39ab8b267b55de9f4b693b6`。最终元数据 `.dart_tool/dynamic-font-candidate-config.json`，前一版配置单独保留。

下节 `244e8b6c...` APK 已被 T 面板及最终生成客户端更新取代，不包含本轮 UI，不用于最终联验。当前 ADB 无设备，未安装或启动；38876尚无已核验的隔离转发。按负责人安排保留等待连接，客户端固定并启动后才开始新字体 ID 的核心旅程。公网兼容差异仍未解决，不能声称整套门禁全绿或真机验收完成。实际 Android 字形、键盘／选区、系统剪贴板、发帖／保存重开、离线恢复、新版／停用／撤回／回滚、PSS及同进程原生账本均未覆盖，须按上方真实产品步骤执行。

本批次最终应用全量静态分析零问题（237.5秒，`.dart_tool/dynamic-font-final-app-analyze.log`），生成客户端零问题（`dynamic-font-final-generated-analyze.log`）；1505个 Dart 文件格式无变化、架构与23模块文档通过，API范围175/175无缺项。新增 UI、观察器和最终审计枚举没有改变已完成完整门禁的字体运行时；本轮补验上述直接受影响路径，不把旧完整门禁结果改写成新源码全量测试通过。

### 前一版兼容源码检查与候选证据（已被本轮更新取代）

- 应用源码摘要：`03e91de9e303b844b923ede2b679f674dea8d9e66b2e3d218e37b5f2d45b4cb8`（lib、Android、生成客户端、pubspec，2079个文件）；门禁后只修正测试断言与文档，构建前复核应用摘要未变。
- `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2` 已完整执行。格式1499文件零改动；应用/生成客户端静态分析、架构、23模块文档、API覆盖175/175及再生成一致性通过；Windows工具49/49通过，Debug APK构建成功。
- Flutter原始全量结果为7648通过、1跳过、2失败。两处失败均为仍期待字体协议1的旧测试断言；按正式字体协议2修正后，主题创建/聚合仓储3项、楼中楼生成客户端链路6项复验通过。原日志保留失败，不称原始全量全绿。
- 公网兼容检查仍未满足：公网为5.40／`6e00c403`，本地为5.43.0-dev.20261022.2／`7c9719e4`。未部署、修改公网配置或跳过此检查，动态兼容证据等待登记隔离入口。
- 默认构建APK仅作本地编译证据，SHA-256：`2039a499b911e00d7cd3df221bfe5015ddf58040b46de3e459e37fd37e04a1fb`。
- 联验候选：`build/dynamic-font-v2-candidate/app-dynamic-font-v2-loopback-244e8b6c0f92-debug.apk`，156094180字节；SHA-256：`244e8b6c0f920b8fe9a59830697732d0009aae93f15590029a2b8bb7ad3051c2`。包名`site.wenyou.app.debug`，名称“温油站 Debug”，版本`0.10.0-debug`／versionCode 100，仅`arm64-v8a`，APK v2签名验证通过。
- 固定配置为`API_BASE_URL=http://127.0.0.1:38876/api/v1`；以该UTF-8字符串（无换行）计算defines SHA-256：`e56725816143f5dca48f183bb1941c4e6d79f9d3a39ab8b267b55de9f4b693b6`。详细本地元数据位于`.dart_tool/dynamic-font-candidate-config.json`。
- 尚未安装或启动候选。Backend最终审计枚举增量尚未提交，收到正式SHA后独立同步契约/生成客户端并按变化补验；核心新ID联验须在最终双方构建及会话打开后开始。设备数据归属、隔离入口、负责人验收仍待核验。

### 行为与分项记录

当前固定 Backend `7c9719e44dbdc62ede77056fe93a98551133d0e9`／API 5.43，Foundation v7.6.0。沿用当前 Worktree、任务分支和 PR #114。契约已通过独立 chore 同步；数值 fontVersion 被生成器误识别为字符串的问题已通过生成归一化工具修正，提交 `4d93bc59`，生成客户端全量分析零问题。历史 28 款 APK、截图与门禁仍绑定旧源码，不作为本次动态系统证据。

生产服务已接入以下候选行为：

- 所有正文读取与写入声明字体能力 2。合法 `tfv_` ID 经 Markdown、编辑器、草稿保源，不依赖固定名单；字体 v1 继续解析，颜色与其他行内格式保留。旧服务不支持 v2 时拒绝有损保存。
- `DynamicFontCatalog` 使用轻目录分页、ETag、完整快照原子替换；游标409只立即重取一次，失败保留旧快照。点查合并、404负缓存30秒、五分钟前台/选择器重验证；明确撤回墓碑跨缓存恢复优先，未知状态/语言及不可变资源被替换均拒绝。
- `DynamicFontRuntime` 分别处理策略、目录与单版本清单失败；损坏目录不阻断已知正文按版本读取，一个坏清单不阻断其他字体。元数据最大64KiB、清单最大4MiB；清单驻留最多32份/16MiB原始JSON，目录最多8192项/4MiB，描述符和负缓存各256项。撤回墓碑最多4096项，饱和时保守停止动态呈现，不能淘汰墓碑后复活。
- 引擎级 `TextFontNativeLedger` 统一旧 v1、固定 manifest 和动态注册：64MiB输入/1024个SHA+family键，调用前预留，失败不退款，同键复用、不同family分别计费；Provider及账号变化不重新给额。历史超限保留原占用与已加载结果，拒绝新增。注册输入计数不能称为RSS。
- 元数据、PNG样张和正文共用60秒/24MiB/64请求窗口，并发1。元数据等正在进行的正文完成后执行，避免反复取消造成正文无法完成。传输采用15秒无字节进度/600秒总限；非200状态可立即结束未EOF响应，调用方取消与状态完成分别处理。
- 选择器保留中文/日文/英文/其他分类，仅显示按需PNG；同SHA样张失败会退避重试，离屏/后台取消无用需求。选择前复核状态。粘贴先点查：历史已发布允许原版本，停用/撤回/未知新增片段默认字体；已有正文不被清洗，颜色/粗体与保存重开保留。

本轮已执行的回归记录：`.dart_tool/dynamic-font-metadata-regression.log` 18项（数值协议、分页/缓存/不可变状态、真实HTTP慢流及未EOF状态）；`.dart_tool/dynamic-font-selector-runtime-regression.log` 13项（选择器分组/样张恢复、并发1、账本迁移/撤回/故障独立）；`.dart_tool/dynamic-font-write-paste-regression.log` 27项（字体2头及写入DTO、四种状态粘贴、独立阅读语义、保存重开）。具体路径为 `test/core/network/dynamic_font_numeric_contract_test.dart`、`test/core/text_fonts/dynamic_font_catalog_test.dart`、`text_font_transport_test.dart`、`dynamic_font_service_test.dart`、`dynamic_font_runtime_test.dart`，以及 `test/features/editor/editor_dynamic_font_list_test.dart`、`editor_dynamic_font_paste_test.dart`、`test/core/network/network_providers_test.dart`、posts/drafts/threads对应repository测试。全量静态检查与完整门禁继续进行，不称本轮全绿。

补充本地检查：`.dart_tool/dynamic-font-core-final-regression.log` 161通过/1失败，失败是总时限诊断原因在拆分取消令牌后未透传，已修正；随后正式传输夹具与真实HTTP全套22项通过（`.dart_tool/dynamic-font-transfer-final-regression.log`）。清单恶意/错误输入及真实Provider容器/账号切换账本12项通过（`.dart_tool/dynamic-font-manifest-lifetime-regression.log`）；新增v2跨动态/评论/私聊默认字体投影、选择器和服务10项通过（`.dart_tool/dynamic-font-projection-selector-regression.log`）。架构与23模块文档通过；API范围175/175，零缺项，91项明确排除。首次全量分析只有11条info，已按规则修正，最终复验进入统一 `npm run check -- -ContinueAfterFailure -TestConcurrency 2`，日志 `.dart_tool/dynamic-font-integration-gate.log`；未结束前不称完整门禁通过。
v1 兼容已按 `7c9719e44dbdc62ede77056fe93a98551133d0e9`／`5.43.0-dev.20261022.2` 接入，契约同步提交 `76827706`。观察到 v2 支持后，同一引擎内保持 v2 路由；固定映射的 v1 使用历史版本描述符和受控网关，源标记不改写。停用仍可阅读但不允许新增粘贴；撤回同时移除 v1/v2 呈现、取消需求，原生账本不退额。缺失、404、网络错误和能力降级均不能回退旧清单/公共 URL；已有可信状态可离线恢复，持久化撤回墓碑在新会话能力缺失时也优先。无映射退役 ID 使用默认字体。旧二进制已取得的公共 URL 和本地缓存不能由本次客户端更新远程撤销，限制见 `contracts/deprecation-register.md`。

`.dart_tool/dynamic-font-legacy-routing-regression.log` 35 项通过，覆盖正式 `legacyRoutingCases`、`legacyCapabilityCases`、固定映射一致性、源标记与粘贴范围、旧注册账本共享、运行时并发及四种状态保存重开。实际路径：`test/core/text_fonts/text_font_legacy_routing_test.dart`、`dynamic_font_runtime_test.dart`、`dynamic_font_service_test.dart`、`test/features/editor/editor_dynamic_font_paste_test.dart`。

此前 `.dart_tool/dynamic-font-integration-gate.log` 已主动停止：当时公开契约不匹配，分析缺少 rendering 导入，测试 1,906 通过／1 跳过／1 失败；测试运行期间发生源码变化，不能作为最终候选证据。导入和旧目录请求回归已修正，分项复验通过。最终兼容源码需重新执行统一门禁，不沿用混合源码结果。

设备 `4b9c39b5` 曾重新核验在线（model 2509FPN0BC，transport_id 13），后续读取ABI与进程时再次返回device not found；当前不能开展真机操作，联验前须重新核验。本任务单独控制该设备；本轮产品 APK 已构建但尚未安装，同会话验收未执行。真实写入 E2E 等待 Backend 提供独立 PG、Redis、存储、账号与清理所有者的已提交入口，不回退线上。顺序必须是最终客户端构建/启动之后真实Admin上传→处理→预览→发布新ID，再在同一Android会话验证选择、发帖、阅读、系统剪贴板、保存重开、离线恢复、预算与RSS。后续新版、停用、撤回、回滚也须保留原帖版本。旧FontLab结果不替代此验收。

本轮 Android 联验记录要求（均待执行）：

治理已指定最终联验候选使用普通显式配置 `API_BASE_URL=http://127.0.0.1:38876/api/v1`；Windows 端口已只读确认无监听。完整门禁默认 APK 仅作编译证据，门禁结束后基于相同应用源码另构建这一固定配置并记录 source/defines/APK 哈希。Backend 交付登记环境后，由治理建立 38876 到实际随机端口的 SSH 转发；设备再通过本任务 ADB reverse 连接。loopback 不是隔离证据，启动、登录及写入仍等待环境身份、转发目的地、API能力与 Debug 包数据归属全部核验。此配置不恢复已退役 preview 机制。

候选配置核对：`android/app/build.gradle.kts` 的 Debug applicationId 为 `site.wenyou.app.debug`，Profile 为 `site.wenyou.app.profile`，正式包为 `site.wenyou.app`。`AppEnvironment` 只接受普通 `API_BASE_URL`，不会按地址分区 Token、偏好、数据库或字体缓存；旧 `WENYOU_PREVIEW_*` 明确拒绝启动，不能称为仍可用的隔离构建入口。当前门禁默认构建的 API 为公网，仅作为本地编译产物，不启动其写入联验。最终联验地址固定为上述 38876 loopback 配置，转发目的地待 Backend 登记入口核验；新字体 ID 必须在该候选启动后创建。安装前只在 Debug 包不存在，或已有数据已确证为本任务隔离环境所有时继续；已有真实账号/草稿或归属不明时保留现场，不卸载、清数据或自动跨环境启动。

| 场景 | 必须记录的结果 |
| --- | --- |
| 安装与环境 | 实际包名、安装前后更新时间、设备内 APK SHA-256、应用源码摘要、设备 ABI、API 地址及隔离 runId；已有本地账号与草稿不得带入另一环境 |
| 新字体发布 | 客户端构建和启动时间早于真实 Admin 创建 ID；同一会话打开选择器出现新 ID、正确语言分组与 PNG 样张，选择器本身不增加原生字体注册 |
| 正文闭环 | 选择文字、应用字体、发布、阅读、打开编辑、系统剪贴板复制粘贴、保存、重开；记录原文 ID、可见文字、颜色、粗体、段落边界 |
| 新版本与回滚 | 已有正文保持旧版本；新选择使用当前版本；回滚不重写原帖、不重新注册相同 SHA+family |
| 停用与撤回 | 停用历史仍可读，新增选择/粘贴默认；撤回后对应 v1/v2 同时默认、无后续资源请求，原文 ID 保留；前台恢复、离线重开和能力降级不能复活 |
| 内存与流量 | 分别记录原生注册键/输入字节、网络窗口占用、Dart heap/external、Android RSS/PSS；失败计费与重复访问不重计，禁止将输入额度当作 RSS |
| 清理与验收 | 由隔离环境所有者记录上传、帖子、测试账号及数据库/缓存/存储清理；负责人明确复验结果单独登记，自动验证不能替代 |

最新定向检查：页面保持可见时能力更新、嵌套滚动作用域、选择器和恢复默认共 9 项通过（`test/core/widgets/text_font_render_scope_test.dart`、`test/features/editor/editor_text_font_picker_test.dart`，日志 `.dart_tool/dynamic-font-scope-picker-compatible.log`）。兼容最终门禁为 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，日志 `.dart_tool/dynamic-font-compatible-final-gate.log`；应用源码保持固定，最终结论见本节顶部。

跨端补充审查只增加必要回归，未改动应用实现：`dynamic_font_catalog_test.dart` 和 `dynamic_font_runtime_test.dart` 共 20 项通过（`.dart_tool/dynamic-font-tombstone-eviction-regression.log`）。任意非内置新 ID 撤回后，超过256条详细描述符淘汰、目录轮换、迟到 published、旧目录再次包含以及离线恢复均不能恢复选择、粘贴、呈现或资源请求。独立撤回集最多4096条；饱和后持久化 denyAll，不通过淘汰墓碑释放内存。新增用例在最终门禁进入静态分析和全量测试前完成，将纳入该次门禁。

最终门禁的 Flutter 阶段发现 `test/features/editor/thread_compose_repository_test.dart` 仍期待创建/聚合写入字体版本1；正式新契约要求2，应用实际已发送2。只修正两处旧断言，应用源码未变；该文件3项复验全部通过，日志 `.dart_tool/dynamic-font-compose-protocol-regression.log`。完整门禁日志中的该次失败保留，不改写成原始全绿；无需据测试断言更新重复整套已验证应用源码。

另一处旧协议断言位于 `test/features/threads/thread_detail_stack_test.dart`：生成客户端楼中楼写入实际为 `textFontVersion: 2`，旧预期仍为1。只更新该断言，完整文件6项复验通过，日志 `.dart_tool/dynamic-font-reply-protocol-regression.log`。上述两项均未修改应用源码，保留原始失败及定向通过证据。

2026-10-22 负责人决定不能分片则移除小城拉风体，当前目标为 28 款（中文 12、日文 10、英文 6）。已固定 Backend `f27898ec3b168b9e027b5d5abef43a0d3dafa242`，同步新不可变 manifest、快照及通用“15 秒无进度／600000 ms 总上限”策略；不修改旧 v1 解析或删除历史字体 ID。旧内容保留文字并安全回退，最近使用记录不能使已撤下字体重新出现。下文 29 款、65／869 资源、18.4 MB 原件与旧 Android 两次实验均为历史证据，不能改称新 28 款实测。新 28 款常用集合结果单独记录，不重复旧全目录压力实验。

## 原运行与证据边界

旧源码 `dcfa323fcb92a3c566859baf55d9da5eb12872d2c5f1896f2242e4b7ed13ea23` 的完整门禁于 Flutter 测试 19:15、5,102 通过／1 跳过时停止，未开始 APK 构建。格式、应用及客户端分析、架构、文档、API 覆盖已通过，公网契约仍不匹配；不宣称完整门禁通过。日志 `.dart_tool/thread-font-scope-final-gate-apk.log` 保留。已停止的测试仅属于本任务进程。

`.dart_tool/thread-font-product-flow-r5/scope-final` 的 10 张作用域／粘贴图片仍代表该旧源码；不把它们或既有 APK 标成持续加载实现的证据。

## Flutter 原生生命周期事实

已读取本机 Flutter 3.44.8 对应 engine `0cd610717bde95fd88343c64f81c11ba4e5c0010` 的源码：

- `engine/src/flutter/lib/ui/text/font_collection.cc` 的 `LoadFontFromList` 用 `SkMemoryStream(..., true)` 复制输入，动态字体管理器持有 `SkTypeface`。
- `txt/src/txt/typeface_font_asset_provider.cc` 向 `typefaces_` 追加对象；重用 family 不替换既有对象。`font_collection.cc` 的 `ClearFontFamilyCache` 仅清排版缓存。
- [FontLoader 公共 API](https://api.flutter.dev/flutter/services/FontLoader-class.html) 没有 unload。销毁 Widget、清空 Dart Map 或丢弃 FontLoader 均不能证明原生字体释放。[Flutter 生命周期提案](https://github.com/flutter/flutter/issues/186925) 不能当成已交付 API。
- 普通 Android 插件不能通过现有公开接口替换引擎字体集合。自定义引擎或独立原生排版会影响 Quill、选区、输入和无障碍，不能作为未验证的快捷修复；不采用偷偷重启引擎的办法。

## 资源控制设计

固定 manifest 1.2.0（SHA `e2836703a30eec5f59dd9d4d72f6887756c2dd30c070606db5cee258ebd0efa3`）的 Mobile 唯一资源为 868 个、184,645,488 B（176.09 MiB），28 个 core 合计 35,570,596 B。这是注册输入的有限上界，**不是 RSS 或 Android 安全内存承诺**。

1. 进程锁定已校验 manifest 的有限注册快照，按资产 SHA 与 family 核对身份；每个资源最多一次原生注册尝试。调用原生前保守记账，失败也不假设已释放；失败资源不阻断同字体其他片。
2. 资源版本不随路由、目录刷新无限累积。撤回立即停止提供样式，既有原生对象不可卸载；不向冻结集合追加未来版本。新目录接入边界由共享策略明确。
3. 下载使用 60 秒滑动窗口 24 MiB／64 次，串行执行，无原件专属额度。失败的尝试仍计费，到期自然补充，窗口使用单调时钟。缓存命中不消耗网络额度。
4. 按资源记录暂时错误，1／2／4／8／16／32／60 秒上限的 full jitter，尊重 Retry-After。可见需求和恢复前台／网络恢复只唤醒仍有效需求；反复滚动不能清空失败计数或突破窗口。离屏、销毁和后台不持续空转重试。
5. 校验、解码、撤回及已尝试原生注册失败隔离，不作为普通网络错误无限重试。不因一个片失败永久封禁整个 fontId。
6. 磁盘缓存继续有界 LRU，注册后不长期保留 Dart 字节数组；已注册字体的磁盘副本可淘汰，不能把磁盘回收算成原生内存回收。许可与清单的小型元数据独立保留。

事实源为 Backend `f27898ec3b168b9e027b5d5abef43a0d3dafa242`／API `5.42.0-dev.20261022.1`，独立提交 `ad19617d` 同步策略、schema、夹具与生成客户端。`GET /meta/text-fonts/runtime-policy` 的 `policyVersion: 2` 必须绑定描述符及实际 manifest SHA。旧不可变 manifest 和 v1 `limits` 语义保留。

生产 v2 的传输层采用 15 秒无进度／600 秒总上限，服务与队列不再另包 15 秒总超时。请求发出时计时，排队不计；响应头不续期，只有未超限的非空正文块续期。响应头、每块和 EOF 均核对单调截止，截止瞬间已超时，重合时总上限优先。取消、后台、离屏释放在途读取；HTTP 暂时状态先于 MIME 分类。旧 `TextFontRuntime` v1 的总 15 秒兼容行为不变。

目录与策略也计入同一窗口，每次按固定 64 KiB 预占并流式限长；manifest 按完整描述符预占。JSON 归属声明使用 `application/json`，许可使用 `text/plain`，TTF/OTF 使用各自字体 MIME。公开独立传输不带账号身份、不使用通用 API 的自动重放。未知策略或校验失败时本实现保持系统回退，不猜测放宽额度。旧累计运行时仅保留在未协商的独立测试入口，生产服务要求已验证 v2。

生产代码入口：`text_font_service.dart` 管理可见 owner、冷启动元数据恢复、前台/在线事件、撤回及元数据串行事务；`text_font_demand_queue.dart` 管理资源级需求、退避与注册；`text_font_scope.dart` 按路由、屏幕和最近滚动视口交集持有/释放需求。新增正文不会取消另一仍可见正文的下载。缓存读写/指针失败不撤销已验证输入，明确撤回会清除当前可用清单，冻结的原生快照不授予下载权限。

## Windows 原生实验

手动工具 `tool/measure_text_font_native_memory_test.dart` 逐个校验正式本地资源并调用真实 FontLoader，不使用旧应用预算；它是设计实验，不是运行时集成验收。无账号或业务写入、无字体 HTTP 请求。VM 诊断仅连接本测试进程 localhost，原始响应不保存调试访问令牌。

- core29 首轮 PID 30844：输入 53,981,196 B／29 个资产；RSS 基线 189,739,008 B，返回后 249,106,432 B，峰值 273,580,032 B。移除文本与 Dart 注册表后 RSS 249,397,248 B。没有 VM 服务采样，不据此区分 Dart 与 native。
- typical29 PID 5844：增加实际日文假名、组合音符等命中片，输入 **62,125,436 B／65 个资产**；同进程访问所有 29 款并反向返回五轮，所有轮次均无新增读取或注册。
- 带 VM 诊断的基线 RSS 243,937,280 B；五轮返回 RSS 为 318,054,400、322,220,032、326,623,232、322,338,816、323,817,472 B，峰值 348,553,216 B。内存有波动，不能称为完全不变。
- 每次采样前执行 Dart GC。基线 Dart heapUsage 120,594,704 B／externalUsage 132,208 B；第五轮为 126,009,968 B／132,176 B，未保留约 62 MiB 的外部输入缓冲。仍包含 manifest、测试及 VM 诊断开销。
- VM 未归属 RSS 包含引擎、字体、图形等，不能全部标成“字体 native 内存”。Windows `flutter_tester` 不提供按字体归属的原生分配指标；Android PSS／native heap 及低内存设备稳定性尚未验证。
- 2026-10-22 全目录压力实验 PID 35520 注册 869 个唯一资源／203,056,088 B 后，五轮返回无新增注册。基线 RSS 244,682,752 B，五轮为 480,722,944、476,827,648、481,263,616、478,490,624、485,015,552 B，峰值 507,187,200 B。第五轮 Dart heapUsage 125,095,152 B／externalUsage 132,176 B；VM 未归属 RSS 308,744,192 B（基线 71,344,128 B），其中仍混合引擎、字体及图形。全目录驻留有明显成本，不能据此承诺低内存 Android 安全；应用不执行这种全目录预加载。

机器记录位于 `.dart_tool/thread-font-native-memory/core29-30844.json`、`typical29-5844.json` 和 `all-assets-35520.json`；后两者包含各阶段 OS WorkingSet／PrivateBytes、Dart heap／external 和 VM process breakdown。日志 `.dart_tool/thread-font-native-memory-core-retest.log`、`.dart_tool/thread-font-native-memory-typical.log`、`.dart_tool/thread-font-native-memory-all.log`。初次实验因 PowerShell 可执行路径未解析失败，原日志保留，修为绝对路径后通过。

## 独立验证及剩余工作

2026-10-22 DotGothic 定位：原预览把手动推进的时钟与真实文件 I/O 混用，500 轮结束时缺片请求尚未完成，不能据此断言生产死锁。改用真实 `Stopwatch`、每款 2 分钟有界等待，并通过 `tester.runAsync` 让真实事件循环推进，源码摘要 `2d941dcb83c96ce83971ef53e962d6a822a873753101d38e032ef6678fd7950f` 的旧目录诊断已完成 DotGothic 的三片注册与截图，路径 `.dart_tool/thread-font-product-flow-r5/continuous-clock/dotgothic16.png`。该诊断在完成定位后主动停止，没有跑完整 29 款及五轮返回；不冒称最终 28 款验证。下一轮工具记录每个文件读取完成时间、完成字节、每款注册完成时间和队列状态；Windows 截图中的系统字形替身不覆盖 emoji，不能冒称 Android 的默认字形效果。

通用进度期限及真实 loopback HTTP 已验证持续非空字节超过 15 秒后成功、停流超时、外部取消分类和 timer 清理。首次慢流测试的服务端缓冲使字节未实际流出，修正测试服务端 `bufferOutput=false` 后通过。正式接入已统一 transport 默认与服务／队列边界；旧 v1 总时限保留。生产 service/queue 的元数据、字体两条慢流回归在旧 15 秒包装下均失败（`.dart_tool/thread-font-progress-service-old-failure.log`），候选在 `.dart_tool/thread-font-28-core-tests.log` 的 80 项核心测试中通过。

14 条正式 `transferCases` 通过生产 Dio 流读取验证（`.dart_tool/thread-font-transfer-fixtures-eventloop.log`），覆盖响应头不续期、空块、迟到字节、总限、排队和三类取消。模拟流取消会经过真实事件队列，测试逐事件时点交替推进并等待，不能先将 fake 时钟推完；元数据超限在 2000 ms 准确拒绝。另有真实 HTTP 未 EOF 超限用例证明立即拒绝，不把模拟调度现象冒称生产挂起，日志 `.dart_tool/thread-font-limit-real-http.log`。

`test/core/text_fonts/text_font_download_window_test.dart` 与 `text_font_retry_ledger_test.dart` 覆盖跨十轮累计 240 MiB、超过旧请求额度继续、失败尝试不退额、原件入普通窗口、时钟倒退保护、full jitter／Retry-After 和隔离。队列测试覆盖同 SHA 多 family 合并下载、逐键原生失败、独立坏 SHA、429、离屏与撤回。策略测试逐项消费正式拒绝与抖动夹具；服务测试覆盖目录/policy/manifest 独立失败、完全无缓存冷启动、前台唤醒、元数据同窗、取消与新需求竞态、缓存不可写。真实 loopback HTTP 测试经过生产 `TextFontTransport`，验证响应头 MIME、JSON 声明、UUID、无 Authorization 和 64 KiB 流式上限。它们使用测试夹具，不代表公网部署或真机验收。

独立 Android 默认网络事件通道使用 `registerDefaultNetworkCallback` 与能力回调，按订阅注册、取消及引擎清理注销，不探测公网；`ACCESS_NETWORK_STATE` 为普通权限，无新增请求 UI。网络能力仅作唤醒提示，不决定目标可达性。原生代码已随本次产品 APK 编译通过，网络事件的实际真机行为仍待负责人验证。

独立 Android FontLab 已构建 ARM64 APK，包名 `site.wenyou.fontlab`，版本 `1.0.0+1`，SHA-256 `479af084706ec89e2f5fa361f571c38f437d6c5a57158efb35be55f52fbfa21d`。本地保存 `.dart_tool/thread-font-native-memory/android/fontlab-arm64-479af084706e.apk` 和 `candidate.json` 来源清单。设备 `4b9c39b5` 首次安装返回 `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`；用户明确允许后重试一次成功，设备更新时间为 2026-10-22 00:48:56，设备内 APK 哈希一致。未更改系统网络、未触碰现有温油站应用。此实验包离线捆绑资源仅用于测量，不是产品 APK，不能作为生产 service/scope 的验收结果。

Android 两个独立实验进程均完成同进程 29 款首轮及五轮返回。typical PID 29576：65 个资源／62,125,436 B，返回五轮无新增注册；nativeHeapAllocatedBytes 基线 45,149,440 B，第五轮 136,379,808 B；RSS 基线 508,956,672 B，峰值 655,941,632 B；PSS 基线 421,225 KiB，第五轮 504,104 KiB。all PID 12326：869 个资源／203,056,088 B，五轮无新增注册；native heap 基线 46,467,008 B，第五轮 349,269,040 B；RSS 基线 524,890,112 B，峰值 872,099,840 B；PSS 基线 448,684 KiB，第五轮 728,593 KiB。

两组均在采样前做 Dart GC。第五轮 Dart externalUsage 均为 5,034,112 B，包含实验 manifest 等开销，没有长期持有全部字体输入。native heap、RSS 和 PSS 均有波动，含引擎、调试和图形开销，不是字体专属分配。完整资源压力的成本明显，不能外推低内存 Android 安全。移除 Widget 与 Dart 注册表后 native heap 仍分别约 136.6／350.0 MB；不能假装卸载。真实 JSON、同期 `dumpsys meminfo` 和 PNG 位于上述 android 目录。末帧截图仅展示移除自定义 Widget 后的默认文字和测量完成状态，不是字体效果验收。实验后已停止自有 FontLab 进程，保留安装与数据。

## 当前 28 款生产组件预览

应用源码摘要 `bcb1f6cc5f3717d75b5f5a490dc8fc896f33eab8860caf28f5494123558a6392`（2000 个应用输入文件，不是 Git SHA），真实 `TextFontService`／`TextFontScope`／`FontLoader` 同进程 28 款及五轮返回通过，实际历时约 4 分 11 秒。共 64 个原生注册键、43,714,836 B 输入；128 次请求含 122 次字体或声明资源请求，任意 60 秒最高 40 次、25,012,076 B，满足 64 次／24 MiB。返回五轮均无新增注册和资产请求。目录、manifest 和 policy 各一次暂时失败后，在原正文自动恢复；默认入口零字体请求。请求包含开始／完成单调时间与完成字节，逐款记录注册和队列状态。证据与 32 张原始 PNG：`.dart_tool/thread-font-product-flow-r5/continuous-28/`，本地 `index.html` 可按中文 12／日文 10／英文 6 筛选。

该预览使用本地正式字节和受控失败注入，没有业务账号、HTTP 或写入。Windows 默认字形替身只加载思源黑体 core：“嗷”（U+55F7）实际属于 `u005000`，emoji U+1F600 不在该字库；部分假名也不在 core。因此图中方框或缺字是测试宿主回退覆盖不足，不能作为 Android 回退或全部字符覆盖通过。Android 三语言离线样例另见下节解锁后截图。Windows 测量包含这份独立替身，不混入生产注册账本。

## 当前 28 款 Android 常用集合

独立包版本 `1.0.0+2`，APK SHA `06a42eae515e20ab933db98c77b1ccb1885e2e065eb9180e2e4df8dca088dd07`，设备更新时间 2026-10-22 01:31:09，设备内 APK 哈希一致。PID 24503 加载 64 个资源／43,714,836 B，全部 28 款首轮及五轮返回无新增注册。基线 native heap 44,160,496 B，第五轮 116,565,776 B；RSS 基线 530,214,912 B，第五轮 635,293,696 B，峰值 665,374,720 B；PSS 基线 443,045 KiB，第五轮 521,563 KiB。第五轮 Dart heap 146,105,056 B、external 4,944,240 B。清空 Widget 与注册表后 native heap 116,874,464 B，仍不能声称卸载。原始结果 `.dart_tool/thread-font-native-memory/android28/typical-24503.json`，同期 meminfo 及完成页另存；此页只证明测量完成。该实验进程已停止，数据保留。

三语言效果专用包 `1.0.0+3`，APK 与设备内 SHA 均为 `35c8a441e3de5db87a4f9d694174136e6f2fd4849b0f39dbe29a9547e5a3c427`，更新时间 2026-10-22 01:36:54；`visual` 模式只加载流江毛草、DotGothic16、Great Vibes 并保留画面，不重复内存压力实验。2026-10-22 03:03（Asia/Shanghai）负责人解锁后，重新启动独立实验包的 visual 模式，PID 31802，复核设备内 APK 哈希一致。原始 1200×2608 PNG 位于 `.dart_tool/thread-font-native-memory/android28/visual-three-fonts-unlocked.png`，210,441 B，SHA-256 `3a973a01e1c709214c642ca6e319db9cd306f2ac5c9957fc8be1444603876cb3`。人工查看截图可见流江毛草中文草书、DotGothic16 日文点阵、Great Vibes 英文花体；样例假名、重音字符与 emoji 均可见，未见方框。此结论仅覆盖图中样例，不代表全部字符或产品流程验收。保留实验页供负责人查看，原锁屏黑图不计入效果证据。

剩余：Android 生产网络事件与负责人真机验收。三语言离线效果图已补齐；最终完整门禁与产品 APK 结果见文末，它们不能替代真机验收。公网 5.40／build `6e00c4031a8f970609eef8cbf6fdefe3e6b12126` 尚未部署新契约，完整门禁会如实保留该失败，不宣称全绿。历史 APK、旧源码截图与原生实验不能代替本轮生产链证据。

## 最终粘贴边界与源码对应

边界回归按正式历史字体语义构造输入 `<span data-wenyou-font-v1="xiaocheng-lafeng" data-wenyou-color-v1="#D14343">**来源**</span>`，通过站内 HTML 或同账号内部 Delta 粘贴到空主题，预期新增范围默认字体且保留文字、颜色、粗体；旧实现保留退役 ID，存在服务端拒绝新增范围的风险。另在历史字体 `甲乙` 中间、光标待输入字体为小城时粘贴现役 `wenkai`：旧 Quill 只把待输入字体覆盖到第一个字。逐字断言确认首字为小城、次字为文楷；整段样式交集返回 null 不能作为全部字均默认的证据。

候选只在粘贴计划中去掉退役 font，且 Delta 插入前清除待输入 font；不修改历史 Markdown 解码或全局白名单。新主题、原范围、文字与颜色/粗体、逐字字体、独立阅读语义、保存重开、撤销均已验证。恢复旧两处行为时 5 项精确回归失败（`.dart_tool/thread-font-retired-paste-exact-old-failure.log`）；候选 73 项通过（`.dart_tool/thread-font-retired-paste-final-test.log`），实际执行：

- `test/features/editor/editor_text_font_paste_scope_test.dart`
- `test/features/editor/editor_clipboard_test.dart`
- `test/features/editor/editor_clipboard_contract_test.dart`
- `test/features/editor/editor_atomic_clipboard_test.dart`
- `test/features/editor/editor_text_font_session_test.dart`
- `test/features/editor/editor_text_color_caret_paste_test.dart`
- `test/features/editor/editor_text_color_multiline_input_test.dart`

最终候选应用源码摘要 **`3c4b40b6cf92822e07fc741878f74dc91799d8888e1885c9eec3ea450d2a0030`**（2000 个文件）。与预览摘要 `bcb1f6cc5f3717d75b5f5a490dc8fc896f33eab8860caf28f5494123558a6392` 精确比较只有两处应用文件变化：

| 文件 | 预览时 SHA-256 | 最终候选 SHA-256 |
| --- | --- | --- |
| `lib/features/editor/presentation/editor_clipboard_paste.dart` | `d6a92ca035e16c871ce682999e70013cbb16085f64b626eda4313f04e86d0e03` | `f96788960c57bfc2c288f9b8f18f42d067857b7dd550c21cfb662b674a26f44a` |
| `lib/features/editor/presentation/literal_text_quill_controller.dart` | `463e98f792bbda8bb6f49b2fae6617ef35e9535ace762e34629666dc5462c787` | `9a97ed6155ee67c5da2eeceef1efbcec640ddd179e45e24f7cb3e93d9ff2af66` |

机器差异清单 `.dart_tool/thread-font-final-source-delta.json` 与两份完整 manifest 保留；加载、内存实验和截图继续绑定各自原始来源，不重复执行或改标成最终源码。上述粘贴测试是本地受控输入，没有向线上发送新增或编辑请求；负责人原场景复验仍待进行。

最终完整入口：`npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，日志 `.dart_tool/thread-font-continuous-28-final-gate-apk.log`。此前 `.dart_tool/thread-font-continuous-28-gate-apk.log` 在全量应用分析通过后因粘贴修正主动停止，未作为完整门禁通过记录。

## 负责人待验收清单

前提：使用本次候选源码或对应 APK、明确包名 `site.wenyou.app.debug`，且负责人选择的环境已具备 5.42 字体能力与正式对象资源。当前公网未就绪，自动化未执行任何发帖、修改或上传。下列写入由负责人在授权环境操作；本地构造回归不代替负责人实际输入及原场景。

1. 在同一会话连续浏览全部现役字体并返回旧正文，检查后台自动加载、系统回退、滚动与选区；冷缓存暂时失败后无手动重试也能恢复。检查离屏、后台后停止无用请求，恢复前台后继续有效需求。
2. 列表、搜索、消息、动态、角色弹层和楼层回复预览保持默认字体；打开完整主题／子贴／楼层／展开回复才应用指定字体，正文存储保持原样。
3. 打开历史小城正文，先只改无关内容保存、再重开，确认原文字及历史范围不被清洗。从中复制到空主题和现役字体区段，确认新增文字默认显示且保留颜色、粗体；保存重开后无新增小城范围。
4. 在历史小城光标处粘贴文楷片段，逐字检查首字及后续字均为文楷，左右历史正文不变；撤销恢复原稿。HTML 和应用内复制两条路径分别检查。
5. 复制带字体、颜色及传送门的正文到动态、评论、私聊，检查目标默认文字、传送门地址、撤销与保存；外部和纯文本按原边界处理。
6. Android 产品内三语言效果、系统缺字/emoji 回退、网络能力事件、窄屏/大字号及低内存机稳定性尚未由负责人验收。离线 FontLab 三语言样例截图已补齐；内存实验或离线截图不代替产品验收。

前一轮最终门禁 `.dart_tool/thread-font-continuous-28-final-gate-apk.log` 在全量测试 3:23、1702 通过／1 跳过／2 失败时停止。两条失败均为契约同步后未更新的测试事实：历史 ID 集合错误地等于现役目录、错误码测试仍硬编码 5.41 与旧 Backend revision。分别改为现役 28 + 退役档案 ID、正式 5.42/f278 来源；没有修改应用源码、生产契约或删除历史 ID。两个测试文件定向复验 23 项通过，日志 `.dart_tool/thread-font-28-contract-assertions-test.log`。应用摘要及已通过分析、加载、内存证据不变。完整入口重新执行于 `.dart_tool/thread-font-continuous-28-delivery-gate-apk.log`，不把中断轮次冒充全量通过。

2026-10-22 02:45 补充设备状态：ADB 已无法找到设备 `4b9c39b5`。此前独立实验包安装、设备内哈希及内存结果保留；效果画面仍未采集，无法确认效果模式进程已停止。没有重连其他设备、重启 ADB 服务或操作现有温油站包。该断连不影响 Windows 门禁与 APK 文件交付。

2026-10-22 03:03 状态更新：负责人确认解锁，设备重新可见且 Awake。首次截图为 typical 完成页，另存 `completion-observed-after-unlock.png`，不作为字体效果图；停止本任务独立实验包后，以 visual 参数重新启动，取得上述三语言效果图。仅更新记录，产品候选仍为 `ea13223c3ad81964797d4879e2d353e463a40e66`，应用源码与 APK 未变。

## 本轮完整门禁与产品 APK

2026-10-22 最终完整入口 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2` 已结束，整体 **exit code 1，唯一失败为公网契约兼容性检查**。日志 `.dart_tool/thread-font-continuous-28-delivery-gate-apk.log`：

| 检查 | 实际结果 |
| --- | --- |
| OpenAPI 校验、固定来源、再生成一致性 | 通过，生成文件无漂移 |
| 全仓 Dart 格式 | 1479 文件，0 修改 |
| 应用 / 生成客户端全量分析 | 均零问题 |
| 架构 / 模块文档 / API 覆盖 | 通过；23 模块，175/175，0 missing，75 明确排除 |
| 全量 Flutter 测试 | `test/` 全目录，7,558 通过、1 跳过、0 失败，30:21；跳过线上诊断回执，未发送 |
| Windows 发布工具测试 | 49/49 通过，0 跳过，约 109 秒 |
| Android Debug 构建 | 通过，Gradle 104.3 秒；既有图片插件 KGP 未来版本警告未阻断本次构建 |
| 公网兼容性 | 失败：实际 5.40/6e00 与本地 5.42/f278 不匹配；未部署或规避检查 |

产品 APK 保存于 `build/thread-fonts-continuous-28-candidate/app-thread-fonts-28-7586af998e3b-debug.apk`，**113,087,698 B**，SHA-256 **`7586af998e3be48dd6c7c8915da8ae45ffa9f76ee3d83092dd711e87f3c128a1`**。实际包名 `site.wenyou.app.debug`，versionName `0.10.0-debug`，versionCode `100`，仅 `arm64-v8a`，APK v2 签名验证通过。包内字体文件只有既有 Material Icons，没有捆入28款正文自定义字体。相较旧 r5 APK 增加 158,820 B。

构建后重算2000个应用输入文件，源码摘要仍为 **`3c4b40b6cf92822e07fc741878f74dc91799d8888e1885c9eec3ea450d2a0030`**。同目录 `source-manifest.json`、`evidence.json` 记录来源、包身份、签名与条目；构建时未传 API define，实际默认 `https://wenyou.site/api/v1`。由于公网能力和资源未就绪，不能以当前公网回退画面通过字体端到端验收。

本产品 APK 未安装；独立 FontLab 安装不等于产品 APK 安装。未合并、部署、发布、打 Tag，未执行线上业务写入。原始日志、旧候选及失败记录均保留；候选仍待负责人原场景验收。

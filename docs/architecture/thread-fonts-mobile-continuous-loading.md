# 正文字体持续加载设计与验证

状态：负责人于2026-10-24确认“这版可以”，授权检查通过后合并相关字体 PR、部署兼容后端与 Web，并交付更新的公网 Debug APK。此前显示等待已由负责人说明为“只是单纯网络延迟”。本次认可对应 Mobile `addfc4fd8a12c77c2168d20ff7357a4573ae6790`；没有新增 Android 真机操作记录，不把合并授权写成已执行的设备测试。此前固定28款实验及隔离候选仅属于历史证据。

### 负责人认可与合并交付（2026-10-24）

安全修复 PR #60 合并后的最终部署目标为 `f1025db4ef0d4986f53a4beffac6514d7ee16357`，HTTP仍为5.44 .2；再次经正式脚本同步该来源。其 contracts/ 相对2b8abf3零差异，额外变更只有未纳入Mobile同步范围的邮件安全说明。生成客户端与应用源码不变，公网精确SHA检查等待healthy通知后执行。

兼容后端 PR #58 合并为 `5faf0566bb30ac8157e15a11e9deddabd388fe5a`。已核对其 contracts/ 与 docs/ 相对已验证任务提交2b8abf3零差异，并通过正式同步脚本将精确来源固定到该合并提交；HTTP仍为5.44 .2，应用源码与生成客户端未变化，无需重复生成。模块来源和精确断言同步更新，公网检查等待实际部署后执行。

沿用 PR #114，合并前核对 dev、候选源码和既有检查证据；最终应用源码摘要仍为 `5c0452367ef9655867e65c308ec477b301c727a0a79f8053926a7c56ef99483d`。待兼容后端上线后重新执行公网精确契约检查，不把此前5.43差异改标为通过。合并后只从干净且与 origin/dev 一致的源码构建直连 `https://wenyou.site/api/v1` 的 Debug APK，核验原 Debug 证书、包名及哈希并保存独立交付目录；不自动安装或发布正式版。合并和最终产物证据随交付保存，历史失败及候选记录保留原归属。

## 动态字体生产接入（候选，待真机验收）

### 服务端目录顺序与 HTTP 5.44（2026-10-24，候选）

动态字体列表现在仅按语言过滤服务端完整目录，不再让本机最近使用记录或本地比较器改变顺序；选中字体保留标记。目录在同一版本 ID 下更新 revision 和位置时，原面板刷新顺序并保留手选语言、选中标记、缓存、下载窗口及原生注册账本。旧 v1 最近使用历史继续保留。

首轮同步 Backend `832a3989be7aac22c803a6375e756bea745b443f`／HTTP `5.44.0-dev.20261024.1` 并运行完整门禁；最终同步 `2b8abf3b6ae23c94dd843dfd6ce72865554a657e`／HTTP `5.44.0-dev.20261024.2`。Foundation 仍固定最新正式 Tag v7.6.0。新增5个后台管理操作纳入既有 `admin_product` 排除；公开字体 v2 协议没有变化。最终来源已实现后台管理，本任务未独立执行后台端到端验收。

直接消费 `contracts/admin-font-management-v1-fixtures.json` 的 `two-language-atomic`：期望顺序来自夹具中的两组数组，同版本目录从 revision 7 更新为8，检查中文、日文顺序以及已打开面板的手选语言保持。首轮 .1 夹具与其 Backend Git blob 逐字节一致，SHA-256 为 `50b961e762e9ff85bfc278aeae43ba42cc443eb3b8536e9e8497067881e14b93`。受控公开响应按契约的 sortOrder/familyId 顺序返回，不以待测 UI 比较器生成期望。

开发反馈证据：`editor_dynamic_font_order_test.dart` 的最初两条跨页／同 ID 重排用例在原实现均失败（`.dart_tool/font-order-old-regression.log`），候选通过。正式夹具到达前，以下8个直接相关文件共45项通过（`.dart_tool/font-order-targeted-tests.log`）：

- `test/features/editor/editor_dynamic_font_order_test.dart`
- `test/features/editor/editor_dynamic_font_list_test.dart`
- `test/features/editor/editor_dynamic_font_toolbar_test.dart`
- `test/features/editor/editor_text_font_picker_test.dart`
- `test/features/editor/editor_font_panel_test.dart`
- `test/core/text_fonts/dynamic_font_catalog_test.dart`
- `test/core/text_fonts/dynamic_font_runtime_test.dart`
- `test/core/text_fonts/dynamic_font_service_test.dart`

接入正式夹具和5.44生成客户端后，排序文件、运行时文件及 `test/core/network/audio_budget_contract_test.dart` 三文件共15项通过（`.dart_tool/font-order-544-preflight.log`）。完整门禁结果如下；此前 APK 和测试计数不改标为最终 .2 结果。

首轮唯一入口 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`（`.dart_tool/font-order-544-final-gate.log`）返回 exit 1，仅公网兼容失败：固定5.44 .1／832a3989，实际5.43 .3／`bc1135b72557eb6025a541dbd10119cf528ff989`。其余全部通过：OpenAPI、固定来源、生成一致性、1520文件格式零改动、应用与生成客户端全量静态分析、架构、23模块文档、移动端API覆盖175/175（96排除）、全量Flutter **7701通过／1既有跳过／0失败（56:10）**、Windows工具 **49/49**、ARM64 Debug构建（315.6秒）。

首轮应用源码摘要 `05064e79bc6eef86d7bb4f6249702bd65defe380f752a3c54d2d9524b6b3cae0`（2112文件），构建前后相同；APK `build/dynamic-font-public-candidate/wenyou-font-order-debug-1bae4ab89f93.apk`，156238595字节，SHA-256 `1bae4ab89f93e71ef382017d7ded40a2ac954935489b6bffabfaa025735d6fc3`。身份、v2签名、arm64-v8a和公网API核验通过，仅包含既有Material Icons字体，未安装。该包只代表 .1 完整门禁，不作为最终交付包。

最终 .2 来源固定为 `2b8abf3b6ae23c94dd843dfd6ce72865554a657e`，其 OpenAPI 与管理夹具同兼容契约提交 `1ce559b42be9ac04c4fd09137ee30f482facbfe2` 逐字一致；正式同步的管理夹具 SHA-256 为 `16bc40f293a82230f2d8dfe38d4d30de17ea7417162136ba6b6c6601a63e8d62`。相对首轮 .1 只有版本和可空 `FontJobDto.submissionId` 的生成模型／序列化代码变化，移动端运行逻辑、公开协议及 Android 配置不变。按最终交接约定复验实际增量，没有机械重复全量 Flutter；7701 项结果仍只绑定首轮源码。

最终增量日志 `.dart_tool/font-order-5442-increment.log`：OpenAPI 校验、正式来源、再生成一致性、1521文件格式零修改、应用与生成客户端全量静态分析、架构、23模块文档、API覆盖175/175（96排除）、同步工具回归1/1及最终ARM64 Debug构建（52.0秒）通过。以下4个文件共 **19/19** 通过：

- `test/features/editor/editor_dynamic_font_order_test.dart`
- `test/core/text_fonts/dynamic_font_runtime_test.dart`
- `test/core/network/audio_budget_contract_test.dart`
- `test/core/network/admin_font_management_contract_test.dart`

新增 DTO 文件消费正式 `jobRecoveryCases`，验证缺省、空值及具体任务关联值的编解码；不宣称实现移动端后台处理入口。公网复验仍为实际5.43 .3／bc1135b，与最终5.44 .2／2b8abf3不同，增量总结果保留 exit 1，仅该项失败，没有部署或放宽断言。

**最终候选包**：`build/dynamic-font-public-candidate/wenyou-font-order-debug-4bf62837e69c.apk`，156227566字节，SHA-256 **`4bf62837e69c6789634215a2cfdfe974f3ce6920817d98be8fecae858479e6f0`**。应用源码摘要 **`5c0452367ef9655867e65c308ec477b301c727a0a79f8053926a7c56ef99483d`**，2112文件，构建前后相同。包名 `site.wenyou.app.debug`，版本 `0.10.0-debug / 100`，仅arm64-v8a，v2签名通过且证书与前版Debug相同；kernel含公网API、无原电脑转发端点，内置字体仅Material Icons。源码和制品清单分别为 `.dart_tool/font-order-5442-source.json`、`font-order-5442-apk.json`；未安装或启动。

负责人待验收路径：在授权的可用后台环境中，同语言内置顶、上移、下移并保存；移动端重新打开字体面板或触发目录刷新，核对各语言顺序及选中标记；原面板刷新时检查语言保持，已加载字体继续可用。负责人已确认龙藏体、流江毛草此前两种操作的显示等待只是网络延迟；不再要求提供原文。新候选的排序、进度和键盘效果仍待真机验收。当前 ADB 无设备，本批未安装、启动或进行线上业务写入。

### PR #114 提交前完整检查（2026-10-23）

负责人要求先提交 PR，本轮沿用原任务分支及 Draft PR #114；仍待龙藏体、流江毛草两种原操作的负责人真机验收。Foundation fetch 后最新正式版本仍为 v7.6.0。通过 `tool/sync_backend_contract.ps1` 正式同步已部署 Backend `1902aa4f844f47e3b867806ec7d6fe845b02f267`，API 保持 `5.43.0-dev.20261022.3`；契约内容及生成客户端无语义变化。来源、23份模块记录与精确来源断言归入独立 chore，不放宽检查。

完整入口实际执行 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，原始日志 `.dart_tool/font-pr114-final-gate.log` 保留 **exit code 1**：

| 检查 | 本轮实际结果 |
| --- | --- |
| OpenAPI、固定来源、再生成一致性、公网精确兼容 | 通过；公网版本及 build SHA 与固定来源一致 |
| Dart 格式 | 1519 文件，0 修改 |
| 应用与生成客户端全量分析、架构、API 覆盖 | 通过；175/175，0 missing，91 明确排除 |
| 全量 Flutter `test/` | 34:55，7696 通过、1 跳过、1 失败；跳过线上诊断回执，未发送 |
| 模块文档 | 首轮失败：22份记录缺少新来源提交号 |
| Windows 发布工具 | 49/49 通过，0 跳过 |
| Android ARM64 Debug | 构建通过，Gradle 68.8秒 |

唯一失败测试 `test/core/network/audio_budget_contract_test.dart` 仍断言旧 Backend `62a0313…`，已将期望精确更新到1902；同时同步23份模块当前来源记录。补充复验通过：该断言文件格式无修改、静态零问题、精确测试1/1通过、23模块文档完整，日志 `.dart_tool/font-pr114-contract-followup-{analyze,test,docs}.log`。保留整轮失败，不将后续修正写成一次全绿；应用源码未变，不机械重复其余已通过的数千项测试。

最终应用源码摘要 **`7116c576dfd215f55262d80e65fd4a453c142aaaebf1dd0557bc32c1c3ebb435`**，2084个输入文件，构建前后相同。产品候选 `build/dynamic-font-public-candidate/wenyou-font-progress-debug-4af91771b8c1.apk`，156088060字节，SHA-256 **`4af91771b8c14b30e16e81d7c178b568e2b3e29df3ab120ebd74c39c2ec0a2d7`**；包名 `site.wenyou.app.debug`，`0.10.0-debug`／100，仅arm64-v8a，v2签名通过且与上一Debug证书相同。包内字体仅既有Material Icons，实际kernel包含公网API且无原电脑转发端点；未安装或启动产品包。

应用来源、APK身份与签名记录为 `.dart_tool/font-pr114-final-source.json`、`font-pr114-final-apk.json`、`font-pr114-apk-{badging,signature}.log`。此前离线截图、压力实验和APK保留原来源，不改标为本轮Android验收。负责人仍需用当前候选复验原文的先选后输入、选区更换、完成加载后再次选择、默认恢复、真实IME及横屏大字号键盘；未取得原文、等待时长和手机日志，不能宣称原问题完成。

### 进度、键盘与密度反馈批次（2026-10-22，视觉候选）

开发反馈阶段沿用上一候选源码，执行定向测试、修改文件静态及离线组件截图；当时未重跑完整门禁或生成 APK。随后按负责人“先提交 PR”的要求进入完整交付检查，结果另行记录。上一 APK `3e40d2de0edb…` 不含本批进度与首字订阅修正，不能用于代表当前画面。

`TextFontProgressLedger` 独立于 runtime/queue 的字体就绪通知，按资产去重，先核验当前需求缓存再计算缺失总量，网络分块节流 100ms。未收到完整字节不提前给出完成，收到全部字节仍等待校验及原生注册；重试重新计数，取消后忽略迟到字节，终态／撤回停止转动。作者意图由 `LiteralTextQuillController` 的当前会话状态承载；仅显式选择激活，正文尚无字符时静默，不参与保存或协议。

首字回归使用 `A` 和真实 Quill IME 输入：先选字体后输入时，控制器先发光标通知，再用 `document.compose` 补字体属性；只监听控制器的旧组件没有调用 retain（`.dart_tool/font-progress-widget-debug.log` 保留失败），直到后续操作才可能收集需求。新增文档流订阅后，首字无需下一次输入即可收集；测试同时检查下载分块不替换 Quill Widget/State、不改变 selection 与组合输入状态，已有选区换字体路径单独覆盖。原文与真机日志仍缺失，不能将此受控现象视为原问题的唯一根因或验收通过。

截图由真实 Flutter 组件产生，使用已验证 28 款 PNG 样张；进度通过受控字节流与原生注册完成点呈现，另用测试默认字体替身制作可读正文截图，不宣称该替身为动态字库渲染效果。键盘高度为模拟 `viewInsets`，ADB 当前为空。应用源码摘要、精确测试路径与计数、图片哈希及未覆盖项汇总到 `.dart_tool/font-progress-ui-candidate-evidence.json`。

初轮定向测试为 38 文件、345 项通过；可读进度捕获另有 3 项通过。后续仅处理已知横屏失败：640×400、双倍字号、180 键盘 inset 下，报错创建点为 `.dart_tool/font-visual-capture_test.dart:71` 的 Scaffold 正文 Column，创建链为 `Column ← KeyedSubtree ← _BodyBuilder ← MediaQuery ← LayoutId(body)`，实际最大高度 164px（400−56−180），T 托盘与主栏自然高度 169px，溢出5px。完整诊断保存在 `.dart_tool/font-progress-landscape-diagnosis.log`。

截图宿主原来没有传递生产主题页和帖子编辑器已有的 `EditorToolArea.availableHeight`；补齐这项真实父约束后，新增精确回归仍证实共享 T 组件缺少主栏空间预留，因此不是只修饰截图。`WenyouEditorToolbar._buildHeadingTray` 现在按真实剩余高度扣除主栏（含独立草稿行），短屏时 T 托盘纵向可滚动，主栏保持可操作；取色盘继续沿用自身已有约束。未更改正常密度或字号。旧回归失败见 `.dart_tool/font-progress-landscape-old-regression.log`；修正后精确布局、动态字体工具栏、颜色流程三个文件8项通过；仅新增两文件静态检查，不重跑345项。

同一640×400/2x/180截图用例现已通过，弹层、整体宿主无溢出（`.dart_tool/font-progress-landscape-fixed-capture.log`），旧失败日志保留。至此七组离线布局检查均通过；Android 原生键盘仍待真机验证。最新源码摘要与增量检查单独记入同一 evidence，初轮345项绑定其原源码摘要，不冒称全部在补丁后重跑。

提交前自查补充两项精确回归：必需声明资源校验失败时，即使该资源不计入字体字节总量，也通知进度订阅进入失败终态，避免停留在等待中；T 托盘进入自定义取色盘时保留同一约束组件层级，避免重建状态导致 RGB 面板没有打开。旧实现分别在 `.dart_tool/font-progress-notice-old-regression.log` 和 `.dart_tool/font-progress-color-old-regression.log` 失败；修正后进度文件7项、640×400键盘布局及打开／取消 RGB 场景1项通过。后续完整门禁包含这些正式测试。

### 首次应用延迟与迟到需求调度（2026-10-22，候选／待负责人真机验收）

原场景：负责人使用公网 Debug `wenyou-font-list-debug-9186d10d5e31.apk`，龙藏体、流江毛草选择后正文暂未变化，站酷快乐体立即生效；重开 T → 字体仍显示正确选中。负责人确认“先选后输入”和“选区更换”均出现，随后补充等待较久后最终显示。未取得原始文字、精确等待时长或手机日志，不能把本次受控竞态等同于原场景的唯一根因，也不将最终显示记为负责人验收通过。

公开资源的独立只读检查确认三款 manifest 与 core SFNT 的 SHA／长度正确。站酷快乐体 core 为 759396 B，龙藏体 2663364 B，流江毛草 2583732 B，后两者约大 3.4–3.5 倍；各 core 覆盖约 3869 字。Windows 顺序 GET 为 4.13／4.74／6.49 秒，仅说明该网络上的冷下载，不代表手机速度。证据在 `D:/code/wenyousite/.artifacts/thread-fonts-dynamic-20261022/font-bug-{1,2,3}-{descriptor.json,manifest.json,core.ttf}`。

受控复现独立于公网：使用已有 fixture 的字符 `A`，暂停第一款描述符响应；随后在同一 owner 切换到第二款或新增另一 owner。旧 `load()` 共用在途 Future，但 `dynamic.refresh()` 已收集身份快照，后续只设置 `_dynamicDirty`，完成后未安排跟进；第一款可注册，第二款未请求，需等下一事件或五分钟定时。第二个缺口是动态模式的快路径仍依赖旧版 `_policyJson`／`_catalogDue`，同字体文字增长也进入元数据事务，等待当前字库结束。

候选仅修改 `TextFontService`：新增身份才使动态元数据失效，已有身份的文字增长直接更新分片队列；动态快路径使用已验证队列与下一重验时刻；成功完成本轮后若仍有新身份，则通过既有调度器安排即时跟进。没有在串行事务里递归等待，不增加并发、不重置额度、不清账本、不跳过 Retry-After 或撤回状态。关闭、离线和无订阅继续由既有调度条件阻止请求；未到期的负缓存和终态版本不会形成循环。已认可字体列表 UI、入口与光标/选区语义保持，不新增加载状态 UI。

`test/core/text_fonts/dynamic_font_service_test.dart` 的旧实现回归为5失败／5通过，候选为10通过，日志分别为 `.dart_tool/font-late-demand-old-regression.log` 与 `.dart_tool/font-late-demand-fixed-regression.log`。覆盖同 owner／多 owner 迟到需求、纯文字增长不暂停下载、离线恢复、释放订阅、404 与撤回、并发1及窗口仍保留占用。初步诊断 `.dart_tool/font-delay-diagnostic.log` 使用构造样例，不代表已复现用户原文。

本轮按指定快速候选入口执行整个 `test/core/text_fonts/` 及阅读作用域／编辑器字体与颜色回归，明确参数保存在 `.dart_tool/font-late-demand-test-paths.json`。最终源码、构建及真机待验收记录在 `.dart_tool/font-late-demand-public-apk-evidence.json` 统一交付；旧 `9186d10d5e31…` 与 `dd14d5a9…` 包均保留，不自动安装或启动公网应用，不合并或部署。


本轮最终候选入口成功：1514 文件格式检查、应用与生成客户端全量静态检查零问题，36 个明确测试文件共 335 项通过，ARM64 Debug 构建成功；架构和 23 模块文档检查通过。实际测试参数、展开文件路径与日志均写入 `.dart_tool/font-late-demand-public-apk-evidence.json`。

新包为 `build/dynamic-font-public-candidate/wenyou-font-demand-debug-3e40d2de0edb.apk`，156063850 字节，SHA-256 `3e40d2de0edb2c7e1fb260132edb9c8a957eabefcff5129515a74e5d69b0e514`；包名 `site.wenyou.app.debug`，`0.10.0-debug`／100，仅 arm64-v8a。APK v2 签名验证通过，与 `9186d10d5e31…` 包证书一致，可覆盖安装；两个旧公网包均保留。构建无 API override，环境与 Gradle 属性无相关覆盖，实际 kernel 包含 `https://wenyou.site/api/v1`，不含 `:38876` 端点，无需电脑转发。

最终应用源码摘要 `bd06f8d9a93e6afa5980716696f69bbafd9c920a359056d37d3dcbfcefc302cd`（2082 文件），构建前后相同；HEAD `4f25eee8d29594d8877d5139dd58e57c04c4fc55` 加本轮未提交改动。没有自动安装或启动公网应用、清数据、提交、推送、合并或部署。负责人应在新包复验龙藏体／流江毛草的两种操作、加载完成后再次选择、连续输入和恢复默认；仍为候选／待真机验收，不断言已排除用户手机全部下载等待。

### 字体列表视觉候选（2026-10-22，视觉方向已确认／待真机验收）

最终入口仍是 **T → 字体**，颜色同样留在 T 内；主工具栏、排序偏好与迁移没有变化。面板高度为屏幕的 72%，固定标题、关闭和默认恢复按钮。中／日／英分段仅显示对应字体；当前字体优先决定初始分类，迟到元数据只在用户未手选时对齐，有其他分类才增加第四段。

样张使用正式目录 28 款已校验 PNG。只对可见行解码，先检查编码字节不超过 2 MiB、单边不超过 2048、像素不超过 1048576；扫描所有非零 alpha 像素并留 4 像素安全边距。按宽高比绘制并使用主题文字色，无白色底卡、无固定文字框裁剪或原字体加载。释放 codec、descriptor、buffer 和临时像素引用，行销毁时释放 ui.Image，迟到解码不写入已销毁行。全透明、损坏或超限样张留出稳定占位，名称及选择可用。

320 宽普通字号的行高约 80 像素，首屏约 6 款；名称使用较小主题文字，样张区域保持 42 像素，加载前后不跳动。离线真实 Widget 截图覆盖 320 宽明暗、中日英和 360 宽双倍字号，保存于 `.dart_tool/font-visual-after/`，由 `.dart_tool/font-visual-capture_test.dart` 生成。它们不是 Android 真机截图。负责人已明确反馈“这版可以”，并要求提供更新后的公网 Debug 安装包。旧 APK `dd14d5a9…` 保留且不包含本次视觉改动；新包仅供自行安装复验，不自动安装或启动，不将视觉方向确认等同于真机验收通过。

定向检查、最终应用源码摘要及截图 SHA-256 统一记录在 `.dart_tool/font-visual-candidate-evidence.json`，源码清单为 `.dart_tool/font-visual-source.json`。视觉方向已于 2026-10-22 获负责人确认，手机真机画面未补拍，实际输入和字形效果待新包验收。架构复核将两处 Material 字号入口改为对应的既有语义文字样式，字号与布局保持一致。


本次公网 Debug 已由 `npm run candidate:apk -- <12 个字体／颜色相关测试文件> -TestConcurrency 2` 构建：1514 文件格式检查、应用与生成客户端全量静态检查、52 项定向测试全部通过；架构及 23 模块文档检查通过。最终源码另补拍 3 组真实 Widget 画面（明暗／双倍字号），共 15 张，保存在 `.dart_tool/font-visual-apk/`。

交付 `build/dynamic-font-public-candidate/wenyou-font-list-debug-9186d10d5e31.apk`，156063621 字节，SHA-256 `9186d10d5e31b2e7d4bd85324395227328b1ce4be95fba1aa1997e3224a0cf7d`；包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`／100，仅 arm64-v8a，APK v2 签名校验通过，与上一包签名证书一致，可覆盖安装。前一包 `wenyou-font-caret-debug-dd14d5a9f9d8.apk` 已保留并复核原 SHA-256。

最终应用源码摘要 `fa05663307290e505243cf32adac300cac06bbd7db04289dfae7ce5f27223d28`（2082 文件），基于 HEAD `4f25eee8d29594d8877d5139dd58e57c04c4fc55` 加本轮未提交改动；构建前后摘要一致。构建未传 API override，环境与 Gradle 属性无相关覆盖，使用 AppEnvironment 公网默认 `https://wenyou.site/api/v1`；实际 APK kernel 包含该完整地址且不含 `:38876` 端点，不依赖电脑转发。只读公网 `/meta` 仍为 `5.43.0-dev.20261022.3`／`1902aa4f844f47e3b867806ec7d6fe845b02f267`。没有自动安装、启动、清数据或修改公网服务。

最终稳定证据为 `.dart_tool/font-visual-public-apk-evidence.json`，包含包体、签名、源码、明确测试文件与日志、API 目标和截图哈希。负责人自行打开“温油站 Debug”，复验 T 内字体的中／日／英筛选、光标先选后输入、选区更换／恢复默认及取消后的选区保持；本轮只确认视觉方向，原问题及真机输入效果继续待验收，未提交、推送、合并或部署。

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

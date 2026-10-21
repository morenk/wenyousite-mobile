# 文本颜色 v1 候选验收

状态：视觉候选／待负责人验收。Windows 独立 Worktree `D:/codex-worktrees/mobile-text-color-v1/wenyousite-mobile`，任务分支 `codex/20261016-text-color-v1`，本批最终集成基线 `0b3bd047`（由初始 `17631a2c` 合入已批准的阅读空格修复，集成提交 `28f61b48`）。正式 Foundation `v7.4.0` 对应 `a03b5c24ea7dcdaa2ba07c962f58434bdb40965d`，独立依赖提交 `66b1a479`。后端精确同步来源见 `contracts/backend-contract.properties`。

范围为主题／子帖正文、楼层和回复。动态、私信和主题标题没有取色入口。根据负责人确认，跨应用系统剪贴板继续纯文本；App 内复制与 Web 站内 HTML v2 保留颜色。

## 离线画面和交互

- `test/features/posts/goldens/post_color_t_{320,360}_{light,dark}.png`：真实 PostComposer 页面与 Overlay，T 面板有默认、五预设、四最近、自定义；320dp 使用 1.5 倍字，360dp 使用标准字。
- `test/features/posts/goldens/post_color_rgb_keyboard_{320,360}_{light,dark}.png`：同一页面切换 RGB，模拟数字键盘 220dp inset；保留正文、应用／取消、输入及预览。空白键盘区为测试 inset，未绘制假系统键盘。
- `test/features/posts/goldens/post_color_rgb_keyboard_320x568_dark.png`：320×568、大字号和 320dp 键盘。RGB 使用实际 canvas 高度扣安全区，三通道、预览和应用可达；断言外层不可拖滚动偏移为零，底部由 RGB 内部滚动到达。
- `test/features/editor/goldens/thread_color_rgb_keyboard_320x568_dark.png`：真实主题正文页同样的短屏键盘。取色时保留标题等状态并暂收起附属区域，RGB 使用 AppBar 和状态区域之后的实际高度；短屏键盘展开时维持精简布局，收起键盘恢复标题与元信息。旧实现回归实证溢出 298px。
- `test/features/editor/goldens/editor_rgb_picker_{320,360}_{light,dark}.png`：独立面板，320dp 2 倍字。
- `test/core/widgets/goldens/markdown_text_color_320_{light,dark}.png`：混合彩色长段连续折行，标题与列表、组合格式和普通文字并排。

颜色范围保存、取消、默认、反向选区、跨段、实际提及／传送门 Delta 跳过、单步撤销／重做、后续中文 composing 输入、RGB 0/255/越界、混合色、账号存储隔离均由定向测试覆盖。颜色进入独立语义签名，不能过滤后误报保存。新写关闭时整组改色按钮禁用，避免局部去色形成后端不允许的新范围。

## 数据边界与未覆盖项

本轮 UI 测试使用内存仓储与 mocked SharedPreferences，不访问真实业务写接口。初次交付时 ADB 无设备；后续负责人连接 Xiaomi `4b9c39b5`，本任务独占该 Debug 包的安装／调试，未接管音频任务会话。旧版已由负责人手动启动；本次修复新包已完成完整门禁，并于 2026-10-18 在重新连接的手机覆盖安装、核对设备内 APK 哈希；原场景仍待负责人复验。组件 Golden 不替代真机画面；拖动取色、中文输入法、数字键盘切换、返回正文选区及半屏高度需要负责人验收。测试固定字体缺少部分 emoji，不代表平台字体实际效果。

负责人真机清单（兼容后端已获批部署并开启新写）：

1. 在主题、子帖、楼层和回复选中文字，打开 T；无选区时颜色禁用，混合颜色不预选。
2. 拖动取色并输入 RGB 的 0、255、越界值，确认正文仅在应用时变化；取消后原选区和正文焦点恢复，应用后一次撤销／重做恢复完整颜色范围。
3. 跨段选择中文、emoji、粗斜体、删除线、普通链接和代码，混入图片、骰子与提及；原子内容不着色，恢复默认只去颜色。
4. 展开数字键盘并返回中文输入法，检查 320/360dp、大字号、半屏以及短屏下按钮可达，后续输入不延续本次颜色；明暗切换仍是同一 RGB。
5. 发布、重新编辑、打开各类草稿，并在 Web 保存后回到 App；颜色与其他格式保持，切号后的最近色各自独立且最多四个。

普通 https 链接可与颜色和其他格式一起直接编辑。既有带 title 或相对地址普通链接继续阅读着色、按既有源码方式编辑或保护原文；无色与有色输入均经保源测试，本轮不扩展 Quill 的链接元数据模型。任意 CSS、事件属性和颜色嵌套不能扩大能力。旧端去色展示和覆盖拒绝由 Backend 测试负责；关闭新写的跨运行时语义保存由已提交消费者产物联验。

待确认的主题、楼层／回复及首次正文请求将颜色声明与原内容、幂等键一同持久化；能力读取变化不改变重试声明。旧快照缺失字段仍兼容，明确未声明与 v1 分别保留。

本地颜色能力校验拒绝使用稳定原因和展示映射，主题、回复及草稿面板显示准确提示并保留正文。明确属于 `expected`／`validation` 且未发送请求的失败不会冻结待确认创建；网络超时等未知结果继续保留原有确认流程。真实组件回归覆盖失败后继续编辑、草稿内容不变和未进入 `awaitingConfirmation`。

## 跨运行时联验

真实 `RichEditorSession.flush()` 导出共享合法语料 21 条，经 Web 实际 Milkdown 解析／序列化，再由 App 解码及保存，21 条文字、块与完整格式语义均一致；历史批次连同本地往返与范围测试共 44 项通过。冻结源码后的最终导出与复读另包含 2 项写入保护验证，共 46 项通过，日志为 `.dart_tool/text-color-final-export-verified.log`，21 条 cases 与此前联验产物逐字相同。Web 最终提交 `5231f0fd11f37624b16f96c078ce4f49dac79447` 重导出的 21 条 cases 与此前已复读版本逐字一致，最终回程产物 SHA-256 为 `fe2298484ba4dd26152b52b6f72bbb99e2a50a0827461e1bfe0439f16c720a1d`。本机文件 `build/mobile-web-text-color-final-output.json`，原始复读日志 `.dart_tool/text-color-web-return.log`、集成后复读日志 `.dart_tool/text-color-integrated-export.log`；只更新产物版本绑定，不重复已通过的全测。

Backend 对相同 21 条分别验证启用新写及关闭新写保源；18 条有色原文的旧端覆盖和全部去色覆盖均以 40016 拒绝，3 条无色正常。联验仅传递生成的 Markdown 测试数据，不传播未提交源码、不写真实业务环境。生成输入由文件 SHA-256 清单固定（全部应用源码、导出测试、依赖锁和颜色契约），提交后再次核验清单并在产物绑定正式任务提交。合入阅读空格修复后，reader／颜色／摘要与 Web 回程 107 项通过，额外同段空格实体与颜色组合及阅读 Golden 5 项通过；重新生成输入清单和 21 条保存产物。

## 2026-10-17 交互精简反馈候选

负责人反馈选中文字后颜色与自定义入口无反应。首次只读核验公网 `/meta`：Backend `d3577839dc537e21c546ee385a4c97091b58a8f7`／API `5.38.0-dev.20261016.1`，`textColorV1Supported=true`、`textColorV1WriteEnabled=false`。现有面板按该开关禁用所有操作，但色块仍饱和显示，且点按没有反馈；这是本次确认的原因，不能据此声称已复现选区丢失。当时未开启线上新写或部署消费者。

候选将恢复默认改成带无障碍名称的无文字按钮，自定义固定在色块同行右侧，预设与最近色可横滑；点击区保持 48dp。取色盘顶部以 Aa 实色预览替代重复标题，移除底部预览行；RGB 数值首次聚焦后全选。无选区和新写关闭分别短暂提示原因，正常态不增加常驻说明。

定向入口为 `editor_text_color_palette_test.dart`、`editor_text_color_flow_test.dart`、`editor_text_color_selection_test.dart`、`editor_rgb_picker_tray_test.dart`、`post_composer_text_color_test.dart`、`thread_compose_text_color_test.dart`。最终 34 项通过，日志 `.dart_tool/text-color-ux-focused-final.log`；覆盖真实长按选词 → T → 预设／自定义 → 应用／恢复默认／撤销重做、RGB 边界与首次聚焦全选、禁用原因、320/360dp 单行横滑及 1/1.5/2 倍字号、两类完整编辑器短屏键盘。首次运行 31 通过／1 失败，发现移动端点按光标定位覆盖 `selectAllOnFocus`；改为焦点帧结束后全选，再执行上述检查通过，原失败日志 `.dart_tool/text-color-ux-focused.log` 保留。

14 张 Golden 更新为实际组件渲染，包含完整 T 面板、RGB 面板、明暗与短屏；不是系统键盘或真人交互实拍。当前属于原 PR #106 的连续反馈批次，保留本地现场，未因本次微调重建安装包或重复全量门禁，未宣称负责人已验收。

## 门禁与交付

2026-10-17 负责人明确要求“我要直接真实测试”后，通过管理员入口仅启用当前已部署 Backend `d3577839` 的 `TEXT_COLOR_V1_ENABLED=true` 并重启该服务，公开与本机只读健康、能力及数据安全检查通过；Web 服务未部署。审计见治理仓库 `docs/verification/text-color-v1/write-enable-20261017.json`。App 由负责人返回前台刷新能力，不自动登录或写业务数据。

随后负责人反馈 `MarkdownCodecException`／`markdown.document_roundtrip`，明确操作为“居中对齐、预设色、选中整段”；失败发生在本机编码，尚未发送请求。以“如何呢”、预设 `#D14343`、整段 `center` 和实际输入的 literal 属性构造回归，旧实现同样在 `markdown_delta_codec.dart:163` 拒绝（`.dart_tool/text-color-layout-old.log`），修正对齐解析后通过（`.dart_tool/text-color-layout-fixed.log`）。这份回归匹配已确认操作条件；最终仍须负责人在真机原正文复验。

通过 `tool/sync_backend_contract.ps1 -Revision d3577839dc537e21c546ee385a4c97091b58a8f7` 从只读参考仓库同步实际部署提交；所有契约字节保持一致，仅 `backend-contract.properties` 的来源 SHA 更新。没有通过改写检查、跳过线上核验或同步尚未部署的后续契约绕过此前失败。

本次新增兼容检查：

- `test/core/markdown/markdown_text_color_combinations_test.dart`：7 组通过，覆盖 32 种粗／斜／删除线／代码／链接组合、4096 个相邻样式与同色／异色／默认色组合，以及部分范围、不同链接、转义符、中文、emoji、组合字符、空格、Tab、NBSP。分别核对独立阅读 AST、逐字样式和重开；日志 `.dart_tool/text-color-combinations.log`。
- `test/core/markdown/markdown_text_color_layout_test.dart`、`test/features/editor/editor_text_color_compatibility_test.dart`：34 项通过，覆盖正文／H2／H3 的左中右对齐、引用及三级有序／无序列表与 32 种行内样式、软换行和空段边界、真实输入后以两种顺序应用居中和预设色、局部恢复默认、保存重开，以及图片、表情、骰子、用户／全体玩家提及和传送门原子保持身份且不着色。围栏代码和既有不支持硬换行保持源码保护；恶意属性、任意 HTML、损坏标记和掩码后字符索引均有断言。日志 `.dart_tool/text-color-layout-session-final.log`。
- 首次布局／会话测试 23 通过、2 失败，原因是测试夹具遗漏已有空段分隔属性、全体玩家提及缺少合法词边界；修正夹具后重跑 34 项通过，保留 `.dart_tool/text-color-layout-session.log`，没有为通过测试放宽应用规则。
- `test/core/widgets/wenyou_markdown_text_color_test.dart`：19 项通过，新增明暗 × 居中／右对齐 × 正文／H2／H3 的 12 项真实阅读组件验证，检查 `RenderParagraph` 实际字形位置与原始 RGB，不只依赖编解码互相验证。日志 `.dart_tool/text-color-reader-alignment.log`。

同一修复另通过既有编解码相关 6 文件 384 项回归（`.dart_tool/text-color-codec-existing-regressions.log`），最终定向分析无问题。完整 `npm run check:apk -- -TestConcurrency 2` 首轮通过契约校验／生成、线上精确版本、格式、应用／SDK 分析和架构后，在文档门禁发现其余 22 个模块仍记录旧来源 SHA（`.dart_tool/text-color-ux-codec-check-apk.log`）。契约内容无变化，已同步模块审查来源，23 模块检查及 174/174 API 范围检查通过。第二轮 `.dart_tool/text-color-ux-codec-check-apk-final.log` 在分析阶段主动停止：发现精简面板的无障碍包装隐藏了子按钮点击动作，补 `Semantics.onTap` 后冻结源码重跑完整入口，日志 `.dart_tool/text-color-ux-codec-check-apk-verified.log`。不将尚未完成的检查记为通过。

面板追加实际读屏语义回归：可用时调用颜色／默认色动作，禁用时没有写动作。旧候选可用状态断言失败（`.dart_tool/text-color-ux-semantics-old.log`；同轮还有测试 handle 清理问题），修正包装动作及测试后，整个面板 12 项通过（`.dart_tool/text-color-ux-semantics-final.log`）。此次无障碍修正不改变画面，保留既有 Golden。

Web 本轮临时离线入口补齐生产使用的对齐 parser/schema，验证 78 个合法输入（精确复现、72 组合、3 排版和无空行相邻 center/right 2 例）及 1 个既有硬换行保源负例，79/79 通过；既有 Web 5 文件 248/248。Web `5231f0fd11f37624b16f96c078ce4f49dac79447` 输出 78 条的 SHA-256 为 `9803d936cad68838fceae298899ffc942ce9afb9fa2483f3e1165f70ac1b588e`，通过现有 `editor_text_color_roundtrip_test.dart` 的 `TEXT_COLOR_IMPORT` 入口在 App 实际会话复读：本轮 101 项全部通过（原有 23＋新增 78），日志 `.dart_tool/text-color-web-alignment-return.log`。旧 21 条入口未装载对齐插件，因此不能拿旧结果证明这部分覆盖；Web 永久回归补充另行提交。

Web 永久回归已交付 [PR #73](https://github.com/morenk/wenyousite-frontend/pull/73)，提交 `48eb3e926b9a926152427849e7742ab03fa4aa43`，完整检查 396 文件／5274 测试及构建通过。最终产物 SHA-256 为 `cc184d7627232d8f75028f03cf82651ed0073f8db5ab86190e4515c6032fdecc`；本机独立核对 78 条有序 `id/source/saved` 与已复读输入完全一致，0 差异，按此绑定最终提交，不重复相同 App 检查。

Backend 扩测另外发现旧端投影在无空行相邻对齐块中可能转义对齐标记；补修 [PR #54](https://github.com/morenk/wenyousite-backend/pull/54)／`1b437db739c4c4bf1ed126cb6389b33d38ffc7a8` 已通过完整检查：208 suites／2804 测试、26 E2E 套件、12 音频预算场景，以及 1541 离线组合。本轮 9 组隔离资源核验清理完成。新增 4 个 fixture 属于现有协议的回归，无 API 或 Schema 变化；Mobile 保持实际上线 `d3577839` 来源，不提前同步未部署提交，不需要 Foundation 发版。两份补充 PR 均未合并或部署，不能将兼容补修记为线上已生效。

集成 `0b3bd047` 后的完整批次日志为 `.dart_tool/text-color-check-apk-integrated.log`：Flutter 6720 通过、1 跳过、2 失败，Windows 工具 48/49；继续执行已生成旧树诊断 APK。失败分别为旧行内原子组件断言未区分受控文字样式、旧失败文案构造存量门禁，以及契约导出临时后端缺颜色文档夹具。修复保留原子组件断言，并补同段折行几何和链接／代码基线；颜色能力拒绝改为明确的 `FailureReason.validation`／`keepDraft` 与展示层映射，验证无网络请求；脚本夹具包含颜色文档、Schema 与语料并核对同步字节。该轮失败不被后续补验覆盖，最终应用源码重新运行完整门禁，旧 APK 不交付。

最终冻结源码重新运行 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，日志 `.dart_tool/text-color-check-apk-final-frozen.log`。Flutter 全量 6734 通过、1 跳过、0 失败；跳过的是既有 Sentry 显式联网回执验收，颜色用例没有跳过。Windows 工具 49/49 通过，本轮临时后端契约夹具按测试 `finally` 清理。OpenAPI 校验、固定来源、API 重新生成一致性、1327 文件格式、应用与生成 SDK 分析、架构、23 模块文档和 174/174 API 范围覆盖均通过。

最终脚本返回 1，唯一失败阶段为生产契约精确版本／SHA 校验；Android Debug 构建成功。产物 `build/app/outputs/flutter-apk/app-debug.apk` 为**诊断构建，整体门禁未通过**，不作为合格真机候选。实际包名 `site.wenyou.app.debug`，版本 `0.9.0-debug`／99，ABI `arm64-v8a`，110484748 字节；SHA-256 `5ba7096e628d88ef245483293106dc69101794efdbf6bed013b7c0b4a810e551`。未安装或启动该包；交付时 ADB 仍无设备。仅补充记录未改变通过门禁的应用源码。

首轮 `npm run check:apk -- -ContinueAfterFailure` 的生成一致性、格式、应用／SDK 分析及架构通过；发现并补正模块标题和 API 排除清单版本，23 模块文档与 174/174 API 范围覆盖补检通过。为修正短屏真实约束，中止尚未构建 APK 的首轮，保留 `.dart_tool/text-color-check-apk.log`；最终源码重新从头执行门禁。

只读生产核验实际为 API `5.37.0-dev.20261016.1`、Backend `1aa8655f7c8e25dcc8723d7793afb9cefc6d510d`、Markdown 5，与固定候选 `5.38.0-dev.20261016.1`／`2cdedbc` 不符。该失败不通过部署、跳过或改写版本绕过；即使构建产生 APK，也不能称为完整门禁合格候选。检查同时要求实际 build SHA 与同步来源完全相同；Backend 经批准合并部署后，需要按实际上线 SHA 重新同步／核验消费者契约并补验，合并 SHA 不一定等于当前候选 `2cdedbc`，不能仅凭部署宣称本次锁定自动通过。最终结果、PR 与提交记录在交付时追加，无自动合并、部署或正式发包。

Auto-review 默认偏好已传递；当前协作工具没有审批配置入口，运行策略为 `never`，实际 Auto-review 尚未设置／核验，不能视为“帮我批准”已生效。

## 2026-10-17 本机 SDK 恢复

本轮完整门禁期间发现 `D:/sdk/android` 的平台、NDK、构建工具和许可目录为空，原 platform-tools 完整；手机经 USB 重新连接后 ADB 为 `device`。负责人明确批准重新安装所需官方 SDK 并接受对应许可。下载官方命令行工具 `commandlinetools-win-15859902_latest.zip`，SHA-256 与官网 `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a` 一致，通过 sdkmanager 恢复 NDK `28.2.13676358`、CMake `3.22.1`、Build-Tools `36.0.0`、Android 36 与 37.0；现有插件构建另补 Android 34／35。许可由官方工具在本轮授权后记录，没有手工写入接受哈希。

恢复后 aapt、CMake、NDK clang 可运行，Gradle `help` 与 `:app:checkDebugAarMetadata` 返回 0。未改变应用的 Gradle、SDK 目标、依赖或源码，完整测试继续使用原冻结输入。另一个音频任务报告其旧 Worktree 清理可能沿 SDK junction 影响共享目标，事故原因与清理修复由该任务审计；本任务不删除任何 Worktree，也不将 SDK 缺失归因负责人操作。脱敏恢复记录另存治理交付目录 `docs/verification/text-color-v1/sdk-recovery-20261017.json`。
## 本轮最终自动检查与候选 APK

冻结源码完整运行 `npm run check:apk -- -TestConcurrency 2`，`.dart_tool/text-color-ux-codec-check-apk-verified.log` 返回 0：Flutter **6800 通过、1 项既有 Sentry 显式联网验收跳过、0 失败**；Windows 工具 **49/49**；OpenAPI、固定来源、生成一致性、实际上线精确 SHA、格式、应用／生成 SDK 分析、架构、23 模块文档与 174/174 API 覆盖均通过。Debug ARM64 APK 构建成功（56.1 秒）。3031 个应用、测试、原生、依赖和契约输入在门禁后逐项核对 SHA-256，0 变化；记录 `.dart_tool/text-color-ux-codec-frozen-inputs.json` 与 `text-color-ux-codec-source-verification.json`。后续仅补文档不重复整套应用检查。

候选包名 `site.wenyou.app.debug`，显示名“温油站 Debug”，`0.9.0-debug`／99，`arm64-v8a`，minSdk 26／targetSdk 36，110484748 字节，SHA-256 `4167ee51f0b53c70464052b4359e4811f358a92e5847aa3955d2d3a8ef3f6050`。APK 内 Debug kernel 已核对包含新版单行面板／横滑标识及默认色无障碍文案，避免把旧包时间戳当作新代码证据。另存 `D:/codex-artifacts/text-color-v1/wenyou-text-color-0.9.0-debug-99-4167ee51.apk`，未发布到用户下载通道。

安装前再次查询 `4b9c39b5` 返回 device not found，ADB 与 Windows 即插即用列表均无该设备，故此处不记为安装完成；已请求负责人重新连接，恢复后仅 `install -r`，不自动启动、卸载或清除数据。原场景与中文输入法、RGB 拖动、半屏高度仍待真机验收。

同一门禁运行期间音频 PR #102 合入新的 `dev`。本次冻结候选用于原任务反馈，正式合并前须同步最新集成分支，保留音频／工具栏和链接来源身份继承修复，并按变化风险完成集成验证；不能用本次冻结树的检查结果覆盖之后的合并树。所有 PR 保持待负责人验收，无自动合并、发版或部署。
## 2026-10-18 真机覆盖安装

负责人重新连接 USB 并要求继续。设备 `4b9c39b5`／Xiaomi `2509FPN0BC` 为 `device`，无其他 Flutter run／attach 会话；核对现有与候选包名均为 `site.wenyou.app.debug` 后，以 `adb install -r` 覆盖成功。手机包更新时间 `2026-10-18 00:59:02`，版本 `0.9.0-debug`／99，设备内 base.apk 的 SHA-256 与候选完全一致：`4167ee51f0b53c70464052b4359e4811f358a92e5847aa3955d2d3a8ef3f6050`。

本次安装绑定应用提交 `3e136fa7479210a6a151d45ca515b67c3252e2e3`，复用已经通过完整门禁的原 APK，没有重新构建。未卸载、清除数据、自动启动应用或执行线上业务操作；安装成功不替代负责人验收。请负责人打开“温油站 Debug”，复验居中整段预设色、自定义、选区恢复、中文输入法与半屏高度。安装回执另存本机 `D:/codex-artifacts/text-color-v1/install-20261018.json`。

## 2026-10-18 第 19 楼草稿差异与发布拒绝

状态：发布 40018 继续排查；负责人已明确保留默认继承上次未发布草稿，不新增草稿选择页。发布态是两行红色“杀！”，上方 H3 小字、下方 H2 大字；进入编辑后上方变为空行。使用既有 Dart VM 转发只读检查该楼模型、活动编辑会话，并只读取该目标的本机 `draft.json`，确认已发布原文仍完整：

```markdown
### <span data-wenyou-color-v1="#D14343">杀！</span>
## <span data-wenyou-color-v1="#D14343">杀！</span>
```

活动会话及本机草稿均为以下 56 字符正文，草稿保存的 baseline 仍与上述发布原文及版本相同：

```markdown
<br />
## <span data-wenyou-color-v1="#D14343">杀！</span>
```

两份示例中行之间均为单个 LF，无额外空行。当前同基线草稿会自动恢复，已证实它是此次编辑态与发布态差异的来源；尚无证据确定历史草稿最初何时、为何少了第一行，不归因为编解码丢字。真实 `showPostComposerSheet` 诊断重现恢复后 Quill 文本为 `\n杀！\n`，不是发布原文的 `杀！\n杀！\n`。初始诊断曾期待展示发布原文，失败日志 `.dart_tool/text-color-floor19-old-failure.log` 保留，但负责人随后确认默认恢复才是所需行为，因此不再将此差异登记为待修复缺陷。手机草稿未被 agent 删除或覆盖，账号标识、私人草稿文件及调试授权 URI 不提交。

随后负责人提供 `postEdit` 响应阶段 HTTP 400／业务码 40018（`INVALID_TEXT_COLOR`），请求编号 `8973096d-b040-45f7-9088-a0ce209cde84`，时间 `2026-10-17T17:16:35.861709Z`。该次编码已完成、收到后端响应，与此前本地 `markdown.document_roundtrip` 不同。Backend 只读日志匹配该请求拒绝；离线用上述 56 字符输入确认空段起始使通用 Markdown 解析器把后续有色标题合入 `html_block`，触发严格颜色校验。线上日志不记录正文，因此不声称拿到了该请求的完整发送体；手机草稿及诊断长度提供对应旁证。原 H3＋H2 两行输入可通过现有后端校验。

负责人明确“不需要草稿选择页，默认继承上次未发布的编辑态修改草稿”，本轮尝试的新增选择流程撤回，保持既有恢复行为；仅保留精确原文、草稿恢复及排版兼容测试。Backend 沿原补修 PR #54 修复受控空段边界，不通过移除空行、清草稿或放宽任意 HTML 来规避错误。当前只读调查没有线上业务写入，后端修复未部署，发布反馈仍待后端候选上线后的负责人复验。

最终保留 `test/features/editor/editor_text_color_adjacent_blocks_test.dart` 和 `test/features/posts/post_composer_adjacent_color_restore_test.dart`，14 项通过，日志 `.dart_tool/text-color-floor19-default-restore-final.log`；两文件逐一静态分析无问题。覆盖实际 56 字符草稿的独立阅读空段／H2 字号／RGB、原样编码，108 组相邻正文／H2／H3、换行、对齐和粗体组合，6 种真实 Quill 输入顺序，以及实际页面无草稿、相同草稿、默认继承未发布草稿三条路径。新回归不调用真实业务接口。

应用、Android、依赖、契约和生成客户端相对已安装 `3e136fa` 无差异，本轮只新增测试和验收记录，不重复完整门禁、重建或安装 APK。被撤回选择流程的检查／Golden 不作为最终行为证据。手机继续使用上一节核验过的 `4167ee51` 候选，未新增选择页。

### 2026-10-18 空段补修的跨端复读

Backend PR #54 的 `1ab948107960c1b221cf5dffd7a1d79ee9f5a277` 已通过完整检查和全部远端 CI；完整检查为 208 suites／2857 tests、26 个 E2E 套件及 12 个音频预算场景，关闭新写另行隔离验证通过，8 组隔离资源清理完成。负责人已明确批准合并和正式后端部署，包括 dev 中音频 #53 及其额度迁移；本记录不以批准代替实际部署完成。

该提交新增的 8 个空段相邻排版 fixture，经 Web `48eb3e926b9a926152427849e7742ab03fa4aa43` 生产编辑配置读写，37 项通过；Mobile 使用实际 RichEditorSession 复读源文与保存文，原有 23＋新增 8 共 31 项通过。覆盖标题、无序／有序列表、引用、引用内空段及居中／右对齐。复读文件 SHA-256 为 `7dbd5cfa48ba0cde599ee1753e7c577d086f464d7c62c85daacd73e0a4f74a8d`，本机日志 `.dart_tool/text-color-empty-row-web-return-test.log`，原始产物保存于治理仓库 `docs/verification/text-color-v1/empty-row-web-return-20261018.json`。只运行离线消费者回归，没有自动发布真实正文。
### 2026-10-18 紧凑底栏候选与覆盖安装

按负责人新增反馈，主题底部楼层操作行去掉上下各 8dp 额外留白，保留至少 48dp 点击区域及系统安全区；发表入口使用 Foundation 输入框颜色／边框／圆角，显示“回复一下”，点击打开原编辑器。窄屏保留文字，放大字号自然增高，游客登录和发言权限不变。新增 320/360dp、明暗、1/1.5 倍字号共 8 张组件 Golden；2 倍字号与大额计数另验布局。此为视觉候选，负责人尚未验收。

`npm run candidate:apk -- test/features/threads/thread_detail_bottom_bar_test.dart -TestConcurrency 2` 返回 0：1334 个文件格式检查无变化，应用与生成 SDK 全量分析无问题，11 项定向测试及 Debug 构建通过（190.5 秒）。日志 `.dart_tool/thread-bottom-bar-candidate-apk.log` SHA-256 `57d0dc7bc3e4ccd27d18195485aab8a1ce91f7015af910a46f0f47f4448c42be`。既有 `thread_detail_page_test.dart` 首轮 76 通过／8 失败，更新 6 张受影响整屏 Golden 和旧入口断言后 83 通过／1 失败，最终修正测试定位到真实 TextButton 语义节点，该项独立通过；84 项分阶段覆盖，不称为一次完整通过。日志分别为 `.dart_tool/thread-bottom-bar-page.log`、`thread-bottom-bar-page-updated.log`、`thread-bottom-bar-semantics.log`。文档 23 模块补检通过。

3042 个冻结输入复核 0 漂移；基线 `feb8d956a26a2daf3a64531b90608a8d8a4b13ae`，唯一应用变更 `lib/features/threads/presentation/thread_detail_bottom_bar.dart` SHA-256 `b76fce85780d66cda57e84ac06660aa6155cd785577669ffc022b78f35d22eb0`。冻结清单 `.dart_tool/thread-bottom-bar-candidate-inputs.json` SHA-256 `54853a067410f66c953e30daf1e7862953b37a59271da65c1d8a7df66737ae93`。本轮纯界面反馈使用快速候选入口，未重复全量 Flutter 测试；此前 6800 项完整门禁仅绑定此前颜色候选，正式集成仍须验证最终合并树。

既有 VM 服务已无法连接，Flutter attach 尝试退出，未热重载或重启应用；随后按授权生成独立 APK。包名 `site.wenyou.app.debug`／“温油站 Debug”，`0.9.0-debug`／99，arm64-v8a、minSdk 26／targetSdk 36，110484748 字节，签名核验通过，SHA-256 `7b0c585cc220a94e202c7cb662e46676a725aa42e5325b750d7116f1aadeac38`。另存 `D:/codex-artifacts/text-color-v1/wenyou-thread-bottom-bar-0.9.0-debug-99-7b0c585c.apk`。

设备 `4b9c39b5` 上 `adb install -r` 成功，实际 base.apk 哈希与候选一致，手机包更新时间 `2026-10-18 01:57:55`。安装回执 `D:/codex-artifacts/text-color-v1/bottom-bar-install-20261018.json`；保留数据与草稿，没有自动启动或业务写入。已请求负责人手动打开主题页观察新版底栏；真机画面和原发布问题仍待验收。
### 2026-10-18 私聊同色底栏与热重载

负责人已确认紧凑布局“可以了”，但认为输入框底色偏深，要求与私聊一致。对照 `DirectMessageComposer` 使用的 `WenyouInlineComposerDock`，仅将底栏背景从 `tokens.input` 改为 `tokens.softPanel`，边框继续复用相同 `tokens.border`；尺寸、圆角、布局及权限行为不变。明暗两套对照真实私聊 dock 的回归在旧实现失败，改动后 13 项底栏和 6 项整屏定向回归全部通过，8 张组件和 6 张整屏 Golden 更新；两文件定向 Dart 分析通过。日志 `.dart_tool/thread-bottom-bar-tone-before.log`、`thread-bottom-bar-tone-analyze.log`、`thread-bottom-bar-tone-test.log`、`thread-bottom-bar-tone-page.log`。不重复完整构建或全量门禁。

用户手动打开 App 后，新运行进程 VM 端口变为 39339；保留已有 5510→36657 转发不改，使用 `--no-rebind` 建立本任务独立 5511→39339 转发并 attach。当前调试会话归属本任务与本 Worktree，设备 4b9c39b5／包 site.wenyou.app.debug，host 5511、Flutter daemon PID 13276；未启动／重启 App 或接管其他调试会话。源文件 SHA-256 `138bef69bd83a6b73ff2bde8b3b4d4689c8e9f2eb9e265df28b60eede45ce087`，`app.restart(fullRestart:false)` 返回 code 0，Reloaded 1 of 4730 libraries，2838ms。调试授权 URI 只留本机忽略文件，不提交。

只读获取真机画面确认浅底色已生效：1200×2608、density 480、400dp 宽、font_scale 1.0、亮色主题。截图 `D:/codex-artifacts/text-color-v1/thread-bottom-bar-device-soft-tone-20261018.png` 含真实业务内容，仅留本机，不入库。手机安装 APK 仍为上一节 7b0c585c；当前画面绑定本次源码摘要及 reload 回执，不能用初装哈希代表热重载后的颜色。独立转发与调试会话保留供同一反馈批次使用，本轮未重打 APK；新色调仍待负责人确认。

Backend #54 已按负责人明确批准合并并正式部署 `08bbf5dbcd791270764fc2152fe9b61f683d7fa1`／API 5.39.0-dev.20261017.1。正式部署退出 0，三项异地备份及音频额度迁移成功，local/public health 200，颜色支持与新写均为 true；Web release、PID 和启动时间不变。已上线编译产物的 56 字符空段＋彩色 H2 纯函数验证通过，无线上业务写入；真实发布仍由负责人复验。此 Mobile 反馈树继续固定 API 5.38 来源，正式集成前需同步最新 dev／已发布契约并验证最终树。
### 2026-10-18 列表摘要统一与真实最近回复复验

负责人反馈最近回复显示颜色 span，并在追问后明确搜索楼层目前未发现异常；随后要求与搜索复用实现。实际代码有两套摘要：最近回复独立 AST 未注册颜色语法，搜索／草稿走通用正则。真机“我的→回复”第 19 楼卡片确实显示两个完整颜色 span，与原始相邻 H3／H2 两行一致。Backend 08bbf5d 离线核验最近回复 preview 先去色再截断、content 保源，搜索只返回完整 Markdown；无需为此修改后端或 DTO。

新增 core `markdown_plain_text_preview.dart` 作为唯一 AST 处理，`MarkdownContent.toPlainTextPreview` 调用该入口，`recentReplyPreview` 只做薄封装与既有骰子结果策略。完整解析后折叠摘要空白，再按 Unicode 码点截断；严格受控颜色、标题、列表、链接、图片占位、实体、提及投影、骰子及中文 emoji 共用规则。代码／转义／普通 HTML 或损坏标签作为可见字面保留，不全局删尖括号；标准 CodeBlockSyntax 优先于自定义段落，避免 4 空格或 Tab 缩进代码中的颜色标记误解析。没有修改阅读器、Codec、契约、依赖或正文持久化。

旧最近回复精确回归 10 失败／7 通过，缩进代码补验旧实现另有 2 失败，均保留日志。最终直接消费者 173/173 通过（`.dart_tool/text-color-preview-consumers-final.log`），包括真实 HTTP DTO→仓储→公开／本人最近回复列表、综合／全局／主题内搜索仓储与主题内结果页、云草稿面板、角色提及，以及 9 个独立 canonical fixture。角色提及旧正则曾把代码内节点削成昵称，现纠正为完整代码字面且不参与身份投影。首轮 fixture 代码空白期望未折叠导致一项失败，修正独立期望后通过；未降低语义要求。

最终全量 `flutter analyze --fatal-infos --fatal-warnings` 无问题（29.6 秒），日志 `.dart_tool/text-color-preview-analyze-final.log`；此前中断分析和 8 条测试字符串插值 lint 失败分别保留为 `text-color-preview-analyze-interrupted.log`／`text-color-preview-analyze-lint-before.log`，测试 lint 修改后两文件 48/48 补验通过。9 个变动 Dart 文件格式无变化，23 模块文档通过，diff 检查通过。最终冻结 9 个应用／测试输入复核 0 漂移，清单 `.dart_tool/text-color-preview-source-inputs.json` SHA-256 `dd2581b329035d22b3529407522dd792510e9a7cff0aa8f5e82730974a28c051`。

App 后台期间旧 attach 断开；负责人手动切回前台后，同一 PID 13380／VM 39339 恢复可达，复用本任务 5511 转发重新 attach，无启动／重启。初次 reload 返回 0 libraries，读取 VM library 清单发现新摘要模块尚未加载，因此不将该次视为更新成功。仅刷新已检查的 3 个源文件修改时间、不改变字节，重新热重载实际为 3/4731 libraries、2495ms、code 0，且只读确认新共享 library 已进入 VM。日志 `.dart_tool/thread-list-preview-attach.log` 含调试授权 URI，仅留本机忽略目录。

审查当前页面下拉刷新仅调用资料、钱包和最近回复 GET 后，执行只读滚动／刷新，实际第 19 楼卡片从两段 span 源码变为“杀！ 杀！”。真机 400dp、亮色、font_scale 1.0，截图 `D:/codex-artifacts/text-color-v1/list-preview-confirmed-20261018.png` 含真实内容，仅留本机。未自动发帖、编辑、删除、签到或清草稿。本轮没有重建／安装 APK，仍以初装 7b0c585c 加当前源码与 reload 记录绑定；候选现场可见变化，负责人最终验收仍独立记录。

### 2026-10-18 光标先选色与最终集成候选

负责人新增要求允许先选颜色再输入。有效折叠光标（包括空正文）可选择输入色，第一个 T 选择默认色并保留其他格式；有文字选区时仍只改范围，原子元素与换行不着色。连续输入、中文组合输入和换行保留显式输入色，主动移动光标后按新位置重新计算；取消 RGB 恢复原状态，只读、能力关闭和换正文清除临时色。选色本身不改文档、不写草稿或增加空撤销步骤。纯文本粘贴使用实际提交时的输入色，结构化片段保留来源格式；最近自定义色仍最多四个。

本轮已整合 `origin/dev` 的 `60a118084f680c270f0e05e6acb02659ee23d399`，合并提交 `d2c2ef0b` 保留音频、可定制工具栏和链接来源身份。独立 `chore` 提交 `7a99c643` 将契约绑定到已部署 Backend `08bbf5dbcd791270764fc2152fe9b61f683d7fa1`／API `5.39.0-dev.20261017.1`；OpenAPI 与该集成基线相同，生成 SDK 无差异。独立 `chore` 提交 `5c877c93` 锁定已批准正式发布的 Foundation `v7.5.0`，解引用提交 `fef249d8856f5ed08f55eab69a2a2ed01b2742ce`，不使用浮动分支或未发布源码。

应用候选提交为 `9aa396191b9845ba055752955f563dceba175937`。直接相关 13 个测试文件共 120 项通过，日志 `.dart_tool/text-color-caret-final-regression.log`，覆盖 caret、范围、默认、取消、数字焦点、真实 Quill composing `n → ni → 你`、纯文本／富文本粘贴、多步撤销／重做、音频投影及多行输入。音频元数据投影同时重算撤销／重做端点与选区，避免清空重做或留下旧偏移；按住播放器时仅允许内部投影补偿。多字符 String 含 LF 时逐文字段应用继承及显式行内格式，显式关闭覆盖继承，不将颜色或粗斜体附到行尾；单个回车保留原块规则。阅读器仅抽取既有音频来源与单行识别职责以满足文件大小门禁，直接阅读回归 97 项通过。

首轮完整门禁 `.dart_tool/text-color-caret-check-apk.log` 为 7171 通过／1 跳过／15 失败，未进入工具测试或 APK 构建。失败分别为一个旧 Backend SHA 硬编码、十个共享多行输入的 Quill 行属性断言、四张尚未更新的快翻 Golden。原始日志及 3170 项冻结清单保留。多行精确回归旧实现 10 项全部失败；仅移除 pending color 后仍有四个粗斜体组合失败，随后按非换行文字范围处理全部行内格式。继承粗体／斜体补验旧行为 11 通过／2 失败，修正后通过，显式 `bold:null` 保持关闭。完整预期同时核对可见文字、块属性、阅读、保存重开与撤销，未放宽语义守卫。四张 320/360/400/600dp 快翻 Golden 经目视批准后更新，差异包括已认可的紧凑浅色回复底栏及旧基准残留的 DEBUG 标记，不称为仅底栏像素变化。

最终对冻结源码执行 `npm run check:apk -- -TestConcurrency 2` 返回 0，日志 `.dart_tool/text-color-caret-check-apk-final.log`，SHA-256 `f60bbb7c77153b73b0965e86b13c2dfe8e32fefa0319740e634a9248ec8aeb86`。Flutter 7199 通过、1 项既有显式 Sentry 联网验收跳过、0 失败（22 分 02 秒）；Windows 发布工具 49/49。契约来源、SDK 再生成、精确线上 SHA／API、格式、应用与 SDK 分析、架构、23 个模块文档和 API 覆盖全部通过；同次门禁 Debug APK 构建成功（137.5 秒）。现有 `flutter_image_compress_common` 的 KGP 未来兼容警告仍在，无构建失败。

冻结清单 `.dart_tool/text-color-caret-final-frozen-inputs.json` 包含 3171 个应用、测试、契约、依赖和构建输入，SHA-256 `be8dc0ed694b39baca96e8dfa69460f0f41c2a773da714b85980c5e0e1702b51`；门禁后工作文件逐字复核 0 漂移。与应用提交绑定时，3151 个 Git blob 与检出字节相同，另 20 个脚本／生成 FILES 按仓库明确的 `eol=crlf` 规则从 Git LF 转换为 Windows CRLF；逐项验证后内容差异为 0。绑定记录 `.dart_tool/text-color-caret-final-commit-binding.json` 的 SHA-256 为 `07ddef0c8645e8299b50c8647fa8554f8f0d834bdf6aad9352d685feda2cfe20`，不把预期换行转换伪称为原始字节一致。

新增真实编辑器 T 面板 320/360dp 明暗四张 `editor_caret_color_*` Golden，320dp 使用 1.5 倍字号，模拟 220dp 键盘 inset；根任务已目视，没有新增布局阻断。模拟键盘不代表系统键盘或真机验收。原系统跨应用剪贴板仍为纯文本，不新增富 HTML 传输、草稿选择页或最近色管理入口。

候选 APK 为 `site.wenyou.app.debug`／“温油站 Debug”，`0.9.0-debug`／99，`arm64-v8a`，minSdk 26／targetSdk 36，152779816 字节，SHA-256 `e7cc965e16e646d1a052a15f331084c143aa533b80662fecaf5156dc6eb76987`。构建路径 `build/app/outputs/flutter-apk/app-debug.apk`，根任务独立保存并核验到 `D:/codex-artifacts/text-color-v1/wenyou-text-color-caret-0.9.0-debug-99-e7cc965e.apk`。交付时 ADB 列表为空，尚未安装、启动或热重载这份候选；没有自动线上业务写入。负责人需安装后复验空正文先选色、默认 T、RGB 取消／应用、中文键盘、换行、多次撤销与音频周围输入，PR 继续保持 Draft／待验收，不自动合并或发布。

### 2026-10-18 先选色输入候选覆盖安装

负责人重新连接设备后，根任务核对 `4b9c39b5`／Xiaomi `2509FPN0BC`，未发现其他 Flutter run／attach 会话。候选 `site.wenyou.app.debug`／`0.9.0-debug`（99）／arm64 与目标应用一致，使用同一份 `e7cc965e` APK 执行 `adb install -r` 返回 `Success`；设备包更新时间为 `2026-10-18 05:37:26 Asia/Shanghai`，设备内 base.apk 的 SHA-256 为 `e7cc965e16e646d1a052a15f331084c143aa533b80662fecaf5156dc6eb76987`，与已通过完整门禁的候选完全一致。

安装绑定应用提交 `9aa396191b9845ba055752955f563dceba175937`，回执保存在 `D:/codex-artifacts/text-color-v1/caret-install-20261018.json`。没有重新构建、卸载、清除数据、自动启动应用或执行线上业务写入，保留原有草稿。本次仅追加安装事实，既有代码门禁与 APK 证据继续有效；PR 保持 Draft，先选色输入、默认 T、RGB、中文键盘、换行、撤销及音频周围输入仍待负责人真机验收。

### 2026-10-18 负责人明确验收通过

负责人于 `2026-10-18`（Asia/Shanghai）明确回复“验收通过”，本批 Mobile 功能状态更新为负责人验收通过。结论绑定已安装到 `4b9c39b5`／Xiaomi `2509FPN0BC` 的应用提交 `9aa396191b9845ba055752955f563dceba175937`、`site.wenyou.app.debug`／`0.9.0-debug`（99），APK 与设备内 base.apk 的 SHA-256 均为 `e7cc965e16e646d1a052a15f331084c143aa533b80662fecaf5156dc6eb76987`。

应用输入保持不变，7199 项 Flutter 测试通过（1 项既有显式联网跳过）、49 项工具测试通过及同次构建证据继续有效；本次仅更新文档状态，不重复门禁或构建。之前的失败、待验收及安装记录作为历史保留。本次确认不扩展为 Web 实际人工跨端测试通过；既有跨运行时自动回归仍按各自记录解释。PR #106 可转为 Ready 供合并评审，未合并、部署或清理；后续新功能由独立任务处理，不计入本次已验收源码。

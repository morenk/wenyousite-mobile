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

本轮 UI 测试使用内存仓储与 mocked SharedPreferences，不访问真实业务写接口。`adb devices -l` 无已连接设备，未安装或启动 Debug，未接管音频等并行任务设备。当前没有真机画面；真机拖动取色、中文输入法、数字键盘切换、返回正文选区及半屏高度需要负责人验收。测试固定字体缺少部分 emoji，不代表平台字体实际效果。

负责人真机清单（兼容后端另行批准生效后）：

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

## 门禁与交付

集成 `0b3bd047` 后的完整批次日志为 `.dart_tool/text-color-check-apk-integrated.log`：Flutter 6720 通过、1 跳过、2 失败，Windows 工具 48/49；继续执行已生成旧树诊断 APK。失败分别为旧行内原子组件断言未区分受控文字样式、旧失败文案构造存量门禁，以及契约导出临时后端缺颜色文档夹具。修复保留原子组件断言，并补同段折行几何和链接／代码基线；颜色能力拒绝改为明确的 `FailureReason.validation`／`keepDraft` 与展示层映射，验证无网络请求；脚本夹具包含颜色文档、Schema 与语料并核对同步字节。该轮失败不被后续补验覆盖，最终应用源码重新运行完整门禁，旧 APK 不交付。

最终冻结源码重新运行 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，日志 `.dart_tool/text-color-check-apk-final-frozen.log`。Flutter 全量 6734 通过、1 跳过、0 失败；跳过的是既有 Sentry 显式联网回执验收，颜色用例没有跳过。Windows 工具 49/49 通过，本轮临时后端契约夹具按测试 `finally` 清理。OpenAPI 校验、固定来源、API 重新生成一致性、1327 文件格式、应用与生成 SDK 分析、架构、23 模块文档和 174/174 API 范围覆盖均通过。

最终脚本返回 1，唯一失败阶段为生产契约精确版本／SHA 校验；Android Debug 构建成功。产物 `build/app/outputs/flutter-apk/app-debug.apk` 为**诊断构建，整体门禁未通过**，不作为合格真机候选。实际包名 `site.wenyou.app.debug`，版本 `0.9.0-debug`／99，ABI `arm64-v8a`，110484748 字节；SHA-256 `5ba7096e628d88ef245483293106dc69101794efdbf6bed013b7c0b4a810e551`。未安装或启动该包；交付时 ADB 仍无设备。仅补充记录未改变通过门禁的应用源码。

首轮 `npm run check:apk -- -ContinueAfterFailure` 的生成一致性、格式、应用／SDK 分析及架构通过；发现并补正模块标题和 API 排除清单版本，23 模块文档与 174/174 API 范围覆盖补检通过。为修正短屏真实约束，中止尚未构建 APK 的首轮，保留 `.dart_tool/text-color-check-apk.log`；最终源码重新从头执行门禁。

只读生产核验实际为 API `5.37.0-dev.20261016.1`、Backend `1aa8655f7c8e25dcc8723d7793afb9cefc6d510d`、Markdown 5，与固定候选 `5.38.0-dev.20261016.1`／`2cdedbc` 不符。该失败不通过部署、跳过或改写版本绕过；即使构建产生 APK，也不能称为完整门禁合格候选。检查同时要求实际 build SHA 与同步来源完全相同；Backend 经批准合并部署后，需要按实际上线 SHA 重新同步／核验消费者契约并补验，合并 SHA 不一定等于当前候选 `2cdedbc`，不能仅凭部署宣称本次锁定自动通过。最终结果、PR 与提交记录在交付时追加，无自动合并、部署或正式发包。

Auto-review 默认偏好已传递；当前协作工具没有审批配置入口，运行策略为 `never`，实际 Auto-review 尚未设置／核验，不能视为“帮我批准”已生效。

# 正文字体 Mobile 候选与验收记录

状态：开发候选／待门禁与负责人验收。完整门禁未通过；尚未安装 APK、未接管设备或 Debug 会话、未执行线上业务写入、未合并或发布。

## 来源与范围

- Worktree：`D:\codex-worktrees\1528\wenyousite-mobile`；分支 `codex/20261021-thread-fonts-mobile`，PR #114。
- Backend PR #56：`1cf51dd752a98e3733f3dc0c83b17add75be7e46`，API `5.41.0-dev.20261021.1`；契约同步独立提交 `81e27f5e`。Foundation 最新正式 v7.6.0。
- 最终应用源码摘要：`388c3e6445f6b1f90c6b3dd345816135c2d98284a7b092fba27142f87771d31a`。对 Git 管理及新增的 `lib/`、`packages/wenyou_api/`、`android/`、`assets/`、`pubspec.yaml`、`pubspec.lock` 共 1,966 个文件按路径排序，以 `路径 SHA-256` 的 LF 行串计算摘要；逐文件记录在 `.dart_tool/thread-fonts-source-manifest.json`。生成器完成规范化后计算，排除中间生成文件。
- 17 款正式 ID，其中 16 款 ready，小城拉风体 `xiaocheng-lafeng` 为 pendingSource；不把研究别名写入正文。菜单使用“文楷”，不使用派生字体的保留名称。
- 主题、子贴正文、楼层、回复局部文字；不改变应用 UI、标题、动态与私聊字体，不在 APK 捆绑全字体库。

## 实现边界

- 字体与颜色在同一个受控 span，字体属性在前；支持粗体、斜体、删除线、普通链接和行内代码，逐行选区跳过原子。清除最后字体后重新安全序列化，避免把 `#`、`>`、`*` 等字面文字变成块结构。
- 编辑会话 Delta 只使用正式 font ID；Markdown、草稿、站内结构化剪贴板保留 ID，摘要输出可见文字。未知未来 ID 保留兼容原文。资源加载与回退绝不修改正文。
- 所有读取声明 `X-Text-Font-Version: 1`；相关创建、更新、聚合保存、正文 upsert 和云草稿声明 `textFontVersion: 1`，含移除全部字体。旧服务能力缺失时保护含字体内容；40019–40021 保留草稿。
- “字体”入口位于文字工具箱，仅非空选区可用；恢复默认可在关闭新增字体时使用。最近五款按账号存本机，整个选择操作可一次撤销。
- `lib/core/text_fonts/` 只访问目录公布的 HTTPS 自有基址与内容哈希路径，不请求上游、不带登录凭据、不跟随重定向。逐对象校验大小和 SHA-256；声明文件与字体一起保存。目录未发布时不发资源请求。
- 一个进程共用运行时：串行下载（不超过并发 2），最多 8 家族、64 请求、24 MiB 下载、24 MiB 注册输入、32 次注册；失败的原生注册仍消耗预算。离开页面不会清零。磁盘 SHA 缓存 64 MiB、LRU，已使用资源不删除；坏缓存删除后只下载一次，失败家族在本进程回退。
- 离线重启可读取已验证清单与缓存；所有缺字/缺资源/超预算都使用可读回退。输入字节预算不等于原生驻留内存。
- 字体目录不可用时可手动重新加载；目录缓存有效期五分钟，重试复用同一运行时与累计预算，字体声明按内容哈希去重。

## 正式资源与实际预览

从 VPS `/tmp/thread-font-release-publish` 只读复制构建资产至 `.dart_tool/thread-font-release`，未修改 VPS 源码。1,353 对象共 218,247,414 B，逐文件 SHA-256 全部匹配内容寻址文件名。完整清单 3,207,159 B，SHA-256 `ad22427e048b90f798bddafc308195786600ee006459f54144610d1bbe35d5c3`。

预览入口：`.dart_tool/thread-font-preview/index.html`，32 张原生 Flutter PNG；每款含实际 `WenyouMarkdown` 与 `TextFontQuillEditor`，360px 明色和 320px 暗色/200% 字号，正文包含颜色、粗体、斜体、行内代码。生成器 `tool/preview_thread_fonts_test.dart` 使用正式清单的实际分片，不使用 audit3500 研究子集。四次独立测试进程分别加载四款目标与思源黑体回退，没有在单进程重置预算。

| 批次 | 注册分片 | 请求 | 注册输入 B | 下载 B | Windows RSS 前/后 B |
| --- | --- | --- | --- | --- | --- |
| 0 | 5 | 13 | 7,874,732 | 7,898,612 | 255,213,568 / 316,432,384 |
| 1 | 6 | 17 | 8,694,308 | 8,730,328 | 254,570,496 / 305,020,928 |
| 2 | 5 | 15 | 8,914,748 | 8,944,991 | 255,049,728 / 306,991,104 |
| 3 | 6 | 17 | 9,411,516 | 9,446,330 | 254,767,104 / 321,695,744 |

15 款非基准字体的原生字符光栅与思源黑体不同；三款 BOOTH 的“汉语书”等缺字、篆书的字母与缺失汉字，光栅与明确指定的思源黑体回退相同。基准字体自身不作“与自己不同”的断言。范围来自清单 unicodeRanges，样本命中数不等于完整字库覆盖。RSS 包含 Flutter、图片等测试开销，不是 Android 字体内存。

真实预览发现并修正阅读端行内代码强制等宽、覆盖所选字体的问题；普通无字体代码仍用原有等宽样式。最终字体容器调整后重新生成全部预览，四批通过日志为 `.dart_tool/thread-fonts-preview-delivery-0.log` 至 `thread-fonts-preview-delivery-3.log`；上表为这次重跑数据。开发过程日志保留，但最终预览仍不能替代真机验收。

## 本地验证与门禁结果

- OpenAPI validate、客户端及诊断路由重新生成通过。
- 原颜色组合回归：`test/core/markdown/markdown_text_color_combinations_test.dart`，7 项通过。
- 字体 Codec、运行时缓存/预算、选区：`test/core/markdown/markdown_text_font_test.dart`、`test/core/text_fonts/text_font_runtime_test.dart`、`test/features/editor/editor_text_font_selection_test.dart`，首次收敛 31 项通过；后来追加的预算测试纳入最终门禁。
- 实际会话输入/保存/重开、clipboard v2、创建/更新/聚合/草稿载荷：`test/features/editor/editor_text_font_session_test.dart`、`test/features/posts/post_repository_test.dart`、`test/features/drafts/content_draft_repository_test.dart`、`test/features/editor/thread_compose_repository_test.dart`、`test/features/threads/thread_management_repository_test.dart`、`test/core/network/network_providers_test.dart`，29 项通过。
- 颜色工具箱、光标、字体会话、缓存预算与架构规则：`test/features/editor/editor_text_color_flow_test.dart`、`test/features/editor/editor_text_color_caret_widget_test.dart`、`test/features/editor/editor_text_font_session_test.dart`、`test/core/text_fonts/text_font_runtime_test.dart`、`test/tool/check_architecture_test.dart`，53 项通过（`.dart_tool/thread-fonts-final-related.log`）。
- 最终目录重试/离线缓存、运行时与真实选区工具箱：`test/core/text_fonts/`、`test/features/editor/editor_text_font_picker_test.dart`，12 项通过（`.dart_tool/thread-fonts-service-final.log`）。验证开启新增时更换字体、关闭新增时恢复默认、原选区与焦点恢复。补充测试的初次构造错误已修正。
- 完整门禁首次因公网仍为 API `5.40.0-dev.20261018.1`、Backend `6e00c4031a8f970609eef8cbf6fdefe3e6b12126` 而失败。第二次收集在修正旧颜色工具箱的 ProviderScope 回归前主动终止，不能算通过。最终使用唯一入口 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，该现有参数只继续收集检查，任一步失败仍以非零退出，未跳过或修改公网校验。
- 写入保护补充回归：`test/core/markdown/text_font_write_guard_test.dart`、`test/core/markdown/text_color_write_guard_test.dart`、`test/core/network/api_failure_test.dart`，21 项通过。新增断言先确认旧实现三项失败（本地恢复动作、内容保留标志），修正后通过；前后日志为 `.dart_tool/thread-fonts-guard-before.log`、`thread-fonts-guard-after.log`。覆盖已知/未来字体、代码字面量、网络前创建/更新/upsert 拦截和 40019–40021。
- `test/core/network/audio_budget_contract_test.dart` 的旧 5.40 来源断言已同步正式 5.41，并加入字体错误码反序列化；精确补测通过（`.dart_tool/thread-fonts-contract-regression.log`）。两处 lint 已修正，未关闭分析规则。
- 编辑器与帖子完整目录检查：`test/features/editor/`、`test/features/posts/`，1,759 项通过、4 张 Golden 失败（`.dart_tool/thread-fonts-pages-after.log`）。差异图确认仅为工具箱打开后误唤起选区手柄；字体容器现仅在所需文字变化时重建，原编辑器 Key 保留在 Quill 上。旧 Key 类型问题先以两个真实主题页面测试确认失败（`.dart_tool/thread-fonts-page-before.log`）。修正后 `test/features/posts/post_composer_text_color_test.dart`、`test/features/editor/thread_compose_text_color_test.dart`、`test/features/editor/editor_text_font_picker_test.dart` 共 10 项通过（`.dart_tool/thread-fonts-pages-final.log`），未改 Golden 基准。字体选择测试随后改为使用实际字体容器，2 项再次通过（`.dart_tool/thread-fonts-picker-final.log`）。
- 最后一次完整门禁为 `.dart_tool/thread-fonts-final-v5-gate-apk.log`：OpenAPI 校验、固定来源、再生成一致性、1,447 文件格式、应用/生成客户端分析、架构、23 模块文档、API 有效覆盖 176/176 和 Debug 构建通过。Flutter 全量运行 7,348 项通过、1 项跳过、1 项失败；跳过项为需显式开启的 Sentry 接收验收。唯一失败是 `test/features/threads/thread_detail_stack_test.dart` 的精确 Map 未包含正确发出的 `textFontVersion: 1`，补齐期望后该文件 6 项通过（`.dart_tool/thread-fonts-stack-final.log`）。
- 同轮 Windows 工具测试 48/49 通过，失败为 `tool/windows/contract_revision.test.mjs` 的模拟后端缺少新增字体文档。补齐两份文档并增加八份字体契约逐字同步断言后，`npm run test:release-tool` 全部 49 项通过（`.dart_tool/thread-fonts-release-tool-final.log`）。这两项修正仅涉及测试夹具，冻结的 1,966 个应用文件与 APK 构建前后一致。
- 完整门禁原记录以退出码 1 结束，包含公网契约、Flutter 旧期望、Windows 夹具三个失败步骤；后两个已独立修正复验，完整门禁未重跑，公网校验仍未通过。不能将本次收集或补测称为统一门禁成功。前置 Foundation APK 不是本字体产物；公网部署、资源发布与负责人真机验收尚未完成。

## Debug 验证包

- 文件：`D:\codex-worktrees\1528\wenyousite-mobile\build\thread-fonts-candidate\app-thread-fonts-6f15730d186f-debug.apk`，155,236,322 B。
- SHA-256：`6f15730d186f4b3c13bfb63a6e4072aff266b87acaa8bb30605cc7f2327f6e12`。构建时间：2026-10-21 07:06（Asia/Shanghai）。
- `applicationId=site.wenyou.app.debug`，名称“温油站 Debug”，`versionName=0.10.0-debug`，`versionCode=100`，最低 API 26，目标 API 36，仅 `arm64-v8a`；APK v2 签名校验通过，未捆绑正式字体分片。
- 构建未传 API define，实际默认地址 `https://wenyou.site/api/v1`。当前公网未发布字体契约及资源，此包仅为开发验证产物，不构成已通过完整门禁的发布候选。未安装，设备内 APK 哈希、启动和字体真机关键路径均未验证。

## 负责人真机清单

1. 核对安装目标为 `site.wenyou.app.debug`，再核对更新时间和设备内 APK SHA-256；不能只看同构建号。当前尚未安装。
2. 在可用字体环境进入主题或共享帖子编辑器，选跨行正文切换字体，检查颜色、粗体、斜体、删除线、链接、代码，撤销/重做与恢复默认；图片、提及、骰子不被染入字体。
3. 在已核验隔离环境手动保存并重开，检查段落、空段、字体范围及原子归属；关闭新增字体后保持/删除历史范围，并确认不允许增加/修改范围。线上自动化只读。
4. 阅读三款 BOOTH 的简中缺字、篆书英文/空格，验证平台可读回退；小城拉风体不可选。断网重开已有缓存，检查未缓存字仍可读且正文 ID 不丢失。
5. 320px 小屏、200% 字号、暗色、横向系统字体回退、快速切页及八家族以上连续阅读；检查截字、选区和光标、滚动跳动与预算耗尽。真实设备 RSS 与字体驻留内存仍待测量。
6. 确认应用 UI、主题标题、动态与私聊继续使用原有系统字体。当前负责人验收结果：未收到。

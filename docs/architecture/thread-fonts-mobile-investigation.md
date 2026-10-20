# 主题帖字体 Mobile 接入调查

状态：前置调查，尚未实现字体功能；等待治理交接已提交 Backend 契约。保持最新已发布 Foundation；仅当实际变更其机器契约或运行产物时才等待新正式 Tag。

## 范围与基线

- 治理任务：`01a15a8c-53c1-7203-a4c5-6c9d5fc731de`。
- Windows Worktree：`D:\codex-worktrees\1528\wenyousite-mobile`。
- 分支：`codex/20261021-thread-fonts-mobile`，从 fetch 后的 `origin/dev`（`6f0064507a77e2034250ee4fd9f1d382e0a063a9`）创建。
- 目标：主题正文、子贴、楼层和回复局部选字字体；按负责人最新调整，首批为 15 个家族，不补足 30。默认恢复、最近使用及与合法格式组合；中英与符号覆盖按实际资源核验，缺字可读回退。不改变应用 UI 系统字体，不捆入字体全集。
- 2026-10-21，记录的 Backend、只读镜像 `origin/dev`、公网只读 `/meta.buildSha` 均为 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`，HTTP 契约 `5.40.0-dev.20261018.1`。未发现需先同步的契约 revision 变化；尚无本目标协议 SHA。
- Foundation 已执行 `git fetch origin --tags`；最新正式 `v7.6.0` 指向 `1bbd5a5476b50c51d2bba1f2a218f9408a852c4a`。相对 `v7.5.0` 的 Flutter 库只变更版本常量；Mobile profile、品牌资源及颜色规则保持不变。先独立升级固定 Tag 和锁文件；字体业务协议由 Backend 承担，消费者可能继续使用 `v7.6.0` UI Token，是否需要新 Foundation 发布以实际变更为准。
- 已阅读治理 AGENTS、任务分派、本仓 AGENTS、editor 和 threads 模块文档，以及 Markdown 实现与固定契约。本仓没有 `docs/modules/markdown.md`；Markdown 属于 `lib/core/markdown`，行为文档归 editor、threads、posts 等消费者。
- 默认 Auto-review 偏好已收到；实际宿主为 `approval_policy=never`、文件系统 unrestricted，未设置或核验 `resolvedApprovalsReviewer=auto_review`，不能声称已启用“帮我批准”。
- 治理已通知 VPS 代理修复、Backend/Foundation/Web 原任务恢复；Mobile 尚未收到已提交 Backend 字体契约 SHA，保持当前任务、分支与 PR 等待正式交接，不持续轮询。首批每家族只采用一个默认字重。

## 首批名单与资源状态

本名单取代此前 30 款输入。保留 11 款：思源黑体、无界黑、朱雀仿宋、霞鹜文楷、小赖、龙藏体、流江毛草（Liu Jian Mao Cao）、铁蒺藜、缝合像素、站酷快乐体、站酷小薇体。

新增 4 款：

| 字体 | 治理提供的索引页面 | 当前资源状态 |
| --- | --- | --- |
| 侵食明朝 | https://www.maoken.com/freefonts/29703.html | 待原 ZIP 与内部许可证、RFN、覆盖及哈希核验 |
| 冒险黑体 | https://www.maoken.com/freefonts/29709.html | 待原 ZIP 与内部许可证、RFN、覆盖及哈希核验 |
| 怪聞書 | https://www.maoken.com/freefonts/29697.html | 待原 ZIP 与内部许可证、RFN、覆盖及哈希核验 |
| 白光明朝 | https://www.maoken.com/freefonts/29628.html | 待原 ZIP 与内部许可证、RFN、覆盖及哈希核验 |

治理交接称新增 4 款已追溯作者 lavsic 的 BOOTH 官方页面，页面声明 OFL 1.1，但原 ZIP 下载需登录；Mobile 尚未核验源文件。以上索引不作为下载目录，不用预览替代完整字库，不将这些字体标为可用，也不编造资源 ID、字符覆盖或摘要。

此前被移除的 19 款不再属于首批范围。目录、测试矩阵与预算均以这 15 款和待交接的 audit-v3 为准；此前 30 款的源字库及测试子集总量不能作为新名单预算，测试子集也不视为正式资源。保留 11 款同样须经 Backend 已提交目录交接后才接入。

## 已核查的影响面

| 链路 | 代码入口 | 字体接入要求 |
| --- | --- | --- |
| 能力 | `app_capabilities.dart`、`meta_repository.dart`、`editor_capabilities.dart` | 分离读取、创建与历史保存能力；具体字段等 Backend 固定 |
| 读取声明 | `network_providers.dart` | 当前两处客户端配置使用 `X-Text-Color-Version: 1`；字体读取协商须同步检查匿名与认证路径，不能沿用颜色版本代表字体能力 |
| 解析 | `markdown_text_color.dart`、`markdown_rich_line_decoder.dart`、`markdown_inline_runs.dart` | 当前颜色内部禁止嵌套 HTML；需共享用例确定字体和颜色组合、顺序、交叉与非法标记 |
| Codec | `markdown_delta_inline_encoder.dart`、`markdown_delta_block_encoder.dart`、`markdown_delta_semantics.dart` | 当前普通属性白名单没有 font；同步编码、解码、语义等价和保存保护，不能只放行属性 |
| 编辑会话 | `literal_text_quill_controller.dart`、`rich_editor_session.dart`、`editor_text_color_selection.dart` | 范围修改跳过换行和原子；跨段一个撤销步骤；恢复默认只清字体；保留中文组合输入、选区与其他属性 |
| 格式 UI | `editor_text_color_palette.dart`、`editor_text_color_configuration.dart`、`editor_toolbar.dart` | 现有格式面板中的轻量选择，最近使用按账号隔离；字体目录预览不能加载全部 15 个完整家族 |
| 阅读 | `wenyou_markdown.dart`、`markdown_text_color_builder.dart`、`wenyou_markdown_body.dart` | 编辑与阅读共用已解析家族；按可见内容调度，异步加载后重排需检查滚动位置与选择 |
| 复制与摘要 | `editor_site_clipboard.dart`、`editor_clipboard_paste.dart`、`markdown_clipboard_text.dart`、`markdown_plain_text_preview.dart` | 站内保留字体；外部 CSS 不获任意资源加载权；摘要输出可见文字，代码内标记保持字面语义 |
| 写入与恢复 | threads 三类 repository、`post_repository.dart`、`content_draft_repository.dart`、`markdown_write_guard.dart` | 创建主题、聚合草稿、子贴、主楼/回复、正文 upsert、云草稿均接入声明与旧后端保护 |
| 持久化请求 | `thread_compose_models.dart`、`post_publish_draft.dart`、本机 Markdown 快照 | 恢复旧快照和待确认请求时保持原能力与幂等语义；不静默剥字体后重发 |

## 动态加载可行性与限制

本机 Flutter SDK `services/font_loader.dart` 明确支持 TTF/OTF，通过 `dart:ui.loadFontFromList` 注册字体家族。固定 Quill 提交 `c273155025d1255335a6dd3e6ecd3700d29f103e` 的 `text_line.dart` 已把 `Attribute.font` 映射为 `TextStyle.fontFamily`，具备基础渲染入口。官方参考：[FontLoader](https://api.flutter.dev/flutter/services/FontLoader-class.html)、[loadFontFromList](https://api.flutter.dev/flutter/dart-ui/loadFontFromList.html)。

这些是源码/API 可行性证据，尚非首批 15 个目标家族的中文覆盖、字重、渲染一致性或 Android 内存实测。

- 公开 FontLoader API 没有字体卸载接口。磁盘 LRU 淘汰不能释放已经注册的引擎字体；运行时必须在加载前限制累计家族数及累计文件字节，达到上限后保留字体语义、使用可读回退，不做“淘汰后无限加载”。
- 家族注册名应由受信目录身份与资源摘要确定，防止不同版本复用一个名字。保存的协议 ID 与本地注册名分离，具体 ID 形状等待正式契约。
- 同一资源下载、校验和注册均需并发去重；限制全局在途数，不能因预构建整栋楼而提前下载所有字体。
- 磁盘先写临时文件，校验大小与 SHA-256 后原子就绪；缓存命中仍须处理损坏、目录升级与被系统清理。错误有界、显式重试，不能用自动循环耗尽流量。
- 下载只接受后端版本化目录规定的资源，需核验来源、重定向、最大字节与格式。不能把正文属性或外部剪贴板 URL 直接交给下载器。
- 首批资源不进入 `pubspec.yaml` 字体资产；选择列表优先目录提供的小样本图片。小样本字体也会占引擎注册槽位，不能默认认为没有驻留成本。
- 每家族只有一个默认字重时，仍保留用户粗体、斜体属性。需逐家族验证引擎合成/回退后的实际显示与中英字形一致性，不能通过删除格式规避缺少字重文件。
- 缺字、未知 ID、离线及注册上限应保留原文可读与原始标记。未知协议的可编辑/只读保护须按共享契约处理，不能只靠平台静默 fallback 就允许破坏性保存。

磁盘容量、驻留家族数量、累计字节预算以及可见区预取范围尚未固定；应由新名单 15 家族的正式资源大小、分片方案和 Android 测量决定，不能按旧名单总量推算或在契约未知时制造跨端规范。

现有 `wenyou_markdown.dart`、`rich_editor_session.dart` 和帖子编辑页面接近 900 行门槛，新增实现需先按职责提取组件/服务；不得追加 allowlist 或机械迁入超大 part 文件。

## 必要交接

1. Backend 完整提交 SHA、分支、版本化目录、首批 15 家族 audit-v3 及中文/拉丁/符号覆盖、内部许可与 RFN、TTF/OTF 正式资源、分片方案、大小/摘要和预览资源；未核验资源保持不可用。
2. 字体 Markdown 标记与版本、能力门禁、读取协商、各写 DTO 声明、未知 ID/版本、停写但保留历史内容、旧客户端投影和错误语义。
3. 字体与颜色/粗体/斜体/删除线/链接/代码、跨行/空行、转义/未知标记、原子、站内与外部剪贴板的固定语料。
4. 保持最新已发布 Foundation；由治理交接 UI 系统字体与用户正文业务字体的边界结论。只有实际变更 Foundation 机器契约或运行产物时才等待新正式 Tag，不预设选择器接入必然需要发布新版本；未发布运行产物不作为消费者依赖。
5. 隔离测试资源身份或离线真实组件入口；本轮不接管其他任务设备或 Debug 进程。

## 验证安排与当前证据

依赖准备先验证主题、品牌资产、颜色选区和颜色组合，记录实际结果。字体实现后覆盖 Codec 可见文字/空段/块归属、控制器中文输入/撤销/跨行、粘贴/保存重开、各 repository 能力门禁及请求恢复，再验证下载去重、损坏恢复、淘汰、断网与驻留上限。

2026-10-21 定向验证：`flutter test` 显式执行 `test/app/app_theme_test.dart`、`test/tool/foundation_brand_assets_test.dart`、`test/features/editor/editor_text_color_selection_test.dart`、`test/core/markdown/markdown_text_color_combinations_test.dart`，23 项通过。后者覆盖四组 1024 种相邻样式组合；品牌资源摘要一致。两份改动 Dart 测试文件格式无差异，架构与 23 个模块文档检查通过。

同日完整 `npm run check:apk -- -TestConcurrency 2` 通过：OpenAPI、固定来源、再生成无差异、公网只读兼容、全仓格式、应用与生成客户端分析、架构、模块文档、API 覆盖、7308 项 Flutter 测试（1 项既有跳过）、49 项 Windows 工具测试及 ARM64 Debug 构建。独立全量应用静态分析也为零问题。检查后仅补充文档，不再修改应用或依赖。

- 日志：本 Worktree `.dart_tool/thread-fonts-foundation-check.log`，SHA-256 `54af8db227435ddb51361cd5aec1e8ae58919c8cb2e8fd17273bc292b8d33893`。
- APK：`build/thread-fonts-baseline/app-foundation-7.6.0-debug.apk`；由本次成功门禁的 `build/app/outputs/flutter-apk/app-debug.apk` 保存，供后续同条件比较。
- 实际包名 `site.wenyou.app.debug`，versionName `0.10.0-debug`，versionCode `100`，最低 API 26，仅 `arm64-v8a`。
- 大小 `112831150` 字节，SHA-256 `8caf842c47ba75b01406e81a3805e0ba29cd031fa7ff3edb61e782f085ed4ce0`。
- 构建出现既有 `flutter_image_compress_common` KGP 迁移及 SDK XML 工具版本提示，未导致失败；本次未扩大依赖升级范围。
- 未安装、未启动 Debug、未接管设备；没有人工画面或字体功能验收。升级复验可由负责人检查明暗主题、普通正文编辑/阅读和已有取色面板；涉及线上发布/上传仍由负责人手动决定。

真实画面需要明暗、窄屏、大字号下编辑/阅读对照，包含多字体长楼与滚动回退。单个/多个字体的下载量、冷暖缓存耗时、磁盘占用、注册数和内存须分别测量；包体积对比使用相同构建条件。本轮尚无这些数据、截图或设备验收。

本目标涉及契约、网络和持久化，最终候选须执行 `npm run check:apk` 并提供负责人真机清单；当前依赖准备与调查不能代表字体功能候选或完成。

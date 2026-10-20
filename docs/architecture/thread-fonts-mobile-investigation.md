# 主题帖字体 Mobile 接入调查

状态：已收到并同步 Backend PR #56 的正式候选契约 `1cf51dd752a98e3733f3dc0c83b17add75be7e46`，开始消费者实现；尚未交付字体功能或取得真机验收。Foundation 保持最新正式 v7.6.0。

正式交接：API `5.41.0-dev.20261021.1`，17 款目录中 16 款 ready、小城拉风体 pendingSource。正式 ID 为 `shattered-display`、`xiaocheng-lafeng`、`jf-zsk-seal`，替代研究别名。VPS `/tmp/thread-font-release-publish` 含正式分片与声明对象，Mobile 预览只读取这些构建资产；研究 audit3500 子集不代表正式 core 覆盖。清单 SHA-256 `ad22427e048b90f798bddafc308195786600ee006459f54144610d1bbe35d5c3`，3,207,159 B；资源基址未发布时不发字体请求。下文保留前置调查过程，当前交接状态以本段为准。

## 范围与基线

- 治理任务：`01a15a8c-53c1-7203-a4c5-6c9d5fc731de`。
- Windows Worktree：`D:\codex-worktrees\1528\wenyousite-mobile`。
- 分支：`codex/20261021-thread-fonts-mobile`，从 fetch 后的 `origin/dev`（`6f0064507a77e2034250ee4fd9f1d382e0a063a9`）创建。
- 目标：主题正文、子贴、楼层和回复局部选字字体；按负责人最新选款 revision 4，首批为 17 个家族，不补足 30。默认恢复、最近使用及与合法格式组合；中英与符号覆盖按实际资源核验，缺字可读回退。不改变应用 UI 系统字体，不捆入字体全集。
- 2026-10-21，记录的 Backend、只读镜像 `origin/dev`、公网只读 `/meta.buildSha` 均为 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`，HTTP 契约 `5.40.0-dev.20261018.1`。未发现需先同步的契约 revision 变化；尚无本目标协议 SHA。
- Foundation 已执行 `git fetch origin --tags`；最新正式 `v7.6.0` 指向 `1bbd5a5476b50c51d2bba1f2a218f9408a852c4a`。相对 `v7.5.0` 的 Flutter 库只变更版本常量；Mobile profile、品牌资源及颜色规则保持不变。先独立升级固定 Tag 和锁文件；字体业务协议由 Backend 承担，消费者可能继续使用 `v7.6.0` UI Token，是否需要新 Foundation 发布以实际变更为准。
- 已阅读治理 AGENTS、任务分派、本仓 AGENTS、editor 和 threads 模块文档，以及 Markdown 实现与固定契约。本仓没有 `docs/modules/markdown.md`；Markdown 属于 `lib/core/markdown`，行为文档归 editor、threads、posts 等消费者。
- 默认 Auto-review 偏好已收到；实际宿主为 `approval_policy=never`、文件系统 unrestricted，未设置或核验 `resolvedApprovalsReviewer=auto_review`，不能声称已启用“帮我批准”。
- 治理已通知 VPS 代理修复、Backend/Foundation/Web 原任务恢复；Mobile 尚未收到已提交 Backend 字体契约 SHA，保持当前任务、分支与 PR 等待正式交接，不持续轮询。首批每家族只采用一个默认字重。

## 首批名单与资源状态

负责人最新选款 revision 4 的目标为 17 款，不补足 30，取代此前 15 款目标。保留原 11 款、侵食明朝／冒险黑体／白光明朝，新增嗷呜碎黑体、小城拉风体、敬峰中山王篆，移除怪聞書（kaibunsyo）。

原 11 款已在治理 audit-v3 阶段完成研究侧核验：思源黑体、无界黑、朱雀仿宋、霞鹜文楷、小赖、龙藏体、流江毛草（Liu Jian Mao Cao）、铁蒺藜、缝合像素、站酷快乐体、站酷小薇体。

其余 6 款的当前交接状态：

| 字体 | 治理提供的索引页面 | 当前资源与授权状态 |
| --- | --- | --- |
| 侵食明朝 | [索引](https://www.maoken.com/freefonts/29703.html) | 用户已提供 `ShinsyokuMincho.zip`，治理正在核验原包 SHA、内置许可、覆盖与体积 |
| 冒险黑体 | [索引](https://www.maoken.com/freefonts/29709.html) | 用户已提供 `BoukenGothic.zip`，治理正在核验原包 SHA、内置许可、覆盖与体积 |
| 白光明朝 | [索引](https://www.maoken.com/freefonts/29628.html) | 用户已提供 `HakkouMincho_v1.004.zip`，治理正在核验原包 SHA、内置许可、覆盖与体积 |
| 嗷呜碎黑体 | [索引](https://www.maoken.com/freefonts/29521.html) | 治理指向官方 `howlingFounts/ShatteredDisplay`，待 audit-v4 正式资源证据 |
| 小城拉风体 | [索引](https://www.maoken.com/freefonts/27663.html) | 负责人本轮确认本项目已取得使用授权，按该陈述推进接入；待正式资产与完整字体成本交接 |
| 敬峰中山王篆 | [索引](https://www.maoken.com/freefonts/27589.html) | 治理指向官方 `jeffi369/JFZSKSealScript`，待 audit-v4 正式资源证据 |

治理交接称保留的 3 款 BOOTH 字体已追溯作者 lavsic 的官方页面，页面声明 OFL 1.1。用户已将完整 ZIP 下载至 `D:\Download`，治理已找到上表三份原包并正在核验；当前不再是 `download_blocked_login`，不重复请求用户下载。Mobile 等待治理交接固定 SHA 资产和 audit-v4，不将“文件已取得”写成内部许可/RFN、覆盖或体积已核验。以上索引不作为下载目录，不用预览替代完整字库，不将待核验字体标为可用，也不编造资源 ID、字符覆盖或摘要。

小城拉风体的本项目使用授权依据为负责人本轮明确确认，按该陈述推进接入，不再仅因网页一般条款挂起，也不重复请求授权。此确认不改写为 OFL，不虚构授权文书或声称 Mobile 已审查原始授权文件。网页所述一般条款与本项目授权依据分别保留；具体资源处理按本项目授权及正式资产交接执行，不套用 OFL 推定修改、转换或拆分权利，当前完整字体成本仍待核验。

怪聞書已退出当前目标。本仓此前仅在调查文档记录该名称，未引入其 fontId、资源目录或消费者实现；不制造已上线、需迁移或清理旧客户端的假设。后续若 Backend 已提交版本包含相关 ID，按交接的版本兼容事实处理。

目录、测试矩阵与预算以 revision 4 的 17 款及待交接 audit-v4 为准。此前 30 款或 15 款目标下的实验子集数据不作为正式资源或本批总预算；所有字体均须经 Backend 已提交机器目录交接后才接入。

治理提供的原 11 款、3615 码点实验子集合计 SFNT `18,710,648 B`、WOFF2 `9,640,808 B`；这仅是 11 款实验文件成本，不是当前 17 款总量，也不是运行内存。证据来源为治理工作区 `audit-v3/font-audit-evidence.json` 的阶段交接，Mobile 未将其导入应用或当作正式资源。通用协议工作不因资源审计暂停，消费者协议实现仍等待 Backend 已提交契约。

## 已核查的影响面

| 链路 | 代码入口 | 字体接入要求 |
| --- | --- | --- |
| 能力 | `app_capabilities.dart`、`meta_repository.dart`、`editor_capabilities.dart` | 分离读取、创建与历史保存能力；具体字段等 Backend 固定 |
| 读取声明 | `network_providers.dart` | 当前两处客户端配置使用 `X-Text-Color-Version: 1`；字体读取协商须同步检查匿名与认证路径，不能沿用颜色版本代表字体能力 |
| 解析 | `markdown_text_color.dart`、`markdown_rich_line_decoder.dart`、`markdown_inline_runs.dart` | 当前颜色内部禁止嵌套 HTML；需共享用例确定字体和颜色组合、顺序、交叉与非法标记 |
| Codec | `markdown_delta_inline_encoder.dart`、`markdown_delta_block_encoder.dart`、`markdown_delta_semantics.dart` | 当前普通属性白名单没有 font；同步编码、解码、语义等价和保存保护，不能只放行属性 |
| 编辑会话 | `literal_text_quill_controller.dart`、`rich_editor_session.dart`、`editor_text_color_selection.dart` | 范围修改跳过换行和原子；跨段一个撤销步骤；恢复默认只清字体；保留中文组合输入、选区与其他属性 |
| 格式 UI | `editor_text_color_palette.dart`、`editor_text_color_configuration.dart`、`editor_toolbar.dart` | 现有格式面板中的轻量选择，最近使用按账号隔离；字体目录预览不能加载全部 17 个完整家族 |
| 阅读 | `wenyou_markdown.dart`、`markdown_text_color_builder.dart`、`wenyou_markdown_body.dart` | 编辑与阅读共用已解析家族；按可见内容调度，异步加载后重排需检查滚动位置与选择 |
| 复制与摘要 | `editor_site_clipboard.dart`、`editor_clipboard_paste.dart`、`markdown_clipboard_text.dart`、`markdown_plain_text_preview.dart` | 站内保留字体；外部 CSS 不获任意资源加载权；摘要输出可见文字，代码内标记保持字面语义 |
| 写入与恢复 | threads 三类 repository、`post_repository.dart`、`content_draft_repository.dart`、`markdown_write_guard.dart` | 创建主题、聚合草稿、子贴、主楼/回复、正文 upsert、云草稿均接入声明与旧后端保护 |
| 持久化请求 | `thread_compose_models.dart`、`post_publish_draft.dart`、本机 Markdown 快照 | 恢复旧快照和待确认请求时保持原能力与幂等语义；不静默剥字体后重发 |

## 动态加载可行性与限制

本机 Flutter SDK `services/font_loader.dart` 明确支持 TTF/OTF，通过 `dart:ui.loadFontFromList` 注册字体家族。固定 Quill 提交 `c273155025d1255335a6dd3e6ecd3700d29f103e` 的 `text_line.dart` 已把 `Attribute.font` 映射为 `TextStyle.fontFamily`，具备基础渲染入口。官方参考：[FontLoader](https://api.flutter.dev/flutter/services/FontLoader-class.html)、[loadFontFromList](https://api.flutter.dev/flutter/dart-ui/loadFontFromList.html)。

这些是源码/API 可行性证据，尚非首批 17 个目标家族的中文覆盖、字重、渲染一致性或 Android 内存实测。

- 公开 FontLoader API 没有字体卸载接口。磁盘 LRU 淘汰不能释放已经注册的引擎字体；运行时必须在加载前限制累计家族数及累计文件字节，达到上限后保留字体语义、使用可读回退，不做“淘汰后无限加载”。
- 家族注册名应由受信目录身份与资源摘要确定，防止不同版本复用一个名字。保存的协议 ID 与本地注册名分离，具体 ID 形状等待正式契约。
- 同一资源下载、校验和注册均需并发去重；限制全局在途数，不能因预构建整栋楼而提前下载所有字体。
- 磁盘先写临时文件，校验大小与 SHA-256 后原子就绪；缓存命中仍须处理损坏、目录升级与被系统清理。错误有界、显式重试，不能用自动循环耗尽流量。
- 下载只接受后端版本化目录规定的资源，需核验来源、重定向、最大字节与格式。不能把正文属性或外部剪贴板 URL 直接交给下载器。
- 首批资源不进入 `pubspec.yaml` 字体资产；选择列表优先目录提供的小样本图片。小样本字体也会占引擎注册槽位，不能默认认为没有驻留成本。
- 每家族只有一个默认字重时，仍保留用户粗体、斜体属性。需逐家族验证引擎合成/回退后的实际显示与中英字形一致性，不能通过删除格式规避缺少字重文件。
- 缺字、未知 ID、离线及注册上限应保留原文可读与原始标记。未知协议的可编辑/只读保护须按共享契约处理，不能只靠平台静默 fallback 就允许破坏性保存。

磁盘容量、驻留家族数量、累计字节预算以及可见区预取范围尚未固定；应由 revision 4 名单 17 家族的正式资源大小、各自授权允许的分发方式和 Android 测量决定，不能按旧名单总量推算或在契约未知时制造跨端规范。

现有 `wenyou_markdown.dart`、`rich_editor_session.dart` 和帖子编辑页面接近 900 行门槛，新增实现需先按职责提取组件/服务；不得追加 allowlist 或机械迁入超大 part 文件。

## 必要交接

1. Backend 完整提交 SHA、分支、版本化目录、首批 17 家族 audit-v4 及中文/拉丁/符号覆盖、内部许可与 RFN、TTF/OTF 正式资源、按授权允许的分发方式、大小/摘要和预览资源；小城拉风体记录负责人本轮确认的项目使用授权，待正式资产和完整字体成本交接；三份 BOOTH ZIP 已取得，待固定 SHA 与审计结果，不再请求下载或授权。
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

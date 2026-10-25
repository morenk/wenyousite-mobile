# 六项未合并 PR 的组合验收候选

状态：负责人于 2026-10-25 明确验收通过，并授权合并与清理任务分支。已验收 APK 的 SHA-256 为 `D46922D5BE45596539126D1FD0AC7DE5A5E7E359BFC50286CCA06845AAC44AD3`，交付源码为 `27629010f47c74da96868774cfd3157de9603f75`。

本轮仅补充验收记录，应用、测试、契约、依赖和原生源码不变。按负责人明确要求，复用下述完整门禁结果，不重复全量测试或构建。六项通过组合 PR #120 合入 `dev`；#99 仍不在授权范围。清理前将 APK 和检查证据保留到 `D:\codex-artifacts\mobile-six-pr-accepted-20261025`，不发布或部署。

## 范围与来源

初始基线为 `origin/dev@b7e1a4acf9433b38b29505834b5f1eea77598330`。每个原 PR 保留独立分支及提交，使用普通 merge 更新基线；组合分支 `codex/20261025-mobile-pr-acceptance` 只用于共同验证与负责人验收。

沿用该基线固定的 Backend 契约提交 `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`、API `5.44.0-dev.20261024.3` 与 Foundation `v7.6.0`；本轮没有修改契约、生成客户端、依赖或 Android／iOS 原生配置。检查与构建使用 Windows 上的 Flutter `3.44.8`／Dart `3.12.2`。

| 顺序 | 原 PR | 验收目标 | 本轮纳入提交 |
| --- | --- | --- | --- |
| 1 | [#101](https://github.com/morenk/wenyousite-mobile/pull/101) | 网络故障降噪、后台冷却与显式恢复 | `91efa3c390f166a4467cf591ca4c0865f1b0e972` |
| 2 | [#103](https://github.com/morenk/wenyousite-mobile/pull/103) | 编辑器失效范围、提及与异步链接保护 | `dc29601fe30302ff31d176c96f57571ec6fa99e4` |
| 3 | [#100](https://github.com/morenk/wenyousite-mobile/pull/100) | 分隔线边界、保存诊断与粘贴预检 | `c6921fbe3d9a4e286cf333c4f1c949e2ee61d10b` |
| 4 | [#76](https://github.com/morenk/wenyousite-mobile/pull/76) | 尖括号、对齐元信息与打开诊断 | `3e5a90c2e7f414b849c2080304fc1eefe35bb856` |
| 5 | [#104](https://github.com/morenk/wenyousite-mobile/pull/104) | 图片 PUT 失败的同 ID 恢复 | `fc3f38db334514846325d9c86a3d1d86bbc2b728` |
| 6 | [#92](https://github.com/morenk/wenyousite-mobile/pull/92) | 评论自动续页与失败暂停 | `2a88bb32a2d9335b849a5afd8ac9b531003a7ce5` |

[#99](https://github.com/morenk/wenyousite-mobile/pull/99) 的 APK 直连存储不纳入此包。其后端配套未合并，旧候选还包含过时契约；后续需在后端兼容条件满足后单独更新和验收。

## 组合适配

- 最新字体 v1/v2、颜色、结构化剪贴板、音频、图库与安全区继续来自当前 dev。
- 范围校验必须在编辑事务、历史与音频投影之前执行；分隔线维护与实际输入属于同一撤销事务。
- 粘贴预检与实际输入共用分隔线规范化，保存 Codec 的严格结构校验保持。
- 尖括号保护同时识别真实字体与颜色标签；实体形式的标签仍保留为可见文字。
- 两个 Sentry 稳定性分支共享的文案审计只保留一份，不扩大豁免阈值。
- 评论自动续页接入当前公共分页实现，失败暂停、代次保护与一次失效游标恢复继续有效。

已处理 #103/#100 控制器冲突：先读取有效区间，成功后才进入事务；正文替换与分隔线维护共用一个事务，保留实际 Delta 长度的光标修正。已处理 #100/#76 诊断冲突：保存失败保留结构数量字段，打开保护保留白名单原因映射；两种诊断都不采集正文。#92 仅变更日志冲突，保留双方记录，生产代码自动合入。

已处理 #101/#104 鉴权冲突：继续由请求的后台标记决定刷新是否受冷却约束；不重放 POST，只有刷新成功且会话仍有效时才标记可明确重试。请求开始及标记成功均复制 `extra`，保留既有策略键并支持不可变输入。动态／评论的失败弹层尊重任务可重试性，弹层返回后再次核验当前状态。

控制器的 #103/#100 冲突与网络的 #101/#104 冲突均经过另一协作代理只读复核，未发现确定阻断。新增组合回归分别检查失效范围后在分隔线旁粘贴字体／实体标签、单步历史／保存重开，以及后台冷却期间同 ID 上传恢复／续期后明确重试。复核不能代替下方实际检查结果。

## 检查证据

原 PR 的本轮定向检查用于验证各自适配；最终应用源码在本组合 Worktree 通过官方 `npm run check:apk` 执行完整门禁与构建。历史 APK、历史完整门禁及单独定向通过均不能代替本轮组合完整门禁。

- #101：163 项定向通过、0 跳过、0 失败；契约再生成零差异、只读公网兼容、1556 文件格式、应用与 SDK 全量分析、架构、23 模块文档、API 覆盖通过。检查源码树 `e217b8382eda2ef1d5277fc3f95c949f9c0590ba`，交付提交仅在其上补充两份记录文档。详见[原候选记录](sentry-network-recovery-candidate.md)。

- #103：23 个文件、244 项定向通过；14 个改动 Dart 文件格式／分析、架构与 23 模块文档通过。当前 dev 的普通／音频控制器旧实现出现 10 项真实失效范围断言失败，2 项已有剪贴板签名保护通过；候选恢复后通过。详见[原候选记录](editor-range-candidate.md)。

- #100：18 个文件、168 项定向通过，15 个差异 Dart 文件格式／分析、架构和 23 模块文档通过。旧粘贴预检发生真实失败；首轮适配发现 4 项光标重复补偿失败，修正后全部通过。详见[原候选记录](editor-sentry-save-candidate.md)。

- #76：23 个文件、619 项定向通过，含原楼层 2813 字符／9 个居中块及真实页面保存重开；1560 文件格式、21 个差异 Dart 文件分析、架构和 23 模块文档通过。旧字体路径 2 项反证失败，首轮遗漏打开保护的颜色前缀判断导致 102 项字体相关失败，修正后全部通过。冻结检查树 `981d8f9acdee51057201b049abdc3da107db8d9a`，详见[本轮记录](editor-angle-integration-20261025.md)。

- #104：417 项定向通过，23 个差异 Dart 文件格式／分析、架构和 23 模块文档通过。冻结检查树 `34095c09a659b5c05c04fda741f004964cb6d764`。新增实际图库页面、鉴权续期及失败弹层回归；刷新后无法手动重试、不可变请求参数及弹层绕过重试限制的失败历史与修正见[上传候选记录](sentry-upload-recovery-candidate.md)。

- #92：初始 8 文件 95 项定向通过，4 张 Golden 更新后逐张查看（320 黑夜、360／400／600 明亮双倍字）并非更新复跑通过。首次冻结树 `6ab729314ba35d67329fe72c8ddb90a69c72fb42`。组合文案审计失败后追加类型化修正，最终冻结树 `1de71a6f47acc9167b42a6bb5b591b4c6d29c769`；97 个相关场景和 6 项原样 AST 文案测试分批验证通过，原分支计数从 421 收敛到 418。新增页面测试首轮两处标题断言与内联组件不符，改为实际消息后整个页面文件 9 项通过；生产没有因此改展示。最终 7 个差异 Dart 格式／分析、架构、23 模块文档通过，Golden 非更新通过且字节未变。详细命令、首轮失败及最终检查见[评论候选记录](moment-comment-autoload-candidate.md)。

组合首轮定向为 12 通过／1 失败：编辑器重开后的源码分隔行位置不同，原测试将原始 Quill 换行位置误作编辑块身份。输入后的精确光标、单步撤销／重做、阅读器四个块及可见样式均已通过；改为只过滤明确标记的源码分隔行，核对四个实际编辑块、分隔线属性、真实空段及再次保存不漂移。应用源码未因此修改；首轮日志保留为 `build/combined-acceptance-20261025/combination-regressions.log`，不计为通过。

组合定向最终命令为 `flutter test --no-pub --concurrency=1 --reporter expanded test/features/editor/editor_combined_pr_acceptance_test.dart test/features/media/media_network_recovery_integration_test.dart test/core/diagnostics/diagnostic_enrichment_test.dart`：13 项通过、0 跳过／失败、退出 0。两项新增上传测试使用封闭内存 HTTP adapter，所有未登记请求直接失败；没有真实网络回退。日志位于组合 Worktree 的 `build/combined-acceptance-20261025/`：

| 日志 | 结果 | SHA-256 |
| --- | --- | --- |
| `combination-regressions.log` | 首轮 12 通过／1 失败，保留 | `51A892EF22432EB25B32869E7D53C1A1D5224A3596B7B33D82192E6B13110089` |
| `combination-regressions-retry1.log` | 最终 13 通过 | `F504DBE745D9F3021DD4AC4DE7D245E1297700A2EAC1DC4D3B1BB2F09B599DF6` |

首轮完整门禁以 `3add3b47723d8eabdf54ffed0ff5d031c4ec4a12` 冻结树为输入，命令为 `npm run check:apk -- -TestConcurrency 1`，日志 `build/combined-acceptance-20261025/check-apk.log`。契约校验／来源核验／再生成零差异、公网只读兼容检查、1588 文件格式、应用与生成客户端全量分析、架构、23 模块文档及 API 覆盖 175/175 通过；Flutter 测试 8090 通过、1 项既有真实 Sentry 收件验收跳过、1 失败，测试阶段 56:41，门禁退出 1，没有进入 Windows 工具测试或 APK 构建。失败为旧式 `ApiFailure(userMessage: ...)` 构造数量 420 超过固定上限 418，日志 SHA-256 `6631D7CA0A57D3759FD6F970F4D0AB8702F0FB82B13D5679FEFF483AEAA3517E`。首轮源码与冻结树一致，失败不计通过，也不使用历史 APK。

定位到 #92 自动续页的三处新构造（替换 dev 一处，净增两处）：游标缺失、不前进／循环及重复失效游标。此前 #92 的独立定向没有包含组合分支的 AST 文案审计，未提前发现。修正已回传原 PR，使用现有类型化错误和展示映射，保留固定上限；补查发现缺失当前游标时原明确重试也会停在空游标，现改为用户明确重试才重读首页，自动加载仍暂停，并覆盖重试互斥、失败后再试及成功恢复续页。

第二轮在没有其他 Dart／Flutter 检查进程、约 4 GiB 可用内存时，将测试并发设为 2；仍通过同一官方入口执行全部检查和测试，不删减矩阵。最终检查源码、退出码与制品以下方完成记录为准。

第二轮前置组合回归：`flutter test --no-pub --concurrency=1 --reporter expanded test/user_facing_copy_test.dart test/features/editor/editor_combined_pr_acceptance_test.dart test/features/media/media_network_recovery_integration_test.dart test/features/moments/moment_comment_pagination_controller_test.dart test/features/moments/moment_comment_pagination_page_test.dart`，31 项通过、0 跳过／失败、退出 0。原样 AST 实现独立遍历 `lib`，精确计数为 417，上限仍为 418。

| 日志 | SHA-256 |
| --- | --- |
| `build/combined-acceptance-20261025/pr92-audit-fix-combined.log` | `C916FE37937AB8DE47217DFAE432ECC333C0EF29AEEFC31673286EC43558326C` |
| `build/combined-acceptance-20261025/legacy-copy-count.log` | `B5608C8FDE2B6E83B6647E85510E4A3E75BF0D556CAB8853490AF8417C6DF342` |

第二轮冻结检查树 `ff2f5a09d8917e2573eb1bc7c745f902fb727426`，构建时分支 HEAD 为 `0d14ef20746a0db72c9f32982433134afe08d4f1`，其上包含已暂存的两项组合测试与交付文档。完整命令 `npm run check:apk -- -TestConcurrency 2`，最终退出 **0**。日志 `build/combined-acceptance-20261025/check-apk-retry1.log`，SHA-256 为 `4E63290C286984C7D7B8C385455F1695E8ED8F6312D5F8571F4C100F45E0ACAA`。

- 契约校验、固定来源核验、客户端再生成零差异、公网只读兼容检查通过。
- 1588 文件格式零改动，应用与生成客户端全量分析零问题，架构、23 模块文档、API 覆盖 175/175 通过。
- 全量 Flutter：**8093 通过、1 跳过、0 失败**，用时 34:32；跳过的是既有真实 Sentry 收件人工验收。此前失败的文案审计本轮通过。
- Windows 工具测试：**49/49 通过**，0 跳过／失败；同次 ARM64 Debug 构建成功，Gradle 阶段 205.5 秒。
- 构建后与冻结树逐路径比较，只有本验收记录变化；应用、测试、工具、契约、依赖及原生源码一致。交付提交将冻结树与后补文档一并提交，其精确 SHA 同步记录在组合 PR 和本地 `verification.json`，不依赖构建时的旧 HEAD 推断测试来源。

## 本轮 APK

本地制品：`D:\codex-worktrees\mobile-pr-acceptance-20261025\wenyousite-mobile\build\combined-acceptance-20261025\wenyou-mobile-six-pr-0.10.0-debug-100.apk`。从本轮 `build/app/outputs/flutter-apk/app-debug.apk` 复制后再次比对，SHA-256 一致。

| 项目 | 核验结果 |
| --- | --- |
| 应用名称／包名 | 温油站 Debug／`site.wenyou.app.debug` |
| 版本／构建号 | `0.10.0-debug`／`100` |
| 架构／最低 Android | 仅 `arm64-v8a`／API 26 |
| 大小 | 114342633 字节（约 109.0 MiB） |
| APK SHA-256 | `D46922D5BE45596539126D1FD0AC7DE5A5E7E359BFC50286CCA06845AAC44AD3` |
| 签名 | `apksigner verify --verbose --print-certs` 退出 0；APK v2，单个 Android Debug 签名者 |
| 签名证书 SHA-256 | `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7` |
| API | `https://wenyou.site/api/v1`；官方构建命令未覆盖 `API_BASE_URL`，使用已核验的 `AppEnvironment.fromDefines()` 默认值 |

`aapt dump badging`、签名输出与结构化记录保存在同目录 `apk-badging.txt`、`apk-signature.txt` 和 `verification.json`。负责人安装后应打开 **温油站 Debug**；本包与正式应用 `site.wenyou.app` 的数据独立，实际网络仍连接下述真实环境。

没有安装或启动应用，没有进行线上业务写入、合并 dev/main、部署、发布、关闭原问题或清理分支。

## 负责人手测

1. 网络：断网后打开既有页面，再恢复网络并显式重试；确认恢复可用，后台不密集重试，不自动重发发布操作。
2. 范围：在原提及、链接或输入法场景中快速编辑、切换选区与关闭页面；确认不再卡住或崩溃，迟到操作不会插入另一段文字。
3. 分隔线：在分隔线两侧输入和粘贴带字体/颜色的内容，撤销、重做、保存并重开；确认分隔线独占一行，正文与光标正确。
4. 尖括号：打开原含居中标记与尖括号的楼层，确认可见文字、居中和斜体正确；检查字体、颜色、实体标签及真实不支持格式的原文保护。
5. 上传：负责人手动选图后中断网络，重开草稿并明确重试；确认原附件恢复、没有重复附件，恢复后仍需明确发送。
6. 评论：分别检查短列表、长列表、接近底部、切换排序、刷新与失败重试；确认自动补足、无重复评论或请求循环，楼中楼仍按原入口展开。

本包 API 为 `https://wenyou.site/api/v1`。该地址属于负责人正在使用的真实环境，人工上传、发送及云草稿保存会作用于实际账号；本包不提供运行时切换 API 的入口。

涉及原手机问题、真实 Sentry 收件、线上网络条件和负责人实际观感的部分仍需人工验收。自动化使用离线夹具或只读兼容检查；独立环境写入 E2E 尚未执行，不能以此包或 Debug 标识宣称数据隔离。

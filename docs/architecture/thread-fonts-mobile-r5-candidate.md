# 正文字体 revision 5 候选记录

状态：最终 29-ready 候选已实现并完成本地验证及 APK 构建；完整门禁仅因公网契约未同步返回非零，仍待负责人真机验收。未合并、部署、安装或接管其他任务设备；旧 APK 不代表本批源码。

## 固定来源与范围

- Backend `102b825379eb5da462f0ff765b29dc8fd7fb93ad`，API `5.41.0-dev.20261021.2`、目录 `1.1.1`。29 款全部 ready，中文 13／日文 10／英文 6。
- 最终 manifest SHA-256 `7aab91a436933049bc8f55c1aba6085078a251d174c5b253456d3af0c91a0582`，5,031,019 B；VPS 只读来源 `/tmp/thread-font-release-complete-publish`。
- 首批 28-ready 来自 `a192628fc1484990871a8d159a7324446cdf0b05`，manifest `e793a3f4674a85840c8da2cd2a5c53f8af62c3c6256a951d269875f4cba2f1e6`。已逐项比较确认最终锁中这 28 款完整 manifest 条目未变，下方实际渲染证据继续适用；原包和记录保留。
- Foundation 已重新 fetch 远端和 tags，最新正式 Tag 仍为 v7.6.0；已读该版本 CHANGELOG，无新增 Flutter 字体迁移。
- 契约同步独立提交 `069564bf`，补齐目录／来源 Schema 并生成客户端。OpenAPI validate、生成客户端分析、`test/core/network/audio_budget_contract_test.dart`、`tool/windows/contract_revision.test.mjs` 均通过。
- 公网只读 `/meta.contractVersion` 与 Backend `origin/dev` 仍为 `5.40.0-dev.20261018.1`，正式候选与公网不同；这是独立未满足项，不通过部署规避。

## 当前实现边界

- 固定 29 个正式 ID，移除未发布候选 `zcoolxiaowei`；旧候选内容沿用未知 ID 保留原文的通用行为，不构造退役迁移。
- 选择器按 manifest `designLanguage` 排列中文／日文／英文组，最近五款仍按账号保存、在对应组内优先显示；语言不表示字形覆盖。未知／缺失语言归“未分类”并禁用，未知 deliveryMode 回退系统字体。
- 普通单资产 6 MiB、下载及注册各 24 MiB、8 家族、32 faces、64 请求（包括声明和清单）、15 秒超时、64 MiB 缓存上限不变。
- 小城仅接受 `xiaocheng-lafeng`、`original` 单分片及 SHA `cf4a4215e562d6de6e3ee88f25fc5d47d77668d28eb3a0f2533c7290de307423`、18,410,600 B。Web/Mobile 必须是同一原始 TTF；只使用正式别名注册，不修改原文件。
- 原件独立额度在下载或缓存首次注册前一次性预留，失败／超时不退还；目录重试、清单刷新与页面重建均不能重置。已注册 face 可重复使用，普通声明或其他字体不能借用额度。它仍占用共享家族、face、请求、超时和缓存预算。
- 理论输入上限为 25,165,824 + 18,410,600 = 43,576,424 B；这不是原生内存或真机 RSS 保证。

## 验证记录

- 最终资源集逐个哈希与大小校验通过：1,799 个对象、303,835,700 B，审计 `.dart_tool/thread-fonts-r5-final-assets-verified.json`。复用 1,676 个已核验对象，仅从正式交接目录读取 123 个新对象。
- 最终源码提交 `97bd14c8`，应用源码 SHA-256 `6f70d880bb22a3026a4edb5fc5462f792acc2a2ef3954f3bf7c480cd85082e35`（1,966 文件）。清单 `.dart_tool/thread-fonts-r5-source-manifest.json` 覆盖 `lib`、生成 API、Android、assets 和两个 pubspec；逐文件 SHA 按路径排序，以 `路径 空格 SHA`、LF 分隔且无尾 LF 再计算总摘要。
- 最终截图总览 `.dart_tool/thread-font-preview-r5-legends/index.html` 共 29 款／58 张正文图片及 6 张选择器图片，按语言过滤；原像素文件未加工。离线工具显式使用当前主题颜色标注“阅读／编辑”，修正部分暗色图例不清晰的问题后重新渲染 8 批全部通过；只改手动预览工具，不改应用源码。日志 `.dart_tool/thread-fonts-r5-legends-0.log` 至 `-7.log`，旧截图保留。
- 怪盗及最终选择器补充预览通过：`.dart_tool/thread-fonts-r5-final-preview-0.log`、`-4.log`；图片及批次数据位于 `.dart_tool/thread-font-preview-r5-final`。怪盗混排样例的 28 个码位全部来自自身字形；实际额外加载假名片 `u003000`，SHA `c9025811126ed706e1d662d2e9e352a19cdbe82f941e388d64ac86eabd182bd4`、677,204 B。最终批次 4 普通注册 16,422,172 B、30 请求、20 faces，未使用原件额度。
- 最终目录相关回归 `test/core/network/audio_budget_contract_test.dart`、`test/core/text_fonts/`、`test/features/editor/editor_text_font_picker_test.dart` 共 22 项通过，日志 `.dart_tool/thread-fonts-r5-final-lock-retest.log`。前一次 21 通过／1 失败是测试滚回中文组时文字仍在视口边缘；补齐滚动结束、居中和点击命中断言后复验，未关闭命中检查，未修改应用行为。
- 针对性验证 41 项通过：`test/core/text_fonts/`、`test/core/markdown/markdown_text_font_test.dart`、`test/features/editor/editor_text_font_picker_test.dart`。日志 `.dart_tool/thread-fonts-r5-targeted-final.log`。随后补充未知语言选择器场景，该文件 3 项全部通过（新增 1 项、复验 2 项），日志 `.dart_tool/thread-fonts-r5-picker-final.log`。
- 原件预算测试用模拟的已验证缓存边界隔离状态机；真实文件 SHA 和 FontLoader 注册必须由离线正式资产预览另行验证，不用模拟字节冒充真实字体。
- 1,677 个正式对象逐个 SHA-256 与大小校验通过，共 269,672,516 B；审计 `.dart_tool/thread-fonts-r5-assets-verified.json`。只读传输曾中断，分段续传后以完整对象哈希确认一致，不以传输成功代替校验。
- 28 款在真实 `WenyouMarkdown` 与 `TextFontQuillEditor` 通过实际 FontLoader 注册、原生字形区别及缺字回退光栅断言，共 56 张 360dp 亮色／320dp 暗色 200% 图片；另有 6 张真实语言分组选择器图片。目录 `.dart_tool/thread-font-preview-r5`，日志 `.dart_tool/thread-fonts-r5-preview-0.log` 至 `-6.log`。旧 16 款截图保留不覆盖。
- 日文样例为 `旅の記録 あいうカタカナゕゖ 汉语 Hello 123。`，每款日文的假名必须实际注册非 core 分片；逐款分片 ID、SHA、字节及缺字探针保存在 `batch-*.json`。小城样例包括缺失的 ASCII 引号及弯单引号，缺字光栅与显式回退相同。预览显式使用思源黑体作测试回退，不能代表 Android 系统回退或真机 RSS。
- 架构、23 模块文档检查通过。早期全仓 Dart 分析只发现手动预览工具的测试专用偏好 API 位置警告，已改为测试消息通道并对该文件重新分析零问题；最终完整门禁全量分析也已通过，保留先前警告及修正记录。

| 最终 29 款批次（每进程最多 4 款及显式回退） | 普通注册输入 B | 独立原件 B | 资源读取次数 | faces |
| --- | ---: | ---: | ---: | ---: |
| 0 | 8,977,976 | 0 | 14 | 6 |
| 1 | 7,679,064 | 0 | 17 | 6 |
| 2 | 16,020,068 | 0 | 24 | 14 |
| 3 | 10,765,520 | 18,410,600 | 24 | 12 |
| 4 | 16,422,172 | 0 | 30 | 20 |
| 5 | 7,884,712 | 0 | 27 | 17 |
| 6 | 1,751,316 | 0 | 15 | 5 |
| 7 | 1,601,536 | 0 | 6 | 2 |

批次 3 已真实加载小城原件，下载／注册／预留的独立额度均为 18,410,600 B；各批普通预算均未突破。离线预览从本地直接读入 manifest，表中读取次数为字体与许可对象的运行时读取，不是线上 HTTP 测量，也不包含清单预读；正式服务下载 manifest 时仍计入同一请求／字节预算。进程 RSS 变化还包含 Widget、光栅截图和测试框架，不作为字体独占内存结论。

## 最终完整门禁

- 对冻结应用源码执行一次 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，日志 `.dart_tool/thread-fonts-r5-final-gate-apk.log`，最终 exit code **1**。唯一失败为公网 API／来源不匹配：预期 API `5.41.0-dev.20261021.2`、Backend `102b8253`，实际 API `5.40.0-dev.20261018.1`、Backend `6e00c403`。`ContinueAfterFailure` 仅收集后续结果，没有把失败改成成功。
- OpenAPI 校验、固定来源、客户端再生成一致性、1,448 文件格式、应用与生成客户端静态分析、架构、23 模块文档、API 覆盖全部通过。
- 全量 `test/`：**7,358 通过、1 跳过、0 失败**，约 26 分钟。跳过项为需要单独授权发送的 `test/core/diagnostics/diagnostic_live_receipt_test.dart`；未发送线上回执。上批失败的 `test/features/threads/thread_detail_stack_test.dart` 在本次全量中通过。
- Windows 工具测试 **49/49 通过**，包括上批缺少字体文档的 `tool/windows/contract_revision.test.mjs`。Debug APK 构建通过。
- 门禁期间只补手动预览工具的图例颜色及验收文档，没有修改应用源码；该工具另经格式与静态分析零问题、8 批真实预览通过。APK 构建后逐项重查 1,966 文件集合与 SHA，仍与冻结摘要完全一致，不重复无变化的应用门禁。

## APK、签名与体积

| 项目 | 实际结果 |
| --- | --- |
| 文件 | `build/thread-fonts-r5-candidate/app-thread-fonts-r5-631ee2a41a2e-debug.apk` |
| 构建时间 | 2026-10-21 19:59:27，Asia/Shanghai |
| 大小 | 112,928,878 B（约 107.7 MiB） |
| SHA-256 | `631ee2a41a2e34e55da2589375ee1e9595e6772a7b3be05b26b613fe41f1da93` |
| 包名／应用名 | `site.wenyou.app.debug`／温油站 Debug |
| 版本／构建号 | `0.10.0-debug`／100 |
| ABI／SDK | 仅 `arm64-v8a`，min 26、target 36 |
| 签名 | `apksigner verify` 通过，APK v2 为 true |
| 安装／Debug 会话 | 未安装；未接管其他任务设备或会话 |

候选目录同时保留 `evidence.json` 和 `source-manifest.json`。aapt、签名与二进制审计日志分别为 `.dart_tool/thread-fonts-r5-apk-badging.log`、`-apk-signature.log`、`-apk-content-audit.json`、`-apk-structure-audit.json`。

- 基线 112,831,150 B → 上批 155,236,322 B → 本批 112,928,878 B。本批较上批减少 **42,307,444 B**，较基线只增加 **97,728 B**。
- 三包均有 732 个有效条目；逐条解压内容哈希核对，本批与基线仅 `assets/flutter_assets/kernel_blob.bin` 不同，其余 731 项相同，无新增／删除条目。kernel 压缩大小由 42,311,196 B 增至 42,408,924 B，差值恰为整个 APK 增量。
- 上批 42,311,263 B 未引用空填充区在本批不存在；本批有效 kernel 比上批增加 3,819 B，故精确减少量为 `42,311,263 - 3,819 = 42,307,444 B`。
- APK 内唯一字体文件仍为原 Material Icons，哈希与基线一致；全 APK 解压条目没有与 1,799 个正式字体资源对象相同的哈希，未打入字体全集或研究资源。
- 打包目录处理采用完整备份：工具安全策略拒绝递归删除后，已将本 Worktree 的 `build/app/intermediates/incremental/packageDebug`、`build/app/outputs/apk/debug`、`build/app/outputs/flutter-apk` 分别更名保留为 `*-thread-fonts-r4-preserved`，没有删除数据；旧候选与基线 APK 的 SHA 均已再次核对一致。

## 未满足项与负责人手测

- 当前构建默认 API 是 `https://wenyou.site/api/v1`；该环境尚未部署字体能力和资源基址，不能据此 APK 宣称字体功能已可端到端真机验收。上述手测需要字体能力及资源已就绪的授权环境；写入 E2E 还必须满足独立环境核验，本任务不自行部署或切换 API。
- 本任务没有可接管的设备会话；安装前仍须核对目标为 `site.wenyou.app.debug`，安装后核对该包更新时间和设备内 APK SHA，不凭构建号 100 判断已更新。
- 待负责人执行：中文／日文／英文分组与最近列表；真实长按跨段选区更换字体、颜色／粗斜体组合、一次撤销及恢复默认；主题／子贴／楼层／回复保存并重开；日文假名、怪盗混排和小城缺失引号回退；离线缓存、预算耗尽后的可读回退与正文保留；切号最近列表隔离；与 Web 的正文往返。
- 公网兼容门禁、Android 设备表现／内存、跨端保存及负责人验收均未完成。Windows 预览、自动测试、签名和 APK 构建不替代负责人明确验收结果。

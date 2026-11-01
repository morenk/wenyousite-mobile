# Android 0.12.0+102 发布准备

2026-11-01 最新进展：负责人已确认后台说明并明确授权直接合并、正式发布与推送；重新预检通过，`confirmedRevision=1`。后续合并和上线结果统一见[正式发布记录](mobile-0.12.0-release.md)，下方此前预检失败与准备状态保留为历史。

## 2026-11-01 更新准备（当前状态）

负责人确认文字排版与分享链接候选“可以了，合并分支吧”，随后要求“完成后然后直接提交正式版准备推送，跳过不必要的测试阶段”。修复 PR #134 已合入 `dev@2e5f65527413fe1cb39dd0e2567b68128dbe44a8`；已核验完整包含任务提交，本地与远端修复分支均已清理，主工作区及本机文件保留。

沿用本发布准备分支与 PR #128，保持原定正式版本 `0.12.0+102`，纳入最新 dev 已合并的阅读性能、定位、字体换行、引用边界、传送门排版及分享链接修复。发布准备分支的应用、测试、工具、机器契约、依赖与原生源码相对该 dev 基线无差异；只额外保留正式版本号和发布文档。下方 2026-10-31 的范围、旧制品和待验收项为历史，不能作为本轮制品证据。

按负责人要求复用刚完成的检查与真机结果，不重复全量测试。实际全量批次 8,364 通过／1 既有条件跳过／2 失败；两项失败已修正并分别通过链接与文案 46 项、阅读恢复 14 项及相册组合 1 项。Windows 发布／调试工具 49/49 通过，契约、生成一致性、全量分析及架构检查已完成；完整失败和补验过程见[文字修复验收记录](reading-text-style-candidate.md)。不将分段接续验证描述成单次全量零失败。

本轮通过标准 `--build-only --skip-checks` 入口重新构建正式签名包，2026-11-01 22:20 完成，退出 0，Gradle 构建 239.3 秒。包名、版本、单 ARM64、ZIP／ELF 16 KB 对齐和正式签名均通过；证书与上一正式 build 101 一致。当前授权按“正式版准备推送”执行，尚未上传、晋级 main 或打正式 Tag，实际对用户推送仍需通过后台说明预检。

| 本轮制品 | 结果 |
| --- | --- |
| 构建源码 | `e6484698d83f48a1de4893289eaccb608576371b` |
| applicationId | `site.wenyou.app` |
| versionName / versionCode | `0.12.0` / `102` |
| APK 字节数 | `37981017` |
| APK SHA-256 | `3cadf36fa8db5ba7763d39fd196ee3866baf5d023fdaf3a51a602a1a1439df05` |
| 签名证书 SHA-256 | `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839` |

APK、摘要、JSON 清单、构建日志、更新说明草稿与线上只读状态保存于 `D:\codex-artifacts\mobile-release-0.12.0-102-20261101`，复制后哈希已核验。后续仅补充此文档，不改变源码制品；旧目录 `mobile-release-0.12.0-102` 的 10 月 31 日 APK 仅作历史保留。公网 `/meta` 仍推荐 build 101、最低支持构建号 null，Backend 为 `19a6c4ed`。

后台只读预检 `--gateway --preflight --version 0.12.0 --build 102` 本轮仍返回 `MOBILE_RELEASE_COMMAND_FAILED`，未取得 `confirmedRevision`；不能仅凭通用错误确定原因，也不绕过预检。本轮未自动执行线上业务写入，未安装或启动 Release 覆盖用户正式包。

### 本轮更新说明建议稿

温油站 0.12.0

- 新增主动检查更新入口，优化空回复提示。
- 优化长文阅读、发布后定位及返回原位置的体验。
- 修复自定义字体换行、引用边界及传送门对齐与间距问题。
- 统一编辑与阅读字号，修复大字号、彩色代码和字体链接的排版。
- 支持从分享文案中提取链接，修复部分分享链接无法保存的问题。
- 修复键盘弹出后标题无法编辑、部分系统返回异常，完善发布失败的问题详情。

## 2026-10-31 首轮准备历史记录

## 范围与授权

2026-10-31（Asia/Shanghai），负责人要求准备移动端正式版，并确认版本 `0.12.0+102`。基线为已更新的 `origin/dev@51a5edee`，上一正式版为 `v0.11.0`／build 101；只包含已合并内容，未合并 PR #99 存储桶直连方案不纳入。

本任务分支 `codex/20261031-mobile-release-0-12` 复用空闲且干净的 Windows 主 checkout `D:\code\wenyousite\wenyousite-mobile`；未接管其他 Worktree 或设备会话。宿主管理 Worktree 工具不接受治理项目下嵌套产品仓库作为 sourceRoot，因此未创建新的托管 Worktree。当前任务只处理这一 Mobile 发布准备目标。

本次授权为准备候选。正式合并、`dev → main` 晋级、Tag、上传与线上推荐切换仍待负责人明确决定；本版 Release 真机冒烟与后台说明确认也待完成。旧版本的跳过全量测试或直接发布授权不扩展至本轮。

## 拟发布更新说明

温油站 0.12.0

- 新增主动检查更新入口。
- 优化空回复提示，保留动态回复中的合法符号内容。
- 修复键盘弹出后主题标题无法编辑的问题。
- 修复部分系统返回场景的异常。
- 完善动态发布失败的问题详情，便于反馈与排查。

本节是建议稿，尚未在后台确认。最新回复定位问题此前由负责人明确跳过，未修复；动态发布原始故障根因仍未定位，不将新增诊断写成修复全部发布失败。此前主动更新与空回复合并未附新增真机验收，仍需在本轮正式候选复验。

## 依赖与检查

固定 Backend `19a6c4ed48829a781182527faaafce6e788e9e2e`、API `5.44.0-dev.20261024.3`、Foundation `v7.6.0`。本轮仅同步已部署来源身份，机器契约和应用实现不变，见[来源复核](backend-contract-source-20261031.md)。标准 Release 连接公网 `https://wenyou.site/api/v1`，承载真实用户数据。

最近同一应用源码的集成门禁记录为 `5298f3d5`，原日志摘要已独立复核。本轮版本与来源断言调整后，实际重新执行 `npm run check -- -TestConcurrency 2`，退出 0：Flutter **8134 通过、1 项条件收件跳过、0 失败**，Windows 工具 **49/49 通过**；OpenAPI 校验、固定来源、SDK 再生成一致性、线上只读兼容、1601 个 Dart 文件格式、应用及生成 SDK 全量分析、架构、23 模块文档与 API 覆盖全部通过。跳过项为既有 Sentry 显式收件验收，不代表本版手机已经收件。

应用 `lib` tree 为 `d04adcb9e90b5048a141fb21ee715bcfd88b4940`，`android` tree 为 `948213a0815ae4c46530b60cb3ff4c3799605213`，均与已验证集成源码一致。依赖锁文件、机器契约与生成 SDK 没有 diff。本轮成功日志为证据目录 `check.log`；构建时使用 `--skip-checks` 复用这份刚完成的门禁，不重复运行测试。

首轮门禁在静态分析阶段误扫本机历史 `build/thread-font-codegen-cache-20261015/entrypoint/build.dart`，因生成缓存缺少原依赖而失败。将该缓存的 499 个文件完整移至证据目录 `preserved-thread-font-codegen-cache-20261015`，移动前后逐文件 SHA-256 一致，确认无 reparse point、无使用该缓存的活动进程；没有删除缓存或修改分析规则。清单为 `preserved-cache-inventory.json`，首轮失败日志为 `check-failed-stale-cache.log`，上述成功结果来自移出缓存后的完整重跑。

只读管理入口 `--gateway --preflight --version 0.12.0 --build 102` 返回 `MOBILE_RELEASE_COMMAND_FAILED`，未取得 confirmedRevision；通用错误不能单独证明具体失败原因。后台说明确认及预检仍待完成，不能绕过；该结果不阻止本地 BuildOnly。

## 制品与待办

标准 Windows 入口 `tool/release-mobile-from-local.sh --version 0.12.0 --build 102 --platform android --build-only --skip-checks` 已退出 0，Gradle Release 构建耗时 543.4 秒。构建时工作区干净且 HEAD 与远端任务分支一致；复用本轮成功门禁，不上传、不切换推荐策略。

| 项目 | 结果 |
| --- | --- |
| 构建源码 | `53c13f544305c039aaee10a80fbdf6fee0d971a2` |
| applicationId | `site.wenyou.app` |
| versionName / versionCode | `0.12.0` / `102` |
| APK 字节数 | `37849945` |
| APK SHA-256 | `75343f11ee1e93cd7ad16872f8d7ec6a885b391000c9ae47a267cc8d2d2f0154` |
| 签名证书 SHA-256 | `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839` |
| 完整门禁日志 SHA-256 | `46cda03c55c7db8fbecc8ed40fb07ad4168a223be780e93a7cb08492a7138cc9` |
| 构建日志 SHA-256 | `d0c82402f27cd93a713c03ec0faf8c03b80093b50e3194ce9e5af0be7a26d9e2` |

APK 为单 ARM64，5 个原生库、0 个应用 UI 字体、1 个功能字体。标准入口的正式签名、包名／版本、ZIP 与 ELF 的 16 KB 对齐校验通过；证书与上一正式 build 101 一致。构建带入既有仓库外独立诊断配置，凭据和 DSN 不进入 Git。既有 Kotlin 插件迁移、SDK XML 与 CupertinoIcons 提示保留，不以本轮升级依赖。

制品与日志独立保存于 `D:\codex-artifacts\mobile-release-0.12.0-102`，APK 为 `wenyou-0.12.0-102.apk`，同目录保留 `.apk.sha256`、制品 JSON、`verification.json`、检查／构建日志及更新说明建议稿。复制后重新计算 SHA-256，与标准入口清单一致。新旧 APK 总大小恰好相同，另核对新包 `libapp.so` SHA-256 为 `c1517b15b5a0f92e7000cd8be79736aafd00b196e2a67858faff56f583ceaea8`，与旧版不同，记录于 `native-app-comparison.json`。

BuildOnly 的 `notesConfirmedRevision` 为 null，不是已确认发布制品。构建后只读 `/meta` 仍推荐 build 101、最低支持构建号 null，Backend 来源仍为 `19a6c4ed`。ADB 没有连接设备，未安装、启动应用或执行线上写入 E2E；本版 Release 真机验收尚未取得。

负责人手测正式包 `site.wenyou.app` 覆盖升级并保留原有数据：核对 `0.12.0 (102)`、登录状态和草稿；检查账号设置的主动更新入口、空回复与合法符号回复；复验带图正文下的标题输入、键盘和系统返回。动态发布若再失败，使用本版问题详情反馈；不要将 Debug 新数据成功视为原正式数据故障已解决。

发布准备 [PR #128](https://github.com/morenk/wenyousite-mobile/pull/128) 已推送，保持 Draft／待验收。源码同步独立提交 `e138891a`，版本与构建源码为上表 `53c13f54`；后续只补充本记录，不改变应用源码或重建候选。负责人完成候选验收、后台 Android／`0.12.0`／102 的更新说明确认并明确授权正式发布后，按既有标准入口执行说明 revision 预检、合并晋级、正式 Tag、不可变上传与管理员网关晋级；最终以线上只读回读及完整下载摘要核验收口。本轮不清理候选分支或现场，不归档 chat。

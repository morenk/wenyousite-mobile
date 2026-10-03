# 私有 APK 发布与下载适配（候选／待验收）

## 每日下载次数增补（2026-10-03，候选／待验收）

本轮沿用相同 Windows Worktree、分支及 PR #84。治理和 Mobile AGENTS 已读取；固定 Backend `10b7819ad4a15777490dad5ab9abb7ae961422fc`／`5.32.0-dev.20261003.1`，通过官方同步导出 33 个文件并重新生成 SDK，操作仍为 238 项、Mobile 范围 164/164。先提交独立 chore `aade8bd6`，再实现消费者提示；其余发布 CLI、文件完整性与原生签名校验不变。

目标是 HEAD 或 GET 返回 429 时从原因头区分设备／IP 当天次数耗尽，并沿用服务端 Retry-After 等待。共享默认浏览器设备 3 次、IP 10 次、跨构建和北京时间日界语义由 Backend 实现；原生不新增 Cookie、info 前置请求或硬件标识。未知／缺失原因兼容原通用提示，503 不按次数原因改判，已验证本地包继续安装不消耗新下载。本轮是网络契约扩展，按高风险入口对最终源码执行完整 `check:apk`，不增加视觉样式测试。

只使用本机随机端口的 HTTP fixture 验证 Mobile 行为，不访问真实桶或凭据，不调用远程发布／迁移。HEAD 无正文、GET 空 429、HEAD→GET 额度竞争、跨构建等待、北京时间次日前后及本地包复用属于本轮自动检查；服务端 SQLite 原子计次、跨进程持久化、Cookie 签名及真实旧 APP 安装由 Backend／负责人独立验收。公网仍是已部署 `5.30.0-dev.20261001.1 / 2b803a8e4bc73bc01bd046142e6f9005f92aa411`，现有来源门禁差异如实保留。

Auto-review 默认偏好已传递；当前工具没有设置入口，宿主审批策略为 `never`，未设置为 Auto-review，本轮未重新核验 reviewer。未以提示词或仓库文档代替实际权限配置，也未递归分派。

本轮已执行 `flutter test --no-pub --concurrency=2`，路径为 `test/features/app_shell/` 下的 `mobile_update_http_test.dart`、`mobile_update_service_test.dart`、`mobile_update_controller_test.dart`、`mobile_release_controller_test.dart`，**56 项通过**。新增设备每日限额 HEAD 用例在旧实现先失败（只得到通用限流提示），候选通过；这是已提交新契约的构造响应，不声称复现了生产或真机问题。契约同步阶段另运行 `app_download_contract_test.dart`，**6 项通过**。

全量静态分析零问题，源码固定于 `828128ceba30657f42098e3928fdd3fa19c54a3c`；最终门禁和新 APK 证据如下。下列 `1708da69` 与 `1857d60f` 记录属于前一候选，不覆盖本次新增行为。

本轮负责人后续手测在已核验隔离环境进行：分别返回设备／IP 次数耗尽的无正文 HEAD 429 和 HEAD 成功后的空正文 GET 429，确认对应当日提示、强制更新不解除、冷却内重复操作不重新下载；等待服务端指定期限后显式重试可恢复。已有校验通过的包在未知来源授权返回后继续安装，不能因为每日限额重复下载。旧无 Cookie 正式 APP 的 IP 10 次总额度，以及新 Cookie 的浏览器设备 3 次、跨构建／跨日持久化属于服务端及真实设备联合验收，不由 Mobile 本机响应替身证明；合成 build 4242 不用于安装。

### 每日次数最终门禁与产物（828128ce）

在 Windows 对上述源码执行 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，退出码 **1**，唯一未通过阶段为公网契约检查。其余阶段均通过：OpenAPI 校验、固定来源、SDK 再生成一致性、全仓格式、应用／生成客户端全量静态分析、架构、21 个模块文档及 API 范围 164/164；全量 Flutter `test/` **5,161 通过、1 跳过**；`npm run test:release-tool` **87/87 通过**；Debug APK 构建成功。33 个导出文件另与固定 Backend 逐项核对一致（保留两处既有参数规范化及独立语料来源），受限发布 CLI 与前一来源逐字相同。

公网阶段首次因 TLS 握手中断失败；第一次单项复查仍连接中断。最后一次同入口 `npm run api:verify:production` 取得完整响应，确认期望 `5.32.0-dev.20261003.1 / 10b7819ad4a15777490dad5ab9abb7ae961422fc`，实际仍为 `5.30.0-dev.20261001.1 / 2b803a8e4bc73bc01bd046142e6f9005f92aa411`。Markdown 5 在支持的 3/4/5 范围内。原门禁和单项复查均保留非零退出，不宣称全绿，也未部署、改写来源或放宽比较。

- 当前 APK：`D:\codex-worktrees\9e50\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，生成于 **2026-10-03 23:02:57（Asia/Shanghai）**，**150,314,508 bytes**。
- 包名 `site.wenyou.app.debug`，版本 `0.8.0-debug+97`；最低 API 26，目标 API 36，仅 `arm64-v8a`；`apksigner` 验证 v2 签名有效，证书为 Android Debug。
- APK SHA-256：`99bbffc3f7170923b1163e55dab98f365d2d0b4b43ce6c128a035f498bcae900`。
- 完整门禁日志 `build/private-apk-daily-final-gate.log`，SHA-256：`ff32953245d0ce21a8d66ca1a8e90e07e97e98704ae4bc98ecd5265f78b68429`。
- 最终公网复查日志 `build/private-apk-daily-public-final.log`，SHA-256：`96006081573a6d46889143a645226c2ae82b5a1e3f875b141cd95ee3cd296757`。首次单项连接失败日志另存 `build/private-apk-daily-public-recheck.log`；以上日志均 Git 忽略。

门禁后只更新验收文档与 CHANGELOG，应用、测试、契约和生成客户端与 `828128ce` 一致，不重复完整门禁或构建。上述当前 APK 覆盖了同一路径的前一产物；仍未安装或用于正式包覆盖，真实云配置、桶、凭据、部署和生产数据均未触碰。候选继续在 [PR #84](https://github.com/morenk/wenyousite-mobile/pull/84) 评审，剩余为兼容部署后的公网来源复验，以及隔离网关／真实旧 APP／正式签名覆盖安装的负责人验收。

## 范围和基线

- Windows Worktree：`D:\codex-worktrees\9e50\wenyousite-mobile`，分支 `codex/20261002-private-apk-release`，由更新后的 `origin/dev` `510c63db8e28ec3563d8fc0e9593fa7440b4e66d` 建立。
- 已 fetch Foundation tags，正式最新 `v7.2.1` 与 `pubspec.yaml` 一致；语义参考 PR #30 最终提交 `b75835b1ffcf2dc6d98f86e94a3b71804a53f0bb`（26 个固定用例），包含既有凭据复用边界；不新增 Token、依赖或 Android 原生实现。
- 契约先通过 `021029ad` 同步首版下载协议，后由 `940560b5` 固定运行时 Backend `27dc3ff7eeb51334ff024feb8494e78eb7ae7fc8`／`5.31.0-dev.20261003.1`，见[同步记录](private-apk-contract-sync.md)。生成 SDK 完整保留上游讨论定位新增内容，其 UI 消费由独立切片处理。
- `79f73119` 已合入最新 Mobile `origin/dev` `5dfeb583`，保留双方变更记录；当前契约继续固定下载候选来源，不用旧线上 SHA 覆盖它。
- 最终来源进一步固定 Backend `1857d60fe3af309149eb5c1846be221d3a45fb86`（PR #41）：相对 `27dc3ff7` 只有隔离预览响应头修正，同步契约与发布 CLI 逐字不变。随后合入新 Mobile `origin/dev` `4a52274c` 的完整讨论定位实现，移除两项已消费窗口 API 的临时排除，不覆盖原切片的验收边界。
- 2026-10-02 历史门禁时本地来源 `4db0cdf2c079fc8b66545c67849053cd74945f8a` 与公网 `/meta.buildSha` `edd0b23d870d533df5f4ac787eb22df9a822981f` 不同，双方 OpenAPI 为 `5.29.0-dev.20261001.1`。后续公网来源差异继续如实报告，不改线上或放宽门禁。

## 独立完成的实现

发布准备提交 `d07c9080` 改用鉴权 S3 HEAD 和 sidecar/manifest GET，保留 APK 类型、大小、SHA-256、证书、包名、版本、构建和源提交 metadata。附件流式读取且不超过本地已知长度和 64 KiB，不下载完整 APK 验证；所有网络失败停止，禁止公开回退。旧对象同名同内容可复用，metadata 不符禁止覆盖。

上传程序限制 `wenyou-apk/mobile/android`；不接受含凭据、查询参数或 fragment 的 endpoint/URL。SDK 请求、附件流和无效 URL 解析错误不回显原始敏感输入，SSH 移除本机上传凭据并禁用 SendEnv。DPAPI、Windows 签名、原生安装器验证均保留。

负责人于 2026-10-03 允许复用现有存储凭据，不要求新建只读凭据，不调整原有云权限。目录与读取操作限制是应用层约束，不证明凭据在云端只读或只能访问 APK；泄漏可能影响其原有授权的全部资源。后端只能在隔离的显式预热／修复进程读取私有配置，公开网关不得持有或继承凭据；Windows 不通过 SSH 传递上传密钥。

消费者保留独立 Dio 的安全连接、HEAD/GET 元数据、完整长度与 SHA-256 验证，并由原生桥核对包名／构建／已安装签名。固定文件 URL 无需 `.apk` 后缀，允许网关 `private, no-store`；当前只请求整包，不发 Range，HEAD/GET 都只接受 200，非预期 206 即使带完整字节也拒绝安装并清理 `.part`。

429/503 候选按 origin 共用 `Retry-After` 整数秒期限，缺失或非法时等待 60 秒；同源切换构建、缓存的预检结果不能绕过。到期不主动重发，由下一次既有检查或用户操作恢复。已验证 APK 的继续安装不受网络等待影响。限流和暂时不可下载分别给出稍后重试提示，强制更新保留门禁，等待页不推断“正在发布”。

发布工具已接入已提交的受限 `--gateway`，两次说明预检也带该前置标志，因此旧入口不支持时在构建前停止。上传器输出源桶／key／历史 URL 与独立 publicUrl，晋级前严格复核版本、build、大小和 SHA；`--url` 继续传原 RainS3 身份。后端在单个受限入口内预热并晋级，失败不回退旧通道、不自动恢复、不报告成功；Windows 不执行远程内部 CLI 或代管服务。上传-only 明确只完成源对象上传，不声称已预热或公开可用。

最终编排定向检查：`node --test --test-concurrency=1 tool/upload_android_release.test.mjs tool/windows/release_notes.test.mjs` **29/29 通过**。实际运行本地 shell 参数解析和受限命令编排，SSH／构建／上传采用测试替身，不把替身结果当作已部署 Backend 的实际预热或恢复证明。该行为依赖合并部署后的同版后端入口。

## 已执行的隔离回归

- `node --test tool/upload_android_release.test.mjs`：真实本机 HTTP 的 S3 SDK 签名请求；仅虚构凭据、随机 loopback 端口，关闭匿名读取。覆盖旧对象复用、metadata 不符、附件同长度篡改、403/404/503 失败与禁止公开回退。
- `tool/windows/release_notes.test.mjs`：保留原参数解析与发布编排，仅把构建、上传和 SSH 替换为本轮临时目录的 fixture；SSH 遇上传凭据即失败，不访问实际发布端。
- `node --test --test-concurrency=1 tool/upload_android_release.test.mjs tool/windows/release_notes.test.mjs`：24 项通过。
- `node --test tool/windows/windows_release_scripts.test.mjs`：12 项通过，包含桌面 SSH 预检移除上传凭据、禁用 SendEnv、失败后恢复调用方环境。
- `flutter test --concurrency=1 test/features/app_shell/mobile_update_http_test.dart test/features/app_shell/mobile_update_service_test.dart`：20 项通过。真实 loopback HTTP 覆盖 HEAD→GET、无后缀地址、GET metadata 缺失、429/503、206 部分正文拒绝、哈希及缓存状态机。

HTTP 测试在 adapter 中把虚构 HTTPS 地址的传输映射到本机，保留消费者 HTTPS 判断；不能代表公网 TLS、Caddy、实际 Backend 网关或真机安装验收。原生安装桥使用测试替身，不能代替正式签名 APK 的系统覆盖安装。

2026-10-03 新消费者验证：`mobile_update_http_test.dart`、`mobile_update_service_test.dart`、`mobile_release_controller_test.dart`、`mobile_update_controller_test.dart`（均在 `test/features/app_shell/`）与 `test/app_shell_test.dart` 共 **72 项通过**。明确拒绝完整字节 206 后，重跑前两个文件 **30 项通过**。同一“429 后重新预检和手动下载共用等待期限”回归在旧实现失败（3 次 HEAD），候选只发 1 次；这是新网关的隔离构造响应，不声称已复现生产网关或已安装旧 APP。架构及 21 个模块文档检查通过；全量静态分析零问题；新增 320dp／两倍字号／明暗主题的两项强制等待 Widget 检查通过。发布上传与 Windows 脚本最新回归 32/32 通过（移除未使用的旧公网 header 检查，新增流错误及无效 URL 脱敏）。

## Foundation 验收编号映射

| 编号 | Mobile 证据与边界 |
| --- | --- |
| `download-explicit-action`、`legacy-head-get` | HTTP 用例只在显式 launch 后 GET，覆盖旧 URL 与固定构建 URL；旧正式 APK 真机仍待验收 |
| `info-target-race` | 控制器测试验证下载前目标变化禁止下载旧目标；Mobile 仍以 `/meta` 决策 |
| `download-rate-limited`、`download-service-unavailable` | HTTP 等待期限与恢复；Controller/Widget 显示提示且不解除强制门禁 |
| `single-range` | SDK 测试验证 Range 参数；APP 不发 Range，HTTP 用例拒绝非预期 206；服务端范围和计费由 Backend 验证 |
| `artifact-identity-preserved` | S3 metadata/附件 SHA、APP 长度/摘要/缓存回归；原生签名未改，正式覆盖安装待真机 |
| `origin-credential-reuse` | Windows 使用虚构既有凭据、固定上传目录、错误脱敏和 SSH 环境隔离回归；后端预热读取范围、私有配置权限、公众进程隔离由 Backend 独立测试及部署验收证明，Windows 上传仍需要写入操作 |
| `accessible-layout` | 共用等待组件的新增提示窄屏／大字号 Widget 检查；未查看画面不作为视觉验收 |
| `prewarm-before-promote` | Windows fixture 验证受限 gateway 参数、先预检再构建、身份复核、失败不回退；内部预热顺序由固定 Backend 源码与其隔离测试证明，本任务不在 Windows 执行 Backend |
| `migration-public-read-gate` | 未改桶公共读，Mobile 测试不能替代旧 APP 和网关隔离验收 |

## 前一候选门禁与 Debug 产物（1708da69）

2026-10-03 对最终应用源码 `1708da695ea5013d8d821354ac6500ebf3914a33` 执行 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，退出码 **1**。仅公网契约精确来源检查失败，其余阶段和 Debug 构建均成功；不能据此声明完整门禁通过或已可合并。

| 项目 | 实际结果 |
| --- | --- |
| OpenAPI、固定来源、SDK 再生成一致性 | 通过 |
| 全仓格式、应用及生成客户端静态分析 | 通过，分析零问题 |
| 架构、模块文档、API 覆盖 | 通过；21 个模块；164/164（总操作 238，明确排除 74） |
| 全量 Flutter `test/` | **5,142 通过、1 跳过** |
| `npm run test:release-tool` | **87/87 通过**；覆盖上传器、Windows 发布脚本、说明编排、契约来源、质量门禁、候选构建和 `tool/dev/*.test.mjs` |
| 公网精确版本／SHA | **失败**；期望 `5.31.0-dev.20261003.1 / 1857d60fe3af309149eb5c1846be221d3a45fb86`，实际 `5.30.0-dev.20261001.1 / 2b803a8e4bc73bc01bd046142e6f9005f92aa411` |
| Markdown 兼容范围 | 实际 Markdown 5 在支持的 3/4/5 范围内；不是失败原因 |
| Debug 构建与 APK 签名检查 | 成功；APK v2 签名有效，证书为 Android Debug |

该差异来自候选 Backend 尚未部署，未以部署、改写来源或放宽比较消除它。后续仅补本文及 CHANGELOG，不改变应用源码和 APK 的证据绑定。

- APK 绝对路径：`D:\codex-worktrees\9e50\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 身份：`site.wenyou.app.debug`，`0.8.0-debug+97`，最低 API 26，目标 API 36，仅 `arm64-v8a`。
- 生成时间：2026-10-03 05:11:24（Asia/Shanghai）；大小 **150,335,830 bytes**。
- APK SHA-256：`cedf2721fc27e1b7d554e24f2f77b0f9734de6ad6476dcac614fe3151e7f77ee`。
- 本机日志：`private-apk-final-gate.log`（Git 忽略）；SHA-256：`e81fa1c48d66c870d33904ef9bb9278a360ff3d336dae3e7bd3341d2c8bd0afa`。
- 分支已推送，评审入口为 [Mobile PR #84](https://github.com/morenk/wenyousite-mobile/pull/84)，保持草稿候选；依赖 [Backend PR #41](https://github.com/morenk/wenyousite-backend/pull/41) 与 [Foundation 语义 PR #30](https://github.com/morenk/wenyousite-foundation/pull/30)。

没有安装 APK、启动设备 Debug 会话、读取真实云凭据或执行正式签名／上传／晋级。构建工具提示 `flutter_image_compress_common` 仍使用 Kotlin Gradle Plugin；本轮构建成功，该提示不构成下载迁移的已验证内容。

## 历史门禁与中止记录

2026-10-02 在 Windows 执行一次 `npm run check:apk -- -ContinueAfterFailure`，退出码 **1**。唯一失败为公网 `/meta.buildSha` 与本地契约来源精确 SHA 不同，见上述基线；未修改线上、未放宽检查，也不报告为完整门禁通过。

- OpenAPI 校验、固定契约来源、SDK 再生成一致性、全仓格式、应用及生成客户端全量分析、架构、模块文档和 API 覆盖均通过。
- 全量 Flutter：**5,053 通过、1 跳过**；全量 Windows 发布及开发工具：**82/82 通过**。
- Debug 构建成功，绑定当时应用／原生／SDK 源码 `510c63db8e28ec3563d8fc0e9593fa7440b4e66d`；**不覆盖本轮新 SDK、下载等待或后续 CLI**，不能作为最终迁移验证。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，`site.wenyou.app.debug`，`0.8.0-debug+97`，仅 `arm64-v8a`，**109,443,518 bytes**。
- APK SHA-256：`5f5c0a29139b4bf2c8ecc7f2a424166a1f55b557cae0935b7c97e09340436a7a`。
- 本机完整日志：`private-apk-gate.log`（Git 忽略）；SHA-256：`93a4bf25fa412f0e461fb06f34df784c4ff5f5d10d51fc36614dc0b6a3428160`。

此历史 APK 没有安装，也没有启动 Debug 设备会话；当前文件已由上节最终候选覆盖，历史摘要只用于追溯。

2026-10-03 曾对 `0a6312db` 启动最终门禁，再生成、格式、应用/SDK 分析、架构、文档及 API 范围通过；公网当时为 `5.30.0-dev.20261001.1 / 2b803a8e4bc73bc01bd046142e6f9005f92aa411`，与候选不符。全量测试途中发现 `dev` 已新合入讨论定位切片，于是仅停止本任务的门禁进程树并保留日志 `private-apk-interrupted-gate-0a6312.log`；此轮被主动中止，不计作完整通过、不绑定新 APK。解决冲突后在最终整合源码重跑完整门禁。

## 剩余交接与验收

真机前置：治理提供已核验、与线上隔离的 HTTPS 下载地址和既有策略样本；正式覆盖安装另需与已安装 `site.wenyou.app` 同签名、目标构建更高的真实 APK。Backend `sample=downloads` 的 build 4242 是合成数据，不能作为安装验收制品；不得为接入 HTTP 样本放宽 APP 的 HTTPS 或身份校验。此次 Debug APK 只作为编译与界面候选证据，包名为 `site.wenyou.app.debug`，不能冒充对旧正式包的更新。此处没有授权或执行真实签名／发布。

负责人手测清单：

- 核对实际打开的包名、版本和构建。旧正式 APP 在隔离策略下先 HEAD；出现更新说明后，点击前不发 APK GET，点击后显示下载进度并在校验成功后进入系统安装器。
- 真实正式候选验证包名、目标构建和签名；拒绝未知来源权限后再授权，应能继续使用已验证文件。记录取消、恢复与最终安装结果，不能用 Debug 包安装成功代替。
- 本轮消费者候选分别接收 429／`Retry-After: 120` 和 503；检查稍后重试提示和强制门禁：429 的 120 秒内不再请求该下载地址；503 遵守其 Retry-After，缺失时等待 60 秒。当前进程内手动重查／回前台也不能绕过，到期后可恢复。429/503 的新等待行为不强加给未升级的旧二进制。
- 预置下载内容篡改、身份不符或非预期 206 时不得进入安装器，恢复有效制品后可重新下载。正式环境只读，不为测试主动破坏生产缓存或制品。
- 记录候选提交、包名、APK SHA、设备、操作和负责人明确结果；未回复、自动测试与系统安装器打开均不等于验收通过。

1. 已固定 Backend 受限 CLI、完成 Windows 编排及最终本地验证；公网来源门禁仍因候选尚未部署而失败，后续在对应后端上线后核对实际来源。
2. 治理协调独占设备与隔离环境后复验旧正式 APP 的 HEAD/GET。此任务不执行实际上传、正式安装、晋级、部署、桶权限修改或线上写入。
3. 缓存缺失、预算/限流、Range 服务端计费与持久化由 Backend 的隔离测试证明；Mobile 测试不冒充这些服务端验收。

当前为候选／待验收，源码与完整契约已集成并推送 PR #84，最终门禁和 APK 证据见上节。完整迁移、旧正式 APP 真机验收和可合并状态尚未达成。

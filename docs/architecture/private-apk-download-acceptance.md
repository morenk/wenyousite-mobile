# 私有 APK 发布与下载适配（候选开发中／待验收）

## 范围和基线

- Windows Worktree：`D:\codex-worktrees\9e50\wenyousite-mobile`，分支 `codex/20261002-private-apk-release`，由更新后的 `origin/dev` `510c63db8e28ec3563d8fc0e9593fa7440b4e66d` 建立。
- 已 fetch Foundation tags，正式最新 `v7.2.1` 与 `pubspec.yaml` 一致；另参考下载语义提交 `6c3776dd7c2de1aacafe0f6403fbb3ea98c5fb0d`，不新增 Token、依赖或 Android 原生实现。
- 契约先通过 `021029ad` 同步首版下载协议，后由 `940560b5` 固定运行时 Backend `27dc3ff7eeb51334ff024feb8494e78eb7ae7fc8`／`5.31.0-dev.20261003.1`，见[同步记录](private-apk-contract-sync.md)。生成 SDK 完整保留上游讨论定位新增内容，其 UI 消费由独立切片处理。
- `79f73119` 已合入最新 Mobile `origin/dev` `5dfeb583`，保留双方变更记录；当前契约继续固定下载候选来源，不用旧线上 SHA 覆盖它。
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
| `accessible-layout` | 共用等待组件的新增提示窄屏／大字号 Widget 检查；未查看画面不作为视觉验收 |
| `prewarm-before-promote` | Windows fixture 验证受限 gateway 参数、先预检再构建、身份复核、失败不回退；内部预热顺序由固定 Backend 源码与其隔离测试证明，本任务不在 Windows 执行 Backend |
| `migration-public-read-gate` | 未改桶公共读，Mobile 测试不能替代旧 APP 和网关隔离验收 |

## 本轮完整门禁与 Debug 产物

2026-10-02 在 Windows 执行一次 `npm run check:apk -- -ContinueAfterFailure`，退出码 **1**。唯一失败为公网 `/meta.buildSha` 与本地契约来源精确 SHA 不同，见上述基线；未修改线上、未放宽检查，也不报告为完整门禁通过。

- OpenAPI 校验、固定契约来源、SDK 再生成一致性、全仓格式、应用及生成客户端全量分析、架构、模块文档和 API 覆盖均通过。
- 全量 Flutter：**5,053 通过、1 跳过**；全量 Windows 发布及开发工具：**82/82 通过**。
- Debug 构建成功，绑定当时应用／原生／SDK 源码 `510c63db8e28ec3563d8fc0e9593fa7440b4e66d`；**不覆盖本轮新 SDK、下载等待或后续 CLI**，不能作为最终迁移验证。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，`site.wenyou.app.debug`，`0.8.0-debug+97`，仅 `arm64-v8a`，**109,443,518 bytes**。
- APK SHA-256：`5f5c0a29139b4bf2c8ecc7f2a424166a1f55b557cae0935b7c97e09340436a7a`。
- 本机完整日志：`private-apk-gate.log`（Git 忽略）；SHA-256：`93a4bf25fa412f0e461fb06f34df784c4ff5f5d10d51fc36614dc0b6a3428160`。

没有安装该 APK、启动 Debug 设备会话、读取真实云凭据或执行正式签名／上传／晋级。后端契约和 CLI 接入前不重复全量门禁或构建；最终验证按后续实际变更和治理安排执行。

## 剩余交接与验收

1. 已固定 Backend 受限 CLI 并完成 Windows 编排；当前等待最终本地门禁与独立环境验收。
2. 针对已提交 CLI 增补编排模拟，再对最终集成代码完成所需门禁，记录失败项和未覆盖云／设备验收，不把本轮准备阶段的检查冒充最终迁移验证。
3. 治理协调独占设备与隔离环境后复验旧正式 APP 的 HEAD/GET。此任务不执行实际上传、正式安装、晋级、部署、桶权限修改或线上写入。
4. 缓存缺失、预算/限流、Range 服务端计费与持久化由 Backend 的隔离测试证明；Mobile 测试不冒充这些服务端验收。

当前为候选／待验收，源码与完整契约已在本任务集成；最终门禁、推送与 PR 结果在交付时补记。完整迁移、旧正式 APP 真机验收和可合并状态尚未达成。

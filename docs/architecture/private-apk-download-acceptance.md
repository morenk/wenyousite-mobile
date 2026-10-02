# 私有 APK 发布与下载适配（开发中）

## 范围和基线

- Windows Worktree：`D:\codex-worktrees\9e50\wenyousite-mobile`，分支 `codex/20261002-private-apk-release`，由更新后的 `origin/dev` `510c63db8e28ec3563d8fc0e9593fa7440b4e66d` 建立。
- 已 fetch Foundation tags，正式最新 `v7.2.1` 与 `pubspec.yaml` 一致；不改视觉、依赖或 Android 原生代码。
- 本地 Backend 契约来源 `4db0cdf2c079fc8b66545c67849053cd74945f8a`，只读镜像 `origin/dev` 与公网 OpenAPI 版本均为 `5.29.0-dev.20261001.1`。2026-10-02 公网 `/meta.buildSha` 为 `edd0b23d870d533df5f4ac787eb22df9a822981f`，与本地精确 revision 不同；公网精确来源门禁仍需如实报告。
- 本任务只实施 Mobile 的发布工具和消费者回归。Backend 精确下载契约、预热／晋级 CLI 的已提交 SHA 尚未交付，不臆造字段，不手工修改生成客户端。

## 独立完成的实现

发布工具改用鉴权 S3 HEAD 和 sidecar/manifest GET，保留 APK 类型、大小、SHA-256、证书、包名、版本、构建和源提交 metadata。附件流式读取且不超过本地已知长度和 64 KiB，不下载完整 APK 验证；所有网络失败停止，禁止公开回退。旧对象同名同内容可复用，metadata 不符禁止覆盖。

发布目录限制为 `wenyou-apk/mobile/android`；不接受含凭据、查询参数或 fragment 的 endpoint/URL。SDK 网络错误只输出状态，SSH 移除本机上传凭据并禁用 SendEnv。DPAPI、Windows 签名、原生安装器验证均保留。

旧 APP 不要求 URL 具有 `.apk` 后缀，只要求安全连接、HEAD/GET 元数据一致、完整长度与摘要，并由原生桥核对包名／构建／当前签名。当前客户端使用整包 GET，不发 Range；206 部分正文必须拒绝且清理 `.part`。429/503 沿用可重试失败／预检等待，不自动回退或重新下载。

## 已执行的隔离回归

- `node --test tool/upload_android_release.test.mjs`：真实本机 HTTP 的 S3 SDK 签名请求；仅虚构凭据、随机 loopback 端口，关闭匿名读取。覆盖旧对象复用、metadata 不符、附件同长度篡改、403/404/503 失败与禁止公开回退。
- `tool/windows/release_notes.test.mjs`：保留原参数解析与发布编排，仅把构建、上传和 SSH 替换为本轮临时目录的 fixture；SSH 遇上传凭据即失败，不访问实际发布端。
- `node --test --test-concurrency=1 tool/upload_android_release.test.mjs tool/windows/release_notes.test.mjs`：24 项通过。
- `node --test tool/windows/windows_release_scripts.test.mjs`：12 项通过，包含桌面 SSH 预检移除上传凭据、禁用 SendEnv、失败后恢复调用方环境。
- `flutter test --concurrency=1 test/features/app_shell/mobile_update_http_test.dart test/features/app_shell/mobile_update_service_test.dart`：20 项通过。真实 loopback HTTP 覆盖 HEAD→GET、无后缀地址、GET metadata 缺失、429/503、206 部分正文拒绝、哈希及缓存状态机。

HTTP 测试在 adapter 中把虚构 HTTPS 地址的传输映射到本机，保留消费者 HTTPS 判断；不能代表公网 TLS、Caddy、实际 Backend 网关或真机安装验收。原生安装桥使用测试替身，不能代替正式签名 APK 的系统覆盖安装。

## 本轮完整门禁与 Debug 产物

2026-10-02 在 Windows 执行一次 `npm run check:apk -- -ContinueAfterFailure`，退出码 **1**。唯一失败为公网 `/meta.buildSha` 与本地契约来源精确 SHA 不同，见上述基线；未修改线上、未放宽检查，也不报告为完整门禁通过。

- OpenAPI 校验、固定契约来源、SDK 再生成一致性、全仓格式、应用及生成客户端全量分析、架构、模块文档和 API 覆盖均通过。
- 全量 Flutter：**5,053 通过、1 跳过**；全量 Windows 发布及开发工具：**82/82 通过**。
- Debug 构建成功，应用与原生及生成 SDK 源码没有改动，绑定原应用源码 `510c63db8e28ec3563d8fc0e9593fa7440b4e66d`。工具、回归和文档仍是本任务未提交改动；这不是新下载 CLI 集成后的最终验证。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，`site.wenyou.app.debug`，`0.8.0-debug+97`，仅 `arm64-v8a`，**109,443,518 bytes**。
- APK SHA-256：`5f5c0a29139b4bf2c8ecc7f2a424166a1f55b557cae0935b7c97e09340436a7a`。
- 本机完整日志：`private-apk-gate.log`（Git 忽略）；SHA-256：`93a4bf25fa412f0e461fb06f34df784c4ff5f5d10d51fc36614dc0b6a3428160`。

没有安装该 APK、启动 Debug 设备会话、读取真实云凭据或执行正式签名／上传／晋级。后端契约和 CLI 接入前不重复全量门禁或构建；最终验证按后续实际变更和治理安排执行。

## 剩余交接与验收

1. 收到 Backend 精确 SHA 后同步固定契约、生成 SDK，接入源对象身份与对外 URL 分离、先预热后晋级及失败恢复。
2. 针对已提交 CLI 增补编排模拟，再对最终集成代码完成所需门禁，记录失败项和未覆盖云／设备验收，不把本轮准备阶段的检查冒充最终迁移验证。
3. 治理协调独占设备与隔离环境后复验旧正式 APP 的 HEAD/GET。此任务不执行实际上传、正式安装、晋级、部署、桶权限修改或线上写入。
4. 缓存缺失、预算/限流、Range 服务端计费与持久化由 Backend 的隔离测试证明；Mobile 测试不冒充这些服务端验收。

当前为开发中，尚无完整迁移、真机验收或可合并结论；尚未提交、推送或创建迁移 PR，等待治理交付 Backend 精确 SHA/CLI 后继续同一任务。

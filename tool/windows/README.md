# Windows Android 发布工具

Android 发布候选要求后台先确认精确版本的纯文本说明。`Publish-WenyouAndroid.ps1`、`Invoke-WenyouAndroidRelease.ps1 -Mode Publish` 共用 `release-mobile-from-local.sh`：构建前调用现有受限 SSH 入口的 `--preflight`，严格验证平台、版本名、build 和 `confirmedRevision`；上传后再次预检，revision 变化则停止，晋级携带原 `--notes-revision`。预检与晋级均不带 `--gateway`，恢复 RainS3 直连。`--skip-checks` 不能绕过预检，远程入口不可用时停止，不回退网关，不自动执行 `--recover`。

JSON 构建摘要保存 `notesConfirmedRevision`，将确认记录与 APK 摘要、版本和源提交绑定；无预检的分段构建该值为 `null`。

上传器只允许 `wenyou-apk/mobile/android`，上传后以签名 S3 HEAD 核对大小、类型、不可变缓存、附件名与完整发布 metadata，并以签名 GET 读回两个不超过 64 KiB 的附件，逐字节验证本地 SHA-256。上传验证保持鉴权读取，失败即停止；公开 HEAD 与 sidecar 可用性由 Backend 在晋级前复核。既有同名对象必须身份与内容均一致才能复用，禁止覆盖。Windows 的 DPAPI 存储和正式签名流程保持；SSH 子进程移除上传 AccessKey/SecretKey，禁用 SendEnv，SDK 错误不回显签名请求或原始服务端错误正文。

负责人已允许复用现有存储凭据，不要求新建只读凭据，也不调整现有云端权限。上述 APK 目录约束属于应用层限制，不等于凭据只有 APK 读取权限；泄漏可能影响该凭据原先授权的全部资源。Windows 不通过 SSH 转交上传凭据，也不复制生产配置。

发布协议来源见 [直连候选记录](../../docs/architecture/android-direct-download-acceptance.md) 与 [已提交契约](../../contracts/android-direct-download.md)。上传器保留 v1 制品字段：`bucket/key/legacyUpdateUrl` 为源对象事实，`publicUrl` 与 `legacyUpdateUrl` 均为原 RainS3 对象地址，另有版本、构建、大小和摘要。`release_artifact.mjs` 在晋级前再次精确核验全部身份字段；不接受旧 `{url,size,sha256}` 输出、网关地址、下载页地址、任意主机或带查询参数的 URL。`WENYOU_RELEASE_PUBLIC_BASE_URL` 与 `WENYOU_RELEASE_LEGACY_BASE_URL` 继续兼容原固定桶地址。

Windows 只调用 `sudo -n <既有受限晋级入口> --version ... --build ... --url <legacyUpdateUrl> --size ... --sha256 ... --notes-revision ...`。Backend 公开验证对象与 sidecar，再执行说明、策略及 TSV 事务，失败使用原补偿；Windows 不通过 SSH 传密钥、上传 manifest、执行任意 node CLI 或独立重启服务。需恢复时仍由负责人明确执行原 `--recover`。成功后显示存储桶地址，不改写历史制品或审计。

此交付是待验收候选，不部署、不切 `/meta`、不修改桶权限。兼容 Backend 合并并由管理入口部署后，再由负责人授权切换推荐策略；App 读取下一次 `/meta` 后使用桶地址，历史网关端点和缓存 URL 继续兼容。定向 mock 回归见[直连候选记录](../../docs/architecture/android-direct-download-acceptance.md)，早期网关记录保留在[私有 APK 下载适配](../../docs/architecture/private-apk-download-acceptance.md)。

`BuildOnly` 只构建签名测试制品，无需已配置说明，也不联系说明或晋级通道。`UploadOnly` 构建并上传对象，但不修改推荐策略或公开说明；真实晋级仍须重新完成完整发布流程。中断恢复、后台确认规则和受限入口部署依赖由上游[发布运维文档](../../contracts/mobile-release-operations.md)维护。本轮开发仅使用 fixture 测试，不执行正式构建、上传或晋级。

Debug、Profile 和 Release 均为仅含 `arm64-v8a` 的单 APK。仓库 Gradle 在 `defaultConfig` 统一声明 ABI，并关闭 Flutter 自动默认过滤，避免把 ARM32/x86_64 再合入制品。Debug 候选、完整门禁和正式构建入口传入 `--target-platform android-arm64`；直接构建 Profile 时也使用该参数，不使用会偏移构建号的 ABI 分包。开发和验收使用 ARM64 设备。参考 [Flutter ABI 过滤说明](https://docs.flutter.dev/release/breaking-changes/default-abi-filters-android)。

`Test-WenyouReleaseApk.ps1 -ApkPath <apk>` 在正式构建与上传前读取 ZIP 条目，要求原生库仅含 ARM64，包含 `libapp.so`、`libflutter.so`，禁止已移除的应用 UI 字体和测试字体；原有签名、包名、版本、SHA-256 与 16 KB 对齐校验继续执行。验收时在 ARM64 真机覆盖安装并检查文字、图片、资料和站内更新。仅本地验收使用 `--build-only`，不上传或调整线上策略。

本目录只保存可审计的发布程序，不保存任何凭据或私钥。安装脚本把程序复制到当前用户的 `%LOCALAPPDATA%\WenyouSite\release`，并在桌面创建一次性 SSH 初始化和日常 Android 发布入口。

桌面入口从 `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe` 调用系统 Windows PowerShell，不依赖 PATH 中存在 `powershell.exe`；仍运行原有已安装脚本并保留失败退出码。不修改全局 PATH，也不更换发布通道。

首次安装：

```powershell
& "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File tool/windows/Install-WenyouReleaseTools.ps1
```

随后按 [`contracts/mobile-release-operations.md`](../../contracts/mobile-release-operations.md) 配置 DPAPI 凭据与 VPS 主机指纹。日常发布只允许干净且已推送的 Git 提交，版本直接读取 `pubspec.yaml`。

以下内容永远不进入仓库：

- `%LOCALAPPDATA%\WenyouSite\release\rains3-credentials.json`
- `%USERPROFILE%\.ssh` 下的发布私钥
- `android/key.properties` 与正式 keystore
- 安装器生成、包含本机路径的 `release-config.json`

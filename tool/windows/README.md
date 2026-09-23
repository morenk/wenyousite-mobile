# Windows Android 发布工具

Debug、Profile 和 Release 均为仅含 `arm64-v8a` 的单 APK。仓库 Gradle 在 `defaultConfig` 统一声明 ABI，并关闭 Flutter 自动默认过滤，避免把 ARM32/x86_64 再合入制品。Debug 候选、完整门禁和正式构建入口传入 `--target-platform android-arm64`；直接构建 Profile 时也使用该参数，不使用会偏移构建号的 ABI 分包。开发和验收使用 ARM64 设备。参考 [Flutter ABI 过滤说明](https://docs.flutter.dev/release/breaking-changes/default-abi-filters-android)。

`Test-WenyouReleaseApk.ps1 -ApkPath <apk>` 在正式构建与上传前读取 ZIP 条目，要求原生库仅含 ARM64，包含 `libapp.so`、`libflutter.so`，禁止已移除的应用 UI 字体和测试字体；原有签名、包名、版本、SHA-256 与 16 KB 对齐校验继续执行。验收时在 ARM64 真机覆盖安装并检查文字、图片、资料和站内更新。仅本地验收使用 `--build-only`，不上传或调整线上策略。

本目录只保存可审计的发布程序，不保存任何凭据或私钥。安装脚本把程序复制到当前用户的 `%LOCALAPPDATA%\WenyouSite\release`，并在桌面创建一次性 SSH 初始化和日常 Android 发布入口。

首次安装：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/windows/Install-WenyouReleaseTools.ps1
```

随后按 [`contracts/mobile-release-operations.md`](../../contracts/mobile-release-operations.md) 配置 DPAPI 凭据与 VPS 主机指纹。日常发布只允许干净且已推送的 Git 提交，版本直接读取 `pubspec.yaml`。

以下内容永远不进入仓库：

- `%LOCALAPPDATA%\WenyouSite\release\rains3-credentials.json`
- `%USERPROFILE%\.ssh` 下的发布私钥
- `android/key.properties` 与正式 keystore
- 安装器生成、包含本机路径的 `release-config.json`

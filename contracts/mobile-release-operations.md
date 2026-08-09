# 移动端私有发布运维

本文描述移动端仓库在开发机、服务端仓库在 VPS 时的发布方式。Flutter 构建和真机调试始终留在开发机；VPS 只接收 Android release APK、切换版本策略并提供 HTTPS 下载。HTTP 契约仍以 [`mobile-client-guide.md`](./mobile-client-guide.md) 和 OpenAPI 为准。

## 一次性准备

### Android 签名

- 在移动端仓库配置独立的 release keystore，所有后续构建必须使用同一个签名。
- keystore、别名和密码只保存在开发机的安全存储中，不提交 Git、不上传 VPS。
- 移动端仓库提供 `android/key.properties.example`，并从未跟踪的 `android/key.properties` 读取 `storeFile`、`storePassword`、`keyAlias`、`keyPassword`；发布脚本缺少任一项都会停止。
- 第一版分发前在至少一台真机完成“安装旧版 → 发布新版 → 覆盖安装”验证。Android 会拒绝使用不同签名覆盖现有应用。

### VPS 下载目录

Caddy 把 `/downloads/mobile/android/*` 映射到：

```text
/var/lib/wenyousite/mobile-releases/android
```

文件名包含版本与构建号，使用一年 immutable 缓存；目录列表未开启。发布脚本另外维护 SHA-256 sidecar 和不公开的 `release-history.tsv`。

### iOS TestFlight

在 App Store Connect 建立固定的外部测试组，并配置 App Store Connect API Key。开发机安装 `fastlane`，把 fastlane API Key JSON 放在 Git 忽略目录或系统钥匙串管理的路径中。首次外部测试仍可能等待 TestFlight Beta Review。

## 把发布脚本放入移动端仓库

从 VPS 复制已经部署的本地发布入口：

```bash
mkdir -p tool
scp root@wenyou.site:/root/wenyousite/wenyousite-backend/scripts/release-mobile-from-local.sh \
  tool/release-mobile-from-local.sh
chmod +x tool/release-mobile-from-local.sh
```

该脚本不包含服务端密码或签名材料，可以提交到移动端仓库。Android 默认使用 `root@wenyou.site`；若使用专用 SSH 用户，通过 `WENYOU_RELEASE_SSH_TARGET` 覆盖。

## 日常发布

只发布 Android：

```bash
./tool/release-mobile-from-local.sh \
  --version 1.4.0 \
  --build 120 \
  --platform android
```

Android 流程依次运行 `flutter pub get`、`flutter analyze`、`flutter test`、release 构建、SCP 临时上传和 VPS 原子发布。VPS 在确认 APK 是有效 ZIP 且包含 `AndroidManifest.xml` 后：

1. 复制为 `wenyou-1.4.0-120.apk` 并核对 SHA-256。
2. 拒绝覆盖同名但内容不同的文件，也拒绝低于当前推荐版本的构建号。
3. 原子更新 `.env` 中的 `MOBILE_ANDROID_RECOMMENDED_BUILD` 与 `MOBILE_ANDROID_UPDATE_URL`。
4. 重启后端并验证 `/health` 与 `/meta`；失败时恢复原环境配置。
5. 成功后记录发布历史，并只保留当前和前两个 APK。

只发布 iOS：

```bash
export APP_STORE_CONNECT_API_KEY_JSON=/absolute/path/to/api-key.json
export TESTFLIGHT_GROUP='Wenyou Internal'
./tool/release-mobile-from-local.sh \
  --version 1.4.0 \
  --build 120 \
  --platform ios
```

同时发布两端时使用 `--platform both`。Android 与 iOS 各自以实际上传成功为准；TestFlight 处理或审核失败不会撤回已经成功发布的 Android 构建。

## Flutter 客户端已接入行为

移动端仓库已实现以下客户端行为，VPS 不参与 Flutter 构建与真机调试：

- 启动和回到前台时读取 `GET /api/v1/meta`，使用 `versionCode` / `CFBundleVersion` 与当前平台策略比较。
- 小于 `recommendedBuild` 时显示可关闭提示；小于 `minimumSupportedBuild` 时显示阻断更新页。
- Android 下载 `updateUrl` 到应用 cache，展示进度，随后通过 `FileProvider`/系统包安装器打开 APK。
- Android Manifest 声明 `android.permission.REQUEST_INSTALL_PACKAGES`；Android 8+ 在调用安装器前检查 `canRequestPackageInstalls()`，未授权时引导到当前应用的“安装未知应用”设置。
- 下载中断、空间不足、用户取消或安装失败时允许重试；更新检查网络失败本身不阻断仍兼容的客户端。
- iOS 更新按钮只打开 TestFlight，不下载或执行 IPA。

实现入口位于移动端仓库的 `lib/features/app_shell/`、`android/app/src/main/kotlin/site/wenyou/app/MainActivity.kt`、`ios/Runner/AppDelegate.swift` 与 `tool/release-mobile-from-local.sh`。发布前仍必须在开发机执行 Flutter 检查，并用正式签名真机验证 Android 旧版覆盖安装。

FCM/APNs 不用于传输安装包。Google 服务不可用的 Android 设备在应用下次启动或回到前台时发现更新。

## 保留、强制升级与故障处理

- 默认只保留 3 个 APK。按 80 MB/包估算约占 240 MB；1000 位用户完整更新一次约产生 80 GB 出站流量。
- `MOBILE_ANDROID_MIN_SUPPORTED_BUILD` 不由日常发布脚本自动提高。只有确认旧客户端必须停用时才手工设置，并确保对应下载 URL 已验证。
- Android 不依赖降级回滚。坏版本使用更高 build number 发布修复版；服务器保留旧 APK 主要用于诊断。
- 若单次发布流量接近 VPS 月额度，可把 APK 迁移到国内可访问的对象存储/CDN，只需修改发布脚本的 `MOBILE_RELEASE_PUBLIC_BASE_URL` 和 Caddy/上传目标，不改变 `/meta` 比较语义。

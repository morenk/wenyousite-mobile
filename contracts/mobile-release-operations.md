# 移动端私有发布运维

Flutter 检查、正式签名、APK 验收与 RainS3 上传始终在 Windows 开发机完成。VPS 不接收 APK 或对象存储密钥，只在公开对象通过复核后原子更新 `GET /api/v1/meta` 的 Android 推荐构建号与下载地址。

## 安全边界

- 正式 keystore 与 `android/key.properties` 只保存在开发机，并做加密离线备份；禁止提交 Git 或上传 VPS。
- RainS3 使用独立桶 `wenyou-apk`，公开读只允许 `mobile/android/*`，禁止匿名写与目录列表。
- 发布桶专用 AccessKey 不得访问媒体桶；密钥只以当前 Windows 用户 DPAPI 密文保存，不进入 APK、Git、日志、命令历史或 VPS。
- VPS 使用无密码专用用户 `wenyou-release`。它只能通过 sudo 调用 `/usr/local/sbin/wenyousite-promote-android`，不能读取后端 `.env` 或执行任意 root 命令。
- SSH 主机密钥必须与 VPS 控制台的 ED25519 指纹独立比较；禁止使用 `StrictHostKeyChecking=no`、`accept-new` 或空 `known_hosts` 绕过校验。
- `Wenyou-Publish-Android.cmd` 只发布干净且 `HEAD` 等于上游分支的提交，防止无法追溯的本机代码进入安装包。

仓库内 [`tool/windows`](../tool/windows/README.md) 只保存可审计程序。以下机器私有文件不进入 Git：

```text
%LOCALAPPDATA%\WenyouSite\release\rains3-credentials.json
%LOCALAPPDATA%\WenyouSite\release\release-config.json
%USERPROFILE%\.ssh\wenyou_release_ed25519*
android/key.properties
*.jks / *.keystore
```

## Windows 一次性安装

### 1. 创建专用 SSH 发布密钥

已有专用 ED25519 密钥可跳过。不要覆盖默认 `id_rsa`；自动发布密钥使用独立文件，私钥始终留在 Windows：

```powershell
ssh-keygen -t ed25519 `
  -f "$env:USERPROFILE\.ssh\wenyou_release_ed25519" `
  -C "wenyou-release@windows"
```

自动发布需要非交互 SSH，因此该专用密钥不设置口令；安装器会把私钥 ACL 收紧为当前用户与 SYSTEM。把 `.pub` 公钥安装到 VPS 的 `/home/wenyou-release/.ssh/authorized_keys`，不得复制私钥。

### 2. 安装本机工具和桌面入口

从移动端仓库根目录执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File tool/windows/Install-WenyouReleaseTools.ps1
```

当 `.ssh` 中有多个 `wenyou_release_ed25519*` 私钥时显式指定：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File tool/windows/Install-WenyouReleaseTools.ps1 `
  -ReleaseKeyPath "$env:USERPROFILE\.ssh\wenyou_release_ed25519"
```

安装器执行以下可重复操作：

1. 从当前 Git 安装位置解析 Git Bash 与 OpenSSH，不固化仓库盘符。
2. 把版本化 PowerShell 工具复制到 `%LOCALAPPDATA%\WenyouSite\release`。
3. 写入只含本机路径的 `release-config.json`，不读取或覆盖 RainS3 凭据。
4. 保留现有 SSH 配置；缺少 `wenyou-release-vps` 时追加专用别名。
5. 在桌面安装 `Wenyou-Release-Setup.cmd` 与 `Wenyou-Publish-Android.cmd`。

仓库移动、Git 安装位置变化或工具升级后重新运行安装器即可。

### 3. 保存 RainS3 DPAPI 凭据

先撤销任何已暴露或不再使用的旧密钥，再创建权限仅覆盖发布桶前缀的新密钥。不要把新密钥发送到聊天或写入命令行参数；在隐藏提示中输入：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "$env:LOCALAPPDATA\WenyouSite\release\Set-RainS3Credentials.ps1"
```

脚本使用 `ConvertFrom-SecureString` 生成当前 Windows 用户绑定的 DPAPI 密文，并把文件 ACL 限制为当前用户与 SYSTEM。换机或更换 Windows 账号后必须重新输入；复制密文文件不能迁移凭据。

### 4. 核验 VPS 指纹与发布权限

在 VPS 控制台独立执行：

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

随后在 Windows 双击桌面 `Wenyou-Release-Setup.cmd`，粘贴控制台输出中的 `SHA256:...`。工具只有在网络扫描指纹与控制台指纹完全一致时才写入 `known_hosts`，然后以 `wenyou-release-vps` 执行只读预检：

```text
sudo -n /usr/local/sbin/wenyousite-promote-android --help
```

VPS sudo 权限必须精确为：

```text
wenyou-release ALL=(root) NOPASSWD: /usr/local/sbin/wenyousite-promote-android *
```

## 日常一键发布

发布前只需完成代码事实：

1. 在 `pubspec.yaml` 递增开发版本与 Android build，例如 `0.3.0-dev.39+45`。
2. 更新 `README.md` 与 `docs/CHANGELOG.md` 的版本记录。
3. 提交并推送当前分支，保持移动端仓库没有未提交或未跟踪文件。
4. 双击桌面 `Wenyou-Publish-Android.cmd`，核对版本与源提交后输入 `y`。

桌面入口自动执行：

1. 读取 `pubspec.yaml` 的 versionName 与 versionCode。
2. 检查 Git 工作树为空且 `HEAD` 等于上游提交。
3. 通过 SSH 预检确认专用用户、主机指纹和 sudo 规则仍有效。
4. 运行 Flutter 依赖、静态分析与完整测试，构建正式签名 APK。
5. 校验 zipalign、签名、`site.wenyou.app`、版本和构建号。
6. 生成版本化 APK、`.apk.sha256` 与 JSON 构建摘要。
7. 上传 `wenyou-apk/mobile/android/`；同名对象内容不同则拒绝覆盖。
8. 通过 metadata、公开 HEAD、sidecar 与 manifest 复核公网制品。
9. SSH 通知 VPS 晋级推荐构建，并再次读取公网 `/meta` 确认生效。

一次完整发布会运行全部测试和 release 构建，通常需要数分钟。窗口必须保持打开直到明确显示成功或失败；失败时不会跳过后续门禁。

## 手工分段与故障恢复

桌面入口不可用时，可从已安装工具显式选择阶段；版本默认读取 `pubspec.yaml`：

仅构建、验签并生成本地制品：

```powershell
& "$env:LOCALAPPDATA\WenyouSite\release\Invoke-WenyouAndroidRelease.ps1" `
  -Mode BuildOnly
```

上传并验证 RainS3，但不向用户推荐：

```powershell
& "$env:LOCALAPPDATA\WenyouSite\release\Invoke-WenyouAndroidRelease.ps1" `
  -Mode UploadOnly
```

完成构建、上传与 VPS 晋级：

```powershell
& "$env:LOCALAPPDATA\WenyouSite\release\Invoke-WenyouAndroidRelease.ps1" `
  -Mode Publish
```

底层 Git Bash 入口仍为 `tool/release-mobile-from-local.sh`。上传成功但 VPS 晋级失败时，对象保留为未广告制品；修复 SSH 或 VPS 后可幂等重试，同名同摘要对象不会重复覆盖。

固定对象参数为：

```text
endpoint=https://cn-nb1.rains3.com
region=auto
bucket=wenyou-apk
prefix=mobile/android
publicBaseUrl=https://wenyou-apk.cn-nb1.rains3.com
Content-Type=application/vnd.android.package-archive
Cache-Control=public, max-age=31536000, immutable
```

## 撤回、强制升级与密钥轮换

坏版本先在 VPS 撤回推荐策略，再以更高 build 发布修复；不覆盖 RainS3 对象，不降低 Android versionCode：

```bash
sudo -n /usr/local/sbin/wenyousite-promote-android --withdraw
```

撤回会清除 Android `minimumSupportedBuild`、`recommendedBuild` 与 `updateUrl`，停止新的更新提示，但不会删除已上传对象。普通发布只更新 `recommendedBuild`；提高 `minimumSupportedBuild` 必须由维护者单独评估，不能由桌面入口自动决定。

RainS3 密钥轮换顺序：先创建最小权限新密钥，在 Windows 重新运行 `Set-RainS3Credentials.ps1` 并完成一次 `UploadOnly`，确认成功后撤销旧密钥。SSH 私钥轮换时先把新公钥加入 VPS，重新运行安装器与 SSH 初始化验证，再删除旧公钥。

## 客户端更新行为

- 客户端在启动和回到前台时读取 `/meta`；小于推荐构建号显示可关闭提示，小于最低支持构建号才阻断使用。
- Android 在下载前核对 RainS3 类型、长度、应用 ID、版本和 SHA-256，再以 `.part` 下载到 cache 并计算摘要；只有验证完成的文件才交给原生安装桥。
- 原生桥在打开系统安装器前再次验证包名、目标构建和当前应用签名；对象校验、HTTPS、客户端哈希与 Android 包校验共同保护发布链路。
- FCM/APNs 不传输 APK。VPS 只在 `/var/lib/wenyousite/mobile-release-history.tsv` 保存小型晋级历史，不保存安装包。
- 旧对象暂不自动删除；设置生命周期策略前必须确认对象没有仍被 `/meta` 引用。

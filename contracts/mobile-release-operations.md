# 移动端私有发布运维

Flutter 构建、正式签名、APK 验收和对象存储上传始终在 Windows 开发机完成。VPS 不接收或分发 APK，只在对象已公开可读后更新 `GET /api/v1/meta` 的推荐构建号与下载地址。

## 一次性准备

- 正式 keystore 与 `android/key.properties` 只保存在开发机，并做加密离线备份；禁止提交 Git 或上传 VPS。
- RainS3 使用独立桶 `wenyou-apk`。公开读仅允许 `mobile/android/*`，禁止匿名写和目录列表。
- 为开发机创建发布桶专用 AccessKey；它不得访问媒体桶，也不得进入 APK、客户端、Git 或 VPS。
- VPS 使用无密码专用 SSH 发布用户。该用户只能通过 sudo 调用版本晋级脚本，不能执行任意命令或读取后端 `.env`。

Windows Git Bash 在每次发布会话中无回显读取密钥，避免把明文写入 shell 历史：

```bash
read -r -p 'RainS3 Access Key: ' WENYOU_RELEASE_S3_ACCESS_KEY_ID
read -r -s -p 'RainS3 Secret Key: ' WENYOU_RELEASE_S3_SECRET_ACCESS_KEY
printf '\n'
export WENYOU_RELEASE_S3_ACCESS_KEY_ID WENYOU_RELEASE_S3_SECRET_ACCESS_KEY
export WENYOU_RELEASE_SSH_TARGET='wenyou-release@wenyou.site'
```

不要把这两个变量写入仓库脚本。首次使用专用发布用户前，在 Windows 执行 `ssh-keygen -t ed25519`（已有默认密钥可跳过），再由 VPS 管理员把对应 `.pub` 公钥安装到 `wenyou-release`；私钥始终留在 Windows。

其余默认值为：

```text
endpoint=https://cn-nb1.rains3.com
region=auto
bucket=wenyou-apk
prefix=mobile/android
publicBaseUrl=https://wenyou-apk.cn-nb1.rains3.com
```

## 构建、上传与晋级

仅完成本地构建和验签：

```bash
./tool/release-mobile-from-local.sh \
  --version 0.3.0-dev.37 \
  --build 43 \
  --platform android \
  --build-only
```

上传 RainS3、验证公网对象，但暂不向用户推荐：

```bash
./tool/release-mobile-from-local.sh \
  --version 0.3.0-dev.37 \
  --build 43 \
  --platform android \
  --upload-only
```

完整发布去掉 `--build-only` / `--upload-only`。流程固定为：

1. 运行 Flutter 检查并构建正式签名 APK。
2. 校验 zipalign、签名、`site.wenyou.app`、versionName 与 versionCode。
3. 生成版本化 APK、`.apk.sha256` 和 JSON 构建摘要。
4. 直接上传 `wenyou-apk/mobile/android/`；同名对象已存在且内容不同则停止，绝不覆盖。
5. 通过对象 metadata、公开 HEAD、sidecar 与 manifest 复核大小、摘要和响应头。
6. SSH 通知 VPS 晋级版本；VPS 不下载 APK，只原子更新 `/meta` 策略。

APK 固定响应头：

```text
Content-Type: application/vnd.android.package-archive
Cache-Control: public, max-age=31536000, immutable
Content-Disposition: attachment; filename="wenyou-<version>-<build>.apk"
```

上传成功但 VPS 晋级失败时，对象保留为未广告制品，可在修复 VPS 后幂等重试。普通发布只更新 `recommendedBuild`；`minimumSupportedBuild` 必须另行人工决定。

## 客户端行为与故障处理

- 客户端在启动和回到前台时读取 `/meta`；小于推荐构建号显示可关闭提示，小于最低支持构建号才阻断使用。
- Android 先用 RainS3 HEAD/GET 响应核对 APK 类型、长度、应用 ID、版本和发布 SHA-256，再以 `.part` 下载到 cache 并计算 SHA-256；只有验证完成的文件才交给原生桥。FCM/APNs 不传输安装包。
- 原生桥在打开系统安装器前再次解析 APK，要求包名为 `site.wenyou.app`、versionCode 等于 `/meta` 目标且高于当前构建，并与已安装应用具有相容签名；发布工具的对象校验、HTTPS、客户端哈希与 Android 包校验共同保护发布链路。
- 坏版本先在 VPS 执行撤回，停止新的推荐提示，再发布更高 build 修复；不覆盖对象、不降低 Android versionCode。
- 旧对象暂不自动删除。需要生命周期策略时，先确认没有仍被 `/meta` 引用的版本。

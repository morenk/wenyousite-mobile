# 温油站移动端

温油站的 Flutter 原生客户端。首发 Android 8+（API 26），手机竖屏优先；共享 Dart 代码保持 iOS 兼容，但当前不做 iOS 验收。

当前版本：`0.3.0-dev.78+84`。默认连接公网开发 API `https://wenyou.site/api/v1`，请只使用专用测试账号。

## 技术基线

- Riverpod：状态管理与依赖注入
- go_router：主导航、鉴权回跳与目标恢复
- Dio：请求追踪、双 Token 刷新锁、安全重试与上传
- OpenAPI Generator `dart-dio`：固定契约客户端，输出在 `packages/wenyou_api`
- Drift：完整 Markdown 编辑快照和待确认幂等创建操作
- Flutter Quill：仅作为内存编辑模型；后端、云草稿和本地快照始终保存 Markdown v3
- flutter_secure_storage：Access/Refresh Token 单记录原子替换
- wenyousite-foundation v2.4.2：跨端语义 Token、图标注册表、三角色自托管字体、移动 profile 与编辑器体验契约
- WenyouThemeTokens：Foundation 常量到 Flutter ThemeExtension 的轻量适配层

产品与模块事实从 [`docs/README.md`](docs/README.md) 开始阅读；共享审美只以锁定版本的 [`wenyousite-foundation`](https://github.com/morenk/wenyousite-foundation/tree/v2.4.2) 为事实源；协作约束见 [`AGENTS.md`](AGENTS.md)。

## 本地环境

本机 SDK 约定：

```text
D:\sdk\flutter
D:\sdk\android
Node.js 22+
Flutter 3.44.8 / Dart 3.12.2
```

确认环境：

```bash
flutter doctor -v
flutter pub get
npm ci
```

移动端默认连接部署在 VPS 的公网开发 API，不在 Windows 启动后端。只有已经显式建立“Windows `127.0.0.1:3000` → VPS `127.0.0.1:3000`”SSH 隧道时，Android 模拟器才使用：

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

不传 `API_BASE_URL` 时连接公网开发 API。Windows 下的前端和后端目录均为只读参考镜像，不得在移动端任务中安装依赖、启动服务、迁移或部署。

## 契约同步

后端契约只在 API、Markdown 语料、移动推送协议或移动端接入指南变化时同步，不需要为普通后端实现提交机械拉取。同步脚本会动态固定当前版本的 Markdown 规范化、节点和编辑器往返语料，以及 OpenAPI、mobile push v1 Schema/样例、移动 V1 黄金旅程与 operationId 分类、动态分类 fixture、合同变更记录和接入指南。

```bash
powershell.exe -NoProfile -File tool/sync_backend_contract.ps1
npm run api:validate
npm run api:generate
```

生成代码禁止手改。契约变化必须使用独立 `chore` 切片，并同步受影响模块文档与 [`docs/CHANGELOG.md`](docs/CHANGELOG.md)。

## 质量门禁

第一阶段以快速本地迭代为主：日常切片只运行相关测试和受影响范围检查；认证、契约、网络、持久化等高风险变更或阶段验收时运行唯一完整本地门禁：

```bash
npm run check
```

需要 Debug APK 时运行 `npm run check:apk`。完整门禁和 Android 发布入口都会强制执行公网 API、后端 revision 与 Markdown 契约核对，避免兼容版本先于服务端事实发布。

GitHub Actions 当前仅支持手动触发，不随 `dev` push 自动运行，也不作为日常切片完成条件。日常切片完成后默认原子提交并推送 `dev`；`main` 的合并与正式 Tag 只在维护者明确决定时执行。

## Android 私有发布

正式 APK 由 Windows 开发机验签后直接上传独立 RainS3 桶，VPS 只更新 `/meta`，不保存或转发安装包。首次在 Windows 执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/windows/Install-WenyouReleaseTools.ps1
```

安装完成后，桌面 `Wenyou-Release-Setup.cmd` 只用于首次核验 VPS 指纹；日常提交、推送并更新 `pubspec.yaml` 后，双击 `Wenyou-Publish-Android.cmd` 即可完成测试、构建、验签、上传、晋级和线上复核。DPAPI 凭据、手工回退和撤回方法见 [`contracts/mobile-release-operations.md`](contracts/mobile-release-operations.md)。

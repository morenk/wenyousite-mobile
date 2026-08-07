# 温油站移动端

温油站的 Flutter 原生客户端。首发 Android 8+（API 26），手机竖屏优先；共享 Dart 代码保持 iOS 兼容，但当前不做 iOS 验收。

当前版本：`0.2.0-dev.3+5`。默认连接公网开发 API `https://wenyou.site/api/v1`，请只使用专用测试账号。

## 技术基线

- Riverpod：状态管理与依赖注入
- go_router：主导航、鉴权回跳与目标恢复
- Dio：请求追踪、双 Token 刷新锁、安全重试与上传
- OpenAPI Generator `dart-dio`：固定契约客户端，输出在 `packages/wenyou_api`
- Drift：完整 Markdown 编辑快照和待确认幂等创建操作
- Flutter Quill：仅作为内存编辑模型；后端、云草稿和本地快照始终保存 Markdown v2
- flutter_secure_storage：Access/Refresh Token 单记录原子替换

产品与模块事实从 [`docs/README.md`](docs/README.md) 开始阅读；协作约束见 [`AGENTS.md`](AGENTS.md)。

## 本地环境

本机 SDK 约定：

```text
D:\sdk\flutter
D:\sdk\android
Node.js 22+
```

确认环境：

```bash
flutter doctor -v
flutter pub get
npm ci
```

Android 模拟器连接本地后端：

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

不传 `API_BASE_URL` 时连接公网开发 API。

## 契约同步

后端契约只在 API、Markdown 语料、移动推送协议或移动端接入指南变化时同步，不需要为普通后端实现提交机械拉取。同步脚本会固定 OpenAPI、两层 Markdown v2 语料、mobile push v1 Schema/样例、合同变更记录和接入指南。

```bash
powershell.exe -NoProfile -File tool/sync_backend_contract.ps1
npm run api:validate
npm run api:generate
```

生成代码禁止手改。契约变化必须使用独立 `chore` 切片，并同步受影响模块文档与 [`docs/CHANGELOG.md`](docs/CHANGELOG.md)。

## 质量门禁

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --fatal-infos --fatal-warnings
flutter test
npm run api:check
npm run docs:check
flutter build apk --debug
```

日常切片完成后默认原子提交并推送 `dev`。`main` 的合并与正式 Tag 只在维护者明确决定时执行。

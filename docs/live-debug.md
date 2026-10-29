# Flutter Debug 开发

日常开发直接使用 Flutter Debug、已有 API 和热重载。Backend 快照、consumer、预览批次和后台控制器已退役，不再是启动条件。

## 启动与反馈

在本任务 Windows Worktree 中确认 SDK、依赖和设备。先检查其他任务或 IDE 是否正在使用同一设备的 `site.wenyou.app.debug`；已有本任务会话直接复用，其他任务占用时保留现场。

```powershell
flutter devices
npm run dev -- -d <设备序号>
# 需要连接已有开发 API 时显式指定真实地址。
npm run dev -- -d <设备序号> --dart-define=API_BASE_URL=https://dev.example.test/api/v1
```

`npm run dev` 是 `flutter run --debug` 的薄入口，透传标准 Flutter 参数和终端输入。它只核验 Debug 包名并使用任务目录内的 ADB guard：Flutter 覆盖安装失败后尝试卸载时会被拒绝，保留旧登录态和草稿。它不启动 Backend、数据库、SSH、ADB reverse 或后台会话服务，不改共享 SDK 或全局 Flutter 配置。普通 `flutter run --debug` 的开发方式仍可使用，但 Flutter 本身可能在覆盖安装失败后自动卸载旧包；代理安装含用户数据的 Debug 包必须经过此保护入口。

- 同一反馈批次保留原终端：`r` 热重载，`R` 热重启，`q` 停止。也可使用 Flutter machine 协议，但不再有专用 `dev:*` 控制命令。
- 展示变动先热重载；初始化、Provider、路由、全局／静态状态变动热重启。
- API 的 Dart defines 变动必须退出并重启。依赖、资源、字体、代码生成变动执行相应获取／生成并重启；插件、Manifest、Gradle 或原生代码变动重新构建。
- 启动前后核对 `site.wenyou.app.debug`、设备、应用更新时间；首次安装核对 APK SHA-256。安装失败时停止，不卸载、不清数据、不降级覆盖正式包。
- 热重载画面记录当前源码 SHA、含未提交变化的内容摘要、Worktree、设备、API、会话及 reload 结果。首次 APK 哈希不能代表热重载后的画面。

同一会话的纯展示调整保持当前页面和会话，直接热重载，不机械重建环境。

本入口无后台登记／控制器；任务自行保留终端与归属记录，不接管其他会话。退出 Flutter 不清除应用数据，也不停止其他任务的进程或隧道。

## API 与数据边界

没有显式 `API_BASE_URL` 时保持应用原默认值 `https://wenyou.site/api/v1`。自定义地址不可用时报告错误，不静默切回默认值。普通 Debug 预览可直接启动、复用和热重启；登录恢复、自动签到等应用正常启动行为无需另行检查或审批，不作为暂停预览或要求负责人手动启动的理由。仍记录实际 API 和会话归属，保留现有登录态与草稿，不为预览修改自动签到产品逻辑。

公网与 Tailnet 开发环境仍按线上保护，本机 Debug 或 loopback 地址不代表数据隔离。普通调试启动授权不扩展为代理自动执行发帖、上传、删除等业务写入 E2E；负责人自行操作与代理自动化测试分别记录。

写入 E2E 继续要求独立 PostgreSQL、Redis、上传路径与账号，关闭真实邮件、推送及外部存储写入。登录／写入前核验资源身份和实际 API 目标；失败立即停止，登记 runId、资源归属及清理结果。详见[治理 E2E 数据隔离规范](https://github.com/morenk/wenyousite-workspace/blob/main/docs/e2e-data-isolation.md)。

普通构建沿用既有 Token、偏好、Drift、待确认操作、图片草稿、诊断和缓存路径。`API_BASE_URL` 本身不分区本地账号和草稿；不要把当前账号或待提交内容带到另一环境。需要操作不同环境时先明确数据边界，不自动复制、清空或迁移用户数据。

## 旧方案退役

`dev:start/status/list/reload/restart/stop`、consumer 私有协议、身份探测与预览横幅已移除。残留 `WENYOU_PREVIEW_*` Dart defines 会显式拒绝启动，须移除后重新确认 API，不能复用旧 consumer 启动新客户端。

旧 `preview_<run>.…` 安全存储键、偏好、数据库、图片草稿与缓存保留在原处。普通客户端不再读取这些数据；需要找回时使用旧版本的对应任务现场按原归属显式导出，不能直接导入普通账号。此次退役不执行设备清理、旧会话停止或 `%LOCALAPPDATA%\Wenyou\live-debug` 清理。仍在运行的旧会话由其原任务、旧版本工具处理。

## 检查与验收

局部低风险纯样式修改（如背景色、间距、圆角和单个组件外观）从开发反馈到合并前都只做直接相关的 Widget/Golden／精确回归、受影响文件静态检查和必要视觉验证，不默认跑全量 Flutter 测试、`npm run check`、`npm run check:apk` 或无关契约与发布工具检查。没有合适自动用例时记录实际画面与未覆盖项，不为形式新增复述实现的测试。具体适用范围和例外见 [AGENTS.md 的质量门禁](../AGENTS.md#8-质量门禁)。

纯展示调整优先热重载；需要脱离会话使用或发布产物时才按现有入口构建一次，不因构建而追加全量测试。源码、依赖和构建配置未变时复用有效证据。实际工具依赖需要全量静态分析、影响范围扩大或发现失败／风险时，说明原因后扩大相关验证。网络、认证、持久化等高风险变更与正式晋级发布仍须原有门禁；负责人验收和数据隔离要求保持不变。环境或设备未就绪时报告具体阻塞，Widget/Golden 只作辅助证据。

# 持续 Debug 与隔离开发预览

开发反馈顺序为：agent 启动预览 → 改样式 → 热重载查看 → 连续反馈 → 收敛后交付门禁。同一批次使用同一任务、Worktree 和 PR。交互式预览不是一次性 E2E，不在每次反馈后删除数据。

## 启动与控制

Backend 管理入口准备当天快照与独立预览实例后，将无密钥 `consumer.json` 交给本任务。协议固定版本见 `contracts/dev-preview-session-source.json`；只接受 ready 描述和真实身份匹配的实例。所有数据和邮件收件箱留在 VPS，Windows 不获取线上数据库或存储凭据。

```powershell
npm run dev:start -- --session C:\private\consumer.json
npm run dev:status
npm run dev:list -- --json
npm run dev:reload
npm run dev:restart
npm run dev:stop
```

- 默认识别唯一已连接 ARM64 真机；多个设备时添加 `--device <序号>`。SDK 从环境变量与本机约定路径发现，Flutter 使用 SDK 内的 Dart 与 flutter_tools.snapshot。
- `start` 幂等，同一任务与 runId 复用现有会话。首次 `flutter run --machine --debug` 编译并安装 `site.wenyou.app.debug`；普通热重载不再次安装，不更改正式包或其数据。
- `reload` 调用 `app.restart(fullRestart: false)`；`restart` 使用 `true`。初始化、Provider 装配或全局状态变更用热重启；依赖、资源、生成代码变化先执行对应获取／生成，必要时停止再启动；原生变化重新构建。
- 进程隐藏运行，控制地址只监听 loopback，状态目录为 `%LOCALAPPDATA%\Wenyou\live-debug`。ACL 仅当前用户与 SYSTEM 可读；控制 token 不输出到状态展示、事件或源码。不要分享私有状态文件。
- 同设备 Debug 包一把独占锁，控制器绑定任务分支、绝对 Worktree、设备、runId、PID 与进程开始时间。不能从另一个 Worktree 接管。`status` 可从新终端调用；异常退出在原 Worktree 执行 `stop` 按登记恢复清理。
- 启动、恢复与停止共享 Windows Named Mutex，持锁后重新读取归属；系统在控制进程异常退出时释放互斥。daemon 必须核对本次启动 token、runId 和 PID 后才能领取状态，迟到的旧 daemon 不能控制新批次。
- `dev:start` 还与治理桥接共用 `%LOCALAPPDATA%\Wenyou\preview-control\transition.lock`，避免治理检查无人使用后又有 Mobile 接入旧批次。锁不可重入，只能回收确认 PID 已退出的普通锁文件；活 PID、权限失败、坏锁和遗留 recovery 锁均保留并拒绝本次启动。start 发布初始状态与设备锁后，后台启动继续受会话登记保护。
- `dev:list` 只读当前用户全部 Worktree 的登记，不启动 SDK、ADB 或 Flutter，不输出控制凭据。它核验控制器开始时间、设备锁及 authenticated status，区分已核验活动会话、干净停止的历史会话和归属不明的阻塞项。治理在共同过渡锁内调用 `node tool/dev/list.mjs --json`；绑定旧 run 的 `active` 或 `blocked` 条目阻止暂停、断开共享桥接及切换。需要释放时由原任务执行 `dev:stop`，不能从治理接管其他任务设备。完整输出协议见 [Mobile 会话查询协议](../contracts/mobile-dev-session-list.md)。
- Flutter 与自有 SSH 使用 Windows Job Object：挂起创建进程，登记 Job 后才继续运行，并绑定 daemon 的实际进程句柄。daemon、根进程或 wrapper 被强杀都会回收全部后代，覆盖子进程尚未写入状态文件的窗口；不能证明后代归属的旧状态保留设备锁，不宣称清理完成。
- 首次安装通过任务私有 SDK 视图内的 ADB guard；共享 Android SDK 与 Flutter 配置不修改。guard 保留参数、二进制管道及退出码，拒绝 `uninstall`／`pm clear`，阻止 Flutter 覆盖安装失败后自动卸载旧包。启动前以真实 `flutter devices --machine` 核验 guard 确实被使用；不能核验或安装失败则停止，保留旧登录态和草稿。

## 网络与持久化边界

SSH 只转发本批次 API 与媒体端口到 `wenyou-dev-vps` 的 loopback，ADB reverse 保持相同端口，预签名 URL 不改写。已有同端口隧道只有实际 backend/media 身份全部匹配才借用；仅本任务创建的隧道和 reverse 会在 stop 时清理。Web/Mobile 联合批次先由治理桥接持有共享隧道，Mobile 再借用；Mobile 自建隧道只供当前 Mobile 会话。不要在反馈批次中关闭治理共享隧道。

服务器的新入口统一使用 Web `14310`、API `14311`、媒体 `14312`，同时仅运行一个交互批次；Mobile 继续消费 v1 的安全 loopback 描述，兼容尚未迁移的旧端口。固定地址切换不改变 App 编译时的 runId：旧页面每次请求重新探测身份，错误批次或暂停立即拒绝请求，原 run 恢复后才重新放行。Token、待确认写操作及图片草稿按 runId 保留，切换端口不会把旧草稿或旧会话传给新批次。不要手工覆盖 consumer 描述来热重载不同 run；停止原 Debug 后由目标任务重新启动。

启动和运行期间检查服务实际 PostgreSQL／Redis／媒体身份；App 在登录、API 请求及直传前重新核验双方身份。API 加 `X-Wenyou-Preview-Run`，直传保留原签名。拒绝重定向、错误批次、线上端口和未知上传 origin。失败停止请求，绝不回落到线上 `3000` 或公网 API。Backend／媒体暂不可用时控制器标记 unavailable，保留 Flutter 与当前页面，正确身份恢复后自动回 ready；设备、自有 SSH 或 Flutter 退出才停止调试。

Token、Drift、图片草稿、持久偏好、诊断与图片缓存按 runId 分离。线上继续使用原键和原文件；切换环境不自动复制或删除数据。系统选图只恢复属于当前命名空间的选择。预览关闭 Sentry；页面显示开发预览及快照时间；Release/Profile 拒绝预览 defines。

## 反馈和验收证据

开发中只执行直接相关测试，不因每次保存执行完整门禁。`events.jsonl` 记录每次成功启动、热重载／热重启的源码 SHA、包含未提交修改的 SHA-256、runId、设备、Flutter appId、Android 进程与包更新时间；初装另核对设备 APK 哈希；不得把最初 APK 哈希作为热重载画面版本。源码在热重载期间又发生变化时必须重试，失败不覆盖上次成功证据。

反馈收敛后对最终源码执行仓库规定门禁。网络／认证／持久化等高风险改动首次候选仍需完整门禁与构建；本工具只改善后续反馈节奏，不取消交付检查。独立 APK 仅在需要离开 Debug 会话验收或构建条件变化时生成。视觉结果仍由负责人确认；自动检查不替代真机画面与交互验收。

管理快照尚未审核启用时，只能用已核验隔离样本验证连接，必须注明“真实数据登录／图片链路待验收”，不能以 mock 身份端点证明隔离成功。停止保留后端数据，显式 reset/cleanup 按 Backend 归属门禁执行，Mobile 不自动重置批次。

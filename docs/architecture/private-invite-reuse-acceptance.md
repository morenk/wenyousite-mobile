# 私密邀请重复分享候选验收

状态：候选／待负责人验收。自动检查、辅助 Widget 画面与 APK 均不代表原问题已获负责人复验通过。

## 原问题与固定来源

原场景：楼主第一次复制私帖邀请后没有保存链接，离开页面后再次分享只能生成新链接。旧链接随重置失效，已加入成员从旧邀请入口访问也失败，容易被误认为已失去主题权限。

已核对旧 Mobile 基线 `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3`：面板只有“生成新邀请链接”，服务调用 POST；链接只在面板内存中保留，未提供重新取得入口。Backend 已明确重置不删除成员，本切片不改成员权限。

- Backend 固定 `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`，API `5.29.0-dev.20261001.1`；[Backend PR #38](https://github.com/morenk/wenyousite-backend/pull/38)。
- 独立契约提交 `4ca1a1e325c33a1fa0ff4a94a33ad9e7419b9b3b`；同步脚本固定分支和完整 SHA，客户端使用 OpenAPI Generator 7.23.0 生成，无手改产物。
- Foundation 保持已发布 v7.2.1；本次[共享交互文档 PR #28](https://github.com/morenk/wenyousite-foundation/pull/28)不新增包、Token 或 API。

## 候选行为

- “复制邀请链接”每次调用 PUT 取得当前链接，无则首次创建；离开、重启或换设备不依赖本地保存。接口失败不会回退 POST。
- “重置邀请链接”单独确认旧链接立即失效且成员权限不变，确认才 POST；成功展示并尝试复制。重置显式 `authenticatedNonReplayable`，不自动刷新后重放或网络重试。
- 超时、429、5xx、响应不可消费及重置401续期后只用 PUT 核对当前链接。取得成功也不声称重置成功；核对失败保留不确定上下文且不展示可能过期的旧链接。
- 请求失败与剪贴板失败分别处理。剪贴板失败保留可长按复制的链接。锁覆盖确认、请求和剪贴板；切号、销毁、主题切换和权限撤销使迟到结果失效，不能复制、提示或显示。

## 回归与检查证据

旧实现红灯：`flutter test test/features/threads/thread_invitation_controls_test.dart --plain-name '重新打开私密邀请可直接复制而不必重置链接'` 退出 1，期望 1 个“复制邀请链接”，实际 0 个。该断言在新候选保留。

定向用例：

- `test/features/threads/thread_invitation_controls_test.dart`：连续复制、重开、不重置、确认/取消、响应丢失、核对失败、剪贴板失败、操作锁、账号/销毁/权限/目标切换及320dp明暗画面。
- `test/features/threads/thread_invitation_repository_test.dart`：PUT生成类型与目标校验，POST原端点与禁止重放策略、邀请预览/加入回归。
- `test/features/threads/thread_invitation_controller_test.dart`：取得状态、失败清空凭据、成员加入幂等与预览竞态。
- `test/features/threads/thread_invitation_page_test.dart` 与 `test/features/threads/thread_management_page_test.dart`：邀请路由与已发布私密楼主入口、非楼主及公开主题边界。

最终定向检查 `thread_invitation_controls_test.dart` 与 `thread_invitation_controller_test.dart` 合计 28 项通过。首轮开发定向检查发现确认弹窗打开时背景异步按钮持续显示进度动画，导致等待稳定画面超时；已区分确认与请求阶段并保留锁，复跑通过。既有已加入预览再次读取返回 404 时会清空预览并进入失败终态，本次补充回归确认，不改邀请落地页实现。

完整入口使用 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，用于在保留生产契约失败的同时一次收集其余检查。OpenAPI、固定来源、重新生成无漂移、1129 个文件格式、应用与生成客户端静态分析、架构、21 个模块文档、162/162 移动端范围 API 覆盖均通过。Flutter 全量 5026 项通过、1 项跳过、0 项失败；跳过项为原有显式 Sentry 外部接收验收，本轮未开启。Windows 发布与持续 Debug 工具测试 67/67 通过，ARM64 Debug APK 构建成功（assembleDebug 255.0s）。最终原始退出码为 **1**，唯一失败项是生产契约核验，整体门禁未通过。

生产只读契约核验失败：本地期望 API `5.29.0-dev.20261001.1`、build `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`，实际公网 API `5.28.0-dev.20260929.1`、build `21acf512285f2a21aaa831f960211780de73aafc`。线上 Markdown 5 在客户端支持集合 `{3, 4, 5}` 内，失败来自 API 版本及构建 SHA 差异。未跳过、放宽或伪造生产校验，也未为了通过门禁部署后端。

本地证据保留于本任务 Worktree `D:/codex-worktrees/mobile-invite-reuse/wenyousite-mobile`：

| 证据 | 路径与校验 |
| --- | --- |
| 原始完整日志 | `.buildlog-invite-full.log`；SHA-256 `ae96292fde395f0edbcce447d605392c4e7984dc4753a8a46c86902f5ee42f0a` |
| 本次 APK | `build/app/outputs/flutter-apk/app-debug.apk`；109445894 字节；SHA-256 `fb2b248eb4b3d5541b434a70a3b9cb04ba4551066a26c6959a0ab065266379d8` |
| APK 身份 | aapt 与 `build/app/outputs/apk/debug/output-metadata.json` 核验：`site.wenyou.app.debug`、`0.8.0-debug`、versionCode `97`、`arm64-v8a` |
| 应用源码摘要 | 复用 `tool/dev/runtime.mjs` 的 `sourceEvidence`；构建期间与之后均为 `c9b60db3861f805be96849bd6a22304777b5ae89d5b8d5d514762dce3cbeb4b5`。完整检查后只补充文档，应用源码未变 |

提交前已重新 fetch：`origin/dev` 仍为基线 `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3`，无遗漏上游提交；远端本任务分支尚不存在。APK 未安装，保留构建证据不代表生产功能已可用或设备验收通过。

## 画面、环境和负责人复验

辅助画面来自真实 Flutter Widget 渲染，使用内存样本仓储与确定性测试字体，未访问真实账号或线上业务。320dp light/dark 的邀请内容与重置确认各一张，位于 `test/features/threads/goldens/thread_invite*_320_*.png`。

本机 `adb devices -l` 无连接设备，未启动或接管 Debug 会话、未安装包，也未执行真实账号登录。Mobile 本次仅运行内存测试，没有 Mobile 联网写入 E2E 或真实数据、设备验收证据；独立隔离 API 证据由 Backend PR 提供。不向公网写入业务数据。

现有 Mobile 使用 API origin 组合 Web `/join/{token}`：公网同源 URL 正常；隔离预览 API 与 Web 分端口且未向 App 注入独立 Web origin，因此只能核对 token 与业务 API 语义，不能声称 Web/Mobile 预览完整 URL 一致。本次不扩张预览协议和 ADB 转发范围。

负责人待复验清单：

1. 已发布私帖楼主进入“主题管理 → 私密邀请”，连续复制及关闭重开后复制，同一个有效链接保持不变。
2. 重启 App，并在 Web 或另一设备复制，确认仍为同一链接。
3. 重置前取消不改变链接；确认重置后新链接可用，旧链接对新旧成员均无效，但旧成员直接从主题入口仍能阅读。
4. 弱网或剪贴板失败时不出现误导成功；恢复后再次复制可用，重置丢失响应不会被自动重复提交。
5. 切号、撤销权限或离开面板后的迟到结果不显示、不复制；320dp及明暗界面可读，放大文字可滚动。

默认仅交付检查、任务分支与 PR。必须先合并并发布兼容 Backend，再发布消费者；无自动合并或部署。

生产门禁精确比较 API 版本与 `buildSha`。兼容 Backend 合并部署后，如果实际部署 SHA 不同于当前固定 `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`，必须按现有契约同步入口更新来源登记至实际已部署 SHA，确认契约和生成客户端内容没有漂移，再单独复核生产门禁；不能只凭 API 版本一致声称通过。当前保留已提交的候选事实源，不预猜合并 SHA、不放宽比较。

完整门禁生成的默认 Debug APK 使用公网 API 配置。新 PUT 尚未部署时，它仅作构建证据，不能冒称安装后即可在公网完成本功能验收；真实可操作复验须在兼容 Backend 发布后，或设备就绪后通过已核验的持续 Debug 预览进行。

# 退役隔离开发预览：验收记录

## 范围

从 `origin/dev` 的 `dd1f9edb2542d40f4dfac0b03432340ee0bfe72e` 开始，移除专用 preview consumer、会话控制器、身份探测、批次横幅与运行端存储分支。普通 Flutter Debug 继续使用原 API 配置和存储路径；ADB 防卸载保护独立为薄启动入口。业务 OpenAPI、账号分区、数据库 Schema 和独立写入 E2E 不变。

实施提交中，`contracts/thread-identity.md` 与 `contracts/app-download-gateway.md` 从 Backend 已提交并推送的 `1fa648e04d576f8d52198b4f959204a744b4a0e2` 使用只读 `git show` 原样导出，仅同步退役说明。业务 OpenAPI 不变；合并前的实际部署来源同步见下节。

旧预览磁盘数据保留，不迁移、不删除；普通客户端不再访问。旧 Dart defines 显式拒绝启动，避免原脚本悄悄换到普通账号。历史验收文档保留。

## 检查与未覆盖范围

完整入口：`npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`。本轮使用收集模式执行全部阶段，不能把非零结果称为完整门禁通过。

- Flutter 全量：5431 项通过，1 项原有外部验收跳过。
- OpenAPI 校验、固定契约来源、客户端再生成一致性、Dart 格式、生成 API 分析、架构、22 个模块文档和 API 覆盖检查通过。
- 应用分析首轮扫描到临时纯 Dart 探针，出现文件名及 print lint；探针已移到仓库外，`flutter analyze --no-pub --fatal-infos --fatal-warnings` 补验零问题。未修改 lint 配置，原失败日志保留。
- 公网只读核对失败：固定来源为 `a624bed0eb2b118701bd593fbce2aabf3dea7321`，线上实际为 `a3849f2bb54aa497c21cdd0843cdd173ffbe4b70`；API 版本同为 `5.36.0-dev.20261005.1`，线上 Markdown 为 5（客户端支持 3/4/5/6）。本任务不通过改写来源或部署规避该差异。
- 专项覆盖 `test/core/config/app_environment_test.dart`、`test/core/storage/retired_preview_data_test.dart` 与 `tool/debug/*.test.mjs`。此外纯 Dart 进程验证普通默认／自定义 API，以及六种空值旧 defines 均显式拒绝；实际 Node 入口对旧参数和非 Debug 模式在 SDK/设备访问前拒绝。

应用与 Debug 工具的工作区源码 SHA-256：`9f9b41b7209ab03759d85fc056c636f5af37dff3e81dddba7ebff7c797160101`，按排序后的 1858 个源码／资源文件名、NUL 和文件字节累计计算，范围为 lib、android、assets、pubspec、packages 和 tool/debug。本地证据为任务 Worktree 的 `retirement-quality-gate.log`、`analyze-final.log` 与 `build/retirement-source-evidence.json`。Windows 发布与 Debug 工具 49 项全通过、无跳过。Debug 构建成功（assembleDebug 326.9 秒），同一次完整入口最终因上列两项失败返回 1；应用分析补验通过后，仅公网来源核对差异仍未消除。

APK 位于本任务 Worktree 的 `build/app/outputs/flutter-apk/app-debug.apk`，109995654 字节，SHA-256 `991908d70fbce80e899ad97023932bc024e43b922768d3a3db6add6770ffdcb7`。aapt 核对包名 `site.wenyou.app.debug`、显示名“温油站 Debug”、版本 `0.9.0-debug+99`，仅 `arm64-v8a`，最低 API 26。保留原有 Kotlin 插件／SDK XML 工具警告；未修改依赖或原生配置。

未连接或安装真机，未停止旧会话，未清理任何用户数据或运行资源，未部署。设备启动与负责人画面验收仍未执行；本次代码与工具检查不能代替该结果。

## 2026-10-10 合并前部署来源复核

Backend PR #49 合并并通过管理入口部署后，使用官方 `tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Revision b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045` 同步实际部署提交。对同步前 42 份文件逐个比对 SHA-256，仅 `backend-contract.properties` 的来源一行变化，机器契约、共享语料及两份已退役说明完全一致。22 份模块文档补充本次来源登记，不改写历史审查结果。

`npm run api:verify:production` 退出 0：公网 API／bundle 为 `5.36.0-dev.20261005.1`，build 精确等于上述 SHA，运行时 Markdown 5 在客户端支持范围，`GET /threads?limit=1` 结构兼容。日志为 `build/retirement-deployed-production.log`，本次仅执行只读请求，未登录、启动应用或触发自动签到。

`npm run api:check`、固定列表／行内组合来源校验、`npm run docs:check` 和 `git diff --check` 均退出 0。官方生成入口输出与已提交客户端及诊断路由完全一致；对应日志为 `build/retirement-deployed-api-check.log`、`build/retirement-deployed-contract-sources.log` 和 `build/retirement-deployed-docs.log`。同步日志及逐文件哈希对比单独保留，未手改生成文件或元数据版本。

原始完整入口的退出 1 及分析失败证据保留；应用分析已补验通过，本次通过真实来源同步解除公网阻塞，不豁免精确版本、不改写原日志。应用源码仍为实施提交 `1f128758e85f5c98ddaa99dec41c7629c88c5581`，原全量测试与 APK 继续有效，不重复构建。这是开发工具退役，合并使仓库启动入口及后续构建生效，无需发布新版本或安装 APK；已安装客户端不会被 Git 合并自动更新，未执行的设备验收仍如实保留。

合并清理前把 APK、源码证据、原始完整日志和各次补验日志复制到 `D:/code/wenyousite/artifacts/development-preview-retirement-20261010/mobile`，逐文件复核 SHA-256，保留清单为该目录的 `preservation-manifest.json`。Worktree 仅在治理任务确认合并及清理核验通过后删除，不清理设备或旧隔离账号、草稿和缓存。

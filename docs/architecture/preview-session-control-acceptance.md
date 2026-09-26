# 单活动预览会话管理候选验收

状态：负责人已明确授权合并本工具候选；真实 Mobile 活动会话占用时的跨端联合切换仍未人工验收。本次只修改 Windows 开发工具、回归测试与文档；应用、Android、依赖及生成客户端没有变化，没有构建或安装 APK，没有接管其他任务的设备会话。

## 2026-09-27 合并前完整复验

- 以普通 merge 整合最新 `dev`：`8be9ffb105e1ba2cc157084e6e7d1f058ced70d0`，保留任务原提交 `703de64e82ee403b0397a308a3e057790fdce13e`，不改写共享历史。仅 `docs/CHANGELOG.md` 冲突，双方记录均保留；检查时源码树为 `7e0a7704be4f2d8867c93f3afaf9f25483821501`，之后只补充本记录和 CHANGELOG。
- `npm run check -- -TestConcurrency 2` 完整执行，退出 `0`：Flutter **4943 项通过、1 项既有显式跳过**；Windows 开发／发布工具 **61 项通过、0 失败**。契约、固定来源、生成无漂移、公网只读兼容性、格式、两处静态分析、架构、模块文档及 API 覆盖均通过。本轮没有 OOM；下方首次 OOM 与分段补验仍作为历史证据保留。
- 本地完整日志保存在临时 Worktree 外的 `D:\code\wenyousite\artifacts\mobile-preview-control-merge-20260927\check-final.log`，SHA-256：`70A87A23C6565FAF097BD27063E6BC3A080B39F0802C4B56CF4B62FC5FE21A03`；同目录 `check-final-result.json` 记录命令、时间、退出码与源码树，`runtime-comparison.json` 记录运行时文件逐项 Git 对象比较。
- 相对上述 `dev`，`lib`、`android`、`ios`、生成客户端、资源及字体、`pubspec.yaml`、`pubspec.lock` 和 `package-lock.json` 无差异；`package.json` 仅新增 `dev:list` 命令，依赖元数据一致。因此不重新构建 APK，本 PR 不改变该 `dev` 已构建 Release 测试包的运行时代码。
- 合并授权只针对 Mobile #68，不代表负责人已经完成设备联合验收，也不授权部署或合并其他仓库。本轮只读登记未发现活动 Mobile 会话，保留其他任务已经停止的登记，没有启动、接管或停止设备会话。

## 来源与行为

- Mobile 基线：`9108c6e57744999ae9c2de61e1c2290c8d1aea37`，分支 `codex/20260926-preview-control`，最终源码见本 PR。
- 治理过渡锁协议：`1338a78407ce83b9b0d039c59d411c0a67a45a39` 的 `docs/preview-session-control.md`。沿用 Backend 已固定的 v1 consumer 协议，不更新业务 OpenAPI 或 Foundation。
- `node tool/dev/list.mjs --json` 只读当前 Windows 用户登记，不要求 Flutter、ADB 或 SDK。活动状态同时核验 PID／开始时间、设备锁和 authenticated status；输出不含 token、控制口、私有描述路径或原始异常。
- `dev:start` 与治理 pause/switch 共用 `transition.lock`。仅已确认不存在的 PID 可在独占 recovery 锁内回收；坏锁、同 PID 重入、未知身份或替换锁均拒绝，保留现场。
- API／媒体端口固定为 `14311`／`14312` 后仍按 runId 核验请求及隔离本地持久化；继续兼容旧 v1 描述中的合法端口。

## 2026-09-26 首次候选自动核验

| 范围 | 结果 |
| --- | --- |
| OpenAPI、固定来源、重新生成无漂移 | 通过 |
| 公网 `/meta` 只读兼容性 | 通过，来源 `124fb4e8aa395440f7a2156de98b642ec87f7583`，API `5.26.0-dev.20260922.3` |
| Dart 格式、应用与生成客户端 analyze | 通过，零分析问题 |
| 架构、模块文档、消费端 API 覆盖 | 通过，保留既有架构尺寸提示 |
| 直接相关 Dart 回归 | 2 文件 10 项通过 |
| 开发会话工具 | 43 项通过 |
| 全部发布／开发工具 | `npm run test:release-tool` 串行 61 项通过，退出 0；包含上述 43 项，不重复累计 |
| 全部 Flutter 文件分段覆盖 | 412／412 文件完成，去重 4888 项通过、1 项既有跳过 |
| 最终端口定向复验 | 调整固定端口测试样本后，2 个 Dart 文件 10 项、2 个 Node 文件 19 项再次通过，格式零变化；不重复计入总数 |

`npm run check` 原始运行未通过：默认单并发 Flutter 在 4390 项通过、1 项跳过时发生明确的 `Dart VM Out of memory` 和 `Could not start thread DartWorker`；Flutter 退出 `-1073740791`，外层 PowerShell 也因内存不足退出 `-532462766`。失败前无断言失败。本记录不把原命令改记为成功，也没有修改门禁脚本。

按本次授权分段补验：保留已经完整完成的 343 文件／4347 项通过／1 项跳过；丢弃中断的 `thread_detail_page_test.dart` 部分计数 43，单独重跑该文件 84 项全部通过；其余 68 文件分成 9 个新 Flutter 进程，各以 `--no-pub --concurrency=1` 执行，分别通过 55、52、33、77、82、42、51、53、12 项，共 457 项。完整文件集合无缺失、无重复，去重通过数为 `4347 + 84 + 457 = 4888`。最后单独执行尚未运行的发布工具门禁 61 项通过。

[逐文件覆盖清单](preview-session-control-validation.json) 保留基线、原失败退出码、每段文件、结果及本地日志 SHA-256。原始日志保留于执行账户 `%TEMP%` 下的 `wenyou-mobile-preview-control-check.log`、`wenyou-mobile-preview-control-recover-detail.log`、`wenyou-mobile-preview-control-recover-1.log` 至 `-9.log` 和 `wenyou-mobile-preview-control-release-tests.log`。

联合检查发现初始浏览器端口被用户应用占用，最终统一使用 Web `14310`、API `14311`、媒体 `14312`。Mobile 没有硬编码端口限制，仅同步本任务新增的测试样本与文档。原全量／分段记录保留；最终端口的定向复验覆盖请求失活、旧 run 拒绝、持久化隔离及 v1 描述消费，日志为 `wenyou-mobile-preview-control-final-ports-dart.log` 和 `wenyou-mobile-preview-control-final-ports-node.log`。

## 行为回归与限制

- 临时登记根目录覆盖坏状态、孤立锁、进程复用、终态存活控制器、遗留 reverse、存活子进程及 status 归属变化；真实 loopback HTTP 验证 token、重定向拒绝与响应归属，真实 Windows 进程验证开始时间。CLI 从非 Git 目录、无 SDK PATH 运行，并拒绝另选临时空 registry。
- 实际 `dev:start` 对照：旧基线在已有过渡锁时继续读取故意缺失的 consumer，新入口在读取 consumer 前拒绝；没有启动设备发现、创建设备登记或执行安装。与治理锁实现分别占锁时，对方均拒绝进入；仅使用临时锁目录。
- 固定端口成功请求后切换到另一 run，旧 API／上传请求在到达业务 adapter 前拒绝；暂停时同样拒绝，恢复原 run 后才放行。相同账号和目标的 Drift 待确认操作、图片草稿在另一 run 不可见，恢复原 run 后保留。
- 治理从该 Worktree 调用只读列表成功；首次候选检查时本机登记为空。真实 Mobile 活动会话占用时的跨端切换拒绝及恢复仍待负责人联合验收。旧 start 工具不认识新锁，启用治理前必须同步经过审核的 Mobile 与治理工具。
- 本工具候选的检查未操作线上业务数据、未部署，其他任务的 Flutter／设备会话未停止或接管；首次候选交付时未合并，后续明确合并授权见上方记录。

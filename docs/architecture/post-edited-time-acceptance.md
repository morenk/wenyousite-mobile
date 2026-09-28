# 楼层编辑时间候选验收

状态：候选／待负责人验收。Backend 契约固定 `dc62a36dcf016f58fadcf53672215bb5fa66e618`、API `5.28.0-dev.20260929.1`；契约同步提交 `09a24f35`。Foundation 保持正式 `v7.2.1`，呈现补充说明为 `28808c7fa1f7b81f57f5022fa5ce64fcfcf8e931`（PR #26）。

## 已实现行为

主题详情主楼层、楼中楼预览及独立回复页有准确编辑时间时，仅显示“编辑于…”和最近成功编辑时间；没有该字段或值为 null 时保留发布时间。共用 `WenyouTimeText`，时间格式、本地时区及共享时钟保持；读屏提供“编辑时间”和该时间的完整日期。已编辑的主题详情作者行改用上下两行，避免新增前缀导致 320dp 截断；独立页保留编号与回复对象。

三个展示模型、四类 DTO、列表、深链、编辑回包与 `threadFloorAsPost` 保留 `editedAt`。不从 `updatedAt` 或版本号推算，不修改创建时间排序，也不扩展到主题信息、子贴正文、动态和个人摘要。保存失败不改变展示；成功继续由现有刷新流程读取服务端值。

## 自动验证和画面

- `test/core/network/post_edited_time_contract_test.dart`：四种生成 DTO 的缺字段、null、带时区时间戳与毫秒精度。
- `test/features/posts/post_edited_time_repository_test.dart`：真实生成客户端、Dio 和生产仓储覆盖三种字段状态，经楼层／内嵌／独立回复／详情／编辑回包／主楼及回复深链／展示模型转换传递。
- `test/features/posts/post_edited_time_widget_test.dart`：未编辑兼容、前缀与读屏语义、相对时间和 72 小时／未来／跨年边界；主题主楼与内嵌回复、独立页分别有明暗 320dp Golden。
- `test/features/posts/post_replies_page_test.dart` 中“编辑回复失败不覆盖原内容且保留编辑稿可重试”：失败维持无编辑记录，重试成功立即显示服务端编辑日期。
- 最终 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure` 已执行：OpenAPI、固定来源、再生成一致性、格式、应用和 SDK 分析、架构、21 个模块文档、Mobile API 覆盖 161/161 全部通过；Flutter 5019 项通过、1 项原有显式 Sentry 收据验收跳过，Windows 工具测试 67 项通过；ARM64 Debug 构建通过。
- 统一门禁聚合退出码为 **1**：唯一失败是公网只读契约检查在 VPS 不可达时超时，核验父进程归属后在 154 秒终止本任务该子进程，记录步骤退出码 -1。其余检查与构建由仓库已有 `-ContinueAfterFailure` 继续收集，不修改或放宽门禁。
- VPS 恢复后单独补跑 `npm run api:verify:production`，实际退出码 **1**：公网为 API `5.27.1-dev.20260928.1`、SHA `1bc4d3d3127a85f68118beb76c097643fc05ad6b`、Markdown 5；客户端支持 Markdown 3/4/5，但本任务固定来源为 `dc62a36dcf016f58fadcf53672215bb5fa66e618`／API `5.28.0-dev.20260929.1`，候选兼容后端尚未部署。这个明确版本差异不覆盖前一轮超时事实。

最终运行日志保存在本任务 Windows 目录 `D:\codex-worktrees\mobile-edited-time\check-apk-final.log`，补查日志为同目录 `production-check-recovered.log`，超时归属证据为 `production-check-final-timeout.txt`。没有将未通过的统一门禁或公网来源检查记为通过。

首次完整门禁发现作者行所在文件为 901 行、API 排除清单仍记录旧契约版本；当轮已停止，保留失败日志。随后按组件边界提取 `ThreadPostAuthorLine`，不提高文件长度白名单；审查确认 232 个 operationId 集合未变后仅更新覆盖清单版本，保持全部 71 项排除理由。架构与 API 覆盖复核通过（Mobile 范围 161/161），最终源码重新执行统一完整门禁。首次公网只读检查在 VPS 不可达时等待 139 秒无输出，经核对完整父进程链后只终止本任务该检查，退出码 -1；不将受控终止记成服务端返回的错误，也不影响并行其他任务。

Golden 位于 `test/features/posts/goldens/*edited_time*320.png`，使用确定性合成数据，属于实际 Widget 渲染证据。四张图已检查完整编辑日期、编号、回复对象和明暗窄屏布局。无 Android 设备连接，未启动或控制任何其他任务的 Debug 会话，未安装到其他设备。本轮前段 VPS 不可达，恢复后仍未取得可核验的共享 `consumer.json`，没有执行预览业务写入或回退线上。

## 本轮构建产物

- 路径：`D:\codex-worktrees\mobile-edited-time\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 生成时间：2026-09-29 05:43（北京时间）；大小：109441578 字节。
- 包名 `site.wenyou.app.debug`，版本 `0.8.0-debug`，构建号 `97`，仅 `arm64-v8a`；最低 API 26、目标 API 36。
- SHA-256：`FC7A4C168A0850DF7C6955ED7B9C527D1B28F6BBF3867FCA4959748A6D8A4F63`。
- 构建保留现有 KGP 插件与 Android SDK XML 警告，最终编译成功；没有升级依赖或修改原生配置。

APK 是本轮完整门禁在收集剩余检查时生成的产物，不能据此宣称统一门禁全绿或真机验收通过。

## 负责人验收清单

取得本任务核验过的隔离预览并连接空闲 ARM64 设备后，通过 `npm run dev:start -- --session <consumer.json>` 启动本目标 Debug；仍须记录 runId、设备、源码摘要与画面，不能用 Golden 代替。

统一门禁产出的普通 Debug APK 没有注入本任务隔离预览参数；构建成功只证明可编译，不作为隔离写入验收入口。真机写入验收须使用上述核验过的持续 Debug 会话。

1. 分别浏览未编辑／历史楼层、已编辑楼层、内嵌回复和独立回复，确认只出现对应时间，编号与回复对象保留。
2. 首次和连续编辑成功后立即看到最近编辑时间；重新进入及通过楼层／回复深链打开仍一致。
3. 无改动保存、取消、权限失败及版本冲突不凭空刷新时间；置顶、取消置顶和骰子结算不产生编辑记录。
4. 明暗主题及窄屏检查完整文案与 TalkBack 编辑语义；上线兼容后端前，旧后端缺字段继续显示发布时间。

只推进到候选 PR，未授权合并、部署、正式 Tag 或发布。

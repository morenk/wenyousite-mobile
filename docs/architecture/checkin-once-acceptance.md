# 自动签到成功提示单次显示候选

状态：候选／待负责人验收。日期：2026-09-20。

2026-09-20 负责人明确要求“合并清理分支”，授权执行 PR #46 合并及本任务分支、临时 Worktree 清理；候选包和日志已独立归档，清理不影响复验。该授权不作为原设备真机验收通过的证据，当前仍保留待验收状态。合并前在最终应用源码上执行 `npm run check -- -TestConcurrency 2`，真实退出码 0：4,610 项 Flutter 测试通过、1 项既有线上 Sentry 回执跳过，18 项 Windows 工具测试通过；格式、全量静态分析、架构、文档、API 覆盖、契约来源、公网兼容及再生成一致性全部通过。日志归档为扩展候选目录中的 `checkin-merge-gate.log`；此后只补充文档，不改变应用源码或 APK。

当前继续推进[一次性提示重复场景扩展](transient-feedback-repeat-audit.md)，新增首次可见同帧卸载/替换宿主、后台通知批次部分成功后重试重复的修复。下列原问题与完整门禁/APK 证据属于第一轮 `96e561f7`，保留用于追溯；新候选验证与包身份见本文末尾，不以第一轮完整门禁替代新源码验证。

## 原问题与复现

负责人反馈北京时间转点自动签到后，多次提示签到成功获得温油，并确认当时有切页面或其他操作提示。期望同一次签到只提示一次。具体设备、安装版本和当时逐次操作时间未取得，真机原场景仍待复验。

代码与既有测试证实：原提示必须完整显示 4 秒或主动关闭才消费回执；路由、模态、前后台或操作提示打断会关闭当前提示并保留回执，恢复后重新弹出。构造精确行为回归为北京时间 23:59:58 启动、次日 00:00:01 自动签到、提示可见后触发“已收藏”、等待提示消失。旧实现再次显示签到提示，断言失败；候选不再显示，同日签到请求数不增加。

## 候选行为与范围

- 仅在 Flutter `SnackBar.onVisible` 报告实际显示后消费回执，每个 ID 只确认一次；在帧后通知状态所有者，消费不截断当前 4 秒展示。
- 切页、弹窗、操作消息、切后台或同会话重新挂载均不重播已显示回执。首次显示前被遮挡或在后台收到领取结果则继续等待。
- 展示作用域绑定会话和北京时间日期；即便回执已消费，切号、退出或跨日也会撤掉旧提示。签到调度、请求合并、奖励领取、失败重试与存储不变。
- 基于 `origin/dev` 的 `cd348373`，先复用独立契约提交 `b24cfcbb`（本分支 `685b65e2`）。后端只读镜像已 fetch，公网 `/meta` 为 `e214fd18637cb10d79576c5ab5a4cf42340fef71` / `5.23.0-dev.20260913.1`；该版本 OpenAPI 与后端 `origin/dev` 无差异。固定行内组合与列表独立语料保持原来源。
- Foundation 仍锁定 v7.0.0，本次不修改视觉 Token、外观、文案、依赖或后端。

## 验证证据

- 旧实现运行 `flutter test test/app/app_session_bootstrap_test.dart --plain-name '跨零点签到提示被多次操作提示打断后不再补显'`：失败，预期无签到提示但实际发现一个。
- 候选运行 `flutter test test/app/app_session_bootstrap_test.dart`：20 项通过，包括真实根/分支路由遮挡、跨零点打断、恢复前台、组件重新挂载、切号、跨日与有限重试。
- 直接受影响范围：`test/core/widgets/wenyou_reliable_snack_bar_test.dart`、`test/core/widgets/wenyou_snack_bar_test.dart`、`test/core/widgets/wenyou_snack_bar_visual_test.dart`、`test/features/wallet/`。
- 提示与钱包专项运行 `flutter test --no-pub test/core/widgets/wenyou_reliable_snack_bar_test.dart test/core/widgets/wenyou_snack_bar_test.dart test/features/wallet`：29 项通过；随后新增的“首次显示前切后台”用例在完整门禁中通过。
- 本分支包含契约同步，按高风险流程执行 `npm run check:apk -- -TestConcurrency 2`，替代普通 `candidate:apk`：真实退出码 0。4,566 项 Flutter 测试通过、1 项既有线上 Sentry 回执跳过；18 项 Windows 工具测试通过。格式、应用与生成客户端分析、架构、模块文档、API 覆盖、契约来源、公网兼容及再生成一致性全部通过，同次 Debug APK 构建成功。
- 完整门禁覆盖整个 `test/`，包括上述直接受影响路径及提示 Golden；未修改或更新 Golden 基线。尚未安装设备、未执行负责人真机验收。

## 安装包与日志

- 应用源码提交：`96e561f7`；任务分支：`codex/20260920-checkin-once`。后续仅补充本验收记录，不改变已验证的应用、测试、依赖或生成客户端。
- 应用：温油站 Debug；`applicationId=site.wenyou.app.debug`；`versionName=0.7.1-debug`；`versionCode=95`；最低 API 26；开发 ABI 为 ARM32、ARM64、x86_64，已用 `aapt dump badging` 核对。
- 稳定归档：`D:\code\wenyousite\artifacts\mobile-checkin-once-20260920\wenyou-checkin-once-debug.apk`，183,302,862 字节。
- SHA-256：`6071d93196060d22a41831a2741339204b9e3d422b24e790401fcda475ada041`。
- 同目录保留 `checkin-old-regression.log`、`checkin-targeted.log`、`checkin-widgets.log`、`checkin-full-gate.log` 与 `SHA256SUMS.txt`。构建仅出现既有 `flutter_image_compress_common` KGP 未来兼容性警告。

## 负责人真机步骤

1. 安装本候选 Debug 包，确认打开 `site.wenyou.app.debug` 对应应用；正式版与 Debug 数据独立。若使用 ADB，安装前核对目标包，安装后核对更新时间及设备内 APK SHA-256。
2. 使用专用测试账号在北京时间零点前进入应用并保持前台。自动签到成功提示出现后，立即切页、打开/关闭弹窗或执行收藏等能出现操作提示的动作；签到提示不应再次出现，普通操作反馈正常。
3. 下一次实际领取提示出现时切后台后返回；已显示的提示不再弹出。首次领取结果在后台返回时，应在首次恢复可见后提示一次。
4. 钱包可查看当天签到与流水；同一天再次进入或恢复前台不重复提示，次日实际领取仍可提示一次。

未验证项：原设备转点操作、真机前后台与路由交互。自动测试与 APK 构建不能替代负责人明确验收。

## 扩展候选验证（待负责人验收）

- 新增缺陷复现：`checkin-same-frame-old.log` 在上一候选上确认首次可见同帧卸载后未收到消费回调；`checkin-related-expanded.log` 保留中间实现对真实宿主立即重挂载时出现 SnackBar 队首断言的失败证据。最终同帧宿主回归、渲染阶段延后回调及生命周期矩阵已通过，分别见 `checkin-lifecycle-expanded.log`、`checkin-render-phase.log`。
- 新增 31 个独立测试实例，并强化 4 个普通业务提示测试。覆盖普通/无障碍模式的 14 种打断组合、操作提示抢占、迟到回调、重复领取、并发检查、根/分支底部弹层、真实签到宿主与进程重入，另覆盖后台通知批次部分成功、内容变化、新周期及迟到成功，详细对应关系见排查矩阵。
- 后端公网契约复核仍为 `e214fd18` / `5.23.0-dev.20260913.1`，本轮不改契约或依赖，运行时变更限定于签到提示消费和后台提醒展示确认。架构及 21 个模块文档检查通过。
- `checkin-partial-notifications-old.log` 确认旧后台提醒协调器会在第二条失败后的重试中再次显示第一条，候选只重试未确认项；`checkin-partial-notifications-final.log` 验证内容变化、新后台周期和迟到成功仍安全。
- 已整合 `origin/dev` 的 `1c46ef44`。最终通过 `npm run candidate:apk -- <排查矩阵列出的全部测试路径> -TestConcurrency 2`（真实退出码 0）：全仓 1,033 个 Dart 文件格式检查无变化，应用及生成客户端全量静态分析零问题，211 项相关测试通过、1 项既有线上 Sentry 回执跳过，同次 Debug APK 构建成功。精确命令及输出保存在 `checkin-expanded-candidate.log`，未更新 Golden 基线。负责人随后明确授权合并清理，合并前完整门禁结果见本文顶部。

### 扩展候选安装包与复验

- 应用源码及测试提交：`0e86821a1cf5e4ee479337870475783567bb9c59`；后续仅补充本提交身份记录，不改变已验证源码或 APK。任务分支 `codex/20260920-checkin-once`，Draft PR #46。
- 应用为“温油站 Debug”，`applicationId=site.wenyou.app.debug`，`versionName=0.7.1-debug`，`versionCode=95`，最低 API 26，ARM32、ARM64、x86_64；已用 `aapt dump badging` 核对。与第一轮版本号相同，必须用下列哈希区分候选。
- 归档：`D:\code\wenyousite\artifacts\mobile-checkin-once-expanded-20260920\wenyou-checkin-once-expanded-debug.apk`，223,508,494 字节。
- SHA-256：`097fc39055fd9202e434a7cd1a93ea083b615d9dc26ecd7041784651b2895012`。
- 同目录保存本轮最终候选日志、架构检查日志、同帧卸载与后台通知旧实现失败/候选通过日志、真实宿主中间失败日志及 `SHA256SUMS.txt`。构建仅出现既有 `flutter_image_compress_common` KGP 未来兼容性警告。
- 使用本扩展候选执行前述四步原场景复验，再覆盖快速打开/关闭根与分支弹层、连续前后台、滑动关闭提示、大字号/减少动画。关注、收藏、订阅、草稿提示消失后切页返回不得重播；再次主动操作仍须正常反馈。后台提醒实际系统展示与异常时序仍待设备验收，部分批次平台失败的可控复现以自动测试为证据。
- 尚未安装设备或执行负责人验收；不以构建成功、自动回归或未回复替代验收，不自动合并或发布。

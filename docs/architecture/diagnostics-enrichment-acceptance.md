# 自动诊断补全候选验收

## 范围与原始证据

2026-09-19 负责人要求补齐自动诊断的堆栈和定位上下文，暂不增加主动提交样本。正文、Delta、私信、账号、密码、Token、验证码、图片/预签名 URL 不采集。

Sentry 抽查 build 95 / 0.7.1 的 MOBILE-3、7、9、1、4、5、8、C 最新事件，诊断字段 stack 均为空。原始异常栈及触发内容不可恢复，不能认定所有历史业务故障具有同一根因，也不关闭这些 Issue。

本机 Dart 3.12.2 通过 `dart compile exe` 运行独立无隐私探针，确认 AOT 堆栈存在只含行号、不含列号的帧。原过滤器强制要求列号且只接收三个包，确实不能保留此类坐标；Windows AOT 证据不能代替 Android 正式包和 Sentry 收件验收。

## 验收边界

- 兼容 JIT 行列、AOT 行号及第三方包源码坐标；不采集任意异常 message、函数显示文本或机器绝对路径。
- 堆栈为空时明确区分未提供、过滤丢弃与不支持的符号格式；不以采集器当前栈伪装异常栈。
- 增加安全错误原因、请求类型/耗时、页面名称、生命周期与运行环境；相同类型不同故障位置不能无差别合并。
- 数据在采集、落盘、恢复、导出和 SDK 信封边界执行白名单过滤；保留关闭/清除/切号与失败重发语义。
- 不引入原生崩溃、ANR、OOM 自动采集，不开启录屏、截图、正文或用户身份采集。

## 当前状态

候选修复／待负责人验收。完整门禁与 Debug 构建已通过；尚未取得 Android 原场景与新 Sentry 事件的负责人验收，不关闭历史业务故障。

## 已取得的本地证据

- 基线：`origin/dev` 的 `afc11c8749bce79f6b15195df41f214909296951`；独立契约同步提交 `b24cfcbb` 固定已部署 API 5.23 / e214fd18，OpenAPI 验证、客户端生成、来源、154/154 业务覆盖、模块文档和公网核验通过。
- 旧实现运行 `test/core/diagnostics/diagnostic_stack_regression_test.dart`：3 项均按断言失败（无列号/第三方帧丢失、Sentry 无坐标、不同位置错误同组）。相同测试在候选实现通过。日志 `build/diagnostic-evidence/stack-before.log`。
- `flutter test test/core/diagnostics test/app/app_router_test.dart --reporter expanded --concurrency=2`：46 项通过、1 项既有真实收件测试按显式开关跳过。目录内包含 `diagnostic_stack_regression_test.dart`、`diagnostic_enrichment_test.dart`、`diagnostic_sentry_sender_test.dart`、`diagnostic_bootstrap_test.dart`、`failure_diagnostics_test.dart`、`debug_diagnostic_console_test.dart`、`debug_render_geometry_test.dart`；路由名称跟踪、清除监听和参数不泄漏也已验证。日志 `build/diagnostic-evidence/diagnostics-final.log`。
- 本机重新编译独立 Windows AOT 探针并调用候选过滤器，实际无列号的 Dart runtime 帧得以保留，输出 `AOT_LINE_ONLY_CAPTURE_OK`。为避免探针成为产品源码，探针原文以 `.dart.txt` 随本地证据保留；日志 `build/diagnostic-evidence/aot-after.log`。
- 初轮全量分析发现导入顺序、工具条件分支花括号及未移出的临时探针 lint，均已整理后才进入最终门禁；未关闭 lint。
- 最终 `npm run check:apk -- -TestConcurrency 2` 成功退出：格式、应用和生成客户端全量分析、架构、模块文档、API 覆盖、契约来源/再生成一致性及公网精确 revision 均通过；全量 Flutter 测试 4,532 项通过、1 项显式真实收件测试跳过，Windows 发布工具测试 18 项通过，Debug APK 构建通过。完整日志 `build/diagnostic-evidence/full-check-apk-resume.log`。后续仅完善文档，不重复同一应用源码的门禁。

## 负责人真机与 Sentry 复验

1. 安装候选后打开 Debug 应用（`site.wenyou.app.debug`），不要误开正式应用 `site.wenyou.app`；本任务未自行操作或安装负责人设备。
2. 以专用测试账号重现原编辑/界面错误，或在自然复发后从“故障诊断”复制问题编号。确认记录有固定页面名称、构建模式、系统版本/API 和厂商机型；错误若有常规源码栈，`stackStatus` 应为 captured，文件和行号可与候选源码对照。业务故障是否修复由其原任务独立验收。
3. 用问题编号在 Sentry 找到新事件，核对 `diagnostic_schema=2`、`buildMode=debug`、相同 event ID、源码调用链与诊断码。旧 build 95 的历史空栈不属于新候选收件。普通 Debug 默认不上报；交付包的启用配置以 APK 记录为准。
4. 在专用测试草稿执行可控网络失败，检查请求 operationId、Dio 类型、耗时和超时阈值，正文仍保留且不自动重发业务请求；普通读取断网仍不产生远程 Issue。必要时用 request_id 对照后端日志，不能仅凭无返回判定未写入。
5. 关闭自动发送后再触发一次可控错误，只生成本机记录；清除记录或退出账号后不恢复旧队列。检查复制内容及 Sentry 事件没有正文、Delta、身份、Token、查询参数和完整链接。

以上负责人结果尚未取得；不把自动测试、APK 构建或 SDK 模拟信封验证当作 Android 真机收件通过。

## 执行环境暂停记录

首轮完整门禁在全量测试约 8 分钟后经历长时间执行暂停；恢复时计时跳至约 901 分钟，`moment_animation_test.dart` 首个在途用例报告 10 分钟超时，随后四个用例出现 pump 异步冲突。此前静态分析、契约、架构、文档和 API 检查通过，但该整轮不记为通过。仅终止经命令行核验属于本任务的门禁进程树，保留 `full-check-apk.log`，无修改应用源码或放宽测试阈值。恢复后 `flutter test test/features/moments/moment_animation_test.dart --concurrency=1` 的 8 项全部通过，随后重新执行完整门禁和 APK 构建成功；日志分别为 `moment-animation-resume.log` 与 `full-check-apk-resume.log`。

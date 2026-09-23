# Android 全构建 ARM64 验证

日期：2026-09-20；验收日期：2026-09-23。状态：负责人验收通过，已授权合并与任务清理。

## 负责人验收与合并

2026-09-23，负责人对本任务候选 `ebe7a99958c9681cc177a8f9b2ef1ff9d10a1d28` 明确反馈“已经验收了”，授权 PR #49 合并至 `dev` 并清理分支、临时工作区，同时明确跳过重复全量测试。

合并前整合 `origin/dev` 的 `536bc306`，仅契约来源记录与文档发生冲突；保留 dev 当前契约和生成客户端、保留 ARM64 构建改动。既有 APK 与完整门禁证据仍绑定原候选，不将其记为整合最新 dev 后重新构建或复测。本次执行文档、冲突标记和差异检查，不重复全量测试或 APK 构建。

删除临时工作区前，将两个 APK、验证日志及构建顶层记录归档至 `D:\code\wenyousite\artifacts\mobile-arm64-20260923`，两个 APK 的 SHA-256 与下列候选记录一致。下文 `build/` 日志的归档文件名保持不变。

## 目标与范围

根据负责人要求，Debug/Profile 不再保留 ARM32、ARM64、x86_64 多架构开发包；Debug、Profile、Release 统一只打包 `arm64-v8a`。Gradle 公共配置负责过滤所有原生库，保留关闭 Flutter 自动 ABI 过滤的设置；Debug 构建入口显式指定 `android-arm64`。不改变三个构建类型的包名、签名规则、版本号及单 APK 分发方式。

本次不涉及 Foundation 实现与依赖升级。后端前置同步至 `4b133355c14198506e4a4380fd741cccd19d844d`，API 仍为 `5.23.0-dev.20260913.1`；OpenAPI 与重新生成客户端无行为变化。

## 自动验证

按 Android 原生配置变更执行 `npm run check:apk -- -TestConcurrency 2`，完整门禁通过：格式、应用与生成客户端静态分析、架构、21 个模块文档、API 覆盖、OpenAPI 校验、客户端重新生成无差异、公网精确 revision 与 Markdown 兼容检查全部通过；`flutter test --concurrency=2` 覆盖全部 `test/`，4,626 项通过，1 项显式 Sentry 收件验收因未启用而跳过。18 项 Windows 工具测试通过；`tool/windows/debug_candidate.test.mjs` 与 `tool/windows/quality_gate.test.mjs` 的现有测试同时断言构建参数为 `--target-platform android-arm64`。同次 Debug APK 构建成功。

首次门禁在模块文档检查处因 19 个模块缺少新后端 revision 停止；补齐契约审查记录后重新运行完整入口并通过。原始失败日志保留为 `build/all-builds-arm64-check-attempt1.log`，成功日志为 `build/all-builds-arm64-check.log`。

Debug 制品：

- 归档路径：`D:\code\wenyousite\artifacts\mobile-arm64-20260923\app-debug.apk`。
- 包名 `site.wenyou.app.debug`，应用名“温油站 Debug”，versionName `0.7.1-debug`，versionCode `95`，最低 API 26。
- 大小：108,904,104 字节；SHA-256：`79E41BF140E843BDFAA6F76B5175119E63741DB55238568CF5E8414C7686469D`。
- `aapt dump badging` 确认仅 `arm64-v8a`；遍历 ZIP 中所有 `lib/` 原生库确认全部为非空 ARM64 库且包含 `libflutter.so`；`apksigner verify --verbose` 确认 v2 签名有效。

Profile 使用 `flutter build apk --profile --target-platform android-arm64` 构建成功，日志为 `build/all-builds-arm64-profile.log`：

- 归档路径：`D:\code\wenyousite\artifacts\mobile-arm64-20260923\app-profile.apk`。
- 包名 `site.wenyou.app.profile`，应用名“温油站 Profile”，versionName `0.7.1-profile`，versionCode `95`，最低 API 26。
- 大小：49,658,314 字节；SHA-256：`13528A7454926F1741942F7F827068C250BBFA4D2C5A7E64437F28C55C8563BC`。
- `aapt dump badging` 与 ZIP 原生库逐项检查均确认仅 ARM64，包含非空 `libflutter.so` 和 `libapp.so`；`apksigner verify --verbose` 确认 v2 签名有效。

构建日志保留现有 `flutter_image_compress_common` 的 Kotlin 插件迁移提示，Profile 另有 CupertinoIcons 字体提示；构建均成功。本次未修改这些依赖，未构建或发布正式 Release APK。

## 真机检查

负责人已于 2026-09-23 明确验收通过；本任务未直接安装或操作负责人设备。以下保留原候选的手测清单，不将自动验证替代人工验收。

1. 在 ARM64 设备安装 Debug 候选，核对包名为 `site.wenyou.app.debug`，打开“温油站 Debug”，确认冷启动、首页和正文阅读正常。
2. 在负责人已有 Debug 会话中检查热重载、热重启可用。
3. 安装 Profile 候选，核对包名为 `site.wenyou.app.profile`，打开“温油站 Profile”，确认启动、页面切换和正文阅读正常。
4. 安装前后按仓库规则核对目标包名、更新时间及设备内 APK 的 SHA-256；原有验收记录中的多架构 APK 保持其历史事实。

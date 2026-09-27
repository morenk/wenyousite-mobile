# Windows CI 的 Dart UTF-8 编码复核

当前状态：2026-09-28 负责人明确要求不再使用 GitHub CI，以 Windows 本地门禁为准。Quality 与 Android Debug 两个远端工作流已实际设置为 `disabled_manually`，本仓移除工作流及仅供临时 runner 使用的 UTF-8 helper／探针和对应 CI 测试；本地完整门禁脚本与其失败语义测试保留。下文均为历史排查和旧源码检查证据，不再是开发、合并或发布前置条件；其他仓库 CI 未调整。

## 问题与已证实原因

2026-09-28 正式 Android `0.8.0+97` 发布准备中，两次 Windows 只读 CI 未完成：

- [Android run 36331894587](https://github.com/morenk/wenyousite-mobile/actions/runs/36331894587) 在 `flutter pub get` 失败：Foundation `v7.2.1` 的 `pubspec.yaml` 第 2 行第 43 列出现 `Unexpected character`。文件本身是有效 UTF-8；中文 description 被按 Windows ACP1252 解码为乱码，其中包含 YAML 不接受的字符。
- [Quality run 36331891756](https://github.com/morenk/wenyousite-mobile/actions/runs/36331891756) 在 Flutter SDK 准备阶段耗尽原 30 分钟限时，尚未进入 Install tooling。Android 同批 SDK 下载记录为 1.77GB、18 分 38 秒，镜像路径平均约 1.62MB/s。

当前 Dart `3.12.2` 的 [DEPS](https://github.com/dart-lang/sdk/blob/3.12.2/DEPS) 固定 Pub `74408212b5348003381bc63f3b59274aaa23cfa3`；该版 [Git 源读取](https://github.com/dart-lang/pub/blob/74408212b5348003381bc63f3b59274aaa23cfa3/lib/src/source/git.dart) 使用 `git show`，其 [进程 stdout 解码](https://github.com/dart-lang/pub/blob/74408212b5348003381bc63f3b59274aaa23cfa3/lib/src/git.dart) 默认为 `systemEncoding`。Dart Windows 的 [转换实现](https://github.com/dart-lang/sdk/blob/3.12.2/runtime/bin/utils_win.cc) 使用 `CP_ACP`。只设置控制台 `chcp 65001` 或 PowerShell 输出编码不能改变这个进程级事实。

## 修改范围

两个工作流仍使用 `windows-latest`、`contents: read`，质量门禁仍为 `npm run check`，Debug 仍只构建单 ARM64 APK，不上传、签名或部署。根据仓库正式发布准备规则，恢复 `dev`、`main` 的 push 与面向这两个分支的 pull_request 自动触发，保留 workflow_dispatch；不监听 Tag 发布。

仅 Flutter SDK 下载切换至 `https://storage.googleapis.com`，限时由 30 分钟改为 60 分钟。`PUB_HOSTED_URL` 保持 `https://pub.flutter-io.cn`：应用及生成包锁文件都固定这个 hosted 来源，不能为 CI 环境修正引入锁文件变化。

`tool/ci/Set-WindowsDartUtf8.ps1` 在依赖解析前对 runner 工具缓存中的以下三个 Dart 工具，按 Microsoft [进程 UTF-8 设置](https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page) 使用 `mt.exe` 提取原 manifest，并仅设置 `activeCodePage=UTF-8`：

- `bin/cache/dart-sdk/bin/dart.exe`
- `bin/cache/dart-sdk/bin/dartvm.exe`
- `bin/cache/dart-sdk/bin/dartaotruntime.exe`

保留原 `trustInfo`、执行权限、兼容声明及其他设置；不更改 Dart SDK 源码、snapshot、可执行代码段或机器区域设置。脚本只允许 GitHub Windows CI，且 SDK 必须位于 `RUNNER_TOOL_CACHE` 内；遇到已签名或不能判定为未签名的工具即拒绝修改。每个工具记录整体前后 SHA-256，并验证代码段摘要不变；原／新 manifest 保存在 `RUNNER_TEMP/wenyou-dart-utf8`。随后实际运行 Dart UTF-8 断言，任何失败终止工作流。

## 本地验证证据

验证全部在 Windows 的本任务 `build/ci-encoding-repro` 临时副本执行，未修改 `D:\sdk\flutter` 原件。生产 XML 转换函数参与以下检查；本机没有 Windows SDK `mt.exe`，因此本地副本嵌入使用 Win32 resource API，保留原资源语言及其他资源。不能将该验证表述为已完成远端 `mt.exe` 集成验证。

1. 同一个真实 Foundation `v7.2.1:packages/flutter/pubspec.yaml`：复制 AOT runtime 在 ACP1252 下默认 Git 解码不等于原 UTF-8；ACP65001 下 365 个字符逐字匹配。原 `trustInfo` 与可执行代码段不变。
2. 复制 `dart.exe`、`dartvm.exe`、`dartaotruntime.exe` 和实际 DartDev snapshot，分别设定 en-US 与 UTF-8；在独立临时 pubspec 上执行真实 `dart pub get --offline`，依赖使用原 Foundation Git URL、`v7.2.1` 和 `packages/flutter` 路径。ACP1252 精确复现第 2 行第 43 列错误，退出 65、未生成 package_config；UTF-8 退出 0，生成 package_config 并成功解析 Foundation 7.2.1 及其 25 项依赖。这里使用既有包缓存，未覆盖冷缓存网络下载。
3. `node --test tool/windows/quality_gate.test.mjs`：工作流触发与只读边界、XML 既有字段保留及幂等、缺少设置时正确创建、拒绝本机／缓存外 SDK、原门禁失败聚合与构建控制。最终共 4 项通过。
4. `dart analyze tool/ci/check_windows_utf8.dart` 零问题，格式检查通过；该检查的 AOT 在 UTF-8 副本运行通过。原本机未修改 runtime 不能通过 UTF-8 断言，按预期保留，不为让断言通过修改本机 SDK。
5. 两份 YAML 由 Dart yaml 解析并核对自动触发分支、Windows、只读权限、下载源、时限及编码配置位于 pub get 之前；应用源码与已验收 APK 的摘要重新核对。

证据目录：`D:\code\wenyousite\artifacts\mobile-release-notes-20260927\formal-0.8.0-97\ci-utf8`。包括 `build-ci-encoding-production-repro.log`、`build-ci-real-pub-get.log`、`build-ci-tool-tests.log`、`build-ci-workflow-validation.log`、验证脚本、三个工具 manifest 前后文件及 SHA-256 记录。

## 发布与剩余边界

提交 `84ee1952c6167e8cd61c54ba783822e7580fe153` 的两个自动 PR run 均已通过真实 `mt.exe` 配置与完整 `flutter pub get`。[Android 36335347895](https://github.com/morenk/wenyousite-mobile/actions/runs/36335347895) 成功，ARM64 Debug 的 Gradle 构建用时 640.1 秒；[Quality 36335347781](https://github.com/morenk/wenyousite-mobile/actions/runs/36335347781) 在全量 Flutter 测试失败：4989 通过、2 失败、1 跳过，仅钱包明暗两张 Golden 各有 214px / 0.07% 差异。此前契约、再生成、严格公网、格式、双静态分析、架构、文档和 API 覆盖均已通过；后续 Windows 工具测试未执行，不能算远端通过。两份完整日志、状态与 SHA-256 保存在上述 `ci-utf8` 目录，原失败记录不覆盖。

应用提交保持 `2c0710c0b96fe6ad7537465c5d520afad5854269`，源码摘要 `f69e88ccf6805649b408f7bee7c1d356fe5fe89c4516759b877e5143cd21c92c`。已通过完整本机门禁、签名并在设备安装验收的正式 APK SHA-256 保持 `b3ebe7b5d0a0bd7d7c64963e59967e83ab3485813479bc6583b7191b5e63f245`。本次不重建、不替换已测制品，具体负责人验收及未覆盖项见 [0.8.0 发布记录](mobile-0.8.0-release-acceptance.md)。

## 钱包 Golden 的时区对照与候选修正

后续仅处理上述两个截图失败。原夹具使用 UTC `2026-08-10 01:02`、`02:03`、`03:04`，页面通过 Foundation `formatWenyouExactTime` 转本地；已提交基线来自 UTC+8，显示 `09:02`、`10:03`、`11:04`。起初仅将时区差异列为假设，没有据此改图或放宽比较。

受控对照只给子进程设置 Windows CRT 支持的 `TZ=UTC` 或 `TZ=CST-8`，不修改用户 Windows 全局时区。探针确认同一 UTC 输入分别变为 `01:02` 与 `09:02`；每轮结束核对全局仍为 `China Standard Time`。原测试在 UTC 子进程下两项都精确复现 `214px / 0.07%` 失败，在 CST-8 下两项通过。实际查看明暗失败图及隔离差异图，差异仅为三行小时数字；此对照证实截图夹具依赖运行环境时区。

候选只改 `test/features/wallet/wallet_page_test.dart`：截图注入明确的本地 `DateTime`，固定呈现原基线的 `09:02`、`10:03`、`11:04`，并逐项断言文案。普通 UTC 业务夹具继续保留；新增页面级 UTC→本地时分断言，配合既有共享时间测试独立验证业务语义。不改应用、Foundation、依赖、全局时区、CI 时区、Golden 文件或比较容差。

直接验证文件为 `test/features/wallet/wallet_page_test.dart` 与 `test/core/widgets/wenyou_time_text_test.dart`，UTC 和 CST-8 子进程分别 21 项通过。为保存修后实图，在被忽略的 `build/` 临时副本加只读比较包装器：将比较器收到的实际 PNG 另存制品目录后，仍委托原比较器严格比较原基线，并禁止 update；UTC 下两张截图比较通过。明暗修后实图已查看，保留原版式，显示预期本地时间。

两张修后实际 PNG 的 SHA-256 均与对应已提交基线相同。全量 `flutter analyze --no-pub --fatal-infos --fatal-warnings` 零问题（34.5 秒），格式与 21 模块文档检查通过。首次分析曾扫到诊断时放在 `build/` 的零散上游源码和临时脚本；该失败日志保留，将这些诊断文件迁出仓库到证据目录后按原规则复跑通过，未禁用分析规则或排除应用文件。

证据目录为同一正式制品目录下的 `ci-wallet-goldens`：原 UTC 失败日志与 8 张反馈图、原 CST-8 通过记录、两种进程时区的候选 21 项记录、截图捕获脚本和日志、修后明暗实图、基线及制品摘要。

2026-09-28 旧应用源码最终远端复核：提交 `2415d20c41db6fa33ce4b33bb4f8679ec3127cd1` 的 [Quality 36340692464](https://github.com/morenk/wenyousite-mobile/actions/runs/36340692464) 成功，Flutter 4992 项通过、1 项显式联网诊断跳过，Windows 工具 70 项通过、0 失败；[Android 36340692441](https://github.com/morenk/wenyousite-mobile/actions/runs/36340692441) 成功，Gradle 构建 507.2 秒。完整日志为该目录的 `quality-36340692464-full.log`、`android-36340692441-full.log`。编码与钱包截图前置阻塞消除，但负责人随后确认正式 97 包的安装版空说明重复弹窗；发布已冻结，以上只能代表旧应用源码，不替代[新弹窗候选](mobile-update-once-dialogs-acceptance.md)的门禁和负责人复验。

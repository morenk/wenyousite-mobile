# 2026-09-20 已部署契约来源复核

设置精简切片开始时，主契约登记为 Backend `e214fd18637cb10d79576c5ab5a4cf42340fef71`，远端 `origin/dev` 与公网 `/api/v1/meta` 已为 `4b133355c14198506e4a4380fd741cccd19d844d`。API 均为 `5.23.0-dev.20260913.1`。

在 Windows 主工作区用既有同步脚本完整导出已提交来源，并执行 `npm ci`、`npm run api:validate`、`npm run api:generate`。本次只改变主来源 SHA、契约 CHANGELOG 和客户端指南；OpenAPI、生成 SDK 和锁文件无差异，现有 fixture 不变。行内组合 fixture/schema 与已独立固定的 `f3cad6799d7fdd6b484d7341b3b918970767a190` 完全一致；保留该来源登记及 editor-list 的既有独立来源，不重标语料。

影响：没有接口、模型或业务行为迁移，不新增网络或存储行为。后续设置文案切片依赖本次来源同步，并对最终应用源码执行完整门禁与 Debug APK 构建，结果由该切片记录。

同步和生成日志：`D:/code/wenyousite/artifacts/settings-subtitles-contract-sync.log`。

首次生成在既有 `build_runner` AOT 缓存处停滞，停止了经父进程和命令路径核实属于本任务的三个生成进程。随后通过生成器自带的 `dart run build_runner clean` 重建派生缓存，再运行 `dart run build_runner build --verbose` 和根目录 `flutter pub get`，生成成功且 SDK diff 为空。恢复日志为同目录 `settings-subtitles-generator-recovery.log`；没有手改生成文件或跳过生成一致性检查。

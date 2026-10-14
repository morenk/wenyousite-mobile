# Android 存储桶直连候选

状态：候选／待负责人验收。本轮固定 Backend `882889c5d8dc4a47893cb4fe913a0f68e536ce2f`、OpenAPI `5.37.0-dev.20261015.1`，来源为 [Backend PR #50](https://github.com/morenk/wenyousite-backend/pull/50)，尚未合并或上线。

## 行为与兼容边界

Windows 发布工具恢复 RainS3 原对象地址，`publicUrl` 与 `legacyUpdateUrl` 相同。构建前、晋级前仍分别读取 `confirmedRevision`；预检与最终受限晋级都移除 `--gateway`，最终命令保留 `--notes-revision`、版本、构建、大小和 SHA-256。任何预检、制品身份、说明 revision 或晋级失败都停止，不自动回退网关或执行恢复。

上传继续使用原专用桶、鉴权校验和不可覆盖对象；公开对象可用性由 Backend 的受限直连晋级复核。`UploadOnly` 只完成上传，不宣称推荐策略已变化。Windows 不传上传凭据到 SSH，不操作 Backend 内部 CLI、服务或审计。

App 下载运行时无需修改：继续读取 `/meta.mobileCompatibility.android.updateUrl`，执行无 Cookie 的 HEAD、流式 GET、SHA-256 与原生包身份校验；可同时兼容既有桶 URL 与历史网关 URL。新 `mobileReleasesAndroidDownload` 仅供 Web 下载页，SDK 保留生成方法，Mobile 在 API 覆盖排除清单说明不增加信息接口前置请求。

官方同步脚本增加逐字导出 `contracts/android-direct-download.md`；既有列表和行内组合语料继续保留各自固定来源。生成 SDK 使用固定 OpenAPI Generator `7.23.0`、规范化脚本和 build_runner，没有手改生成文件。

## 定向验证

- 新发布工具回归对旧实现得到 23 通过、6 失败，失败点为网关 URL 和 `--gateway` 编排；改动后同组 29 项通过。
- `node --test --test-concurrency=1 tool/upload_android_release.test.mjs tool/windows/release_notes.test.mjs`：29 项通过，全部使用本机 mock、虚构凭据和临时目录，不调用真实 SSH、构建、上传或晋级。
- `node --test tool/windows/contract_revision.test.mjs`：1 项通过，验证固定 revision、逐字契约导出、保留独立固定语料和拒绝非祖先来源；只使用本机临时 Git fixture。
- `flutter test --no-pub test/features/app_shell/app_download_contract_test.dart test/features/app_shell/mobile_update_service_test.dart test/features/app_shell/mobile_update_http_test.dart`：58 项通过；覆盖新信息接口三种状态和匿名解码、原桶／旧网关 URL 的无 Cookie HEAD→GET、SHA-256／元数据校验、失败不重试／不回退／不安装和临时文件清理。
- SDK 生成最初遇到 Windows `.gitignore` 短暂文件映射锁；从规范化步骤继续后，诊断路由与 build_runner 均成功，生成差异仅涉及新方法、响应模型、serializer、路由及下载地址说明。`4935df91` 与最终 `882889c5` 的 OpenAPI 完全一致，因此最终来源同步后无需重复生成。
- Bash 与 Node 语法检查、变更测试文件格式检查、`dart analyze test/features/app_shell/app_download_contract_test.dart` 及 `git diff --check` 通过；未执行全仓检查。

按负责人本轮要求，未运行全量测试、全仓静态分析、统一门禁或 APK 构建；未签名、安装、上传、晋级、合并或部署。mock 通过不代表真实桶、线上切换或真机验收通过。

## 合并后的操作

先合并兼容 Backend 并由管理入口部署，再按 [存储桶直连契约](../../contracts/android-direct-download.md) 的原受限入口执行同构建或新构建晋级，核对实际 `/meta`、新信息接口、公开 HEAD、sidecar 和版本说明；Web 按对应依赖顺序切换。App 下次读取策略即使用桶直连，不强制发布新 APK。

恢复直连后，下载流量、缓存和服务限制由存储桶承担；原网关限速／计次不再作用于桶请求。公开 URL 无法召回已下载或缓存的安装包。旧网关端点、`--gateway`、账本和审计保留；兼容清理需要独立证据与 PR。上述实际切换不在本轮执行范围内。

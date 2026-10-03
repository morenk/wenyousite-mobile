# 私有 APK 下载契约同步

当前消费者来源固定到已合并并部署的 Backend `3748cc8c85a73f400fa4e237a8d7dd6eecd1853e`／`5.32.0-dev.20261003.1`，共 238 个操作；Mobile API 范围仍为 164/164。2026-10-04 公网来源及主题列表兼容检查通过。以下保留分阶段同步依据，不把早期状态当作当前产品事实。

## 合并后来源与公网验证（2026-10-04）

通过 `tool/sync_backend_contract.ps1 -BackendPath <只读镜像> -Branch dev -Revision 3748cc8c85a73f400fa4e237a8d7dd6eecd1853e` 完整导出；33 个文件与已消费的 `10b7819a` 一致，独立固定的列表／行内组合语料继续使用各自来源，OpenAPI 保留两处既有重复参数规范化。受限发布 CLI 逐字一致；源提交后的改动只涉及 Backend 依赖和测试执行身份／临时进程隔离。

同步结果只有 `backend-contract.properties` 的 revision 一行变化；OpenAPI、SDK、应用／测试、依赖和 Android 配置均未变，不重复生成、全量测试或构建。保留应用源码 `828128ce` 已通过的本地检查和 Debug APK 证据。治理确认标准部署退出 0 后，Mobile 执行 `npm run api:verify:production` 退出 0：公网 `/meta` 的版本与 SHA 精确匹配，Markdown 5 在支持范围内，`GET /threads` Schema 兼容；原历史失败日志保留，见[验收记录](private-apk-download-acceptance.md)。原正式推荐包 97 不在本次发布或替换，正式包预热、网关策略切换和旧 APP 安装尚未验收。

## 每日下载次数兼容契约（2026-10-03）

新增 429 响应头 `X-Download-Limit-Reason` 的六种原因及可选 `Set-Cookie`，不新增或删除路径、operationId、DTO。默认有效浏览器标识每天 3 次、IP 总计每天 10 次，跨构建累计，北京时间零点重置；次数耗尽的 `Retry-After` 为到次日的秒数。合法 GET 在发送前原子预占次数与字节，Range 也计次，预占后中断不退；HEAD/info 不计次数，HEAD 成功不保证后续 GET 获准。info 保持全局发布状态，不被访客次数耗尽污染。

原生 APP 继续无 Cookie 的 HEAD→GET，不增加 info 前置请求、不自行生成设备标识；无有效 Cookie 时仍受 IP 总限额。HTTP 状态、原因头和 Retry-After 可独立读取，不能假设 HEAD 或 GET 429 存在 JSON 正文。未知／缺失原因兼容通用提示，已经验证的本地包可以继续安装，文件与签名校验保留。浏览器 Cookie 不是硬件身份，后台次数持久化及零点原子重置由 Backend 验证，Mobile 不以本机 fixture 冒充该证据。

本 chore 仅同步契约及生成说明，消费者提示随后独立提交；发布工具 CLI 无差异，不重复改造或执行正式发布。兼容保留及回滚边界见[弃用登记](../deprecation-register.md)。公网仍为 `5.30.0-dev.20261001.1 / 2b803a8e4bc73bc01bd046142e6f9005f92aa411`，不改写来源或放宽门禁。

## 首轮下载契约与完整来源同步

2026-10-03 从 Backend 已提交分支 `codex/20261002-download-gateway` 同步 `c7060867fc938e002a14bff596886aea83279b1c`，OpenAPI `5.30.0-dev.20261002.2`。首契约为 `3bd4633e1f647783030eb3db872442c8a64d6f07`；后续修正将 HEAD 显式声明在 GET 前并固定匿名认证语义。

同步使用 `tool/sync_backend_contract.ps1 -BackendPath <只读镜像> -Branch codex/20261002-download-gateway -Revision <完整 SHA>`，新增逐字导出的 `contracts/app-download-gateway.md`。SDK 仅通过固定 OpenAPI Generator `7.23.0`、规范化脚本及 build_runner 生成，不手改生成物。

新增匿名下载信息及固定构建 GET/HEAD，保留旧 `/meta` 字段。文件不是 JSON API：Mobile 保持独立下载 Dio 的 HEAD 与流式 GET，避免 SDK 整包缓冲；下载 JSON 属于 Web 公开页面，不替代 Mobile 的推荐／强制策略。因此 API 审计对三个新 operationId 明确登记消费者边界。文件 metadata 继续校验包名、版本、构建、长度和 SHA-256，原生签名校验保持；文件网关的 `private, no-store` 与存储源对象的 immutable 缓存策略分开。

Foundation 文档／25 个共享场景固定于 `6c3776dd7c2de1aacafe0f6403fbb3ea98c5fb0d`（PR #30），语义来源为 `docs/app-downloads.md` 与 `tests/app-download-semantics-fixtures.json`；不新增 DTO 或 Token，正式依赖仍为 `v7.2.1`。

此提交是契约同步，不证明网关运行时、受限 SSH 预热／晋级入口已实现或部署。2026-10-03 负责人修正凭据前提：可以复用已有存储凭据；上游已提交文档中的“独立只读凭据”要求等待 Backend 后续提交修订，Mobile 不在同步副本内私改。实际接入遵循新授权：只在显式预热／修复进程使用隔离配置，公开网关不得持有或继承凭据，不调整现有凭据权限。固定 APK 桶／路径及只调用读取操作是应用层限制，不能证明云端权限最小化，泄漏仍可能影响现有凭据原先授权的全部资源。

本次定向验证：OpenAPI validate 与 api:generate 成功；`app_download_contract_test.dart` 6 项通过，覆盖 nullable 状态、完整制品身份及匿名 HEAD/GET/Range；`contract_revision.test.mjs` 通过逐字来源同步和拒绝非祖先 revision；生成客户端全量分析零问题；API 覆盖 162/162、21 个模块文档检查通过。既有生成类型无变化，仅新增下载类型、导出、serializer 注册和三条诊断路由。此前应用完整门禁记录继续保留；最终接入后的必要门禁另行执行。

源码来源检查继续以本文件的候选 SHA 为事实，不为消除公网版本／SHA 差异而部署或伪造同步。最终发布工具集成、测试与云／设备未验证项见[交接记录](private-apk-download-acceptance.md)。

## 后续运行时契约同步（2026-10-03）

精确来源更新为 Backend `27dc3ff7eeb51334ff024feb8494e78eb7ae7fc8`／`5.31.0-dev.20261003.1`。该提交包含下载运行时 `53f9325` 与最新讨论定位基线；下载 DTO/operationId 不变，完整 OpenAPI 新增两项讨论窗口、可选 `replyNumber`、窗口模型和 `40010 DISCUSSION_TARGET_FILTERED`，不能用先前下载 OpenAPI 覆盖它们。SDK 继续由固定生成器全量生成，窗口和编号的 UI 消费由另一个独立切片负责，本次不混改阅读行为。

同步入口追加逐字导出 `discussion-navigation.v1.json` 和说明文档。两项未接入窗口 operationId 在覆盖清单明确列为独立切片；现有分页继续兼容。后端运行时入口已核验：原受限晋级命令前置 `--gateway`，`--url` 仍是历史 RainS3 制品地址；内部完成登记、鉴权预热、源身份/缓存复核、说明发布证明、网关启用和策略切换。失败恢复仍由原受限 `--recover` 执行，Windows 不自动恢复或直接执行内部 node CLI。

凭据修正已经包含于本次同步的 Backend 文档：允许复用现有凭据，仅显式预热／修复读取私有配置，公开网关不持有或继承；应用限制不等于云端只读，不改原权限。此前记录保留为历史，不再作为当前前提。

本次运行时来源同步验证：OpenAPI 校验／生成成功；下载契约消费 6 项通过；Windows 固定 revision 与新增文档逐字同步测试通过；生成客户端全量分析零问题；API 范围 162/162（238 总操作、76 项明确排除）及 21 个模块文档检查通过。最终门禁在发布工具接入后统一运行。

# Android 存储桶直连契约同步

固定 Backend `882889c5d8dc4a47893cb4fe913a0f68e536ce2f`／OpenAPI `5.37.0-dev.20261015.1`，来源为 [Backend PR #50](https://github.com/morenk/wenyousite-backend/pull/50)，尚未合并部署。使用官方 `tool/sync_backend_contract.ps1` 从 Windows 后端只读镜像导出，并新增逐字同步的 `contracts/android-direct-download.md`；既有列表和行内组合语料仍保留各自固定来源。

新增 Web 专用 `mobileReleasesAndroidDownload`，返回推荐 Android 制品的固定 RainS3 地址。Mobile 在 `tool/api_coverage_exclusions.json` 明确排除该信息接口，继续由 `/meta.mobileCompatibility.android.updateUrl` 驱动更新。新 SDK 方法仅为共享契约同步，不增加 App 请求；原桶与历史网关 URL、HEAD／流式 GET、SHA-256 和原生包身份校验继续兼容。受限发布工具的默认直连切换在后续独立提交完成。

生成客户端由固定 OpenAPI Generator `7.23.0`、规范化脚本、诊断路由生成及 build_runner 维护，没有手工修改生成文件。初次规范化遇到 Windows 短暂文件映射锁，续跑对应生成步骤成功；最终两份 Backend SHA 的 OpenAPI 一致，不重复未受影响生成。

本轮定向验证：`contract_revision.test.mjs` 1 项通过；`app_download_contract_test.dart`、`mobile_update_service_test.dart` 和 `mobile_update_http_test.dart` 合计 58 项通过；修改的契约测试文件格式与静态分析通过。全部使用本机 fixture，无线上写入、真实上传或晋级。按负责人要求未运行全量测试、全仓静态分析、统一门禁或 APK 构建，不声称真实环境或真机验收通过。

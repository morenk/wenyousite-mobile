# Android 0.12.0+102 发布记录

## 授权与验证复用

2026-11-01（Asia/Shanghai），负责人确认后台更新说明已填写并确认，明确要求“重新跑预检，通过后直接合并发布正式版并推送，跳过重复测试”。本轮发布版本为 Android `0.12.0+102`，沿用发布准备 PR #128 与最新 `dev@2e5f6552` 的应用实现。

发布前只读预检已通过：`schemaVersion=1`、`platform=android`、`versionName=0.12.0`、`buildNumber=102`、`confirmedRevision=1`。正式入口在上传前后再次核对说明 revision，不覆盖负责人在后台确认的说明。

按本次明确授权，复用已完成的检查与 Debug 真机验收，不重复全量测试，不新增 Release 真机验收宣称。完整检查的原始失败、修正与补验以及正式签名准备包见[发布准备记录](mobile-0.12.0-release-preparation.md)及[文字修复验收记录](reading-text-style-candidate.md)。晋级只改变提交身份和文档；正式发布仍执行签名、版本、ABI、16 KB 对齐、上传完整性、说明 revision、网关晋级和公网下载核验。

本轮固定 Backend `19a6c4ed48829a781182527faaafce6e788e9e2e`、API `5.44.0-dev.20261024.3`、Foundation `v7.6.0`。沿用正式包 `site.wenyou.app` 与既有证书，不提高最低支持构建号。上传凭据仅在 Windows 本机进程内解密使用，不写入 Git、日志或传给 SSH。

## 发布结果

预检通过后进入合并、晋级与发布流程，实际提交、Tag、制品与线上核验结果完成后补记；此条不能作为已上线证明。

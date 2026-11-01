# Android 0.12.0+102 发布记录

## 授权与验证复用

2026-11-01（Asia/Shanghai），负责人确认后台更新说明已填写并确认，明确要求“重新跑预检，通过后直接合并发布正式版并推送，跳过重复测试”。本轮发布版本为 Android `0.12.0+102`，沿用发布准备 PR #128 与最新 `dev@2e5f6552` 的应用实现。

发布前只读预检已通过：`schemaVersion=1`、`platform=android`、`versionName=0.12.0`、`buildNumber=102`、`confirmedRevision=1`。正式入口在上传前后再次核对说明 revision，不覆盖负责人在后台确认的说明。

按本次明确授权，复用已完成的检查与 Debug 真机验收，不重复全量测试，不新增 Release 真机验收宣称。完整检查的原始失败、修正与补验以及正式签名准备包见[发布准备记录](mobile-0.12.0-release-preparation.md)及[文字修复验收记录](reading-text-style-candidate.md)。晋级只改变提交身份和文档；正式发布仍执行签名、版本、ABI、16 KB 对齐、上传完整性、说明 revision、网关晋级和公网下载核验。

本轮固定 Backend `19a6c4ed48829a781182527faaafce6e788e9e2e`、API `5.44.0-dev.20261024.3`、Foundation `v7.6.0`。沿用正式包 `site.wenyou.app` 与既有证书，不提高最低支持构建号。上传凭据仅在 Windows 本机进程内解密使用，不写入 Git、日志或传给 SSH。

## 发布结果

2026-11-01 22:37（Asia/Shanghai）正式入口完成上传及网关晋级，退出 0。版本准备 [PR #128](https://github.com/morenk/wenyousite-mobile/pull/128) 合入 `dev`（`682c6ae65f5769d3c2b51421369659137f57415a`），晋级 [PR #135](https://github.com/morenk/wenyousite-mobile/pull/135) 合入 `main`（`76bda64585688e23397dc11b1eae490a3858d90c`）。正式 Tag `v0.12.0` 已推送并固定到该 main 提交，后续文档补记不移动 Tag。

标准入口为 `tool/release-mobile-from-local.sh --version 0.12.0 --build 102 --platform android --host wenyou-admin-vps --skip-checks`。Windows 本机通过既有 DPAPI 读取发布凭据，仅在调用期间注入环境，退出恢复；SSH 继续移除凭据且禁用 SendEnv。全量测试没有重复运行，签名、单 ARM64、ZIP／ELF 16 KB 对齐、不可变上传与说明 revision 前后核验通过。

| 项目 | 发布结果 |
| --- | --- |
| applicationId | `site.wenyou.app` |
| versionName / versionCode | `0.12.0` / `102` |
| 构建源码 | `76bda64585688e23397dc11b1eae490a3858d90c` |
| notesConfirmedRevision | `1` |
| APK 字节数 | `37981017` |
| APK SHA-256 | `3cadf36fa8db5ba7763d39fd196ee3866baf5d023fdaf3a51a602a1a1439df05` |
| 签名证书 SHA-256 | `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839` |

正式 APK 与已准备包的二进制 SHA-256 相同，发布清单另外绑定 main 提交及说明 revision 1。证书与上一正式 build 101 一致。线上 `/meta` 已读回推荐构建号 102、最低支持构建号 null，Backend 来源保持 `19a6c4ed`。正式下载地址为 [Android build 102](https://wenyou.site/api/v1/app-downloads/android/102/file)。

通过正式下载地址完整下载 37,981,017 字节，SHA-256 与上表完全一致；公开说明返回 Android／`0.12.0`／102／revision 1，发布时间为 `2026-11-01T14:37:25.932Z`。负责人填写的摘要“修复了些许BUG。”及 6 条更新内容均保持原文，没有用本地建议稿覆盖。

制品、发布清单、完整下载文件与公开回读证据保存在 `D:\codex-artifacts\mobile-release-0.12.0-102-20261101\published`，包括 `verification.json`、`meta.json` 与 `release-notes.json`；发布日志为上一级 `publish.log`。本记录提交后仅合入 dev，不改变 main、正式 Tag 或发布制品。任务分支的本地与远端清理结果见该目录 `cleanup-final.json`；主工作目录、其他任务 Worktree 和本机文件保持。

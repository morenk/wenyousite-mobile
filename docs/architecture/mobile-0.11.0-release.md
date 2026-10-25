# Android 0.11.0+101 发布记录

## 授权与源码

负责人于 2026-10-25（Asia/Shanghai）确认六项组合 APK 验收通过，授权合并、清理任务分支，随后明确要求“直接发布正式版并推送，跳过全量测试”。本轮按授权发布已合入 `dev` 的内容，基线 `4a6d55ad4b6c1883726419a3232aa70082214e26`；六项原 PR #101、#103、#100、#76、#104、#92 与组合 #120 均已合并，#99 仍排除。

相对已验收源码 `27629010f47c74da96868774cfd3157de9603f75`，应用、测试、工具、契约、依赖和原生源码不变，本轮只递增 `pubspec.yaml` 版本并更新发布记录。沿用 Flutter 8093 通过／1 既有 Sentry 人工验收跳过、Windows 工具 49/49 的完整门禁及已验收 Debug APK；不重复全量测试，不把未运行项目记作新通过。本轮继续执行正式包构建、签名、包名／版本／ARM64／16 KB 对齐、制品摘要、固定契约及实际发布链路核验。

负责人已验收组合 Debug 包并明确要求直接正式发布；本轮没有另行安装或启动 Release 包，不虚构 Release 真机冒烟。构建使用既有正式签名及开发机独立诊断配置，凭据与签名材料不进入 Git、日志或 VPS。

此前验收 APK、测试日志、未跟踪验收资料及逐文件 SHA-256 已保留到 `D:\codex-artifacts\mobile-six-pr-accepted-20261025`；清理对象仅为上述七个任务分支与临时 Worktree，不处理其他任务、历史归档或兼容协议。

## 更新文案

以下为负责人在后台确认并实际发布的 revision 1 文案；保留负责人调整后的内容，不以本地建议稿覆盖。

温油站 0.11.0

自定义字体上线啦!!!

- 新增主题帖自定义字体选择，目前支持中日英三种字体。
- 优化主题编辑安全区、回复栏和相册选图体验。
- 修复编辑器选区异常、分隔线输入及正文保存问题。
- 修复含尖括号、居中标记等内容的显示与编辑异常。

## 发布预检与记录

准备时公网推荐 build 100，最低支持构建号为 null。后台为 Android／`0.11.0`／101 确认说明后，受限预检返回 `confirmedRevision: 1`。首次未确认时预检失败，未绕过；用户确认后重新预检通过。正式上传后再次核对同一 revision，变化即停止。

固定 Backend 来源 `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`、API `5.44.0-dev.20261024.3`、Foundation `v7.6.0`；API 为 `https://wenyou.site/api/v1`。使用已提交的本站下载网关流程，不切换 #99 的存储桶直连方案，不提高最低支持构建号。

## 正式发布结果

2026-10-25 22:12（Asia/Shanghai）完成正式发布。版本准备 [PR #121](https://github.com/morenk/wenyousite-mobile/pull/121) 已合入 `dev`，晋级 [PR #122](https://github.com/morenk/wenyousite-mobile/pull/122) 已合入 `main`。构建时工作区干净，HEAD 与远端 `main` 一致；正式 Tag `v0.11.0` 已推送，固定指向 `fa08a931c893e0355c68a5ad43a83d9a62349dcd`。发布后的文档补记合入 `dev`，不移动该 Tag。

Windows 执行仓库标准入口 `tool/release-mobile-from-local.sh --version 0.11.0 --build 101 --platform android --host wenyou-admin-vps --skip-checks`，退出码为 0。正式签名、单 ARM64 ABI、16 KB ZIP／ELF 对齐、发布前后说明 revision、不可变上传及管理员网关晋级检查通过。`--skip-checks` 按负责人要求复用既有完整门禁，没有重新执行全量测试。

| 项目 | 实际结果 |
| --- | --- |
| applicationId | `site.wenyou.app` |
| versionName / versionCode | `0.11.0` / `101` |
| 源码提交 | `fa08a931c893e0355c68a5ad43a83d9a62349dcd` |
| 更新说明 confirmedRevision | `1` |
| APK 字节数 | `37849945` |
| APK SHA-256 | `22d871b70e789a7b83c0c0ff9160ebb972ea7f1098ac581523a9f0900802ddd5` |
| 签名证书 SHA-256 | `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839` |
| 发布日志 SHA-256 | `D1746993BBB937E728072DBC889B58EDCE9F265A3A4558FCFC098E9990EAFFD2` |

公网 `/meta` 读回确认推荐构建号为 101，最低支持构建号仍为 null，后端源码与 API 版本未改变；更新说明接口返回 Android／`0.11.0`／101／revision 1。由[正式下载地址](https://wenyou.site/api/v1/app-downloads/android/101/file)完整下载 APK，字节数及 SHA-256 与本地签名制品一致。证书摘要与上一正式 build 100 一致。

制品、发布日志、公开说明快照、公网复核结果与更新文案保留于 `D:\codex-artifacts\mobile-release-0.11.0-101`；其中 `verification.json` 记录完整下载校验结果，`release-notes.txt` 为实际发布文案。构建期间既有 Kotlin／图标提示及上传工具依赖审计提示未阻断发布，本轮未修改依赖。

## 已合并任务的清理

六项原 PR #101、#103、#100、#76、#104、#92 及组合 PR #120 的提交已完整进入 `dev`，对应七个本地／远端分支及临时 Worktree 均已清理。清理前核对合并记录、分支 SHA、工作区状态与进程归属；必要的忽略文件、未跟踪验收资料和 APK 均先归档并逐文件核验摘要，远端删除以核验的提交作为条件。

清理证据见 `D:\codex-artifacts\mobile-six-pr-accepted-20261025\cleanup-final.json` 及同目录 `cleanup-before.json`、`evidence-sha256.json`。#99、其他任务 Worktree、主工作目录和既有 stash 均保留。发布任务自身在本记录合并后按同一门禁清理，实际结果另存发布制品目录的 `cleanup-final.json`。

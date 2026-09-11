# PR #15 移动端验收与合并记录

2026-09-11，负责人在当前候选交付后明确回复“可以合并了清理分支”。据此记录移动端候选验收通过，并授权合并 [PR #15](https://github.com/morenk/wenyousite-mobile/pull/15) 到 `dev` 及清理该任务分支、临时 Worktree。此前候选、失败过程与检查记录继续保留，不改写已推送历史。

## 验收对象

- 候选源码：`ffce5178e549eac9a18a400ebb8558a6d7b63de3`。
- APK：`wenyou-debug-clipboard-d04d1e53.apk`；SHA-256 `d04d1e534fba2a6732aa91fb0126a908e99b87272cd5d8847a987945e603cabd`。
- 应用：`site.wenyou.app.debug`／温油站 Debug，`0.7.0-dev.1-debug`（94）。包含列表空项／空行与结构输入、列表标记基线及阅读复制括号修正。
- 验收依据为负责人对已交付候选的明确接受与合并指令。代理未取得设备内 APK 哈希或新增 ADB 安装结果，不补写未执行的设备检查。Web 列表标记对齐仍待原 VPS 任务独立交付，不纳入本次移动端完成结论。

## 合并前核验

- 对照 `dev` 的 `de2761d6` 整合已合并的阅读快翻能力；冲突仅为契约来源、模块契约登记和变更记录，业务源码无冲突。文档保留双方记录。
- Backend `0624126` 与 `b785336` 的机器契约差异仅为列表夹具和 CHANGELOG；保留已审批、包含列表 v1 revision 2 的固定来源 `0624126`，收藏夹计数说明与生成代码不回退。
- 原候选 Flutter 全量 4212 项通过、1 项既有跳过，Windows 工具 17/17；公网契约来源差异及已修正的首轮 lint 记录保留，首轮完整门禁不记作全绿。
- 本次整合后，编辑器、Markdown、真实复制页面和阅读快翻相关回归共 1713 项通过；`flutter analyze --no-pub --fatal-infos --fatal-warnings` 零问题，架构及 21 个模块文档检查通过。日志保存在归档 `build/pr15-merge-verification`。
- 原 APK 仍对应 `ffce5178`；合并其他已验收功能的源码不冒充该 APK 的构建输入。本次只合并开发分支，不正式发布或部署。

## 清理与证据保留

任务制品、历次候选 APK、测试日志、排查探针与失败图片在 Worktree 清理前保存到 Windows 的 `D:\code\wenyousite\artifacts\mobile-pr15-20260911`，逐文件核对 SHA-256；最终合并提交与清理结果见归档 `cleanup-manifest.json`。其他任务目录和含未提交修改的主工作区保留。

本记录优先于关联候选文档中的历史“待验收”状态；它不关闭其他任务的问题，不改变 Web 的独立验收状态。

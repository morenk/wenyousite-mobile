# 手动回车后的正文对齐验收

状态：移动端候选已实现／待负责人验收。

## 原始反馈与范围

负责人反馈，普通正文居中或右对齐后，手动回车不应继续上一行的排版方向；长句因宽度自动折行时，应整体保留所选方向。普通正文与引用的一次回车仍只增加一行，标题与列表保留常规行为，粗体、斜体等行内格式不在重置范围。

旧实现将普通手动回车写成同一段内 LF，并主动继承对齐；保存和重开因此无法区分新排版段与旧段内换行。此处需同时处理编辑输入、段落边界、阅读间距、选区对齐与保存重开，不能只清除当前行的对齐属性。

## 已提交事实源

- Windows 基线：`d402d5d74c98b5ff5f00b4c0c358ce3684860f49`，已包含负责人验收通过的空 H2/H3 与图片输入修复。独立 Worktree 为 `D:\code\wenyousite\wenyousite-mobile\.dart_tool\worktrees\manual-alignment`。
- 后端候选：[PR #5](https://github.com/morenk/wenyousite-backend/pull/5)，`3338028459561565c788d5236fb64db84a2ae538`；同步 `contracts/markdown-editor-newline-v1-fixtures.json`，`version: 1`、`revision: 2`，包含 27 条 `editCases`。
- Web 候选：[PR #6](https://github.com/morenk/wenyousite-frontend/pull/6)，`a8826561774fb9b564f6e126e565b3817617f21c`；兼容登记：[PR #6](https://github.com/morenk/wenyousite-workspace/pull/6)，`9bd2e139b262260b17ea794b8f6a7614b1eb2527`。
- 2026-09-09 再核验 GitHub：上述 PR 已由关联任务合并，合并提交分别为后端 `12d54f6`、Web `928276a`、兼容登记 `99b426d`。后端最新 `origin/dev` 为 `23f76a1`，与交接 commit 的 OpenAPI、newline fixture、契约 CHANGELOG 和移动指南无差异。本任务未执行远端合并或部署。
- 公网后端实测仍为 `e8d0fd6cb193ab5e9a1c2c51c03382ef300adc0c`、HTTP `5.18.0-dev.20260905.1`、Markdown v5；Web 部署未在本任务验证。PR 合并不代表公网运行版本已切换。
- 已 fetch Foundation 远端及 tags，最新正式版仍为 v6.9.0；已核对该版 CHANGELOG 与移动 profile，继续固定此版本。

## 行为与独立预期

- 普通正文中间的一次手动 Enter 使用既有 Markdown 段落分隔，例如 `甲\n\n乙`。编辑和阅读只显示相邻两行；分隔空行不能成为额外可编辑空行。
- 居中或右对齐段落的右侧新段恢复左对齐，旧段方向保留；在行首 Enter 产生的空行不保留无内容对齐，原文字进入新左对齐段。
- 真正空白行使用 `<br />`；连续 Enter 保留数量。空行续写后成为新段，不能重新并回上一段。
- 自动折行不修改文档；旧单 LF 与 Shift+Enter 属于同一段，对齐操作应作用于整个段落。历史段落边界保留，相邻正文段落统一无额外段间距。
- 引用、H2/H3、列表及行内格式保持既有约定。保存前的文字、样式、段落、对齐、链接和节点身份校验继续生效。

## 检查与待验收项

契约同步的 OpenAPI 校验、客户端再生成及一致性检查已通过；生成 SDK、依赖锁文件与 OpenAPI 无变化，21 个模块文档检查通过。真实移动端控制器逐条消费 27 条输入：旧实现 19 条失败，候选全部通过，分别断言输出、可见行、逐行方向、续写和重开。

新增真实回复页面通过 Android 输入连接提交 LF，验证居中／右对齐正文的输入、发布请求和重新编辑；新增旧 LF／Shift+Enter 同段方向、段落独立排版、撤销／重做、删除边界、行内粗体斜体删除线续写、Web 结构片段粘贴与光标回归。阅读位置检查覆盖左／中／右、快速文本与 Markdown 路径、真正空白行和长句自动折行；7 张创作／阅读／主题页 Golden 经查看，均为相邻正文之间额外间距去除后的变化。

补充光标断言后，曾在 18 条行首／行中用例复现多向右跳一字：Quill 将显式 Delta 换行再次计入位置补偿。候选在这条路径保留调用方的准确选区，结构化粘贴收起源码分隔时按实际删除位置变换光标。修正后 92 条换行／对齐／引用／实际回复页相关回归通过，27 条操作同时核对每次 Enter 的光标位置。

完整门禁使用 `npm run check:apk -- -ContinueAfterFailure` 收集结果。所有原检查均执行，任何失败仍使门禁返回非零；候选来源与公网部署版本不同仍必须报告，不能用候选构建替代部署核对或负责人验收。

最终复核 `npm run check -- -ContinueAfterFailure`：2,458 项 Flutter 测试、17 项 Windows 工具测试通过，1 项既有 Sentry 外部回执测试按显式开关未启用；应用与生成客户端完整分析零问题，格式、架构、21 个模块文档、API 覆盖、OpenAPI 校验与客户端再生成一致性通过。门禁最终仅因公网后端 revision 不匹配返回 1，不能标记完整门禁通过。Debug APK 已在最后一版应用代码上构建成功，此后只调整验收记录和视觉测试基线，生成 SDK 与依赖锁文件无差异。

本地日志保存在 `build/wenyou-manual-alignment-red.log`、`build/wenyou-manual-alignment-first-check.log`、`build/wenyou-manual-alignment-cursor-green.log` 和 `build/wenyou-manual-alignment-final-check.log`。首轮发现的 5 条 lint、18 条光标断言和 5 张主题页基线差异均已处理，并由最终全量复核覆盖。

公网来源校验仍要求已部署 revision 与本地记录一致。当前后端运行版本尚未对齐；必须如实记录该限制，不能据此声明完整联调或负责人验收通过。

## 候选安装包

- 候选应用源码提交：`1fe94358bc7a0313a6e8ef974f4d2b17b8327bc2`。交付前合入 `dev` 的任务清理规范，仅涉及 `AGENTS.md` 与 CHANGELOG，应用、测试及依赖与该候选无差异。
- APK：`build/app/outputs/flutter-apk/wenyou-debug-manual-alignment-db2c8965.apk`，203,722,314 字节。
- SHA-256：`db2c896578d3bda6fed24461c413b0ed007612f13b703029e85c0f92b485edac`，同目录提供 `.sha256` 文件。
- 应用：温油站 Debug，包名 `site.wenyou.app.debug`，版本 `0.7.0-dev.1-debug`、构建 94、最低 API 26。APK v2 签名验证通过，ARM32／ARM64／x86_64 引擎及全部三种 Foundation 字体完整。
- 当前未执行本候选的 ADB 安装或负责人真机验收；先前空 H2/H3 包的验收不覆盖此候选。构建保留既有 `flutter_image_compress_common` KGP 迁移警告，未升级依赖。

## 负责人复验

仅使用专用测试账号，在上面的候选包及已确认部署版本的 Web 中执行：

- [ ] 普通正文输入「甲乙」并居中／右对齐，在行首、行中、行尾各按一次 Enter：光标紧接换行，旧段保持方向，新段左对齐，无多余空行。
- [ ] 连续两次／三次 Enter，再续写；只增加对应行数，真正空白行保留，续写为左对齐。
- [ ] 将长段设为居中／右对齐，因屏幕宽度自动折行时整段方向一致；手动回车后的新段可独立设置方向。
- [ ] 发布、关闭再编辑和草稿重开后，文字、行数、方向及粗体／斜体／删除线一致。Web 与移动端交叉保存重开结果相同。
- [ ] 旧段内软换行及 Shift+Enter 保持同段方向，引用不自动退出，H2/H3 与列表继续常规回车行为。

验收状态继续为“候选／待负责人验收”，负责人需明确回复对应候选的原场景结果。

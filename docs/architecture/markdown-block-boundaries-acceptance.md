# 富文本块边界跨端候选验收

## 当前状态与范围

2026-09-11：排查中／契约交接准备。任务分支 `codex/20260911-markdown-block-boundaries` 从 fetch 后的 `origin/dev`（`dbba204dd5d43252a400ff50a4db7348415d62f3`）建立，独立 Windows Worktree 为 `C:\Users\quhui\.codex\worktrees\202d\wenyousite-mobile`。本阶段仅审计与补充基线回归，未改生产实现；等待治理任务提供 Backend 已提交 fixture SHA 后同步，不能视为原问题修复完成。

目标是统一已有 Markdown v5 对齐块边界并保护阅读、编辑、保存重开、草稿和剪贴板链路。不扩大格式或 URL 白名单，不迁移旧内容，不修改 HTTP 字段、字体、Foundation 视觉规范、摘要紧凑规则或段内粘贴继承目标段落对齐的行为。

已记录后端与公网 `/meta` 均为 `0ee2c0de1d9c570e495e778be6661b074b7a4bef`，HTTP 契约 `5.20.0-dev.20260909.1`，公网 Markdown v5。共享 fixture 尚未同步。

## 原始复现与独立证据

原楼层通过只读 GET `/api/v1/posts/cmtvt31qc00497qc2xwuu6ama` 取得。首个触发片段为 `经历：`、单 LF、`[wenyousite-align-v1-center]: #`、单 LF、H2 标题；marker 前没有空行。治理任务报告 Web 有一个 marker 泄漏；Mobile 原截图正常，不能把 Web 根因当作移动端已证实缺陷。

- 对原楼层完整正文执行现有 `MarkdownAlignmentContract.analyze`：32 个有效对齐块、0 个无效 marker。Codec issues 为空，Delta 正文无隐藏 marker。
- `wenyou_markdown_block_boundaries_test.dart` 保留相同字符／换行边界并用短目标正文替换标题，覆盖 center/right × P/H2/H3：验证源码位置、独立阅读块、实际样式和可见文字，无 marker 泄漏。6 个 Widget 回归在未修改生产实现时通过。
- 现有 `markdown_alignment_compatibility_test.dart`、`markdown_delta_alignment_compatibility_test.dart`、`markdown_v5_image_alignment_contract_test.dart` 共 114 个测试通过。
- 原截图第二幕后的手工空格排版片段，以原始正文截取首个 `﹁` 至 `﹂` 所在行：现有 Codec 编码结果与原文逐字符相等，issues 为空。该片段含行首／行中／尾部 ASCII 空格与 U+2060；原始间隔保持，未使用近似排版字符串替代。

原楼层全文和临时审计日志仅保留在本机临时目录／忽略的 `build` 目录，不提交完整用户正文。上述证据不代替真实页面编辑、真机视觉或负责人验收。

## 已证实差异与待交接语义

1. 直接分析 CRLF 的 `before\r\n[wenyousite-align-v1-center]: #\r\n## title` 时，分析器返回 0 个有效块；Codec 会先规范化，因此该路径仍正确。需要统一入口的换行语义。
2. `<div>` 与 `</div>` 之间的 marker 被分析器消费，Codec 给其中标题附加对齐。需按共享 fixture 保护多行 raw HTML。
3. 首尾各一个反引号、内容为 `before`、marker、`title` 三行的合法行内代码，在独立完整 Markdown AST 中是一个 code 节点；现有分析器却消费 marker，Codec 丢失该字面行。需保护跨行 code span。
4. 围栏和四空格缩进代码的已审计样例均未消费 marker。治理已明确：保护区外第 0 列的精确合法 marker 结束引用／列表 lazy continuation；显式引用或缩进 marker 仍为非法嵌套。等待 fixture 固定具体组合。

## 后续验收条件

收到已提交 Backend SHA 后，以同步脚本锁定该 revision，独立 chore 同步契约，再修复与共享语义不符的真实差异。继续覆盖相邻正文、标题、图片、列表、引用、分隔线、协议空段、连续 marker、空行、LF/CRLF、未知协议和危险 URL。

阅读与编辑必须分别断言可见文字、空白行、逐块对齐、空格和 Unicode 字符；补充真实 Quill 输入事务、保存多轮重开、草稿恢复和站内／纯文本剪贴板。纯文本不泄漏隐藏 marker、媒体地址与节点身份，既有粘贴继承行为保持。

交付前运行相关回归、`npm run check` 和 Debug APK 构建，记录 APK 版本与 SHA-256。负责人须使用候选包复验原楼层对齐与手工空格排版，确认阅读、编辑、保存和重开；当前未构建、未安装、未执行该真机验收。正式修复状态保持待负责人验收。

# Sentry 编辑保存候选

状态：候选修复／完整门禁通过，待负责人验收。

## 范围与证据

- 基线：`origin/dev` 的 `d7168b61ea1b547e737585d2e9b250f1b3bd24e2`，任务分支 `codex/20261015-sentry-editor-save`。
- 关联 `WENYOUSITE-MOBILE-2J/1T`（`markdown.document_roundtrip`）、`1G/2A`（`markdown.divider_line`）与 `21`（`markdown.paragraph_alignment_conflict`）。这些事件没有原始正文、Delta 或完整操作序列，不能证明其精确触发条件。本候选不关闭它们。
- 已证实的本机操作：打开 `前文\n\n---\n\n后文`，在分隔线节点后输入文字、删去线前两次换行或线后两次换行，旧代码均产生 `divider_line`；全选跨线并应用 H2 则产生 `divider_attributes`。原有严格保存门禁正确阻断写入。
- 不吸收独立 PR #76 的尖括号／打开保护改动，也不调整 HTTP、Markdown 契约、数据库、依赖或线上数据。

## 实现与保留边界

- 控制器输入、格式和 compose 事务维护分隔线独占行，保留文字与非分隔线节点；选中节点本身仍可删除。补边界与原操作共同进入原生撤销记录，不在序列化后修改正文。
- 既有严格语义等价、块校验、读取列表结构校验保持。无损失败继续保留当前编辑内容及上次成功草稿。
- Codec 异常只附带结构计数与固定差异类别，不保存原始内容。明确机器码分组不受行号变化影响；未知异常仍按位置分组，事件堆栈始终保留。
- 分组键调整只影响新事件，首次发布可能形成新组，不迁移、合并或关闭历史 Sentry issue；仍按 release、机器码与事件时间关联核验。
- 与区间读取候选按 range → codec 合并；整合 `LiteralTextQuillController.replaceText` 时必须保留 range 在公开方法／编辑事务之前的合法性 guard。无效区间应在任何正文修改或分隔线维护前返回，不能把检查移回 `_replaceLiteralText` 内部而让外层维护仍执行。两项候选共享此控制器，不能机械覆盖任一方改动。

## 验证记录

- 旧实现：`editor_divider_editing_test.dart` 四项均在 `flush == true` 断言失败，实际分别为 `divider_line` 三项与 `divider_attributes` 一项。
- 定向 `flutter test --no-pub test/features/editor/editor_divider_editing_test.dart test/features/posts/post_divider_edit_test.dart test/core/diagnostics/codec_structure_diagnostics_test.dart -j 1` 已通过最初 11 项：包含上述四项旧红新绿、原生单次撤销／重做、空段／Emoji／粗体、实际回复页草稿／发布／重开及诊断隐私／分组。之后补充相邻分隔线、无效选区与引用隐藏分段三项，三文件共 14 项已随完整门禁全部通过。
- 2026-10-16 首轮 `npm run check:apk -- -TestConcurrency 1` 通过 OpenAPI、固定来源、再生成一致性、公网只读契约与全仓格式，应用分析因三条新 import 排序 lint 退出 1；已修正，保留原日志后从统一入口重跑。测试仅使用本机内存、离线 Fake Repository，不调用线上写入。
- 2026-10-16 第二轮 `npm run check:apk -- -TestConcurrency 1` 退出 0：契约、生成一致性、格式、应用与生成客户端分析、架构、模块文档和 API 覆盖均通过；全量 Flutter 测试 6601 项通过，1 项既有真实 Sentry 回执测试按显式配置跳过；新增 14 项回归均执行；Windows 发布工具 49 项通过；ARM64 Debug APK 构建成功。应用源码此后没有变化。
- 生成客户端、契约与两个依赖锁文件没有变更；`git diff --check` 通过。完整日志保存在本机 `D:/codex-worktrees/mobile-sentry-codec/check-apk-2.log`，SHA-256 `A74AEA13F72812B9A23C19F75AD47DB945E42BE2722C50F21B744F6E6ACB19C4`；首轮失败日志为同目录 `check-apk.log`，SHA-256 `90ABDD0FDE7C0A82509D2D87EC1A86E9D78777300ADDD7F3912227AFC72BE15D`。
- 真机、原 Sentry 事件精确输入与新 release 观察尚未完成；自动测试与构建不代替负责人验收。

## 本机候选包

- 路径：`D:/codex-worktrees/mobile-sentry-codec/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 实际包名 `site.wenyou.app.debug`，版本 `0.9.0-debug`，构建号 `99`，ABI `arm64-v8a`（`aapt dump badging` 已核验）。
- 大小 `110352398` 字节，SHA-256 `DBAB9FB046CA154001D560A6FADFA81E44A02269A6060970EF9FAEC0C35CE024`。
- 未安装、未启动应用；未执行线上业务写入或隔离写入 E2E，页面回归只使用本机 Fake Repository。

## 负责人复验

1. 在实际使用的候选应用打开含分隔线的可编辑正文，在线前／后输入、删除边界、全选应用 H2／列表／引用，确认文字与分隔线各自保持完整。
2. 验证撤销、重做、关闭恢复草稿、保存与重新打开；继续检查已有空段、Emoji、图片和行内格式。
3. 如仍出现保存保护，复制问题编号与脱敏详情，并在独立沟通中给出可共享的原文和操作顺序；不将真实正文追加到自动诊断。

本子任务可见审批策略为 `never`。Auto-review 默认偏好已传递，但工具没有运行审批配置入口，实际 Auto-review 尚未设置／核验。

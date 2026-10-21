# 编辑器帖内身份入口候选验收

状态：已获负责人合并授权，完整自动化门禁通过；候选原场景尚无真机验收结果。自动回归及合并授权均不替代实际真机验收。

## 2026-10-19 合并准备

负责人明确授权在 Web 两个 PR 合并部署后将 Mobile PR #108 合入 `dev`。本任务只完成检查与提交，最终顺序由治理任务执行；不发布、安装 APK。原场景未获得真机验收结论，分支和 Worktree 保留，不把合并授权记为人工验收通过。

已将最新 `origin/dev`（`98971505d6cc89a880d39213eee7421b00bc0c16`）以普通 merge 整合到原任务分支，保留双方 CHANGELOG；公共流程重构与入口可见性逻辑无代码冲突。最终应用源码为 `694c09702a259d138f01ff629127a26c8c08cfd5`，随后只有文档变化。

完整 `npm run check -- -TestConcurrency 2` 返回 0：Flutter **7299 项通过、1 项既有跳过**；Windows 工具 **49/49 通过**。同时通过 OpenAPI 校验、固定契约来源、客户端重新生成一致性、线上只读契约核验、1429 文件格式检查、应用与生成 API 全量静态分析、架构、23 模块文档与 API 覆盖检查。契约与依赖锁无变化，未构建 APK、未运行线上写入测试。

完整日志：`C:\Users\quhui\AppData\Local\Temp\wenyou-mobile-identity-entry-check-20261019.log`，SHA-256 `a9efe7d7e98d309fe451861f062171e807096c345a47ad26d91312a85b788ab6`。`npm ci` 另报告既有工具依赖 10 项审计漏洞；本次按原锁安装，不扩展依赖升级范围。

## 问题与范围

原始需求：楼主没有开启帖内身份，或已开启但本人没有玩家身份时，编辑器不应显示帖内身份入口。负责人进一步确认保留楼主和协作者的资格。

复现步骤：在关闭功能的主题，或已开启但本人无资格的主题中，打开新楼层、楼中楼或首次 BODY 编辑器。旧实现仍创建身份组件并显示站内头像／用户名，集合残留角色时仍可能出现身份菜单。预期为整个身份区域隐藏，头部恢复本次发表／回复标题。

根因已由组件回归证实：`PostIdentityComposerBar` 没有以集合账号的 `enabled && eligible` 决定是否显示。旧实现下“开关与资格独立控制入口，残留角色不使身份栏可见”的两个分支均失败，实际仍找到站内用户名。本轮没有连接负责人原设备复现，因此原机画面和人工验收仍待完成。

## 候选行为

- 集合确认功能关闭或账号无资格时，整个身份组件隐藏且不占高度；父级传空身份区域，恢复正常标题与拖拽／展开按钮，不追加说明或身份专用留白。
- 资格沿用后端的楼主、协作者或已标记玩家；符合条件但没有角色时仍能从加号配置。读取尚未成功时保留必要加载／重试提示。
- 集合刷新后即时重新判断可见性；旧角色、已选 RP 和旧 RP 草稿不能绕过可见性条件。
- 不在隐藏时改写 mode、identityId、token 或冻结载荷。提交时仍保留角色失效后的停止与草稿防护，不自动改账号发布；再次明确发表才使用账号。
- 已有正文编辑保持原作者，不提供改身份入口。新主题尚未启用身份，仍沿用既有账号流程。

## 版本与边界

- Windows Worktree：`D:\codex-worktrees\mobile-identity-entry\wenyousite-mobile`。
- 分支：`codex/20261018-mobile-identity-entry`，基线 `185b72f2d72affce2ecb3dd6a75535bc5f1a1875`。
- Backend `origin/dev`、本仓固定 revision 与只读公网 `/meta` 的 `buildSha` 均为 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`，API `5.40.0-dev.20261018.1`；本轮未更改契约或生成客户端。
- 无线上业务写入、无部署、无新建 Debug 设备会话或接管现有进程。没有本轮 APK、原机截图或负责人通过结论。
- Auto-review 默认偏好已传递；协作工具没有审批配置入口，实际审批配置尚未设置／核验。宿主实际策略为 `never`，不能等同于 `auto_review`。

## 验证记录

定向测试共 64 项通过，实际路径如下：

- `test/features/posts/post_identity_composer_bar_test.dart`
- `test/features/posts/post_identity_submission_test.dart`
- `test/features/posts/post_identity_entry_visibility_test.dart`
- `test/features/posts/post_identity_selection_test.dart`
- `test/features/posts/post_multiple_identity_selection_test.dart`
- `test/features/posts/post_identity_preference_test.dart`
- `test/features/posts/post_identity_composer_lifecycle_test.dart`
- `test/features/posts/post_body_identity_test.dart`

前两文件在首批执行中通过 18 项，后六文件在第二批执行中通过 46 项；不重复累计首批的入口测试。新入口测试最初使用不存在的编辑目标而失败，修正为既有 `reply-own` 测试对象后，四类编辑器的开关／资格组合及动态撤权恢复全部通过。已有 360dp 明暗 Golden 和 320dp 双倍字号组件回归通过，未更新 Golden 基线；它们不代表本轮真机画面。

普通低风险入口候选按仓库流程执行全仓格式、应用与生成 API 全量静态分析及相关测试；完整 `npm run check` 保留到负责人验收通过后的集成阶段。本轮不要求独立 APK，不执行构建或安装。

本轮检查全部通过：全仓 Dart 格式 1414 文件零修改；应用 `flutter analyze --no-pub --fatal-infos --fatal-warnings` 与生成 API `dart analyze --fatal-infos --fatal-warnings` 均零问题；架构检查通过且无新增超限项；模块文档检查 23 模块完整；`git diff --check` 通过。

## 负责人复验

1. 关闭帖内身份，打开新楼层／回复编辑器：无头像、用户名或身份下拉入口，标题与展开操作正常。
2. 开启功能，以无资格普通用户打开：同样不显示入口；恢复以前 RP 草稿也不应出现入口，正文保留。
3. 开启功能，以玩家、楼主或协作者打开：保留身份选择；尚未配置角色仍可打开设置。
4. 编辑已有楼层或 BODY：保持原标题与原作者；在有 RP 草稿期间撤销资格或关闭功能，点击发表应先停止并保留正文，不自动以账号发出。

仍未完成：以上原场景真机验收及负责人对实际画面的明确通过。完整集成门禁已按 2026-10-19 的明确合并授权执行通过；合并与后续现场处理由治理任务另行记录，本实现任务未部署。

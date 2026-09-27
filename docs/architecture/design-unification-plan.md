# 移动端六类设计统一计划

日期：2026-09-20。依据：[设置精简与设计统一排查](settings-simplification-audit.md)。负责人已要求列计划并开始，按四批推进，第一批候选／待负责人真机验收；负责人随后要求后三批一同完成，现已一同通过完整门禁和 Debug APK 构建，见[后三批验收](design-unification-completion.md)。

## 目标与边界

让同类界面使用同一组件和 Foundation 语义，删除独立维护的近似布局。沿用无冗余副标题的设置入口，必要的权限、隐私、风险和恢复说明仍在操作处呈现。所有批次均不以视觉统一为由合并业务状态、权限或提交策略。

第一批开始时重新 fetch Foundation tags，当时最新正式版为 `v7.0.0`，与 `pubspec.yaml` 一致；已阅读该版本 CHANGELOG 与 Flutter profile。后端已记录 revision、远端 `dev` 和公网 `/meta` 均为 `4b133355c14198506e4a4380fd741cccd19d844d`，无需再次同步契约。

## 顺序、范围与验收

| 批次 | 设计类别 | 实施范围 | 验收条件 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | 设置行 | 个人设置与主题管理共用 `WenyouSettingsLink`，统一名称、当前值、箭头、只读和禁用态，移除页面宽度百分比截断 | 长值、320/360/600dp、两倍字号不溢出；只读无箭头，禁用不响应；权限和自动保存保持 | 候选／待验收 |
| 1 | 选择项 | 外观和主题管理复用 `WenyouSelectionRow`，共用整行操作入口 | 选中背景、勾选、触控面积和读屏状态一致；停用分区不可选；取消和重复选择不保存；失败回滚可重试 | 候选／待验收 |
| 2 | 页面容器 | 外观、诊断、账号设置收敛内容宽度、边距与底部留白 | 320/360/600dp 及大字号可操作；保留个人页联动滚动，键盘与底部安全区无遮挡 | 候选／待验收 |
| 2 | 错误与重试 | 设置读取/保存失败采用既有 `WenyouStatusBanner` 和动作布局 | 读取失败、保存失败、回滚和重试各自正确；不重复提交；错误文案可读 | 候选／待验收 |
| 3 | 底部抽屉 | 正文草稿、主题云草稿、订阅及主题选择收敛安全区、键盘避让、高度策略和关闭入口 | 短内容不留过量空白，长内容可滚动，键盘弹出后操作可见，系统返回和取消不写入；草稿恢复与订阅规则保持 | 候选／待验收 |
| 4 | 时间展示 | 公开用户最近回复采用 `WenyouTimeText`，梳理同类内容元信息 | 本地时区、相对时间边界和完整日期朗读一致；安全记录等精确时间按业务保留并记录例外 | 候选／待验收 |

按负责人最新授权，后三批在一个任务分支一起交付；依赖升级保留独立 chore 提交，三批统一共用完整门禁和候选。Foundation 为唯一视觉事实源，本计划仅记录迁移范围和验收条件。

## 第一批实现与验证边界

分支：`codex/20260920-settings-consistency`，从最新 `origin/dev` 创建后 fast-forward 承接已提交的副标题清理分支。依赖 [PR #47](https://github.com/morenk/wenyousite-mobile/pull/47)，该 PR 仍待验收，本轮不表示其已通过或已合并。第一批 PR 以该任务分支为基底，保证本批 diff 可独立评审。

只改展示组件和调用点，不改 Provider、网络、存储、权限或 Android 配置。共享设置行的消费者为个人设置、后台提醒系统设置和主题管理；共享选择行的既有菜单、作者选择器默认行为不变，并纳入针对性回归。通过显式相关 Widget/Golden、状态测试和全量静态分析后构建 Debug APK；负责人验收通过后、合并前再运行完整门禁。

手测清单：

1. 个人设置仍无副标题，外观当前值、危险色和各导航入口正常。
2. 外观三选一，选中底色及勾选清楚，切换保存后重开保留；失败提示与重试正常。
3. 主题管理检查分区、长标签、招募状态、可见范围和主贴权限；选择后即时保存，取消及重复选择不写入。
4. 用协作者身份检查“仅楼主可改”完整可读且不可点击；停用分区不可选。
5. 浅色、黑夜、320/360/600dp 和系统大字号下检查长值、触控、抽屉滚动及选中项朗读。

当前没有可复用 Debug 会话，不以源码、Widget 或 Golden 检查代替负责人真机验收。制品和实际测试结果见下方记录。

第一批候选使用 `npm run candidate:apk -- <以下测试文件> -TestConcurrency 2`，实际文件范围：

```text
test/core/widgets/wenyou_settings_row_test.dart
test/core/widgets/wenyou_settings_typography_test.dart
test/core/widgets/wenyou_selection_surfaces_test.dart
test/core/widgets/wenyou_filter_controls_test.dart
test/core/widgets/wenyou_discussion_controls_test.dart
test/features/settings/appearance_settings_page_test.dart
test/features/users/me_page_test.dart
test/features/users/background_reminder_settings_panel_test.dart
test/features/threads/thread_management_page_test.dart
test/features/threads/thread_management_controller_test.dart
test/features/threads/thread_management_autosave_test.dart
```

`thread_management_page_test.dart` 同时注册主贴权限测试。覆盖选择后即时保存、权限只读、失败重试、冲突保留、取消/重复选择、停用分区及大字号选项；既有作者选择器和筛选菜单的浅色/黑夜与大字号 Golden 不应改变。

## 第一批实际候选结果

- `npm run candidate:apk` 退出码 0：全仓 Dart 格式、应用与生成客户端全量静态分析通过，122 项上述相关测试全部通过，Debug APK 构建成功。
- `npm run architecture:check`、`npm run docs:check` 和 `git diff --check` 通过。本批未执行全量 Flutter 测试或完整集成门禁，按普通展示切片流程留待负责人验收通过后、合并前执行。
- 更新并检查 5 张 Golden：外观黑夜、主题设置 360dp、主贴权限 320dp 两倍字号、账号设置浅色/黑夜。既有筛选菜单与作者选择器 Golden 保持不变。
- APK：`D:/code/wenyousite/artifacts/settings-consistency-20260920/wenyou-debug-95.apk`，大小 `223430948` 字节；包名 `site.wenyou.app.debug`，显示名“温油站 Debug”，版本 `0.7.1-debug`，构建号 `95`。
- SHA-256：`e0cc1037299d6b484f1defb3bd2f0223afef57678cfde9185e1175df646ca819`。构建号与前候选相同，以该摘要区分实际安装内容。
- 同目录 `candidate-apk.log` 为完整候选入口日志，`goldens-update.log` 为开发反馈，5 张预览与 `candidate.json` 记录实际提交和未验收状态。构建仅出现已知 KGP 与 SDK XML 兼容警告，未修改依赖或 Android 配置。
- 未安装真机；浅色/黑夜、大字号、实际保存、协作者权限及 TalkBack 仍需负责人按上述清单验收。未合并、发布或将依赖 PR #47 标记为已验收。

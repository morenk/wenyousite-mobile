# 编辑器列表入口隐藏候选

状态：视觉候选／待负责人验收。日期：2026-10-15。

## 范围与来源

- 从已更新的 `origin/dev` `d7168b61ea1b547e737585d2e9b250f1b3bd24e2` 创建 `codex/20261015-hide-list-entries`。
- Worktree：`D:\codex-worktrees\mobile-hide-list-entries\wenyousite-mobile`；只修改 Windows Mobile。
- 共享“更多”托盘隐藏无序列表和有序列表入口；其余图标按原规则重新均分，不新增说明和空位。所有复用该工具栏的主题、帖子、回复和子贴编辑器一并生效。
- 保留格式策略、Markdown ↔ Delta 编解码、历史列表编辑与阅读、站内结构化粘贴，以及既有不支持结构的源码保护；不迁移或清理历史内容。
- Foundation 已 fetch tags，最新正式版及 `pubspec.yaml` 均为 `v7.2.1`；继续复用 48dp 命中区、主题颜色和图标。
- Backend 只读镜像 `origin/dev`、本仓库来源登记和公网 `/meta.buildSha` 均为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，公网契约 `5.36.0-dev.20261005.1`、Markdown 5；无契约变化。

## 开发验证边界

按负责人最新要求，仅执行直接相关测试及改动文件检查；未运行全量测试、全量分析、完整门禁、API 再生成、APK 构建或安装。完整检查仅在负责人明确授权合并时执行。

`.github` 没有工作流文件，远端工作流列表为空；本次提交、推送和 draft PR 不以远端全量 CI 为前置条件。页面测试使用 Fake Repository；未登录、未启动真机 Debug，不写入线上业务数据。线上仅执行公开 `/meta` 只读核对。本轮不属于写入 E2E。

## 定向检查

改动的六个 Dart 文件格式化零变化，静态分析范围严格限定为这六个文件并通过（No issues found）。工具栏首次更新四张 Golden 时 25 项通过。最终定向测试使用以下八个文件：

```powershell
flutter test --no-pub --concurrency=2 `
  test/features/editor/editor_toolbar_test.dart `
  test/features/editor/editor_format_policy_test.dart `
  test/features/editor/editor_list_baseline_test.dart `
  test/features/editor/editor_list_blank_lines_test.dart `
  test/features/editor/editor_wysiwyg_parity_test.dart `
  test/core/markdown/markdown_list_contract_test.dart `
  test/features/posts/post_empty_heading_test.dart `
  test/features/posts/post_list_blank_lines_test.dart
```

覆盖工具栏入口、其余格式操作、列表底层创建／切换／取消、独立阅读树、历史列表安全保存、编辑／阅读画面、空列表草稿恢复与回复发布后重开。测试“发布”仅作用于 Fake Repository。

最终定向验证 486 项通过（无失败、无跳过）；四张新托盘 Golden 对比及原有编辑／阅读配对 Golden 通过。`git diff --check` 通过。本机日志：`.buildlog/hide-list-entries-tests.log`。

## 离线画面

以下实际 Widget Golden 已逐张查看：列表图标移除、其余图标均分、无空占位，明暗主题及 2× 字号未见溢出。图片包含共享格式工具栏和展开的“更多”托盘。

截图补正：初版 `7a429804` 的 Golden fixture 未传 `onInsertSticker`，画面没有展示实际编辑器已启用的表情包入口。应用功能未被删除。本轮补齐回调，四种视口均断言表情包按钮存在且可命中、两种列表按钮不存在，并检查布局无异常；以下图片更新为表情包启用状态。应用源码未变化，兼容回归结果继续有效。补图后工具栏 25 项测试通过，四张 Golden 非更新对比 4 项通过，改动测试文件格式检查通过；未重复无关检查或执行全量门禁。日志为 `.buildlog/hide-list-entries-sticker-goldens.log` 与 `.buildlog/hide-list-entries-sticker-compare.log`。

| 视口与字号 | 画面 |
| --- | --- |
| 360×320dp，亮色，1× | [查看](../../test/features/editor/goldens/editor_more_tray_360_light.png) |
| 360×320dp，暗色，1× | [查看](../../test/features/editor/goldens/editor_more_tray_360_dark.png) |
| 320×320dp，亮色，2× | [查看](../../test/features/editor/goldens/editor_more_tray_320_light_2x.png) |
| 320×320dp，暗色，2× | [查看](../../test/features/editor/goldens/editor_more_tray_320_dark_2x.png) |

应用源码摘要（SHA-256）：

- `editor_more_tray.dart`：`dc27586aedbaa69d03b8fc1d031ebe7149adb53a10dec7a740ded6d63e2692fc`。
- `editor_toolbar.dart`：`3572c82a10eba4f57c60c6bd99aa100cabcab43aa0f2c18320cb4fdaa20dcca6`。

## 待负责人验收

1. 在主题或帖子编辑器打开“更多”，确认无序／有序列表入口消失，其余操作的排布符合预期。
2. 打开已有列表正文，确认列表显示正常；继续编辑、保存和重开时保留原有列表语义。真实业务写入由负责人手动执行，自动化仅用离线 Fake Repository。
3. 明暗主题、窄屏和较大系统字号下确认托盘观感。离线 Golden 不代替真机验收。

未覆盖真机软键盘、系统读屏及负责人实际历史帖子；本候选不声称已完成视觉验收或可合并，不包含音频、APK 下载链路及其他页面调整。

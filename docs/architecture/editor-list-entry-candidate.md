# 编辑器工具栏布局候选

状态：视觉候选／待负责人验收。日期：2026-10-15。沿用 [PR #98](https://github.com/morenk/wenyousite-mobile/pull/98)。

## 范围与来源

- 从已更新的 `origin/dev` `d7168b61ea1b547e737585d2e9b250f1b3bd24e2` 创建 `codex/20261015-hide-list-entries`。
- Worktree：`D:\codex-worktrees\mobile-hide-list-entries\wenyousite-mobile`；只修改 Windows Mobile。
- “偏好 → 编辑器工具栏”可分别配置主栏、展开栏顺序；支持拖动、菜单上移／下移、跨组移动和恢复默认。游客与登录用户均可设置。
- 共享工具栏隐藏无序／有序列表入口，列表不进入可选项。表情包保留，主题创作、帖子、回复和子贴共用布局；受限能力及缺少表情回调的动作继续隐藏。
- 保留格式策略、Markdown ↔ Delta 编解码、历史列表编辑与阅读、站内结构化粘贴，以及既有不支持结构的源码保护；不迁移或清理历史内容。
- Foundation 固定正式版 `v7.2.1`，复用 48dp 命中区、设置组件、主题和语义图标，不增加依赖。
- 本任务起始只读核对 Backend `origin/dev`、本仓库来源及公网 `/meta.buildSha` 均为 `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，契约 `5.36.0-dev.20261005.1`、Markdown 5。本切片无契约变化，APK 下载由另一任务处理。

## 布局与持久化

未自定义时继续使用原主栏、草稿分隔线、窄屏草稿独占行和宽屏引用／表情包提升规则。四张原默认工具栏 Golden 在新实现下直接对比通过，未更新其像素基线。

自定义后主栏按用户顺序取可放下的项目，溢出项目按原顺序排在已指定展开项之前；变宽后恢复主栏意图，不修改保存配置。“更多／收起”固定可达；即使场景原先没有更多能力，自定义移入展开栏的可用工具也能访问。展开栏可滚动，不以裁掉动作解决空间不足。

SharedPreferences `editor.toolbar.layout.v1` 只保存版本和两组稳定 ID，不含账号或正文，不请求 API。网页与 App 各自保存本机偏好，不做账号或跨端同步。启动前加载并注入 Riverpod；保存中禁止重复操作，失败回滚并可重试原目标。恢复默认删除覆盖键，重启仍为默认；未知版本或损坏值回退默认，读取不主动改写，重复与未知工具 ID 被规整，缺失工具归展开栏。

音频仅为后续实现预留稳定 ID `audio`，默认归展开栏。本候选没有音频占位按钮，不实现上传、录音、播放器或音频契约。

## 开发验证边界

依据负责人最新要求及[治理规范 PR #26](https://github.com/morenk/wenyousite-workspace/pull/26)（`1e1948f103290b1ea9f83f86524845062db3fbbb`），仅执行直接相关测试及改动文件检查；未运行全量测试、全量分析、完整门禁、API 再生成、APK 构建或安装。完整检查仅在负责人明确授权合并时执行。

提交前再次核对：仓库没有 `.github/workflows`，远端 `gh workflow list --all` 为空，未配置 `core.hooksPath`；此次提交、推送及 draft PR 不自动触发全量 CI。页面验证使用 Fake Repository，不登录、不启动真机 Debug、不写入公网业务数据；起始公网核对仅公开 `/meta` GET。本轮不属于写入 E2E。

## 定向检查

| 范围 | 结果及日志 |
| --- | --- |
| 布局模型、偏好控制器、SharedPreferences、实际自定义工具栏、设置页 | 最终 26 项通过；覆盖两区排序、能力过滤、各种容量不丢失动作、窄屏溢出、默认恢复、重新初始化、保存／读取失败恢复、拖动及真实读屏节点 tap、2× 字号滚动、8 张新 Golden 非更新比较；`.buildlog/editor-toolbar-layout-new-final.log` |
| 上述新增测试及旧工具栏、格式策略、回复空块草稿／重开 | 8 个有效文件共 67 项通过，原默认 Golden 不变；该次命令另误列不存在的 `editor_history_test.dart`，因此整条命令退出 1，不记作命令成功；`.buildlog/editor-toolbar-layout-targeted.log` |
| 纠正历史测试路径 | 正确 `editor_toolbar_history_test.dart` 2 项通过，覆盖分隔线重做最终选区和等长表情替换选区；`.buildlog/editor-toolbar-layout-history.log` |
| 账号设置入口及布局 | 定向名称 `账号设置` 17 项通过；宽度基线 6 项非更新对比通过；`.buildlog/editor-toolbar-settings-entry-compare.log`、`.buildlog/editor-toolbar-settings-width-compare.log` |
| 改动文件静态分析 | 20 个 Dart 文件首轮仅测试集合写法 1 条 info，修正后对 5 个最后调整文件补析为 No issues found；其余 15 文件无问题。日志 `.buildlog/editor-toolbar-layout-final-analyze.log`、`.buildlog/editor-toolbar-layout-final-followup-analyze.log` |
| 格式、差异、文件规模 | 20 个改动 Dart 文件格式检查零变化，`git diff --check` 通过，未超出 900 行边界 |

最初开发期的编译变量遮蔽、import 排序、过时拖动回调及读屏测试节点／句柄释放问题已修正，原失败日志保留。不同轮次的测试数有重叠，不相加冒充独立覆盖总数。

前一列表隐藏切片 `7a4298040f54b006fccb82720ee093a27ac056c9` 的列表兼容专项 486 项通过；随后 `2f2180af1a4ef114b72fb189b8f6b4027c4a7448` 修正 Golden fixture 缺少 `onInsertSticker` 的问题，应用中的表情包从未删除。上述历史检查不冒充本次布局扩展后的完整检查。

## 离线画面

以下实际 Widget Golden 已逐张查看，未见裁切或溢出。自定义设置与工具栏使用同一配置，表情回调已启用；列表及未实现音频无入口。设置长图是便于查看两区的局部候选，不是真机截图。

| 视口与字号 | 自定义工具栏及展开栏 | 同一配置的偏好页 |
| --- | --- | --- |
| 320dp，亮色，工具栏 2×／设置 1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_320_light.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_320_light.png) |
| 320dp，暗色，工具栏 2×／设置 1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_320_dark.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_320_dark.png) |
| 360dp，亮色，1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_360_light.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_360_light.png) |
| 360dp，暗色，1× | [工具栏](../../test/features/editor/goldens/editor_custom_toolbar_360_dark.png) | [偏好](../../test/features/settings/goldens/editor_toolbar_settings_360_dark.png) |

工具栏截图 360dp 高，偏好长图 1100dp 高。设置页另有 320dp、800dp 高、2× 字号明暗滚动与分组移动测试。

原默认对照保持：[360 亮](../../test/features/editor/goldens/editor_more_tray_360_light.png)、[360 暗](../../test/features/editor/goldens/editor_more_tray_360_dark.png)、[320 亮 2×](../../test/features/editor/goldens/editor_more_tray_320_light_2x.png)、[320 暗 2×](../../test/features/editor/goldens/editor_more_tray_320_dark_2x.png)。账号设置因增加“编辑器工具栏”一行，更新其 8 张明暗／宽度基线，原资料编辑页 Golden 字节不变；代表画面为[360 亮](../../test/features/users/goldens/account_settings_light_360.png)和[320 暗 2×](../../test/features/users/goldens/account_settings_320_2x_dark.png)。

本次关键应用源码 SHA-256：

- `editor_toolbar_layout.dart`：`1076f3c5daa67f57444e6fbcec3dbcfd670cb32ea01c8eb77925891a45af00e2`。
- `editor_toolbar_preference.dart`：`c8fe907d6f5cd4e1288e2795194b25e6b1050501517f0fc9d06bce3027d4e422`。
- `editor_toolbar.dart`：`361a451b52b5cbd394e22cdff476ff4e1f6064be551ce0697a5ecf8c9fd54f9b`。
- `editor_more_tray.dart`：`0ef6a1ef3c27b81763c74447fc59647097f44a9bcd266331084ef385336daf2d`。
- `editor_toolbar_settings_page.dart`：`594b07f265abb11cdb0d57548080d6fbe5a5b5466156040721f9dcc67f332719`。

## 待负责人验收

1. 从偏好进入工具栏设置，跨组移动、重排，打开编辑器并展开工具栏；返回页面和重启 App 后确认顺序保留，恢复默认后重启仍为默认。
2. 明暗主题、窄屏及大字号下检查主栏、展开栏、拖动与菜单观感；确认表情包可用，工具不因主栏空间不足丢失。
3. 打开已有列表正文并编辑、保存、重开，确认原列表语义保留。真实业务写入由负责人手动执行，自动化仅用离线 Fake Repository。

未覆盖真机软键盘、系统读屏及负责人实际历史帖子；离线 Golden 和语义断言不能代替人工验收。本候选不声称已验收或可合并，未合并、部署、安装或接管手机。
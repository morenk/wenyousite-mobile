# 自定义字体楼层定位候选

状态：原问题未通过验收／继续排查。既有候选未合并、未发布。

## 原始反馈与范围

负责人反馈：使用自定义字体的楼层跳转一直“定位中”；任何楼层都可能触发，通知、最新回复、最近动态和发布后的自动定位均受影响。预期是显现目标楼层并允许阅读。

本轮仅修改 Windows Mobile 的共享 `DiscussionTargetCover`，不修改 Backend、Web、Foundation、字体下载策略、API、权限或存储。通知等入口最终复用目标楼层的阅读遮罩；编号定位和楼中楼也使用同一组件。

原设备、帖子正文和具体字体未取得，ADB 未发现设备。离线回归证实的是同类阻塞机制，尚不能断言这是负责人原场景的唯一原因；通知、动态、最新回复及发布后的完整真机路径仍待复验。

## 新增反馈：公开与私密差异

负责人补充：公开帖能够正确定位，私密帖不能。当前尚未确认反馈来自正式应用还是 `15002657` Debug 候选；这一差异不支持仅用此前“字体重排持续刷新等待”解释全部原问题。此前回归与 APK 记录仅证明各自已覆盖的场景，不能覆盖本次私密帖失败反馈。

沿用同一任务、Worktree、分支和 PR #124 继续排查；先增加同一账号、同一内容、公开／私密、单／多子贴和普通／自定义字体的对照，再根据实际失败状态确定修复。原私密帖 ID 与目标状态仍待取得，不读取或保存私密正文。

新增 `thread_private_target_navigation_test.dart` 在同一模拟成员登录态下完成公开／私密 × 单／多子贴 × 普通／自定义字体的 8 组真实页面定位对照，并增加楼主长子贴正文前置的公开／私密与普通／自定义字体 4 组对照，共 12 组全部通过。私密主题、目标楼层与所属子贴均用本地模型提供，因此此结果只说明这些已覆盖的客户端分支可完成定位，不能证明真实私密帖的鉴权请求、内容数据和入口状态正常，也不是复现旧问题的回归。

本轮没有新增应用修复，没有重建或替换 `15002657` APK；其应用 `lib` tree 与历史制品证据保持不变。仍需取得无法定位的私密帖链接／ID、目标楼层与实际使用版本；可据此检查目标查询、所属子贴、窗口与页面布局的实际差异。

## 已证实缺陷与候选行为

字体片段异步更新可以改变其他楼层的高度和整个列表的滚动范围。原实现收到重新对齐回调时，无条件取消 180ms 稳定计时；即使目标楼层的矩形完全没有变化，也会重启计时或中断正在进行的淡出。持续的列表范围变化会使目标已经对齐仍无法显现。

候选实现复用目标矩形的 1dp 稳定容差：目标未变化时保留原稳定计时和淡出；目标位置或大小真正变化时仍重新等待。没有添加超时强行揭开、移除定位保护或改动字体加载协议。

`discussion_font_target_stability_test.dart` 使用真实 Markdown、TextFontScope 和滚动布局，以受控运行时模拟字体度量变化；后续楼层每 100ms 改变字体度量，目标矩形保持不变。原实现在 1.5 秒连续变化后遮罩仍存在，候选实现移除遮罩。模拟度量更新不等于重放负责人原帖或实际字体下载。

## 基线与验证

- Worktree：`D:/codex-worktrees/mobile-font-floor-jump-20261025/wenyousite-mobile`。
- 分支：`codex/20261025-font-floor-jump`，从 fetch 后 `origin/dev@6601eea9` 创建。
- 已提交契约：Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`，API `5.44.0-dev.20261024.3`；本轮 `/meta` 与只读镜像 `origin/dev` 一致，没有契约变化。
- 验证与制品的结果见下方候选记录。普通低风险展示状态修复采用定向测试、全量静态分析及独立 Debug APK；完整 `npm run check` 在负责人验收后、合并前执行。

## 候选检查记录

- 应用 `lib` tree：`58b62e4152d055daf9a576bbe314ff667cb5c236`。
- `candidate:apk` 的全仓格式检查、应用与生成 API 客户端全量静态分析通过，静态问题为 0。
- 同次定向测试 134 项通过；`docs:check`（23 个模块）、`architecture:check` 与 diff 空白检查通过。
- 最终回归在原实现上失败的原始日志：Worktree 内 `.font-stability-baseline-final.log`；同次候选检查日志：`.font-floor-candidate.log`。
- 自查确认目标切换、真正尺寸变化、取消动画和销毁保护保留；代码只修改共享定位遮罩。候选未运行线上业务写入或写入 E2E。

同次候选入口实际执行以下测试文件，测试并发为 2：

- `test/core/widgets/discussion_font_target_stability_test.dart`
- `test/core/widgets/discussion_target_transition_test.dart`
- `test/core/widgets/discussion_target_cover_test.dart`
- `test/core/widgets/discussion_target_seek_test.dart`
- `test/core/widgets/discussion_target_start_test.dart`
- `test/core/widgets/text_font_render_scope_test.dart`
- `test/core/widgets/discussion_number_sheet_test.dart`
- `test/features/posts/discussion_number_page_test.dart`
- `test/features/threads/thread_font_target_navigation_test.dart`
- `test/features/threads/thread_detail_page_test.dart`

## 独立 APK

- `candidate:apk` 同次检查与构建退出 0。
- 包名 `site.wenyou.app.debug`，版本 `0.11.0-debug`／101，仅 `arm64-v8a`；已用 Android `aapt` 核对。
- 路径：`D:/codex-worktrees/mobile-font-floor-jump-20261025/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 大小：114340225 bytes。
- SHA-256：`d7a0c85f0c47deb7459ac132cbae28a5f2b8b902169cba18a8d1df22a7b5a415`，构建入口输出与独立重新计算一致。
- 没有连接设备，本轮没有 ADB 安装、设备内摘要核验或真机验收；未更新正式应用。

## 负责人真机复验

1. 使用本轮 Debug 候选，核对应用包名 `site.wenyou.app.debug`；正式包 `site.wenyou.app` 不会因安装 Debug 包而更新。
2. 在原来卡住的自定义字体帖子上，分别从通知、最新回复、最近动态进入，并尝试编号跳转；确认遮罩退出、目标正文可读，且目标楼层号正确。
3. 分别验证字体已缓存与冷加载；字体加载期间目标位置保持合理，其他楼层字体变化不阻塞本次定位。
4. 由负责人自行执行一次发布后的自动定位；代理没有在真实环境自动创建内容。
5. 验证楼中楼定位、返回刚才、目标已删除、关闭页面及重新进入。字体真正改变目标尺寸时仍应重新对齐，不能提前揭开。

自动测试、构建和本机检查不替代本节验收。没有负责人明确通过前保持“候选／待验收”。

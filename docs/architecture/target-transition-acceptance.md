# 精准楼层跳转过渡验收

## 范围与基线

2026-09-27 开发反馈候选，待负责人观察真机效果。原反馈是通知、传送门跳到对应楼层时遮罩简陋；本次完善等待、内容显现和落点提示，不改变目标归属校验、cursor 分页、滚动对齐、返回栈或权限。

任务分支 `codex/20260927-target-transition` 从最新 `origin/dev` 创建并整合当前主页预览分支，保留图片首帧定位修复和已调整的个人区布局。整合基线 `b047a89f`；没有合并到 `dev`。Foundation 重新 fetch 正式 tags，最新仍为 `v7.2.0` / `a6f4e2d`，与锁文件一致。阅读其 motion、feedback、accessibility、Flutter profile 及 CHANGELOG；不创建并行视觉规范。

Backend 记录与公网 `/meta` 均为 `124fb4e8` / OpenAPI `5.26.0-dev.20260922.3`，远端 `dev` 为 `144a1958`，契约版本未变化，本次不修改 API 或同步生成客户端。

## 当前行为

- 等待区使用两张讨论结构骨架（头像、作者和正文行）、一次定位提示及一条不表示百分比的细进度指示。颜色、间距、卡片圆角、字体和语义图标取自 Foundation 与现有共享组件。
- 保留真实目标完成布局后的稳定检查；通过后使用 `WenyouFoundationMotion.standard` 与标准曲线淡出不透明阅读遮罩。正文不位移、不缩放，自动定位结束前不接收点击、键盘焦点或读屏访问。
- 过渡结束后恢复阅读交互并播报定位完成，目标卡边框此时才开始原有短暂停留及淡出。
- 过渡期间换坐标、出现错误或目标重新对齐会取消旧动画并恢复不透明遮罩；旧完成回调不能揭开新目标。超过约 5 秒继续提供慢等待提示和返回；失败／目标不可见沿用原上下文与重试。
- 减少动画时无循环进度动画，骨架静止且稳定后直接显现；运行时切换该设置也生效。

## 验证记录

2026-09-27 以下 11 个文件共 177 项测试全部通过（使用 `flutter test --no-pub`，最终运行未启用 `--update-goldens`）：

- `test/core/widgets/discussion_target_transition_test.dart`
- `test/core/widgets/wenyou_transient_target_frame_test.dart`
- `test/core/widgets/discussion_target_cover_test.dart`
- `test/core/widgets/discussion_target_start_test.dart`
- `test/core/widgets/discussion_target_seek_test.dart`
- `test/features/threads/thread_target_start_page_test.dart`
- `test/features/threads/thread_detail_page_test.dart`
- `test/features/posts/post_replies_page_test.dart`
- `test/features/posts/post_replies_target_geometry_test.dart`
- `test/core/widgets/image_gallery_gestures_test.dart`
- `test/features/media/reading_gallery_page_test.dart`

新增回归覆盖过渡中的语义／操作隔离、稳定位置、切换坐标取消、失败恢复、运行时减少动画、销毁时取消回调，以及目标高亮延迟到揭开后开始。四张等待态 Golden 覆盖 360dp 明暗、320dp 两倍字号，均已目视复核。

主题已有六张 Golden 同步上一轮已实现的分页末尾短文案，其中长文截图同时同步滚动条显示；差异局限于末尾文案及滚动条，没有调整正文排版。已有“当前子贴目标”测试错误地要求缓存中的正文 Widget 不存在；在本次实现前的 `b047a89f` 精确复跑也失败，现改为验证正文不在目标阅读视口内，保留完整列表缓存语义。

全仓应用和生成 API 静态分析零问题；模块文档、架构、`git diff --check` 通过，契约与依赖文件无漂移。自动检查不代替负责人真机验收；最终应用源码合并前仍须执行完整集成门禁。

## 持续 Debug 预览

- 应用源码提交 `c16bd11e3646bf5b0ba59b9f57feba5d24c1102f`，源码摘要 `10bb44b1a9aec2927574b7beae774fe59a6ce9d7db9a42d94ebf4de8c8563fb6`。
- `real-history-preview` / `preview_0bd5ad2bffd8b1c5743c862a`，`site.wenyou.app.debug`，版本 `0.8.0-dev.1+96`。2026-09-27 01:18:39（北京时间）热重启成功，控制器 `source` 与 `loadedSource` 的提交及摘要一致。
- 新分支预览启动时安装 Debug 基础包；安装时间 01:14:01，设备内 APK SHA-256 为 `e2cc4989aacb0e22c349098f50335dfae339bd47257f01fe5bb4cb3075d09c4b`。热重启后的画面以上述源码摘要为准，不能仅用基础 APK 哈希代表。
- 初次热重载请求超时，随后热重启成功；没有清除账号或草稿数据。当前会话继续保留供负责人观察，后续纯视觉反馈继续热重载。
- [草稿 PR #70](https://github.com/morenk/wenyousite-mobile/pull/70) 接续 [主页 UX PR #69](https://github.com/morenk/wenyousite-mobile/pull/69)，未合并、未发布。

## 负责人真机检查

使用 `real-history-preview` 的 `site.wenyou.app.debug`：

1. 从通知打开较远楼层，再从正文传送门进入另一楼层或回复，观察等待区和淡出是否自然、作者与正文开头是否可读。
2. 快速返回后重新点击不同目标，确认没有旧正文闪现、空白闪屏或落点跳动。
3. 较慢加载时确认提示与返回仍可用；可用的失败样例确认重试后能继续定位。
4. 观察目标边框是否在内容显现后出现；滚动后按原逻辑停止自动校正。
5. 黑夜模式、大字号及系统减少动画分别复核；TalkBack 确认遮罩期间不读底层正文。

当前结论：候选／待负责人验收。

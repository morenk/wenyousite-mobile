# 动态一级评论滚动加载候选

状态：候选／待负责人验收。

## 需求与范围

用户要求移动端动态帖的一级评论随向下滚动自动加载，不再提供“加载更多”按钮；楼中楼保持现有展开行为。原实现只有一级评论按钮，主滚动通知仅用于评论目标定位。

本候选只调整动态详情的一级评论分页触发、失败恢复和请求竞争处理。信息流、主题帖、楼中楼、工具箱、API 与依赖版本均不改变。新组件复用共享预取阈值、帧后调度和分页状态组件，不新增常驻说明或到底文案。

## 来源和数据边界

- Windows Worktree：`D:/code/wenyousite/worktrees/mobile-comment-autoload`。
- 分支：`codex/20261013-moment-comment-autoload`。
- 更新后的 `origin/dev` 基线：`65d1bd6fdcb3f6d3a1cc7bd63632a71476c0eff6`。
- 固定后端来源及只读 `/meta` 核对：`b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，契约 `5.36.0-dev.20261005.1`；本次无契约变化。
- 自动测试使用离线 Fake 仓储，不连接业务接口；公网只读取 `/meta`，未登录、签到或写业务数据。
- Auto-review 默认偏好已传递；宿主协作工具不提供实际配置／核验入口，实际审批配置尚未设置／核验。

## 行为和保护

- 实际剩余距离小于共享 480dp 阈值后自动读取下一页；首屏和追加内容不足视口时继续补足，不以 4000dp 缓存预布局作为触发证据。
- 仅主纵向滚动和布局变化触发；并发请求去重，刷新／排序重置代次，迟到结果不追加。输入面板、键盘或覆盖路由期间暂停。
- 正常态没有一级评论按钮；在途保留加载状态。失败保留内容及最后有效分页位置、停止自动尝试，明确重试恢复；刷新失败仍有当前视口即时反馈。
- 排序或刷新首页失败后，旧游标不再使用。失效游标从首页恢复一次，再次失效暂停；无进展或循环游标暂停为可恢复错误。
- 楼中楼的按钮、正序请求和回复分页维持原行为。深链和阅读滑块沿用原协调器，用户主动阅读后不因追加内容跳回目标。

## 自动验证

八个定向测试文件共 92 项通过，包含新增 10 项控制器与 8 项真实页面离线回归。阅读滑块 320／360／400／600dp 双倍字体 Golden 因删除页脚改变总滚动高度而调整了同一归一化位置的正文位置，已逐张检查并在非更新模式通过；其他已有 Golden 未改。实际测试路径包括：

- `test/features/moments/moment_comment_pagination_controller_test.dart`
- `test/features/moments/moment_comment_pagination_page_test.dart`
- `test/features/moments/moment_controllers_test.dart`
- `test/features/moments/moment_repository_test.dart`
- `test/features/moments/moment_comment_target_page_test.dart`
- `test/features/moments/moment_comment_navigation_test.dart`
- `test/features/moments/moment_reading_quick_scroll_test.dart`
- `test/features/moments/moment_pages_test.dart`

应用与生成客户端全量静态分析零问题；全仓 Dart 格式检查 1252 个文件无变化，模块文档检查 23 个模块通过，架构与 `git diff --check` 通过。日志与源码摘要保存在本 Worktree 的 `.artifacts/moment-comment-autoload/`。独立审查提出的排序失败即时反馈、短页成功后重复游标恢复循环两项问题已修正并纳入上述回归。

完整集成门禁在负责人验收通过后、合并前执行。本轮不构建／安装 APK，不启动可能自动签到的真实账号 App；自动断言和已有 Golden 不代表真机验收。

## 负责人真机步骤

1. 打开多页评论动态，向下连续阅读，确认接近底部自动续页、没有一级评论“加载更多”按钮，快滑或阅读滑块停在底部不重复请求。
2. 打开短评论动态，确认不足一屏时补足或自然到底；最后一页没有多余按钮。
3. 分页时断网，确认已加载评论保留，滚动不反复请求；联网点“重试”后继续原位置。
4. 切换正序／倒序、下拉刷新，确认不混入旧排序页；刷新失败能在当前视口看到反馈，恢复后不一直转圈。
5. 展开楼中楼，确认仍按按钮加载；从评论通知进入长评论后继续向下阅读，确认分页和图片变化不拉回旧目标。

真机网络、连续手势、键盘、TalkBack 和负责人的原场景均待验证；尚未合并或发布。

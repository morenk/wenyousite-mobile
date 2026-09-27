# 移动端组件统一修缮与候选验收

## 当前状态与批次边界

2026-09-19：第一批候选已获负责人明确真机验收通过，已整合 dev 的选择控件变更并完成合并前集成验证；线上契约版本检查按下述负责人授权例外处理。工作区为 Windows 独立 Worktree `C:\Users\quhui\.codex\worktrees\component-consistency-1\wenyousite-mobile`，分支 `codex/20260919-component-consistency-1`，从 `origin/dev` 的 `cbd46995` 开始，不包含其他任务尚未提交的下拉框修改。

| 批次 | 内容 | 状态 |
| --- | --- | --- |
| 1 | 确认弹窗、异步按钮、分页反馈 | 负责人验收通过，集成验证完成；线上契约版本检查获明确例外授权 |
| 2 | 底部弹层的标题、关闭、安全区、键盘和滚动框架 | 未开始；第一批验收并获授权合并后推进 |
| 3 | 用户名校验、邮箱字段及错误反馈 | 未开始；第二批验收并获授权合并后推进 |
| 4 | 身份行、等级和时间展示 | 未开始；第三批验收并获授权合并后推进 |

Foundation 已 fetch origin 与 tags，最新正式 Tag 为 `v7.0.0`，与 pubspec 锁定版本一致，读取对应 CHANGELOG、overlay、controls 与 feedback 契约。该 Tag 的 CHANGELOG 仍保留“待发布”文字，按已存在的正式 Tag 核验，不自行更改上游。后端 `origin/dev` 与公网 `/meta` 均为 `602f57324256f358aea27d204937f9e15644f9c7`，契约版本 `5.22.0-dev.20260912.2`；与旧记录 `6fdfa00e` 比较 contracts 和客户端指南无差异，仅通过同步脚本更新来源 revision，生成客户端保持不变。公网 Markdown v5 由既有兼容范围支持。

### 第四批时间规则约束（负责人本轮强调）

负责人明确要求内容时间的日期阶段取消 `HH:mm`：不足 60 秒显示“刚刚”，不足 1 小时显示“X 分钟前”，不足 24 小时显示“X 小时前”，不足 3 天显示“X 天前”；达到 3 天后，同年只显示 `MM-dd`，跨年只显示 `yyyy-MM-dd`。年份按日历年判断，而非距今满一年。未来内容时间同样只显示对应日期；所有比较与显示先转为用户本地时区。

现有 Foundation v7.0.0 的日期回退仍附带 `HH:mm`，与上述新要求不同；第四批须先同步 Foundation 已发布的日期格式能力，再迁移内容调用点，不能误把当前旧格式当作验收预期。现有 `WenyouTimeText` 已把可见文字与完整时间朗读分开；账单、登录记录、草稿等按既有用途保留精确时间。届时覆盖 59／60 秒、59／60 分钟、23／24 小时、3 天前后、本地跨年与未来时间边界，并断言内容日期不含时分。本批未修改时间组件或格式化逻辑。

## 第一批共享入口与行为

- 普通二选一确认使用 `showWenyouConfirmationDialog`；保留文案、Key、确认后的 API 调用、取消结果和根／嵌套 Navigator 设置。删除、撤回、拒绝与丢弃／覆盖内容使用危险操作色；注销前的固定短语输入不变。
- `WenyouAsyncButton` 支持 filled、outlined、text 与 destructive 语义；原 `wenyou_ui.dart` 继续导出既有公开组件，调用方不必迁移 import。加载期保留普通文案尺寸且禁止再次激活，长文案随大字号换行，工具栏 compact 变体只收紧横向留白与图标，最低触控高度保持 48dp；请求、权限及重试仍由原业务控制器负责。
- `WenyouAsyncIconButton` 补充加载播报、独立语义节点与危险语义；业务对象的朗读名称由 semanticLabel／loadingLabel 传入，处理中移除点击语义。角色选中态不被当成普通异步提交替换。
- `WenyouPaginationFooter`／`WenyouLoadMoreControl` 提供 `showEndLabel` 与 `retryLabel`；嵌入区块可以无占位地隐藏结束提示。加载提示允许窄屏换行，失败保留内容且在途禁用重试。自动连续阅读保留原调度，不新增手动加载按钮。
- 动态收藏单独保存 `loadMoreFailure`，只把分页失败交给页尾重试；滚动在失败后不自动重发，显式重试沿用原不透明游标，失效游标仍由原控制器回到首页。移动、取消收藏和刷新失败不冒充分页错误。

## 调用点清单与合理例外

### 确认框：20 处迁移

| 模块／入口 | 迁移内容 |
| --- | --- |
| 私聊会话 | 拒绝请求、撤回消息 |
| 图片选择 | 恢复上次选择、选择失败重新选择；保留非根 Navigator 和遮罩限制 |
| 动态创作 | 删除动态 |
| 楼层／回复 | 删除原楼层或回复、编辑冲突覆盖确认 |
| 账号设置 | 退出其他终端、注销最后确认 |
| 标签管理 | 移除当前主题的标签关联 |
| 主题云草稿 | 删除草稿 |
| 子贴配置／管理 | 放弃修改、删除子贴 |
| 主题创作 | 切换云草稿、本地保存失败后仍然退出 |
| 主题管理 | 放弃未保存修改、删除主题 |
| 邀请／成员 | 生成新邀请、退出玩家、任免协作者 |

已有共享确认调用继续保留。五个原生 AlertDialog 例外按文件、类和方法精确限制：举报表单、打赏表单、剪贴板持久化决策、主题管理冲突选择、动态编辑冲突选择。通用输入 Dialog、内容操作菜单仍由原共享组件承担。

### 异步按钮迁移

- 应用壳：新建收藏夹、全部已读；通知：单条删除。
- 认证／设置／本人资料：重置密码发码、继续注销、退出其他终端、退出当前账号、保存用户名。
- 私聊：接受／拒绝消息请求。
- 草稿／创作：快速保存、空草稿位保存、删除云草稿、发布主题、保存和删除子贴。
- 图片／举报／申诉：确认裁剪、提交举报、进入申诉及提交申诉。
- 社交／收藏：取消拉黑、资料拉黑图标、主题收藏管理、动态收藏管理。
- 标签／主题权限：创建标签、生成新邀请、退出玩家。

成员行中玩家／协作者的两颗按钮具有明确选中态与专属颜色，保留为精确例外；网络图片、上传百分比、消息送达、菜单项及行级忙碌提示不是通用提交按钮，不在本批强行替换。原生圆环预算只收紧，不提高存量基线。

### 分页迁移

动态收藏、动态评论、主题收藏、公开创建／参与／收藏主题、动态搜索、全站楼层搜索、主题内搜索、私信更早消息、钱包流水、主题楼层、独立楼中楼统一消费共享分页反馈。首页、动态主流、通知、私信会话列表、标签主题列表继续使用已有共享入口。

动态评论复用其原瞬时错误面板，因为该状态也承载评论写入失败，不能把所有错误都绑定“加载更多”重试。私聊保留逆序列表及原错误可见条件。主题和用户搜索仍不新增分页能力。不会改变过滤、排序、请求代次、自动预取距离、缓存或存储。

### 受影响文件入口索引

下表记录本批受影响文件的最终共享入口（包括文件内原本已统一并继续保留的调用）；具体迁移与专用例外以上述行为清单为准。

| feature 内路径 | 共享入口 |
| --- | --- |
| [`app_shell/presentation/bookmark_folder_catalog_page.dart`](../../lib/features/app_shell/presentation/bookmark_folder_catalog_page.dart) | 异步图标按钮 |
| [`app_shell/presentation/message_center_page.dart`](../../lib/features/app_shell/presentation/message_center_page.dart) | 异步文字按钮 |
| [`auth/presentation/reset_password_page.dart`](../../lib/features/auth/presentation/reset_password_page.dart) | 异步文字按钮 |
| [`direct_messages/presentation/direct_conversation_page.dart`](../../lib/features/direct_messages/presentation/direct_conversation_page.dart) | 确认、异步文字按钮 |
| [`direct_messages/presentation/direct_conversation_timeline.dart`](../../lib/features/direct_messages/presentation/direct_conversation_timeline.dart) | 分页控件 |
| [`drafts/presentation/content_drafts_sheet.dart`](../../lib/features/drafts/presentation/content_drafts_sheet.dart) | 确认、异步文字按钮 |
| [`media/presentation/editor_image_selection.dart`](../../lib/features/media/presentation/editor_image_selection.dart) | 确认 |
| [`media/presentation/image_crop_dialog.dart`](../../lib/features/media/presentation/image_crop_dialog.dart) | 异步文字按钮 |
| [`moderation/presentation/moderation_appeal_page.dart`](../../lib/features/moderation/presentation/moderation_appeal_page.dart) | 异步文字按钮 |
| [`moments/presentation/moment_bookmark_folder_page.dart`](../../lib/features/moments/presentation/moment_bookmark_folder_page.dart) | 分页控件 |
| [`moments/presentation/moment_compose_page.dart`](../../lib/features/moments/presentation/moment_compose_page.dart) | 确认 |
| [`moments/presentation/moment_detail_page.dart`](../../lib/features/moments/presentation/moment_detail_page.dart) | 确认、分页控件 |
| [`moments/presentation/moment_waterfall_card.dart`](../../lib/features/moments/presentation/moment_waterfall_card.dart) | 异步图标按钮 |
| [`notifications/presentation/notifications_page.dart`](../../lib/features/notifications/presentation/notifications_page.dart) | 确认、异步图标按钮、分页页尾 |
| [`posts/presentation/post_composer_sheet.dart`](../../lib/features/posts/presentation/post_composer_sheet.dart) | 确认 |
| [`posts/presentation/post_discussion_states.dart`](../../lib/features/posts/presentation/post_discussion_states.dart) | 分页控件 |
| [`posts/presentation/post_replies_page.dart`](../../lib/features/posts/presentation/post_replies_page.dart) | 确认 |
| [`reports/presentation/report_widgets.dart`](../../lib/features/reports/presentation/report_widgets.dart) | 异步文字按钮 |
| [`search/presentation/search_page.dart`](../../lib/features/search/presentation/search_page.dart) | 分页页尾 |
| [`search/presentation/thread_post_search_page.dart`](../../lib/features/search/presentation/thread_post_search_page.dart) | 分页页尾 |
| [`settings/presentation/delete_account_page.dart`](../../lib/features/settings/presentation/delete_account_page.dart) | 确认、异步文字按钮 |
| [`settings/presentation/login_sessions_page.dart`](../../lib/features/settings/presentation/login_sessions_page.dart) | 确认、异步文字按钮 |
| [`social/presentation/bookmark_list_page.dart`](../../lib/features/social/presentation/bookmark_list_page.dart) | 异步图标按钮、分页页尾 |
| [`social/presentation/user_relation_actions.dart`](../../lib/features/social/presentation/user_relation_actions.dart) | 确认、异步文字按钮、异步图标按钮 |
| [`social/presentation/user_relation_list_page.dart`](../../lib/features/social/presentation/user_relation_list_page.dart) | 异步文字按钮 |
| [`tags/presentation/thread_tag_management_page.dart`](../../lib/features/tags/presentation/thread_tag_management_page.dart) | 确认、异步文字按钮 |
| [`threads/presentation/remote_thread_drafts_sheet.dart`](../../lib/features/threads/presentation/remote_thread_drafts_sheet.dart) | 确认、异步图标按钮 |
| [`threads/presentation/subthread_editor_page.dart`](../../lib/features/threads/presentation/subthread_editor_page.dart) | 确认、异步图标按钮 |
| [`threads/presentation/subthread_management_page.dart`](../../lib/features/threads/presentation/subthread_management_page.dart) | 确认、异步文字按钮、异步图标按钮 |
| [`threads/presentation/thread_compose_page.dart`](../../lib/features/threads/presentation/thread_compose_page.dart) | 确认、异步文字按钮 |
| [`threads/presentation/thread_detail_sections.dart`](../../lib/features/threads/presentation/thread_detail_sections.dart) | 分页页尾 |
| [`threads/presentation/thread_invitation_controls.dart`](../../lib/features/threads/presentation/thread_invitation_controls.dart) | 确认、异步文字按钮 |
| [`threads/presentation/thread_management_page.dart`](../../lib/features/threads/presentation/thread_management_page.dart) | 确认 |
| [`threads/presentation/thread_member_management_page.dart`](../../lib/features/threads/presentation/thread_member_management_page.dart) | 确认 |
| [`threads/presentation/thread_membership_controls.dart`](../../lib/features/threads/presentation/thread_membership_controls.dart) | 确认、异步文字按钮 |
| [`users/presentation/me_page.dart`](../../lib/features/users/presentation/me_page.dart) | 确认、异步文字按钮 |
| [`users/presentation/me_profile_editor.dart`](../../lib/features/users/presentation/me_profile_editor.dart) | 异步文字按钮 |
| [`users/presentation/public_user_content.dart`](../../lib/features/users/presentation/public_user_content.dart) | 分页页尾 |
| [`wallet/presentation/wallet_page.dart`](../../lib/features/wallet/presentation/wallet_page.dart) | 分页页尾 |

## 回归证据与检查

旧基线已执行并失败：

1. `test/features/posts/post_replies_page_test.dart` 中“删除回复失败保留原内容并展示可诊断错误”：真实页面打开删除回复确认，要求不可逆删除按钮使用 error 色，旧实现返回 null 样式。
2. `test/core/widgets/wenyou_async_button_test.dart` 中“异步按钮在处理期间保留文字宽度且不能再次提交”：旧按钮从 `124×48` 缩为 `60×48`。

候选自查额外记录（未冒充原始基线重放）：`test/features/drafts/content_drafts_sheet_test.dart` 中“320dp 两倍字号快捷保存完整容纳文案”：保留旧 48dp 外层约束时，文案实际高度仅 24dp，低于独立 TextPainter 测得的 39dp；移除外层固定高度，由共享按钮提供最低高度与自适应后，该测试及草稿页全文件 8 项均通过。

新增／扩展验证覆盖：亮暗主题、三种按钮变体、危险色、两倍字号、长文案、48dp、处理中重复点击；确认／取消／系统返回／遮罩、焦点恢复和嵌套 Navigator；分页继续／加载／失败／重试／结束及无占位隐藏；真实动态收藏页的保留卡片、失败后滚动不重发及原游标重试。

组件入口的架构检查使用 Dart AST，禁止新增 feature 原生通用确认框、加载按钮与分页按钮；专用例外精确到类／方法，不放宽文件规模限制。对应工具测试验证拒绝新增、共享入口放行及例外不扩散。

### 实际测试入口

- 完整候选门禁：`npm run check:apk -- -TestConcurrency 2`，包括整个 `test/`、Windows 发布工具测试、全仓格式与 analyze、架构、文档、API 覆盖、契约再生成及 Debug APK。
- 组件精确回归：`test/core/widgets/wenyou_async_button_test.dart`、`wenyou_confirmation_dialog_test.dart`、`wenyou_pagination_test.dart`、`wenyou_ui_test.dart` 和 `test/tool/component_boundaries_test.dart`。
- 页面与状态回归：`test/features/posts/post_replies_page_test.dart`、`test/features/moments/moment_bookmark_list_controller_test.dart`、`moment_bookmark_folder_page_test.dart`；补充执行 `test/features/editor/remote_thread_drafts_sheet_test.dart`、`thread_compose_page_test.dart`、`test/features/social/bookmark_list_page_test.dart` 和 `test/features/drafts/content_drafts_sheet_test.dart`。
- 截图复核：组件两倍字号、消息中心、收藏列表及管理面板（320／390／800dp、亮暗主题、1／2 倍字号）、主题详情的正文／概览／管理者入口。更新项仅为共享按钮尺寸、图标、结束文案与分页留白；创作页使用 compact 变体后继续通过原基线，没有更新正文或发布页截图。
- 第一轮全量回归的 23 个失败分别为截图基线差异、云草稿按钮查找器重复匹配、发布按钮有效主题色断言；已逐项核对及调整。补充回归还发现收藏管理语义节点被并入卡片，已由共享图标按钮建立独立节点，完整收藏页 31 项复核通过。最终门禁结果以以下交付摘要为准。

### 已验收候选的本地验证结果

- 已验收候选源码全量 Flutter 测试：4,506 项通过，1 项跳过。跳过项为 `test/core/diagnostics/diagnostic_live_receipt_test.dart`，仅在显式启用 `WENYOU_VALIDATE_SENTRY` 时验证 Sentry 线上回执，本轮未启用。
- Windows 发布工具测试：18 项全部通过。
- 全仓格式、应用与生成客户端 analyze（零问题）、架构、21 个模块文档、API 覆盖、OpenAPI 校验／再生成一致性及公网兼容性检查均通过。
- 为确认草稿快捷保存的大字号裁切，中间一轮在尚无失败时主动停止；应用修正后已重新完整执行上述门禁，不将中断轮次冒充完成结果。
- `npm run check:apk -- -TestConcurrency 2` 最终退出码 0，完整门禁与同轮 Debug APK 构建成功。

### Debug APK 交付

- 应用源码提交：`e245e07d5dfb949fff396b9e275171b194f95b92`；此前契约来源 chore 为 `dc3e52a4`。后续交付补记仅修改文档，不改变对应源码或 APK。

- 应用 ID：`site.wenyou.app.debug`；APK versionName：`0.7.1-debug`；versionCode：`95`（pubspec 为 `0.7.1+95`，本批未晋级版本）。
- 大小：183,228,110 字节。
- SHA-256：`ed3c5dee8dd2ce1b7f014fcadb0feab1564d5222c40fa7fd77d56192f77fe5e7`。
- 稳定交付文件：`D:/code/wenyousite/artifacts/component-consistency-1-20260919/wenyou-debug-95-ed3c5dee.apk`，复制后重新校验哈希相同。
- 原构建产物：`C:/Users/quhui/.codex/worktrees/component-consistency-1/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 完整日志及旧失败证据：`D:/code/wenyousite/artifacts/component-consistency-1-20260919/`，最终通过日志为 `final-quality-gate.log`。
- 2026-09-19 经负责人明确授权，已通过 `adb install -r` 安装至连接的 Android 真机（型号 `2509FPN0BC`）。安装前核对现有正式／Debug 两个包及候选 applicationId；安装后 `lastUpdateTime=2026-09-19 05:56:56`，设备内 `base.apk` SHA-256 与上述候选完全相同。应打开“温油站 Debug”（`site.wenyou.app.debug`）复验；完整安装证据为同交付目录的 `adb-install-verification.json`。
- 2026-09-19 负责人明确回复“真机验收通过，合并并清理”，对应源码 `e245e07d` 与上述已安装 APK；第一批负责人验收通过。

## 负责人真机验收清单

1. 在对应 Debug 候选中分别打开删除回复、删除动态、删除子贴与云草稿确认：危险色、操作名称一致；取消、返回和遮罩退出均不写入。专用测试内容的删除只在负责人明确确认时执行。
2. 举报提交、用户名保存、退出终端、裁剪确认、发码和发布：处理中按钮不缩窄、不移动、不接受重复点击；失败保留原内容和原恢复入口。
3. 动态收藏、主题收藏、公开资料、三类分页搜索、私信更早消息、流水：继续加载／加载中／失败重试／结束明确；失败保留列表位置与已有数据，嵌入内容不出现多余结束提示。
4. 主题楼层与独立讨论继续自动加载；排序、作者筛选、目标定位和发表入口不受影响。
5. 亮色／黑夜、320–360dp、系统大字号检查确认框和按钮，无截断、溢出、点击区缩小或不可读加载状态。开启 TalkBack 检查处理中播报。
6. 注销、邀请失效、成员权限和私信拒绝涉及真实副作用，仅使用专用测试账号；自动检查使用假仓储，不对共享开发数据批量操作。

第一批已取得负责人明确真机验收通过和合并清理授权；已整合已验收的选择控件变更，重新执行最终源码完整门禁，按下面记录的唯一例外授权合并 PR #44 并清理任务分支。未发布。

## 合并前线上契约变化与负责人例外授权

- 集成期间公网 Backend 从 `602f57324256f358aea27d204937f9e15644f9c7` / `5.22.0-dev.20260912.2` 升级到 `e214fd18637cb10d79576c5ab5a4cf42340fef71` / `5.23.0-dev.20260913.1`，Markdown 仍为 v5。
- 以 JSON 键排序归一化逐项比较 OpenAPI：现有 paths 和 schemas 没有删除或内容变化；只新增两个收藏夹路径、四个重命名／删除 operation 和七个 schema。公网 `GET /threads?limit=1` 返回成功，必需字段与单封面结构保持兼容。完整差异证据保存在交付目录 `backend-additive-contract-review.json`。
- 2026-09-19 负责人明确回复“允许本次契约版本检查例外”，授权范围仅为 PR #44 此次线上契约版本／来源检查；其余完整门禁仍必须通过。使用既有 `-ContinueAfterFailure` 收集全部检查，保留契约检查的失败及非零退出码，不修改或跳过门禁实现。
- 新收藏夹契约与功能继续归属独立 PR #41，本批不引入该任务未验收的功能、不新增 API 覆盖豁免。

### 最终集成验证

- 集成基础为 `origin/dev` 的 `46a31cf558e8c012ac34a296c93d988b83b4bc1f`；保留两批共享行为并解决组合截图差异。
- 精确整合检查：`flutter test --no-pub --update-goldens --concurrency=2 test/features/notifications/notifications_page_test.dart test/features/social/bookmark_list_page_test.dart test/features/threads/thread_detail_page_test.dart`，126 项通过；人工查看通知、收藏大字号暗色和主题概览截图。
- `npm run check -- -TestConcurrency 2 -ContinueAfterFailure` 完整执行：4,519 项 Flutter 测试通过、1 项既有 Sentry 线上回执测试跳过；18 项 Windows 工具测试全部通过。格式、应用与生成客户端静态分析、架构、模块文档、API 覆盖、OpenAPI 校验与客户端再生成一致性均通过。
- 唯一失败为公网契约版本／来源与本地固定来源不一致，命令如实退出 1；按负责人本次明确授权放行，不能标为完整门禁全绿。日志：交付目录 `integration-full-quality-gate.log`。
- 本轮未重新构建或安装 APK；已验收 APK 仍绑定 `e245e07d`，最终集成验证绑定本次合并提交的应用源码。

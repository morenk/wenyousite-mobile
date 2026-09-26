# 移动端体验重构：开发预览与验收

## 范围与状态

2026-09-26 开发反馈批次，任务分支 `codex/20260926-profile-ux-unification`。当前仍待负责人视觉与交互验收，不合并、不发布。

视觉事实源为 Foundation 正式 `v7.2.0`，固定契约仍为 Backend `124fb4e8aa395440f7a2156de98b642ec87f7583` / OpenAPI `5.26.0-dev.20260922.3`。没有接口、成员权限、上传协议或存储迁移。

## 最终行为

- 本人和公开主页保留封面、头像、昵称与简介；本人保留等级进度和明确数值。资料头采用单层表面，空简介不占位，不展示创作统计和重复概览。
- 本人的编辑资料位于头像右侧数据区下方。签名在昵称／等级下面独立左对齐，保留上下留白，不夹在头像和独立大按钮之间。
- 本人统计为关注、粉丝和温油。温油读取现有钱包余额；收藏夹、表情包、油卡单独成组。油卡仍进入原账务路由，入口下不重复余额。公开他人主页不读取私有余额，继续展示公开收到加油。
- 本人内容为主题、动态、参与、回复，默认主题；收藏从独立工具区进入统一收藏页。公开页将动态直接纳入内容标签，参与、回复与收藏仍服从隐私投影。
- 主页标签吸顶，内部列表预留实际标签高度；大字号不使用固定标签高度，不截断统计标签。本人已访问内容继续缓存，刷新保留页面快照。
- 搜索输入与分类固定，结果独立滚动；主题和动态整页创作的提交统一在右上角。待确认与成功后的本机收尾继续原流程，不重复创建。楼层／回复半屏编辑器不改提交位置。
- 修改密码、邮箱、登录终端沿用个人区容器；标签、邀请、导出、用户名与申诉复用共享 Sheet。成员权限管理不调整。
- 通知删除、动态删除、私聊归档、草稿删除使用统一菜单，保留原确认。已关注状态按钮直接打开关系菜单，取消重复更多按钮；等级使用共享徽章。
- 重试统一为“重试”；普通分页结束不占提示行；草稿开关状态、重复表单标题及主题恢复／成功常驻横幅精简。输入约束、权限、覆盖风险、错误和恢复路径保留。

## 负责人反馈约束

负责人已指出首轮真实封面页面布局不合格，重点是编辑按钮、签名与资料区分组。随后明确要求封面、进度条必须保留，不能用删功能代替重排；当前实现已恢复并按此约束继续验证。未将前两轮画面记录为验收通过。

## 开发预览

- 使用 `real-history-preview`，runId 为 `preview_0bd5ad2bffd8b1c5743c862a`，快照时间 `2026-09-26T04:17:55Z`。
- Windows managed Worktree：`D:\codex-worktrees\profile-ux-unification\wenyousite-mobile`。预览连接经批次身份校验，不回落公网。
- Debug 包 `site.wenyou.app.debug`，ARM64 设备 `4b9c39b5`。首次构建因设备已有 build 97、分支 build 96 而安装失败；核对包名后使用保留数据的覆盖安装，未卸载或清数据。后续复用 Flutter machine 热重载。
- 2026-09-26 21:33 初次持续会话就绪，设备 APK SHA-256 `2c737332d89164fdb44e0d7f770903da79846fed6bbb6b5bbfac9c73b61ded08`。此哈希只对应初装包，不能代表后续热重载画面。
- 热重载的具体源码摘要、runId、进程和包更新时间由本机私有 `events.jsonl` 记录；不提交控制 token、真实账号信息或设备私人画面。

## 自动检查

开发反馈的两批直接相关 Flutter 测试分别通过 141 项与 183 项，共 324 项；全量应用静态分析、架构、模块文档检查和 diff 空白检查通过。已目视复核本人主页 360dp 明暗主题、320dp 两倍字号及动态编辑 Golden；自动图像检查不能替代负责人对真实资料页的验收。

最后统一余额失败文案后，补跑 `test/features/wallet/` 全部 29 项通过；动态创作顶栏主操作位置的精确用例通过。最终再次执行全量应用静态分析，零问题；`lib/` 与 `test/` 共 1076 个 Dart 文件格式检查无变更。

当前尚未执行最终完整门禁，也未为这轮持续反馈生成独立候选 APK。依赖同步、预览工具改动和最终 UI 在正式候选前仍须按风险运行 `npm run check:apk`；原初装包不能充当最终源码的候选证据。

- 主页：`test/features/users/me_page_test.dart`、`me_page_visual_test.dart`、`public_user_page_test.dart`、`user_profile_header_test.dart`、`user_profile_header_visual_test.dart`。
- 搜索与创作：`test/features/search/search_page_test.dart`、`test/features/editor/thread_compose_page_test.dart`、`test/features/moments/moment_pages_test.dart`、`moment_pending_page_test.dart`、`moment_bookmark_folder_page_test.dart`。
- 菜单与关系：`test/features/notifications/notifications_page_test.dart`、`test/features/direct_messages/direct_conversation_page_test.dart`、`test/features/social/own_relation_lists_page_test.dart`、`user_relation_list_page_test.dart`、`bookmark_list_page_test.dart`。
- 表单与面板：`test/features/threads/thread_management_page_test.dart`、`thread_export_sheet_test.dart`、`test/features/moderation/moderation_appeal_page_test.dart`、`test/features/settings/change_password_page_test.dart`、`change_email_page_test.dart`、`login_sessions_page_test.dart`、`test/features/drafts/content_drafts_sheet_test.dart`。
- 共享与账务：`test/core/widgets/wenyou_pagination_test.dart`、`test/features/wallet/wallet_page_test.dart`。预览工具全部 29 项回归通过；首次出现临时测试程序文件占用，重跑全部工具回归通过，未放宽目录权限或卸载保护。

## 真机检查

1. 有封面、无封面、长昵称、长签名及两倍字号：封面与进度保留，编辑不与收藏并排，签名与头像分层，工具均可点按。
2. 温油显示本人当前余额，点击温油或油卡进入同一账务页；公开他人页不展示私有余额。
3. 滚动本人／公开主页，标签吸顶时第一条内容不被遮挡；切换动态、主题、参与、回复与隐私允许的收藏，刷新后没有旧账号内容。
4. 搜索长结果后改词或换分类；打开主题／动态创作，软键盘弹出后发布、保存和待确认操作可达。
5. 通知删除、动态删除、关系管理与草稿覆盖逐一取消确认，验证不写入；普通 Sheet 在窄屏和键盘下可滚动到确认入口。
6. 用户确认本批次布局后，再对最终源码运行集成门禁；需要独立安装候选时按风险使用仓库规定入口。持续热重载不等于负责人验收通过。

# 移动端体验重构：开发预览与验收

## 范围与状态

2026-09-26 开发反馈批次，任务分支 `codex/20260926-profile-ux-unification`。当前仍待负责人视觉与交互验收，不合并、不发布。

视觉事实源为 Foundation 正式 `v7.2.0`，固定契约仍为 Backend `124fb4e8aa395440f7a2156de98b642ec87f7583` / OpenAPI `5.26.0-dev.20260922.3`。没有接口、成员权限、上传协议或存储迁移。

## 最终行为

- 本人和公开主页保留封面、头像、昵称与简介；本人保留等级进度和明确数值。资料头采用单层表面，空简介不占位，不展示创作统计和重复概览。
- 本人的编辑资料收纳到账号设置的“账号”分组首项，进入既有 `/me/edit`。主页移除编辑按钮并收紧对应空间；头像嵌入封面的部分不再额外占位，昵称靠近头像，经验数值利用昵称行右侧空间，放不下时自然换行。签名在昵称／等级下面独立左对齐，保留间隔；完整进度条跟随签名，不再为经验数值单独保留底部一行。
- 本人统计为关注、粉丝和温油。温油读取现有钱包余额；收藏夹、表情包、油卡单独成组。油卡仍进入原账务路由，入口下不重复余额。公开他人主页不读取私有余额，继续展示公开收到加油。
- 本人内容为主题、动态、参与、回复，默认主题；收藏从独立工具区进入统一收藏页。公开页将动态直接纳入内容标签，参与、回复与收藏仍服从隐私投影。
- 主页标签吸顶，内部列表预留实际标签高度；大字号不使用固定标签高度，不截断统计标签。本人已访问内容继续缓存，刷新保留页面快照。
- 搜索输入与分类固定，结果独立滚动；主题和动态整页创作的提交统一在右上角。待确认与成功后的本机收尾继续原流程，不重复创建。楼层／回复半屏编辑器不改提交位置。
- 修改密码、邮箱、登录终端沿用个人区容器；标签、邀请、导出、用户名与申诉复用共享 Sheet。成员权限管理不调整。
- 通知删除、动态删除、私聊归档、草稿删除使用统一菜单，保留原确认。关系列表所有状态均保留右侧更多菜单，关注与回关采用紧凑可见表面并保留触控区域；已关注状态也可打开同一菜单。等级使用共享徽章。
- 重试统一为“重试”；普通分页结束不占提示行；草稿开关状态、重复表单标题及主题恢复／成功常驻横幅精简。输入约束、权限、覆盖风险、错误和恢复路径保留。

## 负责人反馈约束

负责人已指出首轮真实封面页面布局不合格，重点是编辑按钮、签名与资料区分组。随后明确要求封面、进度条必须保留，不能用删功能代替重排；当前实现已恢复并按此约束继续验证。负责人进一步指出编辑资料按钮过大，要求完全收纳到设置列表；当前按此要求复用原修改资料页。未将前两轮画面记录为验收通过。

负责人在 22:16 的真实粉丝列表截图中再次指出关注按钮过大、互关行缺少右侧更多菜单。复现路径为“我的 → 粉丝”，对比回关行与互相关注行：前者按钮占据大色块，后者右侧菜单消失。预期是更紧凑的按钮且菜单始终位于行右侧。代码确认固定 96dp 宽／48dp 可见高及 `if (!following)` 条件造成对应现象；该轮继续按候选处理，待负责人复核。

负责人随后在本人资料区截图指出昵称离头像过远，并圈出昵称、签名右侧的大片空白。复现路径为“我的”，使用有封面、短昵称与短签名的资料：头像绘制向上移动 24dp，但旧布局仍保留完整 72dp 高度，产生 32dp 的头像底部至昵称间隔；经验数值还单独占一行。当前移除重叠部分的空占位、收紧统计上下间距，并将经验数值放到昵称行右侧，进度条保留整宽。长昵称、大字号自动换行，签名保持独立间距。该轮为继续排查后的候选，未记录负责人通过。

## 开发预览

- 使用 `real-history-preview`，runId 为 `preview_0bd5ad2bffd8b1c5743c862a`，快照时间 `2026-09-26T04:17:55Z`。
- Windows managed Worktree：`D:\codex-worktrees\profile-ux-unification\wenyousite-mobile`。预览连接经批次身份校验，不回落公网。
- Debug 包 `site.wenyou.app.debug`，ARM64 设备 `4b9c39b5`。首次构建因设备已有 build 97、分支 build 96 而安装失败；核对包名后使用保留数据的覆盖安装，未卸载或清数据。后续复用 Flutter machine 热重载。
- 2026-09-26 21:33 初次持续会话就绪，设备 APK SHA-256 `2c737332d89164fdb44e0d7f770903da79846fed6bbb6b5bbfac9c73b61ded08`。此哈希只对应初装包，不能代表后续热重载画面。
- 热重载的具体源码摘要、runId、进程和包更新时间由本机私有 `events.jsonl` 记录；不提交控制 token、真实账号信息或设备私人画面。
- 资料头空白调整时，22:32 的热重载请求超时，随后 ADB 设备列表为空，22:35 会话转为失败。负责人重新连接手机后恢复同一批次，22:49 会话就绪；已核对实际加载源码 `c052e8b03ac30b625b6316c929f2571d023c218f`，源码摘要 `d03499b3b392609f4a617c825808b119557c6c396ba5fb46efe86407395486e2`，包含头像间距与经验同行调整。
- 本次重建启动仍为 `site.wenyou.app.debug` / `0.8.0-dev.1+96`，设备包更新时间 `2026-09-26 22:48:27`；设备 APK 与本地构建 SHA-256 均为 `0e4fb4808896e8371f7fe546961edb746fcdaed95d058c9d0c9b8f5e32e970b1`。这是持续开发预览的重建证据，未替代正式候选门禁或负责人验收。

## 自动检查

开发反馈的两批直接相关 Flutter 测试分别通过 141 项与 183 项，共 324 项；全量应用静态分析、架构、模块文档检查和 diff 空白检查通过。已目视复核本人主页 360dp 明暗主题、320dp 两倍字号及动态编辑 Golden；自动图像检查不能替代负责人对真实资料页的验收。

统一余额失败文案后，补跑 `test/features/wallet/` 全部 29 项通过；动态创作顶栏主操作位置的精确用例通过。该轮再次执行全量应用静态分析，零问题；`lib/` 与 `test/` 共 1076 个 Dart 文件格式检查无变更。

编辑资料入口继续收纳至设置后，复跑 `me_page_test.dart`、`me_page_visual_test.dart`、`user_profile_header_test.dart`、`user_profile_header_visual_test.dart` 的 71 项已有检查通过；新增设置列表进入原编辑页并返回的用例独立复跑通过。受影响 6 个 Dart 文件静态分析零问题，模块文档检查通过。主页与设置的明暗主题、窄屏及两倍字号 Golden 已更新并目视复核；本轮未重跑全站测试或生成独立候选 APK。

当前尚未执行最终完整门禁，也未为这轮持续反馈生成独立候选 APK。依赖同步、预览工具改动和最终 UI 在正式候选前仍须按风险运行 `npm run check:apk`；原初装包不能充当最终源码的候选证据。

关系列表反馈补充：`own_relation_lists_page_test.dart` 新增按钮紧凑表面／外缘点击、已关注更多菜单、互关更多菜单 3 项精确回归。旧实现分别报告 96dp 宽度超限与两个状态找不到 `more-u`；当前连同 `test/core/widgets/wenyou_async_button_test.dart`、`test/features/social/own_relation_lists_controller_test.dart` 共 47 项通过。核对 32dp 可见高度、48dp 点击区域、回关后菜单右边界稳定、大字号与在途尺寸。受影响 4 个 Dart 文件分析零问题；另启用 `WENYOU_RELATION_SCREENSHOTS=1` 单独运行渲染用例，通过明暗主题、窄屏大字的列表及菜单图像生成，并目视复核普通亮色和两倍字号暗色列表。负责人原场景尚待复核。

资料头空白反馈补充：`user_profile_header_test.dart` 的亮色／黑夜头像间距回归在旧实现下均失败（实际 32dp）；`me_page_visual_test.dart` 的普通字号经验同行回归在数值仍独占底部一行时均失败。最终实现运行 `test/features/users/user_profile_header_test.dart`、`user_profile_header_visual_test.dart`、`me_page_visual_test.dart`、`public_user_page_test.dart`、`me_page_test.dart` 共 89 项通过；断言头像至昵称 8–16dp、经验与昵称同行、签名保留至少 12dp 间隔、签名到进度条 8–12dp。3 个改动 Dart 文件分析零问题，模块文档和 diff 空白检查通过。更新并目视复核 360dp 明暗主页及 320dp 两倍字号 Golden；已重建并恢复真机 Debug 会话，尚未生成经过最终门禁的独立候选，负责人验收仍待反馈。

- 主页：`test/features/users/me_page_test.dart`、`me_page_visual_test.dart`、`public_user_page_test.dart`、`user_profile_header_test.dart`、`user_profile_header_visual_test.dart`。
- 搜索与创作：`test/features/search/search_page_test.dart`、`test/features/editor/thread_compose_page_test.dart`、`test/features/moments/moment_pages_test.dart`、`moment_pending_page_test.dart`、`moment_bookmark_folder_page_test.dart`。
- 菜单与关系：`test/features/notifications/notifications_page_test.dart`、`test/features/direct_messages/direct_conversation_page_test.dart`、`test/features/social/own_relation_lists_page_test.dart`、`user_relation_list_page_test.dart`、`bookmark_list_page_test.dart`。
- 表单与面板：`test/features/threads/thread_management_page_test.dart`、`thread_export_sheet_test.dart`、`test/features/moderation/moderation_appeal_page_test.dart`、`test/features/settings/change_password_page_test.dart`、`change_email_page_test.dart`、`login_sessions_page_test.dart`、`test/features/drafts/content_drafts_sheet_test.dart`。
- 共享与账务：`test/core/widgets/wenyou_pagination_test.dart`、`test/features/wallet/wallet_page_test.dart`。预览工具全部 29 项回归通过；首次出现临时测试程序文件占用，重跑全部工具回归通过，未放宽目录权限或卸载保护。

## 真机检查

1. 有封面、无封面、长昵称、长签名及两倍字号：封面与进度保留，头像与昵称靠近，普通字号经验数值利用昵称右侧空间，空间不足时换行，签名保留独立间距。主页不展示编辑按钮；从设置“账号”首项进入原资料页并可返回，工具均可点按。
2. 温油显示本人当前余额，点击温油或油卡进入同一账务页；公开他人页不展示私有余额。
3. 滚动本人／公开主页，标签吸顶时第一条内容不被遮挡；切换动态、主题、参与、回复与隐私允许的收藏，刷新后没有旧账号内容。
4. 搜索长结果后改词或换分类；打开主题／动态创作，软键盘弹出后发布、保存和待确认操作可达。
5. 通知删除、动态删除、关系管理与草稿覆盖逐一取消确认，验证不写入；普通 Sheet 在窄屏和键盘下可滚动到确认入口。
   关系列表额外核对关注／回关按钮大小、已关注／互相关注右侧菜单及回关前后对齐；菜单中的取消关注、移除粉丝、拉黑与举报仍可达，关闭菜单不改变关系。
6. 用户确认本批次布局后，再对最终源码运行集成门禁；需要独立安装候选时按风险使用仓库规定入口。持续热重载不等于负责人验收通过。

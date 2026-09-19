# 一次性提示重复展示排查与覆盖

日期：2026-09-20。状态：扩展候选／待负责人验收，沿用签到 PR #46。

## 排查边界与结论

扫描 `lib/` 的 SnackBar、一次性回执、状态监听和自动引导入口；重点审查同一个事件因组件重建、重试、导航或前后台恢复再次提示的路径。不将用户主动发起的下一次独立操作按相同文案合并，避免吞掉真实反馈。

只有签到使用 `WenyouReliableSnackBar` 延后回执。普通操作反馈使用替换式短提示，不保存回放队列；关注、主题喜欢/收藏、订阅控制器读取成功消息时清空，草稿面板按消息变化监听且不在重新挂载时立即重放。剪贴板按复制事件去重；通知权限引导保存消费状态；后台通知按基线和指纹判断新事件，失败后重试是未确认展示的恢复逻辑。

本轮额外发现并复现：首次可见同一帧卸载或替换签到宿主时，旧候选丢弃帧后确认，回执可能再次显示；立即替换真实宿主还可使旧回执进入新提示队列，触发关闭非队首 SnackBar 的断言。组件回归和真实签到宿主回归均保留失败记录。候选在非渲染阶段立即确认，在渲染阶段捕获原回执所有者并延后确认，不因提示宿主卸载丢弃已显示事实；旧账号控制器释放后安全忽略迟到回调。

另发现后台通知批次部分成功的问题：第一条平台调用成功、第二条失败后，整批未提交，下一节拍会再次调用第一条。候选仅在当前未提交批次暂存已成功展示的通知键（ID、标题、正文、目标），重试跳过完全相同的已确认项；失败项继续重试，内容变化继续提醒。只保留当前批次仍包含的键，提交成功、停止或新后台周期时清空，迟到成功不写入新周期。原生接口失败但系统可能已经显示的“不确定结果”仍无法证明成功，本轮不承诺消除该平台边界的重复。

## 自动覆盖矩阵

| 同类场景 | 预期与覆盖 |
| --- | --- |
| 零点自动签到、手动检查与恢复事件重叠 | 请求合并；每个实际领取日期最多提示一次 |
| 连续重建、同会话重挂载 | 已显示回执不重播，不重新签到 |
| 首次可见同帧卸载/替换宿主 | 仍消费原回执，不访问已释放的 WidgetRef，不出现队列断言 |
| 渲染阶段回调后宿主卸载 | 帧后安全确认，确认事实不丢失 |
| 根/分支对话框及底部弹层 | 未显示时等待关闭；显示后被打断不重播 |
| 页面 push/pop | 已显示回执不再次弹出 |
| inactive/hidden/paused/resumed 连续切换 | 只保留未显示回执，已显示回执不重播 |
| 多个普通操作消息抢占 | 操作消息优先且只保留最新；待显示签到只展示一次 |
| 滑动关闭、主动隐藏、直接移除、自然超时 | 均不重播，未打断时仍保留 4 秒 |
| 无障碍导航与减少动画 | 上述重建、生命周期、操作抢占、关闭路径逐项复验 |
| 次日、切号、退出与迟到可见回调 | 旧回执不消费新回执，新账号/新日期独立；已释放控制器不抛错 |
| 重复 claimedNow=true、重复确认 | 同日期已消费后不再生成提示，奖励状态仍可查看 |
| 超时后返回已领取、进程重新进入 | 只更新钱包状态，不补播历史奖励 |
| 关注、主题喜欢/收藏、订阅、云草稿成功后重建 | 无历史成功消息重播；用户下一次操作仍正常提示 |
| 剪贴板、权限引导、后台通知与点击 | 复用并执行既有复制事件、消费状态、指纹、在途/迟到结果回归 |
| 后台通知批次部分成功、内容改变和新周期 | 已确认项重试不再显示，失败项继续重试；更新内容、新周期与迟到成功互相隔离 |

## 实际测试路径

- `test/app/app_session_bootstrap_test.dart`
- `test/core/widgets/wenyou_reliable_snack_bar_test.dart`
- `test/core/widgets/wenyou_reliable_snack_bar_interruption_test.dart`
- `test/core/widgets/wenyou_snack_bar_test.dart`、`test/core/widgets/wenyou_snack_bar_visual_test.dart`
- `test/features/wallet/`
- `test/features/social/thread_interaction_actions_test.dart`、`test/features/social/user_relation_actions_test.dart`、`test/features/social/thread_subscription_controls_test.dart`
- `test/features/drafts/content_drafts_sheet_test.dart`
- `test/features/app_shell/clipboard_navigation_prompt_test.dart`、`test/features/app_shell/handled_clipboard_navigation_store_test.dart`、`test/features/app_shell/notification_permission_guidance_test.dart`
- `test/features/app_shell/background_online_poller_test.dart`、`test/features/app_shell/background_online_reminder_coordinator_test.dart`、`test/features/app_shell/background_notification_navigation_test.dart`
- `test/features/app_shell/background_reminder_runtime_test.dart`
- `test/core/diagnostics/`、`test/app/app_router_test.dart`

关注、收藏、订阅和草稿仅补充测试断言，不改变运行时逻辑。实际源码影响限定为签到展示宿主、应用组合层回调、签到回执消费及后台提醒协调器的展示确认；不修改认证、网络、依赖、契约、原生配置或持久化。本轮按普通候选流程执行上述相关测试、全量静态检查与 Debug APK 构建；第一轮完整门禁记录不冒充本轮应用源码的完整门禁；负责人随后明确授权合并清理，当前源码已另行通过最终完整门禁，见签到验收记录。已整合 `origin/dev` 的 `1c46ef44`，冲突仅为历史契约说明，并加跑 `test/core/diagnostics/` 与 `test/app/app_router_test.dart`。

## 真机验收边界

自动回归覆盖上表的可控组合，不等于已验证所有设备与系统时序。仍需负责人在对应新候选包上复验原转点操作，以及快速切页、弹层、前后台、手势关闭与大字号/减少动画。候选身份、SHA-256 和日志见[签到验收记录](checkin-once-acceptance.md)。

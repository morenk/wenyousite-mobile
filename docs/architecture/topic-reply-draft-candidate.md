# 主题内共享回复草稿候选

状态：候选／待负责人验收。用户要求 Web 与移动端同步将回复临时草稿从回复对象改为主题内共享，本记录只涵盖移动端。

## 原问题与复现

原始操作：在 A 楼回复编辑器输入一半，不发表，收起后点 B 楼展开回复框。预期继续看到原文；旧实现按目标保存草稿且各页面各有 Map，实际显示空编辑器。

原始输入未提供，自动回归用「A 楼写到一半\n继续第二段」重现相同操作序列。基线 `d101b198e88e40d8d49a81baa841e9897877ad84` 上新增精确页面回归失败，实际 `\n`，预期完整两段；候选通过。并未冒称取得用户原帖正文或真机录像。

## 行为与边界

- 账号会话内同主题的新楼层/回复共用草稿，本机快照也按账号与主题恢复；正文、富文本、图片、身份保留。跨子贴、楼中楼页和收起重开继续输入，发表指向当前选择。
- 不同主题、账号、编辑已有正文与子贴 BODY 独立。切号关闭旧编辑器、清空会话内存，磁盘仍按账号隔离。
- 明确失败保留草稿并允许换目标；成功清除。结果不明保存原目标、身份、正文和 `clientRequestId`，其他目标在打开编辑器之前被阻断；原入口允许显式重试，不自动发送。
- 旧草稿只在其原入口恢复。普通旧稿在无共享记录时迁移；附件先复制，新记录成功后标记旧记录，部分失败可继续恢复。旧未确认请求单独保留，不覆盖共享稿。无批量扫描、旧附件删除或历史协议清理。

## 验证记录

已运行定向回归：`flutter test test/features/posts/topic_reply_draft_test.dart test/features/posts/post_composer_local_draft_test.dart test/features/posts/post_composer_opening_test.dart test/features/posts/post_identity_composer_lifecycle_test.dart --no-pub --concurrency=2`，18 项通过。

覆盖实际回复对象切换、新目标提交与成功清空、退出页面后的跨子贴富文本恢复、明确失败转目标、结果未确认的磁盘恢复及同请求重试、旧附件复制与中断恢复、不同主题/账号/编辑键、已有正文冲突打开及身份生命周期。后续补充了缺失附件路径保留以及迁移中断后经另一入口补标的回归，纳入最终完整门禁。

首轮 `npm run check:apk -- -TestConcurrency 2` 的 Flutter 全量测试发现 `post_replies_page_test.dart` 中「360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛」仍假设点击后第一帧即为编辑器；新的本机待确认请求核验会先显示准备界面。测试改为先断言准备界面，再等待编辑器，保留原有尺寸、编辑、删除与权限断言，应用源码未因此改动。精确定向复验 `flutter test test/features/posts/post_replies_page_test.dart --plain-name '360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛' --no-pub --concurrency=1`，1 项通过；日志为 Worktree 内 `topic-reply-draft-page-recheck.log`。

同一轮的主题详情页另有 3 项用例未绑定 `pendingMediaFileStoreProvider`（320dp 双倍字号发表、切号清稿、零回复楼层点按回复），新核验提前读取该必要端口，因此测试落入准备失败。正式 App 已在 `production_overrides.dart` 绑定；测试补齐现有内存存储 fixture，切号前后使用同一个 store，未删除业务断言或改变产品逻辑。精确定向复验 `flutter test test/features/threads/thread_detail_page_test.dart --name '320dp 与两倍字号|切号关闭主题详情|登录用户点击零回复' --no-pub --concurrency=1`，3 项通过；日志为 Worktree 内 `topic-reply-draft-thread-recheck.log`。

首轮最终为 5450 通过、1 跳过、5 失败，门禁退出 1，未生成 APK。第 5 项为 `user_facing_copy_test.dart` 的旧式网络文案构造数量约束（新增 3 处使 421 超过 418）；已改为 `PostDraftTargetBlocked` 本机流程异常，由打开界面映射返回原位置的提示，未放宽约束。该受阻界面只保留关闭入口，不能在错误目标重试。唯一跳过项为需显式启用 `WENYOU_VALIDATE_SENTRY` 的在线诊断验收，不在本轮启用。首轮日志为 Worktree 内 `topic-reply-draft-check.log`。

修正后的定向复验：`flutter test test/user_facing_copy_test.dart test/features/posts/topic_reply_draft_test.dart test/features/posts/post_composer_local_draft_test.dart test/features/posts/post_composer_opening_test.dart test/features/posts/post_identity_composer_lifecycle_test.dart --no-pub --concurrency=2`，23 项通过；日志为 Worktree 内 `topic-reply-draft-final-targeted.log`。

第二轮完整入口在测试早期暴露已有 `production_overrides_test.dart` 异步时序问题：端口绑定用例间接自动读取公网 `/meta`，容器销毁后 `StartupController` 才回写，首轮该项未失败。本轮只通过自己的运行会话停止测试，保留 `topic-reply-draft-check-final.log`；测试 fixture 关闭 `StartupController.autoStart`，真实 `metaRepositoryProvider` 及全部必需端口仍逐项验证，不改产品启动代码。`flutter test test/app/production_overrides_test.dart --no-pub --concurrency=1` 5 项通过，未产生 `/meta` 网络启动日志，结果见 `topic-reply-draft-production-bindings-recheck.log`。随后从规定入口重新执行完整检查。

公网 `/meta` 只读核验仍为 Backend `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`、契约 `5.36.0-dev.20261005.1`；已记录来源与受影响契约无变化，本轮无 API / Foundation 契约修改。

## 最终完整门禁与 APK

最终 `npm run check:apk -- -TestConcurrency 2` 退出 0：格式、应用及生成客户端分析、架构、文档、API 覆盖、契约校验和再生成一致性全部通过；Flutter 全量 5455 通过、1 项默认在线诊断跳过、0 失败，Windows 发布工具 49 项通过。Debug APK 在同次门禁中构建成功，完整日志为 `D:\code\wenyousite\worktrees\topic-reply-draft-mobile\topic-reply-draft-check-candidate.log`。应用源码在本次验证后未变化，只补充本记录。

- APK：`D:\code\wenyousite\worktrees\topic-reply-draft-mobile\build\app\outputs\flutter-apk\app-debug.apk`
- `aapt dump badging`：`site.wenyou.app.debug`，`versionName=0.9.0-debug`、`versionCode=99`，`arm64-v8a`；源码版本为 `0.9.0+99`。
- 大小：110643422 bytes。
- SHA-256：`6AB9BF848E1427C58548A86E61CBE8E84CE8E0DDDCBE7CCD12E4F2C952B8E572`。
- 完整检查与 APK 对应本候选提交的应用源码；精确提交 SHA 随 Draft PR 与交付汇总记录。仍为候选／待负责人验收，没有安装、启动、合并或发布。

## 负责人复验

1. 在主题 A 的一个楼层输入含换行、格式与图片的回复，收起，再点另一楼层或楼中楼续写；切换子贴也应保留，收起重开仍在。
2. 确认顶部目标是新对象，发表一次，检查内容只出现在新对象下；再打开同主题回复框应为空。
3. 在不同主题、编辑已有正文及子贴正文打开编辑器，不应带入前述新回复；切换账号后也不应看到其他账号草稿。
4. 发表明确失败后可继续编辑或换对象；超时/服务器错误时换目标会提示返回原位置，回原入口仅显式重试原发表。

未自动启动或安装真实账号 App，避免登录恢复、自动签到或待提交任务写入公网。默认构建 API 为 `https://wenyou.site/api/v1`，它不是隔离测试环境。本任务没有写入 E2E，也无线上业务写入；安装、联网图片上传与最终真机观感待负责人验收。

## 执行环境

Windows Worktree：`D:\code\wenyousite\worktrees\topic-reply-draft-mobile`；任务分支：`codex/20261013-topic-reply-draft-mobile`。父任务传递了 Auto-review 偏好，但本子任务工具无配置入口，实际宿主 `approval_policy=never`；未设置或核验 `auto_review`，不将两者混称。

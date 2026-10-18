# 公共流程重构验收

## 状态与范围

2026-10-19，后续整合候选／待负责人验收。第一批 PR #109 已在 dev（89a18448）验收合并，其结论不延伸至本批。Worktree：D:\codex-worktrees\mobile-shared-flows\wenyousite-mobile；分支 codex/20261019-mobile-shared-flows。仅 Windows 开发，不合并、不发布。

Foundation 已 fetch tags，最新正式版本 v7.5.0 与 pubspec 一致；已读 CHANGELOG，沿用共享主题与控件。Backend 固定来源、只读镜像 origin/dev 与公网只读 /meta 均为 6e00c4031a8f970609eef8cbf6fdefe3e6b12126／5.40.0-dev.20261018.1，无契约升级。未修改 Backend 或生成客户端。

审批默认偏好已传递，实际 Auto-review 配置尚未设置／核验；工具未提供支持的设置入口，实际运行是 never／unrestricted，不把它视为 Auto-review。

## 六类切片与边界

| 类别 | 实际重复与处理边界 | 状态 |
| --- | --- | --- |
| 普通游标分页 | home、tags、moments 列表/收藏及单向评论/回复、social 收藏、users 内容、search 三种分页、notifications 列表、wallet 流水、direct_messages 会话目录共 14 处请求完成/失效游标/失败分支迁入 loadCursorPage；页面保留状态、查询、epoch、写锁、顺序与合并方式 | 定向 94 项通过，候选 |
| 动态 DTO 作者/媒体 | ApiMomentRepository 与 MomentSearchMapper 的相同 DTO 映射 | 后续独立提交 |
| 验证码冷却 | Registration、PasswordRecovery、EmailChange 三套 Timer；只共享计时，不共享业务状态或发送动作 | 后续独立提交 |
| Markdown inline code | content 的精确反引号扫描与 inline_boundary 的闭合判断；不接管完整块解析 | 待实施 |
| 主题/楼层发布协调 | thread_compose_page 与 post_composer_sheet 的附件就绪、flush、发布意图和结束等待；业务写入各自拥有 | 待实施 |
| 编辑冲突选择 | moment_compose_page 与 thread_management_page 的选择弹窗；动作后果与原选项各自保留 | 待实施 |

分页合理保留：首页分类加载、收藏目录/列表双 epoch、搜索各 tab 与 query epoch、通知乐观标记、私聊读取权限/轮询/双向消息窗口、主题/楼层定位讨论窗口均不是通用分页状态机。loadCursorPage 只在当前请求完成时回调，原 ApiFailure 不重映射，40007 恢复由调用者提供。刷新保留内容与失败回退仍由原业务代码决定。现有 mergeUniqueBy 保持已有条目优先；没有统一业务 key 或重排。

附加精确回归：标签列表刷新在途又请求分页，旧实现发出一次旧 cursor 请求（测试预期 0，实际 1）；候选对 Home/Tag/MomentFeed 增加刷新锁；会话目录、钱包流水、个人页和动态详情也补齐刷新锁与旧分页 busy 清理，钱包单独首屏重试使用独立流水世代，个人页按当前 tab 世代识别刷新锁，旧分页晚于刷新成功/失败均不得回写。该场景是审计构造的并发回归，不冒充负责人原始问题。旧实现失败日志 paging-before.log、paging-other-before.log、wallet-before.log 保留（钱包初轮旧实现会等待错误发出的请求而超时，随后改为先断言请求数，精确失败为预期 2、实际 3）。收藏追加按 bookmarkId 去重，保留已有条目优先与原顺序。

## 交叉 PR

未合并 PR 不复制、不 cherry-pick：#108 与 post_composer_sheet 直接交叉；#104 与 moment_compose_page 直接交叉、附件就绪依赖间接交叉；#76 与 markdown_content 直接交叉且新增 MarkdownInlineSource 的范围更广，后续合并需迁移/删除重叠扫描，不能并存两套事实源。#103 的 rich_editor_session 与 #100 的 Codec/语义校验为间接依赖。后续任一先合并，另一方重审相关定向测试和最终源码门禁。

## 验证与交付

实际命令、结果和候选 SHA 在各批检查完成后补录。日志在本任务 .dart_tool/task-evidence/shared-flows（Git 忽略）。没有进行线上写入 E2E，本批尚无负责人真机验收。

分页定向命令：`flutter test --no-pub --concurrency=2 test/core/application/cursor_page_request_test.dart test/features/tags/tag_threads_controller_test.dart test/features/home/home_feed_controller_test.dart test/features/moments/moment_controllers_test.dart test/features/moments/moment_bookmark_list_controller_test.dart test/features/social/bookmark_list_controller_test.dart test/features/users/public_user_controller_test.dart test/features/search/search_controller_test.dart test/features/notifications/notification_controllers_test.dart test/features/wallet/wallet_controllers_test.dart test/features/direct_messages/direct_message_controllers_test.dart`，94 项通过，见 paging-confirmed.log。新增回归覆盖过期成功/失败/40007、刷新失败、重新加载后旧刷新仍悬挂、按收藏 ID 去重。

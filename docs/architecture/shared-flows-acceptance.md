# 公共流程重构验收

## 状态与范围

2026-10-19，后续整合候选／待负责人验收。第一批 PR #109 已在 dev（89a18448）验收合并，其结论不延伸至本批。Worktree：D:\codex-worktrees\mobile-shared-flows\wenyousite-mobile；分支 codex/20261019-mobile-shared-flows。仅 Windows 开发，不合并、不发布。

Foundation 已 fetch tags，最新正式版本 v7.5.0 与 pubspec 一致；已读 CHANGELOG，沿用共享主题与控件。Backend 固定来源、只读镜像 origin/dev 与公网只读 /meta 均为 6e00c4031a8f970609eef8cbf6fdefe3e6b12126／5.40.0-dev.20261018.1，无契约升级。未修改 Backend 或生成客户端。

审批默认偏好已传递，实际 Auto-review 配置尚未设置／核验；工具未提供支持的设置入口，实际运行是 never／unrestricted，不把它视为 Auto-review。

## 六类切片与边界

| 类别 | 实际重复与处理边界 | 状态 |
| --- | --- | --- |
| 普通游标分页 | home、tags、moments 列表/收藏及单向评论/回复、social 收藏、users 内容、search 三种分页、notifications 列表、wallet 流水、direct_messages 会话目录共 14 处请求完成/失效游标/失败分支迁入 loadCursorPage；页面保留状态、查询、epoch、写锁、顺序与合并方式 | 定向 94 项通过，候选 |
| 动态 DTO 作者/媒体 | feature 内 MomentDtoMapper 共用 PostAuthorResponseDto/MomentMediaResponseDto 映射，校验策略保留搜索文案与信息流诊断 | 定向 14 项通过，候选 |
| 验证码冷却 | Registration、PasswordRecovery、EmailChange 共用 ResendCooldown；只共享计时，不共享业务状态或发送动作 | 定向 19 项通过，候选 |
| Markdown inline code | content、alignment 的保护区与 inline_boundary 的闭合判断共用精确反引号扫描；不接管完整块解析 | 定向与真实页面测试通过，候选 |
| 主题/楼层发布协调 | thread_compose_page 与 post_composer_sheet 的附件就绪、flush、发布意图和结束等待；业务写入各自拥有 | 定向与真实页面测试通过，候选 |
| 编辑冲突选择 | moment_compose_page 与 thread_management_page 共用类型化选择弹窗；动作后果与原选项各自保留 | 组件与真实页面测试通过，候选 |

分页合理保留：首页分类加载、收藏目录/列表双 epoch、搜索各 tab 与 query epoch、通知乐观标记、私聊读取权限/轮询/双向消息窗口、主题/楼层定位讨论窗口均不是通用分页状态机。loadCursorPage 只在当前请求完成时回调，原 ApiFailure 不重映射，40007 恢复由调用者提供。刷新保留内容与失败回退仍由原业务代码决定。现有 mergeUniqueBy 保持已有条目优先；没有统一业务 key 或重排。

附加精确回归：标签列表刷新在途又请求分页，旧实现发出一次旧 cursor 请求（测试预期 0，实际 1）；候选对 Home/Tag/MomentFeed 增加刷新锁；会话目录、钱包流水、个人页和动态详情也补齐刷新锁与旧分页 busy 清理，钱包单独首屏重试使用独立流水世代，个人页按当前 tab 世代识别刷新锁，旧分页晚于刷新成功/失败均不得回写。该场景是审计构造的并发回归，不冒充负责人原始问题。旧实现失败日志 paging-before.log、paging-other-before.log、wallet-before.log 保留（钱包初轮旧实现会等待错误发出的请求而超时，随后改为先断言请求数，精确失败为预期 2、实际 3）。收藏追加按 bookmarkId 去重，保留已有条目优先与原顺序。

## 交叉 PR

发布准备的 `ready=false` 分支先于意图检查，避免附件失败取消意图后吞掉失败提示；成功路径编码前后均核对意图和活动作用域。共享函数不分配 clientRequestId，不提交内容、不清草稿。定向覆盖取消、旧世代、flush 失败与异常、作用域失效，真实主题页连点发布只产生一次创建。

未合并 PR 不复制、不 cherry-pick：#108 与 post_composer_sheet 直接交叉；#104 与 moment_compose_page 直接交叉、附件就绪依赖间接交叉；#76 与 markdown_content 直接交叉且新增 MarkdownInlineSource 的范围更广，后续合并需迁移/删除重叠扫描，不能并存两套事实源。#103 的 rich_editor_session 与 #100 的 Codec/语义校验为间接依赖。后续任一先合并，另一方重审相关定向测试和最终源码门禁。

## 验证与交付

冲突弹窗只返回 useLatest、keepCurrent 或取消，不拥有业务写入；保留动态的两按钮与主题的三按钮、原文案和 Key。组件测试覆盖全部选择与返回取消，真实 moment_pages_test.dart、thread_management_page_test.dart 的业务冲突回归包含在 1536 项定向测试内。

实际命令、结果和候选 SHA 见下。日志在本任务 .dart_tool/task-evidence/shared-flows（Git 忽略）。没有进行线上写入 E2E，本批尚无负责人真机验收。

分页定向命令：`flutter test --no-pub --concurrency=2 test/core/application/cursor_page_request_test.dart test/features/tags/tag_threads_controller_test.dart test/features/home/home_feed_controller_test.dart test/features/moments/moment_controllers_test.dart test/features/moments/moment_bookmark_list_controller_test.dart test/features/social/bookmark_list_controller_test.dart test/features/users/public_user_controller_test.dart test/features/search/search_controller_test.dart test/features/notifications/notification_controllers_test.dart test/features/wallet/wallet_controllers_test.dart test/features/direct_messages/direct_message_controllers_test.dart`，94 项通过，见 paging-confirmed.log。新增回归覆盖过期成功/失败/40007、刷新失败、重新加载后旧刷新仍悬挂、按收藏 ID 去重。

DTO 定向：`flutter test --no-pub --concurrency=2 test/features/moments/moment_repository_test.dart test/features/search/search_repository_test.dart`，14 项通过，dto-tests.log。新增用同一 DTO 经真实信息流 repository 与搜索 mapper 验证作者、URL/各图片变体、尺寸、动画及内容类型；不安全 URL 与宽高不成对分别保留 MOMENT_UNSAFE_URL、MOMENT_MEDIA_DIMENSION_MISMATCH 和原搜索错误标签。映射回归现独立为 moment_repository_mapping_test.dart，避免新增手写 part；拆分后已在 additional-final.log 中通过，最终全量会复核。

Markdown 扫描只识别长度完全相同的反引号串闭合，保留转义奇偶性、代码内字面反斜杠及 UTF-16 偏移；未闭合串不遮蔽 HTML。真实帖子页以独立可见文字和 code 属性断言多长度定界符的打开、输入、保存、阅读与重开。编辑器广泛定向测试 1536 项通过（editor-tests.log），追加独立 DTO、真实帖子行内代码、发布准备和主题发布页面测试 34 项通过（additional-final.log）。

已知限制：探针输入如下，旧 dev 基线与候选均未正确恢复行内代码样式，属于既有 Codec 限制，本批未修复；不能用扫描器单测通过代替编辑器语义通过。失败探针及旧基线日志保留在 escaped-code-probe-test.txt、escaped-code-baseline.log 和 additional-tests.log，真实页面已通过的多长度定界符测试不覆盖此限制。

```text
\``<b>`
\```<b>``
```

冷却定向：`flutter test --no-pub --concurrency=2 test/features/auth/registration_controller_test.dart test/features/auth/password_recovery_controller_test.dart test/features/settings/credential_security_controllers_test.dart`，19 项通过，cooldown-tests.log。覆盖冷却到零不自动发送、editEmail/dispose 取消 tick、dispose 后迟到响应不回写、确定失败 Retry-After、429/投递结果不明固定 60 秒与请求编号。注册仅 trim、找回/改邮箱 lowercase+trim、找回 seed、登录/退出与 noAutomaticReplay 保持原业务实现。

编辑器广泛定向实际命令（1536 项通过）：

```powershell
flutter test --no-pub --concurrency=2 test/core/markdown test/core/widgets/wenyou_markdown_inline_code_layout_test.dart test/features/editor/editor_block_boundary_inline_code_test.dart test/features/editor/editor_inline_boundary_input_test.dart test/features/editor/editor_publish_preparation_test.dart test/features/editor/thread_compose_page_test.dart test/features/posts/post_composer_local_draft_test.dart test/features/posts/post_composer_opening_test.dart test/features/posts/post_composer_insertion_test.dart test/features/posts/post_controllers_test.dart test/core/widgets/wenyou_edit_conflict_dialog_test.dart test/features/threads/thread_management_page_test.dart test/features/moments/moment_pages_test.dart
```

补充实际命令（34 项通过）：

```powershell
flutter test --no-pub --concurrency=2 test/features/moments/moment_repository_mapping_test.dart test/features/posts/post_composer_inline_code_test.dart test/features/editor/editor_publish_preparation_test.dart test/features/editor/thread_compose_page_test.dart
```

过程检查如实记录：早期完整 analyze 与广泛测试并行造成内存压力，主动停止，退出 -1，不计为成功；架构初次发现新增手写 part 后已改为独立测试文件，复核通过。首轮完整门禁在静态分析发现六处多行 if 缺花括号后退出 1，日志 check-apk-attempt1.log；c950f00f 补齐代码块，不改变分支语义。最终检查以串行 `npm run check:apk -- -TestConcurrency 2` 的单次结果为准。

## 负责人真机验收清单

2026-10-19 最终完整命令 `npm run check:apk -- -TestConcurrency 2` 退出 0；Flutter **7285 通过／1 条件跳过**，Windows 工具 **49/49 通过**，ARM64 Debug APK 构建成功。完整日志 `D:\codex-worktrees\mobile-shared-flows\wenyousite-mobile\.dart_tool\task-evidence\shared-flows\check-apk.log`，SHA-256：`5DDDFA10C254BF2B3B820DCB013168085E0952956F748A078F9589F16940907B`。构建保留现有 KGP 插件迁移、SDK XML 兼容提示，未修改依赖或 Android 配置。

候选 APK：`D:\codex-worktrees\mobile-shared-flows\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`，112,828,150 字节；aapt 核验包名 `site.wenyou.app.debug`、版本 `0.9.0-debug`、versionCode `99`，仅 `arm64-v8a`。SHA-256：`E6D57B98E9E7D730B81AC02A5E018378E4ACBC4EC6DF8A0AC1044E2218A3D14F`。

构建后 ADB 设备列表为空，目标设备 4b9c39b5 未在线；没有安装、启动或热重载会话，不记录虚构的设备内 APK 哈希与更新时间。候选未传入 API define，沿用默认 `https://wenyou.site/api/v1`；待设备可用后再按保留数据的普通 Debug 入口核验包名与安装摘要。

候选应用源码：`c950f00f7d4d83402b2921e7f6ca7d06387254dc`；lib tree：`6f5686a4f5dec9b01463c63266eadbc79cb44f26`。本地 application-tree.txt 由该提交的 lib、android、packages、assets、pubspec.yaml、pubspec.lock 文件对象清单生成，SHA-256：`73914EA4FDF13E41CB7CD03FE7B00561838A748BB994731FBFE003665402744A`。后续仅验收文档变化沿用该源码证据。

第二轮完整门禁的静态分析、生成客户端分析均零问题，架构检查通过，23 个模块文档完整，移动端 API 范围覆盖 175/175；生成客户端和依赖锁文件无漂移。全量测试中的 diagnostic_live_receipt_test.dart 由既有 WENYOU_VALIDATE_SENTRY 显式开关控制，本轮未开启，不执行线上 Sentry 发送。

本批尚未安装或接管设备，所有项目均待负责人在本批候选验证；PR #109 的验收不替代本批验收。自动化仅组件、状态及只读契约核验，未执行线上写入 E2E。

1. 首页、标签、动态、收藏、搜索和个人内容：滚动加载更多、下拉刷新、失败重试；刷新在途不追加旧列表，收藏无重复、既有顺序保持。会话目录与钱包流水检查相同行为。
2. 同一动态在信息流与搜索核对作者、头像、封面及图片比例、动画类型；进入详情后的媒体一致。
3. 注册、找回密码、更换邮箱：发送后冷却到零再手动发送；返回、改邮箱或离开页面后无残留计时，失败文案及可重试时机保持。
4. 行内代码：已有多长度反引号内容打开、输入、保存、阅读和重开，逐字文字及样式保持；记录中的转义邻接限制不宣称已修复。
5. 主题与楼层：图片仍在准备时发布，连点不重复创建；取消等待、图片失败、重试后必须再次明确发布；成功后正确清理草稿，失败保留正文。
6. 动态和主题编辑遇到版本冲突：分别核对载入最新、保留当前／覆盖及取消；选择前不写入，取消不丢失当前正文。

## 安装与合并授权

2026-10-19，按负责人要求直接执行 `adb install -r` 覆盖安装本候选，ADB 返回 `Success`，未卸载应用或清除数据。随后负责人明确要求“合并清理分支”，据此结束本任务候选保留阶段并推进 PR #110 合并及任务分支、临时 Worktree 清理；不推定未提供的逐项手测结果，已知 Codec 限制继续保留。

应用源码与完整门禁对应版本未变。清理前将 APK、验收文档和本轮检查日志保存在 `D:\codex-task-evidence\wenyousite-mobile\20261019-pr110`；合并与清理结果另存该目录，不部署、不发布。

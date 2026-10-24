# 楼中楼恢复前台保位候选

状态：候选／待负责人验收。治理 chat `01a16e35-9e1e-7841-afb6-e7e3bbb3217d`，实现子 agent `investigate_replies_resume`。

## 原问题与已证实链

原操作：在独立楼中楼读到第 14 条附近，切到其他应用再返回，页面重新加载并回到顶部。期望停留在原回复和条目内位置。原手机系统版本、安装包源码身份、后台时长及进程是否被系统回收尚无日志证据，未声称原手机已复现或修复完成。

已提交基线 `8ab9f1bdb031290d89d6e093177b0ecb6a680fa4` 已存在以下链：`StartupGate.resumed → recheckForUpdate → 新 ContractInfo → 新 AppCapabilities → ApiPostRepository → PostDiscussionController`。仓库观察整个能力对象，而不是实际使用字段；同值响应也重建仓库。新讨论控制器从 loading、正序、全部作者、空窗口加载，列表被骨架替换，阅读锚点被清掉。列表只有普通 Key，重新挂载的 ScrollPosition 使用默认 0。当前回复底栏与相册候选未引入该链。

## 修复与边界

仅在 `apiPostRepositoryProvider` 使用值相等的四布尔字段 record/select：角色提及、字体 v1、字体 v2、文字颜色。相同及无关元信息不更换帖子仓库，保留讨论控制器、所有已加载窗口、筛选及阅读锚点。真实四项能力变化继续更新新写入配置；登录退出、切号、会话失效及可见性变化继续失效旧内容。

不修改启动或会话实现、HTTP 协议、权限、依赖、原生配置、相册与回复底栏，不新增跨进程阅读进度。保留更新检查与强制升级门禁。四项能力真正变化仍可能重建讨论；这是本轮最小修复的明确边界。

本分支从 dev 独立，候选 APK 仅带楼中楼保位改动，不含相册 PR #117。两份候选可能使用相同 `site.wenyou.app.debug` 和 versionCode `100`，必须按源码与 APK SHA-256 区分，不据包名或 versionCode 宣称已经集成。

## 事实源、风险与授权

- Worktree：`D:\codex-worktrees\mobile-replies-resume-20261025\wenyousite-mobile`；分支 `codex/20261025-mobile-replies-resume`，从已更新 origin/dev 创建。
- 本地契约来源 Backend `31f39ff317e56d6eb49b4c5e60ecdb93dfc9ec06`，API `5.44.0-dev.20261024.2`。本轮只读 `/meta` 为 `33574ae73d88123aa216a93f9cc81eab60fb9ee9`、同 API、Markdown 5；本地 metadata 中 markdownContractVersion=4 是固定来源记录，客户端仍支持 v3/v4/v5/v6。Backend 两 SHA 的整个 contracts 目录零 diff，本轮未同步契约或生成客户端。完整集成门禁的部署 SHA 精确检查仍需按当时部署来源同步后执行。
- 中风险阅读生命周期 Bug：生产变更限于一个 feature 仓库 provider 依赖，不改变认证或网络实现；可收窄到精确与直接受影响回归、全量静态分析及独立 Debug APK。完整 `npm run check` 留在负责人验收后、合并前执行。
- Auto-review 默认偏好已传递；本子 agent 宿主实际为 `approval_policy=never`、unrestricted，工具无审批设置入口，未设置/核验 Auto-review，不声称已启用。
- 测试外部 I/O 使用内存/fake Dio，无真实登录、签到、创建或设备控制。未安装、自动启动真实 App、上传 APK、合并或部署。

## 验证证据

- 旧实现对照：生产代码仍为基线时，新增真实装配用例先加载 40 条、停在 `reply-14` 中段，`paused/resumed` 接收同值新元信息后书签变为 null；预期 `reply-14` 的断言失败。日志：Worktree 下 `build/replies-resume-evidence/old-implementation.log`。编译或夹具调试失败不计作原因反证。
- 最小候选：新增 `test/features/posts/post_replies_resume_test.dart` 的 14 项全部通过；使用生产 provider 装配、真实 `StartupGate`、元信息控制器、能力映射和生成客户端，只替换内存传输、会话及设备 I/O，不覆盖 `postRepositoryProvider`。360×800 阅读页断言当前 ID、条目内偏移（1px 内）、同 controller/已加载窗口、无 loading 阶段或额外首屏请求。数字跳转等待揭罩和前向补页后继续手势阅读，停下惯性再模拟恢复，保留“回到刚才”。能力测试显式允许的创建仅到内存 adapter，无真实写入。
- 同时覆盖倒序/作者筛选、深链之后继续阅读、meta 慢/失败/无关能力变化、同账号 Token 轮换、切号/退出/会话失效、旧账号迟到首屏、可见性失效，以及四种真实能力开关进入生成创建载荷。
- 生产变更仅 `lib/features/posts/data/post_repository.dart`，最终文件 SHA-256：`37a73d04c75e20ea0be355f04215da8c54182b6a8b6374854c397860dab23823`。其余应用源码、配置及依赖与基线一致。SDK Flutter 3.44.8 / Dart 3.12.2。
- `dart run tool/check_architecture.dart`、`dart run tool/check_docs.dart` 及 `git diff --check` 通过；日志分别为 `architecture-check.log`、`docs-check.log`，同在上述证据目录。架构检查仅提示存量超过 700 行文件的下次评审提醒，未产生新债务。
- `candidate:apk` 全流程退出码 0：全仓格式、应用与生成客户端全量静态分析均零问题；以下 14 个测试文件共 **175 项全部通过**（含新增 14 项）；ARM64 Debug 构建成功，Gradle 阶段 182.1 秒。主日志 `candidate-apk.log`，SHA-256 `1bb0579ddf2678b8715f7f872eae87ee408820eec6a6279ba21a7f0bfce3a7fc`；旧失败日志 SHA-256 `65076de5b502f39ccda60e9e1f2baf82fcae5c4e03ef247b303b191b9adda8f1`。

```text
test/features/posts/post_replies_resume_test.dart
test/features/posts/post_replies_page_test.dart
test/features/posts/post_controllers_test.dart
test/features/posts/post_repository_test.dart
test/features/posts/discussion_window_controller_test.dart
test/features/posts/discussion_number_page_test.dart
test/features/posts/post_replies_target_geometry_test.dart
test/features/posts/post_reply_visibility_stack_test.dart
test/features/posts/post_identity_composer_lifecycle_test.dart
test/features/posts/post_thread_context_ports_test.dart
test/app_shell_test.dart
test/core/network/session_controller_test.dart
test/app/production_overrides_test.dart
test/app/visibility_cache_invalidation_test.dart
```

执行入口为 `npm run candidate:apk -- <上述路径> -TestConcurrency 1`。完整门禁、原手机复验和部署精确来源核验不以候选定向检查代替。

## 独立 APK

- 稳定副本：`D:\codex-worktrees\mobile-replies-resume-20261025\wenyousite-mobile\build\replies-resume-evidence\wenyousite-debug-replies-resume-302ec97f1daa.apk`。原输出 `build/app/outputs/flutter-apk/app-debug.apk` 与副本复核同哈希。
- SHA-256：`302ec97f1daa4a27fbd7d260813df7865e8f54a741a627fc662d7817ccc13c73`；大小 `113702830` bytes。
- `aapt dump badging`：包名 `site.wenyou.app.debug`，应用名“温油站 Debug”，versionName `0.10.0-debug`，versionCode `100`，ABI 仅 `arm64-v8a`。源 pubspec 为 `0.10.0+100`，本轮未改版本。
- `apksigner verify --verbose --print-certs` 通过：APK Signature Scheme v2、1 位 Android Debug 签名；证书 SHA-256 `a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7`。日志 `apk-badging.log`、`apk-signature.log` 与主日志同目录。
- 未安装、启动、上传或发布；由负责人在确认目标 Debug 包后手动验收。APK 运行默认 API 为 `https://wenyou.site/api/v1`，按真实环境保护，不是隔离测试包。

## 负责人真机清单

1. 在独立讨论读到第 14 条正文中段，切应用后立即返回及较长后台后返回，检查位置、排序与作者筛选保留；应用进程仍存活的结果与系统回收后冷启动分开记录。
2. 多页讨论、倒序与单作者筛选；分别从深链及数字跳转进入，继续滑动，再恢复前台；不回到原目标，“回到刚才”仍恢复原位置。
3. 断网切回前台后保持内容；恢复网络再切回仍可读。必要更新检查及强制升级正常。
4. 退出、切号、会话失效和权限变化不能继续显示旧账号内容。四项能力变化不承诺保留阅读位置。

原手机复验、实际后台内存回收、TalkBack 及最终合并前完整门禁尚未完成。

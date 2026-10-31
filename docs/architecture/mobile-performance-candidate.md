# 移动端性能候选与验收

状态：候选／待负责人验收。原真机问题尚未复现，不能以自动测试或构建替代负责人复验。

2026-11-01 后续状态：**发布后定位验收失败／继续排查**，Debug 与正式包均反馈卡住。PR #129 已获授权合并，但不代表原问题通过；真实现场已确认定位请求风暴，补修与后续验收见[发布定位候选](mobile-publish-locate-candidate.md)。本记录原 APK、日志已保留到 `D:\codex-artifacts\wenyousite-mobile\51fc1f09`。

## 原始反馈与边界

负责人反馈连续使用后越来越卡；编辑楼层保存后偶尔仍显示旧正文，需要刷新一到两次；重复进入正文时字体迟到；打开编辑器出现“正在读取最新正文”；发表或编辑后定位等待数秒；图片处理等待约十秒。后续补充为 **3 MB 图片实测约 5 秒，并判断部分等待可能来自网络**。尚未取得手机型号、应用版本、原始正文和完整操作序列；不要求私密帖链接或正文，也没有据构造样例断言原场景根因。

本轮仅修改 Windows Mobile 工作树。没有安装或启动真机应用、没有线上写入 E2E、没有修改 Web、Backend 或 Foundation 源码。等待最新正文的权限与版本核验保留；网络上传时间不承诺消除。

## 已证实的实现问题与候选行为

| 代码事实 | 候选行为 | 证据与限制 |
| --- | --- | --- |
| 楼层保存后重新进入目标路由，额外读取目标和默认窗口；旧读取可晚于保存 | 已加载楼层采用保存响应原位更新，保留窗口、光标和内嵌回复，递增请求代次丢弃旧响应；继续后台核验主题权限 | 真实页面连续两次编辑、保存、再打开编辑器测试通过；403 清空正文的控制器测试保留。未代替原手机复现 |
| 新建楼层保存结果已经包含定位坐标 | 复用坐标，只读取目标窗口，避免 GET 同帖和重读默认窗口 | 页面测试明确核对请求序列；楼中楼创建流程不改变 |
| 新页面 owner 复用已解析字体仍使元数据变脏，可等待另一字体下载 | 现有 manifest 身份复用，未知／撤回／淘汰身份继续核验 | 阻塞 B 下载时 A 新片段在 200 ms 测试期限内返回；旧实现超时。真实网络耗时未测量 |
| 字体更新重建同一彩色 Markdown 片段时重复注册链接手势 | 同一 AST 链接复用 recognizer，仍由原阅读组件释放 | 连续 100 次字体 builder 重建：旧实现注册 100 个，候选 1 个 |
| 大字体资产 SHA 校验同步占用 UI isolate | 大于 64 KiB 的相同长度／SHA 校验交给工作 isolate | 小文件及 1 MiB 文件正确、损坏、长度不符测试；不是设备帧率报告 |
| 引擎已生成的规范 PNG 在上传前再次做完整 PNG 编码 | 只对同进程、不可变、尺寸匹配的引擎输出复用编码；恢复文件和外来字节仍完整规范化 | 正式 WebP 类型、大小、像素检查保留；无修改上传协议或质量参数 |
| 加载动画可带动周围静态阅读区域重绘 | 公共进度组件与目标阅读区域设置重绘边界 | 10 次动画帧的静态绘制计数：旧实现从 2 增至 12，候选保持 2；不等于整页零布局或真机零掉帧 |

## 契约与源码边界

- 工作树：`D:\codex-worktrees\5af2\wenyousite-mobile`；任务分支 `codex/20261031-mobile-performance`，起点 `51a5edee6b2864b580e713a6f88f43802d35da7a`。
- Foundation 已 fetch tags，最新正式版本和依赖均为 `v7.6.0`；阅读该版本 CHANGELOG、运动和 Flutter profile。没有新增平行视觉 token。
- 初始后端固定 revision `d54313346681eae8f62584d63d07f3315e42381b`，API `5.44.0-dev.20261024.3`；`origin/dev` 和公网 `/meta` buildSha 均为 `19a6c4ed48829a781182527faaafce6e788e9e2e`，契约及 mobile-client-guide 无差异。完整门禁仍要求来源提交精确匹配，因此用固定同步入口更新来源、重生成并以独立 chore 交付，见[来源核对](backend-contract-source-20261101.md)。没有修改校验条件。
- 当前实际运行权限为 `never`／完整访问，不是 Auto-review；偏好已传递，宿主缺少受支持的配置入口，实际 Auto-review 尚未设置／核验。
- `thread_detail_controller.dart` 超过 700 行，已按职责审查：响应到阅读模型的映射拆为 `thread_saved_post.dart`；请求代次和窗口更新仍归原控制器，不机械使用 part 或扩大文件上限。
- 其他超过 700 行的受影响页面按职责复核：本轮主要为公共加载入口替换和局部时长引用，未新增业务职责；保留既有页面结构，不为机械减行拆散状态生命周期。全部文件继续接受 1200 行硬上限检查。

## 验证记录

旧实现对照使用暂存恢复方式运行新增测试，之后恢复候选源码。工作树日志 `performance-regression-before.log` 记录字体复用、连续编辑、图片不可变复用三项失败；`performance-animation-before.log` 记录链接重复注册和静态区域重绘两项失败。初始候选对应回归通过，后续公共组件迁移后由最终完整门禁重新覆盖。

直接执行路径包括：

- `test/core/text_fonts/`：字体元数据、撤回、窗口、缓存、完整性、下载进度和复用。
- `test/core/widgets/markdown_font_link_lifecycle_test.dart`、`discussion_target_cover_test.dart`、`discussion_target_transition_test.dart`、`wenyou_progress_indicator_test.dart`、`audio_player_interaction_test.dart`。
- `test/features/media/media_upload_normalizer_test.dart`。
- `test/features/editor/editor_font_download_progress_test.dart`：大分片校验采用真实工作 isolate 后，测试等待注册开始边界，继续断言实际进度、组合输入和正文实例保持；没有固定产品延时或测试专用校验旁路。
- `test/features/threads/thread_saved_post_test.dart`、`thread_deleted_target_test.dart`、`thread_detail_page_test.dart`（包含目标分页 cases）。
- `test/tool/check_architecture_test.dart`：原生加载／刷新入口绕过共享边界时失败。

2026-11-01 最终执行 `npm run check:apk -- -TestConcurrency 3`，退出码 0。覆盖 `test/` 全量：Flutter **8147 通过、1 项既有 Sentry 条件跳过、0 失败**；Windows 工具 **49/49**。格式、应用及生成客户端静态分析、架构、23 个模块文档、API 覆盖、契约校验与再生成一致性、公网只读兼容性均通过，同一入口完成 Debug APK 构建。日志为 `performance-full-gate.log`。后续仅补充交付文档，不改变已验证的应用源码。

独立候选身份：

| 项目 | 实际结果 |
| --- | --- |
| 应用／包名 | 温油站 Debug／`site.wenyou.app.debug` |
| APK 版本 | `0.11.0-debug`，versionCode `101`；沿用基线构建号 |
| ABI／最低 Android | 仅 `arm64-v8a`／API 26 |
| 文件 | `D:\codex-worktrees\5af2\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| 大小 | `114365761` bytes |
| SHA-256 | `52AB23D4BBECB0A463554DC1D96AF4F5219217A2CE90D34CCEC881CAE249B75C` |
| 构建时间 | 2026-11-01 01:38:57 +08:00 |
| 签名 | `apksigner verify --verbose` 退出 0，v2 签名通过 |
| 应用源码摘要 | `lib` Git tree：`d99ac8880929e57cb5dcb75b1fff73ab42fcd791` |
| Android 源码摘要 | Git tree：`948213a0815ae4c46530b60cb3ff4c3799605213`，本轮未修改 |
| API | 构建未传入 API define；默认 `https://wenyou.site/api/v1`；未启动候选应用 |

来源同步提交为 `215afc72`；性能候选由包含本记录的 `fix` 候选提交追溯。没有 ADB 安装、设备内 APK 哈希核验、持续 Debug 会话或热重载结果。原手机帧时间、内存趋势、3 MB 实际上传分段耗时尚未测量。构建保留第三方 KGP 和 SDK XML 版本警告，当前构建通过；本轮没有借此更新依赖或 SDK。

门禁收敛过程中保留了三类失败证据：部署来源提交不匹配（完整同步修正）、新增测试格式及 7 条静态规范问题（补齐大括号和移除多余导入）、既有音频契约测试写死旧来源（精确 SHA 随来源同步更新）。对应日志为 `performance-full-gate-before-source-sync.log`、`performance-full-gate-format-failure.log`、`performance-full-gate-lint-failure.log`、`performance-full-gate-source-fixture-failure.log`；这些失败轮次不充当候选通过证据。没有关闭校验、放宽断言或修改门禁实现。

全量覆盖另发现字体进度 Widget 测试把两次虚拟帧视为大分片校验已完成，工作 isolate 引入后该假设不成立。测试改为推进真实异步任务并等待注册开始信号，3 项直接重跑通过；保留阶段、百分比、正文实例与组合输入断言。失败退出带来的后续已销毁 Widget 通知错误没有作为独立产品根因；最终以完整门禁重新验证。

## 负责人独立候选手测

1. 确认打开候选 `site.wenyou.app.debug`（与 Profile、正式版数据独立），记录手机型号、版本及网络。不要凭构建号认定安装的是同一应用。
2. 按原习惯连续浏览、进入带字体正文、返回再进入；观察字体复用及触摸／滚动是否持续变慢。
3. 原问题楼层连续修改两次，每次保存后检查正文和编辑时间，不手动刷新；再打开确认最新正文，检查未跳回错误位置。另测发表楼层、目标定位重试、删除后刷新、切号和权限撤回。
4. 使用同一张约 3 MB 图片，分别观察选择／裁剪、本地处理、上传等待、完成的转场；记录总时长和网络。等待期间动画、滚动、取消是否正常；不得据总时长归因 CPU 或网络。
5. 检查明暗主题、窄屏／大字、慢网／失败重试、系统减少动画。未知进度只显示忙碌状态，真实进度和终态不丢失；定位最后收尾没有先露出错误位置再跳动。
6. 负责人明确反馈原场景通过后，才记录验收日期和候选身份、标记修复完成；当前不合并、不发布、不清理任务工作树。

全项目覆盖与 Web 交接见[动效实现与复用边界](motion-implementation.md)。

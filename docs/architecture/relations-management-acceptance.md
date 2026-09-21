# 本人关系管理候选验收

状态：候选／待负责人验收。仅 Windows Mobile；治理任务 `01a0c4bb-9204-7662-93c3-648b8fa03f59`。分支 `codex/20260922-mobile-relations-management`，基线 `c5ba6668`。

## 依赖与实现

- Foundation 正式 v7.1.0（`dcf75d385e39cc0c55d550a6f35921cd9a7aa508`）；共享体验文档 `ba1e921212b908835734732f26e263203a8226c6` 仅作为说明，不直接消费未发布代码。
- Backend 固定 `ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a`，API `5.25.0-dev.20260922.1`；从只读 Git 镜像经同步脚本和 OpenAPI Generator 生成，不手改生成类型。
- 本人双列表共用行锁、双向投影与写入世代，成功才更新；移除粉丝保留反向关注。三个列表动作复用现有 outlined 按钮，Mobile 操作区第二行靠右；不新增 Token。

## 自动检查与构建

执行完整高风险入口 `npm run check:apk -- -ContinueAfterFailure`，不绕过生产契约比对。本地仓储、控制器和 Widget 写入全部使用模拟数据，公网仅读取 `/meta` 与契约；没有线上登录或业务写入。

- OpenAPI 校验、固定来源、客户端重新生成一致性、格式、应用／生成包静态分析、架构、21 个模块文档及 159 个消费操作覆盖检查通过；Windows 发布工具 18 项通过。
- 完整 Flutter 运行记录为 4620 项通过、1 项跳过、28 项失败，日志 `relations-final-gate.log` 如实保留，没有改写为全绿。失败包含诊断端点索引 1 项、Foundation 日期迁移的 25 个 Golden 用例（37 张图片）、运行起点早于修复的同帧双击 1 项（随后在新进程两次通过），以及新增旧式失败文案构造 1 项。
- 已使用仓库生成器同步诊断索引；37 张 Golden 逐张查看差异（包含收藏管理面板遮罩后的日期背景），仅日期移除时分（320dp 双倍字收藏行因此有空间显示更多姓名），没有借机修改页面设计。新的进程使用正常比对模式统一复跑全部 7 个失败文件，163 项通过，日志 `relations-final-recovery.log`；另一次整个 social 目录 158 项通过，日志 `relations-social-final.log`。
- 最后移除旧式异常文案构造，保留原始失败分类和请求编号，展示通过 `UserFacingFailure`；不明状态仍由共享 `unconfirmed` 驱动只读刷新与写入禁用。最终 controller／page／文案门禁 23 项通过，日志 `relations-final-copy-social.log`。
- 公网只读检查未通过：期望 API `5.25.0-dev.20260922.1`／`ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a`，实际 API `5.24.0-dev.20260920.1`／`adf8139ff75da3168435f6d58ce4f134f5dcbb6a`，Markdown 5 在支持范围内。此项是尚未消除的发布前阻塞，不能视为完整门禁通过。

统一恢复命令为 `flutter test --no-pub --concurrency=1`，参数依次为 `test/core/diagnostics/diagnostic_enrichment_test.dart`、`test/features/direct_messages/direct_conversation_page_test.dart`、`test/features/posts/post_reading_quick_scroll_test.dart`、`test/features/social/bookmark_list_page_test.dart`、`test/features/social/own_relation_lists_page_test.dart`、`test/features/threads/thread_detail_page_test.dart`、`test/features/threads/thread_reading_quick_scroll_test.dart`。最终源码 `flutter analyze --no-pub --fatal-infos --fatal-warnings` 零问题，`dart run tool/check_architecture.dart` 通过；最终格式及文档检查复验通过。APK 摘要见下文。

## Widget 渲染证据

最终 Debug 候选由 `flutter build apk --debug --no-pub` 从最终源码构建成功。路径 `build/app/outputs/flutter-apk/app-debug.apk`，183,495,226 字节，SHA-256 `A240C77F8ABE6E71979BC7AE198BB96CFA226B9FD4CC8E0EEC5A4EAB238F8E91`。`aapt dump badging` 确认包名 `site.wenyou.app.debug`、版本名 `0.7.1-debug`、构建号 `95`；未安装到设备。构建仍提示既有插件 Built-in Kotlin 迁移警告，未影响本次 Debug 构建。

应用源码提交为 `6cf95dcca4bad5be2fbd2a30c31e50ac79104322`；其后交付文档补充不改变 APK 源码。本次构建未传入 `API_BASE_URL`，默认连接 VPS 公网开发 API `https://wenyou.site/api/v1`，不是已通过线上门禁的发布包。该环境自动化仅允许只读；关系写入联调需先验证独立隔离后端身份，再使用对应 API 地址重新构建并另记候选 SHA-256。

`build/relations-ui-followers.png` 来自最终共享页签与描边按钮 Widget，PNG SHA-256 为 `5524A09A17B82F75D5F51D429DC8CB62193326D0D0550671FCD5FD52BA88EAED`。仅测试从 Windows 现有 `msyh.ttc` 加载中文字体，产品不捆绑字体；该图用于布局/样式审查，不等于 Android 字形或真机验收。包含回关与互关两种行，另外 Widget 回归验证 320dp 双倍文字、长姓名与亮暗模式不溢出、操作区不少于 48dp。

## 负责人手动验收清单

- 使用本次候选后端启动并验证身份的独立隔离环境及对应 Debug 候选；核对包名 `site.wenyou.app.debug`，本任务不自行安装或操作设备。
- 从“我的”的关注/粉丝与自己的公开主页进入；初始页签正确，切换后各自位置保留。查看他人列表没有管理按钮，旧链接和返回行为正常。
- 单向与互关分别取消：关注页移行；粉丝页保留并变回回关。回关变互关；移除粉丝仅移出粉丝页，自己的关注保留，取消确认不写入。
- 返回本人主页、本人公开主页和对方主页，核对数量与关系状态。失败留行及确认框；断网或超时仅刷新核实，不自动重复写；快速点击、切换页签与切号不污染状态。
- 亮色/黑夜、长姓名、小屏和双倍字体下检查统一描边、触控区域、按钮换行、读屏对象名、焦点返回、系统返回与安全区。Widget 渲染仅辅助审查，不能替代真机验收。

## 发布边界

交付到分支、提交与 PR；未合并、发布 Tag、部署或安装 APK。合并和发布需遵守治理门禁，真机验收未完成。

生产契约检查按精确 `buildSha` 比较；本候选固定 `ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a`。兼容后端正式发布后，即使候选 HEAD 或合并提交的契约字节相同，也必须按实际已部署 SHA 重新同步契约并重跑最终门禁，不能假定部署完成后当前检查自然通过。

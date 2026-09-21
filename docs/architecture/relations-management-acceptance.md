# 本人关系管理候选验收

状态：候选／待负责人验收。仅 Windows Mobile；治理任务 `01a0c4bb-9204-7662-93c3-648b8fa03f59`。分支 `codex/20260922-mobile-relations-management`，基线 `c5ba6668`。

## 依赖与实现

- Foundation 正式 v7.1.0（`dcf75d385e39cc0c55d550a6f35921cd9a7aa508`）；共享体验文档 `ba1e921212b908835734732f26e263203a8226c6` 仅作为说明，不直接消费未发布代码。
- Backend 当前固定 PR #26 合并提交 `4850e2f456ccc452c763853641e3b2136901e237`，API `5.25.0-dev.20260922.1`；原候选 `ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a` 的契约字节不变。来源均经只读 Git 镜像与正式同步脚本记录，原候选客户端由 OpenAPI Generator 生成，不手改生成类型。
- 本人双列表共用行锁、双向投影与写入世代，成功才更新；移除粉丝保留反向关注。三个列表动作复用现有 outlined 按钮，Mobile 操作区第二行靠右；不新增 Token。

## 自动检查与构建

执行完整高风险入口 `npm run check:apk -- -ContinueAfterFailure`，不绕过生产契约比对。本地仓储、控制器和 Widget 写入全部使用模拟数据，公网仅读取 `/meta` 与契约；没有线上登录或业务写入。

- OpenAPI 校验、固定来源、客户端重新生成一致性、格式、应用／生成包静态分析、架构、21 个模块文档及 159 个消费操作覆盖检查通过；Windows 发布工具 18 项通过。
- 完整 Flutter 运行记录为 4620 项通过、1 项跳过、28 项失败，日志 `relations-final-gate.log` 如实保留，没有改写为全绿。失败包含诊断端点索引 1 项、Foundation 日期迁移的 25 个 Golden 用例（37 张图片）、运行起点早于修复的同帧双击 1 项（随后在新进程两次通过），以及新增旧式失败文案构造 1 项。
- 已使用仓库生成器同步诊断索引；37 张 Golden 逐张查看差异（包含收藏管理面板遮罩后的日期背景），仅日期移除时分（320dp 双倍字收藏行因此有空间显示更多姓名），没有借机修改页面设计。新的进程使用正常比对模式统一复跑全部 7 个失败文件，163 项通过，日志 `relations-final-recovery.log`；另一次整个 social 目录 158 项通过，日志 `relations-social-final.log`。
- 最后移除旧式异常文案构造，保留原始失败分类和请求编号，展示通过 `UserFacingFailure`；不明状态仍由共享 `unconfirmed` 驱动只读刷新与写入禁用。最终 controller／page／文案门禁 23 项通过，日志 `relations-final-copy-social.log`。
- 首轮公网只读检查未通过：期望 API `5.25.0-dev.20260922.1`／`ea1ff7e2c6baeae6bf0316e87812ba37bc823d7a`，实际 API `5.24.0-dev.20260920.1`／`adf8139ff75da3168435f6d58ce4f134f5dcbb6a`，Markdown 5 在支持范围内。这是该轮的发布前阻塞，后续精确来源同步与核验结果见下方“兼容后端来源复核”；原日志不改写为通过。

统一恢复命令为 `flutter test --no-pub --concurrency=1`，参数依次为 `test/core/diagnostics/diagnostic_enrichment_test.dart`、`test/features/direct_messages/direct_conversation_page_test.dart`、`test/features/posts/post_reading_quick_scroll_test.dart`、`test/features/social/bookmark_list_page_test.dart`、`test/features/social/own_relation_lists_page_test.dart`、`test/features/threads/thread_detail_page_test.dart`、`test/features/threads/thread_reading_quick_scroll_test.dart`。最终源码 `flutter analyze --no-pub --fatal-infos --fatal-warnings` 零问题，`dart run tool/check_architecture.dart` 通过；最终格式及文档检查复验通过。APK 摘要见下文。

## Widget 渲染证据

最终 Debug 候选由 `flutter build apk --debug --no-pub` 从最终源码构建成功。路径 `build/app/outputs/flutter-apk/app-debug.apk`，183,495,226 字节，SHA-256 `A240C77F8ABE6E71979BC7AE198BB96CFA226B9FD4CC8E0EEC5A4EAB238F8E91`。`aapt dump badging` 确认包名 `site.wenyou.app.debug`、版本名 `0.7.1-debug`、构建号 `95`；未安装到设备。构建仍提示既有插件 Built-in Kotlin 迁移警告，未影响本次 Debug 构建。

应用源码提交为 `6cf95dcca4bad5be2fbd2a30c31e50ac79104322`；其后交付文档补充不改变 APK 源码。本次构建未传入 `API_BASE_URL`，默认连接 VPS 公网开发 API `https://wenyou.site/api/v1`，仍为待负责人验收的 Debug 候选而非正式发布包。该环境自动化仅允许只读；若需要代理执行关系写入联调，须先验证独立隔离后端身份，再使用对应 API 地址重新构建并另记候选 SHA-256。负责人在兼容后端部署核验完成后可使用本 APK 手动验收，这不等于授权代理在线写入或安装设备。

`build/relations-ui-followers.png` 来自最终共享页签与描边按钮 Widget，PNG SHA-256 为 `5524A09A17B82F75D5F51D429DC8CB62193326D0D0550671FCD5FD52BA88EAED`。仅测试从 Windows 现有 `msyh.ttc` 加载中文字体，产品不捆绑字体；该图用于布局/样式审查，不等于 Android 字形或真机验收。包含回关与互关两种行，另外 Widget 回归验证 320dp 双倍文字、长姓名与亮暗模式不溢出、操作区不少于 48dp。

## 负责人手动验收清单

- 兼容后端部署与生产来源核验完成后，负责人使用本 Debug 候选手动验收；核对包名 `site.wenyou.app.debug`，本任务不自行安装或操作设备。代理若需自动化写入测试，仍只允许身份已核验的独立隔离环境。
- 从“我的”的关注/粉丝与自己的公开主页进入；初始页签正确，切换后各自位置保留。查看他人列表没有管理按钮，旧链接和返回行为正常。
- 单向与互关分别取消：关注页移行；粉丝页保留并变回回关。回关变互关；移除粉丝仅移出粉丝页，自己的关注保留，取消确认不写入。
- 返回本人主页、本人公开主页和对方主页，核对数量与关系状态。失败留行及确认框；断网或超时仅刷新核实，不自动重复写；快速点击、切换页签与切号不污染状态。
- 亮色/黑夜、长姓名、小屏和双倍字体下检查统一描边、触控区域、按钮换行、读屏对象名、焦点返回、系统返回与安全区。Widget 渲染仅辅助审查，不能替代真机验收。

## 发布边界

Mobile 交付到分支、提交与 PR；未合并 Mobile、发布 Tag、部署 Mobile 或安装 APK。合并和发布需遵守治理门禁，真机验收未完成。

生产契约检查按精确 `buildSha` 比较；本次已用正式脚本同步 PR #26 合并提交 `4850e2f456ccc452c763853641e3b2136901e237`。部署完成后仍须独立核验生产来源，不能仅凭契约字节一致推断上线成功。

## 兼容后端来源复核

已从只读 `origin/dev` 用 `tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Branch dev -Revision 4850e2f456ccc452c763853641e3b2136901e237` 同步。Backend 两个提交的 `contracts` 目录无差异；Mobile OpenAPI SHA-256 为 `1CF55F50091E14B4118C12355D6DFC82AD90752DBAB3FEC7F246894CC8351BC9`，与原候选一致。生成客户端、`lib`、Android/iOS 配置和 `pubspec` 无差异，既有 APK 的 SHA-256 仍为 `A240C77F8ABE6E71979BC7AE198BB96CFA226B9FD4CC8E0EEC5A4EAB238F8E91`，无需重建，可继续作为真机验收候选。

管理入口完成兼容后端部署后，Mobile 独立运行 `npm run api:verify:production` 通过：API/bundle `5.25.0-dev.20260922.1`，精确 buildSha `4850e2f456ccc452c763853641e3b2136901e237`，部署 Markdown 5 在支持范围内，`GET /threads` Schema 兼容。随后固定契约来源检查与 21 个模块文档检查再次通过，日志分别为 `relations-merged-production-check.log`、`relations-merged-source-check.log`、`relations-merged-docs-check.log`。原生产来源阻塞已解除；本次仅修改来源与文档，不重建 APK、不重复无源码变化的全量测试，也不替代负责人真机验收。

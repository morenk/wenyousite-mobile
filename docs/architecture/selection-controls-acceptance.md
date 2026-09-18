# 选择控件修缮候选验收

状态：负责人已于 2026-09-19 验收通过，授权合并与清理任务分支。任务分支：`codex/20260919-selection-polish`。

## 目标与基线

- 首页、通知、私聊、收藏夹及表单的下拉入口与菜单统一视觉层级；主楼和独立讨论作者选择改为带头像的底部抽屉，子贴导航改为锚点下拉。
- 只调整移动端呈现和选择交互；不修改请求、分页、筛选作用域、权限、持久化、上传或生成 API。
- Foundation 已 fetch tags，最新正式 Tag 为 `v7.0.0`，与 pubspec 固定依赖一致。读取该版本 CHANGELOG、mobile profile 和 selection/overlay 契约。
- 后端 `origin/dev` 与公网 `/meta` 均为 `602f57324256f358aea27d204937f9e15644f9c7`；契约为 `5.22.0-dev.20260912.2`。相对本地来源 `6fdfa00eaf1f3056ba30f2ffbc529d12eed1c823`，规定的契约文件与移动端指南没有差异，因此本轮无需同步生成客户端。
- 只读对照 VPS Web `subthread-tabs.tsx`：标题入口、锚定下方的目录、子贴总数、选中反馈与楼层数；移动端沿用自己的 Foundation 尺寸和 48dp 命中区。

## 行为与回归范围

- 选择菜单使用语义字号、自然换行、右侧勾选、选中淡底色；普通入口按内容收缩，表单保留字段标签与边框。禁用及空选项不能展开；系统返回、外部点击及重选不提交额外选择。
- 作者抽屉首项为“所有人”，作者显示 40dp 头像、名字与角色；复用现有头像 URL 和缺失／失败占位。点击头像和整行均筛选，名单打开后当前选择可见；关闭不改变筛选，排序继续独立控制。
- 子贴标题最多两行，展开目录可阅读完整标题与楼层数，长目录在浮层内滚动；保留左右循环切换、切换后清除作者但保留顺序及原有定位逻辑。
- 举报、子贴权限校验与提交锁不变；草稿删除仍二次确认，图片与私聊操作保持原业务边界。

## 首轮自动验证与候选

2026-09-19 最终候选通过唯一快速入口，参数为下列 13 个测试文件及 `-TestConcurrency 2`：全仓 Dart 格式检查、应用与生成客户端全量静态分析均零问题，262 项相关 Flutter 测试通过，Debug APK 构建成功。文档与架构检查另外通过；18 项 Windows 发布工具测试通过。

候选流程中发现多测试路径被脚本合并为单一文件名，已由独立 chore `0243194a` 修正，并用实际参数数组验证旧实现失败／新实现通过。修正前的失败流程及表单回填补充前的中止流程均不作为候选证据。最终证据日志：`%TEMP%/wenyou-selection-candidate-verified.log`。

- 应用源码提交：`d0754f8f6100a1bb26c3d7834e4ebb5baa21258f`；后续记录提交仅补充交付证据。
- 保留副本：`D:/code/wenyousite/wenyousite-mobile/build/candidates/selection-polish-d0754f8f/wenyou-selection-polish-d0754f8f-debug.apk`，已核对副本 SHA-256；同目录保存 `candidate.log`。
- 安装包：`D:\code\wenyousite\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`。
- 包名：`site.wenyou.app.debug`；应用名：`温油站 Debug`；APK 版本：`0.7.1-debug`，versionCode `95`。
- 大小：`183233778` 字节。
- SHA-256：`effdf7488cd7ca9b12ea1bb6cfcc99946e1f60e3440e20121d9537bab6095825`。
- 已用 aapt 读取候选元数据，Debug ABI 为 ARM32、ARM64 与 x86_64。

本记录不把 Golden、自动测试或 APK 构建视为真机验收。

相关测试范围：

- `test/core/widgets/wenyou_filter_controls_test.dart`
- `test/core/widgets/wenyou_selection_surfaces_test.dart`
- `test/core/widgets/content_image_viewer_page_test.dart`
- `test/features/home/home_page_test.dart`
- `test/features/threads/thread_detail_page_test.dart`
- `test/features/threads/subthread_management_page_test.dart`
- `test/features/posts/post_replies_page_test.dart`
- `test/features/notifications/notifications_page_test.dart`
- `test/features/direct_messages/direct_messages_page_test.dart`
- `test/features/direct_messages/direct_conversation_page_test.dart`
- `test/features/drafts/content_drafts_sheet_test.dart`
- `test/features/reports/report_widgets_test.dart`
- `test/features/social/bookmark_list_page_test.dart`

## 负责人真机清单

1. 打开候选 Debug 应用 `site.wenyou.app.debug`，检查首页排序与状态入口是否轻巧、点按是否方便；切换后结果和分页正确。
2. 主楼和独立讨论打开作者抽屉，检查真实头像、无头像占位、角色、长名字与选中标记；切换作者、恢复所有人、关闭和重选，确认排序不被重置。
3. 在多子贴主题打开标题下拉，检查长标题、楼层数、菜单滚动和左右切换；冻结导航栏滚动后继续操作，关闭菜单保持阅读位置。
4. 检查通知、私聊、收藏夹、举报原因和子贴权限，确认样式一致、长选项可读且表单错误仍清楚。
5. 检查草稿、私聊和图片更多操作；本轮不要求在共享公网数据上执行删除等破坏性操作。
6. 切换浅色／深色和两倍字号，检查窄屏、底部安全区、系统返回、菜单外点击及连续打开关闭。

未取得可复用的 Debug 会话，开发反馈以 Widget/Golden 为依据。首轮候选交付后，负责人明确要求直接 ADB 安装、不执行额外检测；已在当前连接真机覆盖安装，ADB 返回 Success。负责人随后要求继续调整子贴导航；该轮交付时仍待验收，后续通过结果见下方验收记录。

## 子贴导航反馈调整（2026-09-19，候选／待负责人验收）

- 复现路径：进入多子贴主题，查看当前子贴标题并展开导航。首轮候选标题偏左，展开时底色变化，目录显示“主题目录”。负责人要求标题恢复居中、取消底色变化并移除这几个字。
- 调整：导航标题两侧预留对称空间并居中排版；展开和收起使用相同底色；下拉头部仅保留子贴数量，选项与切换行为不变。
- 精确回归：`360dp 子贴目录使用锚点菜单与轻量选中高亮` 新增居中几何、展开前后底色一致及目录文字移除断言，旧实现因未居中失败；截图与主题详情相关回归随候选复核。
- 补充需求：子贴长目录右侧常显滚动条，提示剩余内容；滚动条与目录共用控制器，短目录不绘制。增加浅色与深色两倍字号截图，并验证等待后仍显示、实际滚动、选择末项、关闭和再次打开。
- 初次构建在负责人补充滚动条需求后中止，不作为新候选证据；最终候选包含上述全部调整。
- 最终验证入口：`npm run candidate:apk -- test/features/threads/thread_detail_page_test.dart test/core/widgets/wenyou_selection_surfaces_test.dart test/core/widgets/wenyou_filter_controls_test.dart -TestConcurrency 2`；全仓格式、应用与生成客户端静态分析及 105 项相关测试通过。另行通过文档、架构检查；最终流程日志为 `%TEMP%/wenyou-subthread-final-candidate.log`。
- Debug APK 构建通过，大小 `183233778` 字节，SHA-256：`ce9c4ae867f7747bd9ef012ea9b438afcc06da6326cb4ee77e2e14abb9442785`。保留副本：`build/candidates/subthread-navigation-ce9c4ae8/wenyou-subthread-navigation-debug.apk`，同目录保留日志。版本沿用 `0.7.1-debug` / `95`，包名 `site.wenyou.app.debug`。
- 已按负责人既有授权直接 ADB 覆盖安装，返回 `Success`；按要求未额外核验设备包信息或设备内哈希。请打开“温油站 Debug”复验标题居中、展开底色不变、目录标题移除及长目录滚动条，仍待负责人验收。

## 负责人验收通过（2026-09-19）

- 负责人在最新候选 ADB 安装后明确反馈“可以了合并清理分支”，本轮视觉修缮验收通过，并授权合并到 `dev`、清理本任务分支。
- 对应应用源码：`a7caeb58794f2aa71ba563f79f5bcfb9402ac6e6`；安装包 SHA-256：`ce9c4ae867f7747bd9ef012ea9b438afcc06da6326cb4ee77e2e14abb9442785`。
- 验收后只更新记录，不改变已验收应用源码；合并前执行完整门禁，保留历史候选与自动验证证据。本次不涉及正式发布。
- 首次集成门禁因本地来源仍为 `6fdfa00e`、线上为 `602f5732` 而停止。通过同步脚本重新导出后仅 `backend-contract.properties` 的 Backend revision 变化，接口与共享语料不变；更新来源审查记录并重新运行完整门禁，已验收应用源码保持。

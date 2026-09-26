# 图片查看器首帧定位验收

状态：负责人验收通过／修复完成。2026-09-26，负责人在已核验生效的 Debug 热重载后明确回复“修复完成，合并清理分支吧”，授权合并 PR #67 及对应分支和临时工作区清理。本轮没有构建新 APK，验收对应下述运行源码。

## 原始反馈与复现

2026-09-26，负责人在移动端回复串点击靠后的图片：大图先停在回复串第一张，再点一下界面才滑到实际点击图。

另一原始入口为 [指定楼层](https://wenyou.site/threads/cmu0ax7r002y77qwtrfqpwbuc?post=cmu0g04r0005c7qar011or7ws)。负责人确认正文图片正常，首次大图显示加载失败，再点界面即可滑到该图，并明确这两个现象为同一个问题。未把匿名 GET 返回的 `40402` 当成已登录场景的图片故障原因，也未修改权限或媒体资源。

按负责人授权读取当前 Debug VM：`ReadingGalleryController` 已初始化，`failure=null`，图集含两项，当前来源为该楼层。没有读取或输出登录凭证。未取得图片下载失败的独立网络证据，本次仅处理已确认的画面错位。

## 已证实原因与修正

首次只显示本地点击图，查询返回后它在完整图集中的序号可能增加。旧实现更换 `PageController(initialPage: target)`，但 Flutter 已挂载的 PageView 会把原 `ScrollPosition` 交给新控制器，保留旧偏移。标题与手势使用新序号，画面却停在旧页，下一次点按松手才触发导航对齐。

修正保留同一控制器，按图片稳定身份找到新序号后立即同步实际页面位置。关闭默认页码恢复，重新打开时以本次点击为准；没有重建当前图片的缩放状态，也没有修改图片 URL、缓存回退或图集请求策略。分页到达时若仍按着屏幕，继续取消这次旧序号下的导航意图。

## 范围与环境

- Windows 独立工作区：`D:\codex-worktrees\image-viewer-anchor\wenyousite-mobile`。
- 分支：`codex/20260926-image-viewer-anchor`，基线 `origin/dev` 的 `9108c6e57744999ae9c2de61e1c2290c8d1aea37`。
- 实现只涉及共享图片查看器；主题、楼中楼及动态图集共用。滑块与预览底色的未提交工作仍留在原独立工作区。
- 已记录 Backend revision、只读镜像 `origin/dev` 与本次公网 `/meta` 同为 `124fb4e8aa395440f7a2156de98b642ec87f7583`，API `5.26.0-dev.20260922.3`。本切片不修改契约、依赖、上传或后端。

## 回归与当前交付

- 旧实现精确回归失败：`test/core/widgets/image_gallery_gestures_test.dart` 的“图集从单图补齐前序图片后画面立即保持点击图，不等待再次点按”，预期实际 page 为 2，旧实现为 0。日志 `artifacts-image-anchor-before.log`。
- 候选检查实际可点击画面与 PageController 页码，不只检查标题；另覆盖按住横拖时前插、放大后前插保留变换、真实图集异步补齐和既有双指／双击／保存／收藏行为。
- 三个测试文件共 21 项通过：`test/core/widgets/image_gallery_gestures_test.dart`、`test/features/media/reading_gallery_page_test.dart`、`test/core/widgets/content_image_viewer_page_test.dart`。日志 `artifacts-image-anchor-final-tests.log`。
- 全仓 `flutter analyze --no-pub` 零问题，`docs:check` 通过。日志 `artifacts-image-anchor-full-analyze.log`。开发反馈阶段不把此前其他源码的完整门禁或 APK 哈希用于本次修改。
- 候选源码 `eea809ba4b5b18b7367285ff2c177e973b7e9a1c` 已推送为 [PR #67](https://github.com/morenk/wenyousite-mobile/pull/67)，目标 `dev`；最初以 Draft 交付，负责人已授权在完整门禁通过后合并。
- 该提交的共享查看器补丁通过 Git diff/apply 交接到原 Debug 工作区，保留滑块及预览底色的未提交变更。首次请求热重载时现有 attach 连接断开，Android PID 仍为 `15535`；设备 `mWakefulness=Dozing`，短暂唤醒后 VM 可读，随后再次休眠。当时没有把热重载记为成功，后续在设备保持亮屏后重连验证。
- 负责人随后要求继续应用。2026-09-26 18:37，重新 attach 并恢复原 Activity 到前台后，实际热重载 1/4574 个库；Android PID 仍为 `15535`。VM 源码核验 `_pageController.jumpToPage(target)` 已载入、旧控制器替换逻辑已移除、`keepPage: false` 已载入；运行证据为 `build/candidates/image-anchor-runtime.json`。初始 attach 的“Reloaded 0 libraries”未作为生效依据。没有重启进程或重装 APK，当前图片需关闭再打开来复验首次进入；当时等待负责人手动确认，后续验收结果见本文首段。

## 负责人复验

1. 从回复串靠后位置点击图片，等待图集补齐，首屏应始终是该图，不需要再点画面。
2. 重新打开原链接楼层图片，确认首次就能看到正确图片。
3. 左右切图、双击／捏合放大，加载前页时当前图片与缩放保持；普通关闭回到原阅读位置。

负责人已明确通过原问题复验。本次完成结论来自负责人反馈，自动测试和热重载记录仅提供补充证据。

## 集成验证与证据保留

- 2026-09-26，在本切片 Windows 工作区执行 `npm run check -- -TestConcurrency 2`，退出码为 0，完整门禁通过。应用、测试、契约、依赖和门禁脚本均与已验收实现提交 `eea809ba4b5b18b7367285ff2c177e973b7e9a1c` 一致；后续提交仅更新验收文档。
- 契约校验与再生成一致性、公网兼容性、全仓格式和静态分析、架构、模块文档及 API 覆盖检查通过。Flutter 全量回归 4,889 项通过，1 项跳过；跳过项为需要显式执行的 `test/core/diagnostics/diagnostic_live_receipt_test.dart` Sentry 在线收件验收。Windows 发布工具测试 47 项全部通过。
- 完整日志为 `artifacts-image-anchor-check.log`。清理前将它与旧实现失败、候选精确回归、静态分析及实际热重载的证据另存到 `D:\code\wenyousite\artifacts\mobile-image-viewer-anchor\20260926`，由 `evidence-sha256.json` 记录文件摘要。
- 本轮不构建或重装 APK，也不沿用旧 APK 哈希作为新实现的证据。PR #67 合并后仅清理其专用分支及工作区；原滑块工作区、其他任务和主目录未跟踪制品继续保留。

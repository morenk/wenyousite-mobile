# Sentry 上传恢复候选

状态：候选／待负责人验收；不关闭 Sentry issue，不合并或部署。

## 2026-10-25 组合验收准备

- 沿用 PR #104，从原 HEAD `d31fa975372dde6f421978196dc1933729fbfc95` 普通 merge `origin/dev` `b7e1a4acf9433b38b29505834b5f1eea77598330`。当前固定 Backend 为 `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`、API `5.44.0-dev.20261024.3`，Foundation 为 `v7.6.0`；契约、生成客户端、依赖和原生配置沿用该基线。
- 合并时生产代码自动合入；仅变更日志及媒体模块文档冲突，保留新统一图库、字体、剪贴板、安全区与楼中楼恢复前台行为。上传候选仍只有首次选择与明确重试允许传输；待重传草稿只查询，既有待确认状态保留同 ID 幂等确认，不自动发布。
- 新增 `test/features/media/photo_selection_upload_recovery_test.dart`，串联真实 `PhotoSelectionHost`、`UnifiedImagePicker`、评论页面、共享上传控制器及 Repository/Dio 离线夹具，检查图库路由刷新后的选图、PUT 失败身份保留、重开只查、明确同 ID 重传和再次明确发送。该场景不使用真实图库或线上写入，不能替代负责人原设备断网复验。
- 组合审查发现重签／确认 POST 返回 `40101` 后，拦截器按原策略只续期、不重放，但上传任务把原 401 一律归为不可重试，成功续期也失去手动恢复入口。本轮在拦截器成功续期且会话仍有效时留下仅请求内存的标记，每次发请求先清除；上传任务仅据此保留同 ID 的明确重试。刷新失败、会话失效和普通 401 不放开，也不新增 POST 自动重放。`media_upload_auth_recovery_test.dart` 使用真实 `RequestContextInterceptor`、生成客户端及内存 HTTP adapter 覆盖成功、失败与失效边界。
- 动态／评论共用的附件缩略图按任务 `canRetry` 提供动作，并在弹层返回时再次核对，防止旧动作绕过当前限制；处理中继续等待、移除和重新打开后按新状态恢复的行为保留。`moment_upload_retry_actions_test.dart` 的 8 项真实 Widget 回归覆盖上述边界。
- 旧实现红证据：将上传控制器临时替换为原 HEAD 的版本，重签和确认两项在 `canRetry` 预期 true、实际 false 失败；finally 按原始字节恢复并核验 SHA-256 `E66688C139986F9E764020A6089BF7376F6D1D8C697BD3C0F3069E48E53771DB`。日志 `D:/codex-worktrees/mobile-sentry-upload/upload-auth-baseline-red-20261025.log`，SHA-256 `894CC9A2843EBC2A69187E0122F038FDAEA7EFB321C5ED388421C4AAEAC2F082`。缩略图先新增测试再修改实现，旧实现 2 通过／6 失败，证实错误露出重试及失效后仍调用回调；日志 `upload-retry-actions-red-20261025.log`，SHA-256 `F26FDF73DFF442352C3DE3992A6F2AA8BE93CCEF7AA88D252B044D5D2DE87E36`。
- 本轮最终应用冻结树 `34095c09a659b5c05c04fda741f004964cb6d764` 定向 417 项通过、0 失败、退出 0，测试耗时 3:56；日志 `D:/codex-worktrees/mobile-sentry-upload/upload-targeted-20261025-2.log`，SHA-256 `A4D9D78353AAE4AF339FC980B4298AC3CA50A3CAD21422E14F8743C454AB9918`。实际命令为 `flutter test --no-pub --concurrency=1 test/features/media test/features/editor/editor_pending_images_test.dart test/features/editor/editor_image_upload_completion_test.dart test/features/editor/editor_publish_preparation_test.dart test/features/editor/editor_text_color_audio_integration_test.dart test/features/editor/editor_pending_audios_test.dart test/features/editor/editor_text_font_session_test.dart test/features/moments/moment_upload_experience_test.dart test/features/moments/moment_comment_attachment_lifecycle_test.dart test/features/moments/moment_upload_retry_actions_test.dart test/features/direct_messages/direct_message_media_test.dart test/core/network test/user_facing_copy_test.dart`。后续仅补文档，不改变该应用／测试源码。
- 失败记录保留：图库首轮误把轻量 `onDraftChanged` 当成持久化快照，改为真实草稿存储；第二、三轮未同时推进弹层动画和真实文件 IO，最终采用有界交替驱动通过。第二轮文件句柄导致临时目录清理失败，运行器退出后仅回收精确登记目录 `D:/dev-cache/tmp/wenyou-pending-test-7b21c7e`，最终回归清理通过。首轮矩阵 408 通过／1 失败：原鉴权测试使用不可变 `extra`，新增标记原地写入抛异常并超时；已改为保留原键的新 Map 赋值，原测试保持。该日志 `upload-targeted-20261025.log`，SHA-256 `0A5C16DFD91E8F0D101C13831CFDCD5F0CB94D28AA48D5F1F8BE2A4DC1AD0A22`。各失败均不计通过。
- 最终相对 `origin/dev` 的 23 个差异 Dart 文件格式检查通过（0 改动），`flutter analyze --no-pub --fatal-infos --fatal-warnings` 对同一清单分析通过（153.3 秒、0 问题）；对应日志 `upload-format-20261025-final.log`／`upload-analyze-20261025.log` 的 SHA-256 分别为 `B51EA7019B33A55084A3B43BE500E31C6C79683937D0160FF001811AB823A1A1`／`2A77CC2059C13DEB61AB3338858E4013F7E20C4AEFF2032FB0DEE5660FC5496D`。本轮未重复全应用和生成 SDK 分析。
- `dart run tool/check_architecture.dart` 通过，保留超过 700 行文件的常规评审提示；`dart run tool/check_docs.dart` 通过（23 个模块）。日志 `upload-architecture-20261025.log`／`upload-docs-20261025.log` 的 SHA-256 分别为 `16C5D997BCCE268DC4294BA52BD275AA81E62A3E796697EDE4E6D4F1D9AC69EF`／`8AB319EBD2B97E58F95897DD563CEBE6B4B90F3716AEB8EB263C0149C35E9E35`，均位于 `D:/codex-worktrees/mobile-sentry-upload/`。冻结后核验应用、测试、工具、契约、生成包、锁文件及原生配置无漂移，`git diff --check` 通过；检查完成后仅补充本文交付证据。
- 完整 `check:apk` 由治理在包含六项改动的最终组合分支统一执行。本轮未构建、安装或启动 APK，未进行线上业务写入。下方 2026-10-21、2026-10-16 的完整门禁与 APK 均为历史证据，不代表本轮已通过完整门禁或已有新包；负责人原设备复验仍待完成。

## 2026-10-21 最新 dev 整合

- 沿用原分支 `codex/20261015-sentry-upload-recovery` 与 PR #104，从原 HEAD `ecb9251152b6107133da0326c71ea0e8d93e5237` 使用 merge 整合 `origin/dev` `6f0064507a77e2034250ee4fd9f1d382e0a063a9`，不改写共享历史、不吸收其他候选 PR。
- 本轮固定来源为 Backend `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`／契约 `5.40.0-dev.20261018.1`，保留基线生成客户端、依赖、原生配置及版本 `0.10.0+100`。只读 `GET https://wenyou.site/api/v1/meta` 核对相同 buildSha／contractVersion；服务端 Markdown 为 5，本地来源版本与客户端既有兼容声明维持基线。
- 两处冲突为编辑器及媒体模块文档，逐段保留音频流程和图片恢复说明。生产代码自动合入后逐项核对公共发布准备、文字颜色与音频投影；音频专用上传／重签、主题和帖子公共发布入口与最新 dev 一致，未回退新功能。
- 旧红证据仍可对应本轮未修实现：`d7168b61` 与最新 `6f006450` 的 `lib/features/media/data/media_upload_repository.dart` 均为 Git blob `f7776e4f52a03c7a08cada6a0da15e96ee308661`。原 `upload-baseline.log` 的 PUT 超时用例预期媒体 ID 为 `media-one`、实际 null，失败属于业务断言；本轮在整合后的最终源码验证新绿，未重复运行字节相同的旧实现。
- 新增 `test/features/editor/editor_pending_images_test.dart` 组合回归：有彩色正文和已完成音频时，图片失败使公共发布返回失败，明确重试复用媒体身份，附件完成不自动发布；再次明确发布才提交一次，核对实际 `onMarkdownChanged` 提交输出与会话一致，并保留完整彩色文字片段、音频与图片。本轮定向组合已通过。独立只读审查核对真实等待／重试／发布调用契约，未发现确定阻断；音频覆盖链接和元数据保留，不包含播放或投影视觉验收。
- 独立只读审查已核对生产代码：音频仍参与附件就绪、保存和生命周期；图片显式重签与自动恢复边界、取消／切号保护、最新生成接口兼容未发现确定阻断。审查没有执行 Dart、Flutter、代码生成或 Gradle。
- 本轮先对本工作区执行原生 `dart run build_runner clean`、`npm ci`、`flutter pub get` 和新增测试格式检查，均退出 0；未修改共享缓存，契约、生成客户端、锁文件及原生配置相对 `6f006450` 无额外差异。
- 定向命令：`flutter test --no-pub --concurrency=1 test/features/media test/features/editor/editor_pending_images_test.dart test/features/editor/editor_image_upload_completion_test.dart test/features/editor/editor_publish_preparation_test.dart test/features/editor/editor_text_color_audio_integration_test.dart test/features/editor/editor_pending_audios_test.dart test/features/moments/moment_upload_experience_test.dart test/features/moments/moment_comment_attachment_lifecycle_test.dart test/features/direct_messages/direct_message_media_test.dart`，264 项通过、0 失败、退出 0，测试阶段耗时 1:54。日志 `D:/codex-worktrees/mobile-sentry-upload/upload-targeted-dev-integration-20261021-1.log`，SHA-256 `6EF051539175D3F15CD8BB5429F306BC418DEDD5F54FA85637E908F4258370A7`。首次编译加载耗时较长，核验本任务编译进程继续运行后正常完成，未停止、清缓存或重跑掩盖结果。
- 本组按 #103 → #100 → #101 → #104 串行完成。#104 已验证应用提交为 `de2dff62eb81e920c10b2da07bad58cda7f8f28e`，两个父提交为原分支 `ecb9251152b6107133da0326c71ea0e8d93e5237` 和基线 `6f0064507a77e2034250ee4fd9f1d382e0a063a9`；提交树与检查前冻结树 `c91eb16ce68849ba7f269fb40e64cbaf8f62a8c6` 完全一致。完成检查后仅补充本记录及变更日志，不改变已构建应用。下方 2026-10-16 的日志和 APK 仅为历史证据，不代替本轮检查。
- 本轮第一次完整官方 `npm run check:apk -- -TestConcurrency 1` 成功退出 0：格式检查 1432 文件、0 改动；应用与生成客户端分析、契约校验／再生成一致性、架构、23 个模块文档、API 覆盖 175/175 全部通过。Flutter 7327 通过／1 条既有显式 Sentry 实际上报验收跳过／0 失败，测试阶段 44:18；Windows 发布工具 49/49 通过；同次流程构建 ARM64 Debug APK，Gradle 耗时 241.2 秒。日志 `D:/codex-worktrees/mobile-sentry-upload/upload-check-apk-dev-integration-20261021-1.log`，SHA-256 `98D08F7CC019380D3BAF4595A01D2BFA92D5DB78B6F7DAA002ABD4D558E2AA09`。本轮没有拆分补检代替官方门禁。
- 本轮 APK：`D:/codex-worktrees/mobile-sentry-upload/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`，112838734 字节，包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`（100），ABI `arm64-v8a`；SHA-256 `91FF01A42EECAD8BB99FED24AE7D2A61164A167E17652EA7985AE76BB50C56B1`。仅构建，未安装或启动，负责人原场景验收仍待完成；原图片上传失败的具体网络根因不能由本轮离线回归确定。
- 合并预览仅作后续提示，没有将候选相互合并：以固定基线对 #101 最终提交 `48db24ec1649e9f4b7312cad812880c4595f2d18` 与 #104 冻结树执行只读 `git merge-tree`，仅 `docs/CHANGELOG.md` 产生冲突，未见生产代码冲突；共享 AST 审计文件字节一致。证据 `D:/codex-worktrees/mobile-sentry-upload/network-upload-merge-preview-20261021.txt`。后续实际组合仍须保留各项记录并完成集成检查。
- 审批偏好为 Auto-review，但治理从本轮 `turn_context`（`01a15a6d-7d01-7ce0-9841-d21461295583`）核验实际为 `approval_policy=never`、`approvals_reviewer=user`、`sandbox_policy=danger-full-access`。宿主无支持的配置入口，Auto-review 未启用；没有修改全局配置。

## 范围与来源

- 首轮 Mobile 基线：`d7168b61ea1b547e737585d2e9b250f1b3bd24e2`，发布版 `0.9.0+99`。
- 首轮已验证应用源码提交：`1048245349359d3939fe34bb0772253963489815`。2026-10-16 的官方完整门禁与下述历史 APK 均对应此应用源码。
- 首轮 Backend 固定来源及当时公网只读 `/meta`：`b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，API `5.36.0-dev.20261005.1`。本候选不改变 HTTP API、Markdown 和数据库。
- [27](https://momo-af.sentry.io/issues/WENYOUSITE-MOBILE-27) 为对象存储 PUT 连接超时。构造回归证实旧实现 PUT 失败后丢失已分配的媒体身份；缺少线上原始图片、设备网络及完整步骤，不能把构造回归等同原事件精确复现。
- [2P](https://momo-af.sentry.io/issues/WENYOUSITE-MOBILE-2P) 为 10 月 11 日申请上传地址 500，不属于 10 月 14 日 14:00–17:00（北京时间）维护窗口。只读管理日志已按 requestId `36e16041-68d6-45e3-8917-54de6a466301` 关联到 `MaxRetriesPerRequestError`（Redis）。同分钟有短暂 500，后续分钟恢复成功响应；Redis 请求失败的底层原因及当时部署版本仍待核验。Redis 容器同日 11:15–11:40 UTC 的现存 23 行日志包含正常持久化，未见启动、停机或错误记录，不足以判断客户端连接失败的原因。当前后端已有 Redis 超时与离线队列隔离实现；本轮没有后端源码或基础设施变更。
- 负责人追加的用户截图：北京时间 10 月 16 日 00:40:05、诊断编号 `90a36583-9e4f-40f9-9d90-ea07cf111be0` 精确匹配 [MOBILE-4](https://momo-af.sentry.io/issues/WENYOUSITE-MOBILE-4/?eventId=90a365839e4f40f99d90ea07cf111be0)，来自旧版 `0.7.1+95`，`SocketException / apiWrite.request / responseReceived=false / apiEnvelopeReceived=false`。旧记录缺少接口、Dio 类型与调用堆栈；无法据此定位申请地址、确认还是发布阶段，亦不能据此认定图片格式或大小有误。后端 16:35–16:45 UTC 日志未检索到 requestId `0dc86efc-d2f3-4ba5-b6ed-954faa6d183c`；此项不足以证明具体网络根因。另两条本机加载失败编号未在 Sentry 检索到，保留待用户复制详情；不得并入 27/2P 后宣称已修复。

## 候选行为

1. 申请地址成功即保留媒体 ID、用途、传输阶段及归一化输入 SHA-256；不持久化预签名 URL。
2. PUT 失败或结果不明保留附件和身份。明确重试先查询原媒体；已完成直接使用结果，处理中只续查，仍待上传时调用已发布的 `mediaReissueUploadUrl`，对原对象重新 PUT、确认。
3. 重传前核对用途、大小、类型与本机输入摘要；不能把另一文件写到原媒体。历史 pending 无摘要时兼容既有文件关联，并核对大小与类型。
4. 确认返回 `40419 MEDIA_OBJECT_MISSING` 转入同一媒体的待重传状态；业务查询或重签的普通 401/403/404 保留身份但禁止反复重试。对象存储 PUT 拒绝旧签名可由用户明确重签；仍保留原错误分类用于诊断。重签失败不退回申请新媒体。
5. 草稿自动恢复不申请新媒体、不重签或 PUT：未取得身份的附件等待手动重试，待重传附件仅查询。已有待确认状态沿用查询后对同一媒体幂等确认，处理中状态只续查。编辑器、动态、评论及通用任务只有首次选图或用户点重试才允许传输。私聊保留原乐观消息与 `clientRequestId`，明确重试复用原媒体。
6. 取消、离页暂停和切号沿用现有任务代次与 CancelToken，迟到结果不能恢复旧附件或触发发布。
7. 只有服务端明确 `FAILED` 才释放不可再用的旧身份，保留输入供手动重新上传；普通异常不按错误文案推断终态。此状态的草稿重开同样不会自动申请新媒体。

初次申请上传地址若响应未收到，客户端没有可恢复的媒体 ID；本轮不改变服务端幂等契约，只保留输入并禁止自动重放。用户明确重试可能产生未使用的预留记录，不能承诺此阶段绝不创建重复预留。

## 回归与交付记录

- 旧实现回归：仅新增 `media_processing_resume_test.dart` 的 PUT 超时场景，在基线运行失败，预期 `media-one`，实际 pending 为 null。日志保留于任务工作区外的 `upload-baseline.log`。
- 定向组合：`flutter test --no-pub -j 1 test/features/media test/features/editor/editor_pending_images_test.dart test/features/editor/editor_image_upload_completion_test.dart test/features/moments/moment_upload_experience_test.dart test/features/moments/moment_comment_attachment_lifecycle_test.dart test/features/direct_messages/direct_message_media_test.dart`，200 通过、1 条新增恢复夹具失败（假文件路径无法读取）。改用独立临时文件并正确驱动 widget zone 与文件 IO 后，`editor_pending_images_test.dart` 7/7 通过；首轮日志 `upload-targeted.log`、补检日志 `upload-editor-recheck-2.log` 保留在工作区外。中间一次夹具等待 widget zone 的重检主动终止，未改变产品源码掩盖失败。
- 完整门禁首轮在测试文件多余导入处停止，删除该导入后第二轮前置检查通过；第二轮全量进行中发现新增旧式错误文案构造，已核验并停止本任务进程，保留 `upload-check-apk.log` 与 `upload-check-apk-2.log`。修正应用源码后的第三轮全部前置检查通过，首个测试文件编译时宿主 Dart 无法创建线程（同期另一任务发生内存不足），编译器退出后 runner 停滞；仅停止已核验的本任务进程树，日志 `upload-check-apk-3.log` 保留，不记为通过。
- 分批补检曾建立完整的 499 个测试文件清单，首批运行至 1709 通过、没有失败后主动停止。复核 `AGENTS.md` 第 8 节后确认分步补检不能替代同一次官方完整门禁，改为独占运行 `npm run check:apk -- -TestConcurrency 2`；分批日志和清单保留，不能计为全量通过。
- 第四轮官方完整门禁于 2026 年 10 月 16 日成功退出 0：格式、应用与生成客户端分析、契约校验／再生成一致性、架构、23 个模块文档及 API 覆盖均通过；API 覆盖为 175/175、0 缺失。全量 Flutter 6605 通过、1 条既有显式 Sentry 实际上报验收跳过，耗时 19:21；Windows 发布工具 49/49 通过；同一流程完成 ARM64 Debug APK 构建，Gradle 耗时 201.3 秒。日志 `D:/codex-worktrees/mobile-sentry-upload/upload-check-apk-4.log`，SHA-256 `8ABF0D1E50BC01809D9F62E3CF88208D205E789D944CD4366F607E4C4D2F4E47`。成功不覆盖前三轮失败或主动停止记录。
- APK：`build/app/outputs/flutter-apk/app-debug.apk`，110351718 字节；包名 `site.wenyou.app.debug`，版本 `0.9.0-debug`（99），ABI `arm64-v8a`；SHA-256 `EDAD3CFED01A564D029C8840763FB604C0E5BBADF4BE700C256C986944D0B5E2`。应用源码与测试文件摘要在门禁期间保持不变，提交后仅补充验收记录不会改变此产物。
- Windows 发布工具补检：`npm run test:release-tool`，49/49 通过、退出 0；日志 `upload-release-tool.log` 保留在任务工作区外。
- 复用已提交的共享检查修正 `2a5a9216348c80e9d3e41b3bf553da0f6d7fd786`：语法树统计真正传入 `userMessage` 的旧式错误调用，阈值维持 418，不将纯类型化状态或对象模式误算作文案。待传输状态只携带诊断码，恢复提示由展示映射提供；旧仓库不支持重传时保留媒体身份与重新打开动作。
- 自动回归使用内存 Provider 与 Dio 假响应；未对线上业务执行写入 E2E。
- 独立只读代码审查未发现确定阻断缺陷，核对身份保留、重签、自动恢复、取消/切号与私聊幂等；不替代实际门禁或负责人验收。新增页面恢复接线覆盖正文、动态/评论与私聊，收藏表情沿用通用任务；头像/封面的自有包装未纳入本次恢复改造，不能宣称所有上传入口均已修复。
- 新 APK 不自动安装；负责人真机验收待完成。

## 负责人复验

在指定候选 Debug 包上分别验证正文、动态/评论及私聊：选择图片，在直传阶段断网，恢复网络后手动重试；图片与正文仍在，上传成功且业务内容只发送一次。离页重开应保留附件但不会自动重新直传；手动重试后可继续。另验证取消与切号后不会出现旧任务结果。申请地址、确认和处理阶段故障由离线回归覆盖，线上验收不人为制造服务故障。

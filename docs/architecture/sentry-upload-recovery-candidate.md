# Sentry 上传恢复候选

状态：候选／待负责人验收；不关闭 Sentry issue，不合并或部署。

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

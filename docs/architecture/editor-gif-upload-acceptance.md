# 编辑器 GIF 上传丢失排查与候选验收

状态：候选修复／待负责人验收。

## 原始反馈与复现边界

- 2026-09-13 负责人反馈：移动端主题帖内，子贴和楼层回复上传 GIF 均失败。图片“安全处理中”文案消失后，编辑器没有图片预览，发布后对应内容空白；Web 和动态发布没有该问题。
- 操作：打开上述正文编辑器 → 选择 GIF 并确认 → 等待安全处理提示消失 → 查看编辑器 → 发布查看。
- 预期：处理完成后插入可见的图片块，发布正文保留该图片。
- 尚未取得本次原始 GIF、具体帖子或真机日志；本地使用仓库现有动画夹具和可控的延迟完成上传模拟，不把构造回归等同于原图真机复现。

## 基线与已证实缺陷

- Mobile 基线：`90991ab4`；任务分支：`codex/20260913-editor-gif-insertion`。
- 固定契约、后端只读镜像 `origin/dev` 和公网 `/meta` 同为 `5.22.0-dev.20260912.2` / `6fdfa00eaf1f3056ba30f2ffbc529d12eed1c823`；无需同步契约。
- 已由旧实现失败／候选通过对照证实：上传时页面把 `RichEditorSession` 设为只读；完成回调先于下一帧页面重建，`insertBlockImage` 仍看到只读并直接返回，导致已完成媒体未进入 Markdown。动态附件不使用该插入方法。该时序缺陷不局限于 GIF，任何跨帧完成的正文图片都可能触发；原反馈 GIF 与此缺陷的对应仍需负责人真机确认。
- 目标：修正主题及帖子编辑器消费上传完成结果的时序，保留发布中、取消、离页、账号切换及不支持正文的保护。
- 范围：移动端正文插入；不修改后端、上传协议、GIF 转码或 Foundation。
- 验证：先确认延迟处理的回归在旧实现失败，再验证候选；上传相关候选按高风险入口运行 `npm run check:apk`。

## 实现与自动回归

- 主题及帖子页面仅在消费完成结果时，从当前上传与提交状态同步 `RichEditorSession.readOnly`，随后调用既有图片插入方法。仍由会话保护不支持原文；保留现有取消、离页和账号检查，不移除只读守卫，也不通过等待一帧碰运气。
- 回归文件：`test/features/editor/editor_image_upload_completion_test.dart`。共五条：主题发布、`createFloor`、`createReply`、`editPost`、`upsertBody`。实际打开编辑器、选择 GIF、确认、停留处理状态跨帧、完成后检查图片解码预览；帖子路径继续输入、提交再读回打开。
- 独立预期：原正文保留，恰好一个独占行的 `![图片](https://cdn.example.com/uploaded.gif)`，图片后的文字保留；预览加载完整 WebP 并解码出 320px 宽图片，发布正文不使用派生 URL。仓储与网络展示响应为测试夹具，不请求或改写线上帖子。
- 原件夹具：`test/fixtures/animation-webp-all-surfaces/original.gif`（320×180，2 帧，1,383 字节，SHA-256 `0b508d740ff4d60df8470b194d6a6c6e2697a88350334c04fd251c636fa4ffe7`）；展示使用同目录 `full.webp`，选图确认使用真实 PNG 预览并模拟 GIF 不裁剪。
- 旧应用源码执行上述测试：5 条全部在缺少图片 Markdown 的断言失败，实际仅剩“上传前正文”；日志 `build/editor-gif-old-regression.log`。旧回归命令外层最后打印日志返回 0，但 Flutter 报告明确为 5 个失败，不作为通过证据。
- 候选执行同一文件：5 条全部通过；命令 `flutter test test/features/editor/editor_image_upload_completion_test.dart --reporter expanded --no-pub`，日志 `build/editor-gif-candidate-regression.log`。
- 完整门禁原命令：`npm run check:apk -- -TestConcurrency 2`。负责人随后明确要求“直接跳过测试，我先验证功能先”，已停止本任务检查进程及其子进程；停止前 2,047 项通过、1 项既有跳过、无已报告失败，不宣称完整门禁通过；余下 Flutter 测试、Windows 工具测试和 Debug APK 未完成。日志 `build/editor-gif-full-check.log`。
- 应用源码候选提交：`c776acdf39ca75f51e38b7d84656f988eb39d615`。应用与生成客户端静态分析、契约及生成一致性、架构、文档与 API 覆盖均通过。停止测试后仅补充交付记录，不修改应用源码。
- 第一次 Release 构建失败：与全量测试并行时，Flutter 自动注册文件包含 `integration_test`，但 Release 不编译该测试插件，`:app:compileReleaseJavaWithJavac` 因此失败。日志 `build/editor-gif-release-build.log`；不把磁盘上旧 APK 当成新候选，也不手改自动注册文件。按负责人指令停止测试后，以标准 `flutter build apk --release --target-platform android-arm64` 串行重建，并沿用仓库外诊断配置；日志 `build/editor-gif-release-build-final.log`，无需修改应用源码。

## 真机手测与未验证项

1. 负责人追加要求“adb安装一下就行”。设备实际仅安装 `site.wenyou.app`，版本 `0.7.0 (94)`，因此构建同包名、同签名的本地 ARM64 Release 候选覆盖现有“温油站”，保留账号和数据；不把不同包名的 Debug 当成已更新当前应用。安装后核对更新时间及设备内 APK 的 SHA-256。
2. 使用专用测试账号，在原来失败的子贴正文、楼层和回复中上传同一个 GIF，等待“安全处理中”消失，确认图片出现并播放，前后文字保持。
3. 发布／保存后检查阅读态，再重新编辑，确认图片保留、播放正常；继续输入文字并再次保存。
4. 补查一张普通静态图；上传期间取消或关闭编辑器，确认不会迟到插图。存在自然上传失败时，明确重试后应只插入一张。
5. 未验证：本次原始 GIF、原手机场景、公网真实上传与发布；ADB 仅执行安装及包信息核对，不代替负责人操作页面，没有启动长期调试会话。上述自动检查不能替代负责人结果。

## 候选制品与负责人结果

安装前实际读取的手机版本：`site.wenyou.app` / `0.7.0 (94)`，更新时间 `2026-09-13 06:16:41`；APK SHA-256 `7d7579c5ba5f5511552e0832c0a53c3b3a89a5107b57b4cf76c293af75fa5092`。当前包签名证书 SHA-256 为 `4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839`。

串行 Release 重建成功（26 秒），候选归档在 `D:\code\wenyousite\wenyousite-mobile\build\candidates\editor-gif-c776acdf\wenyou-editor-gif-candidate.apk`。应用“温油站”，包名 `site.wenyou.app`，版本 `0.7.0 (94)`，大小 33,021,007 字节，SHA-256 `0c04f58ee418eca24cbfe6921e93c93b417def34753c2bbf7be95a16984723bd`；与原包同证书，仅 ARM64，16KB ZIP 对齐与发布包内容核验通过。

2026-09-13 已按负责人授权执行 `adb install -r`，返回 `Success`；设备内 `base.apk` SHA-256 与上方候选完全一致，安装后更新时间为 `2026-09-13 06:54:03`。未卸载或清除数据，负责人直接打开原来的“温油站”复验原 GIF。未向 RainS3 上传、未晋级 `/meta`，未合并任务分支。负责人尚未验收，不能标记原问题修复完成。

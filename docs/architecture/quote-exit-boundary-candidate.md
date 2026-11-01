# 引用结束边界候选验收

状态：负责人于 2026-11-01 真机验收通过；集成验证进行中。

## 原始反馈与复现

负责人于 2026-11-01 提供编辑态和阅读态截图：引用内为“如何呢＋传送门”“哈哈哈”两行，引用外第三行为“如何呢＋传送门”；保存后阅读态三行全部进入引用框。Web 编辑没有相同现象。此反馈说明移动端编辑／阅读一致性验收仍未通过，继续沿用当前候选任务处理。

未读取私帖原文，原始 Markdown、传送门地址及完整操作顺序未知。测试使用截图文字和本地示例地址，从三行引用取消第三行引用，复现同样的可编辑块与阅读块不一致；这一构造场景已证实根因，但仍需负责人复验原帖。

## 已证实原因与修改

- 保存只给引用行加 `>`，没有在其后普通正文之前补充空白分隔。CommonMark 将紧邻的无 `>` 普通行当作引用的 lazy continuation，导致阅读侧把第三行并入引用。传送门只是此例中的行内内容，纯文字同样复现。
- 编码缓冲在引用转为普通段落时确保结构分隔；编辑投影将单个引用／正文之间的分隔识别为语法，不新增可编辑空段。连续引用、行内样式及真正空行继续保留各自含义。
- 旧测试中引用后行内代码仍属于框外正文，预期相应补充结束分隔，避免仅以 Codec 往返自洽判定正确。
- 不改后端、Foundation、共享契约或线上正文。已保存的歧义 Markdown 不自动改写；原帖可在更新后重新编辑保存，验证正文仍在框外。

## 验证范围与环境

本轮为普通中风险 Markdown 转换候选，影响范围为引用到普通段落的边界，按候选流程运行精确回归、Markdown／编辑器／楼层相关测试及全量静态检查，在负责人连接的真机上启动持续 Debug。未将上一候选检查当作本轮证据；负责人验收后、合并前仍需完整门禁。

- Windows Worktree：`D:\codex-worktrees\portal-alignment-spacing\wenyousite-mobile`。
- 后端已记录 revision、只读镜像 `origin/dev` 与本次只读 `/meta` 均为 `19a6c4ed48829a781182527faaafce6e788e9e2e`，API `5.44.0-dev.20261024.3`，契约无变化。
- 旧实现：`test/features/editor/editor_quote_exit_boundary_test.dart` 两例失败；独立 CommonMark 预期 `blockquote,p`，实际只有 `blockquote`，日志 `.dart_tool/quote-exit-before.log`。
- 新增真实楼层页面离线回归：`test/features/posts/post_quote_exit_boundary_test.dart`，覆盖打开、取消引用、输入法输入、提交到 Fake Repository、阅读块结构和坐标、重开后的三行与块归属。没有进行线上业务写入。
- 首次检查 ADB 为空；负责人连接后已识别 ARM64 设备 `4b9c39b5`（2509FPN0BC），确认前台应用为 `site.wenyou.app.debug`，无其他 Flutter run 会话。按负责人要求执行 `npm run dev -- -d 4b9c39b5`，本轮使用持续 Debug，不另做独立 APK 交付。

## 负责人复验

1. 安装最新候选并打开“温油站 Debug”，进入截图原楼层编辑。
2. 保留引用内两行，确保第三行已退出引用；保存后只有前两行带引用背景。
3. 再次编辑，仍是三行且第三行在框外，不凭空增加空行。
4. 分别用普通文字、传送门及粗体／斜体正文试验退出引用；检查引用内部换行、真正空行和既有排版未受影响。

负责人于 2026-11-01 在下述持续 Debug 会话明确回复“验收通过，把以上所有改动提交合并”，确认本任务全部改动并授权合并。未读取私帖原始 Markdown；原场景结论来自负责人真机验收。合并前完整集成门禁另行记录。

## 本地测试结果

- `.dart_tool/quote-exit-regression.log`：实际执行 `test/core/markdown`，1580 项中 1578 项通过；两项既有断言仍要求引用后无分隔的旧输出，已按独立阅读语义更新，应用源码未因此追加变更。
- `.dart_tool/quote-exit-codec-verify.log`：重跑 `test/core/markdown/markdown_delta_codec_test.dart`，119 项全部通过，覆盖上述两项断言。
- `.dart_tool/quote-exit-pages.log`：以下六个文件共 80 项全部通过：
  - `test/features/editor/editor_quote_exit_boundary_test.dart`
  - `test/features/editor/editor_quote_paragraphs_test.dart`
  - `test/features/editor/editor_quote_paragraph_boundaries_test.dart`
  - `test/features/editor/editor_enter_newline_test.dart`
  - `test/features/posts/post_quote_exit_boundary_test.dart`
  - `test/features/posts/post_composer_quote_opening_test.dart`
- 本轮共覆盖 1660 项不同用例；旧实现失败／候选通过的精确回归保留独立日志。
- 五个变动 Dart 文件格式检查通过；生成 API 包全量静态检查通过。应用全量静态分析通过（254.9 秒）；模块文档检查通过。

## 持续 Debug 与负责人验收

- Worktree 与分支：当前目录，`codex/20261101-portal-alignment-spacing`；终端会话 `52219`。
- 设备 `4b9c39b5`，ARM64，启动 `npm run dev -- -d 4b9c39b5`；实际默认 API `https://wenyou.site/api/v1`，未切换地址，代理未执行线上发帖／保存。
- 2026-11-01 18:48:59（北京时间）更新 `site.wenyou.app.debug`；版本 `0.11.0-debug+101`。初装 APK 的本地与设备内 SHA-256 同为 `24A1C3CF02AB9AFB7E9CC97BDE2C98210C0207C9D51E159D2020AB9344CA67F6`。
- 首次构建 122.6 秒，安装 5.3 秒；随后原终端发送 `r`，收到 `Reloaded 0 libraries in 1,993ms`，此次应用代码与初装包一致。后续若再次改动并 reload，应以实际源码记录为准，不复用初装哈希代表热重载内容。
- 负责人明确验收通过：引用内保持两行，引用外第三行保存／阅读／重开维持边界；同时确认此前传送门对齐、紧凑行高、阅读字号同步和默认 15 号的全部改动，授权提交合并。

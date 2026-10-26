# 主动检查更新、空回复提示候选与原帖定位调查

状态：前两项候选／待负责人验收；第三项仍在调查，未复现／未解决。不合并、不发布。

## 范围与来源

- 治理任务：`01a17954-f1d8-7662-baa9-f249a5cf5886`，只修改 Windows Mobile。
- Worktree：`D:/codex-worktrees/mobile-update-reply-navigation-20261027/wenyousite-mobile`。
- 分支：`codex/20261027-mobile-update-reply-navigation`，从更新后的 `origin/dev@6601eea95ad783acf082f5ab6abc472b950b2488` 创建。宿主 Worktree 工具无法指定 Mobile 仓库，故用 `git worktree add` 隔离创建；不接管其他任务的 checkout 或 Debug 会话。
- 默认审批偏好已传递；宿主没有审批设置／核验入口，实际 Auto-review 配置尚未设置／核验。
- 固定 API `5.44.0-dev.20261024.3`，记录来源 `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`；本轮 fetch 的 Backend `origin/dev` 与公网 `/meta` 均为 `d54313346681eae8f62584d63d07f3315e42381b`。两版本的 `contracts/` 和 `docs/mobile-client-guide.md` 无差异，不改契约或生成客户端。
- Foundation fetch 后最新正式 Tag 为 `v7.6.0`，与已锁版本一致；该版只扩展 Web 颜色选择，不要求本轮迁移。

## 原始需求与候选行为

1. 首次打开取消推荐更新，后续没有主动更新入口。候选在账号设置和游客“我的”的帮助组提供“检查更新”，每次重读实际安装版本和策略，绕过自动提示的忽略／一次性记录；有更新时复用既有说明、下载校验和安装器动作。检查中防重复，关闭后可再次打开；安装器返回后的下次检查重读安装身份。策略缺失、下载未就绪和请求失败不冒报最新版。
2. 主题帖空回复进入故障样式，动态也缺少一致的就地校验。旧主题回复控制器虽在请求前拒绝空内容，却将其放进故障面板；旧动态编辑器直接调用发送回调。候选在附件准备与编码后复用同一可见内容校验和中性短提示“消息框不能为空。”，保留输入框，不发起空写入、不产生问题编号。纯图片、表情、骰子、音频及动态独立附件仍有效，图片等待与失败处理先走原流程。
3. 负责人反馈原帖在**正式版** App 定位最新回复迟迟不能完成，其他帖子及 Web 正常；实际版本号、机型、系统字体／阅读字号和现场日志仍未知。没有连接 ADB 设备，不能假定负责人已安装最新已发布版本。

## 原帖只读证据与复现边界

原帖：`https://wenyou.site/threads/cmutbun6j00au7qj2plkem82g`。

- 公共读取成功，可见性 `PUBLIC`，四个子贴；默认子贴 `cmutbun6s00ay7qj23cphiik8`。
- `/threads/cmutbun6j00au7qj2plkem82g/posts/latest` 返回 `cmvosuc9q00x27qnpcdr7lrtg`，属于第三子贴 `cmuv7lesn008u7qvxbztzghqs`，`parentPostId=null`。
- `/posts/cmvosuc9q00x27qnpcdr7lrtg` 返回 `FLOOR` 第 22 楼，主题和子贴关联正确，正文 420 字符、无回复；未发现目标 DTO 异常。
- `/subthreads/cmuv7lesn008u7qvxbztzghqs/posts/window?postId=cmvosuc9q00x27qnpcdr7lrtg&limit=20&order=OLDEST` 返回第 13～22 楼十条，`targetNumber=22`、`total=21`、`maxNumber=22`，有 before、无 after。子贴 `_count.posts=79` 包含回复，不等同于主楼层总数。
- 十条正文长度为 745、737、735、1220、1091、1266、415、1404、1075、420，包含较长嵌套回复，没有正文图片／字体标记。第三子贴正文 416 字符，默认子贴正文 919 字符并含一张图片。
- 真实页面从默认子贴点击最新入口，使用该窗口与嵌套回复：原定位实现能在 360×640／1 倍、393×851／1.3 倍、360×480／2 倍文字缩放完成定位。补载可读字体和临时原文对照的同三项也通过；原文运行后已恢复脱敏 fixture，没有提交作者或原正文。
- 提交的 fixture 将汉字替为“文”、英文替为 `x`，保留长度、段落、标点与回复结构；主题／子贴／作者 ID 为本地模型。它不覆盖正式设备实际字体、鉴权、网络时序或 GPU。匿名 API 读取正常不能替代负责人登录会话的现场核验。
- 懒列表估值下的查找停止条件及重复几何变化只是待验证假设，没有对应原帖现场的失败证据。本轮不改定位源码，不恢复负责人已取消的 PR #124。

线上仅执行读取，没有登录、签到、发帖、评论、上传或清理业务数据；本地测试采用 fake 仓储，不是写入 E2E。

## 自动检查

- 旧 `HEAD` 两处编辑器源码运行新增空回复回归均失败：主题空字符串、主题空白、动态空白共 3 项，日志 `.empty-reply-baseline.log`；恢复候选后通过。
- 首轮 4 文件 19 项通过，日志 `.reply-update-tests-final.log`。最终批次另外覆盖策略失败与真实窗口。
- 原定位的脱敏窗口、可读字体、临时原文对照均通过；原文三项日志 `.latest-real-window-raw-baseline.log`。这说明本地未复现，不能证明原问题解决。
- 最后补充 1256×2760／DPR 3.5 的分数逻辑视口与实际上下安全区；连同原三组共 4 项仍通过，日志 `.latest-real-window-fractional-baseline.log`。七档阅读字号为 13～19sp，负责人实际选择未知。
- 初次候选入口在格式阶段失败，未执行分析或构建；随后修正格式和 import 排序。架构检查同时发现跨 feature 新循环，已将更新组件归 app-shell 并由 app/routes 组合根注入个人页，未修改架构 allowlist。

最终 `candidate:apk` 覆盖全仓格式、应用和生成客户端全量静态分析、以下定向测试及 ARM64 Debug 构建：

- `test/core/application/reply_content_validation_test.dart`
- `test/features/settings/mobile_update_settings_link_test.dart`
- `test/features/app_shell/manual_mobile_update_check_test.dart`
- `test/features/app_shell/mobile_update_controller_test.dart`
- `test/features/app_shell/mobile_release_controller_test.dart`
- `test/features/app_shell/mobile_release_widgets_test.dart`
- `test/features/posts/post_composer_empty_reply_test.dart`
- `test/features/posts/post_controllers_test.dart`
- `test/features/posts/post_replies_page_test.dart`
- `test/features/moments/moment_comment_attachment_lifecycle_test.dart`
- `test/features/threads/thread_latest_real_window_test.dart`
- `test/features/users/me_page_test.dart`

另执行模块文档、架构和 diff 检查；完整 `npm run check` 在负责人验收后、合并前执行。

## 负责人真机复验

1. 打开本轮 Debug 应用 `site.wenyou.app.debug`，在账号设置点击“检查更新”。与公网推荐构建均为 101 时会显示最新版，发现新版／下载安装路径以 mock 测试验证，不为测试修改线上策略或降低版本。Debug 与正式版数据独立，本候选不代表正式应用已更新。
2. 主题帖楼层／楼中楼与动态评论／回复分别发送空字符串、仅空格换行，确认只出现空消息提示而无故障面板；输入文字或有效附件后仍可操作。线上写入由负责人手动决定，代理不自动验收写入。
3. 原问题已确认来自正式版。后续需要精确版本号和设备现场，核对登录态请求、目标、窗口、实际字体／字号和布局；继续同一任务调查，不把此前本地通过等同于正式版故障已解决。

## 独立候选制品

- 最终 `candidate:apk` 退出 0：全仓格式、应用及生成客户端全量静态分析零问题、上述 12 文件 184 项测试、ARM64 Debug APK 构建通过。`docs:check`（23 模块）、`architecture:check`、diff 检查通过。
- 应用 `lib` tree：`cf64354ad08226fd6c301ed68cc268cf7c48072f`。检查后未再修改应用源码。
- 应用候选提交：`66d4c0c59873738386a1c499e6eddc1f40458bc9`；后续仅补充本文源码身份，不使原检查或 APK 失效。
- APK：`D:/codex-worktrees/mobile-update-reply-navigation-20261027/wenyousite-mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 包名 `site.wenyou.app.debug`，版本 `0.11.0-debug`／101，仅 `arm64-v8a`，已用 Android `aapt` 核对。
- 大小 114346769 bytes，SHA-256：`2F083648F9399CDE391DDE804F6E41681377E059BE1C0AD041B0493DCBC20E1C`，构建入口与独立重算一致。
- 构建有既有 KGP 与 SDK XML 警告，退出 0；没有改动依赖或原生配置。
- 完整日志保留在本 Worktree 的 `build/validation/mobile-update-reply-20261027/`；原帖原文没有进入该目录或 Git。
- 无连接设备，没有 ADB 安装、Debug 运行或负责人真机验收，未更新正式应用；Worktree／分支与制品保留供复验和第三项继续调查。

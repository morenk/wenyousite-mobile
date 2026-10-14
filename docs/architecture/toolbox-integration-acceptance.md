# 原生工具箱集成验收

负责人已对 `d07b77bf` 对应的真机反馈批次明确授权“合并清理分支吧”。本记录汇总 PR #94 包含的原生工具 PR #93、历史与进阶起名；两者作为一个最终应用候选执行集成门禁，不要求先单独合并 #93。

## 范围与基线

- `origin/dev` 为 `65d1bd6fdcb3f6d3a1cc7bd63632a71476c0eff6`，任务分支已包含该基线及 #93 全部提交；不改写共享历史。
- 四项工具改为 Flutter 本地页面与离线算法；十一国普通双语起名、中文古风／幻想及六国 52 种可选史实／文学风格。默认普通，展开进阶才使用高级参数，收起恢复原普通输入。
- 简洁设置行、常规字重、限高结果与常显滚动条、固定复制和 1.5 秒成功提示。普通、历史 v1、进阶 v2 数据与旧 URL 策略均保留。
- Foundation 正式依赖仍为 v7.2.1。未改变业务 API、登录、存储、原生权限或构建号。

## 依赖与静态兼容清理

生产 Dart、Android、iOS 和集成测试没有 WebView 消费者，唯一剩余测试引用只断言不存在 WebView。改为检查 Android／iOS 平台视图后，正常移除 `webview_flutter`、`webview_flutter_android`、测试接口及传递 `webview_flutter_wkwebview`；锁文件仅移除四项，没有顺带升级。

完整分析器对 `Extended_Pictographic` 的诊断与同 SDK JIT／AOT 运行时不一致，修改键帽转义或正式短别名也无法通过完整分析，未将这些尝试称为修复。最终从 Unicode 16 官方属性文件生成 78 个精确区间，保留 3537 个图形码点、26 个区域指示符和键帽；用二分查找替代平台正则属性。原始文件、SHA-256 与许可见 [来源清单](../../contracts/toolbox/source-unicode-emoji.json)，生成器支持 `--check`，许可证随竖排使用注册。没有关闭 lint、构造非静态正则绕过检查或扩大字符范围。

## 当前证据与门禁

- 固定区间与原完整正则逐一比较 1,114,112 个码点，匹配集合完全一致，共 3564 个；独立测试也逐码点核对 Unicode 源文件。
- 宽度、原算法固定向量、许可与来源摘要、工具目录 Widget／Golden 合计 51 项通过；全仓 `flutter analyze --fatal-infos --fatal-warnings` 无问题，Unicode 生成一致性通过。
- 普通、历史与进阶三套词库生成及来源摘要一致，原共享版本未变。
- 对最终应用源码执行 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，最终退出 1，共两步失败，不能记作完整门禁通过。格式（1283 文件）、应用与生成客户端分析、OpenAPI／固定契约／再生成一致性、架构、23 模块文档、API 覆盖、49 项 Windows 工具测试及 Android Debug 构建均通过。
- 全量 Flutter 测试为 5942 通过、1 项预期跳过、2 项失败。跳过项是未启用 `WENYOU_VALIDATE_SENTRY` 的诊断收据验证；两项失败均为结果滚动 Golden 中“詹姆”由缺字方框恢复正常字形，布局、操作和滚动条未变。此前测试字体补字时遗漏这两张基准，本批独立复现后仅同步 `native_names_scroll_400_dark.png`、`native_names_scroll_320_2x_light.png`；原失败图与摘要保留。
- `tool_result_scroll_test.dart` 与 `name_results_visual_test.dart` 补验 7 项通过，覆盖正常字形、限高常显滚动条、完整复制、重新生成复位及键盘高度。应用源码与已完成全量门禁和 APK 构建一致，仅修正测试基准及补充文档，不机械重跑全量应用测试。
- 随后完整 `test/features/toolbox` 502 项全部通过，包含普通、历史、进阶、文字算法、Unicode 逐码点与工具 Widget／Golden 回归；没有跳过或额外失败。
- 必需的公网只读契约校验仍失败：`HandshakeException: Connection terminated during handshake`。独立复核也失败，未修改 TLS、代理、网络配置或校验脚本绕过；保留 Draft PR，等待连接恢复后补验原入口，当前不可合并。

详细日志保存在治理工作区 `.artifacts/toolbox-merge-20261014`：`mobile-check-apk.log` 保留完整失败退出；`scroll-golden-reproduction.log`、`scroll-golden-font-diff/manifest.json` 保留复现与差异；`scroll-name-results-recheck.log`、`toolbox-final-recheck.log` 记录修正后的定向复验。未操作真机、安装 APK、重启应用、访问业务写入接口、合并或发布。npm 工具链安装提示既有锁文件 10 项审计告警，未执行无关升级；不将其隐藏为已修复。

## APK 保留证据

依赖移除后的 Android Debug APK 已构建并保存到治理工作区 `.artifacts/toolbox-merge-20261014/wenyou-toolbox-integration-debug.apk`，不沿用此前热重载或旧 APK。

- applicationId：`site.wenyou.app.debug`
- 版本：`0.9.0-debug`，versionCode `99`
- ABI：`arm64-v8a`
- 大小：110,299,166 字节
- SHA-256：`3e15981d34004abe7402bc2c22c9169938667ebb60cb0dbce9e72bd46b513296`
- 包信息与摘要：同目录 `apk-badging.txt`、`apk-evidence.json`；最终提交摘要另由外置交付记录绑定。

构建成功不覆盖公网校验失败，也不代表已安装、重新进行真机验收或发布。构建输出仍提示既有 Kotlin 插件迁移和 Android SDK XML 工具版本差异，不在本批顺带升级。

## 历史证据

此前 [原生候选](native-toolbox-candidate.md)、[历史 v1 候选](historical-names-candidate.md)与[进阶 v2 候选](advanced-names-candidate.md)保留原检查及失败记录。本批负责人授权更新验收状态，不把此前定向检查充作新的完整门禁。iOS 真机与正式发布不属于本批。

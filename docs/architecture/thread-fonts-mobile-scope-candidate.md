# 正文字体作用域与粘贴候选

持续加载新要求已取代本文的旧累计预算；门禁在 5,102 项通过后主动停止，未构建此摘要的 APK。当前进度见[持续加载设计与验证](thread-fonts-mobile-continuous-loading.md)。本页保留作用域与粘贴的历史证据，不代表持续加载最终候选。

状态：候选／待负责人验收。沿用 PR #114、Backend `102b825379eb5da462f0ff765b29dc8fd7fb93ad`、API `5.41.0-dev.20261021.2`、目录 1.1.1 和 Foundation v7.6.0。新增要求只澄清产品作用域，不改变共享协议或源正文存储；未合并、部署或安装。

## 入口规则

| 入口 | 当前字体行为 |
| --- | --- |
| 主题、子贴完整正文及楼层正文 | 显式开启自定义字体，后台按需加载 |
| 展开的完整回复正文 | 显式开启自定义字体 |
| 楼层内回复预览、角色身份资料弹层 | 默认字体，保留源 Markdown，不创建字体加载作用域 |
| 帖子列表、消息列表、搜索结果、通知 | 既有 Text／纯文本摘要；不请求自定义字体。搜索返回的完整 Markdown 由共享摘要投影后显示 |
| 动态正文、动态评论、私聊 | 既有文字和站内传送门呈现；不启用自定义字体或新增格式支持 |
| 字号设置示例 | 默认字体 |
| 独立分享预览 | 当前无独立入口，不列作已验收场景 |

共享 `WenyouMarkdown`、`StickerPostMarkdown` 和 `PostReadingBody` 默认 `enableTextFonts: false`。主题正文调用点显式开启，资料弹层和楼层内回复预览明确关闭；不会通过全局主题覆盖正文，也不删除原帖 fontId。`MarkdownTextColorBuilder` 在禁用上下文保留颜色及其他合法格式，但不创建 `TextFontScope`。

## 粘贴边界

- 主题→主题：有效本站结构化载体保留白名单 fontId、颜色、粗斜体、链接等合法格式。
- 主题→动态／评论／私聊：通过同账号、未过期、marker 和可见文字均匹配的进程内载体投影；只保留文字和目标支持的 internal-reference 原子。传送门保留地址，不降成仅显示标签；动态不支持的字体、颜色及粗体不扩展进目标格式。
- 外部 HTML、CSS 字体、未知字体以及纯文本粘贴使用默认字体。未知 fontId 单独丢弃，合法颜色和其他格式保留。插入点已有字体或跨区段替换不会改变这一规则，也不修改两侧已有格式。
- 跨应用系统剪贴板仍受原平台边界限制：Mobile 的系统回退是可见纯文本，不能把 Web／原生系统剪贴板宣称为保留富文本的通道。未经进程内载体验证的 HTML 不进入动态的结构化投影；外部 URL 不会作为字体地址加载。
- 异步读取期间文档、选区或只读状态变化时停止粘贴；切号后不采用旧账号结构化结果。原子编辑器按 Delta 的实际文档长度计算插入终点。

动态、评论与私聊通过 `core/application/atomic_editor_clipboard.dart` 调用剪贴板协作接口，`productionProviderOverrides` 装配 editor 实现。没有新增 feature 直接依赖或架构豁免。

## 静默阅读与预算

阅读挂载后先显示默认字体，`TextFontScope` 自动获取目录并排队加载可见文字所需的分片；注册成功通过通知重建正文，不需要刷新或点击。加载中、缺字、离线和失败均保留可读回退，不显示下载按钮、确认、进度条、Toast 或重试入口，不接管滚动和选区。

沿用单个进程运行时及共享队列，普通 24 MiB 下载／注册、8 家族、32 faces、64 请求、15 秒超时和 64 MiB 缓存不变；失败计数不归还，不通过页面重建重置。小城原件固定 SHA 与 18,410,600 B 独立额度仍一次预留。缓存每次读取检查长度与 SHA；已注册家族重复阅读不重复读取。静默失败不意味着网络不可达时必能呈现指定字形。

## 已保留的原基线证据

- 原应用摘要 `6f70d880bb22a3026a4edb5fc5462f792acc2a2ef3954f3bf7c480cd85082e35` 的 29 款字体真实组件流程已完成：58 个亮暗流程、232 张截图，目录 `.dart_tool/thread-font-product-flow-r5`。每款执行长按选词、跨段选区、字体列表、Foundation 颜色、保存、阅读和重开，含粗斜体、链接与真实空段。窗口为 360dp 亮色、320dp 暗色 200%。截图使用已验证思源黑体作测试回退，不代表 Android 系统字体或真机内存。
- `batch-0.json` 至 `batch-7.json` 记录进程 PID、缓存目录和预算；全部重复读取为零，普通注册最高 17,826,284 B、32 请求、22 faces，含小城批次缓存 30,068,103 B。第 0 批复验使用已有缓存，其余批次为冷读取；离线资源读取不是 HTTP 请求测量。
- Mobile 自产 29 份 `.dart_tool/thread-font-product-flow-r5/mobile-exports.json`，SHA `9a63b4422b4992c2bcb1ca28b752ef404d73867c506c57d2b78b0f782c268c90`。仅自造文字与真实 Quill 序列化，不含业务数据。
- 收到 Web 97 份 Milkdown 输出，固定夹具 `test/fixtures/editor/web-font-exports-r5.json`，SHA `8e91a8e32b0dc0c108807f76ac279f9f79b5caf5cc55b62734b62f717d1ca3d6`。`editor_text_font_web_interop_test.dart` 原基线 98 项通过；独立阅读语义及 29 款硬编码文字／样式预期验证解析、插字、撤销、保存和重开。原回读 `.dart_tool/thread-font-product-flow-r5/web-mobile-reexports.json` SHA `18a84f2027021417309d271898423cee51559d1f5e9dcd5ab02598f9ea06952f`。
- 本次新增作用域和粘贴代码后，以上图片及旧 APK 继续代表原摘要，不冒充新源码结果。新源码预览与门禁单独记录。

## 新源码验证与待验收

原实现回归已失败：共享阅读器默认会调用字体服务；未知 fontId 会连同合法颜色一起丢弃。记录 `.dart_tool/thread-font-render-scope-before.log`、`.dart_tool/thread-font-paste-scope-before.log`。纯文本／CSS／未知字体在带样式光标处粘贴的原行为已满足默认字体规则，没有额外改写该流程。

相关测试首批 28 项通过：`test/core/widgets/text_font_render_scope_test.dart`、`test/features/editor/editor_text_font_paste_scope_test.dart`、`test/features/editor/editor_atomic_clipboard_test.dart`、`test/features/posts/post_identity_profile_preview_test.dart`、`test/features/search/search_repository_test.dart`。新增跨区段替换和撤销后粘贴文件 7 项通过。预览工具开发中的面板开关、空段断言和测试输入修正日志保留，不记作产品缺陷或全绿首轮。

最终应用源码摘要 `dcfa323fcb92a3c566859baf55d9da5eb12872d2c5f1896f2242e4b7ed13ea23`，共 1968 个文件，清单 `.dart_tool/thread-font-scope-final-source-manifest.json`。应用装配补充测试 4 项通过，架构检查通过。完整门禁使用 `npm run check:apk -- -TestConcurrency 2 -ContinueAfterFailure`，最终记录 `.dart_tool/thread-font-scope-final-gate-apk.log`；运行结果与 APK 证据完成后追加。

首次作用域门禁 `.dart_tool/thread-font-scope-gate-apk.log` 暴露测试文件格式、应用 import 排序及动态／私聊直接依赖 editor 的架构问题。已修正格式和排序，并使用应用协作接口替换直接依赖；因应用装配变化，在全量测试开始阶段停止旧运行，重新冻结源码并运行完整门禁，不将旧运行称为通过。

过渡摘要 `52290649…d95f408` 的离线图片保留在 `.dart_tool/thread-font-product-flow-r5/scope`，不改标最终摘要。最终预览单独输出至 `scope-final`，10 张 PNG 已复核，入口为 `scope-final/index.html`，机器记录为 `scope-final/evidence.json`，日志 `.dart_tool/thread-font-scope-final-preview.log`，测试进程 PID 37280 已退出。亮色默认入口字体服务调用及资源读取均为 0；冷加载先显示默认文字、注册后自动更新；暗色 200% 暖缓存没有新增读取。总计 6 次本地资源读取／3,385,960 B 注册包含测试界面的思源黑体回退，不能换算为公网 HTTP 请求。实际动态发布页使用展开视口；另记录紧凑编辑器 132dp 视口在 200% 字号下的初始及滚动后画面，不能把局部可见当成所有文字同时可见。

公网仍为 API 5.40，兼容门禁独立未满足；不通过部署消除。ADB 当前没有设备，本任务没有 Debug 会话，未接管其他设备。离线工具仅运行 flutter_tester，数据是内存偏好、自造文字及任务私有缓存，没有账号启动、自动签到、HTTP 或业务写入；测试完成即退出，无常驻调试进程。

负责人仍需在授权且字体资源就绪的环境验收 Android 冷暖加载、选区与滚动、真实剪贴板、列表／正文作用域和跨端读写。离线预览及自动测试不能替代负责人真机验收。

## 负责人真机复验步骤

前提：确认使用 `site.wenyou.app.debug`，并由负责人选择已授权且字体能力、目录与对象资源就绪的环境。公网未就绪时不能把默认回退视为字体加载验收通过；本任务没有安装应用。

1. 打开完整主题／子贴／楼层／展开回复，观察首屏默认字体及后台自动切换；期间滚动、选中文字，确认不要求点击下载、不出现进度或错误 UI。断网及缺字时仍能阅读。
2. 返回列表、搜索、消息、通知，打开角色资料弹层和楼层内回复预览，确认默认字体；即使同进程已加载正文指定字体，也不能污染这些入口或触发新字体资源请求。
3. 在主题编辑器对真实跨段选区选择字体、颜色及粗斜体，保存并重开；检查空段、链接和段落归属。选择默认字体后确认只清除字体属性。
4. 复制本站有字体、颜色、粗体和传送门的正文，分别粘贴到主题、动态、评论与私聊。主题保留支持格式；其余目标使用默认文字，传送门仍指向原地址。保存、重开及实际发送由负责人在授权环境操作。
5. 在带字体的光标处及跨格式替换选区粘贴纯文本、外部 HTML 和未知字体；检查新文字为默认字体、合法颜色仍保留、两侧原文字不变，撤销可恢复。跨应用系统剪贴板按纯文本边界验收，不承诺富文本通道。
6. 在亮／暗主题、窄屏与 200% 系统字号下重复阅读及动态粘贴；紧凑编辑器可滚动查看全部内容。切换账号后不得复用旧账号结构化剪贴板载体。

# 正文字体 revision 5 候选记录

状态：实现与资源验证中，待最终 29-ready 资源、稳定源码门禁及负责人验收。未合并、部署、安装或接管其他任务设备；上一批 APK 不代表本批源码。

## 固定来源与范围

- Backend `a192628fc1484990871a8d159a7324446cdf0b05`，API `5.41.0-dev.20261021.2`、目录 `1.1.0`。29 款，中文 13／日文 10／英文 6；当前 28 ready，`kaitou-yokoku-gothic` pendingSource。
- 正式 manifest SHA-256 `e793a3f4674a85840c8da2cd2a5c53f8af62c3c6256a951d269875f4cba2f1e6`，4,802,519 B；VPS 只读来源 `/tmp/thread-font-release-r5-publish`。
- Foundation 已重新 fetch 远端和 tags，最新正式 Tag 仍为 v7.6.0；已读该版本 CHANGELOG，无新增 Flutter 字体迁移。
- 契约同步独立提交 `069564bf`，补齐目录／来源 Schema 并生成客户端。OpenAPI validate、生成客户端分析、`test/core/network/audio_budget_contract_test.dart`、`tool/windows/contract_revision.test.mjs` 均通过。
- 公网只读 `/meta.contractVersion` 与 Backend `origin/dev` 仍为 `5.40.0-dev.20261018.1`，正式候选与公网不同；这是独立未满足项，不通过部署规避。

## 当前实现边界

- 固定 29 个正式 ID，移除未发布候选 `zcoolxiaowei`；旧候选内容沿用未知 ID 保留原文的通用行为，不构造退役迁移。
- 选择器按 manifest `designLanguage` 排列中文／日文／英文组，最近五款仍按账号保存、在对应组内优先显示；语言不表示字形覆盖。未知／缺失语言归“未分类”并禁用，未知 deliveryMode 回退系统字体。
- 普通单资产 6 MiB、下载及注册各 24 MiB、8 家族、32 faces、64 请求（包括声明和清单）、15 秒超时、64 MiB 缓存上限不变。
- 小城仅接受 `xiaocheng-lafeng`、`original` 单分片及 SHA `cf4a4215e562d6de6e3ee88f25fc5d47d77668d28eb3a0f2533c7290de307423`、18,410,600 B。Web/Mobile 必须是同一原始 TTF；只使用正式别名注册，不修改原文件。
- 原件独立额度在下载或缓存首次注册前一次性预留，失败／超时不退还；目录重试、清单刷新与页面重建均不能重置。已注册 face 可重复使用，普通声明或其他字体不能借用额度。它仍占用共享家族、face、请求、超时和缓存预算。
- 理论输入上限为 25,165,824 + 18,410,600 = 43,576,424 B；这不是原生内存或真机 RSS 保证。

## 验证记录

- 针对性验证 41 项通过：`test/core/text_fonts/`、`test/core/markdown/markdown_text_font_test.dart`、`test/features/editor/editor_text_font_picker_test.dart`。日志 `.dart_tool/thread-fonts-r5-targeted-final.log`。随后补充未知语言选择器场景，该文件 3 项全部通过（新增 1 项、复验 2 项），日志 `.dart_tool/thread-fonts-r5-picker-final.log`。
- 原件预算测试用模拟的已验证缓存边界隔离状态机；真实文件 SHA 和 FontLoader 注册必须由离线正式资产预览另行验证，不用模拟字节冒充真实字体。
- 1,677 个正式对象逐个 SHA-256 与大小校验通过，共 269,672,516 B；审计 `.dart_tool/thread-fonts-r5-assets-verified.json`。只读传输曾中断，分段续传后以完整对象哈希确认一致，不以传输成功代替校验。
- 28 款在真实 `WenyouMarkdown` 与 `TextFontQuillEditor` 通过实际 FontLoader 注册、原生字形区别及缺字回退光栅断言，共 56 张 360dp 亮色／320dp 暗色 200% 图片；另有 6 张真实语言分组选择器图片。目录 `.dart_tool/thread-font-preview-r5`，日志 `.dart_tool/thread-fonts-r5-preview-0.log` 至 `-6.log`。旧 16 款截图保留不覆盖。
- 日文样例为 `旅の記録 あいうカタカナゕゖ 汉语 Hello 123。`，每款日文的假名必须实际注册非 core 分片；逐款分片 ID、SHA、字节及缺字探针保存在 `batch-*.json`。小城样例包括缺失的 ASCII 引号及弯单引号，缺字光栅与显式回退相同。预览显式使用思源黑体作测试回退，不能代表 Android 系统回退或真机 RSS。
- 架构、23 模块文档检查通过。全仓 Dart 分析只发现手动预览工具的测试专用偏好 API 位置警告，已改为测试消息通道并对该文件重新分析零问题；本批稳定门禁仍会重新全量分析，不把先前警告隐藏成一次全绿。

| 批次（每进程 4 款及显式回退） | 普通注册输入 B | 独立原件 B | 请求数 | faces |
| --- | ---: | ---: | ---: | ---: |
| 0 | 8,977,976 | 0 | 14 | 6 |
| 1 | 7,679,064 | 0 | 17 | 6 |
| 2 | 16,020,068 | 0 | 24 | 14 |
| 3 | 10,765,520 | 18,410,600 | 24 | 12 |
| 4 | 11,949,620 | 0 | 30 | 20 |
| 5 | 6,942,112 | 0 | 24 | 14 |
| 6 | 1,725,648 | 0 | 15 | 5 |

批次 3 已真实加载小城原件，下载／注册／预留的独立额度均为 18,410,600 B；各批普通预算均未突破。进程 RSS 变化还包含 Widget、光栅截图和测试框架，不作为字体独占内存结论。

## 尚未执行与负责人手测

- 等待 Backend 怪盗最终 29-ready 资源锁，收到后只同步正式资产并补受影响验证。
- 稳定源码后集中执行高风险完整门禁与 APK 构建，复核上一批已修正的线程栈载荷期望和 Windows 契约文档夹具。APK 构建前仅清理本任务确认可重建的打包产物，保留旧 APK 及 ZIP 填充审计证据，随后重新核验体积、条目与包身份。
- Android 真机和跨端读写仍待负责人执行：中文／日文／英文分组、长按真实选区选字、颜色与格式组合、保存重开、恢复默认、日文假名、小城缺失引号回退、离线／预算耗尽及账号最近列表。未经负责人明确通过不标记完成。

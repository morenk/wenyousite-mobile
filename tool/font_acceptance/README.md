# Android 真实产品字体连续验收

此目录提供只读观察器，连接普通 Debug 产品的 VM Service 与 ADB。没有独立实验页，也不代替实际编辑、发布、阅读、系统剪贴板操作或负责人验收。当前状态为准备完成、真机未执行；主记录见 [持续加载记录](../../docs/architecture/thread-fonts-mobile-continuous-loading.md)。

## 启动边界

1. 使用最终固定候选及 `.dart_tool/dynamic-font-candidate-config.json`，核对 commit、sourceDigest、definesSha256、apkSha256。包名必须为 `site.wenyou.app.debug`，API 必须为 `http://127.0.0.1:38876/api/v1`。
2. 治理先核验隔离环境 runId、独立 PostgreSQL/Redis/存储、测试账号、外部副作用关闭、清理所有者及 SSH 转发目的地；loopback 不构成隔离证据。手机由负责人连接后核验 ARM64、设备/Debug 会话归属及已有数据。Debug 包不存在或数据确属本任务隔离环境时才能继续；不清除真实数据、不卸载或跨环境复用未知账号/草稿。
3. 核验安装前后包名、更新时间、设备内 APK SHA-256；仅此时安装并通过普通开发入口使用固定 APK 启动：`npm run dev -- -d <设备序号> --use-application-binary <最终APK绝对路径>`。记录实际编译配置，不能用重建的其他 APK 替代。ADB reverse 只连接登记的 38876；保留 Flutter 的独立 VM 调试转发。
4. 在真实应用登录隔离账号，进入主题编辑器，输入测试文字、长按选择，打开 **T → 字体**。固定客户端启动、目录可用后再建立观察器。治理确认双方 client-ready 后才由真实 Admin 上传、处理、预览和发布新的核心字体 ID。

Windows 本地运行（VM 地址取本任务 Flutter 输出，不写入证据或提交）：

```powershell
& D:\sdk\flutter\bin\cache\dart-sdk\bin\dart.exe run tool/font_acceptance/observe.dart --run-id <本次runId> --device <设备序号> --vm-uri <本机VM地址> --candidate .dart_tool/dynamic-font-candidate-config.json
```

观察器持续运行，在同一 stdin 会话逐行输入：

```json
{"stage":"client-ready","fontIds":[]}
{"stage":"first-version-selected","fontIds":["tfv_实际32位小写十六进制ID"]}
```

示例第二行必须换成真实合法 ID。每阶段最多32个 ID，阶段名不能重复。输出位于 `build/font-acceptance/<runId>/<stage>/`，包含实际截图、原始 `dumpsys meminfo` 与结构化快照；`session.json` 固定进程与 APK 身份。阶段结果始终 `checkpointAck:false`，由治理核对证据后另行 ack，观察器不推进后端状态。

## 产品操作及检查点

| 阶段 | 真实产品动作与独立核对 |
| --- | --- |
| client-ready | 双方固定构建和进程，记录初始目录、账本、PSS/RSS；此时核心新 ID 尚不存在。 |
| published-picker | 等治理发布新 ID 后重开 T → 字体，核对中/日/英/其他语言组、名称、PNG 样张；仅浏览选择器不能增加原生注册。 |
| selected-published-read | 选择含粗体/颜色的文字，应用新字体，发布并阅读。核对可见字符、样式、段落和服务端原文实际版本 ID；不能只看账本判断字形正确。 |
| clipboard-save-reopen | 在真实阅读/编辑界面长按“复制”，进入另一真实编辑器通过 Android 系统“粘贴”，保存并重开。逐项核对可见文字、段落、字体 ID 和其他样式；禁止直接调用 Codec、服务或 VM 修改文档充当系统剪贴板验收。 |
| offline-restored | 先取得在线可信资源，只移除本次 38876 reverse，保持 VM 转发/进程；重开已缓存正文并采样，再恢复同一登记入口。不得切到公网或用全局断网破坏其他任务。 |
| second-version | 治理收到上一阶段 ack 后才发布第二版本；新选择显示当前版本，旧帖子保留第一版本且继续呈现。 |
| disabled | 停用后不能新增选择/粘贴，历史正文仍按旧版本阅读；保存重开不清洗原源文。 |
| withdrawn | 撤回后对应动态 v2 及映射 v1 均回到默认，原文 ID 保留，不能继续取被撤回资源。离线重开及恢复前台不能复活。 |
| rollback-repeat | 仅回滚到允许的已发布版本，不复活撤回版本；重复阅读/编辑同一 SHA+family 不增加注册键。对照每阶段实际 PSS/RSS、Dart heap/external 与累计注册输入，各指标分别报告。 |

每阶段均在画面稳定后采样并人工检查 PNG，附后端只读源文核对及治理 checkpoint 引用；不要保存账号凭据、Token 或真实私信。截图只能来自隔离测试内容。新版本、停用、撤回和回滚必须等待治理 ack 后才能推进；不能把一张最终截图回填多个阶段。

## 连续性及证据限制

- 观察器核对设备、PID、`/proc` 启动 ticks、APK SHA、VM 启动时间及 main isolate；持续监听 isolate group 的 `IsolateReload`、isolate 退出与连接中断。变化即停止，不允许断开后用同一目录续接。核心旅程不得热重载/热重启、重装、清数据或换 APK；若发生，交治理判断重新开始。
- 所有采样是只读固定表达式、内存查询和 ADB 读取；不强制 GC，不重置原生账本。不接收任意 VM 表达式，不执行业务写入或 UI 输入。
- 原生账本的 `chargedInputBytes` 是已尝试注册的输入成本，失败也占额度。它不等于原生实际内存；PSS/RSS 来自设备实际 `dumpsys`/`proc`，缺失即报错而不填零。
- VM 的只读求值和截图会引入少量测量开销，单次 PSS 波动不能单独归因于字体。保持相同采样顺序并结合重复访问趋势。
- `quit` 只结束观察器，结束记录仍为 `acceptancePassed:false`；实际验收由负责人单独记录。清理由隔离环境所有者执行并登记。
- `test/tool/font_acceptance_probe_test.dart` 验证参数边界、进程身份、PSS 解析，以及真实桌面 Dart VM 的私有账本读取、长 JSON 与 reload 拒绝。桌面夹具不构成 Android 产品、字形、发布或剪贴板证据。

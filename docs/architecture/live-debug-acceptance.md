# 持续 Debug 候选验收

状态：候选／待负责人验收。该记录区分自动检查、隔离样本真机验证与真实快照验收，未验证项不由其他证据代替。

## 源码与协议

- Mobile 基线：`8d6ba3e4`，任务分支 `codex/20260926-mobile-live-debug`，最终提交见 PR。
- 私有开发协议来源：Backend `5d02f6cf0d927f83f122c71ffcf53dc7c15bcc1b`；同步文件与 SHA-256 在 `contracts/dev-preview-session-source.json`。
- 业务 OpenAPI、Foundation 与数据库 Schema 无变化。原 Token、偏好与数据库文件不迁移、不清理；新增 runId 命名空间承载预览数据。

## 自动检查

定向检查覆盖 `test/core/config`、`test/core/network/preview_identity_test.dart`、`test/core/storage`、`test/features/media/media_picker_recovery_test.dart`。控制工具覆盖 RPC 并发／超时／失联、重载与重启参数、所有权与设备冲突、非法描述、身份错误与重定向、真实 loopback 端口占用、Windows ACL、临时不可用恢复、Named Mutex 并发与异常释放、迟到 daemon、实际 Windows Job 强杀根进程／wrapper／daemon 后回收编译后代、双向 machine 管道与参数引用。补充实际 Mutex＋HTTP 并发 start/stop、ADB guard 参数与管道、安装失败回退拒绝、marker 独占锁回归。

首次收集运行发现纯 Dart 契约工具依赖 Flutter foundation、预览文字未消费语义字体与启动错误文案三项问题，均已修正并单项复核。以下门禁针对同一冻结 Dart 源码分步完成；不声称单次 `check:apk` 返回零：

| 阶段 | 结果 |
| --- | --- |
| OpenAPI 校验、固定来源校验、API 重新生成无漂移 | 通过 |
| 公网契约兼容性（只读） | 通过，API/bundle `5.26.0-dev.20260922.3` |
| Dart 格式 | 1096 文件、零变化 |
| 应用 analyze | 完整入口发生 native crash，退出 `-1073740791`；独立重跑 100.2 秒，零问题 |
| 生成客户端 analyze、架构、文档、API 覆盖 | 通过；160/160 消费端 API；保留既有架构尺寸提示 |
| 全量 Flutter 回归 | 4846 通过、1 项既有跳过；两个测试进程因明确 `Dart VM Out of memory` 中断 |
| 未完成文件恢复 | `home_page_test.dart` 与 `thread_compose_page_test.dart` 单并发补跑 47 项全部通过；与全量已通过项有重叠，不累加计数 |
| 发布与开发工具 | 串行 47 项全部通过，其中开发会话工具 29 项 |
| ARM64 Debug 构建 | 通过，31.2 秒；仅作为质量门禁产物，没有安装到设备 |

全量的每个测试文件均取得成功结果。工具测试改为串行执行，降低本机并发进程内存开销；后续仅 Node/PowerShell/C# 工具修复未修改冻结 Dart 源码，按影响范围复验。

质量门禁 APK：`build/app/outputs/flutter-apk/app-debug.apk`，`109269468` 字节，SHA-256 `54f284055e153849a805af423a7a9bb45f3f4a9f6cc7c9a9551105d63db9ccab`。它是普通 Debug 构建，不是已连接隔离预览的真机会话产物；预览首次启动仍由 `dev:start` 注入已核验的批次配置。源码内容摘要为 `373d71eedcd00c68e9ce45fa9e4b650b03c3b62c146f84bb9f6a9814c72baf51`，最终提交见 PR。

ADB guard 另由真实 Flutter SDK 的 `devices --machine` 核验确实使用私有 guard；共享 `adb.exe` 和全局 `.flutter_settings` 的 SHA-256 前后不变。覆盖安装失败后的卸载回退返回拒绝码，未启动第二次安装；独占打开 marker 时仍保留命令参数与退出码。核验证据不足时拒绝安装。

### 既有 Golden 修复证据

首次全量运行还发现 `thread_management_page_test.dart` 的“320dp 两倍字体的主贴权限设置与完整选项无溢出”（2587 像素，0.81%）和“360dp 主题设置自动保存视觉基线”（2630 像素，0.91%）失败。差异仅在设置行字重；本任务没有修改该页面、共享设置行或主题。

以 `git archive 8d6ba3e4` 导出精确已提交基线，在同一 Windows、Flutter SDK 和固定字体下执行 `flutter test --concurrency=1 test/features/threads/thread_management_page_test.dart`，得到 29 通过、相同两项失败。两边实际图片 SHA-256 完全一致：

| 图片 | 基线与本任务实际图片 SHA-256 |
| --- | --- |
| `thread_management_settings_360.png` | `87bfdfd6ea7ef969a5a287aadac4a2757a0c540a8403e8d7ef3d4ba0d65cc3e2` |
| `thread_management_policy_320_text_2x.png` | `15b67675271e2d971773d0fd5da27bd25c6dad07239a39aa1b65dee786405f3a` |

前次合并 `36e38d99b8d4533eee55e0d38bf90758f9dd0358` 已明确“设置行常规字重”，对应 `WenyouSettingsRow` 的 `FontWeight.w400`；旧 Golden 未随该合并更新。治理任务查看两张差异图并核对代码后，同意仅补这两张遗漏基线。图片来自精确基线运行结果，不改应用 UI，也未批量更新 Golden。

## 联合真机验证

Backend 隔离样本批次 `live-preview-acceptance`，资源 runId `preview_accdd1c57a509345ecd740db`，快照时间 `2026-09-25T19:56:12.739Z`。这是独立样本数据库，不是线上用户快照。治理桥接先持有 API、媒体和 Web 隧道，Mobile 借用 API 与媒体转发。

交付时 `adb devices` 为空，原设备 `4b9c39b5` 已断连；未安装 APK、未建立 Flutter 真机会话。设备重新连接后，验收需要记录：初装应用包、设备内 APK 哈希与更新时间；三轮样式调整前后同一 Flutter appId、Android 进程、源码摘要和页面状态；热重启结果；还原临时样式后的源码摘要与截图。每轮不得重装，结束后保留 Debug 会话供负责人查看。

## Mobile 真实 Repository 隔离联验

Windows Flutter 测试直接使用应用的 `ApiAuthRepository`、`PreviewIdentityVerifier`、`PreviewIdentityInterceptor` 和 `ApiMediaUploadRepository`，访问治理已核验的真实隔离实例；未使用 mock 响应。登录前及每次业务请求、上传前核验双方身份，凭据仅从 VPS 私有样例文件读取，不输出或提交。

样例登录成功；读取 Web 刚编辑的动态 `cmuhecuhj00137qiecgyapckd`，标题“隔离预览联验：Web 与 Mobile”、版本 `2` 与 Web 一致。以下四种 purpose 均实际完成获取预签名 URL、PUT、确认、Worker 处理及媒体 GET 200，每张最终原图读取 `10962` 字节：

| purpose | 隔离 mediaId |
| --- | --- |
| moment | `cmuhemd8y001e7qie32r1vxsc` |
| avatar | `cmuhenpkm001g7qiec5mqbprv` |
| profileCover | `cmuheo08h001i7qietxv7q0nf` |
| richContent | `cmuheoxxz001k7qie55ae43h4` |

这些对象属于同一持续预览批次，保留供反馈，未清理其他任务。该检查验证真实 Mobile 网络与上传代码，不代表真机选图、换头像交互、图片删除或人工视觉验收通过。真机当前断连时不安装、不启动新会话，也不以这项非设备证据替代三轮热重载验收。

## 未覆盖项

- 当天真实快照尚需管理入口独立审核启用；原账号密码登录与历史真实图片尚不作为通过项。
- 负责人对页面观感和完整图片选择／上传的真机验收仍需明确反馈。Backend 隔离上传链路与 Mobile 自动测试不代替人工端到端结果。
- 未合并、未部署、未发布或清理其他任务。样例密码、Token、私有 consumer、控制 token 和调试日志不提交到 Git。

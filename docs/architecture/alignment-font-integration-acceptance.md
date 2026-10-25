# 标题间距验收与字体基线集成

## 验收与来源

2026-10-24，负责人明确回复“验收通过，合并吧”。原验收提交为 `a0865abe875c3d18151ffe3a0141adaf3ec58192`，ARM64 Debug APK SHA-256 为 `d1a5cb0002f0b45d20a7c2b2789a4854fdb2d4e8868a0f07bdb9e03cce264217`，构建输入树为 `9fb5ab4f0e7c2c6b2504ea9bb5a736dcb26f50e1`。原证据见[标题间距候选](editor-alignment-spacing-candidate.md)。

PR #115 合并准备时，`origin/dev` 已包含 PR #114 的完整字体实现。沿用同一任务、Worktree 和分支，将 `06a3fdb22fee7a25009de7c316058e1b23bcc6be` 集成到原候选，不改写已推送历史。集成后的自动检查与新构建单独记录，不冒称再次真机验收；未安装、启动应用或执行线上业务写入。

本轮只读公网与 Backend 已提交来源为 `c80f015402e22647bbc85aecc9513d3d1a026096`／API `5.44.0-dev.20261024.2`。逐项比较同步脚本的全部导出路径，相对字体基线 `f1025db4ef0d4986f53a4beffac6514d7ee16357` 内容零差异，仅来源元数据变化。契约由原脚本精确导出，客户端重新生成；单独固定的列表／行内组合夹具保留原来源清单。Foundation fetch 后最新正式版本仍为 `v7.6.0`。

## 冲突处理

- 保留已合并的动态字体编辑、阅读、下载缓存、v1/v2 协商、撤回和保源行为；覆盖分类沿用已实现能力，不再登记字体为计划接入。
- 保留标题行距的 Quill 固定补丁、阅读 strut 与真实标题分段边界；700 行提醒／1200 行硬上限和第三方完整性门禁与字体边界白名单并存。
- 请求测试改为字体能力启用时发送 v2 声明；保留真实 HTTP 状态、已知错误枚举和预期拒绝分类的更强断言，使用已支持字体后的恢复提示。
- 保留 `contracts/archive/thread-font-xiaocheng-lafeng-v1.json` 历史来源。移除本切片新增且哈希相同、无引用的根目录重复副本；Windows 契约夹具按真实嵌套目标路径逐字断言。
- 新增离线已注册字体、颜色、粗体与 H2/H3 标题的阅读几何回归，覆盖左→中→右→左，直接验证字形顶部／高度和实际字体样式，禁止在线下载测试资源。

## 检查记录

构建前严格生产只读核验通过 API `5.44.0-dev.20261024.2`、精确 buildSha `c80f0154` 及公开主题 Schema。以下分别记录准备阶段、完整门禁与交付前来源复核；原候选门禁历史不复用为本轮通过证据。

准备阶段生成器曾被 Windows 文件映射锁阻止，原命令重试后旧 build_runner 缓存静止，局部重建缓存恢复；没有修改共享缓存或生成源码。首轮完整检查误将诊断缓存中的 Dart 文件纳入分析，移出产品 Worktree 后应用与生成客户端严格分析通过，分析规则没有放宽。

第二轮完整入口的 Flutter 测试为 7765 通过、1 条原条件跳过、1 条既有缓存测试超时，未进入 APK 构建。该测试把首次临时磁盘建目录／扫描／索引 flush 也纳入“完整网络字节已到后”的 2 秒限制，单独重跑原文件 7 项通过。测试夹具新增 `putStarted` 信号：确认慢写入已开始后对原加载 Future 保留 2 秒限制，同时仍断言写入挂起、次数与字节。生产代码不变。临时测试替身故意等待 `holdWrites` 后才返回，2 秒超时被捕获；替身撤回后再验证正常路径，不延长上限、不跳过测试。诊断 Dart 源码保存在产品 Worktree 外。

第三轮官方 `npm run check:apk -- -TestConcurrency 2` 完整成功，退出码 0，日志 `build/alignment-integration-full-gate-3.log`。构建输入树为 `f585686159136c5c4524a4c854f4cefe4577c03a`，相对初始集成树 `124d66f2` 仅上述测试和验收说明变化，应用源码不变。

| 检查 | 第三轮结果 |
| --- | --- |
| OpenAPI、固定来源、生成一致性、严格生产兼容 | 通过；检查时线上为 `c80f0154`／API 5.44 .2 |
| 格式与严格静态分析 | 1527 文件零格式修改；应用分析 229.8 秒及生成客户端均无问题 |
| 架构、第三方完整性、文档 | 通过，23 个模块；保留字体边界白名单 |
| API 范围 | 175/175，零缺失；96 项范围外（raw 175/271） |
| Flutter 全量 | 7766 通过，1 条原条件跳过，零失败，32 分 11 秒 |
| Windows 工具 | 49 通过，零失败 |
| ARM64 Debug | 同次入口成功，165.0 秒 |

唯一跳过为显式 Sentry 接收验证未设置 `WENYOU_VALIDATE_SENTRY`，没有对外发送测试事件。既有 `flutter_image_compress_common` Kotlin Gradle Plugin 迁移提示保留。

本轮 APK 固定为 `build/wenyou-mobile-alignment-integration-20261024-f5856861.apk`，155984289 字节，SHA-256 `2e3122b88b52e9a0956d23dd4de2f91897a20fe15ec168475953e976adb2dc75`。应用名“温油站 Debug”，包名 `site.wenyou.app.debug`，版本 `0.10.0-debug`／`100`，仅 ARM64。该包对应上述集成树；原已验收 APK 不被覆盖，未声称本集成包再次真机验收。

## 交付前后端来源复核

构建结束后线上切到 Backend PR #61 合并提交 `31f39ff317e56d6eb49b4c5e60ecdb93dfc9ec06`，API 仍为 `5.44.0-dev.20261024.2`。首次交付复核按精确 SHA 拒绝，未绕过校验。比较 `c80f0154..31f39ff3`：`contracts/` 全部零差异，同步脚本所有导出路径仅 `docs/dynamic-text-fonts.md` 增加 8 行字体 Worker 沙箱与同单元预检的运维说明。按已提交来源重新同步，仅来源 SHA、说明及来源断言变化；窄复核结果单独记录，不重复应用全测或构建。

构建命令没有固定来源 SHA 的 `dart-define`，`lib/` 与 Android 没有读取 `backend-contract.properties`，该文件也不在 Flutter assets 中；来源 SHA 不嵌入 APK 运行时。APK 仍明确绑定构建树 `f5856861` 和构建时来源 `c80f0154`，不冒称重新编译。

交付窄复核全部通过：OpenAPI 校验、列表及行内组合固定来源校验、5.44 来源断言测试、Windows 工具 49 项、23 模块文档检查，以及最新 `31f39ff3` 的严格生产与公开主题 Schema 核验。日志分别为 `alignment-integration-final-contract-checks.log`、`alignment-integration-final-windows-tools.log`、`alignment-integration-final-docs.log`、`alignment-integration-final-production.log`。最终提交相对构建树仅来源元数据、8 行运维说明、来源测试断言与验收文档变化，应用／依赖／Android／生成客户端零差异。

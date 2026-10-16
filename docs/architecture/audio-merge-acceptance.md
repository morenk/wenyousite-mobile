# 音频与工具栏合并检查

本记录对应用户授权“可以合并分支清理了”，范围仅工具栏 PR98 与音频 PR102。没有正式包发布、部署、安装、设备启动或线上业务写入授权扩张。

## 固定输入与例外

- PR98 最终 head `dc3525209306b4682feac53f2260cfa724152d8e`，合并提交 `d8023684f7b548d365eeb5d74231dd3a514c9d86`，两树相同；历史依赖 Foundation 7.2.1。其原完整检查后的四张个人页 Golden 仅补入已授权的工具栏偏好入口，8 项最终对照通过。日志与旧 APK 已外存，任务分支和 Worktree 已核验清理。
- PR102 正常合入 PR98 和最新 `dev`，不重写共享历史。最终依赖 Foundation 正式 `v7.4.0`／`a03b5c24ea7dcdaa2ba07c962f58434bdb40965d`，Backend 已合并 `7f95563edd8f461ebb7a66d7b458ec0349e39297`／API `5.39.0-dev.20261017.1`。
- 线上只读观察仍是 `d3577839dc537e21c546ee385a4c97091b58a8f7`／API `5.38.0-dev.20261016.1`。成功 DTO 与 Markdown 不变，差异是预算错误及版本元数据。负责人明确“允许本批延期该项，其余门禁通过后合并”，仅延期生产精确版本检查；检查器未改，含该失败的完整命令不能报告为全绿。
- 本仓库 GitHub workflow 为 0，不恢复 CI、不使用 admin bypass；本地 Windows 完整门禁仍必须满足其他全部项目。

## 首轮失败与集中修复

应用源码 `0c0723f27c2c7b44e26165492e137f3c8db3d814` 的 `.buildlog/audio-final-merge-gate.log`：Flutter 6813 通过、1 跳过、24 失败，Windows 工具 48 通过、1 失败。已完整收集这两阶段；主动终止本任务门禁父进程，避免为待修旧树重复构建 APK。该轮不记成功。

- 中央行内矩阵 1 项失败涉及 256 个组合：链接来源切换曾提前 flush 整段，造成重开后的规范拼写改变。修复改为保存 run identity，在 link 边界闭合／重开，不截断段落上下文。原 9216／2304 邻接矩阵断言不改；新增 13 项直接阅读 AST 的链接数量、逐字 marks 与音频信任检查。不同来源（含 null／known）不合并，同一原链接跨 marks 可升级音频。
- 工具栏 4 项、设置页 3 项是新增音频 ID 后的旧 fixture 期待：能力关闭隐藏动作，但已保存 ID 的位置仍保留；显式补充有能力回调可执行，不靠过滤所有 audio 掩盖行为。
- 图片等待 3 项更新为共用附件队列的既有提示“还有 1 个附件未就绪”；保留锁定、取消、完成后单次创建断言。
- 11 张楼层／楼中楼定位入口 Golden 只反映已获准的 w600→w500；逐张查看 diff，未改字号、布局、阈值或普通非交互计数。独立讨论“2 条回复”是与“所有人”同排的定位入口，调用 `post_replies_page._openNumber`，属于同一请求范围。
- 2 项用户文案门禁进一步暴露新增旧式 `ApiFailure(userMessage)`。音频使用 application 层类型化原因，展示层集中映射，不提高既有债务上限。文件长度校验错误保持大小变化语义，取消与恢复行为不变。
- Windows 契约来源测试夹具缺音频与颜色契约文档；补齐固定来源文件，并逐字核验新增同步结果，不放宽缺文件拒绝。
- 架构 README 依赖版本、文档示例 URL 编码及 API 覆盖排除清单已按真实输入修正并独立复验；最终完整门禁将再次覆盖，旧失败日志保留。

## 修复后验证

- `.buildlog/audio-merge-fixes-first.log`：90 项通过，另 1 个旧式构造计数断言失败随后修复；该命令不记全过。
- `.buildlog/audio-failure-classification-recheck.log`：音频仓储／私有存储／队列及用户提示 28 项通过。首次分类构造使用不支持的 const switch 编译失败，改为等价常量条件表达式后补验，原失败保留。
- `.buildlog/audio-page-golden-final.log`：受影响页面、11 张最终 Golden 与队列断言 111 项通过。
- `.buildlog/audio-media-wait-final.log`：等待发布与取消组 4 项通过。
- `.buildlog/audio-contract-fixture-final.log`：固定契约导出、篡改拒绝与来源祖先限制 1 项通过。
- `.buildlog/audio-codec-interaction-final.log`：编辑态音频投影／选区／剪贴板、普通行内组合与跨入口交互 67 项通过。
- `.buildlog/audio-merge-fixes-analyze.log`：13 个变更 Dart 文件 No issues found；同批格式检查 0 变化，`git diff --check` 通过。
- 冻结源码的最终完整门禁结果将在收尾补入；此时仍不能声称 PR102 已满足合并条件。

`531775c4` 的下一轮完整门禁 `.buildlog/audio-final-frozen-gate.log` 通过契约／生成／格式、应用和 SDK 分析、文档与 API 覆盖，但架构发现 data 经 ports 转导出依赖非端口 application 文件。Flutter 刚开始时（477 通过、1 跳过）停止该轮，避免浪费旧树验证和构建。失败 enum／exception 属于上传端口协议，已直接收归 `audio_upload_ports.dart`，不修改 allowlist。`.buildlog/audio-failure-port-architecture.log` 通过，`.buildlog/audio-failure-port-final.log` 故障分类／仓储／队列 24 项通过；最终完整门禁重新绑定修正后的源码。

## 保留边界

`4ccc6c91` 的 `.buildlog/audio-final-port-gate.log` 已通过契约／生成／格式、应用与 SDK 分析、架构、文档及 API 覆盖；Flutter 执行到 4079 通过、1 跳过、24 失败时主动停止本任务门禁与测试进程，未执行该旧树 APK 构建。24 项为 v7 链接首／中／尾的普通输入：Quill 继承公开 link URL，却未继承内部来源，严格来源编码因此将续写拆开。修复限定在普通 String 输入的同一次 literal formatting，根据插入后的实际 URL 与插入前唯一来源匹配；不放宽编码器的 null／known 和不同原链接边界。原 v7 fixture 及期待未修改，完整该组 133 项复验通过。

新增来源交互回归覆盖首／中／尾、跨 marks 选区替换、不同 URL、相邻同 URL 不同来源、跨两个来源的替换、结构化粘贴、null／known 外来 Delta 与一步撤销／重做。首轮新增测试有 3 个断言错误地限定 strong 必须在 link 内，独立 Markdown 语义允许外包，已改为直接读取 AST 的逐字 marks；原失败日志保留。`.buildlog/audio-editor-complete-regression.log` 完整执行 `test/core/markdown` 与 `test/features/editor` 两目录，2580 项全部通过（含上述 13 项、完整 v7、中央邻接矩阵及现有粘贴／音频交互），耗时 3 分 40 秒。`.buildlog/audio-link-continuation-analyze.log` 两个变更 Dart 文件 No issues found，`.buildlog/audio-link-continuation-architecture.log` 架构通过。下一轮完整门禁绑定此后冻结的源码。

负责人已确认原帖音频显示修复成功；本批只读手机证据仍沿原记录，本轮不操作手机。新增传输 Provider／装配不能以旧实例热重载冒充已应用。iOS 保存入口未经过 Xcode 编译；用户“刚上传单音频发送失败”的旧诊断未能唯一复现，不把模拟完成页面回归称为真实线上上传验证。最终 APK 仅交付，不安装，不自动冷启动或热重启登录应用。

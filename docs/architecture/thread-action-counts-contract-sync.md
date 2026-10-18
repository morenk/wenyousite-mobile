# 主题底栏真实统计契约同步

本 chore 从已提交并推送的 Backend `da68203a494c6d0f6d377c23399390c2cee397f3`（`codex/20261018-thread-action-counts`）同步 API `5.40.0-dev.20261018.1`，仅更新固定契约、生成 SDK 和来源文档。Git 中原始 OpenAPI SHA-256 已核验为 `2ec476d48879be46bfbb6f2bf762631300a1b89b9307298e610135b398b059de`；官方脚本继续规范化两处既有重复参数。

`ThreadDetailResponseDto` 新增可选 `bookmarkCount` 和 `subscriberCount`。权威总数来自 GET 主题详情；收藏按有效账号真实收藏关系统计，订阅只统计有效账号显式 `THREAD` 官方更新订阅，自动通知与 `USER` 玩家发言订阅不计入。创建或修改响应共用 DTO，不保证带总数；业务消费者须读取详情，不从 mutation 响应或当前用户布尔状态推算。

可选字段保证旧响应仍可解码，缺失保持未知，真实 0 才显示 0。此切片不添加业务映射或展示，不删除旧协议，不修改 Foundation 正式 `v7.5.0`。此前同任务未提交的已验收圆角和布局修改保留在工作区，不混入该 chore 的暂存内容。消费者接入、完整 `check:apk` 与真机验收按后续提交记录。

官方同步与生成成功，OpenAPI 校验、固定契约来源检查、生成 SDK 全量静态分析、既有详情仓储 12 项测试和 23 模块文档检查通过。生成 diff 仅涉及 SDK 版本说明与两个可选整数及其序列化代码；同步语料其余变化仅为契约版本号。官方生成器仍固定 7.23.0，按原 lock 安装缺失的 Node 工具，没有升级依赖。初次生成因工具尚未安装而停止，安装后重跑成功；已有 `json_serializable` 未知 builder 提示保留，不在本切片调整生成配置。

## 最终合并来源

Backend PR #55 已合并至 dev，最终固定 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`。再次执行官方同步脚本后，只有 `backend-contract.properties` 中 revision 改变，OpenAPI、Markdown fixtures、生成器输入和已生成 SDK 与 `da68203a` 完全相同。本来源 chore 保留工作区业务候选，不混入 UI 或控制器改动；完整 `check:apk` 待精确部署确认后执行。

首次完整门禁在 API 覆盖登记处发现旧 5.39 审查版本尚未同步，停止于全量 Flutter 测试之前。再次逐项对比旧、新 OpenAPI 的 248 个 operationId，新增和删除均为 0；保留所有排除项目及理由，仅将登记版本更新为 5.40，重新运行严格覆盖检查。不将该元数据遗漏当作应用门禁通过，首轮日志保留，后续重跑官方完整入口。

第二轮完整门禁已跑完全部 Flutter 测试：7241 通过、1 项既有跳过，仅原音频兼容测试固定旧 API 版本／后端 SHA 的来源断言失败。同步该测试到 5.40／最终 6e00c403，原有 6 个音频／颜色错误码及旧 42900 兼容断言保持，定向复验通过；应用 37f9cc9d 未改变。失败日志 `.dart_tool/action-counts-full-check-apk-final.log` 保留，后续官方完整绿色轮次另行登记，不把单项修正冒称完整门禁通过。

最终第三轮官方完整 `check:apk` 已返回 0：生产精确来源 `6e00c403`、全部静态／生成／覆盖门禁、7242 项 Flutter 测试（1 项既有跳过）、49 项工具测试和 Debug APK 构建均通过。来源调整没有改变冻结应用 `37f9cc9d`，候选 APK `cb237f57` 与详细证据见[本批验收记录](compact-bottom-actions-acceptance.md#最终完整门禁与候选-apk)。

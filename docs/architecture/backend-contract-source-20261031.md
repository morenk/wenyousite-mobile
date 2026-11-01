# 0.12.0 发布准备的后端来源复核

2026-10-31 公网只读 `/meta` 返回 Backend `19a6c4ed48829a781182527faaafce6e788e9e2e`、API `5.44.0-dev.20261024.3`，Android 推荐 build 101、最低支持构建号 null。原固定来源 `d54313346681eae8f62584d63d07f3315e42381b` 已落后。

更新 Windows 后端只读镜像远端引用后，通过 `tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Revision 19a6c4ed48829a781182527faaafce6e788e9e2e -SkipFetch` 从已提交来源同步。实际契约 diff 仅有 `contracts/backend-contract.properties` 的 revision；OpenAPI、Markdown/字体 fixtures、消费者指南与生成客户端均不变。后端新增聚合事务等待控制和安全错误诊断，无 Mobile 协议迁移，不修改 Foundation 或弃用登记。

本地来源 Markdown v4、线上 Markdown v5 均在客户端既有兼容范围。23 个模块追加当前来源登记，既有来源记录保留；`audio_budget_contract_test.dart` 的精确 revision 断言随已核验事实更新，没有泛化断言或跳过检查。应用、依赖与原生源码保持 `dev@51a5edee`。

本轮检查结果与签名候选见[发布准备](mobile-0.12.0-release-preparation.md)。Windows 后端镜像只用于读取已提交契约，没有修改、构建、启动或部署后端；线上自动化只读。

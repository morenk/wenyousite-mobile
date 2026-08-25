# API 生成

## 固定输入与版本

- 输入：[`contracts/openapi.json`](../../contracts/openapi.json)
- 生成器 CLI：`@openapitools/openapi-generator-cli` 2.40.1（Node.js 22+）
- OpenAPI Generator：7.23.0
- 目标：`dart-dio`，默认 `built_value` 序列化，开启未知枚举降级
- 输出：`packages/wenyou_api`

生成代码禁止手改。`tool/normalize_generated_api.dart` 只修正生成包的 Dart SDK 下限、保留其锁文件、清理序列化模式切换后遗留的辅助文件，并补齐 OpenAPI Generator 7.23.0 在 paginated `allOf` 模型中遗漏的共享成功码 import；这些归一化均由生成器输出形态触发且有一致性检查，不承载业务补丁。生成完成后必须执行根项目 `flutter pub get`，让 Flutter 的 package config 同步生成包的 Dart 语言版本。

后端契约同步时会先运行 `tool/normalize_synced_contract.dart`：它只删除同一 operation 内 `in + name` 相同且 JSON 内容完全一致的重复参数；同名参数内容不一致时立即失败。该边界用于兼容 OpenAPI Generator 无法接受的重复声明，不改变接口语义，也不允许承载移动端私有 Schema 修补。

## 命令

```bash
npm ci
npm run api:validate
npm run api:generate
npm run api:check
dart run tool/audit_api_coverage.dart
dart run tool/audit_api_coverage.dart --require-complete
```

`api:check` 重新生成并检查 Git diff。契约变化先独立同步：运行 `tool/sync_backend_contract.ps1`，审查 OpenAPI、脚本自动发现的当前版本 Markdown 规范化/可见性语料、扩展节点与编辑器往返语料、mobile push v1 Schema/样例、移动 V1 状态旅程与 operationId 分类、动态分类 fixture、后端移动指南和契约 CHANGELOG，再生成、测试并更新所有模块的第 13 节。

业务仓储引用 operationId 和生成类型；模块文档不复制请求/响应 Schema。

`tool/audit_api_coverage.dart` 以固定 OpenAPI 的 operationId 为集合，扫描 `lib/**/*.dart` 中实际生成客户端调用，同时报告原始契约覆盖和移动端适用范围覆盖。`tool/api_coverage_exclusions.json` 必须逐 operationId 记录非移动端能力及理由；当前允许管理产品、部署健康检查、尚未启用的 FCM 设备注册、已废弃端点、后端明确标为 deferred 且已有向后兼容降级的独立产品切片，以及已由权限范围更准确或一致性更强的端点取代的旧调用。被取代的端点必须同时记录实际替代端点和继续调用会破坏的业务不变量。契约删除排除项、移动端开始调用被排除端点，或清单存在重复/未知 ID 时审计直接失败，避免清单变成静默逃生口。

该工具用于持续规划垂直切片，不以字符串计数替代仓储、状态和页面测试；`--require-complete` 要求所有未排除的移动端 operationId 已有真实客户端调用。新增契约端点默认属于移动端范围，必须完成实现，或经产品范围审查后显式加入排除清单。operationId 覆盖不等于枚举语义覆盖：业务层完整映射生成枚举时，必须用双向集合一致性测试排除生成器的 unknown sentinel，并在契约新增值而领域映射未更新时直接失败；社区举报的目标与原因映射按此规则验收。

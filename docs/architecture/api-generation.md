# API 生成

## 固定输入与版本

- 输入：[`contracts/openapi.json`](../../contracts/openapi.json)
- 生成器 CLI：`@openapitools/openapi-generator-cli` 2.40.1（Node.js 22+）
- OpenAPI Generator：7.23.0
- 目标：`dart-dio`，默认 `built_value` 序列化，开启未知枚举降级
- 输出：`packages/wenyou_api`

生成代码禁止手改。`tool/normalize_generated_api.dart` 只修正生成包的 Dart SDK 下限、保留其锁文件、清理序列化模式切换后遗留的辅助文件，并补齐 OpenAPI Generator 7.23.0 在 paginated `allOf` 模型中遗漏的共享成功码 import；这些归一化均由生成器输出形态触发且有一致性检查，不承载业务补丁。生成完成后必须执行根项目 `flutter pub get`，让 Flutter 的 package config 同步生成包的 Dart 语言版本。

## 命令

```bash
npm ci
npm run api:validate
npm run api:generate
npm run api:check
```

`api:check` 重新生成并检查 Git diff。契约变化先独立同步：运行 `tool/sync_backend_contract.ps1`，审查 OpenAPI、Markdown v2 规范化/可见性语料、扩展节点往返语料、mobile push v1 Schema/样例、后端移动指南和契约 CHANGELOG，再生成、测试并更新所有模块的第 13 节。

业务仓储引用 operationId 和生成类型；模块文档不复制请求/响应 Schema。

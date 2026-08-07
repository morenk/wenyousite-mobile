# 移动端变更记录

## Unreleased

### Added

- 建立 Flutter Android 工程、固定 OpenAPI 生成链、契约快照、中文模块文档体系与文档门禁。
- 建立粉白主题、应用环境、网络/会话、本地持久化与 Markdown v2 基线。
- 确定 Flutter Quill 仅作内存编辑模型，并建立自研 Markdown v2 ↔ Delta Codec 边界与测试规范。

### Changed

- OpenAPI Dart 客户端使用稳定的 `built_value` 序列化，未知枚举安全降级。

### Contract

- 后端契约 `3.0.0-dev.20260807.1`，后端提交 `4a9c9bbcf67d9419768675455980810e9765cdf1`，Markdown v2。

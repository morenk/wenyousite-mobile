# 移动端变更记录

## Unreleased

### Added

- 建立 Flutter Android 工程、固定 OpenAPI 生成链、契约快照、中文模块文档体系与文档门禁。
- 建立粉白主题、应用环境、网络/会话、本地持久化与 Markdown v2 基线。
- 确定 Flutter Quill 仅作内存编辑模型，并建立自研 Markdown v2 ↔ Delta Codec 边界与测试规范。
- 同步 Markdown v2 扩展节点往返语料和 mobile push v1 Schema/黄金样例，为后续编辑器与推送切片固定跨端边界。
- 实现账号/密码登录、mobile 终端声明、双 Token 安全落库，以及创建主题入口的登录回跳。

### Changed

- OpenAPI Dart 客户端使用稳定的 `built_value` 序列化，未知枚举安全降级。

### Contract

- 后端契约 `3.0.0-dev.20260807.2`，后端提交 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`，Markdown v2；HTTP 路由与业务响应字段不变，新增全响应追踪头及跨端语料。

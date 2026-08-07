# 移动端变更记录

## Unreleased

### Added

- 建立 Flutter Android 工程、固定 OpenAPI 生成链、契约快照、中文模块文档体系与文档门禁。
- 建立粉白主题、应用环境、网络/会话、本地持久化与 Markdown v2 基线。
- 确定 Flutter Quill 仅作内存编辑模型，并建立自研 Markdown v2 ↔ Delta Codec 边界与测试规范。
- 同步 Markdown v2 扩展节点往返语料和 mobile push v1 Schema/黄金样例，为后续编辑器与推送切片固定跨端边界。
- 实现账号/密码登录、mobile 终端声明、双 Token 安全落库，以及创建主题入口的登录回跳。
- 完成会话刷新与退出闭环：并发刷新锁、单次请求重放、失效原因导航、服务端会话撤销及明确确认的本机退出后备。
- 实现邮箱验证码两步注册、重发冷却、专用错误状态、mobile 双 Token 自动登录及原目标回跳。

### Changed

- 修复生成 API 客户端与 Dio 基地址重复拼接 `/api/v1`，导致真机启动请求 404 的问题。
- OpenAPI Dart 客户端使用稳定的 `built_value` 序列化，未知枚举安全降级。
- 刷新和退出统一通过生成客户端发送稳定请求 ID；重放再次过期或收到 `40103`～`40106` 时清除本地会话并进入登录页。
- `ApiFailure` 读取 `Retry-After` 并为验证码过期/错误、邮箱已注册和用户名占用提供稳定移动端提示。

### Contract

- 后端契约 `3.0.0-dev.20260807.2`，后端提交 `cf8aa382f0ad74d5209ffbfd9aba48b085ddafe3`，Markdown v2；HTTP 路由与业务响应字段不变，新增全响应追踪头及跨端语料。

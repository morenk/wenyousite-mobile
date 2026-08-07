# 温油站移动端文档

本目录维护移动端的当前工程事实。接口字段以 [`contracts/openapi.json`](../contracts/openapi.json) 为唯一机器事实源；跨端生命周期以 [`contracts/mobile-client-guide.md`](../contracts/mobile-client-guide.md) 为补充约束；模块文档只记录客户端流程、状态、权限、存储和验收。

## 阅读入口

- [模块状态与文档索引](modules/README.md)
- [网络与会话](architecture/networking.md)
- [导航](architecture/navigation.md)
- [本地持久化](architecture/persistence.md)
- [API 生成](architecture/api-generation.md)
- [编辑器 Markdown ↔ Delta Codec](architecture/editor-codec.md)
- [变更记录](CHANGELOG.md)

模块开始实现前必须把状态从 `planned` 改为 `in_progress`，并补全可验证的验收条件。行为变化时，代码、测试与对应模块文档在同一提交同步。

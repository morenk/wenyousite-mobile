# 温油站移动端文档

本目录维护移动端的当前工程事实。接口字段以 [`contracts/openapi.json`](../contracts/openapi.json) 为唯一机器事实源；跨端生命周期以 [`contracts/mobile-client-guide.md`](../contracts/mobile-client-guide.md) 为补充约束；V1 状态旅程、operationId 分类与动态分类分别由 `mobile-v1-golden-fixtures.json`、`mobile-v1-operation-coverage.json` 和当前唯一的 `thread-category-v*-fixtures.json` 固定。模块文档只记录客户端流程、状态、权限、存储和验收。

## 阅读入口

- [模块状态与文档索引](modules/README.md)
- [网络与会话](architecture/networking.md)
- [Foundation v6.3.0 Flutter profile](https://github.com/morenk/wenyousite-foundation/blob/v6.3.0/docs/platforms/mobile.md)
- [Foundation v6.3.0 元素系统](https://github.com/morenk/wenyousite-foundation/blob/v6.3.0/docs/elements.md)
- [移动端视觉基线](architecture/visual-baseline.md)
- [语义图标](architecture/icons.md)
- [导航](architecture/navigation.md)
- [依赖边界与架构门禁](architecture/dependencies.md)
- [本地持久化](architecture/persistence.md)
- [API 生成](architecture/api-generation.md)
- [编辑器 Markdown ↔ Delta Codec](architecture/editor-codec.md)
- [变更记录](CHANGELOG.md)
- [当前交付计划](../PROJECT_PLAN.md)
- [上游文档漂移记录](upstream-documentation-drift.md)
- [历史文档归档](archive/)

模块开始实现前必须把状态从 `planned` 改为 `in_progress`，并补全可验证的验收条件。状态只允许 `planned`、`in_progress`、`implemented`、`deferred`，正文状态必须与模块索引一致；文档门禁会拒绝未知、缺失、重复或不一致的条目。行为变化时，代码、测试与对应模块文档在同一提交同步。Foundation 相关实现始终先 fetch 只读镜像的远端 tags，以最新正式发布 Tag 更新依赖和规范后再开发，不能按仓库中已落后的锁定版本继续实现。

第一阶段采用效率优先的本地开发闭环：日常变更运行相关测试和受影响范围检查，高风险切片补完整本地门禁与真机关键路径。开发侧只负责生成并交付 Debug APK 与手测清单；真机安装、点击、日志和验收由项目负责人手动执行，不在自动开发流程中操作 ADB。GitHub Actions 仅手动触发，不作为日常切片阻塞条件；阶段验收或发布准备时再恢复远端持续集成要求。

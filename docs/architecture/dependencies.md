# 依赖边界与架构门禁

## 分层边界

feature 内保持 `presentation → application → domain`，data 在应用边界实现仓储接口并负责 OpenAPI DTO、`DioException` 与 feature 错误语义转换。domain 只保存业务实体、值对象和领域校验异常，不新增 Flutter、Riverpod、Dio、生成客户端、`ApiFailure` 或加载/提交状态依赖。既有债务记录在 `tool/architecture_allowlist.json`，只能逐项减少，不能作为新依赖的通行证。

跨 feature 的 UI 读模型归属其核心业务资源：主题信息流模型、映射和卡片位于 threads，home 与 tags 只保存各自查询和页面状态。capability、资料缓存失效等需要连接多个 feature 的能力由 `lib/app/` 组合层注入；feature 不反向导入 app-shell，也不直接失效另一个 feature 的 provider。

## 可复用生命周期

新异步代码优先使用小状态和 `Notifier` / `AsyncNotifier`；暂不一次性迁移既有 `StateNotifier`。`RequestEpoch` 统一丢弃筛选、刷新后的过期响应，`mergeUniqueBy` 统一游标页按稳定 ID 合并。迁移按热点模块逐步发生，并保持既有 provider、仓储和路由接口不变。

## 自动门禁

`npm run architecture:check` 在本地和 CI 检查：

- 稳定 `clientRequestId` 创建操作声明幂等请求策略；
- domain 不新增网络、框架或应用状态依赖；
- 不新增未审核的跨 feature 边或循环依赖；
- 页面不新增字面量路径导航；
- README 与 pubspec 版本一致；
- pubspec 不保留未被 `lib/` 使用的直接依赖；
- 请求策略不绕过类型化入口直接写原始 Dio `extra` 键。

架构门禁与 `flutter analyze`、完整测试、API 覆盖和文档门禁共同运行。allowlist 变化必须说明移除或保留债务的理由，不能静默扩大。

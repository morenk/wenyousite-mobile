# 依赖边界与架构门禁

## 分层边界

feature 内保持 `presentation → application → domain`，data 在应用边界实现仓储接口并负责 OpenAPI DTO、`DioException` 与 feature 错误语义转换。domain 只保存业务实体、值对象和领域校验异常，不新增 Flutter、Riverpod、Dio、生成客户端、`ApiFailure` 或加载/提交状态依赖。`tool/architecture_allowlist.json` 中 `domainBoundaryDebt`、`featureCycleDebt` 与 `layerDependencyDebt` 当前均为空；不得为省事重新增加，确有例外时必须由独立架构决策说明范围和退出条件。

非生成 Dart 文件以 900 行为硬上限。`largeFileDebt` 只允许冻结门禁启用时已经超限的文件及其精确行数：行数下降后必须同步收紧，降到上限内必须删除记录；禁止新增超限文件、提高基线或用新的超大 `part` 文件搬运复杂度。当前 `largeFileDebt` 已清空，所有非生成 Dart 文件均在上限内。

跨 feature 的 UI 读模型归属其核心业务资源：主题信息流模型、映射和卡片位于 threads，home、tags、search、users 与 social 只保存各自查询和页面状态；`search->threads`、`users->threads` 与 `social->threads` 仅用于把各自主题投影适配到同一只读主题卡片，不读取 threads controller 或 data。capability、会话退出、资料缓存失效等跨 feature 契约位于 `app` 或 `core/application`，由应用根组合具体 provider；feature 不反向导入 app-shell，也不直接失效另一个 feature 的 provider。

## 可复用生命周期

新异步代码优先使用小状态和 `Notifier` / `AsyncNotifier`；暂不一次性迁移既有 `StateNotifier`。`RequestEpoch` 统一丢弃筛选、刷新后的过期响应，`mergeUniqueBy` 统一游标页按稳定 ID 合并。迁移按热点模块逐步发生，并保持既有 provider、仓储和路由接口不变。

## 自动门禁

`npm run architecture:check` 在本地和 CI 检查：

- 稳定 `clientRequestId` 创建操作声明幂等请求策略；
- domain 不新增网络、框架或应用状态依赖，也不得声明 `*State` 或 `*Phase`；
- 不新增未审核的跨 feature 边或循环依赖，并对参与循环的每条有向边单独建账；
- presentation 不新增 data 依赖，application 不新增 data/presentation 依赖，domain 不新增外层依赖；data 只能导入 application 的 `*_ports.dart` 实现端口，不能反向读取 controller/state 或 presentation；
- 非生成 Dart 文件不得超过 900 行；现有超限债务以精确行数为基线，只能收紧；
- 页面不新增字面量路径导航；
- 生产代码不直接使用 `Icons.*`、`IconData` 或 `Icon(...)`，业务含义统一映射到 Foundation 语义图标；
- README 与 pubspec 版本一致；
- README 中的 Foundation 版本与 `pubspec.yaml` 固定 Tag 一致；
- 所有 Golden 测试在生成或比较快照前加载 Foundation 自托管字体；
- pubspec 不保留未被 `lib/` 使用的直接依赖；
- 请求策略不绕过类型化入口直接写原始 Dio `extra` 键。

架构门禁与 `flutter analyze`、完整测试、API 覆盖和文档门禁共同运行。allowlist 变化必须说明移除或保留债务的理由，不能静默扩大。

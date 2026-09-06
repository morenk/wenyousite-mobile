# 依赖边界与架构门禁

## 分层边界

feature 内保持 `presentation → application → domain`，data 在应用边界实现仓储接口并负责 OpenAPI DTO、`DioException` 与 feature 错误语义转换。domain 只保存业务实体、值对象和领域校验异常，不新增 Flutter、Riverpod、Dio、生成客户端、`ApiFailure` 或加载/提交状态依赖。`tool/architecture_allowlist.json` 中 `domainBoundaryDebt`、`featureCycleDebt` 与 `layerDependencyDebt` 当前均为空；不得为省事重新增加，确有例外时必须由独立架构决策说明范围和退出条件。

非生成 Dart 文件以 900 行为硬上限，范围包括 Git 已跟踪文件和新增未被忽略的工作区文件，不限于 `lib/`：测试、工具、集成测试、驱动和其他目录同样受检。生成客户端 `packages/wenyou_api/` 与 `.g.dart` 不计入。`largeFileDebt` 已清空且门禁禁止重新引入；不能新增超限文件、提高基线或用手写 `part` 搬运复杂度。当前所有受检文件均在上限内。

跨 feature 的主题读模型、DTO 映射、卡片与公开分类目录归属无外部 feature 依赖的 `thread_feed`。home、tags、search、users、social 与 threads 只通过该模块根 facade 消费，不再把业务卡片放入 core，也不借由 threads 与 social 建立循环。分类端口、单一 API 映射与进程缓存统一装配，业务 data 仅导入端口 facade，分类是否可选仍由创作/管理流程决定。capability、会话退出、资料缓存失效等横切契约位于 `app` 或 `core/application`；feature 不反向导入 app-shell，也不直接失效另一个 feature 的 provider。

## 可复用生命周期

只读内容 Provider 主动依赖 `ViewerScope = (SessionScope, visibilityRevision)`：账号切换与拉黑关系变化重建投影，Token 刷新保留。可见性协调器只推进版本，不维护跨模块缓存清单；新增读缓存必须声明该依赖。草稿、创建幂等与表单写入只跟随账号边界，不因可见性变更被清除。所有异步完成必须先确认 mounted 与请求代次，释放后不得回写或启动计时器。

新异步代码优先使用小状态和 `Notifier` / `AsyncNotifier`；暂不一次性迁移既有 `StateNotifier`。`RequestEpoch` 统一丢弃筛选、刷新后的过期响应，`mergeUniqueBy` 统一游标页按稳定 ID 合并。迁移按热点模块逐步发生，并保持既有 provider、仓储和路由接口不变。

存量迁移采用非增长基线：`StateNotifier` 声明 59 处、feature presentation 直接创建 `CircularProgressIndicator` 77 处；后续按业务边界改为 `Notifier` / `AsyncNotifier` 和共享加载组件，每次减少后收紧数值。跨 feature 直接引用 data/presentation 内部文件改用 `crossFeatureInternalImportDebt` 冻结 35 条精确的 `源文件->目标文件` 边，不再使用 41 次文本匹配的总量门槛；新边即使与删除的旧边数量相等也不能通过，移除旧边必须同步删账。超过 700 行的受检文件列入复审提示，900 行仍是硬门禁。

## 自动门禁

`npm run architecture:check` 在本地和 CI 检查：

- 稳定 `clientRequestId` 创建操作声明幂等请求策略；
- domain 不新增网络、框架或应用状态依赖，也不得声明 `*State` 或 `*Phase`；
- 通过 Dart AST 读取 import/export（包含条件分支），递归解析本地 export 链并处理循环；facade 不能掩盖分层、domain 框架或跨 feature 循环依赖，但不会把适配器的实现 import 当成 facade 的导出面；
- 不新增未审核的跨 feature 边或循环依赖，并对参与循环的每条有向边单独建账；core 不得直接或经导出链依赖 feature；
- presentation 不新增 data 依赖，application 不新增 data/presentation 依赖，domain 不新增外层依赖；data 只能导入 application 的 `*_ports.dart` 实现端口，不能反向读取 controller/state 或 presentation；
- 全仓受检非生成 Dart 文件不得超过 900 行；已清零的超限债务不得重开，测试与工具也不得使用手写 part；
- 不得增加存量 `StateNotifier` 或 presentation 原始加载圆环，跨 feature 内部层引用逐条冻结并检查失效记录；超过 700 行的文件纳入复审提示；
- 页面不新增字面量路径导航；
- 页面不独立构造路由转场；普通页、瞬时兜底和全屏媒体统一走 `core/navigation` 共享策略，仅帖子编辑器的嵌套 Navigator 初始路由是精确例外；
- 生产代码不直接使用 `Icons.*`、`IconData` 或 `Icon(...)`，业务含义统一映射到 Foundation 语义图标；
- README 与 pubspec 版本一致；
- README 中的 Foundation 版本与 `pubspec.yaml` 固定 Tag 一致；
- 所有 Golden 测试在生成或比较快照前加载 Foundation 自托管字体；
- pubspec 不保留未被 `lib/` 使用的直接依赖；
- 请求策略不绕过类型化入口直接写原始 Dio `extra` 键。

架构门禁与 `flutter analyze`、完整测试、API 覆盖和文档门禁共同运行。allowlist 变化必须说明移除或保留债务的理由，不能静默扩大。

检查入口 `tool/check_architecture.dart` 只编排规则；文件枚举、AST 依赖图、分层检查、展示检查和债务解析位于 `tool/architecture/` 的显式库。大型 Widget 测试保留原 `_test.dart` 注册入口，按完整行为场景拆分 case 库并复用 fixture 库，Golden 路径和字体初始化不变。门禁自身的回归覆盖同数量换边、多层/循环/条件导出、字符串伪 import、新增未暂存文件和手写 part，防止后续绕过。

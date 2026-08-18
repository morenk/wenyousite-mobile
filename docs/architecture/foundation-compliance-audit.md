# Foundation v6.1.0 移动端实现审计

本审计以 Foundation `v6.1.0`（`618954fb3f5048d5c2d89205c814b6ece8aeb386`）为事实源，复核 Flutter profile、`experiences.elements`、`controls`、`feedback`、`formatting`、`images` 与 v6 变更。审计日期为 2026-08-19；它记录当前实现覆盖和明确债务，不在移动端仓库复制或改写上游规范。

## 已闭环基线

- 纯白画布、共享色板与三角色字体已由 `AppTheme`、`WenyouThemeTokens` 和 Foundation 字体统一提供。
- 12/24dp 响应式页边距、600dp 内容上限、普通单列列表整宽和 48dp 触控目标已有共享组件与架构门禁；搜索结果和嵌套回复的内容宽度已复核。
- 公开资料不展示邮箱验证，等级使用五档 Foundation 色阶，核心导航、操作、编辑器和状态图标使用 Foundation 语义 SVG；点赞、收藏和订阅 Toggle 已使用同路径实心状态与透明静止容器。
- 主阅读态和编辑态正文已使用 17sp/1.8；page、expandable sheet、inline 编辑承载复用同一 Quill/Markdown Codec，键盘工具栏按 Foundation 顺序响应式提升能力并保持焦点与选区。
- 正文图片使用 contain 和共享全屏路由，支持系统返回、双击/捏合缩放、放大后平移与未放大下滑关闭；头像和封面维持各自 crop 角色。
- 骰子阅读态与编辑态已共用 `WenyouDiceNode`：无图标、基线对齐、原子不换行且不截断；已结算使用 accent/onAccent，待掷使用 warningSoft/warning，圆角和内边距按 em 契约计算。结果只按 nodeId 绑定服务端事实，缺失时显示 `?`，逐骰结果、修正值和总计仅进入完整 Semantics。

## 已确认未完整实现

| 范围 | 当前差异 | 证据与收敛边界 |
| --- | --- | --- |
| 正文排版 | 独立讨论中的非根回复仍使用 16sp/1.75，主题流内嵌回复预览使用 15sp/1.65；规范要求阅读态与编辑态正文统一 17sp/1.8 并跟随系统缩放。 | `lib/features/posts/presentation/post_replies_page.dart`、`lib/features/threads/presentation/thread_detail_sections.dart`；需在保持层级和列表密度的前提下迁移，并复核 320～600dp 换行、折叠阈值与 Golden。 |
| 语义排版 | `AppTheme.titleLarge/titleMedium` 全局使用文楷，导致列表项、弹层、状态和控件标题也继承文楷；规范要求这些场景使用 Noto Sans SC，只有页面/区块/详情内容标题使用文楷。 | `lib/app/app_theme.dart`；需要先增加明确语义标题入口，再迁移列表、Dialog/Sheet/Popover 与状态组件，不能只交换全局字体。 |
| 提及节点 | 编辑态提及仍是带 `actionMention` 图标的胶囊；阅读态用户坐标会进入站内传送门样式。规范要求透明表面、品牌深色、600 字重、`@` 前缀和无图标的原子提及。 | `lib/features/editor/presentation/editor_embed_builders.dart`、`lib/core/widgets/wenyou_markdown.dart`；需建立阅读/编辑共用提及组件并保持 userId 往返。 |
| 引用与行内代码 | 阅读和编辑引用仍使用斜体，规范固定 normal；行内代码虽已使用等宽字体和 muted 表面，但圆角、0.88em 字号及 0.12/0.35em 内边距未完整按合同落地。 | `lib/core/widgets/wenyou_markdown.dart`、`lib/features/editor/presentation/editor_text_styles.dart`；需同步处理 Flutter Markdown 与 Quill 的能力边界及 Golden。 |
| 主题标签 | 阅读态可点击标签使用品牌色并截断，管理标签仍可接收局部颜色；规范要求中性前景、透明表面、边框、`#` 前缀，状态不能依赖局部颜色。 | `lib/core/widgets/wenyou_tag_link.dart`、`lib/core/widgets/wenyou_tag_chip.dart`；需统一阅读与管理语义，同时保留独立可点击标签的 48dp 命中区。 |
| 头像降级 | 多个具名用户头像在缺图或加载失败时统一显示人物图标。规范要求用户名可读时显示首个可读字符，只有匿名或不可用身份使用中性用户图标。 | `lib/core/widgets/wenyou_avatar_button.dart` 及搜索、主题、动态、关系、资料、私信等本地头像实现；应先建立共享 fallback，再逐处替换，停用账号继续使用不可用状态。 |
| 时间与计数格式 | 共享相对时间已使用 72 小时窗口，但至少主题卡、动态、通知、楼层和回复的可见时间没有同步暴露完整时间 Semantics；私信列表仍有独立日期规则。紧凑计数目前只在创作概览明确消费 Foundation formatter。 | `lib/core/formatters/relative_time.dart` 的五个展示调用点及 `direct_messages_page.dart`；需提供“可见短值 + 完整可访问值”的共享组件，并审计统计数字。 |
| 加载与失败反馈 | 动态瀑布流和创作概览已有结构化 Skeleton，但多数初始资源加载仍只显示居中 Spinner。图片收藏、复制等失败仍使用 Snackbar；规范要求初始内容加载保持结构，失败和重试留在任务上下文，Snackbar 只承载短确认。 | 全仓 `CircularProgressIndicator` 初始页面分支、`content_image_viewer_page.dart`、`wenyou_content_action_menu.dart` 等；按模块迁移，不能用一次全局替换掩盖状态模型差异。 |
| 移动集合布局 | Foundation v6.1.0 已将动态主信息流登记为双列瀑布流领域例外；移动端现有布局尚未显式消费生成合同。 | `lib/features/moments/presentation/moment_feed_page.dart`；接入 `WenyouCollectionContract.mobileDomainLayoutExceptions` 并以测试固定例外只覆盖动态主信息流。 |

## 上游生成物风险

Foundation Flutter 包已导出骰子的标签、语义、绑定与等价性常量，但 v6.0.1 尚未导出骰子的 `radiusEm`、`paddingBlockEm`、`paddingInlineEm` 和两态颜色映射。本仓库的共享骰子组件暂按同一 Tag 的机器合同精确消费这些值；后续 Foundation 若导出对应 Flutter 常量，应迁移为直接引用，避免重复数字继续存在。

## 后续顺序

1. 富文本元素切片：提及、引用、行内代码、主题标签，共享阅读/编辑组件并更新 Codec/Golden。
2. 身份与格式化切片：统一头像 fallback、时间 Semantics、私信时间和紧凑计数。
3. 排版切片：统一紧凑回复正文为 17sp/1.8，建立页面/区块/详情/列表/弹层/状态标题角色并迁移调用点。
4. 反馈切片：结构化首屏 Skeleton、任务内失败/重试和短确认 Snackbar 边界。
5. 动态布局决策：收敛为单列，或由 Foundation 先发布移动瀑布流例外。

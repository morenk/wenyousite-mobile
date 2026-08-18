# Foundation v6.1.0 移动端实现审计

本审计以 Foundation `v6.1.0`（`618954fb3f5048d5c2d89205c814b6ece8aeb386`）为事实源，复核 Flutter profile、`experiences.elements`、`controls`、`feedback`、`formatting`、`images` 与 v6 变更。审计日期为 2026-08-19；它记录当前实现覆盖和明确债务，不在移动端仓库复制或改写上游规范。

## 已闭环基线

- 纯白画布、共享色板与三角色字体已由 `AppTheme`、`WenyouThemeTokens` 和 Foundation 字体统一提供。
- 12/24dp 响应式页边距、600dp 内容上限、普通单列列表整宽和 48dp 触控目标已有共享组件与架构门禁；搜索结果和嵌套回复的内容宽度已复核。
- 公开资料不展示邮箱验证，等级使用五档 Foundation 色阶，核心导航、操作、编辑器和状态图标使用 Foundation 语义 SVG；点赞、收藏和订阅 Toggle 已使用同路径实心状态与透明静止容器。
- 主阅读态和编辑态正文已使用 17sp/1.8；page、expandable sheet、inline 编辑承载复用同一 Quill/Markdown Codec，键盘工具栏按 Foundation 顺序响应式提升能力并保持焦点与选区。
- 独立讨论回复和主题流内嵌回复已统一为 17sp/1.8；提及在阅读/编辑态共用透明无图标原子文字，引用恢复正常字形，行内代码按 0.88em 字号和 0.35em 圆角呈现，Quill 内边距使用 v6.1.0 正式平台例外。
- 主题标签在阅读与管理态统一为中性前景、透明表面、细边框和 `#` 前缀；可点击标签保留 48dp 命中区，非交互标签按内容收缩。
- 页面、区块与详情内容标题通过显式语义入口使用 LXGW WenKai 500；Material 通用标题槽回到 Noto Sans SC，列表标题使用 600，弹层、状态、控件和用户名不再意外继承文楷。表单字段保留持久 label，筛选选择态同时提供下划线、边框/实心点或勾选等非颜色线索。
- 共享头像在具名身份缺图或加载失败时显示首个可读字符，匿名身份显示中性用户图标，停用身份强制显示不可用图标；列表与详情短时间使用 Foundation 72 小时格式并以 Semantics 暴露完整时间，私信不再维护独立日期规则，紧凑计数保留完整朗读值。
- 正文图片使用 contain 和共享全屏路由，支持系统返回、双击/捏合缩放、放大后平移与未放大下滑关闭；头像和封面维持各自 crop 角色。
- 骰子阅读态与编辑态已共用 `WenyouDiceNode`：无图标、基线对齐、原子不换行且不截断；已结算使用 accent/onAccent，待掷使用 warningSoft/warning，圆角和内边距按 em 契约计算。结果只按 nodeId 绑定服务端事实，缺失时显示 `?`，逐骰结果、修正值和总计仅进入完整 Semantics。
- 首页、通知、私信、搜索、公开资料、独立讨论和主题详情的初始读取使用共享结构 Skeleton；已有内容的局部失败继续保留原内容。原图收藏/保存与正文复制失败留在当前任务内并提供重试，Snackbar 只承载短确认。
- Dialog、Bottom Sheet、Popup Menu 与锚点浮层统一消费 Foundation overlay elevation；中央遮罩操作窗阻断背景点击并提供 48dp 显式关闭入口，系统返回仍可退出。
- 动态发现、关注、收藏和用户信息流显式消费 `WenyouCollectionContract.mobileDomainLayoutExceptions['moments-feed']`，仅该领域例外使用双列瀑布流，详情与其他普通集合保持单列。

## 本轮审计结论

本轮识别出的移动端实现差异已在对应垂直切片闭环，并由组件、页面或视觉回归测试固定。后续新增页面仍需直接消费生成合同和共享组件，不得重新引入页面级近似 Token、通用 Spinner 首屏或仅靠 Snackbar 承载可重试失败。

## 上游生成物风险

Foundation Flutter 包已导出骰子的标签、语义、绑定与等价性常量，但 v6.1.0 尚未导出骰子的 `radiusEm`、`paddingBlockEm`、`paddingInlineEm` 和两态颜色映射，也未导出提及、引用、行内代码和主题标签的全部数字常量。本仓库的共享元素组件暂按同一 Tag 的机器合同精确消费这些值；后续 Foundation 若导出对应 Flutter 常量，应迁移为直接引用，避免重复数字继续存在。

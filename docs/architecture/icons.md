# 语义图标

移动端图标以 Foundation v6.3.0 的语义注册表为唯一事实源。生产代码只通过 `WenyouIcon` 与 `WenyouIconIds` 表达“回复、加油、本人资料、发布”等业务含义，不直接引用 Flutter `Icons.*`、`IconData` 或 `Icon(...)`。这样 Web 与移动端会从同一语义名称得到一致图形，例如回复统一为对话气泡，加油统一为加油站，而不再由各页面自行选择左箭头、火苗等近似图标。

图形按紧凑 16dp、默认 20dp、导航 24dp 的角色尺寸绘制，并在输入框前后缀、图标按钮和导航等更大的约束容器内居中；独立操作继续由外层控件提供至少 48dp 命中区，不能通过放大 SVG 代替触控留白。

Foundation v6.3.0 为点赞、收藏与订阅语义直接提供 outline/filled 变体；移动端通过 `WenyouIconVariant` 选择状态，不复制或运行时改写 SVG，也不换成 Material 近似图标。点赞与收藏分别使用 `like` 和 `bookmark` 前景，选中容器保持透明；只读投影显示中性线性图标，不暴露按钮或 toggled 语义。站内传送门固定使用 `content.internal-reference` 的门图标。

本轮迁移基线共发现 64 个生产文件、539 处直接 Material 图标引用、166 个不同图标名，现已全部归零。`tool/check_architecture.dart` 会持续扫描 `lib/`，阻止直接 Material 图标重新进入生产代码；测试通过语义名称定位图标，避免绑定具体字体码位。

新增图标需求必须先判断 Foundation 是否已有准确语义；缺失时先在 Foundation 补充注册表、生成资产、验证 Web/Flutter 映射并发布新版本，再升级移动端锁定版本。页面不得用已有但语义不符的图标临时代替，也不得在移动仓库维护第二套映射。

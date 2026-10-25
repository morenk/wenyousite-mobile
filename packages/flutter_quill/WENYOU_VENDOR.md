# Flutter Quill 固定源码

来源：https://github.com/singerdmx/flutter-quill.git

固定提交：`c273155025d1255335a6dd3e6ecd3700d29f103e`，保留原有 Android IME 选区同步修复。

只收录构建所需 `lib/`、`pubspec.yaml`、`LICENSE`、`analysis_options.yaml`、`l10n.yaml`。上游文件由该提交的 `git archive` 导出并统一为 LF，全部改动记录在仓库 `tool/patches/flutter-quill-heading-spacing.patch`；不跟随浮动分支，不修改全局 Pub 缓存。

补丁在 `EditableTextBlock._getSpacingForLine` 从当前行读取标题属性，并保留标题完整上下间距。对齐分组不再把标题当作普通正文，也不因标题位于分组首尾而裁减留白；非标题仍按原有列表、引用等块规则计算。

同一补丁另含静态分析兼容整理：为键盘回调参数标注 `FocusNode`、为删除规则参数标注 `Operation?`，将未使用的双下划线参数改为通配符 `_`；这三处不改变运行语义。移除 `pubspec.yaml` 仅供上游发布展示的四张 `screenshots` 元数据，避免引用未收录的示例图片；运行依赖和原生配置保持原样。上游分析规则保留，未关闭 lint。

本地复核清单与每个文件的 SHA-256 位于 `tool/vendor/flutter-quill.json`。维护时先更新明确的上游提交，在独立 checkout 核对补丁，再重新生成清单，并执行编辑、选区、输入、撤销重做、Markdown 往返和完整应用门禁。不得通过修改清单掩盖未评审的源码差异。

当前上游尚未包含本问题修复。后续升级前检查相同行为回归；上游满足回归后通过独立依赖变更撤回补丁和固定源码。源码使用上游 `LICENSE` 所列许可证。

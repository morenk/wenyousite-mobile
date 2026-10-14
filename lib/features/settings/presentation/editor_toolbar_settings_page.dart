import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/core/widgets/editor_tool_icon.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';

class EditorToolbarSettingsPage extends ConsumerWidget {
  const EditorToolbarSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorToolbarPreferenceControllerProvider);
    final controller = ref.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    return WenyouSettingsTypography(
      child: Scaffold(
        backgroundColor: wenyouPersonalPageBackground(context),
        appBar: AppBar(
          backgroundColor: wenyouPersonalPageBackground(context),
          title: const Text('编辑器工具栏'),
        ),
        body: WenyouSettingsBody(
          children: [
            if (state.failureMessage case final message?)
              WenyouSettingsFailure(
                message: message,
                retryKey: const Key('editor-toolbar-layout-retry'),
                onRetry: state.isSaving
                    ? null
                    : () => unawaited(controller.retry()),
              ),
            _ToolbarArrangement(
              layout: state.layout,
              enabled: !state.isSaving,
              onChanged: (layout) => unawaited(controller.select(layout)),
            ),
            Center(
              child: TextButton(
                key: const Key('editor-toolbar-layout-reset'),
                onPressed:
                    state.isSaving ||
                        (state.layout.isDefault && !state.readFailed)
                    ? null
                    : () => unawaited(
                        controller.select(const EditorToolbarLayout.defaults()),
                      ),
                child: const Text('恢复默认'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarArrangement extends StatefulWidget {
  const _ToolbarArrangement({
    required this.layout,
    required this.enabled,
    required this.onChanged,
  });

  final EditorToolbarLayout layout;
  final bool enabled;
  final ValueChanged<EditorToolbarLayout> onChanged;

  @override
  State<_ToolbarArrangement> createState() => _ToolbarArrangementState();
}

class _ToolbarArrangementState extends State<_ToolbarArrangement> {
  final _primaryScroll = ScrollController();
  final _primaryViewportKey = GlobalKey();
  final _toolKeys = {for (final tool in EditorTool.values) tool: GlobalKey()};
  Timer? _edgeScrollTimer;
  double _edgeScrollDirection = 0;
  EditorTool? _selected;
  EditorTool? _dragging;
  bool _expanded = true;

  @override
  void didUpdateWidget(covariant _ToolbarArrangement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout != widget.layout) _revealSelection();
  }

  @override
  void dispose() {
    _edgeScrollTimer?.cancel();
    _primaryScroll.dispose();
    super.dispose();
  }

  void _updateDragScroll(DragUpdateDetails details) {
    final box = _primaryViewportKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !_primaryScroll.hasClients) return;
    final point = box.globalToLocal(details.globalPosition);
    _edgeScrollDirection = point.dy < 0 || point.dy > box.size.height
        ? 0
        : point.dx < 24
        ? -1
        : point.dx > box.size.width - 24
        ? 1
        : 0;
    if (_edgeScrollDirection == 0) {
      _edgeScrollTimer?.cancel();
      _edgeScrollTimer = null;
      return;
    }
    _edgeScrollTimer ??= Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_primaryScroll.hasClients) return;
      final position = _primaryScroll.position;
      _primaryScroll.jumpTo(
        (position.pixels + 12 * _edgeScrollDirection).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });
  }

  void _revealSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _toolKeys[_selected]?.currentContext;
      if (context != null) {
        unawaited(Scrollable.ensureVisible(context, alignment: 0.5));
      }
    });
  }

  EditorToolbarGroup _groupOf(EditorTool tool) =>
      widget.layout.primary.contains(tool)
      ? EditorToolbarGroup.primary
      : EditorToolbarGroup.expanded;

  void _move(EditorTool tool, EditorToolbarGroup group, int index) {
    if (!widget.enabled) return;
    final oldGroup = _groupOf(tool);
    final oldIndex = widget.layout.toolsIn(oldGroup).indexOf(tool);
    if (oldGroup == group && oldIndex == index) return;
    setState(() {
      _selected = tool;
      if (group == EditorToolbarGroup.expanded) _expanded = true;
    });
    widget.onChanged(widget.layout.move(tool, group, index));
  }

  // 拖放目标表示插入到该项之前；同组删除源项后，后续目标索引减一。
  int _dropIndex(EditorTool tool, EditorToolbarGroup group, int index) {
    final oldIndex = widget.layout.toolsIn(group).indexOf(tool);
    return oldIndex >= 0 && oldIndex < index ? index - 1 : index;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space16,
            tokens.space12,
          ),
          child: const Text('长按拖动，点按调整'),
        ),
        WenyouPanel(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_expanded) ...[_groupLabel('展开栏'), _expandedBar()],
              _groupLabel('主栏'),
              _primaryBar(),
            ],
          ),
        ),
        if (_selected case final tool?) ...[
          SizedBox(height: tokens.space12),
          _selectionActions(tool),
        ],
      ],
    );
  }

  Widget _groupLabel(String label) {
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space16,
        tokens.space12,
        tokens.space16,
        tokens.space8,
      ),
      child: Semantics(
        header: true,
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }

  Widget _expandedBar() {
    final tools = widget.layout.expanded;
    return KeyedSubtree(
      key: const Key('toolbar-layout-expanded'),
      child: tools.isEmpty
          ? _dropTarget(EditorToolbarGroup.expanded, 0, empty: true)
          : WenyouEditorMoreTray(
              entries: [
                for (var index = 0; index < tools.length; index++)
                  _dropTarget(EditorToolbarGroup.expanded, index),
                if (_dragging != null)
                  _dropTarget(EditorToolbarGroup.expanded, tools.length),
              ],
            ),
    );
  }

  Widget _primaryBar() {
    final tokens = context.wenyouTokens;
    final tools = widget.layout.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: WenyouEditorContract.toolbarHorizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                key: _primaryViewportKey,
                child: tools.isEmpty
                    ? _dropTarget(EditorToolbarGroup.primary, 0, empty: true)
                    : Scrollbar(
                        controller: _primaryScroll,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          key: const Key('toolbar-layout-primary'),
                          controller: _primaryScroll,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(bottom: tokens.space8),
                          child: Row(
                            children: [
                              for (var index = 0; index < tools.length; index++)
                                _dropTarget(EditorToolbarGroup.primary, index),
                              if (_dragging != null)
                                _dropTarget(
                                  EditorToolbarGroup.primary,
                                  tools.length,
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            WenyouEditorToolbarButton(
              key: const Key('toolbar-layout-fixed-more'),
              icon: _expanded
                  ? WenyouIconIds.editorChevronDown
                  : WenyouIconIds.editorMore,
              label: _expanded ? '收起更多（固定按钮）' : '更多（固定按钮）',
              enabled: _dragging == null,
              selected: _expanded,
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
            const WenyouEditorSubmitButton(
              key: Key('toolbar-layout-fixed-submit'),
              enabled: false,
              loading: false,
              label: '发送（固定按钮）',
              onPressed: _doNothing,
            ),
          ],
        ),
      ),
    );
  }

  static void _doNothing() {}

  Widget _dropTarget(
    EditorToolbarGroup group,
    int index, {
    bool empty = false,
  }) {
    final tools = widget.layout.toolsIn(group);
    final tool = index < tools.length ? tools[index] : null;
    final tokens = context.wenyouTokens;
    return DragTarget<EditorTool>(
      key: ValueKey('toolbar-drop-${group.name}-$index'),
      onWillAcceptWithDetails: (details) =>
          widget.enabled &&
          !(_groupOf(details.data) == group &&
              tools.indexOf(details.data) ==
                  _dropIndex(details.data, group, index)),
      onAcceptWithDetails: (details) =>
          _move(details.data, group, _dropIndex(details.data, group, index)),
      builder: (context, candidates, rejected) {
        final active = candidates.isNotEmpty;
        return SizedBox(
          width: empty ? null : WenyouEditorContract.minimumActionExtent,
          height: WenyouEditorContract.minimumActionExtent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tool != null)
                _draggableTool(tool, group)
              else
                DecoratedBox(
                  key: ValueKey('toolbar-empty-${group.name}'),
                  decoration: BoxDecoration(
                    color: active
                        ? tokens.accentedBackground
                        : Colors.transparent,
                    border: Border.all(
                      color: active ? tokens.actionSurface : tokens.border,
                    ),
                    borderRadius: BorderRadius.circular(tokens.radiusControl),
                  ),
                  child: empty ? const Center(child: Text('拖到这里')) : null,
                ),
              if (active && tool != null)
                Positioned(
                  key: const Key('toolbar-drop-indicator'),
                  left: 0,
                  top: tokens.space4,
                  bottom: tokens.space4,
                  width: 3,
                  child: ColoredBox(color: tokens.actionSurface),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _draggableTool(EditorTool tool, EditorToolbarGroup group) {
    final child = SizedBox(
      key: _toolKeys[tool],
      // 长按由拖动接管；图标的 Tooltip 仍提供读屏名称与鼠标悬停提示。
      child: TooltipTheme(
        data: TooltipTheme.of(
          context,
        ).copyWith(triggerMode: TooltipTriggerMode.manual),
        child: _toolButton(tool, group),
      ),
    );
    return LongPressDraggable<EditorTool>(
      key: ValueKey('toolbar-drag-${tool.id}'),
      data: tool,
      maxSimultaneousDrags: widget.enabled ? 1 : 0,
      feedback: Material(
        elevation: 6,
        color: context.wenyouTokens.panel,
        borderRadius: BorderRadius.circular(context.wenyouTokens.radiusControl),
        child: _toolButton(tool, group, feedback: true),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      onDragStarted: () => setState(() {
        _dragging = tool;
        _expanded = true;
      }),
      onDragUpdate: _updateDragScroll,
      onDragEnd: (_) {
        _edgeScrollTimer?.cancel();
        _edgeScrollTimer = null;
        if (mounted) setState(() => _dragging = null);
      },
      child: child,
    );
  }

  Widget _toolButton(
    EditorTool tool,
    EditorToolbarGroup group, {
    bool feedback = false,
  }) {
    final label =
        '${tool.label}，${group == EditorToolbarGroup.primary ? '主栏' : '展开栏'}';
    void select() => setState(() => _selected = tool);
    return group == EditorToolbarGroup.primary
        ? WenyouEditorToolbarButton(
            key: feedback ? null : ValueKey('toolbar-layout-${tool.id}'),
            icon: editorToolIconId(tool),
            label: label,
            enabled: widget.enabled,
            selected: feedback || _selected == tool,
            onPressed: select,
          )
        : WenyouEditorTrayButton(
            key: feedback ? null : ValueKey('toolbar-layout-${tool.id}'),
            icon: editorToolIconId(tool),
            label: label,
            enabled: widget.enabled,
            selected: feedback || _selected == tool,
            onPressed: select,
          );
  }

  Widget _selectionActions(EditorTool tool) {
    final group = _groupOf(tool);
    final items = widget.layout.toolsIn(group);
    final index = items.indexOf(tool);
    final other = group == EditorToolbarGroup.primary
        ? EditorToolbarGroup.expanded
        : EditorToolbarGroup.primary;
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      key: const Key('toolbar-layout-actions'),
      padding: EdgeInsets.only(left: tokens.space16, right: tokens.space4),
      child: Row(
        children: [
          Expanded(child: Semantics(liveRegion: true, child: Text(tool.label))),
          WenyouEditorToolbarButton(
            key: const Key('toolbar-layout-previous'),
            icon: WenyouIconIds.navigationPrevious,
            label: '前移',
            enabled: widget.enabled && index > 0,
            onPressed: () => _move(tool, group, index - 1),
          ),
          WenyouEditorToolbarButton(
            key: const Key('toolbar-layout-next'),
            icon: WenyouIconIds.navigationNext,
            label: '后移',
            enabled: widget.enabled && index < items.length - 1,
            onPressed: () => _move(tool, group, index + 1),
          ),
          WenyouEditorToolbarButton(
            key: const Key('toolbar-layout-change-group'),
            icon: WenyouIconIds.actionMove,
            label: other == EditorToolbarGroup.primary ? '移到主栏' : '移到展开栏',
            enabled: widget.enabled,
            onPressed: () =>
                _move(tool, other, widget.layout.toolsIn(other).length),
          ),
        ],
      ),
    );
  }
}

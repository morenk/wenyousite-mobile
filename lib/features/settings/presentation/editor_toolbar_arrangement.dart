import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/widgets/editor_tool_icon.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reorder_feedback.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'toolbar_arrangement_draggable.dart';

/// 与表情排序相同：逻辑槽位命中、临时腾位，松手才保存一次。
class EditorToolbarArrangement extends StatefulWidget {
  const EditorToolbarArrangement({
    required this.layout,
    required this.enabled,
    required this.onChanged,
    required this.capabilities,
    required this.stickersEnabled,
    super.key,
  });

  final EditorToolbarLayout layout;
  final WenyouEditorCapabilities capabilities;
  final bool stickersEnabled;
  final bool enabled;
  final ValueChanged<EditorToolbarLayout> onChanged;

  @override
  State<EditorToolbarArrangement> createState() =>
      _EditorToolbarArrangementState();
}

class _EditorToolbarArrangementState extends State<EditorToolbarArrangement>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _extent = WenyouEditorContract.minimumActionExtent;
  final _expandedScroll = ScrollController();
  final _viewports = {
    for (final group in EditorToolbarGroup.values) group: GlobalKey(),
  };
  final _contents = {
    for (final group in EditorToolbarGroup.values) group: GlobalKey(),
  };
  final _toolKeys = {for (final tool in EditorTool.values) tool: GlobalKey()};
  final _slots = <EditorToolbarGroup, List<Rect>>{};
  late final Ticker _scrollTicker;
  late final AnimationController _lift;
  late EditorToolbarLayout _preview = widget.layout;
  EditorTool? _dragging;
  EditorTool? _settling;
  EditorToolbarGroup? _target;
  EditorToolbarGroup _source = EditorToolbarGroup.primary;
  Offset _pointer = Offset.zero;
  Offset _grab = Offset.zero;
  Offset _feedbackPosition = Offset.zero;
  Offset _returnFrom = Offset.zero;
  Offset _returnTo = Offset.zero;
  double _releaseLift = 1;
  double? _dragTrayHeight;
  bool _expanded = true;
  double _width = 0;
  bool _changed = false;
  bool _startedWithDraft = false;
  bool _sourceDedicated = false;

  bool get _showMore =>
      widget.capabilities.hasMoreActions || !_preview.isDefault;
  Set<EditorTool> get _available => widget.capabilities.availableTools(
    stickerCallback: widget.stickersEnabled,
  );
  ResolvedEditorToolbarLayout get _resolved =>
      widget.capabilities.resolveToolbar(
        _preview,
        width: _width,
        showSubmit: true,
        stickerCallback: widget.stickersEnabled,
      );
  List<EditorTool> _items(EditorToolbarGroup group) =>
      group == EditorToolbarGroup.primary
      ? _resolved.primary
      : _resolved.expanded;

  // 首次真正移动才从可见分配开始；不可用能力保留原组和相对顺序。
  EditorToolbarLayout _materialize(
    List<EditorTool> primary,
    List<EditorTool> expanded,
  ) {
    List<EditorTool> merge(List<EditorTool> old, List<EditorTool> visible) {
      final remaining = visible.iterator;
      return [
        for (final tool in old)
          if (!_available.contains(tool))
            tool
          else if (remaining.moveNext())
            remaining.current,
        for (; remaining.moveNext();) remaining.current,
      ];
    }

    return EditorToolbarLayout.custom(
      primary: merge(widget.layout.primary, primary),
      expanded: merge(widget.layout.expanded, expanded),
    );
  }

  EditorToolbarLayout _moved(
    EditorTool tool,
    EditorToolbarGroup group,
    int index,
  ) {
    final resolved = _resolved;
    final primary = [...resolved.primary]..remove(tool);
    final expanded = [
      ...resolved.expanded,
      if (resolved.dedicatedDraft) EditorTool.drafts,
    ]..remove(tool);
    final destination = group == EditorToolbarGroup.primary
        ? primary
        : expanded;
    final capacity = ((_width / _extent).floor() - (_showMore ? 1 : 0) - 1)
        .clamp(0, EditorTool.values.length);
    final last = group == EditorToolbarGroup.primary
        ? (capacity - 1).clamp(0, destination.length)
        : destination.length;
    destination.insert(index.clamp(0, last), tool);
    expanded.insertAll(0, primary.skip(capacity));
    return _materialize(primary.take(capacity).toList(), expanded);
  }

  Duration _lastTick = Duration.zero;
  OverlayEntry? _feedback;

  Duration get _duration => wenyouAnimationsDisabled(context)
      ? Duration.zero
      : WenyouFoundationMotion.standard;

  @override
  void initState() {
    super.initState();
    _scrollTicker = createTicker(_autoScroll);
    _lift = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _settling != null) {
          _clearFeedback();
        }
      });
    _expandedScroll.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(EditorToolbarArrangement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragging != null &&
        (!widget.enabled || oldWidget.layout != widget.layout)) {
      _finish(cancelled: true);
    } else if (_dragging == null) {
      _preview = widget.layout;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _finish(cancelled: true);
  }

  @override
  void didChangeMetrics() => _finish(cancelled: true);

  RenderBox? _box(GlobalKey key) =>
      key.currentContext?.findRenderObject() as RenderBox?;

  void _start(EditorTool tool, EditorToolbarGroup group) {
    if (!widget.enabled || _dragging != null || _settling != null) return;
    final box = _box(_toolKeys[tool]!);
    if (box == null) return;
    _source = group;
    _startedWithDraft = _resolved.dedicatedDraft;
    _sourceDedicated = _startedWithDraft && tool == EditorTool.drafts;
    _changed = false;
    _grab = _sourceDedicated
        ? const Offset(_extent / 2, _extent / 2)
        : box.globalToLocal(_pointer);
    _feedbackPosition = _sourceDedicated
        ? _pointer - _grab
        : box.localToGlobal(Offset.zero);
    final tray = _box(_viewports[EditorToolbarGroup.expanded]!);
    _dragTrayHeight = tray == null ? null : tray.size.height + 1;
    setState(() {
      _preview = widget.layout;
      _dragging = tool;
      _target = group;
      _expanded = true;
    });
    HapticFeedback.selectionClick();
    _feedback = OverlayEntry(builder: _buildFeedback);
    Overlay.of(context).insert(_feedback!);
    _lift.duration = _duration;
    _lift.forward(from: 0);
    if (_dragTrayHeight == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _dragging != tool) return;
        final tray = _box(_viewports[EditorToolbarGroup.expanded]!);
        if (tray != null) {
          setState(() => _dragTrayHeight = tray.size.height + 1);
        }
      });
    }
  }

  Widget _buildFeedback(BuildContext context) {
    final tool = _dragging ?? _settling;
    if (tool == null) return const SizedBox.shrink();
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    return AnimatedBuilder(
      animation: _lift,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: WenyouReorderFeedback(
            key: const Key('toolbar-drag-feedback'),
            animation: _dragging != null
                ? _lift
                : _lift.drive(Tween(begin: 0.0, end: _releaseLift)),
            child: _button(tool, _source, feedback: true),
          ),
        ),
      ),
      builder: (context, child) {
        final global = _dragging != null
            ? _feedbackPosition
            : Offset.lerp(
                _returnFrom,
                _returnTo,
                wenyouStandardMotionCurve.transform(1 - _lift.value),
              )!;
        final position = overlayBox.globalToLocal(global);
        return Positioned(
          key: const Key('toolbar-feedback-position'),
          left: position.dx,
          top: position.dy,
          width: _extent,
          height: _extent,
          child: child!,
        );
      },
    );
  }

  void _update(DragUpdateDetails details) {
    if (_dragging == null) return;
    _pointer = details.globalPosition;
    _feedbackPosition = _pointer - _grab;
    _feedback?.markNeedsBuild();
    _updatePreview();
    _syncAutoScroll();
  }

  void _updatePreview() {
    final tool = _dragging;
    if (tool == null) return;
    EditorToolbarGroup? target;
    int? index;
    for (final group in EditorToolbarGroup.values) {
      final viewport = _box(_viewports[group]!);
      final content = _box(_contents[group]!);
      if (viewport == null || content == null) continue;
      if (!(Offset.zero & viewport.size).contains(
        viewport.globalToLocal(_pointer),
      )) {
        continue;
      }
      final center = content.globalToLocal(
        _feedbackPosition + const Offset(_extent / 2, _extent / 2),
      );
      final slots = _slots[group]!;
      var distance = double.infinity;
      for (final (slotIndex, slot) in slots.indexed) {
        final candidate = (slot.center - center).distanceSquared;
        if (candidate < distance) {
          distance = candidate;
          index = slotIndex;
        }
      }
      target = group;
      // 空白尾部也能放到末尾，不在起拖时追加占位格改变托盘高度。
      if (slots.isNotEmpty &&
          center.dx > slots.last.right &&
          center.dy >= slots.last.top) {
        index = _items(group).length;
      }
      break;
    }
    if (target == null || index == null) {
      if (_target != null) setState(() => _target = null);
      return;
    }
    if (!_changed && _items(target).indexOf(tool) == index) {
      if (_target != target) setState(() => _target = target);
      return;
    }
    final next = _moved(tool, target, index);
    if (!_sameOrder(next, _preview) || _target != target) {
      setState(() {
        _target = target;
        _preview = next;
        _changed = true;
      });
    }
  }

  bool _sameOrder(EditorToolbarLayout a, EditorToolbarLayout b) =>
      listEquals(a.primary, b.primary) && listEquals(a.expanded, b.expanded);

  void _finish({bool cancelled = false}) {
    final tool = _dragging;
    if (tool == null) return;
    final next = cancelled || _target == null || !_changed
        ? widget.layout
        : _preview;
    _scrollTicker.stop();
    _releaseLift = _lift.value;
    _lift.stop();
    setState(() {
      _dragging = null;
      _target = null;
      _settling = tool;
      _preview = next;
      _returnFrom = _feedbackPosition;
      _returnTo = _feedbackPosition;
    });
    if (next != widget.layout) widget.onChanged(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _settling != tool) return;
      // 命中与落位均依据最终逻辑槽位，不读取动画中途的图标坐标。
      final group = _resolved.primary.contains(tool)
          ? EditorToolbarGroup.primary
          : EditorToolbarGroup.expanded;
      final index = _items(group).indexOf(tool);
      final content = _box(_contents[group]!);
      final slots = _slots[group];
      if (content != null &&
          slots != null &&
          index >= 0 &&
          index < slots.length) {
        _returnTo = content.localToGlobal(slots[index].topLeft);
      }
      if (_resolved.dedicatedDraft && tool == EditorTool.drafts) {
        final draft = _box(_toolKeys[tool]!);
        if (draft != null) {
          _returnTo =
              draft.localToGlobal(draft.size.center(Offset.zero)) -
              const Offset(_extent / 2, _extent / 2);
        }
      }
      _feedback?.markNeedsBuild();
      _lift.duration = _duration;
      _lift.reverse(from: 1);
    });
  }

  void _clearFeedback() {
    _feedback?.remove();
    _feedback?.dispose();
    _feedback = null;
    if (mounted) {
      setState(() {
        _settling = null;
        _dragTrayHeight = null;
      });
    }
  }

  double _edgeStrength(EditorToolbarGroup group) {
    final viewport = _box(_viewports[group]!);
    final scroll = _expandedScroll;
    if (group == EditorToolbarGroup.primary) return 0;
    if (_dragging == null || viewport == null || !scroll.hasClients) return 0;
    final point = viewport.globalToLocal(_pointer);
    if (!(Offset.zero & viewport.size).contains(point)) return 0;
    final horizontal = group == EditorToolbarGroup.primary;
    final value = horizontal ? point.dx : point.dy;
    final size = horizontal ? viewport.size.width : viewport.size.height;
    final edge = context.wenyouTokens.minimumTouchTarget;
    final strength = value < edge
        ? -((edge - value) / edge).clamp(0.0, 1.0)
        : value > size - edge
        ? ((value - size + edge) / edge).clamp(0.0, 1.0)
        : 0.0;
    final position = scroll.position;
    if ((strength < 0 && position.pixels <= position.minScrollExtent) ||
        (strength > 0 && position.pixels >= position.maxScrollExtent)) {
      return 0;
    }
    return strength;
  }

  void _syncAutoScroll() {
    final active = EditorToolbarGroup.values.any(
      (group) => _edgeStrength(group) != 0,
    );
    if (active && !_scrollTicker.isActive) {
      _lastTick = Duration.zero;
      _scrollTicker.start();
    } else if (!active) {
      _scrollTicker.stop();
    }
  }

  void _autoScroll(Duration elapsed) {
    final dt =
        (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    for (final group in EditorToolbarGroup.values) {
      final strength = _edgeStrength(group);
      if (strength == 0) continue;
      final scroll = _expandedScroll;
      final position = scroll.position;
      scroll.jumpTo(
        (position.pixels + strength * _extent * 6 * dt.clamp(0, 0.05)).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    }
    _syncAutoScroll();
  }

  void _onScroll() {
    if (_dragging != null) _updatePreview();
  }

  void _moveAccessible(EditorTool tool, EditorToolbarGroup group, int index) {
    if (!widget.enabled || _dragging != null || _settling != null) return;
    widget.onChanged(_moved(tool, group, index));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final toolContext = _toolKeys[tool]!.currentContext;
      if (toolContext != null) {
        unawaited(Scrollable.ensureVisible(toolContext, alignment: 0.5));
      }
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _width =
          constraints.maxWidth -
          WenyouEditorContract.toolbarHorizontalPadding * 2;
      return Listener(
        onPointerCancel: (_) => _finish(cancelled: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [if (_expanded) _expandedBar(), _primaryBar()],
        ),
      );
    },
  );

  Widget _expandedBar() {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth -
            WenyouEditorContract.toolbarHorizontalPadding * 2;
        final columns = (width / _extent).floor().clamp(1, 6);
        final rows =
            (_resolved.expanded.length.clamp(1, EditorTool.values.length) /
                    columns)
                .ceil();
        final height = (rows * _extent + tokens.space4 * 2 + 1).clamp(
          0.0,
          152.0,
        );
        return AnimatedContainer(
          key: const Key('toolbar-layout-expanded'),
          duration: _duration,
          curve: wenyouStandardMotionCurve,
          height: _dragTrayHeight ?? height,
          decoration: BoxDecoration(
            color: tokens.panel,
            border: Border(top: BorderSide(color: tokens.border)),
          ),
          child: SizedBox(
            key: _viewports[EditorToolbarGroup.expanded],
            child: SingleChildScrollView(
              controller: _expandedScroll,
              padding: EdgeInsets.symmetric(
                horizontal: WenyouEditorContract.toolbarHorizontalPadding,
                vertical: tokens.space4,
              ),
              child: _area(EditorToolbarGroup.expanded, width),
            ),
          ),
        );
      },
    );
  }

  Widget _primaryBar() {
    final tokens = context.wenyouTokens;
    final resolved = _resolved;
    final draftRow =
        resolved.dedicatedDraft ||
        (_startedWithDraft && (_dragging != null || _settling != null));
    final count = resolved.primary.length + (_showMore ? 1 : 0) + 1;
    double left(int index) => _width / count * (index + 0.5) - _extent / 2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: WenyouEditorContract.toolbarHorizontalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _duration,
              curve: wenyouStandardMotionCurve,
              height: draftRow ? tokens.minimumTouchTarget + tokens.space4 : 0,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: draftRow
                  ? SizedBox(
                      key: const Key('toolbar-preview-dedicated-draft'),
                      height: tokens.minimumTouchTarget + tokens.space4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: tokens.space4),
                          child:
                              resolved.dedicatedDraft ||
                                  (_sourceDedicated &&
                                      (_dragging == EditorTool.drafts ||
                                          _settling == EditorTool.drafts))
                              ? _draggable(
                                  EditorTool.drafts,
                                  EditorToolbarGroup.expanded,
                                  dedicated: true,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(
              key: const Key('toolbar-layout-primary'),
              height: tokens.minimumTouchTarget + tokens.space8,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SizedBox(
                      key: _viewports[EditorToolbarGroup.primary],
                      child: _area(EditorToolbarGroup.primary, _width),
                    ),
                  ),
                  if (_showMore)
                    Positioned(
                      left: left(resolved.primary.length),
                      top: tokens.space4,
                      child: WenyouEditorToolbarButton(
                        key: const Key('toolbar-layout-fixed-more'),
                        icon: _expanded
                            ? WenyouIconIds.editorChevronDown
                            : WenyouIconIds.editorMore,
                        label: _expanded ? '收起更多（固定按钮）' : '更多（固定按钮）',
                        enabled: _dragging == null,
                        selected: _expanded,
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                    ),
                  Positioned(
                    left: left(count - 1),
                    top: tokens.space4,
                    child: const WenyouEditorSubmitButton(
                      key: Key('toolbar-layout-fixed-submit'),
                      enabled: false,
                      loading: false,
                      label: '发送（固定按钮）',
                      onPressed: _doNothing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _area(EditorToolbarGroup group, double width) {
    final items = _items(group);
    final count = items.length.clamp(1, EditorTool.values.length);
    final primary = group == EditorToolbarGroup.primary;
    final columns = primary ? count : (width / _extent).floor().clamp(1, 6);
    final rows = (count / columns).ceil();
    final slots = <Rect>[];
    var offset = 0;
    final primaryCount = items.length + (_showMore ? 1 : 0) + 1;
    for (var row = 0; row < rows; row++) {
      final length = count ~/ rows + (row < count % rows ? 1 : 0);
      for (var column = 0; column < length; column++) {
        slots.add(
          Rect.fromLTWH(
            primary
                ? width / primaryCount * (offset + 0.5) - _extent / 2
                : width / length * (column + 0.5) - _extent / 2,
            row * _extent + (primary ? context.wenyouTokens.space4 : 0),
            _extent,
            _extent,
          ),
        );
        offset++;
      }
    }
    _slots[group] = slots;
    final tokens = context.wenyouTokens;
    return SizedBox(
      width: width,
      height: rows * _extent + (primary ? tokens.space8 : 0),
      child: Stack(
        key: _contents[group],
        clipBehavior: Clip.none,
        children: [
          for (final (index, slot) in slots.indexed)
            Positioned.fromRect(
              key: ValueKey('toolbar-drop-${group.name}-$index'),
              rect: slot,
              child: const SizedBox.expand(),
            ),
          if (items.isEmpty)
            Positioned.fill(
              child: DecoratedBox(
                key: ValueKey('toolbar-empty-${group.name}'),
                decoration: BoxDecoration(
                  color: tokens.softPanel,
                  borderRadius: BorderRadius.circular(tokens.radiusCompact),
                ),
                child: Semantics(
                  container: true,
                  label: '空工具栏，可拖入工具',
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          if (_dragging != null && items.contains(_dragging))
            Positioned.fromRect(
              key: const Key('toolbar-drop-indicator'),
              rect: slots[items.indexOf(_dragging!)],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.softPanel,
                  borderRadius: BorderRadius.circular(tokens.radiusCompact),
                  border: Border.all(color: tokens.border),
                ),
              ),
            ),
          // 拖动源留在原组，跨栏预览只移动占位；不重挂载活动手势。
          for (final tool in {
            ...items.where(
              (tool) =>
                  tool != _dragging && !(_sourceDedicated && tool == _settling),
            ),
            if (_dragging != null && group == _source && !_sourceDedicated)
              _dragging!,
          })
            AnimatedPositioned(
              key: ValueKey('toolbar-position-${tool.id}'),
              duration: _duration,
              curve: wenyouStandardMotionCurve,
              left:
                  slots[(items.indexOf(tool)).clamp(0, slots.length - 1)].left,
              top: slots[(items.indexOf(tool)).clamp(0, slots.length - 1)].top,
              width: _extent,
              height: _extent,
              child: _draggable(tool, group),
            ),
        ],
      ),
    );
  }

  Widget _draggable(
    EditorTool tool,
    EditorToolbarGroup group, {
    bool dedicated = false,
  }) {
    final items = _items(group);
    final index = items.indexOf(tool);
    final other = group == EditorToolbarGroup.primary
        ? EditorToolbarGroup.expanded
        : EditorToolbarGroup.primary;
    final canMove = widget.enabled && _dragging == null && _settling == null;
    return ToolbarArrangementDraggable(
      key: ValueKey('toolbar-drag-${tool.id}'),
      data: tool,
      maxSimultaneousDrags: canMove ? 1 : 0,
      feedback: const SizedBox.shrink(),
      onDragStarted: () => _start(tool, group),
      onDragUpdate: _update,
      onDragEnd: (_) => _finish(),
      child: Listener(
        key: _toolKeys[tool],
        onPointerDown: (event) => _pointer = event.position,
        child: Opacity(
          opacity: tool == _dragging || tool == _settling ? 0 : 1,
          child: Semantics(
            key: ValueKey('toolbar-semantics-${tool.id}'),
            container: true,
            label: dedicated
                ? '${tool.label}，独立行'
                : '${tool.label}，${group == EditorToolbarGroup.primary ? '主栏' : '展开栏'}，第${index + 1}项',
            enabled: canMove,
            customSemanticsActions: canMove
                ? {
                    if (index > 0)
                      const CustomSemanticsAction(label: '前移'): () =>
                          _moveAccessible(tool, group, index - 1),
                    if (index < items.length - 1)
                      const CustomSemanticsAction(label: '后移'): () =>
                          _moveAccessible(tool, group, index + 1),
                    CustomSemanticsAction(
                      label: other == EditorToolbarGroup.primary
                          ? '移到主栏'
                          : '移到展开栏',
                    ): () =>
                        _moveAccessible(tool, other, _items(other).length),
                  }
                : null,
            child: ExcludeSemantics(
              child: MouseRegion(
                cursor: canMove
                    ? SystemMouseCursors.grab
                    : SystemMouseCursors.basic,
                child: AbsorbPointer(
                  child: ExcludeFocus(
                    child: dedicated
                        ? OutlinedButton.icon(
                            onPressed: _doNothing,
                            icon: const WenyouIcon(
                              WenyouIconIds.editorContentDrafts,
                            ),
                            label: const Text('正文草稿'),
                          )
                        : _button(tool, group),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _doNothing() {}

  Widget _button(
    EditorTool tool,
    EditorToolbarGroup group, {
    bool feedback = false,
  }) {
    final button = group == EditorToolbarGroup.primary
        ? WenyouEditorToolbarButton(
            key: feedback ? null : ValueKey('toolbar-layout-${tool.id}'),
            icon: editorToolIconId(tool),
            label: tool.label,
            enabled: true,
            selected: false,
            onPressed: _doNothing,
          )
        : WenyouEditorTrayButton(
            key: feedback ? null : ValueKey('toolbar-layout-${tool.id}'),
            icon: editorToolIconId(tool),
            label: tool.label,
            enabled: true,
            selected: false,
            onPressed: _doNothing,
          );
    return group == EditorToolbarGroup.primary &&
            tool == EditorTool.drafts &&
            _preview.isDefault
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.wenyouTokens.border),
              ),
            ),
            child: button,
          )
        : button;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _feedback?.remove();
    _feedback?.dispose();
    _scrollTicker.dispose();
    _lift.dispose();
    _expandedScroll.dispose();
    super.dispose();
  }
}

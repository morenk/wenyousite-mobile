import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum WenyouPopoverPlacement { above, below }

enum WenyouPopoverAlignment { start, center, end }

enum WenyouPopoverActionTone { normal, destructive }

class WenyouPopoverHandle {
  const WenyouPopoverHandle({
    required this.isOpen,
    required this.open,
    required this.close,
    required this.toggle,
  });

  final bool isOpen;
  final VoidCallback open;
  final VoidCallback close;
  final VoidCallback toggle;
}

typedef WenyouPopoverAnchorBuilder =
    Widget Function(BuildContext context, WenyouPopoverHandle handle);
typedef WenyouPopoverBuilder =
    Widget Function(BuildContext context, VoidCallback close);

/// A route-local popup that follows its trigger without changing page layout
/// or taking focus away from an active composer.
class WenyouAnchoredPopover extends StatefulWidget {
  const WenyouAnchoredPopover({
    required this.size,
    required this.anchorBuilder,
    required this.popoverBuilder,
    this.placement = WenyouPopoverPlacement.above,
    this.alignment = WenyouPopoverAlignment.center,
    this.gap = 8,
    this.semanticLabel = '弹出菜单',
    super.key,
  });

  final Size size;
  final WenyouPopoverAnchorBuilder anchorBuilder;
  final WenyouPopoverBuilder popoverBuilder;
  final WenyouPopoverPlacement placement;
  final WenyouPopoverAlignment alignment;
  final double gap;
  final String semanticLabel;

  @override
  State<WenyouAnchoredPopover> createState() => _WenyouAnchoredPopoverState();
}

class _WenyouAnchoredPopoverState extends State<WenyouAnchoredPopover> {
  final MenuController _menuController = MenuController();
  final GlobalKey _anchorKey = GlobalKey();
  LocalHistoryEntry? _historyEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    final entry = _historyEntry;
    _historyEntry = null;
    entry?.remove();
    if (_menuController.isOpen) _menuController.close();
    super.dispose();
  }

  void _open() {
    if (_menuController.isOpen) return;
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    final anchorSize = renderObject is RenderBox
        ? renderObject.size
        : Size.zero;
    final x = switch (widget.alignment) {
      WenyouPopoverAlignment.start => 0.0,
      WenyouPopoverAlignment.center =>
        (anchorSize.width - widget.size.width) / 2,
      WenyouPopoverAlignment.end => anchorSize.width - widget.size.width,
    };
    final y = switch (widget.placement) {
      WenyouPopoverPlacement.above => -widget.size.height - widget.gap,
      WenyouPopoverPlacement.below => anchorSize.height + widget.gap,
    };
    _menuController.open(position: Offset(x, y));
  }

  void _close() {
    if (_menuController.isOpen) _menuController.close();
  }

  void _toggle() => _menuController.isOpen ? _close() : _open();

  void _onOpen() {
    if (!_isOpen) setState(() => _isOpen = true);
    final route = ModalRoute.of(context);
    if (route == null || _historyEntry != null) return;
    final entry = LocalHistoryEntry(
      onRemove: () {
        _historyEntry = null;
        _close();
      },
    );
    _historyEntry = entry;
    route.addLocalHistoryEntry(entry);
  }

  void _onClose() {
    if (_isOpen && mounted) setState(() => _isOpen = false);
    final entry = _historyEntry;
    _historyEntry = null;
    entry?.remove();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final handle = WenyouPopoverHandle(
      isOpen: _isOpen,
      open: _open,
      close: _close,
      toggle: _toggle,
    );
    return MenuAnchor(
      controller: _menuController,
      useRootOverlay: true,
      animated: false,
      consumeOutsideTap: true,
      crossAxisUnconstrained: false,
      reservedPadding: EdgeInsets.all(tokens.space8),
      onOpen: _onOpen,
      onClose: _onClose,
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        fixedSize: WidgetStatePropertyAll(widget.size),
        maximumSize: WidgetStatePropertyAll(widget.size),
        backgroundColor: WidgetStatePropertyAll(tokens.panel),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.shadow.withValues(alpha: 0.16),
        ),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius16),
            side: BorderSide(color: tokens.border),
          ),
        ),
      ),
      menuChildren: [
        SizedBox.fromSize(
          size: widget.size,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: widget.semanticLabel,
            child: widget.popoverBuilder(context, _close),
          ),
        ),
      ],
      builder: (context, _, _) => KeyedSubtree(
        key: _anchorKey,
        child: widget.anchorBuilder(context, handle),
      ),
    );
  }
}

@immutable
class WenyouPopoverAction<T> {
  const WenyouPopoverAction({
    required this.value,
    required this.icon,
    required this.label,
    this.semanticsLabel,
    this.enabled = true,
    this.loading = false,
    this.tone = WenyouPopoverActionTone.normal,
    this.key,
  });

  final T value;
  final String icon;
  final String label;
  final String? semanticsLabel;
  final bool enabled;
  final bool loading;
  final WenyouPopoverActionTone tone;
  final Key? key;
}

class WenyouAnchoredActionBubble<T> extends StatelessWidget {
  const WenyouAnchoredActionBubble({
    required this.actions,
    required this.anchorBuilder,
    required this.onSelected,
    this.placement = WenyouPopoverPlacement.above,
    this.alignment = WenyouPopoverAlignment.center,
    this.semanticLabel = '操作菜单',
    super.key,
  });

  static const double actionWidth = 56;
  static const double actionHeight = 72;
  static const double panelPadding = 8;
  static const int maxActionsPerRow = 5;

  final List<WenyouPopoverAction<T>> actions;
  final WenyouPopoverAnchorBuilder anchorBuilder;
  final ValueChanged<T> onSelected;
  final WenyouPopoverPlacement placement;
  final WenyouPopoverAlignment alignment;
  final String semanticLabel;

  static Size sizeFor(int actionCount) {
    assert(actionCount > 0);
    final columns = math.min(actionCount, maxActionsPerRow);
    final rows = (actionCount / maxActionsPerRow).ceil();
    return Size(
      columns * actionWidth + panelPadding * 2,
      rows * actionHeight + panelPadding * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(actions.isNotEmpty);
    return WenyouAnchoredPopover(
      size: sizeFor(actions.length),
      placement: placement,
      alignment: alignment,
      semanticLabel: semanticLabel,
      anchorBuilder: anchorBuilder,
      popoverBuilder: (context, close) => Padding(
        padding: const EdgeInsets.all(panelPadding),
        child: Wrap(
          children: [
            for (final action in actions)
              _WenyouPopoverActionButton<T>(
                action: action,
                onPressed: () {
                  close();
                  onSelected(action.value);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _WenyouPopoverActionButton<T> extends StatelessWidget {
  const _WenyouPopoverActionButton({
    required this.action,
    required this.onPressed,
  });

  final WenyouPopoverAction<T> action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final destructive = action.tone == WenyouPopoverActionTone.destructive;
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : tokens.text;
    return SizedBox(
      key: action.key,
      width: WenyouAnchoredActionBubble.actionWidth,
      height: WenyouAnchoredActionBubble.actionHeight,
      child: Semantics(
        button: true,
        enabled: action.enabled && !action.loading,
        label: action.semanticsLabel ?? action.label,
        child: InkWell(
          onTap: action.enabled && !action.loading ? onPressed : null,
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.loading)
                  SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.brandForeground,
                    ),
                  )
                else
                  WenyouIcon(
                    action.icon,
                    size: 22,
                    color: action.enabled ? color : tokens.mutedText,
                  ),
                SizedBox(height: tokens.space4),
                Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: action.enabled ? color : tokens.mutedText,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

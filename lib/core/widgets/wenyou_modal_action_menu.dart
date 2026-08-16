import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';

/// Opens a compact action window in the center of a dimmed modal barrier.
///
/// The anchor only owns the gesture. The menu does not depend on the anchor's
/// render position, so long-pressed content near a viewport edge remains easy
/// to locate and operate.
class WenyouModalActionMenu<T> extends StatefulWidget {
  const WenyouModalActionMenu({
    required this.actions,
    required this.anchorBuilder,
    required this.onSelected,
    this.semanticLabel = '操作菜单',
    super.key,
  });

  static const double actionWidth = 72;
  static const double actionHeight = 72;
  static const double panelPadding = 12;
  static const int maxActionsPerRow = 3;

  final List<WenyouPopoverAction<T>> actions;
  final WenyouPopoverAnchorBuilder anchorBuilder;
  final ValueChanged<T> onSelected;
  final String semanticLabel;

  @override
  State<WenyouModalActionMenu<T>> createState() =>
      _WenyouModalActionMenuState<T>();
}

class _WenyouModalActionMenuState<T> extends State<WenyouModalActionMenu<T>> {
  var _isOpen = false;

  void _open() {
    if (_isOpen) return;
    unawaited(_show());
  }

  void _close() {
    if (!_isOpen) return;
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _toggle() => _isOpen ? _close() : _open();

  Future<void> _show() async {
    setState(() => _isOpen = true);
    final selection = await showDialog<_ModalActionSelection<T>>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: '关闭${widget.semanticLabel}',
      animationStyle: AnimationStyle.noAnimation,
      builder: (dialogContext) => _WenyouActionDialog<T>(
        actions: widget.actions,
        semanticLabel: widget.semanticLabel,
        onSelected: (value) =>
            Navigator.of(dialogContext).pop(_ModalActionSelection(value)),
      ),
    );
    if (!mounted) return;
    setState(() => _isOpen = false);
    if (selection != null) widget.onSelected(selection.value);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.actions.isNotEmpty);
    return widget.anchorBuilder(
      context,
      WenyouPopoverHandle(
        isOpen: _isOpen,
        open: _open,
        close: _close,
        toggle: _toggle,
      ),
    );
  }
}

class _ModalActionSelection<T> {
  const _ModalActionSelection(this.value);

  final T value;
}

class _WenyouActionDialog<T> extends StatelessWidget {
  const _WenyouActionDialog({
    required this.actions,
    required this.semanticLabel,
    required this.onSelected,
  });

  final List<WenyouPopoverAction<T>> actions;
  final String semanticLabel;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final columns = math.min(
      actions.length,
      WenyouModalActionMenu.maxActionsPerRow,
    );
    final width =
        columns * WenyouModalActionMenu.actionWidth +
        WenyouModalActionMenu.panelPadding * 2;
    return Dialog(
      key: const Key('wenyou-modal-action-menu'),
      insetPadding: EdgeInsets.all(context.wenyouTokens.space24),
      child: SizedBox(
        width: width,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: Padding(
            padding: const EdgeInsets.all(WenyouModalActionMenu.panelPadding),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (final action in actions)
                  _ModalActionButton<T>(
                    action: action,
                    onPressed: () => onSelected(action.value),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalActionButton<T> extends StatelessWidget {
  const _ModalActionButton({required this.action, required this.onPressed});

  final WenyouPopoverAction<T> action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final destructive = action.tone == WenyouPopoverActionTone.destructive;
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : tokens.text;
    final enabled = action.enabled && !action.loading;
    return SizedBox(
      key: action.key,
      width: WenyouModalActionMenu.actionWidth,
      height: WenyouModalActionMenu.actionHeight,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: action.semanticsLabel ?? action.label,
        child: InkWell(
          onTap: enabled ? onPressed : null,
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

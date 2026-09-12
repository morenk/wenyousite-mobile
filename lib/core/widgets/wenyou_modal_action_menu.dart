import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
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
  static const double actionMinHeight = 72;
  static const double panelPadding = 12;
  static const int maxActions = 6;

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
        onClose: () => Navigator.of(dialogContext).pop(),
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
    required this.onClose,
    required this.onSelected,
  });

  final List<WenyouPopoverAction<T>> actions;
  final String semanticLabel;
  final VoidCallback onClose;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    assert(actions.length <= WenyouModalActionMenu.maxActions);
    final columns = switch (actions.length) {
      <= 3 => actions.length,
      4 => 2,
      _ => 3,
    };
    final width = math.max(
      WenyouModalActionMenu.actionWidth * 2 +
          WenyouModalActionMenu.panelPadding * 2,
      columns * WenyouModalActionMenu.actionWidth +
          WenyouModalActionMenu.panelPadding * 2,
    );
    final rows = <List<WenyouPopoverAction<T>>>[
      for (var start = 0; start < actions.length; start += columns)
        actions.sublist(start, math.min(start + columns, actions.length)),
    ];
    return Dialog(
      key: const Key('wenyou-modal-action-menu'),
      insetPadding: EdgeInsets.all(context.wenyouTokens.space24),
      constraints: const BoxConstraints(minWidth: 0),
      child: SizedBox(
        width: width,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: context.wenyouTokens.space12,
                  top: context.wenyouTokens.space4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        semanticLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.wenyouCompactTitle
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      key: const Key('wenyou-modal-action-close'),
                      tooltip: '关闭$semanticLabel',
                      onPressed: onClose,
                      icon: const WenyouIcon(WenyouIconIds.actionClose),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WenyouModalActionMenu.panelPadding,
                  0,
                  WenyouModalActionMenu.panelPadding,
                  WenyouModalActionMenu.panelPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var rowIndex = 0;
                      rowIndex < rows.length;
                      rowIndex++
                    ) ...[
                      if (rowIndex > 0)
                        SizedBox(height: context.wenyouTokens.space4),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final action in rows[rowIndex])
                              _ModalActionButton<T>(
                                action: action,
                                onPressed: () => onSelected(action.value),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
    return ConstrainedBox(
      key: action.key,
      constraints: const BoxConstraints(
        minWidth: WenyouModalActionMenu.actionWidth,
        maxWidth: WenyouModalActionMenu.actionWidth,
        minHeight: WenyouModalActionMenu.actionMinHeight,
      ),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: action.semanticsLabel ?? action.label,
        excludeSemantics: true,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 22,
                  child: action.loading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tokens.brandForeground,
                        )
                      : WenyouIcon(
                          action.icon,
                          size: 22,
                          color: action.enabled ? color : tokens.mutedText,
                        ),
                ),
                SizedBox(height: tokens.space4),
                Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.wenyouCaption.copyWith(
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

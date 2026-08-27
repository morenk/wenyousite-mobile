import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selectable_action_region.dart';

class WenyouInternalReferenceText extends StatefulWidget {
  const WenyouInternalReferenceText({
    required this.content,
    this.style,
    this.selectable = false,
    this.onTapText,
    this.onLongPressNonText,
    super.key,
  });

  final String content;
  final TextStyle? style;
  final bool selectable;
  final VoidCallback? onTapText;
  final VoidCallback? onLongPressNonText;

  @override
  State<WenyouInternalReferenceText> createState() =>
      _WenyouInternalReferenceTextState();
}

class _WenyouInternalReferenceTextState
    extends State<WenyouInternalReferenceText> {
  final _selectionAreaKey = GlobalKey<SelectionAreaState>();
  var _hasSelection = false;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);
    final spans = <InlineSpan>[];
    var portalIndex = 0;
    for (final segment in tokenizeInternalReferenceText(widget.content)) {
      switch (segment) {
        case InternalReferencePlainText(:final value):
          spans.add(TextSpan(text: value));
        case InternalReferencePortal(:final label, :final reference):
          final index = portalIndex++;
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: WenyouInternalReferenceChip(
                key: ValueKey('wenyou-internal-reference-$index'),
                surfaceKey: ValueKey(
                  'wenyou-internal-reference-surface-$index',
                ),
                label: label,
                style: resolvedStyle,
                onTap: () =>
                    openInternalWenyouLink(context, reference.location),
                onLongPress: widget.onLongPressNonText == null
                    ? null
                    : _handleNonTextLongPress,
              ),
            ),
          );
      }
    }
    final layout = Text.rich(TextSpan(style: resolvedStyle, children: spans));
    final tappableLayout = widget.onTapText == null
        ? layout
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleTapText,
            child: layout,
          );
    if (!widget.selectable) return tappableLayout;
    return WenyouSelectableActionRegion(
      selectionAreaKey: _selectionAreaKey,
      onLongPressBlank: widget.onLongPressNonText == null
          ? null
          : _handleNonTextLongPress,
      child: SelectionArea(
        key: _selectionAreaKey,
        onSelectionChanged: (content) {
          _hasSelection = content?.plainText.isNotEmpty == true;
        },
        child: tappableLayout,
      ),
    );
  }

  void _handleTapText() {
    if (_hasSelection) {
      _clearSelection();
      return;
    }
    widget.onTapText?.call();
  }

  void _handleNonTextLongPress() {
    _clearSelection();
    widget.onLongPressNonText?.call();
  }

  void _clearSelection() {
    if (!_hasSelection) return;
    final selectableRegion = _selectionAreaKey.currentState?.selectableRegion;
    selectableRegion?.hideToolbar();
    selectableRegion?.clearSelection();
    _hasSelection = false;
  }
}

/// Foundation `content.internal-reference` 的移动端阅读态实现。
///
/// 视觉胶囊按正文 em 计算，透明外层保证独立交互仍满足 48dp 命中区。
class WenyouInternalReferenceChip extends StatefulWidget {
  const WenyouInternalReferenceChip({
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.style,
    this.surfaceKey,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final TextStyle? style;
  final Key? surfaceKey;

  @override
  State<WenyouInternalReferenceChip> createState() =>
      _WenyouInternalReferenceChipState();
}

class _WenyouInternalReferenceChipState
    extends State<WenyouInternalReferenceChip> {
  var _pressed = false;
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final stateOpacity = _pressed
        ? WenyouElementContract.internalReferencePressedStateOpacity
        : _focused
        ? WenyouIconControlContract.focusStateLayerOpacity
        : 0.0;
    return Semantics(
      link: true,
      label: '站内传送门：${widget.label}',
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: WenyouElementContract.interactiveMinimumTarget,
              minHeight: WenyouElementContract.interactiveMinimumTarget,
            ),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: WenyouInternalReferenceSurface(
                surfaceKey: widget.surfaceKey,
                label: widget.label,
                style: widget.style,
                stateOpacity: stateOpacity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The compact, non-interactive Foundation surface shared by reading and edit
/// states. Interaction and the platform hit target stay with the caller.
class WenyouInternalReferenceSurface extends StatelessWidget {
  const WenyouInternalReferenceSurface({
    required this.label,
    this.style,
    this.stateOpacity = 0,
    this.surfaceKey,
    super.key,
  });

  final String label;
  final TextStyle? style;
  final double stateOpacity;
  final Key? surfaceKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = baseStyle.fontSize ?? 14;
    final foreground = tokens.onAccentedBackground;
    final surface = Color.alphaBlend(
      foreground.withValues(alpha: stateOpacity),
      tokens.accentedBackground,
    );
    return AnimatedContainer(
      key: surfaceKey,
      duration: WenyouFoundationMotion.fast,
      padding: EdgeInsets.symmetric(
        horizontal:
            fontSize * WenyouElementContract.internalReferencePaddingInline,
        vertical:
            fontSize * WenyouElementContract.internalReferencePaddingBlock,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(
          fontSize * WenyouElementContract.internalReferenceRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WenyouIcon(
            WenyouIconIds.contentInternalReference,
            size: fontSize * WenyouElementContract.internalReferenceIconSize,
            color: foreground,
          ),
          SizedBox(
            width: fontSize * WenyouElementContract.internalReferenceGap,
          ),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: baseStyle.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

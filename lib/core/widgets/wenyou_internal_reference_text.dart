import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

class WenyouInternalReferenceText extends StatelessWidget {
  const WenyouInternalReferenceText({
    required this.content,
    this.style,
    this.selectable = false,
    super.key,
  });

  final String content;
  final TextStyle? style;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
    final children = <Widget>[];
    final plainText = StringBuffer();
    var portalIndex = 0;
    for (final segment in tokenizeInternalReferenceText(content)) {
      switch (segment) {
        case InternalReferencePlainText(:final value):
          plainText.write(value);
        case InternalReferencePortal(:final label, :final reference):
          if (plainText.isNotEmpty) {
            children.add(Text(plainText.toString(), style: resolvedStyle));
            plainText.clear();
          }
          final index = portalIndex++;
          children.add(
            WenyouInternalReferenceChip(
              key: ValueKey('wenyou-internal-reference-$index'),
              surfaceKey: ValueKey('wenyou-internal-reference-surface-$index'),
              label: label,
              style: resolvedStyle,
              onTap: () => openInternalWenyouLink(context, reference.location),
            ),
          );
      }
    }
    if (plainText.isNotEmpty) {
      children.add(Text(plainText.toString(), style: resolvedStyle));
    }
    final layout = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
    return selectable ? SelectionArea(child: layout) : layout;
  }
}

/// Foundation `content.internal-reference` 的移动端阅读态实现。
///
/// 视觉胶囊按正文 em 计算，透明外层保证独立交互仍满足 48dp 命中区。
class WenyouInternalReferenceChip extends StatefulWidget {
  const WenyouInternalReferenceChip({
    required this.label,
    required this.onTap,
    this.style,
    this.surfaceKey,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouMentionSurface extends StatelessWidget {
  const WenyouMentionSurface({required this.label, this.style, super.key});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
    return Text(
      label,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: resolvedStyle.copyWith(
        color: tokens.brandForeground,
        backgroundColor: Colors.transparent,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
    );
  }
}

class WenyouMentionLink extends StatelessWidget {
  const WenyouMentionLink({
    required this.label,
    required this.onTap,
    this.style,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      link: true,
      label: '查看 $label 的个人资料',
      onTap: onTap,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: tokens.minimumTouchTarget,
              minHeight: tokens.minimumTouchTarget,
            ),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: WenyouMentionSurface(label: label, style: style),
            ),
          ),
        ),
      ),
    );
  }
}

class WenyouInlineCodeSurface extends StatelessWidget {
  const WenyouInlineCodeSurface({required this.text, this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = resolvedStyle.fontSize ?? 14;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.35,
        vertical: fontSize * 0.12,
      ),
      decoration: BoxDecoration(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(fontSize * 0.35),
      ),
      child: Text(
        text,
        style: resolvedStyle.copyWith(
          color: tokens.text,
          backgroundColor: Colors.transparent,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

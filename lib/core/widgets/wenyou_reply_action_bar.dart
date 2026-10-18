import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 详情页共享底部操作容器；安全区与48dp操作行随系统保留。
class WenyouReplyActionBar extends StatelessWidget {
  const WenyouReplyActionBar({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      color: tokens.panel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.symmetric(horizontal: tokens.space8),
          child: Padding(
            padding: EdgeInsets.only(bottom: tokens.space12),
            child: Align(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tokens.wideContainerMaxWidth,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(children: children),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WenyouReplyFieldAction extends StatelessWidget {
  const WenyouReplyFieldAction({
    required this.authenticated,
    required this.onPressed,
    this.fieldKey,
    this.semanticLabel,
    super.key,
  });

  final bool authenticated;
  final VoidCallback? onPressed;
  final Key? fieldKey;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      label: semanticLabel ?? (authenticated ? '回复一下' : '回复一下，登录后发表'),
      excludeSemantics: true,
      child: Tooltip(
        message: authenticated ? '回复一下' : '登录后回复',
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.square(tokens.minimumTouchTarget),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.standard,
            foregroundColor: tokens.mutedText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radiusControl),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              key: fieldKey,
              decoration: BoxDecoration(
                color: tokens.softPanel,
                border: Border.all(color: tokens.border),
                borderRadius: BorderRadius.circular(tokens.radiusControl),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space4,
                  vertical: tokens.space8,
                ),
                child: const _ReplyFieldContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyFieldContent extends StatelessWidget {
  const _ReplyFieldContent();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.wenyouCompactBody.copyWith(
      color: context.wenyouTokens.mutedText,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: '回复', style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
          maxLines: 1,
        )..layout();
        final canShowWords = painter.width <= constraints.maxWidth;
        final lineHeight = painter.height;
        painter.text = TextSpan(text: '回复一下', style: style);
        painter.layout();
        final canShowFullLabel = painter.width <= constraints.maxWidth;
        painter.dispose();
        // 极窄大字下连“回复”也放不下时保留明确入口，不缩小用户字号。
        if (!canShowWords) {
          return SizedBox(
            height: lineHeight,
            child: const Center(
              child: WenyouIcon(WenyouIconIds.actionReply, size: 20),
            ),
          );
        }
        return Text(
          canShowFullLabel ? '回复一下' : '回复',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}

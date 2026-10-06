import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 昵称独占首行，次要信息可换行，编号始终位于次行右侧。
class WenyouAuthorHeader extends StatelessWidget {
  const WenyouAuthorHeader({
    required this.avatar,
    required this.name,
    required this.metadata,
    this.nameStyle,
    this.trailing,
    super.key,
  });

  final Widget avatar;
  final String name;
  final List<Widget> metadata;
  final TextStyle? nameStyle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        SizedBox(width: tokens.space8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle ?? textTheme.wenyouLabel,
              ),
              if (metadata.isNotEmpty || trailing != null) ...[
                SizedBox(height: tokens.space4),
                DefaultTextStyle.merge(
                  style: textTheme.wenyouCaption.copyWith(
                    color: tokens.mutedText,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: tokens.space8,
                          runSpacing: tokens.space4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: metadata,
                        ),
                      ),
                      if (trailing != null) ...[
                        SizedBox(width: tokens.space8),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

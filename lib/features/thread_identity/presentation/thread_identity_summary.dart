import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';

/// 帖内预览、历史卡片与发表入口共用层级，账号动作仍由外层负责。
class ThreadIdentitySummary extends StatelessWidget {
  const ThreadIdentitySummary({
    required this.name,
    this.label,
    this.avatar,
    this.avatarUrl,
    this.supportingText,
    this.avatarSize = 40,
    this.maxNameLines,
    this.trailing,
    this.nameBadge,
    super.key,
  });

  final String name;
  final String? label;
  final Widget? avatar;
  final String? avatarUrl;
  final String? supportingText;
  final double avatarSize;
  final int? maxNameLines;
  final Widget? trailing;
  final String? nameBadge;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar ??
            ExcludeSemantics(
              child: WenyouAvatar(
                username: name,
                avatarUrl: avatarUrl,
                size: avatarSize,
              ),
            ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label case final caption?)
                Text(
                  caption,
                  style: text.wenyouCaption.copyWith(color: tokens.mutedText),
                ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: maxNameLines,
                      overflow: maxNameLines == null
                          ? null
                          : TextOverflow.ellipsis,
                      style: text.wenyouCompactTitle,
                    ),
                  ),
                  if (nameBadge case final badge?) ...[
                    SizedBox(width: tokens.space4),
                    Text(
                      badge,
                      style: text.wenyouCaption.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                  ],
                ],
              ),
              if (supportingText case final supporting?) ...[
                SizedBox(height: tokens.space4),
                Text(
                  supporting,
                  style: text.wenyouCaption.copyWith(color: tokens.mutedText),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: tokens.space8), trailing!],
      ],
    );
  }
}

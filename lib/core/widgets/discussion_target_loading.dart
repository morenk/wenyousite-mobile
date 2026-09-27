import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// 保持讨论卡的阅读结构；等待时不使用循环装饰或虚构进度。
class DiscussionTargetLoading extends StatelessWidget {
  const DiscussionTargetLoading({
    required this.label,
    this.slow = false,
    super.key,
  });

  final String label;
  final bool slow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final message = slow ? '仍在定位，请稍候…' : label;
    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space12),
              child: Row(
                children: [
                  WenyouIcon(
                    WenyouIconIds.navigationExplore,
                    color: tokens.brandForeground,
                    size: WenyouIconContract.defaultSize,
                  ),
                  SizedBox(width: tokens.space8),
                  Expanded(
                    child: Text(
                      message,
                      key: slow ? const Key('discussion-target-slow') : null,
                      style: Theme.of(context).textTheme.wenyouCompactBody
                          .copyWith(color: tokens.mutedText),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space8),
            const _DiscussionSkeletonCard(),
            SizedBox(height: tokens.cardGap),
            const _DiscussionSkeletonCard(compact: true),
          ],
        ),
      ),
    );
  }
}

class _DiscussionSkeletonCard extends StatelessWidget {
  const _DiscussionSkeletonCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      contentCard: true,
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              WenyouSkeletonBlock(
                height: tokens.space32,
                width: tokens.space32,
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.38,
                      child: WenyouSkeletonBlock(height: tokens.space12),
                    ),
                    SizedBox(height: tokens.space8),
                    FractionallySizedBox(
                      widthFactor: 0.22,
                      child: WenyouSkeletonBlock(height: tokens.space8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space20),
          for (final fraction
              in compact
                  ? const [1.0, 0.62]
                  : const [1.0, 0.94, 1.0, 0.72]) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: WenyouSkeletonBlock(height: tokens.space12),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (!compact) ...[
            SizedBox(height: tokens.space8),
            ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusControl),
              child: wenyouAnimationsDisabled(context)
                  ? SizedBox(
                      height: tokens.space4,
                      child: ColoredBox(color: tokens.brandSurface),
                    )
                  : LinearProgressIndicator(
                      minHeight: tokens.space4,
                      color: tokens.brandForeground,
                      backgroundColor: tokens.softPanel,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

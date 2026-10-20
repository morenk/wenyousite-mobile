import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

/// 已有阅读顶栏中的紧凑入口，滚动只更新编号，不触发读屏播报。
class DiscussionPositionButton extends StatelessWidget {
  const DiscussionPositionButton({
    required this.reading,
    required this.onPressed,
    required this.replies,
    this.entryKey,
    super.key,
  });

  final ReadingQuickScrollController reading;
  final VoidCallback onPressed;
  final bool replies;
  final GlobalKey? entryKey;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: reading,
    builder: (context, _) {
      if (entryKey != null &&
          (reading.isEntryVisible(entryKey!) ||
              reading.visibleBookmark?.number == null)) {
        return const SizedBox.shrink();
      }
      final number = reading.visibleBookmark?.number;
      final label = number == null ? '定位' : '#$number';
      final tokens = context.wenyouTokens;
      return Semantics(
        label:
            '${replies ? '回复' : '楼层'}定位${number == null ? '' : '，当前 $number'}',
        button: true,
        onTap: onPressed,
        excludeSemantics: true,
        child: TextButton(
          key: const Key('discussion-position-button'),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1),
              SizedBox(width: tokens.space4),
              const WenyouIcon(WenyouIconIds.navigationExpand, size: 16),
            ],
          ),
        ),
      );
    },
  );
}

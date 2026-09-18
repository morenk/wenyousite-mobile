import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadSubthreadNavigator extends StatelessWidget {
  const ThreadSubthreadNavigator({
    required this.subthreads,
    required this.selectedSubthreadId,
    required this.onSelected,
    super.key,
  });

  final List<ThreadSubthreadModel> subthreads;
  final String selectedSubthreadId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (subthreads.isEmpty) return const SizedBox.shrink();
    final tokens = context.wenyouTokens;
    final selectedIndex = subthreads.indexWhere(
      (subthread) => subthread.id == selectedSubthreadId,
    );
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final selected = subthreads[safeIndex];
    final canCycle = subthreads.length > 1;
    final previousIndex =
        (safeIndex - 1 + subthreads.length) % subthreads.length;
    final nextIndex = (safeIndex + 1) % subthreads.length;
    return Row(
      key: const Key('thread-subthread-navigator-frame'),
      children: [
        IconButton(
          key: const Key('thread-subthread-previous'),
          onPressed: canCycle
              ? () => onSelected(subthreads[previousIndex].id)
              : null,
          tooltip: canCycle
              ? '上一个子贴：${subthreads[previousIndex].title}'
              : '没有其他子贴',
          icon: const WenyouIcon(WenyouIconIds.navigationPrevious),
        ),
        Expanded(
          child: WenyouSelectionMenu<String>(
            key: const Key('thread-subthread-menu'),
            tooltip: '切换子贴',
            selected: selected.id,
            onSelected: onSelected,
            matchAnchorWidth: true,
            showScrollIndicator: true,
            menuTitle: '共 ${subthreads.length} 个子贴',
            optionKeyPrefix: 'thread-subthread',
            options: [
              for (final subthread in subthreads)
                WenyouFilterOption(
                  value: subthread.id,
                  keyValue: subthread.id,
                  label: subthread.title,
                  trailingLabel: '${subthread.postCount} 楼',
                ),
            ],
            anchorBuilder: (context, isOpen) => ConstrainedBox(
              constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
              child: Center(
                child: Container(
                  key: const Key('thread-subthread-menu-capsule'),
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.space12,
                    vertical: tokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(tokens.radius16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: tokens.space8 + 16),
                      Expanded(
                        child: Text(
                          selected.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.wenyouCaption
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(width: tokens.space8),
                      WenyouIcon(
                        isOpen
                            ? WenyouIconIds.navigationCollapse
                            : WenyouIconIds.navigationExpand,
                        size: 16,
                        color: tokens.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: const Key('thread-subthread-next'),
          onPressed: canCycle
              ? () => onSelected(subthreads[nextIndex].id)
              : null,
          tooltip: canCycle ? '下一个子贴：${subthreads[nextIndex].title}' : '没有其他子贴',
          icon: const WenyouIcon(WenyouIconIds.navigationNext),
        ),
      ],
    );
  }
}

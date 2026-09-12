import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadSubthreadNavigator extends StatefulWidget {
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
  State<ThreadSubthreadNavigator> createState() =>
      _ThreadSubthreadNavigatorState();
}

class _ThreadSubthreadNavigatorState extends State<ThreadSubthreadNavigator> {
  var _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedIndex = widget.subthreads.indexWhere(
      (subthread) => subthread.id == widget.selectedSubthreadId,
    );
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final selected = widget.subthreads[safeIndex];
    final canCycle = widget.subthreads.length > 1;
    final previousIndex =
        (safeIndex - 1 + widget.subthreads.length) % widget.subthreads.length;
    final nextIndex = (safeIndex + 1) % widget.subthreads.length;
    return Row(
      key: const Key('thread-subthread-navigator-frame'),
      children: [
        IconButton(
          key: const Key('thread-subthread-previous'),
          onPressed: canCycle
              ? () => widget.onSelected(widget.subthreads[previousIndex].id)
              : null,
          tooltip: canCycle
              ? '上一个子贴：${widget.subthreads[previousIndex].title}'
              : '没有其他子贴',
          icon: const WenyouIcon(WenyouIconIds.navigationPrevious),
        ),
        Expanded(
          child: OutlinedButton(
            key: const Key('thread-subthread-menu'),
            onPressed: () => _showSubthreads(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, tokens.minimumTouchTarget),
              padding: EdgeInsets.zero,
              side: BorderSide.none,
              textStyle: Theme.of(
                context,
              ).textTheme.wenyouCaption.copyWith(fontWeight: FontWeight.w500),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ConstrainedBox(
                key: const Key('thread-subthread-menu-capsule'),
                constraints: const BoxConstraints(minHeight: 36),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(tokens.radius16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.space8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selected.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: tokens.space4),
                        WenyouIcon(
                          _menuOpen
                              ? WenyouIconIds.navigationCollapse
                              : WenyouIconIds.navigationExpand,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: const Key('thread-subthread-next'),
          onPressed: canCycle
              ? () => widget.onSelected(widget.subthreads[nextIndex].id)
              : null,
          tooltip: canCycle
              ? '下一个子贴：${widget.subthreads[nextIndex].title}'
              : '没有其他子贴',
          icon: const WenyouIcon(WenyouIconIds.navigationNext),
        ),
      ],
    );
  }

  Future<void> _showSubthreads(BuildContext context) async {
    setState(() => _menuOpen = true);
    String? selected;
    try {
      selected = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          final tokens = sheetContext.wenyouTokens;
          return SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.space16,
                      0,
                      tokens.space16,
                      tokens.space12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '主题目录',
                            style: Theme.of(
                              sheetContext,
                            ).textTheme.wenyouRowTitle,
                          ),
                        ),
                        Text(
                          '共 ${widget.subthreads.length} 个子贴',
                          style: Theme.of(sheetContext).textTheme.wenyouCaption
                              .copyWith(color: tokens.mutedText),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: tokens.border),
                  Flexible(
                    child: ListView.separated(
                      key: const Key('thread-subthread-directory'),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.symmetric(vertical: tokens.space4),
                      itemCount: widget.subthreads.length,
                      separatorBuilder: (_, index) => Divider(
                        key: Key('thread-subthread-directory-divider-$index'),
                        height: 1,
                        indent: tokens.space16,
                        endIndent: tokens.space16,
                        color: tokens.border,
                      ),
                      itemBuilder: (context, index) {
                        final subthread = widget.subthreads[index];
                        final isSelected =
                            subthread.id == widget.selectedSubthreadId;
                        return ListTile(
                          key: Key('thread-subthread-${subthread.id}'),
                          minTileHeight: tokens.minimumTouchTarget,
                          selected: isSelected,
                          selectedColor: tokens.brandForeground,
                          selectedTileColor: tokens.accentedBackground,
                          shape: const RoundedRectangleBorder(),
                          leading: SizedBox.square(
                            dimension: 24,
                            child: isSelected
                                ? const WenyouIcon(
                                    WenyouIconIds.actionConfirm,
                                    size: 20,
                                  )
                                : null,
                          ),
                          title: Text(
                            subthread.title,
                            style: isSelected
                                ? Theme.of(context).textTheme.wenyouBody
                                      .copyWith(fontWeight: FontWeight.w600)
                                : null,
                          ),
                          trailing: Text(
                            '${subthread.postCount} 楼',
                            style: Theme.of(context).textTheme.wenyouCaption
                                .copyWith(color: tokens.mutedText),
                          ),
                          onTap: () => Navigator.pop(context, subthread.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _menuOpen = false);
    }
    if (!mounted) return;
    if (selected != null && selected != widget.selectedSubthreadId) {
      widget.onSelected(selected);
    }
  }
}

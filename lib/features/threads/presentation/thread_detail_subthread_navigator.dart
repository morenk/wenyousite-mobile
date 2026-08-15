part of 'thread_detail_page.dart';

class _SubthreadNavigator extends StatefulWidget {
  const _SubthreadNavigator({
    required this.subthreads,
    required this.selectedSubthreadId,
    required this.onSelected,
    required this.trailing,
  });

  final List<ThreadSubthreadModel> subthreads;
  final String selectedSubthreadId;
  final ValueChanged<String> onSelected;
  final Widget trailing;

  @override
  State<_SubthreadNavigator> createState() => _SubthreadNavigatorState();
}

class _SubthreadNavigatorState extends State<_SubthreadNavigator> {
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
        SizedBox(width: tokens.space4),
        Expanded(
          child: OutlinedButton(
            key: const Key('thread-subthread-menu'),
            onPressed: () => _showSubthreads(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, tokens.minimumTouchTarget),
              padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showDirectoryIcon = constraints.maxWidth >= 128;
                final showPostCount = constraints.maxWidth >= 176;
                return Row(
                  children: [
                    if (showDirectoryIcon) ...[
                      const WenyouIcon(WenyouIconIds.contentList, size: 18),
                      SizedBox(width: tokens.space8),
                    ],
                    Expanded(
                      child: Text(
                        selected.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showPostCount) ...[
                      SizedBox(width: tokens.space4),
                      Text(
                        '${selected.postCount} 楼',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                    SizedBox(width: tokens.space4),
                    WenyouIcon(
                      _menuOpen
                          ? WenyouIconIds.navigationCollapse
                          : WenyouIconIds.navigationExpand,
                      size: 18,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(width: tokens.space4),
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
        SizedBox(width: tokens.space4),
        widget.trailing,
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
                            style: Theme.of(sheetContext).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '共 ${widget.subthreads.length} 个子贴',
                          style: Theme.of(sheetContext).textTheme.bodySmall
                              ?.copyWith(color: tokens.mutedText),
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
                      padding: EdgeInsets.all(tokens.space12),
                      itemCount: widget.subthreads.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: tokens.space4),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.radius12,
                            ),
                          ),
                          leading: SizedBox.square(
                            dimension: 24,
                            child: isSelected
                                ? const WenyouIcon(
                                    WenyouIconIds.actionConfirm,
                                    size: 20,
                                  )
                                : null,
                          ),
                          title: Text(subthread.title),
                          trailing: Text(
                            '${subthread.postCount} 楼',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.mutedText),
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

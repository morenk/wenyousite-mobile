import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

class PostReplyFilters extends StatelessWidget {
  const PostReplyFilters({
    required this.state,
    required this.replyCount,
    required this.authors,
    required this.onOrder,
    required this.onAuthor,
    super.key,
  });

  final PostDiscussionState state;
  final int replyCount;
  final List<PostAuthor> authors;
  final ValueChanged<PostReplyOrder> onOrder;
  final ValueChanged<String?> onAuthor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedAuthor = authors
        .where((author) => author.id == state.authorId)
        .firstOrNull;
    final settingsLabel = selectedAuthor == null
        ? _shortOrderLabel(state.order)
        : '${_shortOrderLabel(state.order)} · ${selectedAuthor.username}';
    return Row(
      children: [
        Expanded(
          child: Text(
            '$replyCount 条回复',
            key: const Key('post-replies-count'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton.icon(
          key: const Key('post-replies-settings'),
          onPressed: () => _showSettings(context),
          style: TextButton.styleFrom(
            foregroundColor: tokens.mutedText,
            padding: EdgeInsets.symmetric(horizontal: tokens.space8),
          ),
          icon: WenyouIcon(
            WenyouIconIds.actionFilter,
            size: 20,
            color:
                selectedAuthor == null && state.order == PostReplyOrder.oldest
                ? tokens.mutedText
                : tokens.brandForeground,
          ),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 128),
            child: Text(
              settingsLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  String _shortOrderLabel(PostReplyOrder order) =>
      order == PostReplyOrder.oldest ? '最早在前' : '最新在前';

  Future<void> _showSettings(BuildContext context) async {
    final selected = await showModalBottomSheet<_ReplySettingsSelection>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ReplySettingsSheet(
        order: state.order,
        authorId: state.authorId,
        authors: authors,
      ),
    );
    if (!context.mounted || selected == null) return;
    switch (selected.kind) {
      case _ReplySettingsKind.order:
        final order = selected.order;
        if (order != null && order != state.order) onOrder(order);
      case _ReplySettingsKind.author:
        if (selected.authorId != state.authorId) onAuthor(selected.authorId);
    }
  }
}

class PostDiscussionTitle extends StatelessWidget {
  const PostDiscussionTitle({required this.root, super.key});

  final PostItem root;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final floorLabel = root.floorNumber == null
        ? null
        : '#${root.floorNumber}楼';
    final contextLabel = [
      root.subthreadTitle ?? '楼中楼讨论',
      ?floorLabel,
    ].join(' · ');
    return Column(
      key: const Key('post-replies-reading-title'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          root.threadTitle ?? '楼中楼讨论',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          contextLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
    );
  }
}

enum _ReplySettingsKind { order, author }

class _ReplySettingsSelection {
  const _ReplySettingsSelection.order(this.order)
    : kind = _ReplySettingsKind.order,
      authorId = null;

  const _ReplySettingsSelection.author(this.authorId)
    : kind = _ReplySettingsKind.author,
      order = null;

  final _ReplySettingsKind kind;
  final PostReplyOrder? order;
  final String? authorId;
}

class _ReplySettingsSheet extends StatelessWidget {
  const _ReplySettingsSheet({
    required this.order,
    required this.authorId,
    required this.authors,
  });

  final PostReplyOrder order;
  final String? authorId;
  final List<PostAuthor> authors;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: ListView(
          key: const Key('post-replies-settings-sheet'),
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: tokens.space12),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space24,
                0,
                tokens.space24,
                tokens.space8,
              ),
              child: Text(
                '讨论设置',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space24),
              child: Text(
                '回复顺序',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: tokens.mutedText),
              ),
            ),
            RadioGroup<PostReplyOrder>(
              groupValue: order,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context, _ReplySettingsSelection.order(value));
                }
              },
              child: Column(
                children: [
                  for (final value in PostReplyOrder.values)
                    RadioListTile<PostReplyOrder>(
                      value: value,
                      title: Text(value.label),
                    ),
                ],
              ),
            ),
            Divider(height: tokens.space16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space24),
              child: Text(
                '只看回复者',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: tokens.mutedText),
              ),
            ),
            RadioGroup<String>(
              groupValue: authorId ?? '',
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(
                    context,
                    _ReplySettingsSelection.author(
                      value.isEmpty ? null : value,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  const RadioListTile<String>(value: '', title: Text('全部回复者')),
                  for (final author in authors)
                    RadioListTile<String>(
                      value: author.id,
                      title: Text(author.username),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

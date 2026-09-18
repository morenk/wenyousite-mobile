import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';

@immutable
class WenyouDiscussionAuthorOption {
  const WenyouDiscussionAuthorOption({
    required this.id,
    required this.label,
    this.supportingLabel,
    this.avatarUrl,
  });

  final String id;
  final String label;
  final String? supportingLabel;
  final String? avatarUrl;
}

/// null 路由结果表示取消；authorId 为 null 则明确选择了所有人。
class WenyouAuthorSelection {
  const WenyouAuthorSelection(this.authorId);
  final String? authorId;
}

Future<WenyouAuthorSelection?> showWenyouAuthorPicker({
  required BuildContext context,
  required List<WenyouDiscussionAuthorOption> authors,
  required String? selectedId,
  required String allAuthorsLabel,
}) => showModalBottomSheet<WenyouAuthorSelection>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _AuthorPicker(
    authors: authors,
    selectedId: selectedId,
    allAuthorsLabel: allAuthorsLabel,
  ),
);

class _AuthorPicker extends StatefulWidget {
  const _AuthorPicker({
    required this.authors,
    required this.selectedId,
    required this.allAuthorsLabel,
  });
  final List<WenyouDiscussionAuthorOption> authors;
  final String? selectedId;
  final String allAuthorsLabel;

  @override
  State<_AuthorPicker> createState() => _AuthorPickerState();
}

class _AuthorPickerState extends State<_AuthorPicker> {
  final _selectedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedContext = _selectedKey.currentContext;
      if (mounted && selectedContext != null) {
        Scrollable.ensureVisible(selectedContext, alignment: 0.5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        key: const Key('discussion-author-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: tokens.space20,
                right: tokens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '只看作者',
                      style: Theme.of(context).textTheme.wenyouRowTitle,
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭作者筛选',
                    onPressed: () => Navigator.pop(context),
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('discussion-author-list'),
                padding: EdgeInsets.fromLTRB(
                  tokens.space12,
                  tokens.space4,
                  tokens.space12,
                  tokens.space12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _option(
                      id: null,
                      label: widget.allAuthorsLabel,
                      leading: SizedBox.square(
                        dimension: 40,
                        child: Center(
                          child: WenyouIcon(
                            WenyouIconIds.identityMember,
                            size: 22,
                            color: tokens.mutedText,
                          ),
                        ),
                      ),
                    ),
                    for (final author in widget.authors)
                      _option(
                        id: author.id,
                        label: author.label,
                        supportingLabel: author.supportingLabel,
                        leading: WenyouAvatar(
                          username: author.label,
                          avatarUrl: author.avatarUrl,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option({
    required String? id,
    required String label,
    required Widget leading,
    String? supportingLabel,
  }) {
    final tokens = context.wenyouTokens;
    final selected = id == widget.selectedId;
    return Padding(
      key: selected ? _selectedKey : null,
      padding: EdgeInsets.symmetric(vertical: tokens.space4 / 2),
      child: InkWell(
        key: ValueKey('discussion-author-${id ?? 'all'}'),
        borderRadius: BorderRadius.circular(tokens.radius12),
        onTap: () => Navigator.pop(context, WenyouAuthorSelection(id)),
        child: WenyouSelectionRow(
          label: label,
          selected: selected,
          leading: leading,
          supportingLabel: supportingLabel,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_buttons.dart';

class WenyouEditorMoreTray extends StatelessWidget {
  const WenyouEditorMoreTray({
    required this.enabled,
    required this.showLink,
    required this.showInlineStyles,
    required this.showBlockStyles,
    required this.showQuote,
    required this.showAlignment,
    required this.showDice,
    required this.showSticker,
    required this.inlineCodeSelected,
    required this.quoteSelected,
    required this.bulletListSelected,
    required this.orderedListSelected,
    required this.strikethroughSelected,
    required this.alignmentSelection,
    required this.onLink,
    required this.onInlineCode,
    required this.onQuote,
    required this.onBulletList,
    required this.onOrderedList,
    required this.onAlignmentChanged,
    required this.onHorizontalRule,
    required this.onDice,
    required this.onSticker,
    required this.onStrikethrough,
    super.key,
  });

  final bool enabled;
  final bool showLink;
  final bool showInlineStyles;
  final bool showBlockStyles;
  final bool showQuote;
  final bool showAlignment;
  final bool showDice;
  final bool showSticker;
  final bool inlineCodeSelected;
  final bool quoteSelected;
  final bool bulletListSelected;
  final bool orderedListSelected;
  final bool strikethroughSelected;
  final MarkdownAlignmentSelectionState alignmentSelection;
  final VoidCallback onLink;
  final VoidCallback onInlineCode;
  final VoidCallback onQuote;
  final VoidCallback onBulletList;
  final VoidCallback onOrderedList;
  final ValueChanged<WenyouTextAlignment> onAlignmentChanged;
  final VoidCallback onHorizontalRule;
  final VoidCallback onDice;
  final VoidCallback onSticker;
  final VoidCallback onStrikethrough;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final entries = <Widget>[
      if (showLink)
        _button(icon: WenyouIconIds.editorLink, label: '链接', onPressed: onLink),
      if (showInlineStyles)
        _button(
          icon: WenyouIconIds.editorInlineCode,
          label: '行内代码',
          selected: inlineCodeSelected,
          onPressed: onInlineCode,
        ),
      if (showQuote)
        _button(
          icon: WenyouIconIds.editorQuote,
          label: '引用',
          selected: quoteSelected,
          onPressed: onQuote,
        ),
      if (showBlockStyles)
        _button(
          icon: WenyouIconIds.editorBulletList,
          label: '无序列表',
          selected: bulletListSelected,
          onPressed: onBulletList,
        ),
      if (showBlockStyles)
        _button(
          icon: WenyouIconIds.editorOrderedList,
          label: '有序列表',
          selected: orderedListSelected,
          onPressed: onOrderedList,
        ),
      if (showAlignment)
        _button(
          key: const Key('editor-align-left'),
          icon: WenyouIconIds.editorAlignLeft,
          label: '左对齐',
          selected: alignmentSelection.alignment == WenyouTextAlignment.left,
          buttonEnabled: alignmentSelection.canApply,
          onPressed: () => onAlignmentChanged(WenyouTextAlignment.left),
        ),
      if (showAlignment)
        _button(
          key: const Key('editor-align-center'),
          icon: WenyouIconIds.editorAlignCenter,
          label: '居中',
          selected: alignmentSelection.alignment == WenyouTextAlignment.center,
          buttonEnabled: alignmentSelection.canApply,
          onPressed: () => onAlignmentChanged(WenyouTextAlignment.center),
        ),
      if (showAlignment)
        _button(
          key: const Key('editor-align-right'),
          icon: WenyouIconIds.editorAlignRight,
          label: '右对齐',
          selected: alignmentSelection.alignment == WenyouTextAlignment.right,
          buttonEnabled: alignmentSelection.canApply,
          onPressed: () => onAlignmentChanged(WenyouTextAlignment.right),
        ),
      if (showBlockStyles)
        _button(
          key: const Key('editor-horizontal-rule'),
          icon: WenyouIconIds.editorHorizontalRule,
          label: '分隔线',
          onPressed: onHorizontalRule,
        ),
      if (showDice)
        _button(icon: WenyouIconIds.editorDice, label: '骰子', onPressed: onDice),
      if (showSticker)
        _button(
          icon: WenyouIconIds.editorSticker,
          label: '表情包',
          onPressed: onSticker,
        ),
      if (showInlineStyles)
        _button(
          icon: WenyouIconIds.editorStrikethrough,
          label: '删除线',
          selected: strikethroughSelected,
          onPressed: onStrikethrough,
        ),
    ];
    return Container(
      key: const Key('editor-more-tray'),
      constraints: const BoxConstraints(maxHeight: 152),
      padding: EdgeInsets.symmetric(vertical: tokens.space4),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: SingleChildScrollView(
        key: const Key('editor-more-tray-scroll'),
        padding: const EdgeInsets.symmetric(
          horizontal: WenyouEditorContract.toolbarHorizontalPadding,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maximumColumns =
                (constraints.maxWidth /
                        WenyouEditorContract.minimumActionExtent)
                    .floor()
                    .clamp(1, 6);
            final rowCount = (entries.length / maximumColumns).ceil();
            final minimumRowLength = entries.length ~/ rowCount;
            final longerRows = entries.length % rowCount;
            final rows = <List<Widget>>[];
            var entryIndex = 0;
            for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
              final rowLength =
                  minimumRowLength + (rowIndex < longerRows ? 1 : 0);
              rows.add(entries.sublist(entryIndex, entryIndex += rowLength));
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (rowIndex, rowEntries) in rows.indexed)
                  Row(
                    key: Key('editor-more-row-$rowIndex'),
                    children: [
                      for (final entry in rowEntries)
                        Expanded(
                          child: Center(
                            child: SizedBox.square(
                              dimension:
                                  WenyouEditorContract.minimumActionExtent,
                              child: entry,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _button({
    Key? key,
    required String icon,
    required String label,
    required VoidCallback onPressed,
    bool selected = false,
    bool buttonEnabled = true,
  }) {
    return WenyouEditorTrayButton(
      key: key,
      icon: icon,
      label: label,
      selected: selected,
      enabled: enabled && buttonEnabled,
      onPressed: onPressed,
    );
  }
}

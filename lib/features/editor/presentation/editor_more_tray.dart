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
    final entries = <_MoreTrayEntry>[
      if (showLink)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorLink,
            label: '链接',
            onPressed: onLink,
          ),
        ),
      if (showInlineStyles)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorInlineCode,
            label: '行内代码',
            selected: inlineCodeSelected,
            onPressed: onInlineCode,
          ),
        ),
      if (showQuote)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorQuote,
            label: '引用',
            selected: quoteSelected,
            onPressed: onQuote,
          ),
        ),
      if (showBlockStyles)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorBulletList,
            label: '无序列表',
            selected: bulletListSelected,
            onPressed: onBulletList,
          ),
        ),
      if (showBlockStyles)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorOrderedList,
            label: '有序列表',
            selected: orderedListSelected,
            onPressed: onOrderedList,
          ),
        ),
      if (showAlignment)
        _MoreTrayEntry(
          slots: 3,
          child: WenyouEditorAlignmentControl(
            enabled: enabled,
            selection: alignmentSelection,
            onChanged: onAlignmentChanged,
          ),
        ),
      if (showBlockStyles)
        _MoreTrayEntry(
          child: _button(
            key: const Key('editor-horizontal-rule'),
            icon: WenyouIconIds.editorHorizontalRule,
            label: '分隔线',
            onPressed: onHorizontalRule,
          ),
        ),
      if (showDice)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorDice,
            label: '骰子',
            onPressed: onDice,
          ),
        ),
      if (showSticker)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorSticker,
            label: '表情包',
            onPressed: onSticker,
          ),
        ),
      if (showInlineStyles)
        _MoreTrayEntry(
          child: _button(
            icon: WenyouIconIds.editorStrikethrough,
            label: '删除线',
            selected: strikethroughSelected,
            onPressed: onStrikethrough,
          ),
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
            final columns = (constraints.maxWidth / 64).floor().clamp(4, 8);
            final cellWidth = constraints.maxWidth / columns;
            return Wrap(
              children: [
                for (final entry in entries)
                  SizedBox(
                    width: (cellWidth * entry.slots).clamp(
                      cellWidth,
                      constraints.maxWidth,
                    ),
                    child: entry.child,
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
  }) {
    return WenyouEditorTrayButton(
      key: key,
      icon: icon,
      label: label,
      selected: selected,
      enabled: enabled,
      onPressed: onPressed,
    );
  }
}

class WenyouEditorAlignmentControl extends StatelessWidget {
  const WenyouEditorAlignmentControl({
    required this.enabled,
    required this.selection,
    required this.onChanged,
    super.key,
  });

  final bool enabled;
  final MarkdownAlignmentSelectionState selection;
  final ValueChanged<WenyouTextAlignment> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selection.alignment == null
        ? <WenyouTextAlignment>{}
        : {selection.alignment!};
    final canApply = enabled && selection.canApply;
    return Semantics(
      container: true,
      label: '段落对齐',
      enabled: canApply,
      child: SegmentedButton<WenyouTextAlignment>(
        key: const Key('editor-alignment'),
        showSelectedIcon: false,
        emptySelectionAllowed: true,
        expandedInsets: EdgeInsets.zero,
        style: wenyouEditorSegmentedButtonStyle(context),
        segments: const [
          ButtonSegment(
            value: WenyouTextAlignment.left,
            tooltip: '左对齐',
            icon: WenyouIcon(
              WenyouIconIds.editorAlignLeft,
              key: Key('editor-align-left'),
            ),
          ),
          ButtonSegment(
            value: WenyouTextAlignment.center,
            tooltip: '居中',
            icon: WenyouIcon(
              WenyouIconIds.editorAlignCenter,
              key: Key('editor-align-center'),
            ),
          ),
          ButtonSegment(
            value: WenyouTextAlignment.right,
            tooltip: '右对齐',
            icon: WenyouIcon(
              WenyouIconIds.editorAlignRight,
              key: Key('editor-align-right'),
            ),
          ),
        ],
        selected: selected,
        onSelectionChanged: canApply
            ? (value) {
                if (value.isNotEmpty) onChanged(value.single);
              }
            : null,
      ),
    );
  }
}

final class _MoreTrayEntry {
  const _MoreTrayEntry({required this.child, this.slots = 1});

  final Widget child;
  final int slots;
}

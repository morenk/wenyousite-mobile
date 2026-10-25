import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_buttons.dart';

String editorFontLanguage(String value) =>
    const {'zh', 'ja', 'en'}.contains(value) ? value : 'other';

class EditorFontPanelHeader extends StatelessWidget {
  const EditorFontPanelHeader({this.defaultSelected, super.key});
  final bool? defaultSelected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.wenyouTokens.space16),
    child: Row(
      children: [
        Expanded(
          child: Text('字体', style: Theme.of(context).textTheme.wenyouRowTitle),
        ),
        if (defaultSelected != null)
          Semantics(
            key: const Key('editor-font-default'),
            selected: defaultSelected,
            child: TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: Text(defaultSelected! ? '默认字体' : '恢复默认'),
            ),
          ),
        IconButton(
          key: const Key('editor-font-close'),
          tooltip: '关闭字体',
          onPressed: () => Navigator.pop(context),
          icon: const WenyouIcon(WenyouIconIds.actionClose),
        ),
      ],
    ),
  );
}

class EditorFontPanel extends StatefulWidget {
  const EditorFontPanel({
    required this.initialLanguage,
    required this.hasOther,
    required this.defaultSelected,
    required this.writeEnabled,
    required this.body,
    this.selectionLabel,
    super.key,
  });
  final String initialLanguage;
  final bool hasOther;
  final bool defaultSelected;
  final bool writeEnabled;
  final String? selectionLabel;
  final Widget Function(BuildContext, String) body;
  @override
  State<EditorFontPanel> createState() => _EditorFontPanelState();
}

class _EditorFontPanelState extends State<EditorFontPanel> {
  late String _language = widget.initialLanguage;
  bool _manuallySelected = false;
  @override
  void didUpdateWidget(covariant EditorFontPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_manuallySelected &&
        oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final language = _language == 'other' && !widget.hasOther
        ? 'zh'
        : _language;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorFontPanelHeader(defaultSelected: widget.defaultSelected),
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            tokens.space4,
            tokens.space16,
            tokens.space8,
          ),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            style: wenyouEditorSegmentedButtonStyle(context),
            segments: [
              for (final entry in const {
                'zh': '中文',
                'ja': '日文',
                'en': '英文',
                'other': '其他',
              }.entries)
                if (entry.key != 'other' || widget.hasOther)
                  ButtonSegment(
                    value: entry.key,
                    label: Text(
                      entry.value,
                      key: Key('editor-font-language-${entry.key}'),
                    ),
                  ),
            ],
            selected: {language},
            onSelectionChanged: (value) => setState(() {
              _manuallySelected = true;
              _language = value.single;
            }),
          ),
        ),
        if (widget.selectionLabel case final label?)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space16,
              vertical: tokens.space4,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.wenyouCaption,
            ),
          ),
        if (!widget.writeEnabled)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space16,
              vertical: tokens.space4,
            ),
            child: const Text('暂时无法更换字体，可恢复默认字体'),
          ),
        Divider(height: 1, color: tokens.border),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(language),
            child: widget.body(context, language),
          ),
        ),
      ],
    );
    // 横屏或键盘收起的过渡帧高度极小时，整张面板可滚动而非溢出。
    return LayoutBuilder(
      builder: (context, constraints) {
        final minimum = tokens.minimumTouchTarget * 5;
        return constraints.maxHeight < minimum
            ? SingleChildScrollView(
                child: SizedBox(height: minimum, child: content),
              )
            : content;
      },
    );
  }
}

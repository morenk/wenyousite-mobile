import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dynamic_font_list.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_panel.dart';

class EditorTextFontSheet extends StatefulWidget {
  const EditorTextFontSheet({
    required this.service,
    required this.account,
    required this.writeEnabled,
    required this.selectedFont,
    required this.onRecentLoaded,
    super.key,
  });
  final TextFontService service;
  final String account;
  final bool writeEnabled;
  final ({String? font, bool mixed}) selectedFont;
  final ValueChanged<List<String>> onRecentLoaded;
  @override
  State<EditorTextFontSheet> createState() => _EditorTextFontSheetState();
}

class _EditorTextFontSheetState extends State<EditorTextFontSheet> {
  TextFontRuntime? _runtime;
  List<String> _recent = [];
  bool _loading = true;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final runtime = await widget.service.openPicker();
      if (!mounted) return;
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _runtime = runtime;
        _recent =
            preferences.getStringList(
              'editor.textFont.v1.${Uri.encodeComponent(widget.account)}',
            ) ??
            [];
        _recent = _recent
            .where(
              (id) => widget.service.dynamicEnabled
                  ? widget.service.dynamicRuntime?.catalog.entries.any(
                          (entry) => entry.versionId == id,
                        ) ==
                        true
                  : runtime.manifest?.fonts[id]?.ready == true &&
                        MarkdownTextFont.ids.contains(id),
            )
            .toList();
        _loading = false;
      });
      widget.onRecentLoaded(_recent);
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtime = _runtime;
    if (_loading || _failed || runtime == null) {
      return Column(
        children: [
          const EditorFontPanelHeader(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_loading) ...[
                      const WenyouCircularProgressIndicator(),
                      SizedBox(height: context.wenyouTokens.space16),
                      const Text('正在加载字体'),
                    ] else ...[
                      const Text('字体加载失败'),
                      TextButton(onPressed: _load, child: const Text('重新加载字体')),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (widget.service.dynamicEnabled) {
      return Column(
        children: [
          Expanded(
            child: EditorDynamicFontList(
              service: widget.service,
              runtime: runtime,
              writeEnabled: widget.writeEnabled,
              selectedFont: widget.selectedFont.font,
              mixedSelection: widget.selectedFont.mixed,
            ),
          ),
          if (widget.service.dynamicRuntime?.catalog.entries.isEmpty != false)
            TextButton(onPressed: _load, child: const Text('重新加载字体')),
        ],
      );
    }
    final fonts = runtime.manifest?.fonts.values.toList() ?? [];
    fonts.sort((a, b) {
      final ai = _recent.indexOf(a.id), bi = _recent.indexOf(b.id);
      return (ai < 0 ? 100 : ai).compareTo(bi < 0 ? 100 : bi);
    });
    final selected = widget.selectedFont;
    final current = runtime.manifest?.fonts[selected.font];
    return EditorFontPanel(
      initialLanguage: current == null
          ? 'zh'
          : editorFontLanguage(current.language?.name ?? 'other'),
      hasOther: fonts.any((font) => font.language == null),
      defaultSelected: !selected.mixed && selected.font == null,
      writeEnabled: widget.writeEnabled,
      selectionLabel: selected.mixed ? '多种字体' : null,
      body: (context, language) {
        final matching = fonts
            .where(
              (font) =>
                  editorFontLanguage(font.language?.name ?? 'other') ==
                  language,
            )
            .toList();
        return ListView(
          padding: EdgeInsets.only(bottom: context.wenyouTokens.space16),
          children: [
            if (matching.isEmpty) const ListTile(title: Text('暂无这类字体')),
            if (fonts.isEmpty || !runtime.assetsAvailable)
              ListTile(title: const Text('重新加载字体'), onTap: _load),
            for (final font in matching)
              ListTile(
                key: Key('editor-font-${font.id}'),
                title: Text(font.name),
                selected: !selected.mixed && selected.font == font.id,
                selectedColor: context.wenyouTokens.onAccentedBackground,
                selectedTileColor: context.wenyouTokens.accentedBackground,
                trailing: !selected.mixed && selected.font == font.id
                    ? WenyouIcon(
                        WenyouIconIds.actionConfirm,
                        color: context.wenyouTokens.onAccentedBackground,
                      )
                    : null,
                enabled:
                    widget.writeEnabled &&
                    font.ready &&
                    runtime.assetsAvailable &&
                    MarkdownTextFont.ids.contains(font.id),
                onTap: () => Navigator.pop(context, font.id),
              ),
          ],
        );
      },
    );
  }
}

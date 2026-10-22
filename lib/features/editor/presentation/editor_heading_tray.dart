import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_rgb_picker_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_palette.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_picker.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_buttons.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

class EditorTextColorConfiguration {
  const EditorTextColorConfiguration({
    required this.presets,
    required this.maximumRecentColors,
    required this.accountId,
    required this.store,
    required this.writeEnabled,
  });
  final List<EditorTextColorPreset> presets;
  final int maximumRecentColors;
  final String accountId;
  final EditorTextColorPreferenceStore store;
  final bool writeEnabled;
}

class WenyouEditorHeadingTray extends StatefulWidget {
  const WenyouEditorHeadingTray({
    required this.controller,
    required this.enabled,
    required this.onHeading,
    required this.onComplete,
    required this.onPickerChanged,
    this.focusNode,
    this.textColor,
    this.textFont = false,
    super.key,
  });
  final QuillController controller;
  final bool enabled;
  final ValueChanged<int> onHeading;
  final VoidCallback onComplete;
  final ValueChanged<bool> onPickerChanged;
  final FocusNode? focusNode;
  final EditorTextColorConfiguration? textColor;
  final bool textFont;

  @override
  State<WenyouEditorHeadingTray> createState() =>
      _WenyouEditorHeadingTrayState();
}

class _WenyouEditorHeadingTrayState extends State<WenyouEditorHeadingTray> {
  List<String> _recent = const [];
  TextSelection? _selection;
  String? _document;
  EditorTypingStyleSnapshot? _typingStyle;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecent());
  }

  @override
  void didUpdateWidget(covariant WenyouEditorHeadingTray oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textColor?.accountId != widget.textColor?.accountId ||
        oldWidget.textColor?.store != widget.textColor?.store) {
      _selection = null;
      _recent = const [];
      unawaited(_loadRecent());
    }
  }

  Future<void> _loadRecent() async {
    final generation = ++_generation;
    final config = widget.textColor;
    if (config == null) return;
    try {
      final values = await config.store.read(config.accountId);
      if (!mounted || generation != _generation) return;
      setState(
        () => _recent = values
            .where((v) => RegExp(r'^#[0-9A-F]{6}$').hasMatch(v))
            .toSet()
            .take(config.maximumRecentColors)
            .toList(),
      );
    } on Object {
      if (mounted && generation == _generation) {
        showWenyouSnackBar(context, '最近颜色加载失败', tone: WenyouSnackBarTone.error);
      }
    }
  }

  void _openPicker() {
    _selection = widget.controller.selection;
    _document = jsonEncode(widget.controller.document.toDelta().toJson());
    final controller = widget.controller;
    _typingStyle = controller is LiteralTextQuillController
        ? controller.captureTypingStyle()
        : null;
    widget.onPickerChanged(true);
    widget.focusNode?.unfocus();
    setState(() {});
  }

  void _complete() {
    final selection = _selection;
    if (selection != null &&
        _document ==
            jsonEncode(widget.controller.document.toDelta().toJson())) {
      _restoreSelection(selection);
    }
    widget.onPickerChanged(false);
    widget.onComplete();
    widget.focusNode?.requestFocus();
  }

  void _apply(String? color, {bool custom = false}) {
    final config = widget.textColor;
    if (!widget.enabled || config == null || !config.writeEnabled) {
      _complete();
      return;
    }
    if (_selection != null &&
        _document !=
            jsonEncode(widget.controller.document.toDelta().toJson())) {
      _complete();
      return;
    }
    final selection = _selection ?? widget.controller.selection;
    if (_selection != null) _restoreSelection(selection);
    EditorTextColorPolicy.apply(widget.controller, selection, color);
    if (color != null && (custom || _recent.contains(color))) {
      ++_generation;
      final recent = rememberEditorTextColor(
        _recent,
        color,
        maximum: config.maximumRecentColors,
      );
      final messenger = ScaffoldMessenger.maybeOf(context);
      unawaited(
        config.store.write(config.accountId, recent).catchError((Object error) {
          messenger?.showWenyouSnackBar(
            '最近颜色保存失败',
            tone: WenyouSnackBarTone.error,
          );
        }),
      );
    }
    _selection = null;
    _complete();
  }

  void _restoreSelection(TextSelection selection) {
    final controller = widget.controller;
    if (controller is LiteralTextQuillController) {
      controller.restoreToolSelection(selection, snapshot: _typingStyle);
    } else {
      controller.updateSelection(selection, ChangeSource.local);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selection = EditorTextColorPolicy.selection(widget.controller);
    if (_selection != null) {
      return EditorRgbPickerTray(
        initialColor: selection.color == null
            ? Theme.of(context).colorScheme.onSurface
            : Color(int.parse('FF${selection.color!.substring(1)}', radix: 16)),
        onApply: (color) => _apply(
          '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}',
          custom: true,
        ),
        onCancel: _complete,
      );
    }
    final header = widget.controller
        .getSelectionStyle()
        .attributes[Attribute.header.key]
        ?.value;
    return Container(
      key: const Key('editor-heading-tray'),
      padding: EdgeInsets.all(tokens.space8),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: IntrinsicWidth(
                  child: Row(
                    key: const Key('editor-font-heading-row'),
                    children: [
                      if (widget.textFont) ...[
                        EditorTextFontPicker(
                          controller: widget.controller,
                          enabled: widget.enabled,
                          focusNode: widget.focusNode,
                        ),
                        SizedBox(width: tokens.space8),
                      ],
                      Expanded(
                        child: SegmentedButton<int>(
                          showSelectedIcon: false,
                          style: wenyouEditorSegmentedButtonStyle(context),
                          segments: const [
                            ButtonSegment(value: 0, label: Text('正文')),
                            ButtonSegment(value: 2, label: Text('H2')),
                            ButtonSegment(value: 3, label: Text('H3')),
                          ],
                          selected: {
                            header == 2
                                ? 2
                                : header == 3
                                ? 3
                                : 0,
                          },
                          onSelectionChanged: widget.enabled
                              ? (value) => widget.onHeading(value.single)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.textColor case final config?)
            EditorTextColorPalette(
              presets: config.presets,
              recent: _recent,
              selection: widget.enabled
                  ? selection
                  : (enabled: false, mixed: false, color: null),
              writeEnabled: config.writeEnabled,
              onSelect: _apply,
              onCustom: _openPicker,
            ),
        ],
      ),
    );
  }
}

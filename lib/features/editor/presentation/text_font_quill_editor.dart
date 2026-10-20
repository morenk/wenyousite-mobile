import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_scope.dart';

class TextFontQuillEditor extends StatefulWidget {
  const TextFontQuillEditor({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.config,
    this.editorKey,
    super.key,
  });
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final QuillEditorConfig config;
  final Key? editorKey;

  @override
  State<TextFontQuillEditor> createState() => _TextFontQuillEditorState();
}

class _TextFontQuillEditorState extends State<TextFontQuillEditor> {
  Map<String, String> _texts = {};

  Map<String, String> _collect() {
    final texts = <String, String>{};
    for (final operation in widget.controller.document.toDelta().operations) {
      final font = operation.attributes?['font'];
      final text = operation.data;
      if (font is String && text is String) {
        texts[font] = '${texts[font] ?? ''}$text';
      }
    }
    return texts;
  }

  @override
  void initState() {
    super.initState();
    _texts = _collect();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant TextFontQuillEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
    _texts = _collect();
  }

  void _changed() {
    final texts = _collect();
    // 选区变化由 Quill 自己处理，不能重建并重新唤起工具箱已隐藏的手柄。
    if (!mapEquals(_texts, texts)) setState(() => _texts = texts);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFontScope(
    texts: _texts,
    builder: (context, runtime) => QuillEditor(
      key: widget.editorKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      scrollController: widget.scrollController,
      config: widget.config.copyWith(
        customStyleBuilder: (attribute) {
          if (attribute.key != 'font') {
            return widget.config.customStyleBuilder?.call(attribute) ??
                const TextStyle();
          }
          // 空家族让未加载/未知 ID 使用平台回退，绝不把协议 ID 当家族名。
          return runtime?.style(
                attribute.value as String,
                const TextStyle(fontFamily: ''),
              ) ??
              const TextStyle(fontFamily: '');
        },
      ),
    ),
  );
}

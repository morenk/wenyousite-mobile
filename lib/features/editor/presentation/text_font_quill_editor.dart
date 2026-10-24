import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_scope.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_download_progress.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

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
  int _applicationGeneration = -1;
  String? _applicationFont;
  Document? _document;
  StreamSubscription<DocChange>? _documentChanges;

  void _watchDocument() {
    if (identical(_document, widget.controller.document)) return;
    _documentChanges?.cancel();
    _document = widget.controller.document;
    // 输入事务先通知光标、后补文字字体；文档事件才能看到完整格式，
    // 否则首个 IME 字符的字体需求要等下一次用户操作才出现。
    _documentChanges = _document!.changes.listen((_) => _changed());
  }

  void _captureApplication() {
    final controller = widget.controller;
    _applicationGeneration = controller is LiteralTextQuillController
        ? controller.fontApplicationGeneration
        : -1;
    _applicationFont = controller is LiteralTextQuillController
        ? controller.fontApplication
        : null;
  }

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
    _captureApplication();
    _watchDocument();
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
    _captureApplication();
    _watchDocument();
  }

  void _changed() {
    if (!mounted) return;
    _watchDocument();
    final texts = _collect();
    final generation = widget.controller is LiteralTextQuillController
        ? (widget.controller as LiteralTextQuillController)
              .fontApplicationGeneration
        : -1;
    final font = widget.controller is LiteralTextQuillController
        ? (widget.controller as LiteralTextQuillController).fontApplication
        : null;
    // 选区变化由 Quill 自己处理，不能重建并重新唤起工具箱已隐藏的手柄。
    if (!mapEquals(_texts, texts) ||
        _applicationGeneration != generation ||
        _applicationFont != font) {
      setState(() {
        _texts = texts;
        _captureApplication();
      });
    }
  }

  @override
  void dispose() {
    _documentChanges?.cancel();
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFontScope(
    texts: _texts,
    builder: (context, runtime) => Column(
      children: [
        Expanded(
          child: QuillEditor(
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
        ),
        if (widget.controller case final LiteralTextQuillController controller)
          EditorFontDownloadProgress(
            runtime: runtime,
            font: controller.readOnly ? null : controller.fontApplication,
            text: _texts[controller.fontApplication] ?? '',
            generation: controller.fontApplicationGeneration,
          ),
      ],
    ),
  );
}

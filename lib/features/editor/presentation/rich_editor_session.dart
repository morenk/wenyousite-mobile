import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

enum RichEditorSelectionPlacement { preserve, start, end }

/// Owns the ephemeral Quill side of a Markdown-backed editing session.
///
/// Delta remains an in-memory presentation detail. Business controllers only
/// receive Markdown after a short idle period or an explicit [flush].
class RichEditorSession extends ChangeNotifier {
  RichEditorSession({
    required String initialMarkdown,
    required this.onMarkdownChanged,
    this.codecDebounce = const Duration(milliseconds: 120),
    RichEditorSelectionPlacement initialSelection =
        RichEditorSelectionPlacement.start,
  }) {
    final decoded = MarkdownDeltaCodec.decode(initialMarkdown);
    _issues = decoded.issues;
    _lastMarkdown = initialMarkdown;
    final document = Document.fromDelta(decoded.delta);
    controller = QuillController(
      document: document,
      selection: _selectionFor(document, initialSelection, null),
    )..addListener(_onDocumentChanged);
    focusNode.addListener(_onFocusChanged);
  }

  final Duration codecDebounce;
  final ValueChanged<String> onMarkdownChanged;

  late final QuillController controller;
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  Timer? _codecTimer;
  bool _applyingDocument = false;
  bool _disposed = false;
  bool _dirty = false;
  int _scheduledExternalRevision = -1;
  String _lastMarkdown = '';
  String? _codecFailure;
  List<MarkdownCodecIssue> _issues = const [];

  String? get codecFailure => _codecFailure;
  List<MarkdownCodecIssue> get issues => _issues;
  bool get hasFocus => focusNode.hasFocus;
  bool get isDirty => _dirty;
  int get characterCount =>
      controller.document.toPlainText().trimRight().length;

  set readOnly(bool value) => controller.readOnly = value;

  /// Applies an authoritative Markdown revision after the current build.
  void scheduleExternalMarkdown({
    required String markdown,
    required int revision,
    RichEditorSelectionPlacement selection =
        RichEditorSelectionPlacement.preserve,
  }) {
    if (revision == _scheduledExternalRevision) return;
    _scheduledExternalRevision = revision;
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      if (_disposed || revision != _scheduledExternalRevision) return;
      applyExternalMarkdown(markdown, selection: selection);
    });
    binding.ensureVisualUpdate();
  }

  void applyExternalMarkdown(
    String markdown, {
    RichEditorSelectionPlacement selection =
        RichEditorSelectionPlacement.preserve,
  }) {
    _codecTimer?.cancel();
    _applyingDocument = true;
    try {
      final decoded = MarkdownDeltaCodec.decode(markdown);
      final previousSelection = controller.selection;
      final document = Document.fromDelta(decoded.delta);
      controller.document = document;
      controller.updateSelection(
        _selectionFor(document, selection, previousSelection),
        ChangeSource.local,
      );
      _issues = decoded.issues;
      _codecFailure = null;
      _lastMarkdown = markdown;
      _dirty = false;
    } on Object catch (error) {
      _codecFailure = '恢复正文时发生错误：$error';
    } finally {
      _applyingDocument = false;
    }
    notifyListeners();
  }

  /// Encodes the current Delta immediately and publishes Markdown upstream.
  /// Returns false when the document contains a construct that cannot be
  /// represented safely by the Markdown v2 contract.
  bool flush() {
    _codecTimer?.cancel();
    _codecTimer = null;
    if (!_dirty && _codecFailure == null) return true;
    try {
      final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
      _codecFailure = null;
      _dirty = false;
      if (markdown != _lastMarkdown) {
        _lastMarkdown = markdown;
        onMarkdownChanged(markdown);
      }
      notifyListeners();
      return true;
    } on MarkdownCodecException catch (error) {
      _codecFailure = error.message;
      notifyListeners();
      return false;
    }
  }

  void insertBlockImage({
    required String url,
    String alt = '图片',
    String? title,
  }) {
    _replaceSelectionWithBlockEmbed(
      Embeddable(MarkdownDeltaCodec.imageEmbed, {
        'version': 1,
        'url': url,
        'alt': alt,
        'title': title,
      }),
    );
    flush();
  }

  void insertSticker({
    required String assetId,
    required String url,
    String alt = '表情',
  }) {
    _replaceSelectionWithInlineEmbed(
      Embeddable(MarkdownDeltaCodec.stickerEmbed, {
        'version': 1,
        'assetId': assetId,
        'url': url,
        'alt': alt,
      }),
    );
    flush();
  }

  void _replaceSelectionWithBlockEmbed(Embeddable embed) {
    var offset = _deleteSelection();
    final plainText = controller.document.toPlainText();
    if (offset > 0 && plainText[offset - 1] != '\n') {
      controller.replaceText(
        offset,
        0,
        '\n',
        TextSelection.collapsed(offset: offset + 1),
      );
      offset += 1;
    }
    controller.replaceText(
      offset,
      0,
      embed,
      TextSelection.collapsed(offset: offset + 1),
    );
    controller.replaceText(
      offset + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: offset + 2),
    );
  }

  void _replaceSelectionWithInlineEmbed(Embeddable embed) {
    final offset = _deleteSelection();
    controller.replaceText(
      offset,
      0,
      embed,
      TextSelection.collapsed(offset: offset + 1),
    );
  }

  int _deleteSelection() {
    final selection = controller.selection;
    final documentEnd = controller.document.length - 1;
    final start = selection.start.clamp(0, documentEnd).toInt();
    final end = selection.end.clamp(start, documentEnd).toInt();
    if (end > start) {
      controller.replaceText(
        start,
        end - start,
        '',
        TextSelection.collapsed(offset: start),
      );
    }
    return start;
  }

  void _onDocumentChanged() {
    if (_applyingDocument) return;
    _dirty = true;
    _codecTimer?.cancel();
    _codecTimer = Timer(codecDebounce, flush);
  }

  void _onFocusChanged() => notifyListeners();

  static TextSelection _selectionFor(
    Document document,
    RichEditorSelectionPlacement placement,
    TextSelection? previous,
  ) {
    final end = document.length - 1;
    final offset = switch (placement) {
      RichEditorSelectionPlacement.start => 0,
      RichEditorSelectionPlacement.end => end,
      RichEditorSelectionPlacement.preserve =>
        (previous?.baseOffset ?? 0).clamp(0, end).toInt(),
    };
    return TextSelection.collapsed(offset: offset);
  }

  @override
  void dispose() {
    _disposed = true;
    _codecTimer?.cancel();
    controller
      ..removeListener(_onDocumentChanged)
      ..dispose();
    focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    scrollController.dispose();
    super.dispose();
  }
}

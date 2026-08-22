// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';

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
    Future<String?> Function()? readClipboardText,
    Future<void> Function(String text)? writeClipboardText,
    WenyouEditorClipboardStore? clipboardStore,
    RichEditorSelectionPlacement initialSelection =
        RichEditorSelectionPlacement.start,
  }) : _readClipboardText = readClipboardText ?? _readSystemClipboardText,
       _writeClipboardText = writeClipboardText ?? _writeSystemClipboardText,
       _clipboardStore = clipboardStore ?? wenyouEditorClipboardStore {
    final decoded = MarkdownDeltaCodec.decode(initialMarkdown);
    _issues = decoded.issues;
    _lastMarkdown = initialMarkdown;
    final document = Document.fromDelta(decoded.delta);
    controller = QuillController(
      document: document,
      selection: _selectionFor(document, initialSelection, null),
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          onClipboardPaste: _pasteClipboard,
        ),
      ),
    )..addListener(_onDocumentChanged);
    focusNode.addListener(_onFocusChanged);
  }

  final Duration codecDebounce;
  final ValueChanged<String> onMarkdownChanged;
  final Future<String?> Function() _readClipboardText;
  final Future<void> Function(String text) _writeClipboardText;
  final WenyouEditorClipboardStore _clipboardStore;

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

  Map<ShortcutActivator, Intent> get clipboardShortcuts => const {
    SingleActivator(LogicalKeyboardKey.keyC, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.copy),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.copy),
    SingleActivator(LogicalKeyboardKey.keyX, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.cut),
    SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.cut),
    SingleActivator(LogicalKeyboardKey.keyV, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.paste),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.paste),
  };

  Map<Type, Action<Intent>> get clipboardActions => {
    _EditorClipboardIntent: CallbackAction<Intent>(
      onInvoke: (intent) {
        final clipboardIntent = intent as _EditorClipboardIntent;
        switch (clipboardIntent.action) {
          case WenyouEditorClipboardAction.copy:
            unawaited(copySelection());
          case WenyouEditorClipboardAction.cut:
            unawaited(copySelection(cut: true));
          case WenyouEditorClipboardAction.paste:
            unawaited(controller.clipboardPaste());
        }
        return null;
      },
    ),
  };

  Widget buildContextMenu(
    BuildContext context,
    QuillRawEditorState rawEditorState,
  ) {
    final items = rawEditorState.contextMenuButtonItems
        .map((item) {
          final type = item.type;
          if (type != ContextMenuButtonType.copy &&
              type != ContextMenuButtonType.cut) {
            return item;
          }
          return ContextMenuButtonItem(
            type: type,
            onPressed: () {
              unawaited(copySelection(cut: type == ContextMenuButtonType.cut));
              rawEditorState.hideToolbar();
            },
          );
        })
        .toList(growable: false);
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: rawEditorState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  Future<bool> copySelection({bool cut = false}) async {
    if ((cut && controller.readOnly) || controller.selection.isCollapsed) {
      return false;
    }
    final selection = controller.selection;
    final start = selection.start;
    final length = selection.end - start;
    final delta = controller.document.toDelta().slice(start, selection.end);
    final fallback = _clipboardStore.capture(
      delta: delta,
      plainTextFallback: controller.document.getPlainText(start, length),
      operation: cut
          ? WenyouEditorClipboardOperation.cut
          : WenyouEditorClipboardOperation.copy,
    );
    try {
      await _writeClipboardText(fallback);
    } on Object {
      _clipboardStore.clear();
      rethrow;
    }
    if (cut) {
      controller.replaceText(
        start,
        length,
        '',
        TextSelection.collapsed(offset: start),
      );
    }
    flush();
    return true;
  }

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
  /// represented safely by the Markdown v3 contract.
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

  Future<bool> _pasteClipboard() async {
    // `true` means the paste was handled. Consume it in read-only mode so
    // Quill does not fall back to the platform clipboard and attempt a write.
    if (controller.readOnly) return true;
    final clipboardText = await _readClipboardText();
    if (clipboardText == null) return false;
    final resolution = _clipboardStore.resolve(clipboardText);
    if (resolution.delta case final delta?) {
      _replaceSelectionWithDelta(delta);
      flush();
      return true;
    }
    if (resolution.usePlainText) {
      _replaceSelectionWithDelta(Delta()..insert(clipboardText));
      flush();
      return true;
    }
    final selection = controller.selection;
    final selectedText = selection.isCollapsed
        ? ''
        : controller.document.getPlainText(
            selection.start,
            selection.end - selection.start,
          );
    final paste = resolveInternalReferencePaste(
      clipboardText: clipboardText,
      selectedText: selectedText,
    );
    if (paste == null) return false;
    _replaceSelectionWithInlineEmbed(
      Embeddable(MarkdownDeltaCodec.internalReferenceEmbed, {
        'version': 1,
        'label': paste.label,
        'location': paste.reference.location.toString(),
      }),
    );
    flush();
    return true;
  }

  static Future<String?> _readSystemClipboardText() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboard?.text;
  }

  static Future<void> _writeSystemClipboardText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  void _replaceSelectionWithDelta(Delta delta) {
    final selection = controller.selection;
    controller.replaceText(
      selection.start,
      selection.end - selection.start,
      delta,
      TextSelection.collapsed(offset: selection.start + delta.length),
    );
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

enum WenyouEditorClipboardAction { copy, cut, paste }

class _EditorClipboardIntent extends Intent {
  const _EditorClipboardIntent(this.action);

  final WenyouEditorClipboardAction action;
}

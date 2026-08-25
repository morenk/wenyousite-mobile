// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

enum RichEditorSelectionPlacement { preserve, start, end }

enum RichEditorOperationFailureKind {
  clipboardBusy,
  clipboardEmpty,
  clipboardRead,
  clipboardWrite,
  pasteFailed,
  documentChanged,
  contentTooLong,
}

class RichEditorOperationFailure {
  const RichEditorOperationFailure(this.kind, this.message);

  final RichEditorOperationFailureKind kind;
  final String message;
}

/// Owns the ephemeral Quill side of a Markdown-backed editing session.
///
/// Delta remains an in-memory presentation detail. Business controllers only
/// receive Markdown after a short idle period or an explicit [flush].
class RichEditorSession extends ChangeNotifier {
  RichEditorSession({
    required String initialMarkdown,
    required this.onMarkdownChanged,
    this.codecDebounce = const Duration(milliseconds: 120),
    this.maximumSerializedLength = 10000,
    this.clipboardScope,
    EditorClipboardGateway? clipboardGateway,
    Future<String?> Function()? readClipboardText,
    Future<void> Function(String text)? writeClipboardText,
    WenyouEditorClipboardStore? clipboardStore,
    RichEditorSelectionPlacement initialSelection =
        RichEditorSelectionPlacement.start,
  }) : _clipboardGateway =
           clipboardGateway ??
           _legacyClipboardGateway(readClipboardText, writeClipboardText),
       _clipboardStore = clipboardStore ?? wenyouEditorClipboardStore {
    final decoded = MarkdownDeltaCodec.decode(initialMarkdown);
    _issues = decoded.issues;
    _lastMarkdown = initialMarkdown;
    _serializedLength = initialMarkdown.length;
    final document = Document.fromDelta(decoded.delta);
    controller = _LiteralTextQuillController(
      document: document,
      selection: _selectionFor(document, initialSelection, null),
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          onClipboardPaste: _pasteClipboard,
        ),
      ),
    );
    _listenToDocument(document);
    focusNode.addListener(_onFocusChanged);
  }

  final Duration codecDebounce;
  final int maximumSerializedLength;
  final Object? clipboardScope;
  final ValueChanged<String> onMarkdownChanged;
  final EditorClipboardGateway _clipboardGateway;
  final WenyouEditorClipboardStore _clipboardStore;

  late final QuillController controller;
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  Timer? _codecTimer;
  StreamSubscription<DocChange>? _documentChanges;
  Future<bool>? _pasteInFlight;
  bool _applyingDocument = false;
  bool _disposed = false;
  bool _dirty = false;
  int _documentGeneration = 0;
  int _scheduledExternalRevision = -1;
  String _lastMarkdown = '';
  String? _codecFailure;
  RichEditorOperationFailure? _operationFailure;
  int _serializedLength = 0;
  List<MarkdownCodecIssue> _issues = const [];

  String? get codecFailure => _codecFailure;
  RichEditorOperationFailure? get operationFailure => _operationFailure;
  List<MarkdownCodecIssue> get issues => _issues;
  bool get hasFocus => focusNode.hasFocus;
  bool get isDirty => _dirty;
  bool get isClipboardBusy => _pasteInFlight != null;
  int get serializedLength => _serializedLength;
  bool get isOverLimit => _serializedLength > maximumSerializedLength;
  int get characterCount =>
      controller.document.toPlainText().trimRight().length;

  set readOnly(bool value) => controller.readOnly = value;

  Map<ShortcutActivator, Intent> get clipboardShortcuts => {
    const SingleActivator(LogicalKeyboardKey.keyC, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.copy),
    const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.copy),
    const SingleActivator(LogicalKeyboardKey.keyX, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.cut),
    const SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.cut),
    const SingleActivator(LogicalKeyboardKey.keyV, control: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.paste),
    const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        _EditorClipboardIntent(WenyouEditorClipboardAction.paste),
    ..._blockedFormattingShortcuts(control: true),
    ..._blockedFormattingShortcuts(meta: true),
  };

  static Map<ShortcutActivator, Intent> _blockedFormattingShortcuts({
    bool control = false,
    bool meta = false,
  }) {
    const blocked = DoNothingAndStopPropagationIntent();
    return {
      for (final key in const [
        LogicalKeyboardKey.keyB,
        LogicalKeyboardKey.keyI,
        LogicalKeyboardKey.keyU,
        LogicalKeyboardKey.keyK,
        LogicalKeyboardKey.keyG,
        LogicalKeyboardKey.keyM,
        LogicalKeyboardKey.backquote,
        LogicalKeyboardKey.digit0,
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
        LogicalKeyboardKey.digit6,
      ])
        SingleActivator(key, control: control, meta: meta): blocked,
      for (final key in const [
        LogicalKeyboardKey.keyB,
        LogicalKeyboardKey.keyC,
        LogicalKeyboardKey.keyL,
        LogicalKeyboardKey.keyO,
        LogicalKeyboardKey.keyS,
        LogicalKeyboardKey.tilde,
      ])
        SingleActivator(key, control: control, meta: meta, shift: true):
            blocked,
    };
  }

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
    final documentSignature = _documentSignature();
    final delta = controller.document.toDelta().slice(start, selection.end);
    final marker = const Uuid().v4();
    final fallback = _clipboardStore.capture(
      delta: delta,
      plainTextFallback: controller.document.getPlainText(start, length),
      operation: cut
          ? WenyouEditorClipboardOperation.cut
          : WenyouEditorClipboardOperation.copy,
      marker: marker,
      scope: clipboardScope,
    );
    try {
      await _clipboardGateway.write(text: fallback, marker: marker);
    } on Object {
      _clipboardStore.clear();
      _setOperationFailure(
        RichEditorOperationFailureKind.clipboardWrite,
        cut ? '剪切失败，请重试。' : '复制失败，请重试。',
      );
      return false;
    }
    if (cut) {
      if (_disposed ||
          controller.readOnly ||
          controller.selection != selection ||
          _documentSignature() != documentSignature) {
        _setOperationFailure(
          RichEditorOperationFailureKind.documentChanged,
          '正文已发生变化，请重新剪切。',
        );
        return false;
      }
      controller.replaceText(
        start,
        length,
        '',
        TextSelection.collapsed(offset: start),
      );
    }
    await flush();
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
    _documentGeneration += 1;
    try {
      final decoded = MarkdownDeltaCodec.decode(markdown);
      final previousSelection = controller.selection;
      final document = Document.fromDelta(decoded.delta);
      unawaited(_documentChanges?.cancel());
      controller.document = document;
      _listenToDocument(document);
      controller.updateSelection(
        _selectionFor(document, selection, previousSelection),
        ChangeSource.local,
      );
      _issues = decoded.issues;
      _codecFailure = null;
      _operationFailure = null;
      _lastMarkdown = markdown;
      _serializedLength = markdown.length;
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
  Future<bool> flush() async {
    _codecTimer?.cancel();
    _codecTimer = null;
    await Future<void>.microtask(() {});
    final paste = _pasteInFlight;
    if (paste != null && !await paste) return false;
    return _flushCurrentDelta();
  }

  bool _flushCurrentDelta() {
    _codecTimer?.cancel();
    _codecTimer = null;
    try {
      final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
      _serializedLength = markdown.length;
      if (_serializedLength > maximumSerializedLength) {
        _setOperationFailure(
          RichEditorOperationFailureKind.contentTooLong,
          '正文过长，请删减后再保存。',
        );
        return false;
      }
      _codecFailure = null;
      if (_operationFailure?.kind ==
          RichEditorOperationFailureKind.contentTooLong) {
        _operationFailure = null;
      }
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
    _flushCurrentDelta();
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
    _flushCurrentDelta();
  }

  Future<bool> _pasteClipboard() {
    // `true` means the paste was handled. Quill must never fall back to its
    // HTML/Markdown path for this editor.
    if (controller.readOnly) return Future.value(true);
    if (_pasteInFlight != null) {
      _setOperationFailure(
        RichEditorOperationFailureKind.clipboardBusy,
        '正在粘贴，请稍候。',
      );
      return Future.value(true);
    }

    late final Future<bool> tracked;
    tracked = _performPasteSafely().whenComplete(() {
      if (identical(_pasteInFlight, tracked)) {
        _pasteInFlight = null;
        if (!_disposed) notifyListeners();
      }
    });
    _pasteInFlight = tracked;
    notifyListeners();
    // Quill interprets false as permission to execute its default rich paste.
    // The operation result remains available to flush(), but the platform
    // callback is always consumed, including empty or rejected clipboard data.
    return tracked.then((_) => true);
  }

  Future<bool> _performPasteSafely() async {
    try {
      return await _performPaste();
    } on Object {
      _setOperationFailure(
        RichEditorOperationFailureKind.pasteFailed,
        '粘贴失败，请重试。',
      );
      return false;
    }
  }

  Future<bool> _performPaste() async {
    final generation = _documentGeneration;
    final documentSignature = _documentSignature();
    final selection = controller.selection;
    final documentEnd = controller.document.length - 1;
    final start = selection.start.clamp(0, documentEnd).toInt();
    final end = selection.end.clamp(start, documentEnd).toInt();
    final selectedText = end == start
        ? ''
        : controller.document.getPlainText(start, end - start);

    EditorClipboardSnapshot snapshot;
    try {
      snapshot = await _clipboardGateway.read();
    } on Object {
      _setOperationFailure(
        RichEditorOperationFailureKind.clipboardRead,
        '无法读取剪贴板，请重试。',
      );
      return false;
    }
    if (_disposed ||
        controller.readOnly ||
        controller.selection != selection ||
        _documentSignature() != documentSignature ||
        generation != _documentGeneration) {
      if (!_disposed && generation == _documentGeneration) {
        _setOperationFailure(
          RichEditorOperationFailureKind.documentChanged,
          '正文已发生变化，请重新粘贴。',
        );
      }
      return false;
    }

    final clipboardText = _normalizeClipboardText(snapshot.text);
    if (clipboardText == null || clipboardText.isEmpty) {
      _setOperationFailure(
        RichEditorOperationFailureKind.clipboardEmpty,
        '剪贴板中没有可粘贴的文字。',
      );
      return false;
    }
    if (clipboardText.length > maximumSerializedLength) {
      _setOperationFailure(
        RichEditorOperationFailureKind.contentTooLong,
        '粘贴后正文过长，请删减后重试。',
      );
      return false;
    }

    final resolution = _clipboardStore.resolve(
      clipboardText,
      marker: snapshot.marker,
      scope: clipboardScope,
    );
    final insert = switch (resolution.delta) {
      final Delta delta => delta,
      null when !resolution.usePlainText => _internalReferenceDelta(
        clipboardText,
        selectedText,
      ),
      _ => null,
    };
    final delta =
        insert ??
        (Delta()..insert(clipboardText, {
          MarkdownDeltaCodec.literalTextAttribute: true,
        }));

    final candidateBefore = controller.document.toDelta();
    final candidate = Document.fromDelta(candidateBefore);
    candidate.replace(start, end - start, Delta.from(delta));
    final candidateMetadataPatch =
        MarkdownDeltaLineMetadata.sourceSeparatorPatch(
          before: candidateBefore,
          after: candidate.toDelta(),
          index: start,
          replacedLength: end - start,
          insertedLength: MarkdownDeltaLineMetadata.documentLength(delta),
          insertedDelta: delta,
        );
    if (candidateMetadataPatch.isNotEmpty) {
      candidate.compose(candidateMetadataPatch, ChangeSource.local);
    }
    final encoded = MarkdownDeltaCodec.encode(candidate.toDelta());
    if (encoded.length > maximumSerializedLength) {
      _serializedLength = encoded.length;
      _setOperationFailure(
        RichEditorOperationFailureKind.contentTooLong,
        '粘贴后正文过长，请删减后重试。',
      );
      return false;
    }
    if (_disposed ||
        controller.readOnly ||
        controller.selection != selection ||
        _documentSignature() != documentSignature ||
        generation != _documentGeneration) {
      return false;
    }

    controller.replaceText(
      start,
      end - start,
      delta,
      TextSelection.collapsed(
        offset: start + MarkdownDeltaLineMetadata.documentLength(delta),
      ),
    );
    _operationFailure = null;
    // Document changes are delivered by Quill's asynchronous stream. Drain
    // them so literal input formatting is composed before serialization and
    // so a stale debounce timer cannot fire after an immediate save.
    await Future<void>.microtask(() {});
    if (_disposed || generation != _documentGeneration) return false;
    _flushCurrentDelta();
    return true;
  }

  static Delta? _internalReferenceDelta(
    String clipboardText,
    String selectedText,
  ) {
    final paste = resolveInternalReferencePaste(
      clipboardText: clipboardText,
      selectedText: selectedText,
    );
    if (paste == null) return null;
    return Delta()..insert({
      MarkdownDeltaCodec.internalReferenceEmbed: {
        'version': 1,
        'label': paste.label,
        'location': paste.reference.location.toString(),
      },
    });
  }

  static String? _normalizeClipboardText(String? value) {
    if (value == null) return null;
    return value
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp('[\u2028\u2029]'), '\n')
        .replaceAll(
          RegExp('[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]'),
          '',
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

  void _listenToDocument(Document document) {
    _documentChanges = document.changes.listen(_onDocumentChange);
  }

  String _documentSignature() =>
      jsonEncode(controller.document.toDelta().toJson());

  void _onDocumentChange(DocChange change) {
    if (_applyingDocument || _disposed) return;
    _dirty = true;
    _operationFailure = null;
    try {
      if (MarkdownDeltaCodec.encode(controller.document.toDelta()) ==
          _lastMarkdown) {
        _dirty = false;
        _codecTimer?.cancel();
        _codecTimer = null;
        notifyListeners();
        return;
      }
    } on MarkdownCodecException {
      // The regular flush path below reports the actionable codec failure.
    }
    _codecTimer?.cancel();
    _codecTimer = Timer(codecDebounce, () => unawaited(flush()));
    notifyListeners();
  }

  void _setOperationFailure(
    RichEditorOperationFailureKind kind,
    String message,
  ) {
    _operationFailure = RichEditorOperationFailure(kind, message);
    if (!_disposed) notifyListeners();
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
    _documentGeneration += 1;
    _codecTimer?.cancel();
    unawaited(_documentChanges?.cancel());
    controller.dispose();
    focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    scrollController.dispose();
    super.dispose();
  }

  static EditorClipboardGateway _legacyClipboardGateway(
    Future<String?> Function()? read,
    Future<void> Function(String text)? write,
  ) {
    if (read == null && write == null) {
      return const PlatformEditorClipboardGateway();
    }
    return _CallbackEditorClipboardGateway(
      readCallback: read ?? _readSystemClipboardText,
      writeCallback: write ?? _writeSystemClipboardText,
    );
  }

  static Future<String?> _readSystemClipboardText() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboard?.text;
  }

  static Future<void> _writeSystemClipboardText(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}

/// Adds the literal-source marker synchronously while Quill still exposes the
/// exact replacement offset. Document change streams are asynchronous and may
/// otherwise describe an earlier edit after a later replacement has landed.
class _LiteralTextQuillController extends QuillController {
  _LiteralTextQuillController({
    required super.document,
    required super.selection,
    required super.config,
  });

  @override
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    final before = document.toDelta();
    super.replaceText(
      index,
      len,
      data,
      textSelection,
      ignoreFocus: ignoreFocus,
      shouldNotifyListeners: shouldNotifyListeners,
    );
    final insertedLength = switch (data) {
      String value => value.length,
      Delta value => MarkdownDeltaLineMetadata.documentLength(value),
      Embeddable() => 1,
      _ => 0,
    };
    final sourceSeparatorPatch = MarkdownDeltaLineMetadata.sourceSeparatorPatch(
      before: before,
      after: document.toDelta(),
      index: index,
      replacedLength: len,
      insertedLength: insertedLength,
      insertedDelta: data is Delta ? data : null,
    );
    if (sourceSeparatorPatch.isNotEmpty) {
      document.compose(sourceSeparatorPatch, ChangeSource.local);
    }
    if (data is! String || data.isEmpty) return;

    final formatting = Delta();
    var formattingOffset = 0;
    var sourceOffset = 0;
    while (sourceOffset < data.length) {
      final newline = data.indexOf('\n', sourceOffset);
      final end = newline < 0 ? data.length : newline;
      if (end > sourceOffset) {
        final start = index + sourceOffset;
        if (start > formattingOffset) {
          formatting.retain(start - formattingOffset);
        }
        formatting.retain(end - sourceOffset, {
          MarkdownDeltaCodec.literalTextAttribute: true,
        });
        formattingOffset = start + end - sourceOffset;
      }
      if (newline < 0) break;
      sourceOffset = newline + 1;
    }
    if (formatting.isNotEmpty) {
      document.compose(formatting, ChangeSource.local);
    }
  }
}

class _CallbackEditorClipboardGateway implements EditorClipboardGateway {
  _CallbackEditorClipboardGateway({
    required this.readCallback,
    required this.writeCallback,
  });

  final Future<String?> Function() readCallback;
  final Future<void> Function(String text) writeCallback;
  String? _lastWrittenText;
  String? _lastMarker;

  @override
  Future<EditorClipboardSnapshot> read() async {
    final text = await readCallback();
    return EditorClipboardSnapshot(
      text: text,
      marker: text == _lastWrittenText ? _lastMarker : null,
    );
  }

  @override
  Future<void> write({required String text, required String marker}) async {
    await writeCallback(text);
    _lastWrittenText = text;
    _lastMarker = marker;
  }
}

enum WenyouEditorClipboardAction { copy, cut, paste }

class _EditorClipboardIntent extends Intent {
  const _EditorClipboardIntent(this.action);

  final WenyouEditorClipboardAction action;
}

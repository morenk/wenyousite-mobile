// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';

enum WenyouAtomicTextSelectionPlacement { preserve, start, end }

/// Owns a compact plain-text document whose only structured inline node is a
/// Wenyou internal reference. The wire value remains canonical Markdown.
class WenyouAtomicTextController extends ChangeNotifier {
  WenyouAtomicTextController({
    required String initialMarkdown,
    required this.maximumMarkdownLength,
  }) {
    final document = Document.fromDelta(_decode(initialMarkdown));
    quillController = _AtomicTextQuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          onClipboardPaste: _handleClipboardPaste,
        ),
      ),
    );
    _markdown = _encodeDocument(document.toDelta());
    _documentChanges = document.changes.listen(_handleDocumentChanged);
  }

  final int maximumMarkdownLength;

  late final QuillController quillController;
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  late StreamSubscription<DocChange> _documentChanges;
  String _markdown = '';
  String? _failure;
  bool _disposed = false;
  Future<bool>? _pasteInFlight;

  String get markdown => _markdown;
  String? get failure => _failure;
  bool get isEmpty => _markdown.trim().isEmpty;
  bool get isOverLimit => _markdown.length > maximumMarkdownLength;
  int get documentLength => quillController.document.length - 1;
  TextSelection get selection => quillController.selection;

  set readOnly(bool value) => quillController.readOnly = value;

  Map<ShortcutActivator, Intent> get clipboardShortcuts => const {
    SingleActivator(LogicalKeyboardKey.keyC, control: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.copy),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.copy),
    SingleActivator(LogicalKeyboardKey.keyX, control: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.cut),
    SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.cut),
    SingleActivator(LogicalKeyboardKey.keyV, control: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.paste),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        _AtomicClipboardIntent(_AtomicClipboardAction.paste),
  };

  Map<Type, Action<Intent>> get clipboardActions => {
    _AtomicClipboardIntent: CallbackAction<Intent>(
      onInvoke: (intent) {
        final action = (intent as _AtomicClipboardIntent).action;
        switch (action) {
          case _AtomicClipboardAction.copy:
            unawaited(copySelection());
          case _AtomicClipboardAction.cut:
            unawaited(copySelection(cut: true));
          case _AtomicClipboardAction.paste:
            unawaited(pasteClipboard());
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
    return TextFieldTapRegion(
      child: AdaptiveTextSelectionToolbar.buttonItems(
        anchors: rawEditorState.contextMenuAnchors,
        buttonItems: items,
      ),
    );
  }

  bool flush() {
    try {
      _syncMarkdown();
    } on Object {
      _failure = '内容暂时无法发送，请重新编辑后再试。';
      notifyListeners();
      return false;
    }
    if (isOverLimit) {
      _failure = '内容过长，请删减后再发送。';
      notifyListeners();
      return false;
    }
    _failure = null;
    notifyListeners();
    return true;
  }

  void clear() =>
      applyMarkdown('', selection: WenyouAtomicTextSelectionPlacement.start);

  void applyMarkdown(
    String markdown, {
    WenyouAtomicTextSelectionPlacement selection =
        WenyouAtomicTextSelectionPlacement.preserve,
  }) {
    final previousSelection = quillController.selection;
    final document = Document.fromDelta(_decode(markdown));
    unawaited(_documentChanges.cancel());
    quillController.document = document;
    _documentChanges = document.changes.listen(_handleDocumentChanged);
    final end = document.length - 1;
    final nextSelection = switch (selection) {
      WenyouAtomicTextSelectionPlacement.start => const TextSelection.collapsed(
        offset: 0,
      ),
      WenyouAtomicTextSelectionPlacement.end => TextSelection.collapsed(
        offset: end,
      ),
      WenyouAtomicTextSelectionPlacement.preserve => TextSelection(
        baseOffset: previousSelection.baseOffset.clamp(0, end),
        extentOffset: previousSelection.extentOffset.clamp(0, end),
        affinity: previousSelection.affinity,
        isDirectional: previousSelection.isDirectional,
      ),
    };
    quillController.updateSelection(nextSelection, ChangeSource.local);
    _markdown = _encodeDocument(document.toDelta());
    _failure = null;
    notifyListeners();
  }

  void updateSelection(TextSelection selection) {
    final end = documentLength;
    quillController.updateSelection(
      TextSelection(
        baseOffset: selection.baseOffset.clamp(0, end),
        extentOffset: selection.extentOffset.clamp(0, end),
        affinity: selection.affinity,
        isDirectional: selection.isDirectional,
      ),
      ChangeSource.local,
    );
  }

  Future<bool> copySelection({bool cut = false}) async {
    if ((cut && quillController.readOnly) ||
        quillController.selection.isCollapsed) {
      return false;
    }
    final selection = quillController.selection;
    final start = selection.start;
    final length = selection.end - start;
    final delta = quillController.document.toDelta().slice(
      start,
      selection.end,
    );
    final fallback = _atomicClipboard.capture(delta);
    try {
      await Clipboard.setData(ClipboardData(text: fallback));
    } on Object {
      _failure = cut ? '剪切失败，请重试。' : '复制失败，请重试。';
      notifyListeners();
      return false;
    }
    if (cut && !_disposed && quillController.selection == selection) {
      quillController.replaceText(
        start,
        length,
        '',
        TextSelection.collapsed(offset: start),
      );
    }
    return true;
  }

  @visibleForTesting
  String? captureSelectionForTesting() {
    if (quillController.selection.isCollapsed) return null;
    final selection = quillController.selection;
    return _atomicClipboard.capture(
      quillController.document.toDelta().slice(selection.start, selection.end),
    );
  }

  Future<bool> _handleClipboardPaste() => pasteClipboard().then((_) => true);

  Future<bool> pasteClipboard() {
    if (quillController.readOnly || _pasteInFlight != null) {
      return Future.value(false);
    }
    late final Future<bool> tracked;
    tracked = _performPaste().whenComplete(() {
      if (identical(_pasteInFlight, tracked)) _pasteInFlight = null;
    });
    _pasteInFlight = tracked;
    return tracked;
  }

  Future<bool> _performPaste() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (_disposed || quillController.readOnly) return false;
    final text = _normalizeClipboardText(clipboard?.text);
    if (text == null || text.isEmpty) return false;

    return pasteText(text);
  }

  bool pasteText(String text) {
    if (_disposed || quillController.readOnly || text.isEmpty) return false;

    final selection = quillController.selection;
    final start = selection.start.clamp(0, documentLength);
    final end = selection.end.clamp(start, documentLength);
    final selectedText = end == start
        ? ''
        : quillController.document.getPlainText(start, end - start);
    final stored = _atomicClipboard.resolve(text);
    final insert = stored ?? _internalReferenceDelta(text, selectedText);
    final data = insert ?? text;
    final insertedLength = insert?.length ?? text.length;
    quillController.replaceText(
      start,
      end - start,
      data,
      TextSelection.collapsed(offset: start + insertedLength),
    );
    return true;
  }

  void _handleDocumentChanged(DocChange _) {
    if (_disposed) return;
    _syncMarkdown();
    notifyListeners();
  }

  void _syncMarkdown() {
    _markdown = _encodeDocument(quillController.document.toDelta());
    _failure = isOverLimit ? '内容过长，请删减后再发送。' : null;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_documentChanges.cancel());
    quillController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

class WenyouAtomicTextEditor extends StatelessWidget {
  const WenyouAtomicTextEditor({
    required this.controller,
    required this.editorKey,
    required this.placeholder,
    required this.semanticLabel,
    this.enabled = true,
    this.autofocus = false,
    this.expands = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.constraints = const BoxConstraints(minHeight: 48, maxHeight: 132),
    super.key,
  });

  final WenyouAtomicTextController controller;
  final Key editorKey;
  final String placeholder;
  final String semanticLabel;
  final bool enabled;
  final bool autofocus;
  final bool expands;
  final EdgeInsetsGeometry padding;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    controller.readOnly = !enabled;
    final tokens = context.wenyouTokens;
    const horizontalSpacing = HorizontalSpacing.zero;
    const verticalSpacing = VerticalSpacing.zero;
    final body = Theme.of(context).textTheme.wenyouBody;
    final styles = DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        body,
        horizontalSpacing,
        verticalSpacing,
        verticalSpacing,
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        body.copyWith(color: tokens.mutedText),
        horizontalSpacing,
        verticalSpacing,
        verticalSpacing,
        null,
      ),
    );
    final editor = Semantics(
      textField: true,
      label: semanticLabel,
      child: QuillEditor(
        key: editorKey,
        controller: controller.quillController,
        focusNode: controller.focusNode,
        scrollController: controller.scrollController,
        config: QuillEditorConfig(
          scrollable: true,
          expands: expands,
          autoFocus: autofocus,
          padding: padding,
          placeholder: placeholder,
          customStyles: styles,
          embedBuilders: const [_AtomicInternalReferenceEmbedBuilder()],
          customShortcuts: controller.clipboardShortcuts,
          customActions: controller.clipboardActions,
          contextMenuBuilder: controller.buildContextMenu,
          onTapOutside: (_, focusNode) => focusNode.unfocus(),
        ),
      ),
    );
    if (expands) return editor;
    return ConstrainedBox(constraints: constraints, child: editor);
  }
}

class _AtomicTextQuillController extends QuillController {
  _AtomicTextQuillController({
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
    final internalReference = data is String
        ? _internalReferenceDelta(
            data,
            len == 0 ? '' : document.getPlainText(index, len),
          )
        : null;
    final effectiveData = internalReference ?? data;
    final effectiveSelection = internalReference == null
        ? textSelection
        : TextSelection.collapsed(offset: index + 1);
    if (effectiveData is Delta) toggledStyle = const Style();
    super.replaceText(
      index,
      len,
      effectiveData,
      effectiveSelection,
      ignoreFocus: ignoreFocus,
      shouldNotifyListeners: shouldNotifyListeners,
    );
  }
}

class _AtomicInternalReferenceEmbedBuilder extends EmbedBuilder {
  const _AtomicInternalReferenceEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.internalReferenceEmbed;

  @override
  bool get expanded => false;

  @override
  WidgetSpan buildWidgetSpan(Widget widget) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: widget,
  );

  @override
  String toPlainText(Embed node) => _portalLabel(node.value.data);

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final label = _portalLabel(embedContext.node.value.data);
    return Semantics(
      key: const Key('atomic-editor-internal-reference'),
      label: '站内传送门：$label',
      excludeSemantics: true,
      child: WenyouInternalReferenceSurface(
        label: label,
        style: embedContext.textStyle,
      ),
    );
  }
}

Delta _decode(String markdown) {
  final delta = Delta();
  for (final segment in tokenizeInternalReferenceText(markdown)) {
    switch (segment) {
      case InternalReferencePlainText(:final value):
        if (value.isNotEmpty) delta.insert(value);
      case InternalReferencePortal(:final label, :final reference):
        delta.insert({
          MarkdownDeltaCodec.internalReferenceEmbed: {
            'version': 1,
            'label': label,
            'location': reference.location.toString(),
          },
        });
    }
  }
  delta.insert('\n');
  return delta;
}

Delta? _internalReferenceDelta(String text, String selectedText) {
  final paste = resolveInternalReferencePaste(
    clipboardText: text,
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

String _encodeDocument(Delta delta) {
  final encoded = _encodeDelta(delta);
  return encoded.endsWith('\n')
      ? encoded.substring(0, encoded.length - 1)
      : encoded;
}

String _encodeDelta(Delta delta) {
  final output = StringBuffer();
  for (final operation in delta.operations) {
    if (!operation.isInsert) continue;
    final data = operation.data;
    if (data is String) {
      output.write(data);
      continue;
    }
    if (data is! Map || data.length != 1) {
      throw const FormatException('无法识别的编辑器原子');
    }
    final payload = data[MarkdownDeltaCodec.internalReferenceEmbed];
    if (payload is! Map) {
      throw const FormatException('无法识别的编辑器原子');
    }
    final location = payload['location']?.toString();
    final reference = location == null
        ? null
        : parseInternalReference(location);
    if (reference == null) throw const FormatException('站内传送门地址不合法');
    final label = resolveInternalReferenceLabel(
      label: payload['label']?.toString() ?? internalReferenceDefaultLabel,
      reference: reference,
    );
    output.write(
      InternalReferencePaste(label: label, reference: reference).serialized,
    );
  }
  return output.toString();
}

String _portalLabel(Object? data) {
  if (data is! Map) return internalReferenceDefaultLabel;
  final location = data['location']?.toString();
  final reference = location == null ? null : parseInternalReference(location);
  final label = data['label']?.toString() ?? internalReferenceDefaultLabel;
  return reference == null
      ? label
      : resolveInternalReferenceLabel(label: label, reference: reference);
}

String? _normalizeClipboardText(String? value) {
  if (value == null) return null;
  return value
      .replaceAll(RegExp(r'\r\n?'), '\n')
      .replaceAll(RegExp('[\u2028\u2029]'), '\n')
      .replaceAll(
        RegExp('[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]'),
        '',
      );
}

final _atomicClipboard = _AtomicClipboardStore();

class _AtomicClipboardStore {
  Delta? _delta;
  String? _fallback;
  DateTime? _capturedAt;

  String capture(Delta delta) {
    final copy = Delta.fromJson(delta.toJson());
    final fallback = _encodeDelta(copy);
    _delta = copy;
    _fallback = fallback;
    _capturedAt = DateTime.now();
    return fallback;
  }

  Delta? resolve(String clipboardText) {
    final capturedAt = _capturedAt;
    if (_delta == null ||
        _fallback != clipboardText ||
        capturedAt == null ||
        DateTime.now().difference(capturedAt) > const Duration(minutes: 10)) {
      _delta = null;
      _fallback = null;
      _capturedAt = null;
      return null;
    }
    return Delta.fromJson(_delta!.toJson());
  }
}

enum _AtomicClipboardAction { copy, cut, paste }

class _AtomicClipboardIntent extends Intent {
  const _AtomicClipboardIntent(this.action);

  final _AtomicClipboardAction action;
}

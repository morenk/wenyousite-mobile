// ignore_for_file: experimental_member_use
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/editor/quill_document_range.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_link_identity.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_paste.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_document_alignment.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_selection_history.dart';

typedef EditorTypingStyleSnapshot = ({
  Document document,
  Style style,
  bool hasColor,
  String? color,
  int generation,
});

/// Marks literal source at the exact offset before async changes can race.
class LiteralTextQuillController extends QuillController {
  LiteralTextQuillController({
    required super.document,
    required super.selection,
    required super.config,
  });

  final _selectionHistory = EditorSelectionHistory();
  bool _hasTypingColor = false;
  String? _typingColor;
  int _editDepth = 0;
  bool _textColorInputEnabled = true;
  int _typingInputGeneration = 0;

  bool get textColorInputEnabled => _textColorInputEnabled;
  set textColorInputEnabled(bool enabled) {
    if (_textColorInputEnabled == enabled) return;
    _textColorInputEnabled = enabled;
    _typingInputGeneration++;
    _hasTypingColor = false;
    _typingColor = null;
    toggledStyle = toggledStyle.removeAll({Attribute.color});
  }

  /// 未选色／显式 RGB／显式默认属于会话输入状态，不写入正文或草稿。
  void useColorForTyping(String? color) {
    if (readOnly || !_textColorInputEnabled) return;
    _hasTypingColor = true;
    _typingColor = color;
    document.history.lastRecorded = 0;
    _restoreTypingColor();
    notifyListeners();
  }

  void useDefaultColorForTyping() => useColorForTyping(null);

  EditorTypingStyleSnapshot captureTypingStyle() => (
    document: document,
    style: toggledStyle,
    hasColor: _hasTypingColor,
    color: _typingColor,
    generation: _typingInputGeneration,
  );

  /// 工具面板恢复的是原输入位置，不能被当成主动移位清掉未落地样式。
  /// 快照只对同一文档和仍允许写色的会话有效。
  void restoreToolSelection(
    TextSelection selected, {
    EditorTypingStyleSnapshot? snapshot,
  }) {
    final saved = snapshot ?? captureTypingStyle();
    if (!identical(saved.document, document)) return;
    _withTypingColorState(() {
      final canRestoreColor =
          saved.generation == _typingInputGeneration &&
          _textColorInputEnabled &&
          !readOnly;
      _hasTypingColor = saved.hasColor && canRestoreColor;
      _typingColor = _hasTypingColor ? saved.color : null;
      super.updateSelection(selected, ChangeSource.local);
      toggledStyle = canRestoreColor
          ? saved.style
          : saved.style.removeAll({Attribute.color});
      _restoreTypingColor();
      notifyListeners();
    });
  }

  @override
  set readOnly(bool value) {
    if (value) {
      _typingInputGeneration++;
      _hasTypingColor = false;
      _typingColor = null;
      toggledStyle = toggledStyle.removeAll({Attribute.color});
    }
    super.readOnly = value;
  }

  String? get typingColor => !_textColorInputEnabled
      ? null
      : _hasTypingColor
      ? _typingColor
      : super.getSelectionStyle().attributes[Attribute.color.key]?.value
            as String?;

  void _restoreTypingColor() {
    if (_hasTypingColor || !_textColorInputEnabled) {
      toggledStyle = toggledStyle.put(
        Attribute.clone(Attribute.color, typingColor),
      );
    }
  }

  /// 纯文本粘贴在提交时取色一次，验证和真正插入使用同一份 Delta。
  /// 结构化片段不调用这里，颜色只属于非换行的普通字符。
  Delta colorPlainTextPaste(Delta source) {
    final color = typingColor;
    final result = Delta();
    for (final operation in source.operations) {
      final text = operation.data;
      if (text is! String) {
        result.insert(text, operation.attributes);
        continue;
      }
      final parts = text.split('\n');
      for (var index = 0; index < parts.length; index++) {
        if (parts[index].isNotEmpty) {
          final attributes = Map<String, dynamic>.from(
            operation.attributes ?? {},
          )..remove('color');
          if (color != null) attributes['color'] = color;
          result.insert(parts[index], attributes.isEmpty ? null : attributes);
        }
        if (index < parts.length - 1) {
          final attributes = Map<String, dynamic>.from(
            operation.attributes ?? {},
          )..remove('color');
          result.insert('\n', attributes.isEmpty ? null : attributes);
        }
      }
    }
    return result;
  }

  @override
  set document(Document value) {
    _hasTypingColor = false;
    _typingColor = null;
    toggledStyle = const Style();
    super.document = value;
  }

  @override
  void updateSelection(TextSelection textSelection, ChangeSource source) {
    // 输入、撤销及音频投影的位置补偿不是用户主动移动光标；同选区的
    // 焦点恢复和 IME 回报也不能取消尚未落地的输入色。
    if (_editDepth == 0 &&
        (textSelection.baseOffset != selection.baseOffset ||
            textSelection.extentOffset != selection.extentOffset)) {
      _hasTypingColor = false;
      _typingColor = null;
    }
    super.updateSelection(textSelection, source);
    _restoreTypingColor();
  }

  /// 复合命令的正文变化与最终选区一起附着于同一原生历史条目。
  void runEditCommand(void Function() command) =>
      _withTypingColorState(() => _selectionHistory.record(this, command));

  void projectDocumentView(Delta Function(Delta) project) =>
      _withTypingColorState(() => _selectionHistory.projectView(this, project));

  void _withTypingColorState(void Function() command) {
    _editDepth++;
    try {
      command();
    } finally {
      _editDepth--;
      _restoreTypingColor();
    }
  }

  @override
  void undo() => _withTypingColorState(
    () => _selectionHistory.restore(this, super.undo, undo: true),
  );

  @override
  void redo() => _withTypingColorState(
    () => _selectionHistory.restore(this, super.redo, undo: false),
  );

  @override
  void formatText(
    int index,
    int len,
    Attribute? attribute, {
    bool shouldNotifyListeners = true,
  }) => runEditCommand(
    () => super.formatText(
      index,
      len,
      attribute,
      shouldNotifyListeners: shouldNotifyListeners,
    ),
  );

  @override
  void compose(Delta delta, TextSelection textSelection, ChangeSource source) =>
      runEditCommand(() => super.compose(delta, textSelection, source));

  @override
  Style getSelectionStyle() {
    var selected = super.getSelectionStyle();
    if (selection.isCollapsed && (_hasTypingColor || !_textColorInputEnabled)) {
      selected = selected.put(Attribute.clone(Attribute.color, typingColor));
    }
    if (!selection.isCollapsed) return selected;
    final actual = _actualLineStyle(selection.start);
    if (actual == null) return selected;
    // Quill 空行会沿前文收集样式；行内续写可以继承，块归属必须来自当前行。
    // 工具栏状态、格式切换和回车共用该事实，不再逐种格式修补空状态。
    return Style.attr({
      for (final entry in selected.attributes.entries)
        if (entry.value.scope != AttributeScope.block) entry.key: entry.value,
      for (final entry in actual.attributes.entries)
        if (entry.value.scope == AttributeScope.block) entry.key: entry.value,
    }).mergeAll(
      Style.attr({
        for (final entry in toggledStyle.attributes.entries)
          if (entry.value.scope == AttributeScope.block) entry.key: entry.value,
      }),
    );
  }

  Style? _actualLineStyle(int position) {
    final line = document.queryChild(position).node;
    if (line is! Line) return null;
    final parent = line.parent;
    return parent is Block ? parent.style.mergeAll(line.style) : line.style;
  }

  @override
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    final selectedText = readQuillDocumentRange(
      document,
      index,
      len,
      includeTerminalNewline: true,
    );
    if (selectedText == null) return;
    runEditCommand(
      () => _replaceLiteralText(
        index,
        len,
        data,
        textSelection,
        selectedText: selectedText,
        ignoreFocus: ignoreFocus,
        shouldNotifyListeners: shouldNotifyListeners,
      ),
    );
  }

  void _replaceLiteralText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    required String selectedText,
    required bool ignoreFocus,
    required bool shouldNotifyListeners,
  }) {
    final before = document.toDelta();
    if (data is String) _restoreTypingColor();
    // 外来 Delta 已携带完整颜色事实。Quill 的非 String 补样式只作用
    // 第一个字符，不能让待输入色污染富文本／已校验的粘贴候选。
    if (data is Delta) toggledStyle = toggledStyle.removeAll({Attribute.color});
    final preservesLink =
        toggledStyle.attributes[Attribute.link.key]?.value != null ||
        document.collectStyle(index, 0).attributes[Attribute.link.key]?.value !=
            null;
    if (data == ' ' && len == 0 && index > 0) {
      final left = document.collectStyle(index - 1, 1).attributes;
      final right = document.collectStyle(index, 1).attributes;
      for (final entry in left.entries) {
        if (entry.value.isInline &&
            entry.value.value != right[entry.key]?.value &&
            !toggledStyle.attributes.containsKey(entry.key)) {
          toggledStyle = toggledStyle.put(Attribute.clone(entry.value, null));
        }
      }
    }
    final inputColor = typingColor;
    final internalReference = data is String
        ? WenyouEditorClipboardPastePlanner.internalReferenceDelta(
            data,
            selectedText,
          )
        : null;
    final newline = _plainNewline(data, index);
    final effectiveData = internalReference ?? newline ?? data;
    final continuationStyle = newline != null && keepStyleOnNewLine
        ? Style.attr(
            Map.fromEntries(
              getSelectionStyle().attributes.entries.where(
                (entry) =>
                    entry.value.isInline && entry.key != Attribute.link.key,
              ),
            ),
          )
        : null;
    final effectiveSelection = internalReference == null
        ? textSelection
        : TextSelection.collapsed(offset: index + 1);
    final multilineStyle =
        effectiveData is String &&
            effectiveData.length > 1 &&
            effectiveData.contains('\n')
        ? Style.attr(
            Map.fromEntries(
              {
                ...getSelectionStyle().attributes,
                // 显式关闭也必须覆盖从当前位置收集的样式。
                ...toggledStyle.attributes,
              }.entries.where((entry) => entry.value.isInline),
            ),
          )
        : const Style();
    // Quill 会把待输入色保留到整个 String（包括换行）。文字颜色由下方
    // 非换行范围统一应用；含 LF 的多字符输入也逐文字段应用其他行内格式，
    // 单个回车继续使用原有块规则。事务结束再恢复临时输入色。
    toggledStyle = toggledStyle.removeAll({
      Attribute.color,
      ...multilineStyle.values,
    });
    if (_containsEmbed(effectiveData)) {
      // Quill applies pending inline toolbar styles to every replacement,
      // including embeds. Protocol nodes must remain attribute-free so the
      // Markdown codec can persist them without weakening its fail-closed
      // validation.
      toggledStyle = const Style();
    }
    super.replaceText(
      index,
      len,
      effectiveData,
      effectiveSelection,
      ignoreFocus: ignoreFocus,
      shouldNotifyListeners: shouldNotifyListeners,
    );
    final insertedLength = switch (effectiveData) {
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
      insertedDelta: effectiveData is Delta ? effectiveData : null,
    );
    if (sourceSeparatorPatch.isNotEmpty) {
      document.compose(sourceSeparatorPatch, ChangeSource.local);
    }
    if (newline != null && effectiveSelection != null) {
      // 显式换行 Delta 不经过插入规则，不应再次使用 Quill 的位置补偿。
      updateSelection(effectiveSelection, ChangeSource.local);
    }
    if (effectiveData is Delta &&
        effectiveData.operations.any(
          (operation) =>
              operation.attributes?[MarkdownDeltaLineMetadata
                  .sourceSeparatorAttribute] ==
              true,
        )) {
      final current = document.toDelta();
      final patch = current.diff(MarkdownParagraphBoundaries.collapse(current));
      if (patch.isNotEmpty) {
        // Delta 替换已包含准确插入长度，使用调用方的插入终点，避免
        // Quill 再把整个片段当成一个 embed 计算位置偏移。
        final intended = effectiveSelection ?? selection;
        final adjusted = intended.copyWith(
          baseOffset: patch.transformPosition(intended.baseOffset),
          extentOffset: patch.transformPosition(intended.extentOffset),
        );
        document.compose(patch, ChangeSource.local);
        updateSelection(adjusted, ChangeSource.local);
      }
    }
    if (effectiveData is Delta &&
        effectiveData.operations.length == 1 &&
        effectiveData.operations.single.attributes?[MarkdownParagraphBoundaries
                .key] ==
            1) {
      if (MarkdownParagraphBoundaries.range(before, index)?.start == index) {
        _resetNewParagraphAlignment(index);
      }
      _resetNewParagraphAlignment(index + insertedLength);
    }
    repairEditorTrailingNewlineAlignment(
      controller: this,
      before: before,
      insertedData: effectiveData,
      replacedLength: len,
      selection: effectiveSelection,
    );
    if (continuationStyle != null) toggledStyle = continuationStyle;
    if (effectiveData is! String || effectiveData.isEmpty) return;

    final formatting = Delta();
    var formattingOffset = 0;
    var sourceOffset = 0;
    while (sourceOffset < effectiveData.length) {
      final newline = effectiveData.indexOf('\n', sourceOffset);
      final end = newline < 0 ? effectiveData.length : newline;
      if (end > sourceOffset) {
        final start = index + sourceOffset;
        if (start > formattingOffset) {
          formatting.retain(start - formattingOffset);
        }
        formatting.retain(end - sourceOffset, {
          ...?multilineStyle.toJson(),
          MarkdownDeltaCodec.literalTextAttribute: true,
          Attribute.color.key: inputColor,
          // Quill 续写只继承公开 link 属性；仅明确位于同一原链接的
          // String 输入补回来源，外来 Delta 与相邻独立链接不能猜测合并。
          markdownLinkIdentityKey: preservesLink
              ? _continuedLinkIdentity(
                  before,
                  index,
                  len,
                  document
                      .collectStyle(start, end - sourceOffset)
                      .attributes[Attribute.link.key]
                      ?.value,
                )
              : null,
          // Literal typing must not acquire Quill's automatically detected
          // links. Existing links and explicitly enabled input marks survive.
          if (!preservesLink) Attribute.link.key: null,
        });
        formattingOffset = start + end - sourceOffset;
      }
      if (newline < 0) break;
      sourceOffset = newline + 1;
    }
    if (formatting.isNotEmpty) {
      document.compose(formatting, ChangeSource.local);
    }
    toggledStyle = Style.attr({
      ...toggledStyle.attributes,
      ...multilineStyle.attributes,
    });
  }

  static Object? _continuedLinkIdentity(
    Delta before,
    int index,
    int length,
    Object? insertedUrl,
  ) {
    if (insertedUrl is! String) return null;
    (String, Object?)? sourceAt(int position) {
      var offset = 0;
      for (final operation in before.operations) {
        final end = offset + operation.length!;
        if (position >= offset && position < end) {
          final text = operation.data;
          final url = operation.attributes?[Attribute.link.key];
          if (text is! String ||
              text[position - offset] == '\n' ||
              url is! String) {
            return null;
          }
          return (url, operation.attributes?[markdownLinkIdentityKey]);
        }
        offset = end;
      }
      return null;
    }

    if (length == 0) {
      final left = sourceAt(index - 1);
      final right = sourceAt(index);
      final matching = [
        if (left?.$1 == insertedUrl) left!,
        if (right?.$1 == insertedUrl) right!,
      ];
      if (matching.isEmpty || matching.any((item) => item != matching.first)) {
        return null;
      }
      return matching.first.$2;
    }
    // 替换只继承完全落在同一原链接内的选区；跨链接或混合正文时保留
    // 新输入自己的边界，不能借一个端点覆盖另一段来源。
    final source = sourceAt(index);
    if (source?.$1 != insertedUrl || source?.$2 == null) return null;
    var offset = 0;
    for (final operation in before.operations) {
      final end = offset + operation.length!;
      if (end > index && offset < index + length) {
        final start = index > offset ? index : offset;
        final stop = index + length < end ? index + length : end;
        if ((
                  operation.attributes?[Attribute.link.key],
                  operation.attributes?[markdownLinkIdentityKey],
                ) !=
                source ||
            operation.data is! String ||
            (operation.data as String)
                .substring(start - offset, stop - offset)
                .contains('\n')) {
          return null;
        }
      }
      offset = end;
      if (offset >= index + length) break;
    }
    return source!.$2;
  }

  static bool _containsEmbed(Object? data) => switch (data) {
    Embeddable() => true,
    Delta value => value.operations.any(
      (operation) => operation.isInsert && operation.data is Map,
    ),
    _ => false,
  };

  Object? _plainNewline(Object? data, int index) {
    if (data != '\n') return null;
    final attributes =
        (_actualLineStyle(index) ?? document.collectStyle(index, 0)).attributes;
    if (attributes.containsKey('header') ||
        attributes.containsKey('list') ||
        attributes.containsKey('code-block') ||
        attributes.containsKey('indent')) {
      return null;
    }
    // Quill's string insertion exits an empty quote/aligned line without
    // inserting anything. An explicit Delta keeps the user's Enter literal.
    final startsParagraph =
        attributes['blockquote']?.value != true &&
        !HardwareKeyboard.instance.isShiftPressed;
    final range = MarkdownParagraphBoundaries.range(document.toDelta(), index);
    return Delta()..insert('\n', {
      if (attributes['blockquote']?.value == true) 'blockquote': true,
      if (startsParagraph) MarkdownParagraphBoundaries.key: 1,
      if ((!startsParagraph || range?.start != index) &&
          attributes['align']?.value != null)
        'align': attributes['align']!.value,
    });
  }

  void _resetNewParagraphAlignment(int position) {
    final delta = document.toDelta();
    final range = MarkdownParagraphBoundaries.range(delta, position);
    if (range == null) return;
    final patch = Delta();
    var offset = 0;
    var patched = 0;
    for (final operation in delta.operations) {
      if (operation.data case final String text) {
        for (var index = 0; index < text.length; index++) {
          final at = offset + index;
          if (text[index] == '\n' &&
              at >= range.start &&
              at < range.end &&
              operation.attributes?['align'] != null) {
            if (at > patched) patch.retain(at - patched);
            patch.retain(1, {'align': null});
            patched = at + 1;
          }
        }
      }
      offset += operation.length!;
    }
    if (patch.isNotEmpty) document.compose(patch, ChangeSource.local);
  }
}

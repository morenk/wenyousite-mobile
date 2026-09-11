import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_canonical_literal_decoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_block_encoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_block_validator.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_encoding_buffer.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_extension_nodes.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_inline_encoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_rich_lines.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_semantics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editable_block_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_quote_paragraphs.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

export 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

/// Markdown v4/v5 扩展节点与 Quill Delta 之间的无损协议层。
///
/// 受支持的普通 Markdown 先解析为中立富文本行模型，再映射为 Quill 属性；
/// 扩展节点提升为原子 embed；无法精确往返的语法保留源码文本。
class MarkdownDeltaCodec {
  MarkdownDeltaCodec._();

  static const mentionEmbed = 'wenyou_mention';
  static const diceEmbed = MarkdownDiceContract.embedType;
  static const stickerEmbed = 'wenyou_sticker';
  static const imageEmbed = 'wenyou_image';
  static const internalReferenceEmbed =
      MarkdownDeltaRichLines.internalReferenceEmbed;
  static const compatibilityEmbed = 'wenyou_compatibility';
  static const horizontalRuleEmbed = 'wenyou_horizontal_rule';

  static const emptyParagraphAttribute = MarkdownDeltaLineMetadata.emptyKey;
  static const sourceBreakAttribute = MarkdownDeltaLineMetadata.sourceBreakKey;
  static const literalLineAttribute = MarkdownDeltaLineMetadata.literalLineKey;
  static const literalTextAttribute =
      MarkdownDeltaBlockEncoder.literalTextAttribute;
  static const alignmentAttribute = 'align';

  static const _allPlayersLabel = '@全体玩家';
  static const _stickerPrefix = 'wenyousite-sticker:v1:';

  static final _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  static final _closingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})[\t ]*$');
  static final _emptyParagraph = RegExp(
    r'^ {0,3}<br\s*/?>[\t ]*$',
    caseSensitive: false,
  );
  static final _mention = RegExp(
    r'^\[(@[^\]\r\n]{1,32})\]\(/users/([a-zA-Z0-9_-]+)\)',
  );
  static final _dice = MarkdownDiceContract.nodeAtStart;
  static final _image = RegExp(
    r'''^!\[([^\]\n]*)\]\(\s*([^\s)]+)(?:\s+["']([^"'\n]*)["'])?\s*\)''',
  );
  static final _internalReferenceMarkdown = RegExp(
    r'^\[([^\]\r\n]+)\]\(([^)\r\n]+)\)',
  );
  static final _stickerAssetId = RegExp(r'^c[a-z0-9]{20,}$');
  static final _mentionWord = RegExp(r'[a-zA-Z0-9_\u4e00-\u9fff]');

  static MarkdownDeltaDocument decode(
    String markdown, {
    bool imageAlignment = false,
  }) => _decode(markdown, false, imageAlignment);
  static MarkdownDeltaDocument decodeReaderClipboard(
    String markdown, {
    bool imageAlignment = false,
  }) => _decode(markdown, true, imageAlignment);

  static MarkdownDeltaDocument _decode(
    String markdown,
    bool readerClipboard,
    bool imageAlignment,
  ) {
    final editorDocument = MarkdownEditorDocument.parse(
      markdown,
      imageAlignment: imageAlignment,
    );
    final source = editorDocument.toMarkdown();
    final delta = Delta();
    final issues = <MarkdownCodecIssue>[];
    final diceNodeIds = <String>{};
    final lines = source.split('\n');
    final literalLines = MarkdownContent.unsupportedLineIndexes(
      source,
      imageAlignment: imageAlignment,
    );
    final alignmentAnalysis = MarkdownAlignmentContract.analyzeLines(
      lines,
      imageAlignment: imageAlignment,
    );
    final validAlignmentMarkers = alignmentAnalysis.validMarkerLines;
    _Fence? fence;

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      if (validAlignmentMarkers.contains(lineIndex)) continue;
      if (line.isEmpty &&
          lineIndex > 0 &&
          lineIndex + 1 < lines.length &&
          !literalLines.contains(lineIndex + 1) &&
          MarkdownEditableBlockSyntax.listItem(lines[lineIndex + 1])?.content ==
              '') {
        // 写出器为避免空列表改变前一块语义所加的源码分隔。
        continue;
      }
      final multilineEnd =
          alignmentAnalysis.protection.multilineCodeRanges[lineIndex];
      if (multilineEnd != null && !literalLines.contains(lineIndex)) {
        final rich = MarkdownRichLineDecoder.decode(
          alignmentAnalysis.protection.multilineCodeSources[lineIndex]!,
        );
        if (rich != null) {
          MarkdownDeltaRichLines.append(rich, delta);
          final direction = alignmentAnalysis.alignmentForLine(lineIndex);
          delta.insert('\n', {
            ...rich.lineAttributes,
            if (direction != WenyouTextAlignment.left)
              alignmentAttribute: direction.name,
            if (multilineEnd == lines.length - 1) sourceBreakAttribute: false,
            if (validAlignmentMarkers.contains(multilineEnd + 1))
              MarkdownParagraphBoundaries.key: 1,
          });
          lineIndex = multilineEnd;
          continue;
        }
      }
      final opening = _openingFence.firstMatch(line)?.group(1);
      var isProtocolEmptyParagraph = false;
      Map<String, dynamic>? richLineAttributes;
      if (literalLines.contains(lineIndex)) {
        delta.insert(line);
        richLineAttributes = const {literalLineAttribute: true};
      } else if (fence != null) {
        delta.insert(line);
        final closing = _closingFence.firstMatch(line)?.group(1);
        if (closing != null &&
            closing[0] == fence.marker &&
            closing.length >= fence.length) {
          fence = null;
        }
      } else if (opening != null) {
        fence = _Fence(opening[0], opening.length);
        delta.insert(line);
      } else if (MarkdownContent.isQuotedEmptyParagraphLine(line)) {
        richLineAttributes = const {'blockquote': true};
        isProtocolEmptyParagraph = true;
      } else if (MarkdownContent.isEmptyQuoteLine(line)) {
        // Keep paragraph separators inside the quote, so Quill groups both
        // sides into one block instead of displaying a literal marker.
        richLineAttributes = const {'blockquote': true};
      } else if (_emptyParagraph.hasMatch(line)) {
        // 独占 <br /> 是协议空段，不进入可编辑文本。
        isProtocolEmptyParagraph = true;
      } else if (MarkdownRichLineDecoder.isReaderThematicBreak(line)) {
        delta.insert({
          horizontalRuleEmbed: const {'version': 1},
        });
      } else if (MarkdownContent.hasCanonicalLiteralEncoding(line)) {
        richLineAttributes = _decodeInlineLine(
          line,
          delta,
          issues,
          diceNodeIds,
        );
      } else {
        final richSource = readerClipboard
            ? MarkdownRichLineDecoder.canonicalizeReaderBlockPrefix(line)
            : line;
        final richLine =
            _tryDecodeRichLine(richSource) ??
            (readerClipboard
                ? MarkdownRichLineDecoder.decodeEditable(richSource)
                : null);
        if (richLine == null) {
          richLineAttributes = _decodeInlineLine(
            line,
            delta,
            issues,
            diceNodeIds,
          );
        } else {
          MarkdownDeltaRichLines.append(richLine, delta);
          richLineAttributes = richLine.lineAttributes;
        }
      }

      final isLastLine = lineIndex == lines.length - 1;
      final attributes = <String, dynamic>{
        ...?richLineAttributes,
        if (MarkdownContent.hasWhitespaceGuards(line))
          MarkdownDeltaLineMetadata.guardedWhitespaceKey: true,
        // marker 是独立段落边界；即使源码没有空行，也不能把前段和目标段合并。
        if (validAlignmentMarkers.contains(lineIndex + 1) &&
            line.isNotEmpty &&
            richLineAttributes?['header'] == null &&
            richLineAttributes?['list'] == null &&
            richLineAttributes?['blockquote'] != true)
          MarkdownParagraphBoundaries.key: 1,
        if (alignmentAnalysis.alignmentForLine(lineIndex) case final alignment
            when alignment != WenyouTextAlignment.left)
          alignmentAttribute: alignment.name,
        if (isProtocolEmptyParagraph) emptyParagraphAttribute: true,
        if ((line.isEmpty && lines.length > 1) ||
            MarkdownContent.isEmptyQuoteLine(line))
          MarkdownDeltaLineMetadata.sourceSeparatorAttribute: true,
        if (isLastLine) sourceBreakAttribute: false,
      };
      delta.insert('\n', attributes.isEmpty ? null : attributes);
    }

    return MarkdownDeltaDocument(
      delta: MarkdownParagraphBoundaries.collapse(
        MarkdownQuoteParagraphs.collapse(delta),
      ),
      editorDocument: editorDocument,
      issues: List.unmodifiable(issues),
    );
  }

  static String encode(Delta delta, {bool imageAlignment = false}) {
    final encoded = _encode(delta, true, imageAlignment);
    final reopened = _decode(encoded, false, imageAlignment).delta;
    if (!MarkdownDeltaSemantics.equivalent(delta, reopened)) {
      throw const MarkdownCodecException('正文无法安全保存，请撤销最近的格式操作');
    }
    MarkdownDeltaBlockValidator.validateEmptyListReading(delta, encoded);
    return encoded;
  }

  static String _encode(
    Delta delta,
    bool sanitizeUnsupported, [
    bool imageAlignment = false,
  ]) {
    if (delta.operations.any((operation) => !operation.isInsert)) {
      throw const MarkdownCodecException('文档 Delta 只能包含 insert 操作');
    }
    delta = MarkdownDeltaLineMetadata.prepareForEncoding(delta);
    MarkdownDeltaBlockValidator.validate(
      delta,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    final encodingBuffer = MarkdownDeltaEncodingBuffer(
      imageAlignment: imageAlignment,
    );
    final line = StringBuffer();
    final inline = MarkdownDeltaInlineEncoder(line);
    var lineHasLiteralText = false;
    for (final operation in delta.operations) {
      if (!operation.isInsert) {
        throw const MarkdownCodecException('文档 Delta 只能包含 insert 操作');
      }
      final data = operation.data;
      if (data is String) {
        lineHasLiteralText = _encodeText(
          data,
          operation.attributes,
          line,
          inline,
          encodingBuffer,
          lineHasLiteralText: lineHasLiteralText,
        );
        continue;
      }
      if (data is! Map) {
        throw const MarkdownCodecException('遇到无法识别的 Quill embed');
      }
      if (operation.attributes?.isNotEmpty ?? false) {
        throw const MarkdownCodecException('扩展节点不能携带富文本属性');
      }
      inline.flush();
      _encodeEmbed(Map<String, dynamic>.from(data), line);
    }
    inline.flush();
    if (line.isNotEmpty) encodingBuffer.output.write(line);
    final encoded = sanitizeUnsupported
        ? MarkdownContent.literalizeUnsupported(
            encodingBuffer.output.toString(),
            imageAlignment: imageAlignment,
          )
        : MarkdownContent.normalize(encodingBuffer.output.toString());
    final document = MarkdownEditorDocument.parsePrepared(
      encoded,
      imageAlignment: imageAlignment,
    );
    final serialized = document.toMarkdown();
    final reparsed = MarkdownEditorDocument.parsePrepared(
      serialized,
      imageAlignment: imageAlignment,
    );
    if (!document.structurallyEquivalentTo(reparsed)) {
      throw const MarkdownCodecException('正文块结构无法安全保存，请撤销最近的格式操作');
    }
    return serialized;
  }

  static List<Map<String, Object?>> extractExtensionNodes(Delta delta) {
    return MarkdownDeltaExtensionNodes.extract(
      delta,
      mentionEmbed: mentionEmbed,
      diceEmbed: diceEmbed,
      stickerEmbed: stickerEmbed,
      imageEmbed: imageEmbed,
      allPlayersLabel: _allPlayersLabel,
    );
  }

  static Map<String, dynamic>? _decodeInlineLine(
    String line,
    Delta delta,
    List<MarkdownCodecIssue> issues,
    Set<String> diceNodeIds,
  ) {
    final text = StringBuffer();
    final lineStart = delta.length;
    Map<String, dynamic>? lineAttributes;

    void flushText() {
      if (text.isEmpty) return;
      final source = text.toString();
      final isFirst = delta.length == lineStart;
      final hasLiteral = MarkdownContent.hasCanonicalLiteralEncoding(source);
      final literal = hasLiteral ? _decodeCanonicalLiteral(source) : null;
      final rich = !hasLiteral
          ? _tryDecodeRichLine(source, protocolTextOnly: true)
          : null;
      final attributes = literal?.lineAttributes ?? rich?.lineAttributes;
      if (attributes?.isNotEmpty == true && delta.length != lineStart) {
        delta.insert(source);
      } else if (literal != null) {
        for (final operation in literal.delta.operations) {
          delta.insert(operation.data, operation.attributes);
        }
        if (isFirst) lineAttributes = attributes;
      } else if (rich != null) {
        MarkdownDeltaRichLines.append(rich, delta);
        if (isFirst) lineAttributes = attributes;
      } else if (MarkdownContent.decodeLiteralSpans(source) case final spans?) {
        for (final span in spans) {
          delta.insert(
            span.text,
            span.literal ? const {literalTextAttribute: true} : null,
          );
        }
      } else {
        delta.insert(source);
      }
      text.clear();
    }

    var index = 0;
    while (index < line.length) {
      if (line[index] == r'\') {
        final end = index + 2 <= line.length ? index + 2 : line.length;
        text.write(line.substring(index, end));
        index = end;
        continue;
      }

      if (line[index] == '`') {
        var runLength = 1;
        while (index + runLength < line.length &&
            line[index + runLength] == '`') {
          runLength += 1;
        }
        final delimiter = '`' * runLength;
        final closing = line.indexOf(delimiter, index + runLength);
        if (closing >= 0) {
          final end = closing + runLength;
          text.write(line.substring(index, end));
          index = end;
          continue;
        }
      }

      final remaining = line.substring(index);
      final mention = _mention.firstMatch(remaining);
      if (mention != null) {
        flushText();
        final raw = mention.group(0)!;
        delta.insert({
          mentionEmbed: {
            'version': 1,
            'kind': 'user',
            'userId': mention.group(2)!,
            'label': mention.group(1)!,
          },
        });
        index += raw.length;
        continue;
      }

      final portalMatch = _internalReferenceMarkdown.firstMatch(remaining);
      if (portalMatch != null) {
        final reference = parseInternalReference(portalMatch.group(2)!);
        if (reference != null) {
          flushText();
          delta.insert({
            internalReferenceEmbed: {
              'version': 1,
              'label': portalMatch.group(1)!,
              'location': reference.location.toString(),
            },
          });
          index += portalMatch.group(0)!.length;
          continue;
        }
      }

      if (_isAllPlayersAt(line, index)) {
        flushText();
        delta.insert({
          mentionEmbed: const {
            'version': 1,
            'kind': 'all_players',
            'label': _allPlayersLabel,
          },
        });
        index += _allPlayersLabel.length;
        continue;
      }

      final dice = _dice.firstMatch(remaining);
      if (dice != null) {
        final raw = dice.group(0)!;
        final nodeId = dice.group(1)!.toLowerCase();
        final notation = MarkdownDiceContract.normalizeNotation(dice.group(2)!);
        if (notation == null) {
          flushText();
          _insertCompatibility(
            delta,
            issues,
            MarkdownCodecIssueKind.invalidDice,
            raw,
            '骰子表达式不符合 NdM±K 约束',
          );
        } else if (!diceNodeIds.add(nodeId)) {
          flushText();
          _insertCompatibility(
            delta,
            issues,
            MarkdownCodecIssueKind.duplicateDice,
            raw,
            '同一正文中不能重复使用骰子节点 ID',
          );
        } else {
          flushText();
          delta.insert({
            diceEmbed: {'version': 1, 'nodeId': nodeId, 'notation': notation},
          });
        }
        index += raw.length;
        continue;
      }

      if (remaining.toLowerCase().startsWith('[[dice:')) {
        final end = remaining.indexOf(']]');
        if (end >= 0) {
          flushText();
          final raw = remaining.substring(0, end + 2);
          _insertCompatibility(
            delta,
            issues,
            remaining.toLowerCase().startsWith('[[dice:v1:')
                ? MarkdownCodecIssueKind.invalidDice
                : MarkdownCodecIssueKind.unknownProtocol,
            raw,
            '这个骰子内容暂时无法编辑',
          );
          index += raw.length;
          continue;
        }
      }

      final image = _image.firstMatch(remaining);
      if (image != null) {
        flushText();
        final raw = image.group(0)!;
        final url = _unwrapAngleUrl(image.group(2)!);
        final alt = image.group(1)!;
        final title = image.group(3);
        final uri = Uri.tryParse(url);
        if (uri == null ||
            !uri.hasScheme ||
            !MarkdownContent.isSafeImage(uri)) {
          _insertCompatibility(
            delta,
            issues,
            MarkdownCodecIssueKind.unsafeImage,
            raw,
            '图片 URL 不是安全的 HTTP(S) 地址',
          );
        } else if (title?.startsWith(_stickerPrefix) ?? false) {
          final assetId = title!.substring(_stickerPrefix.length);
          if (!_stickerAssetId.hasMatch(assetId)) {
            _insertCompatibility(
              delta,
              issues,
              MarkdownCodecIssueKind.invalidSticker,
              raw,
              '这个表情内容暂时无法编辑',
            );
          } else {
            delta.insert({
              stickerEmbed: {
                'version': 1,
                'assetId': assetId,
                'url': url,
                'alt': alt,
              },
            });
          }
        } else if (title?.contains('wenyousite-sticker:') ?? false) {
          _insertCompatibility(
            delta,
            issues,
            MarkdownCodecIssueKind.unknownProtocol,
            raw,
            '这个表情内容暂时无法编辑',
          );
        } else {
          delta.insert({
            imageEmbed: {'version': 1, 'url': url, 'alt': alt, 'title': title},
          });
        }
        index += raw.length;
        continue;
      }

      text.write(line[index]);
      index += 1;
    }
    flushText();
    return lineAttributes;
  }

  static MarkdownCanonicalLiteralDecodeResult? _decodeCanonicalLiteral(
    String source,
  ) => MarkdownCanonicalLiteralDecoder.decode(
    source,
    literalTextAttribute: literalTextAttribute,
    internalReferenceEmbed: internalReferenceEmbed,
    sourceBreakAttribute: sourceBreakAttribute,
    preservesSource: (candidate) {
      try {
        final encoded = _encode(candidate, false);
        if (encoded == source) return true;
        final original = MarkdownRichLineDecoder.decode(source);
        final canonical = MarkdownRichLineDecoder.decode(encoded);
        return original != null &&
            canonical != null &&
            original.semanticallyEquivalentTo(canonical);
      } on MarkdownCodecException {
        return false;
      }
    },
  );

  static MarkdownRichLine? _tryDecodeRichLine(
    String source, {
    bool protocolTextOnly = false,
  }) => MarkdownDeltaRichLines.decode(
    source,
    protocolTextOnly: protocolTextOnly,
    encode: (delta) => _encode(delta, false),
  );
  static bool _encodeText(
    String value,
    Map<String, dynamic>? attributes,
    StringBuffer line,
    MarkdownDeltaInlineEncoder inline,
    MarkdownDeltaEncodingBuffer encodingBuffer, {
    required bool lineHasLiteralText,
  }) {
    var start = 0;
    for (var index = 0; index <= value.length; index++) {
      final isLineBreak = index < value.length && value[index] == '\n';
      if (!isLineBreak && index != value.length) continue;
      if (index > start) {
        if (attributes != null) {
          MarkdownDeltaBlockEncoder.validateTextAttributes(attributes);
        }
        inline.add(value.substring(start, index), attributes);
        lineHasLiteralText =
            lineHasLiteralText || attributes?[literalTextAttribute] == true;
      }
      if (!isLineBreak) break;
      inline.flush();
      final encodedLine = MarkdownDeltaBlockEncoder.encode(
        line.toString(),
        attributes,
        containsLiteralText: lineHasLiteralText,
      );
      encodingBuffer.writeLine(
        encodedLine,
        attributes,
        sourceBreakAttribute: sourceBreakAttribute,
        literalLineAttribute: literalLineAttribute,
        emptyParagraphAttribute: emptyParagraphAttribute,
      );
      line.clear();
      lineHasLiteralText = false;
      start = index + 1;
    }
    return lineHasLiteralText;
  }

  static void _encodeEmbed(Map<String, dynamic> embed, StringBuffer output) {
    if (embed.length != 1) {
      throw const MarkdownCodecException('Quill embed 必须只有一个类型键');
    }
    final type = embed.keys.single;
    final payload = _payload(embed[type], type);
    if (payload['version'] != 1) {
      throw MarkdownCodecException('这类$type内容暂时无法编辑');
    }
    switch (type) {
      case mentionEmbed:
        final kind = _requiredString(payload, 'kind', type);
        if (kind == 'all_players') {
          output.write(_allPlayersLabel);
          return;
        }
        if (kind != 'user') {
          throw const MarkdownCodecException('提及节点 kind 不受支持');
        }
        final label = _markdownLabel(
          _requiredString(payload, 'label', type),
          type,
        );
        final userId = _stableId(
          _requiredString(payload, 'userId', type),
          type,
        );
        output.write('[$label](/users/$userId)');
      case diceEmbed:
        final nodeId = _requiredString(payload, 'nodeId', type).toLowerCase();
        if (!MarkdownDiceContract.uuidV4.hasMatch(nodeId)) {
          throw const MarkdownCodecException('骰子节点缺少有效 UUID v4');
        }
        final notation = MarkdownDiceContract.normalizeNotation(
          _requiredString(payload, 'notation', type),
        );
        if (notation == null) {
          throw const MarkdownCodecException('骰子表达式不合法');
        }
        output.write('[[dice:v1:$nodeId:$notation]]');
      case stickerEmbed:
        final assetId = _requiredString(payload, 'assetId', type);
        if (!_stickerAssetId.hasMatch(assetId)) {
          throw const MarkdownCodecException('表情资源 ID 不合法');
        }
        final url = _safeImageUrl(_requiredString(payload, 'url', type), type);
        output.write('![表情]($url "$_stickerPrefix$assetId")');
      case imageEmbed:
        final url = _safeImageUrl(_requiredString(payload, 'url', type), type);
        final rawAlt = payload['alt'];
        if (rawAlt is! String) {
          throw const MarkdownCodecException('图片 alt 类型不合法');
        }
        final alt = _markdownLabel(rawAlt, type, allowAtPrefix: true);
        final title = payload['title'];
        if (title != null && title is! String) {
          throw const MarkdownCodecException('图片 title 类型不合法');
        }
        if (title is String &&
            (title.contains('"') ||
                title.contains('\n') ||
                title.contains('\r'))) {
          throw const MarkdownCodecException('图片说明包含暂不支持的字符');
        }
        output.write('![$alt]($url${title == null ? '' : ' "$title"'})');
      case internalReferenceEmbed:
        final label = _plainMarkdownLabel(
          _requiredString(payload, 'label', type),
          type,
        );
        final rawLocation = _requiredString(payload, 'location', type);
        final reference = parseInternalReference(rawLocation);
        if (reference == null) {
          throw const MarkdownCodecException('站内传送门地址不合法');
        }
        output.write('[$label](${reference.location})');
      case compatibilityEmbed:
        output.write(_requiredString(payload, 'raw', type));
      case horizontalRuleEmbed:
        output.write(MarkdownEditorDocument.horizontalRuleMarker);
      default:
        throw MarkdownCodecException('未知 Quill embed：$type');
    }
  }

  static void _insertCompatibility(
    Delta delta,
    List<MarkdownCodecIssue> issues,
    MarkdownCodecIssueKind kind,
    String raw,
    String message,
  ) {
    delta.insert({
      compatibilityEmbed: {'version': 1, 'raw': raw, 'reason': kind.name},
    });
    issues.add(MarkdownCodecIssue(kind: kind, rawToken: raw, message: message));
  }

  static bool _isAllPlayersAt(String line, int index) {
    if (!line.startsWith(_allPlayersLabel, index)) return false;
    if (index > 0 && _mentionWord.hasMatch(line[index - 1])) return false;
    final end = index + _allPlayersLabel.length;
    return end == line.length || !_mentionWord.hasMatch(line[end]);
  }

  static String? normalizeDiceNotation(String value) =>
      MarkdownDiceContract.normalizeNotation(value);

  static Map<String, dynamic> _payload(Object? value, String type) =>
      value is Map
      ? Map<String, dynamic>.from(value)
      : throw MarkdownCodecException('$type embed 载荷不是对象');

  static String _requiredString(
    Map<String, dynamic> payload,
    String key,
    String type,
  ) {
    final value = payload[key];
    if (value is! String || value.isEmpty) {
      throw MarkdownCodecException('$type embed 缺少 $key');
    }
    return value;
  }

  static String _markdownLabel(
    String value,
    String type, {
    bool allowAtPrefix = false,
  }) {
    if (value.contains(']') || value.contains('\n') || value.contains('\r')) {
      throw MarkdownCodecException('这类$type内容包含暂不支持的字符');
    }
    if (!allowAtPrefix && !value.startsWith('@')) {
      throw MarkdownCodecException('$type embed 提及标签必须以 @ 开头');
    }
    return value;
  }

  static String _plainMarkdownLabel(String value, String type) =>
      _markdownLabel(value, type, allowAtPrefix: true);

  static String _stableId(String value, String type) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      throw MarkdownCodecException('$type embed 稳定 ID 不合法');
    }
    return value;
  }

  static String _safeImageUrl(String value, String type) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !MarkdownContent.isSafeImage(uri) ||
        RegExp(r'[\s)]').hasMatch(value)) {
      throw MarkdownCodecException('$type embed 图片 URL 不安全');
    }
    return value;
  }

  static String _unwrapAngleUrl(String value) =>
      value.startsWith('<') && value.endsWith('>')
      ? value.substring(1, value.length - 1)
      : value;
}

class _Fence {
  const _Fence(this.marker, this.length);

  final String marker;
  final int length;
}

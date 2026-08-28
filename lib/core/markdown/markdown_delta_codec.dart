import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_canonical_literal_decoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_block_validator.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

export 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

/// Markdown v3 扩展节点与 Quill Delta 之间的无损协议层。
///
/// 受支持的普通 Markdown 先解析为中立富文本行模型，再映射为 Quill 属性；
/// 需要稳定身份的扩展节点提升为原子 embed。无法证明精确往返的语法继续保留
/// 源码文本，不改变后端、云草稿和本地快照保存完整 Markdown 的边界。
class MarkdownDeltaCodec {
  MarkdownDeltaCodec._();

  static const mentionEmbed = 'wenyou_mention';
  static const diceEmbed = MarkdownDiceContract.embedType;
  static const stickerEmbed = 'wenyou_sticker';
  static const imageEmbed = 'wenyou_image';
  static const internalReferenceEmbed = 'wenyou_internal_reference';
  static const compatibilityEmbed = 'wenyou_compatibility';
  static const horizontalRuleEmbed = 'wenyou_horizontal_rule';

  static const emptyParagraphAttribute = MarkdownDeltaLineMetadata.emptyKey;
  static const sourceBreakAttribute = MarkdownDeltaLineMetadata.sourceBreakKey;
  static const literalLineAttribute = MarkdownDeltaLineMetadata.literalLineKey;
  static const literalTextAttribute = 'wenyou_literal_text';

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

  static MarkdownDeltaDocument decode(String markdown) {
    final editorDocument = MarkdownEditorDocument.parse(markdown);
    final source = editorDocument.toMarkdown();
    final delta = Delta();
    final issues = <MarkdownCodecIssue>[];
    final diceNodeIds = <String>{};
    final lines = source.split('\n');
    final literalLines = MarkdownContent.unsupportedLineIndexes(source);
    _Fence? fence;

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
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
      } else if (_emptyParagraph.hasMatch(line)) {
        // 独占 <br /> 是协议空段，不进入可编辑文本。
        isProtocolEmptyParagraph = true;
      } else if (line == '---') {
        delta.insert({
          horizontalRuleEmbed: const {'version': 1},
        });
      } else if (MarkdownContent.hasCanonicalLiteralEncoding(line)) {
        final decoded = MarkdownCanonicalLiteralDecoder.decode(
          line,
          literalTextAttribute: literalTextAttribute,
          internalReferenceEmbed: internalReferenceEmbed,
          sourceBreakAttribute: sourceBreakAttribute,
          preservesSource: (candidate) {
            try {
              return _encode(candidate, sanitizeUnsupported: false) == line;
            } on MarkdownCodecException {
              return false;
            }
          },
        );
        if (decoded == null) {
          for (final span in MarkdownContent.decodeLiteralSpans(line)!) {
            delta.insert(
              span.text,
              span.literal ? const {literalTextAttribute: true} : null,
            );
          }
        } else {
          for (final operation in decoded.delta.operations) {
            delta.insert(operation.data, operation.attributes);
          }
          richLineAttributes = decoded.lineAttributes;
        }
      } else {
        final richLine = _tryDecodeRichLine(line);
        if (richLine == null) {
          _decodeInlineLine(line, delta, issues, diceNodeIds);
        } else {
          for (final span in richLine.spans) {
            final portal = span.internalReference;
            if (portal == null) {
              delta.insert(span.text, span.attributes);
            } else {
              delta.insert({
                internalReferenceEmbed: {
                  'version': 1,
                  'label': portal.label,
                  'location': portal.reference.location.toString(),
                },
              });
            }
          }
          richLineAttributes = richLine.lineAttributes;
        }
      }

      final isLastLine = lineIndex == lines.length - 1;
      final attributes = <String, dynamic>{
        ...?richLineAttributes,
        if (isProtocolEmptyParagraph) emptyParagraphAttribute: true,
        if (line.isEmpty && lines.length > 1)
          MarkdownDeltaLineMetadata.sourceSeparatorAttribute: true,
        if (isLastLine) sourceBreakAttribute: false,
      };
      delta.insert('\n', attributes.isEmpty ? null : attributes);
    }

    return MarkdownDeltaDocument(
      delta: delta,
      editorDocument: editorDocument,
      issues: List.unmodifiable(issues),
    );
  }

  static String encode(Delta delta) =>
      _encode(delta, sanitizeUnsupported: true);

  static String _encode(Delta delta, {required bool sanitizeUnsupported}) {
    delta = MarkdownDeltaLineMetadata.prepareForEncoding(delta);
    MarkdownDeltaBlockValidator.validate(
      delta,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    final output = StringBuffer();
    final line = StringBuffer();
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
          output,
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
      _encodeEmbed(Map<String, dynamic>.from(data), line);
    }
    if (line.isNotEmpty) output.write(line);
    final encoded = sanitizeUnsupported
        ? MarkdownContent.literalizeUnsupported(output.toString())
        : MarkdownContent.normalize(output.toString());
    final document = MarkdownEditorDocument.parsePrepared(encoded);
    final serialized = document.toMarkdown();
    final reparsed = MarkdownEditorDocument.parsePrepared(serialized);
    if (!document.structurallyEquivalentTo(reparsed)) {
      throw const MarkdownCodecException('正文块结构无法安全保存，请撤销最近的格式操作');
    }
    return serialized;
  }

  static List<Map<String, Object?>> extractExtensionNodes(Delta delta) {
    final nodes = <Map<String, Object?>>[];
    for (final operation in delta.operations) {
      final data = operation.data;
      if (!operation.isInsert || data is! Map || data.length != 1) continue;
      final embed = Map<String, dynamic>.from(data);
      final type = embed.keys.single;
      final payload = _payload(embed[type], type);
      switch (type) {
        case mentionEmbed:
          final kind = payload['kind'];
          if (kind == 'all_players') {
            nodes.add(const {
              'type': 'mention_all_players',
              'label': _allPlayersLabel,
            });
          } else if (kind == 'user') {
            nodes.add({
              'type': 'mention',
              'userId': payload['userId'],
              'label': payload['label'],
            });
          }
        case diceEmbed:
          nodes.add({
            'type': 'dice',
            'nodeId': payload['nodeId'],
            'notation': payload['notation'],
          });
        case stickerEmbed:
          nodes.add({
            'type': 'sticker',
            'assetId': payload['assetId'],
            'url': payload['url'],
            'alt': payload['alt'],
          });
        case imageEmbed:
          nodes.add({
            'type': 'image',
            'url': payload['url'],
            'alt': payload['alt'],
            'title': payload['title'],
          });
      }
    }
    return nodes;
  }

  static void _decodeInlineLine(
    String line,
    Delta delta,
    List<MarkdownCodecIssue> issues,
    Set<String> diceNodeIds,
  ) {
    final text = StringBuffer();

    void flushText() {
      if (text.isEmpty) return;
      delta.insert(text.toString());
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
  }

  static MarkdownRichLine? _tryDecodeRichLine(String source) {
    if (source.contains('](/users/') ||
        source.contains(_allPlayersLabel) ||
        source.toLowerCase().contains('[[dice:') ||
        source.contains('![')) {
      return null;
    }
    final richLine = MarkdownRichLineDecoder.decode(source);
    if (richLine == null) return null;

    final candidate = Delta();
    for (final span in richLine.spans) {
      final portal = span.internalReference;
      if (portal == null) {
        candidate.insert(span.text, span.attributes);
      } else {
        candidate.insert({
          internalReferenceEmbed: {
            'version': 1,
            'label': portal.label,
            'location': portal.reference.location.toString(),
          },
        });
      }
    }
    candidate.insert('\n', {
      ...richLine.lineAttributes,
      sourceBreakAttribute: false,
    });
    try {
      if (_encode(candidate, sanitizeUnsupported: false) !=
          MarkdownInlineBoundary.canonicalize(source)) {
        return null;
      }
    } on MarkdownCodecException {
      return null;
    }
    return richLine;
  }

  static bool _encodeText(
    String value,
    Map<String, dynamic>? attributes,
    StringBuffer line,
    StringBuffer output, {
    required bool lineHasLiteralText,
  }) {
    var start = 0;
    for (var index = 0; index <= value.length; index++) {
      final isLineBreak = index < value.length && value[index] == '\n';
      if (!isLineBreak && index != value.length) continue;
      if (index > start) {
        line.write(
          _encodeInlineText(value.substring(start, index), attributes),
        );
        lineHasLiteralText =
            lineHasLiteralText || attributes?[literalTextAttribute] == true;
      }
      if (!isLineBreak) break;
      final encodedLine = _encodeLine(
        line.toString(),
        attributes,
        containsLiteralText: lineHasLiteralText,
      );
      final isLiteral = attributes?[literalLineAttribute] == true;
      if (isLiteral &&
          output.isNotEmpty &&
          !output.toString().endsWith('\n\n')) {
        output.write('\n');
      }
      output.write(encodedLine);
      line.clear();
      lineHasLiteralText = false;
      if (attributes?[sourceBreakAttribute] != false) {
        output.write(isLiteral ? '\n\n' : '\n');
      }
      start = index + 1;
    }
    return lineHasLiteralText;
  }

  static String _encodeInlineText(
    String value,
    Map<String, dynamic>? attributes,
  ) {
    if (attributes == null || attributes.isEmpty) return value;
    _rejectUnknownAttributes(attributes, const {
      'bold',
      'italic',
      'strike',
      'code',
      'link',
      emptyParagraphAttribute,
      sourceBreakAttribute,
      literalLineAttribute,
      literalTextAttribute,
      'header',
      'list',
      'blockquote',
      'indent',
    });

    final inlineCode = attributes['code'] == true;
    final bold = attributes['bold'] == true;
    final italic = attributes['italic'] == true;
    final strike = attributes['strike'] == true;
    final link = attributes['link'];
    if (inlineCode && (bold || italic || strike || link != null)) {
      throw const MarkdownCodecException('行内代码不能与其他行内格式组合');
    }
    if (inlineCode) return _inlineCode(value);

    var encoded = attributes[literalTextAttribute] == true
        ? MarkdownContent.literalizeInlineText(value)
        : value;
    if (link != null) {
      if (link is! String || link.isEmpty) {
        throw const MarkdownCodecException('链接属性不是有效字符串');
      }
      final uri = Uri.tryParse(link);
      if (uri == null ||
          !uri.hasScheme ||
          !MarkdownContent.isSafeLink(uri) ||
          RegExp(r'[\s)]').hasMatch(link) ||
          value.contains(']')) {
        throw const MarkdownCodecException('这个链接暂时无法安全编辑');
      }
      encoded = '[$encoded]($link)';
    }
    if (strike) encoded = '~~$encoded~~';
    if (italic) encoded = '*$encoded*';
    if (bold) encoded = '**$encoded**';
    return encoded;
  }

  static String _encodeLine(
    String content,
    Map<String, dynamic>? attributes, {
    required bool containsLiteralText,
  }) {
    if (attributes == null || attributes.isEmpty) {
      return containsLiteralText
          ? MarkdownContent.protectUnsafeWhitespace(content)
          : content;
    }
    _rejectUnknownAttributes(attributes, const {
      'bold',
      'italic',
      'strike',
      'code',
      'link',
      emptyParagraphAttribute,
      sourceBreakAttribute,
      literalLineAttribute,
      literalTextAttribute,
      'header',
      'list',
      'blockquote',
      'indent',
    });
    if (attributes[literalLineAttribute] == true) {
      final incompatible = attributes.keys.where(
        (key) => key != literalLineAttribute && key != sourceBreakAttribute,
      );
      if (incompatible.isNotEmpty) {
        throw const MarkdownCodecException('字面源码行不能携带其他富文本属性');
      }
      return MarkdownContent.literalizeLine(content);
    }
    if (attributes[emptyParagraphAttribute] == true) {
      if (content.isNotEmpty) {
        throw const MarkdownCodecException('这段内容暂时无法安全编辑');
      }
      return '<br />';
    }

    final canonicalContent = MarkdownInlineBoundary.canonicalize(content);

    final indentValue = attributes['indent'];
    final indent = switch (indentValue) {
      null => 0,
      int value when value >= 0 && value <= 3 => value,
      _ => throw const MarkdownCodecException('列表缩进只支持 0～3 级'),
    };
    final header = attributes['header'];
    final list = attributes['list'];
    final quote = attributes['blockquote'] == true;
    final blockStyleCount =
        (header == null ? 0 : 1) + (list == null ? 0 : 1) + (quote ? 1 : 0);
    if (blockStyleCount > 1) {
      throw const MarkdownCodecException('同一行不能组合标题、列表和引用');
    }
    final hasUnsafeWhitespace =
        canonicalContent.startsWith('    ') ||
        canonicalContent.startsWith('\t') ||
        RegExp(r' {2,}$').hasMatch(canonicalContent);
    if (hasUnsafeWhitespace && blockStyleCount == 0 && containsLiteralText) {
      return MarkdownContent.protectUnsafeWhitespace(canonicalContent);
    }
    if (header != null) {
      if (header != 2 && header != 3) {
        throw const MarkdownCodecException('编辑器只支持二级与三级标题');
      }
      return '${'#' * (header as int)} $canonicalContent';
    }
    if (list != null) {
      if (list != 'bullet' && list != 'ordered') {
        throw const MarkdownCodecException('编辑器列表类型不受支持');
      }
      final prefix = list == 'ordered' ? '1. ' : '- ';
      return '${'  ' * indent}$prefix$canonicalContent';
    }
    if (quote) return '> $canonicalContent';
    if (indent != 0) {
      throw const MarkdownCodecException('只有列表行可以携带缩进');
    }
    return canonicalContent;
  }

  static String _inlineCode(String value) {
    var longestRun = 0;
    var currentRun = 0;
    for (final rune in value.runes) {
      if (rune == 0x60) {
        currentRun += 1;
        if (currentRun > longestRun) longestRun = currentRun;
      } else {
        currentRun = 0;
      }
    }
    final delimiter = '`' * (longestRun + 1);
    final needsPadding = value.startsWith('`') || value.endsWith('`');
    return '$delimiter${needsPadding ? ' ' : ''}$value${needsPadding ? ' ' : ''}$delimiter';
  }

  static void _rejectUnknownAttributes(
    Map<String, dynamic> attributes,
    Set<String> allowed,
  ) {
    final unknown = attributes.keys.where((key) => !allowed.contains(key));
    if (unknown.isNotEmpty) {
      throw MarkdownCodecException('遇到不支持的富文本属性：${unknown.join(', ')}');
    }
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

  static Map<String, dynamic> _payload(Object? value, String type) {
    if (value is! Map) {
      throw MarkdownCodecException('$type embed 载荷不是对象');
    }
    return Map<String, dynamic>.from(value);
  }

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

  static String _plainMarkdownLabel(String value, String type) {
    if (value.contains(']') || value.contains('\n') || value.contains('\r')) {
      throw MarkdownCodecException('这类$type内容包含暂不支持的字符');
    }
    return value;
  }

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

  static String _unwrapAngleUrl(String value) {
    if (value.startsWith('<') && value.endsWith('>')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}

class _Fence {
  const _Fence(this.marker, this.length);

  final String marker;
  final int length;
}

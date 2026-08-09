import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

enum MarkdownCodecIssueKind {
  unknownProtocol,
  invalidDice,
  duplicateDice,
  invalidSticker,
  unsafeImage,
}

class MarkdownCodecIssue {
  const MarkdownCodecIssue({
    required this.kind,
    required this.rawToken,
    required this.message,
  });

  final MarkdownCodecIssueKind kind;
  final String rawToken;
  final String message;
}

class MarkdownDeltaDocument {
  const MarkdownDeltaDocument({required this.delta, required this.issues});

  final Delta delta;
  final List<MarkdownCodecIssue> issues;

  bool get isSourceCompatible => issues.isNotEmpty;
}

class MarkdownCodecException implements Exception {
  const MarkdownCodecException(this.message);

  final String message;

  @override
  String toString() => 'MarkdownCodecException: $message';
}

/// Markdown v2 扩展节点与 Quill Delta 之间的无损协议层。
///
/// 当前切片把普通 Markdown 保留为可编辑源码文本，只把需要稳定身份的扩展
/// 节点提升为原子 embed。后续富文本属性映射可以复用同一 embed 载荷，不改变
/// 后端、云草稿和本地快照继续保存完整 Markdown 的边界。
class MarkdownDeltaCodec {
  MarkdownDeltaCodec._();

  static const mentionEmbed = 'wenyou_mention';
  static const diceEmbed = 'wenyou_dice';
  static const stickerEmbed = 'wenyou_sticker';
  static const imageEmbed = 'wenyou_image';
  static const compatibilityEmbed = 'wenyou_compatibility';

  static const emptyParagraphAttribute = 'wenyou_empty_paragraph';
  static const sourceBreakAttribute = 'wenyou_source_break';

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
  static final _dice = RegExp(
    r'^\[\[dice:v1:([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}):([^\]\r\n]{1,32})\]\]',
    caseSensitive: false,
  );
  static final _diceNotation = RegExp(
    r'^\s*(?:(\d+)\s*)?[dD]\s*(\d+)(?:\s*([+-])\s*(\d+))?\s*$',
  );
  static final _uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  static final _image = RegExp(
    r'''^!\[([^\]\n]*)\]\(\s*([^\s)]+)(?:\s+["']([^"'\n]*)["'])?\s*\)''',
  );
  static final _stickerAssetId = RegExp(r'^c[a-z0-9]{20,}$');
  static final _mentionWord = RegExp(r'[a-zA-Z0-9_\u4e00-\u9fff]');

  static MarkdownDeltaDocument decode(String markdown) {
    final source = MarkdownContent.normalize(markdown);
    final delta = Delta();
    final issues = <MarkdownCodecIssue>[];
    final diceNodeIds = <String>{};
    final lines = source.split('\n');
    _Fence? fence;

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final opening = _openingFence.firstMatch(line)?.group(1);
      var isProtocolEmptyParagraph = false;
      if (fence != null) {
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
      } else {
        _decodeInlineLine(line, delta, issues, diceNodeIds);
      }

      final isLastLine = lineIndex == lines.length - 1;
      final attributes = <String, dynamic>{
        if (isProtocolEmptyParagraph) emptyParagraphAttribute: true,
        if (isLastLine) sourceBreakAttribute: false,
      };
      delta.insert('\n', attributes.isEmpty ? null : attributes);
    }

    return MarkdownDeltaDocument(
      delta: delta,
      issues: List.unmodifiable(issues),
    );
  }

  static String encode(Delta delta) {
    final output = StringBuffer();
    for (final operation in delta.operations) {
      if (!operation.isInsert) {
        throw const MarkdownCodecException('文档 Delta 只能包含 insert 操作');
      }
      final data = operation.data;
      if (data is String) {
        _encodeText(data, operation.attributes, output);
        continue;
      }
      if (data is! Map) {
        throw const MarkdownCodecException('遇到无法识别的 Quill embed');
      }
      _encodeEmbed(Map<String, dynamic>.from(data), output);
    }
    return MarkdownContent.normalize(output.toString());
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
        final notation = _normalizeDiceNotation(dice.group(2)!);
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
            '无法安全编辑这个骰子协议节点',
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
              '表情资源 ID 不符合协议',
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
            '无法安全编辑这个表情协议版本',
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

  static void _encodeText(
    String value,
    Map<String, dynamic>? attributes,
    StringBuffer output,
  ) {
    for (var index = 0; index < value.length; index++) {
      final character = value[index];
      if (character != '\n') {
        output.write(character);
        continue;
      }
      if (attributes?[emptyParagraphAttribute] == true) {
        output.write('<br />');
      }
      if (attributes?[sourceBreakAttribute] != false) output.write('\n');
    }
  }

  static void _encodeEmbed(Map<String, dynamic> embed, StringBuffer output) {
    if (embed.length != 1) {
      throw const MarkdownCodecException('Quill embed 必须只有一个类型键');
    }
    final type = embed.keys.single;
    final payload = _payload(embed[type], type);
    if (payload['version'] != 1) {
      throw MarkdownCodecException('$type embed 协议版本不受支持');
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
        if (!_isUuidV4(nodeId)) {
          throw const MarkdownCodecException('骰子节点缺少有效 UUID v4');
        }
        final notation = _normalizeDiceNotation(
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
          throw const MarkdownCodecException('图片 title 包含协议不支持的字符');
        }
        output.write('![$alt]($url${title == null ? '' : ' "$title"'})');
      case compatibilityEmbed:
        output.write(_requiredString(payload, 'raw', type));
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

  static String? _normalizeDiceNotation(String value) {
    final match = _diceNotation.firstMatch(value);
    if (match == null) return null;
    final quantity = int.tryParse(match.group(1) ?? '1');
    final sides = int.tryParse(match.group(2)!);
    final magnitude = int.tryParse(match.group(4) ?? '0');
    if (quantity == null ||
        sides == null ||
        magnitude == null ||
        quantity < 1 ||
        quantity > 100 ||
        sides < 2 ||
        sides > 1000 ||
        magnitude > 10000) {
      return null;
    }
    final sign = match.group(3);
    final modifier = magnitude == 0
        ? ''
        : '${sign == '-' ? '-' : '+'}$magnitude';
    return '${quantity}d$sides$modifier';
  }

  static bool _isUuidV4(String value) => _uuidV4.hasMatch(value);

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
      throw MarkdownCodecException('$type embed 标签包含协议不支持的字符');
    }
    if (!allowAtPrefix && !value.startsWith('@')) {
      throw MarkdownCodecException('$type embed 提及标签必须以 @ 开头');
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

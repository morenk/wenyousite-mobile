import 'package:flutter_quill/quill_delta.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// Reconstructs only the allow-listed rich fragment emitted by Wenyou Web.
///
/// The envelope is an interoperability hint rather than proof of origin. Every
/// element and attribute is rebuilt into the mobile Delta model, and the
/// result must survive the Markdown v4 codec before it can reach the editor.
class WenyouSiteClipboardParser {
  const WenyouSiteClipboardParser();

  static const maximumHtmlLength = 1000000;
  static const _versionAttribute = 'data-wenyou-clipboard';
  static const _sourceAttribute = 'data-wenyou-clipboard-source';

  Delta? parse(String? html) {
    if (html == null || html.isEmpty || html.length > maximumHtmlLength) {
      return null;
    }
    try {
      final fragment = html_parser.parseFragment(html);
      final envelopes = fragment.querySelectorAll('[$_versionAttribute]');
      if (envelopes.length != 1) return null;
      final envelope = envelopes.single;
      final source = switch (envelope.attributes[_sourceAttribute]) {
        'reader' => _SiteClipboardSource.reader,
        'editor' => _SiteClipboardSource.editor,
        _ => null,
      };
      final version = int.tryParse(
        envelope.attributes[_versionAttribute] ?? '',
      );
      if ((version != 1 && version != 2) || source == null) {
        return null;
      }
      return _SiteClipboardDeltaBuilder(source, version!).build(envelope);
    } on Object {
      return null;
    }
  }
}

enum _SiteClipboardSource { reader, editor }

class _SiteClipboardDeltaBuilder {
  _SiteClipboardDeltaBuilder(this.source, this.version);

  static const _blockTags = {'blockquote', 'h2', 'h3', 'hr', 'ol', 'p', 'ul'};
  static const _droppedTags = {
    'button',
    'iframe',
    'input',
    'noscript',
    'object',
    'script',
    'select',
    'style',
    'svg',
    'template',
    'textarea',
  };

  final _SiteClipboardSource source;
  final int version;

  Delta? build(dom.Element envelope) {
    if (envelope.nodes.any(_beginsBlock)) {
      final collector = _ClipboardBlockCollector(source, version, _beginsBlock)
        ..appendChildren(envelope.nodes);
      return _canonicalizeBlocks(collector.groups);
    }

    final lines = _ClipboardInlineBuilder(source).build(envelope.nodes);
    if (lines.every(_isVisiblyEmpty)) return null;
    final raw = _assembleGroups([
      _ClipboardBlockGroup(
        lines.map((line) => _ClipboardLine(line)).toList(growable: false),
      ),
    ]);
    if (raw == null) return null;
    final decoded = _canonicalize(raw);
    if (decoded == null) return null;
    final length = MarkdownDeltaLineMetadata.documentLength(decoded);
    return length <= 1 ? null : decoded.slice(0, length - 1);
  }

  Delta? _canonicalizeBlocks(List<_ClipboardBlockGroup> groups) {
    final raw = _assembleGroups(groups);
    return raw == null ? null : _canonicalize(raw);
  }

  Delta? _canonicalize(Delta raw) {
    try {
      MarkdownDeltaCodec.encode(raw);
      return Delta.from(raw);
    } on Object {
      return null;
    }
  }

  Delta? _assembleGroups(List<_ClipboardBlockGroup> groups) {
    final nonEmpty = groups.where((group) => group.lines.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return null;
    final output = Delta();
    for (var groupIndex = 0; groupIndex < nonEmpty.length; groupIndex++) {
      if (groupIndex > 0) {
        output.insert('\n', {
          MarkdownDeltaLineMetadata.sourceSeparatorAttribute: true,
        });
      }
      final group = nonEmpty[groupIndex];
      for (var lineIndex = 0; lineIndex < group.lines.length; lineIndex++) {
        final line = group.lines[lineIndex];
        _appendDelta(output, line.content);
        final isLast =
            groupIndex == nonEmpty.length - 1 &&
            lineIndex == group.lines.length - 1;
        final attributes = <String, dynamic>{
          ...line.attributes,
          if (isLast) MarkdownDeltaCodec.sourceBreakAttribute: false,
        };
        output.insert('\n', attributes.isEmpty ? null : attributes);
      }
    }
    return output;
  }

  bool _beginsBlock(dom.Node node) {
    if (node is! dom.Element) return false;
    final tag = node.localName;
    if (tag == null || _droppedTags.contains(tag)) return false;
    if (_blockTags.contains(tag)) return true;
    if (tag == 'img' &&
        source == _SiteClipboardSource.editor &&
        node.attributes['data-type'] == 'image-block') {
      return true;
    }
    return node.nodes.any(_beginsBlock);
  }
}

class _ClipboardBlockCollector {
  _ClipboardBlockCollector(this.source, this.version, this.beginsBlock);

  final _SiteClipboardSource source;
  final int version;
  final bool Function(dom.Node node) beginsBlock;
  final List<_ClipboardBlockGroup> groups = [];

  void appendChildren(
    Iterable<dom.Node> nodes, {
    bool alignmentEligible = true,
  }) {
    final inline = <dom.Node>[];
    void flushInline() {
      if (inline.isEmpty) return;
      final lines = _ClipboardInlineBuilder(source).build(inline);
      inline.clear();
      if (lines.every(_isVisiblyEmpty)) return;
      _appendInlineGroup(lines);
    }

    for (final node in nodes) {
      if (!beginsBlock(node)) {
        inline.add(node);
        continue;
      }
      flushInline();
      _appendBlock(node as dom.Element, alignmentEligible: alignmentEligible);
    }
    flushInline();
  }

  void _appendBlock(dom.Element element, {required bool alignmentEligible}) {
    final tag = element.localName;
    switch (tag) {
      case 'p':
        final contents = _ClipboardInlineBuilder(source).build(element.nodes);
        _appendInlineGroup(
          contents,
          lineAttributes: _alignmentAttributes(
            element,
            contents,
            alignmentEligible: alignmentEligible,
          ),
          preserveEmpty: true,
        );
      case 'h2':
      case 'h3':
        final level = tag == 'h2' ? 2 : 3;
        final contents = _ClipboardInlineBuilder(source).build(element.nodes);
        _appendInlineGroup(
          contents,
          lineAttributes: {
            'header': level,
            ..._alignmentAttributes(
              element,
              contents,
              alignmentEligible: alignmentEligible,
            ),
          },
          preserveEmpty: true,
        );
      case 'blockquote':
        final lines = <Delta>[];
        final paragraphs = element.children
            .where((child) => child.localName == 'p')
            .toList(growable: false);
        if (paragraphs.isEmpty) {
          lines.addAll(_ClipboardInlineBuilder(source).build(element.nodes));
        } else {
          for (final paragraph in paragraphs) {
            lines.addAll(
              _ClipboardInlineBuilder(source).build(paragraph.nodes),
            );
          }
        }
        _appendInlineGroup(
          lines,
          lineAttributes: const {'blockquote': true},
          preserveEmpty: true,
        );
      case 'ul':
      case 'ol':
        final lines = <_ClipboardLine>[];
        _appendListLines(element, depth: 0, output: lines);
        if (lines.isNotEmpty) groups.add(_ClipboardBlockGroup(lines));
      case 'hr':
        groups.add(
          _ClipboardBlockGroup([
            _ClipboardLine(
              Delta()..insert({
                MarkdownDeltaCodec.horizontalRuleEmbed: const {'version': 1},
              }),
            ),
          ]),
        );
      case 'img'
          when source == _SiteClipboardSource.editor &&
              element.attributes['data-type'] == 'image-block':
        final lines = _ClipboardInlineBuilder(source).build([element]);
        if (lines.any((line) => !_isVisiblyEmpty(line))) {
          _appendInlineGroup(lines);
        }
      default:
        appendChildren(element.nodes, alignmentEligible: false);
    }
  }

  Map<String, dynamic> _alignmentAttributes(
    dom.Element element,
    List<Delta> contents, {
    required bool alignmentEligible,
  }) {
    if (version != 2 ||
        !alignmentEligible ||
        contents.every(_isVisiblyEmpty) ||
        _containsRegularImage(element)) {
      return const {};
    }
    return switch (element.attributes['data-wenyou-align']) {
      'center' => const {MarkdownDeltaCodec.alignmentAttribute: 'center'},
      'right' => const {MarkdownDeltaCodec.alignmentAttribute: 'right'},
      _ => const {},
    };
  }

  static bool _containsRegularImage(dom.Element element) {
    for (final media in element.querySelectorAll(
      'img, [data-wenyou-clipboard-media]',
    )) {
      final isSticker =
          media.attributes['data-wenyou-clipboard-media'] == 'sticker' ||
          media.attributes['data-type'] == 'sticker-inline';
      if (!isSticker) return true;
    }
    return false;
  }

  void _appendListLines(
    dom.Element list, {
    required int depth,
    required List<_ClipboardLine> output,
  }) {
    final ordered = list.localName == 'ol';
    for (final item in list.children.where(
      (child) => child.localName == 'li',
    )) {
      final contentNodes = item.nodes.where(
        (node) =>
            node is! dom.Element ||
            (node.localName != 'ul' && node.localName != 'ol'),
      );
      final contentLines = _ClipboardInlineBuilder(source).build(contentNodes);
      final content = _mergeInlineLines(contentLines);
      if (!_isVisiblyEmpty(content)) {
        output.add(
          _ClipboardLine(content, {
            'list': ordered ? 'ordered' : 'bullet',
            if (depth > 0) 'indent': depth.clamp(0, 3),
          }),
        );
      }
      for (final nested in item.children.where(
        (child) => child.localName == 'ul' || child.localName == 'ol',
      )) {
        _appendListLines(nested, depth: depth + 1, output: output);
      }
    }
  }

  void _appendInlineGroup(
    List<Delta> contents, {
    Map<String, dynamic> lineAttributes = const {},
    bool preserveEmpty = false,
  }) {
    if (!preserveEmpty && contents.every(_isVisiblyEmpty)) return;
    groups.add(
      _ClipboardBlockGroup(
        contents
            .map(
              (content) => _ClipboardLine(content, {
                ...lineAttributes,
                if (_isVisiblyEmpty(content))
                  MarkdownDeltaCodec.emptyParagraphAttribute: true,
              }),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ClipboardInlineBuilder {
  _ClipboardInlineBuilder(this.source);

  static final _allPlayersWord = RegExp(
    r'[a-zA-Z0-9_\u4e00-\u9fff]',
    unicode: true,
  );
  static final _mentionId = RegExp(r'^[a-zA-Z0-9_-]{1,128}$');
  static final _stickerAssetId = RegExp(r'^c[a-z0-9]{20,}$');
  static final _unsafeControl = RegExp(
    '[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]',
  );
  static final _htmlWhitespace = RegExp(r'[\t\n\f\r ]+');

  final _SiteClipboardSource source;
  final List<Delta> _lines = [Delta()];

  Delta get _current => _lines.last;

  List<Delta> build(Iterable<dom.Node> nodes) {
    final materialized = nodes.toList(growable: false);
    final soleBreak =
        materialized.length == 1 &&
        materialized.single is dom.Element &&
        (materialized.single as dom.Element).localName == 'br';
    for (final node in materialized) {
      _appendNode(node, const {});
    }
    if (soleBreak && _lines.length == 2 && _lines.every(_isVisiblyEmpty)) {
      _lines.removeLast();
    }
    return _lines;
  }

  void _appendNode(dom.Node node, Map<String, dynamic> attributes) {
    if (node is dom.Text) {
      _appendText(node.data, attributes);
      return;
    }
    if (node is! dom.Element) return;
    final tag = node.localName;
    if (tag == null) return;

    final media = node.attributes['data-wenyou-clipboard-media'];
    if (source == _SiteClipboardSource.reader &&
        (tag == 'img' || media == 'image' || media == 'sticker')) {
      _appendText(media == 'sticker' ? '[表情]' : '[图片]', attributes);
      return;
    }
    if (node.attributes.containsKey('data-dice-node-id') ||
        node.attributes['data-type'] == 'dice_inline') {
      _appendDice(node, attributes);
      return;
    }
    if (tag == 'img') {
      _appendEditorImage(node, attributes);
      return;
    }
    if (_SiteClipboardDeltaBuilder._droppedTags.contains(tag)) return;
    if (tag == 'br') {
      _lines.add(Delta());
      return;
    }
    if (tag == 'a') {
      _appendAnchor(node, attributes);
      return;
    }

    final nested = switch (tag) {
      'b' ||
      'strong' when attributes['code'] != true => {...attributes, 'bold': true},
      'i' ||
      'em' when attributes['code'] != true => {...attributes, 'italic': true},
      's' ||
      'strike' ||
      'del' when attributes['code'] != true => {...attributes, 'strike': true},
      'code' => const <String, dynamic>{'code': true},
      _ => attributes,
    };
    for (final child in node.nodes) {
      _appendNode(child, nested);
    }
  }

  void _appendAnchor(dom.Element element, Map<String, dynamic> attributes) {
    final href = element.attributes['href'] ?? '';
    final label = _visibleText(element);
    final reference = parseInternalReference(href);
    if (reference != null && _isSafeAtomicLabel(label)) {
      _current.insert({
        MarkdownDeltaCodec.internalReferenceEmbed: {
          'version': 1,
          'label': resolveInternalReferenceLabel(
            label: label,
            reference: reference,
          ),
          'location': reference.location.toString(),
        },
      });
      return;
    }

    final user = RegExp(r'^/users/([^/]+)$').firstMatch(href);
    if (user != null &&
        _mentionId.hasMatch(user.group(1)!) &&
        label.startsWith('@') &&
        label.length <= 32 &&
        _isSafeAtomicLabel(label)) {
      _current.insert({
        MarkdownDeltaCodec.mentionEmbed: {
          'version': 1,
          'kind': 'user',
          'userId': user.group(1)!,
          'label': label,
        },
      });
      return;
    }

    final uri = Uri.tryParse(href);
    final canLink =
        attributes['code'] != true &&
        uri != null &&
        uri.hasScheme &&
        MarkdownContent.isSafeLink(uri) &&
        href.length <= 2048 &&
        !RegExp(r'[\s)]').hasMatch(href) &&
        !_unsafeControl.hasMatch(href) &&
        !label.contains(']');
    final nested = canLink
        ? <String, dynamic>{...attributes, 'link': href}
        : attributes;
    for (final child in element.nodes) {
      _appendNode(child, nested);
    }
  }

  void _appendDice(dom.Element element, Map<String, dynamic> attributes) {
    final oldNodeId =
        element.attributes['data-dice-node-id'] ??
        element.attributes['data-node-id'] ??
        '';
    final notation = MarkdownDiceContract.normalizeNotation(
      element.attributes['data-dice-notation'] ??
          element.attributes['data-notation'] ??
          '',
    );
    if (MarkdownDiceContract.uuidV4.hasMatch(oldNodeId) && notation != null) {
      _current.insert({
        MarkdownDeltaCodec.diceEmbed: {
          'version': 1,
          'nodeId': const Uuid().v4(),
          'notation': notation,
        },
      });
      return;
    }
    _appendText(_visibleText(element), attributes);
  }

  void _appendEditorImage(
    dom.Element element,
    Map<String, dynamic> attributes,
  ) {
    if (source != _SiteClipboardSource.editor) {
      _appendText('[图片]', attributes);
      return;
    }
    final type = element.attributes['data-type'];
    final url = element.attributes['src'] ?? '';
    if (type == 'sticker-inline') {
      final assetId = element.attributes['data-asset-id'] ?? '';
      if (_stickerAssetId.hasMatch(assetId) && _isSafeImageUrl(url)) {
        _current.insert({
          MarkdownDeltaCodec.stickerEmbed: {
            'version': 1,
            'assetId': assetId,
            'url': url,
            'alt': '表情',
          },
        });
        return;
      }
      _appendText('[图片]', attributes);
      return;
    }
    if (!_isSafeImageUrl(url)) {
      _appendText('[图片]', attributes);
      return;
    }

    final imageBlock = type == 'image-block';
    final rawAlt = imageBlock
        ? _normalizedRatio(element.attributes['ratio'])
        : (element.attributes['alt'] ?? '').substring(
            0,
            (element.attributes['alt'] ?? '').length.clamp(0, 512),
          );
    final alt = _isSafeAtomicLabel(rawAlt) ? rawAlt : '图片';
    final rawTitle = imageBlock
        ? element.attributes['caption']
        : element.attributes['title'];
    final title = _safeImageTitle(rawTitle);
    _current.insert({
      MarkdownDeltaCodec.imageEmbed: {
        'version': 1,
        'url': url,
        'alt': alt,
        'title': title,
      },
    });
  }

  void _appendText(String value, Map<String, dynamic> attributes) {
    final normalized = value
        .replaceAll(_unsafeControl, '')
        .replaceAll(_htmlWhitespace, ' ');
    if (normalized.isEmpty) return;
    if (attributes['code'] == true || attributes['link'] != null) {
      _insertLiteralText(normalized, attributes);
      return;
    }

    const allPlayers = '@全体玩家';
    var offset = 0;
    while (offset < normalized.length) {
      final index = normalized.indexOf(allPlayers, offset);
      if (index < 0) break;
      final end = index + allPlayers.length;
      final leftSafe =
          index == 0 || !_allPlayersWord.hasMatch(normalized[index - 1]);
      final rightSafe =
          end == normalized.length ||
          !_allPlayersWord.hasMatch(normalized[end]);
      if (!leftSafe || !rightSafe) {
        offset = end;
        continue;
      }
      if (index > offset) {
        _insertLiteralText(normalized.substring(offset, index), attributes);
      }
      _current.insert({
        MarkdownDeltaCodec.mentionEmbed: const {
          'version': 1,
          'kind': 'all_players',
          'label': allPlayers,
        },
      });
      offset = end;
    }
    if (offset < normalized.length) {
      _insertLiteralText(normalized.substring(offset), attributes);
    }
  }

  void _insertLiteralText(String value, Map<String, dynamic> attributes) {
    if (value.isEmpty) return;
    _current.insert(value, {
      ...attributes,
      MarkdownDeltaCodec.literalTextAttribute: true,
    });
  }

  static String _visibleText(dom.Element element) => element.text
      .replaceAll(_unsafeControl, '')
      .replaceAll(_htmlWhitespace, ' ')
      .trim();

  static bool _isSafeAtomicLabel(String value) =>
      value.isNotEmpty &&
      !value.contains(']') &&
      !value.contains('\n') &&
      !value.contains('\r');

  static bool _isSafeImageUrl(String value) {
    final uri = Uri.tryParse(value);
    return value.isNotEmpty &&
        value.length <= 2048 &&
        uri != null &&
        uri.hasScheme &&
        MarkdownContent.isSafeImage(uri) &&
        !RegExp(r'[\s)]').hasMatch(value) &&
        !_unsafeControl.hasMatch(value);
  }

  static String _normalizedRatio(String? value) {
    final ratio = double.tryParse(value ?? '1');
    return ((ratio?.isFinite ?? false) && ratio! > 0 ? ratio : 1.0)
        .toStringAsFixed(2);
  }

  static String? _safeImageTitle(String? value) {
    if (value == null || value.isEmpty) return null;
    final limited = value.substring(0, value.length.clamp(0, 512));
    if (limited.contains('"') ||
        limited.contains('\n') ||
        limited.contains('\r')) {
      return null;
    }
    return limited;
  }
}

class _ClipboardBlockGroup {
  const _ClipboardBlockGroup(this.lines);

  final List<_ClipboardLine> lines;
}

class _ClipboardLine {
  const _ClipboardLine(this.content, [this.attributes = const {}]);

  final Delta content;
  final Map<String, dynamic> attributes;
}

void _appendDelta(Delta target, Delta source) {
  for (final operation in source.operations) {
    target.insert(operation.data, operation.attributes);
  }
}

Delta _mergeInlineLines(List<Delta> lines) {
  final output = Delta();
  for (var index = 0; index < lines.length; index++) {
    if (index > 0 && !_isVisiblyEmpty(output)) {
      output.insert(' ', {MarkdownDeltaCodec.literalTextAttribute: true});
    }
    _appendDelta(output, lines[index]);
  }
  return output;
}

bool _isVisiblyEmpty(Delta delta) => delta.operations.every((operation) {
  final data = operation.data;
  return data is String && data.trim().isEmpty;
});

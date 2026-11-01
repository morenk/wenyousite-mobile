import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_empty_paragraphs.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_image_occurrence_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_compatibility_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_quote_line_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_reader_leading_space_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_reader_paragraph_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_selection_scope.dart';
import 'package:wenyousite_mobile/core/widgets/markdown_internal_reference_projection.dart';
import 'package:wenyousite_mobile/core/widgets/markdown_text_color_builder.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_body_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_dice_node.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_inline_builder.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_rich_text_style_spec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selectable_action_region.dart';

export 'package:wenyousite_mobile/core/widgets/wenyou_dice_node.dart'
    show WenyouDiceRollDetail;

String formatWenyouDiceSemantics({
  required String notation,
  required List<int> results,
  required int total,
}) => '骰子 $notation，总计 $total';

class WenyouMarkdown extends StatefulWidget {
  const WenyouMarkdown({
    required this.data,
    this.diceLabels = const {},
    this.mediaDisplays = const {},
    this.mediaAudios = const {},
    this.mentionLabels = const {},
    this.diceSemantics = const {},
    this.diceDetails = const {},
    this.onInternalLink,
    this.onAddImageToStickers,
    this.onOpenImage,
    this.onTapText,
    this.onLongPressNonText,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    this.enablePlainTextFastPath = true,
    this.enableTextFonts = false,
    this.diagnosticRenderKey,
    super.key,
  });

  final String data;
  final Map<String, MediaDisplay> mediaDisplays;
  final Map<String, MediaAudio> mediaAudios;
  final Map<String, String> mentionLabels;
  final Map<String, String> diceLabels;
  final Map<String, String> diceSemantics;
  final Map<String, WenyouDiceRollDetail> diceDetails;
  final ValueChanged<Uri>? onInternalLink;
  final Future<String> Function(Uri uri)? onAddImageToStickers;
  final void Function(int imageIndex, Uri uri, String? alt)? onOpenImage;
  final VoidCallback? onTapText;
  final VoidCallback? onLongPressNonText;
  final double bodyFontSize;
  final double bodyHeight;
  final bool enablePlainTextFastPath;

  final bool enableTextFonts;
  final GlobalKey? diagnosticRenderKey;

  @override
  State<WenyouMarkdown> createState() => _WenyouMarkdownState();
}

class _WenyouMarkdownState extends State<WenyouMarkdown>
    with AutomaticKeepAliveClientMixin {
  DiscussionSelectionController? _selectionScope;
  @override
  bool get wantKeepAlive => _hasSelection;
  final _selectionAreaKey = GlobalKey<SelectionAreaState>();
  late final ValueNotifier<Map<String, String>> _diceLabels;
  late final ValueNotifier<Map<String, String>> _mentionLabels;
  late final ValueNotifier<Map<String, String>> _diceSemantics;
  late final ValueNotifier<Map<String, WenyouDiceRollDetail>> _diceDetails;
  late String _normalizedData;
  List<MarkdownRenderSegment> _renderSegments = const [];
  List<int> _segmentImageStarts = const [];
  List<bool> _segmentSeparators = const [];
  List<InternalReferencePortal> _internalReferences = const [];
  Map<String, md.LinkReference> _imageReferences = const {};
  MarkdownStyleSheet? _styleSheet;
  Widget? _renderedBody;
  Key? _markdownParseKey;
  var _usesPlainTextFastPath = false;
  var _hasSelection = false;
  final _colorRecognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _diceLabels = ValueNotifier(Map.unmodifiable(widget.diceLabels));
    _mentionLabels = ValueNotifier(Map.unmodifiable(widget.mentionLabels));
    _diceSemantics = ValueNotifier(Map.unmodifiable(widget.diceSemantics));
    _diceDetails = ValueNotifier(Map.unmodifiable(widget.diceDetails));
    _prepareData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectionScope = DiscussionSelectionScope.of(context);
    _styleSheet = _createStyleSheet(context);
    _renderedBody = null;
  }

  @override
  void didUpdateWidget(covariant WenyouMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableTextFonts != widget.enableTextFonts) {
      _markdownParseKey = UniqueKey();
      _renderedBody = null;
    }
    if (!mapEquals(oldWidget.diceLabels, widget.diceLabels)) {
      _diceLabels.value = Map.unmodifiable(widget.diceLabels);
    }
    if (!mapEquals(oldWidget.diceSemantics, widget.diceSemantics)) {
      _diceSemantics.value = Map.unmodifiable(widget.diceSemantics);
    }
    if (!mapEquals(oldWidget.diceDetails, widget.diceDetails)) {
      _diceDetails.value = Map.unmodifiable(widget.diceDetails);
    }
    if (!mapEquals(oldWidget.mediaDisplays, widget.mediaDisplays) ||
        !mapEquals(oldWidget.mediaAudios, widget.mediaAudios)) {
      _renderedBody = null;
    }
    if (!setEquals(
      MarkdownAudioProjection.sourceKeys(oldWidget.mediaAudios),
      MarkdownAudioProjection.sourceKeys(widget.mediaAudios),
    )) {
      // 上游只在 data/styleSheet 改变时重建 children；可信音频集合
      // 也会改变段落分块，必须让 AST 与 children 同步。等价 DTO 不重挂。
      _markdownParseKey = UniqueKey();
    }
    if (!mapEquals(oldWidget.mentionLabels, widget.mentionLabels)) {
      _mentionLabels.value = Map.unmodifiable(widget.mentionLabels);
    }
    if (oldWidget.data != widget.data ||
        oldWidget.enablePlainTextFastPath != widget.enablePlainTextFastPath) {
      _prepareData();
    }
    if (oldWidget.bodyFontSize != widget.bodyFontSize ||
        oldWidget.bodyHeight != widget.bodyHeight) {
      _styleSheet = _createStyleSheet(context);
      _renderedBody = null;
    }
    if ((oldWidget.onTapText == null) != (widget.onTapText == null) ||
        (oldWidget.onAddImageToStickers == null) !=
            (widget.onAddImageToStickers == null) ||
        (oldWidget.onLongPressNonText == null) !=
            (widget.onLongPressNonText == null) ||
        oldWidget.diagnosticRenderKey != widget.diagnosticRenderKey) {
      _renderedBody = null;
    }
  }

  @override
  void dispose() {
    for (final recognizer in _colorRecognizers) {
      recognizer.dispose();
    }
    _selectionScope?.update(this, false);
    _diceLabels.dispose();
    _mentionLabels.dispose();
    _diceSemantics.dispose();
    _diceDetails.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _renderedBody ??= _buildBody();
  }

  @override
  void reassemble() {
    super.reassemble();
    // 阅读缓存包含解析器和 builder；Debug 热重载后重新应用渲染规则。
    _renderedBody = null;
    _markdownParseKey = UniqueKey();
  }

  Widget _buildBody() {
    for (final recognizer in _colorRecognizers) {
      recognizer.dispose();
    }
    _colorRecognizers.clear();
    final Widget body;
    if (_usesPlainTextFastPath) {
      final paragraphs = _normalizedData.split(_plainTextParagraphBreak);
      body = Column(
        key: const Key('wenyou-markdown-plain-text'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < paragraphs.length; index++) ...[
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onTapText == null ? null : _handleTapText,
              child: Text(paragraphs[index], style: _styleSheet?.p),
            ),
          ],
        ],
      );
    } else {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTapText == null ? null : _handleTapText,
        child: KeyedSubtree(
          key: _markdownParseKey,
          child: _buildMarkdownSegments(),
        ),
      );
    }
    return KeyedSubtree(
      key: widget.diagnosticRenderKey,
      child: WenyouSelectableActionRegion(
        selectionAreaKey: _selectionAreaKey,
        onLongPressBlank: widget.onLongPressNonText == null
            ? null
            : _handleBlankLongPress,
        child: SelectionArea(
          key: _selectionAreaKey,
          onSelectionChanged: _handleSelectionChanged,
          child: body,
        ),
      ),
    );
  }

  void _prepareData() {
    final normalized = MarkdownContent.literalizeUnsupported(
      MarkdownEmptyParagraphs.recoverLegacy(
        MarkdownSourceProtection.prepareForReader(widget.data),
      ),
      imageAlignment: true,
    );
    final prepared = projectMarkdownInternalReferences(
      MarkdownEmptyParagraphs.prepareForLineEditor(
        MarkdownInlineBoundary.canonicalizeDocument(normalized),
      ),
    );
    _normalizedData = prepared.data;
    _renderSegments = prepared.segments;
    _internalReferences = prepared.references;
    final referenceDocument = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    // 没有引用定义起始行时，避免为图片引用映射再解析整篇正文。
    if (RegExp(r'\]\s*:').hasMatch(_normalizedData)) {
      referenceDocument.parse(_normalizedData);
    }
    _imageReferences = referenceDocument.linkReferences;
    var imageIndex = 0;
    _segmentImageStarts = _renderSegments.length == 1
        ? [0]
        : [
            for (final segment in _renderSegments)
              () {
                final start = imageIndex;
                imageIndex += MarkdownImageOccurrenceSyntax.count(
                  segment.markdown,
                  references: _imageReferences,
                );
                return start;
              }(),
          ];
    _segmentSeparators = _renderSegments.length == 1
        ? [false]
        : [
            for (var i = 0; i < _renderSegments.length; i++)
              _separatesRenderSegments(i),
          ];
    _usesPlainTextFastPath =
        widget.enablePlainTextFastPath &&
        prepared.references.isEmpty &&
        _renderSegments.every((segment) => !segment.isAligned) &&
        _isUnambiguousPlainText(prepared.data);
    _renderedBody = null;
  }

  Widget _buildMarkdownSegments() {
    if (_renderSegments.length == 1 && !_renderSegments.single.isAligned) {
      return _buildMarkdownBody(_normalizedData, _styleSheet);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _renderSegments.length; index++) ...[
          if (_segmentSeparators[index])
            SizedBox(height: _styleSheet?.blockSpacing ?? 0),
          KeyedSubtree(
            key: ValueKey(
              'wenyou-markdown-segment-$index-'
              '${_renderSegments[index].alignment.name}',
            ),
            child: _buildMarkdownBody(
              _renderSegments[index].markdown,
              _alignedStyleSheet(_renderSegments[index].alignment),
              expandBlockWidth: _renderSegments[index].isAligned,
              alignment: _renderSegments[index].alignment,
              imageStartIndex: _segmentImageStarts[index],
            ),
          ),
        ],
      ],
    );
  }

  MarkdownStyleSheet? _alignedStyleSheet(WenyouTextAlignment alignment) {
    final styleSheet = _styleSheet;
    if (styleSheet == null || alignment == WenyouTextAlignment.left) {
      return styleSheet;
    }
    final wrapAlignment = alignment == WenyouTextAlignment.center
        ? WrapAlignment.center
        : WrapAlignment.end;
    return styleSheet.copyWith(
      textAlign: wrapAlignment,
      h2Align: wrapAlignment,
      h3Align: wrapAlignment,
    );
  }

  bool _separatesRenderSegments(int index) {
    if (index == 0) return false;
    final previous = _renderSegments[index - 1].markdown.trimRight();
    final next = _renderSegments[index].markdown.trimLeft();
    final previousBlocks = md.Document().parse(previous);
    final nextBlocks = md.Document().parse(next);
    // 显式空段在连续阅读时并入正文行，标题边界仍有块间距。
    // 对齐拆段不能因相邻 <br /> 把这部分标题留白一起移除。
    bool isHeading(md.Node node) =>
        node is md.Element && RegExp(r'^h[1-6]$').hasMatch(node.tag);
    if ((previousBlocks.isNotEmpty && isHeading(previousBlocks.last)) ||
        (nextBlocks.isNotEmpty && isHeading(nextBlocks.first))) {
      return true;
    }
    if (previousBlocks.isNotEmpty &&
        nextBlocks.isNotEmpty &&
        WenyouMarkdownBody.isBodyParagraph(previousBlocks.last) &&
        WenyouMarkdownBody.isBodyParagraph(nextBlocks.first)) {
      return false;
    }
    return !previous.endsWith('<br />') && !next.startsWith('<br />');
  }

  MarkdownBody _buildMarkdownBody(
    String data,
    MarkdownStyleSheet? styleSheet, {
    bool expandBlockWidth = false,
    WenyouTextAlignment alignment = WenyouTextAlignment.left,
    int imageStartIndex = 0,
  }) => WenyouMarkdownBody(
    data: data,
    parseRevision: (_markdownParseKey, imageStartIndex, _imageReferences),
    mediaAudios: widget.mediaAudios,
    selectable: false,
    // MarkdownBody defaults to fitContent=true, which shrink-wraps its inner
    // paragraph Wrap. A centered/right-aligned TextAlign then has no spare
    // width and still paints at the left edge. Alignment segments must stretch
    // their block before the style-sheet alignment can affect geometry.
    fitContent: !expandBlockWidth,
    softLineBreak: true,
    styleSheet: styleSheet,
    blockSyntaxes: [
      const md.SetextHeaderSyntax(),
      const MarkdownQuoteLineSyntax(_emptyParagraphTag),
      MarkdownLiteralRowsSyntax(
        isAtomicLine: widget.mediaAudios.isEmpty
            ? null
            : (line) =>
                  MarkdownAudioProjection.fromLine(line, widget.mediaAudios) !=
                  null,
      ),
      _EmptyParagraphBlockSyntax(),
      const MarkdownReaderParagraphSyntax(),
    ],
    inlineSyntaxes: [
      MarkdownReaderLeadingSpaceSyntax(),
      MarkdownTextColorSyntax(),
      MarkdownImageOccurrenceSyntax(
        startIndex: imageStartIndex,
        references: _imageReferences,
      ),
      ...MarkdownInlineCompatibilitySyntax.create(),
      _InternalReferenceInlineSyntax(),
      _UserMentionInlineSyntax(),
      _AllPlayersMentionInlineSyntax(),
      _DiceInlineSyntax(),
    ],
    builders: {
      MarkdownTextColor.tag: MarkdownTextColorBuilder(
        enableTextFonts: widget.enableTextFonts,
        onLink: (href) => _openLink(context, href),
        registerRecognizer: _colorRecognizers.add,
      ),
      'img': _OccurrenceImageBuilder((element) {
        final uri = Uri.parse(element.attributes['src']!);
        final title = element.attributes['title'];
        final alt = element.attributes['alt'];
        final imageIndex = int.tryParse(
          element.attributes['data-image-index'] ?? '',
        );
        final image = WenyouMarkdownImage(
          uri: uri,
          display: widget.mediaDisplays[uri.toString()],
          title: title,
          alt: alt,
          onOpen: imageIndex == null || widget.onOpenImage == null
              ? null
              : () => widget.onOpenImage!(imageIndex, uri, alt),
          onAddToStickers: widget.onAddImageToStickers == null
              ? null
              : _addImageToStickers,
          onLongPress: widget.onLongPressNonText == null
              ? null
              : _handleNonTextLongPress,
          blockAlignment: alignment,
        );
        return image;
      }),
      _emptyParagraphTag: _EmptyParagraphMarkdownBuilder(
        lineHeight: widget.bodyFontSize * widget.bodyHeight,
      ),
      'wenyou-internal-reference': _InternalReferenceMarkdownBuilder(
        _internalReferences,
        (reference) => _openInternalReference(context, reference),
        onLongPress: widget.onLongPressNonText == null
            ? null
            : _handleNonTextLongPress,
      ),
      'wenyou-dice': _DiceMarkdownBuilder(
        _diceLabels,
        _diceSemantics,
        _diceDetails,
        onLongPress: widget.onLongPressNonText == null
            ? null
            : _handleNonTextLongPress,
      ),
      'wenyou-mention': _MentionMarkdownBuilder(
        (location) => _openInternalLocation(context, location),
        _mentionLabels,
      ),
      'code': _InlineCodeMarkdownBuilder(),
      'hr': _HorizontalRuleMarkdownBuilder(fontSize: widget.bodyFontSize),
    },
    onTapLink: (_, href, _) => _openLink(context, href),
  );

  void _handleTapText() {
    if (_hasSelection) {
      _clearSelection();
      return;
    }
    widget.onTapText?.call();
  }

  void _handleSelectionChanged(SelectedContent? content) {
    _hasSelection = content?.plainText.isNotEmpty == true;
    _selectionScope?.update(this, _hasSelection);
    updateKeepAlive();
  }

  void _handleNonTextLongPress() {
    _clearSelection();
    widget.onLongPressNonText?.call();
  }

  void _handleBlankLongPress() {
    _clearSelection();
    widget.onLongPressNonText?.call();
  }

  void _clearSelection() {
    if (!_hasSelection) return;
    final selectableRegion = _selectionAreaKey.currentState?.selectableRegion;
    selectableRegion?.hideToolbar();
    selectableRegion?.clearSelection();
    _hasSelection = false;
    _selectionScope?.update(this, false);
    updateKeepAlive();
  }

  Future<String> _addImageToStickers(Uri uri) =>
      widget.onAddImageToStickers!(uri);

  MarkdownStyleSheet _createStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);
    final spec = WenyouRichTextStyleSpec.resolve(
      context,
      bodyFontSize: widget.bodyFontSize,
      bodyHeight: widget.bodyHeight,
    );
    return baseStyle.copyWith(
      p: spec.body,
      a: spec.link,
      h1: spec.h1,
      h1Padding: spec.h1Padding,
      h2: spec.h2,
      h2Padding: spec.h2Padding,
      h3: spec.h3,
      h3Padding: spec.h3Padding,
      h4: spec.h3,
      h4Padding: spec.h3Padding,
      h5: spec.body.copyWith(fontWeight: FontWeight.w700),
      h6: spec.body.copyWith(fontWeight: FontWeight.w700),
      strong: spec.strong,
      em: spec.emphasis,
      blockSpacing: spec.blockSpacing,
      listBullet: spec.listMarker,
      code: spec.codeBlock,
      blockquote: spec.quote,
      blockquotePadding: spec.quotePadding,
      blockquoteDecoration: spec.quoteDecoration,
      horizontalRuleDecoration: spec.horizontalRuleDecoration,
    );
  }

  void _openLink(BuildContext context, String? href) {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null) return;
    final internal = internalWenyouLocation(uri);
    if (internal != null) {
      _openInternalLocation(context, internal);
      return;
    }
    if (MarkdownContent.isSafeLink(uri)) {
      unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      return;
    }
  }

  void _openInternalReference(
    BuildContext context,
    InternalReference reference,
  ) => _openInternalLocation(context, reference.location);

  void _openInternalLocation(BuildContext context, Uri location) {
    if (widget.onInternalLink != null) {
      widget.onInternalLink!(location);
    } else {
      openInternalWenyouLink(context, location);
    }
  }
}

const _emptyParagraphTag = 'wenyou-empty-paragraph';

class _EmptyParagraphBlockSyntax extends md.BlockSyntax {
  static final _pattern = RegExp(
    r'^ {0,3}<br\s*/?>[\t ]*$',
    caseSensitive: false,
  );

  var _index = 0;

  @override
  RegExp get pattern => _pattern;

  @override
  md.Node parse(md.BlockParser parser) {
    final element = md.Element.empty(_emptyParagraphTag);
    element.attributes['index'] = '${_index++}';
    parser.advance();
    return element;
  }
}

class _EmptyParagraphMarkdownBuilder extends MarkdownElementBuilder {
  _EmptyParagraphMarkdownBuilder({required this.lineHeight});

  final double lineHeight;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return SizedBox(
      key: ValueKey(
        'wenyou-markdown-empty-paragraph-${element.attributes['index']}',
      ),
      height: lineHeight,
    );
  }
}

final _markdownMeaningfulCharacter = RegExp(
  r'[\\`*_{}\[\]()#>+\-.!|~@<>&:]',
  unicode: true,
);
final _plainTextParagraphBreak = RegExp(r'\n[ \t]*\n+', unicode: true);

bool _isUnambiguousPlainText(String data) {
  if (_markdownMeaningfulCharacter.hasMatch(data) || data.contains('\t')) {
    return false;
  }
  return !data.startsWith(' ') && !data.contains('\n ');
}

class _UserMentionInlineSyntax extends md.InlineSyntax {
  _UserMentionInlineSyntax()
    : super(MarkdownMentionTarget.nodePattern, startCharacter: 0x5b);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final target = MarkdownMentionTarget.parse(match.group(2)!);
    if (target == null || !target.acceptsLabel(match.group(1)!)) return false;
    parser.addNode(
      md.Element.text('wenyou-mention', match.group(1)!)
        ..attributes['location'] = target.sourceHref,
    );
    return true;
  }
}

class _AllPlayersMentionInlineSyntax extends md.InlineSyntax {
  _AllPlayersMentionInlineSyntax()
    : super(r'@全体玩家(?![A-Za-z0-9_\u4e00-\u9fff])', startCharacter: 0x40);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('wenyou-mention', match.group(0)!));
    return true;
  }
}

class _MentionMarkdownBuilder extends WenyouMarkdownInlineBuilder {
  _MentionMarkdownBuilder(this.onTap, this.labels);

  final ValueChanged<Uri> onTap;
  final ValueListenable<Map<String, String>> labels;

  @override
  Widget? buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) => ValueListenableBuilder<Map<String, String>>(
    valueListenable: labels,
    builder: (context, values, _) {
      var label = element.textContent;
      final style = preferredStyle ?? parentStyle;
      final location = Uri.tryParse(element.attributes['location'] ?? '');
      if (location != null &&
          location.pathSegments.length == 2 &&
          location.pathSegments.first == 'users' &&
          label.startsWith('@')) {
        final target = MarkdownMentionTarget.parse(location.toString());
        final display = target == null
            ? null
            : values[target.projectionKey(label.substring(1))];
        if (display != null) label = '@$display';
      }
      if (location == null || location.path.isEmpty) {
        return WenyouMentionSurface(label: label, style: style);
      }
      return WenyouMentionLink(
        label: label,
        style: style,
        onTap: () => onTap(location),
      );
    },
  );
}

class _InlineCodeMarkdownBuilder extends WenyouMarkdownInlineBuilder {
  @override
  Widget? buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final mergedStyle = parentStyle?.merge(preferredStyle) ?? preferredStyle;
    return WenyouInlineCodeSurface(
      text: element.textContent,
      style: mergedStyle?.copyWith(
        fontStyle: parentStyle?.fontStyle ?? mergedStyle.fontStyle,
        fontWeight: parentStyle?.fontWeight ?? mergedStyle.fontWeight,
        decoration: parentStyle?.decoration ?? mergedStyle.decoration,
      ),
    );
  }
}

class _OccurrenceImageBuilder extends WenyouMarkdownInlineBuilder {
  _OccurrenceImageBuilder(this.buildImage);
  final Widget Function(md.Element element) buildImage;

  @override
  bool usesInlineLayout(md.Element element) =>
      element.attributes['title']?.startsWith('wenyousite-sticker:') == true;

  @override
  PlaceholderAlignment inlineAlignment(md.Element element) =>
      PlaceholderAlignment.middle;

  @override
  Widget buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) => buildImage(element);
}

class _HorizontalRuleMarkdownBuilder extends MarkdownElementBuilder {
  _HorizontalRuleMarkdownBuilder({required this.fontSize});

  final double fontSize;

  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) => WenyouBodyDivider(fontSize: fontSize);
}

class _InternalReferenceInlineSyntax extends md.InlineSyntax {
  _InternalReferenceInlineSyntax()
    : super(
        r'\[\[wenyou-internal-reference:v1:(\d+)\]\]',
        startCharacter: 0x5b,
      );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
      md.Element.empty('wenyou-internal-reference')
        ..attributes['index'] = match.group(1)!,
    );
    return true;
  }
}

class _InternalReferenceMarkdownBuilder extends WenyouMarkdownInlineBuilder {
  _InternalReferenceMarkdownBuilder(
    this.references,
    this.onTap, {
    this.onLongPress,
  });

  final List<InternalReferencePortal> references;
  final ValueChanged<InternalReference> onTap;
  final VoidCallback? onLongPress;

  @override
  Widget? buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final index = int.tryParse(element.attributes['index'] ?? '');
    if (index == null || index < 0 || index >= references.length) return null;
    final portal = references[index];
    return WenyouInternalReferenceChip(
      key: ValueKey('markdown-internal-reference-$index'),
      surfaceKey: ValueKey('markdown-internal-reference-surface-$index'),
      label: portal.label,
      style: parentStyle,
      onTap: () => onTap(portal.reference),
      onLongPress: onLongPress,
    );
  }
}

class _DiceInlineSyntax extends md.InlineSyntax {
  _DiceInlineSyntax()
    : super(
        r'\[\[dice:v1:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}):([^\]\r\n]{1,32})\]\]',
        startCharacter: 0x5b,
        caseSensitive: false,
      );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final nodeId = match.group(1)!.toLowerCase();
    final notation = match.group(2)!.trim();
    parser.addNode(
      md.Element.text('wenyou-dice', notation)..attributes['node-id'] = nodeId,
    );
    return true;
  }
}

class _DiceMarkdownBuilder extends WenyouMarkdownInlineBuilder {
  _DiceMarkdownBuilder(
    this.labelsByNodeId,
    this.semanticsByNodeId,
    this.detailsByNodeId, {
    this.onLongPress,
  });

  final ValueListenable<Map<String, String>> labelsByNodeId;
  final ValueListenable<Map<String, String>> semanticsByNodeId;
  final ValueListenable<Map<String, WenyouDiceRollDetail>> detailsByNodeId;
  final VoidCallback? onLongPress;

  @override
  Widget? buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final nodeId = element.attributes['node-id']!;
    final notation = element.textContent;
    final style =
        preferredStyle ?? parentStyle ?? DefaultTextStyle.of(context).style;
    return ListenableBuilder(
      listenable: Listenable.merge([
        labelsByNodeId,
        semanticsByNodeId,
        detailsByNodeId,
      ]),
      builder: (context, _) {
        final labels = labelsByNodeId.value;
        final detail = detailsByNodeId.value[nodeId];
        final label = detail == null
            ? labels[nodeId] ?? '$notation = ?'
            : '$notation = ${detail.total}';
        final settled = detail != null || labels.containsKey(nodeId);
        return WenyouDiceNode(
          key: ValueKey('wenyou-dice-$nodeId'),
          label: label,
          semanticLabel: settled
              ? '骰子 $notation，总计 ${label.split('=').last.trim()}'
              : semanticsByNodeId.value[nodeId] ?? '骰子 $notation，待掷',
          settled: settled,
          style: style,
          detail: detail,
          onLongPress: onLongPress,
        );
      },
    );
  }
}

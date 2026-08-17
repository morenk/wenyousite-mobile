import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_link_style.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';

String formatWenyouDiceSemantics({
  required String notation,
  required List<int> results,
  required int total,
}) {
  if (results.isEmpty) return '骰子 $notation，总计 $total';
  final resultTotal = results.fold<int>(0, (sum, result) => sum + result);
  final modifier = total - resultTotal;
  final modifierPhrase = switch (modifier) {
    > 0 => '，修正加 $modifier',
    < 0 => '，修正减 ${modifier.abs()}',
    _ => '',
  };
  return '骰子 $notation，逐骰结果 ${results.join('、')}$modifierPhrase，总计 $total';
}

class WenyouMarkdown extends StatefulWidget {
  const WenyouMarkdown({
    required this.data,
    this.diceLabels = const {},
    this.diceSemantics = const {},
    this.onInternalLink,
    this.onSaveImage,
    this.onTapText,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    super.key,
  });

  final String data;
  final Map<String, String> diceLabels;
  final Map<String, String> diceSemantics;
  final ValueChanged<Uri>? onInternalLink;
  final Future<String> Function(Uri uri)? onSaveImage;
  final VoidCallback? onTapText;
  final double bodyFontSize;
  final double bodyHeight;

  @override
  State<WenyouMarkdown> createState() => _WenyouMarkdownState();
}

class _WenyouMarkdownState extends State<WenyouMarkdown>
    with AutomaticKeepAliveClientMixin<WenyouMarkdown> {
  late final ValueNotifier<Map<String, String>> _diceLabels;
  late final ValueNotifier<Map<String, String>> _diceSemantics;
  late String _normalizedData;
  List<InternalReferencePortal> _internalReferences = const [];
  MarkdownStyleSheet? _styleSheet;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _diceLabels = ValueNotifier(Map.unmodifiable(widget.diceLabels));
    _diceSemantics = ValueNotifier(Map.unmodifiable(widget.diceSemantics));
    _prepareData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _styleSheet = _createStyleSheet(context);
  }

  @override
  void didUpdateWidget(covariant WenyouMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.diceLabels, widget.diceLabels)) {
      _diceLabels.value = Map.unmodifiable(widget.diceLabels);
    }
    if (!mapEquals(oldWidget.diceSemantics, widget.diceSemantics)) {
      _diceSemantics.value = Map.unmodifiable(widget.diceSemantics);
    }
    if (oldWidget.data != widget.data) {
      _prepareData();
    }
    if (oldWidget.bodyFontSize != widget.bodyFontSize ||
        oldWidget.bodyHeight != widget.bodyHeight) {
      _styleSheet = _createStyleSheet(context);
    }
  }

  @override
  void dispose() {
    _diceLabels.dispose();
    _diceSemantics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MarkdownBody(
      data: _normalizedData,
      selectable: true,
      softLineBreak: true,
      styleSheet: _styleSheet,
      inlineSyntaxes: [_InternalReferenceInlineSyntax(), _DiceInlineSyntax()],
      builders: {
        'wenyou-internal-reference': _InternalReferenceMarkdownBuilder(
          _internalReferences,
          (reference) => _openInternalReference(context, reference),
        ),
        'wenyou-dice': _DiceMarkdownBuilder(_diceLabels, _diceSemantics),
      },
      onTapLink: (_, href, _) => _openLink(context, href),
      onTapText: widget.onTapText,
      imageBuilder: (uri, title, alt) => _MarkdownImage(
        uri: uri,
        title: title,
        alt: alt,
        onSave: widget.onSaveImage,
      ),
    );
  }

  void _prepareData() {
    final normalized = MarkdownContent.literalizeUnsupported(widget.data);
    final prepared = _prepareInternalReferences(normalized);
    _normalizedData = prepared.data;
    _internalReferences = prepared.references;
  }

  MarkdownStyleSheet _createStyleSheet(BuildContext context) {
    final tokens = context.wenyouTokens;
    final theme = Theme.of(context);
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: widget.bodyFontSize,
      height: widget.bodyHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: widget.bodyFontSize * 0.008,
    );
    final h1 = bodyStyle?.copyWith(
      fontSize: widget.bodyFontSize * 1.65,
      height: 1.4,
      fontWeight: FontWeight.w700,
      letterSpacing: widget.bodyFontSize * 0.015,
    );
    final h2 = bodyStyle?.copyWith(
      fontSize: widget.bodyFontSize * 1.35,
      height: 1.45,
      fontWeight: FontWeight.w700,
      letterSpacing: widget.bodyFontSize * 0.015,
    );
    final h3 = bodyStyle?.copyWith(
      fontSize: widget.bodyFontSize * 1.12,
      height: 1.55,
      fontWeight: FontWeight.w700,
      letterSpacing: widget.bodyFontSize * 0.015,
    );
    final compactBody = bodyStyle?.copyWith(
      fontSize: widget.bodyFontSize * 0.88,
      height: 1.7,
    );
    return baseStyle.copyWith(
      p: bodyStyle,
      a: wenyouContentLinkStyle(context, base: bodyStyle),
      h1: h1,
      h1Padding: EdgeInsets.only(top: tokens.space16, bottom: tokens.space8),
      h2: h2,
      h2Padding: EdgeInsets.only(top: tokens.space16, bottom: tokens.space4),
      h3: h3,
      h3Padding: EdgeInsets.only(top: tokens.space12, bottom: tokens.space4),
      h4: h3,
      h4Padding: EdgeInsets.only(top: tokens.space12, bottom: tokens.space4),
      h5: bodyStyle?.copyWith(fontWeight: FontWeight.w700),
      h6: bodyStyle?.copyWith(fontWeight: FontWeight.w700),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: widget.bodyFontSize * 0.018,
      ),
      em: const TextStyle(fontStyle: FontStyle.italic),
      blockSpacing: tokens.space12,
      listBullet: bodyStyle?.copyWith(color: tokens.brandForeground),
      code: compactBody?.copyWith(
        color: tokens.text,
        backgroundColor: tokens.softPanel,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w500,
      ),
      blockquote: bodyStyle?.copyWith(fontStyle: FontStyle.italic),
      blockquotePadding: EdgeInsets.all(tokens.space12),
      blockquoteDecoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(
          left: BorderSide(color: tokens.brandForeground, width: 3),
        ),
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(tokens.radius12),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.border)),
      ),
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

final _markdownCodePattern = RegExp(
  r'(`{3,}[^\r\n]*\r?\n[\s\S]*?\r?\n`{3,}|~{3,}[^\r\n]*\r?\n[\s\S]*?\r?\n~{3,}|`[^`\r\n]*`)',
  unicode: true,
);

({String data, List<InternalReferencePortal> references})
_prepareInternalReferences(String source) {
  final output = StringBuffer();
  final references = <InternalReferencePortal>[];
  var offset = 0;
  for (final match in _markdownCodePattern.allMatches(source)) {
    _appendInternalReferenceChunk(
      source.substring(offset, match.start),
      output,
      references,
    );
    output.write(match.group(0));
    offset = match.end;
  }
  _appendInternalReferenceChunk(source.substring(offset), output, references);
  return (data: output.toString(), references: List.unmodifiable(references));
}

void _appendInternalReferenceChunk(
  String source,
  StringBuffer output,
  List<InternalReferencePortal> references,
) {
  for (final segment in tokenizeInternalReferenceText(source)) {
    switch (segment) {
      case InternalReferencePlainText(:final value):
        output.write(value);
      case InternalReferencePortal(:final label, :final reference):
        final previous = output.isEmpty
            ? ''
            : output.toString()[output.length - 1];
        if (previous == '!' || previous == r'\') {
          output.write('[$label](${reference.location})');
          continue;
        }
        final index = references.length;
        references.add(segment);
        output.write('[[wenyou-internal-reference:v1:$index]]');
    }
  }
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

class _InternalReferenceMarkdownBuilder extends MarkdownElementBuilder {
  _InternalReferenceMarkdownBuilder(this.references, this.onTap);

  final List<InternalReferencePortal> references;
  final ValueChanged<InternalReference> onTap;

  @override
  Widget? visitElementAfterWithContext(
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

class _DiceMarkdownBuilder extends MarkdownElementBuilder {
  _DiceMarkdownBuilder(this.labelsByNodeId, this.semanticsByNodeId);

  final ValueListenable<Map<String, String>> labelsByNodeId;
  final ValueListenable<Map<String, String>> semanticsByNodeId;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final nodeId = element.attributes['node-id']!;
    final notation = element.textContent;
    final style =
        (preferredStyle ?? parentStyle ?? DefaultTextStyle.of(context).style)
            .copyWith(
              fontFamily: WenyouFoundationTypography.utility,
              fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
              fontFeatures: const [FontFeature.tabularFigures()],
            );
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ListenableBuilder(
              listenable: Listenable.merge([labelsByNodeId, semanticsByNodeId]),
              builder: (context, _) {
                final labels = labelsByNodeId.value;
                final label = labels[nodeId] ?? '$notation = ?';
                return Semantics(
                  key: ValueKey('wenyou-dice-$nodeId'),
                  label:
                      semanticsByNodeId.value[nodeId] ??
                      (labels.containsKey(nodeId)
                          ? '骰子 $notation，总计 ${label.split('=').last.trim()}'
                          : '骰子 $notation，待掷'),
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: style,
                    strutStyle: StrutStyle.fromTextStyle(
                      style,
                      forceStrutHeight: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownImage extends StatelessWidget {
  const _MarkdownImage({required this.uri, this.title, this.alt, this.onSave});

  final Uri uri;
  final String? title;
  final String? alt;
  final Future<String> Function(Uri uri)? onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (!MarkdownContent.isSafeImage(uri)) {
      return Semantics(
        label: '已阻止不安全图片${alt == null ? '' : '：$alt'}',
        child: WenyouIcon(
          WenyouIconIds.statusImageUnavailable,
          color: tokens.mutedText,
        ),
      );
    }
    final isSticker = title?.startsWith('wenyousite-sticker:') == true;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
      ),
    );
    final image = WenyouCachedImage(
      imageUrl: uri.toString(),
      fit: BoxFit.contain,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => Semantics(
        label: '图片加载失败${alt == null ? '' : '：$alt'}',
        child: fallback,
      ),
    );
    final imageContent = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: isSticker
          ? SizedBox.square(dimension: 96, child: image)
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: image,
            ),
    );
    if (isSticker) {
      return Semantics(
        image: true,
        label: alt?.trim().isNotEmpty == true ? alt!.trim() : '收藏表情',
        child: imageContent,
      );
    }
    final imageAlt = alt?.trim() ?? '';
    final descriptiveAlt = imageAlt == '图片' ? '' : imageAlt;
    return Semantics(
      button: true,
      image: true,
      label: descriptiveAlt.isEmpty ? '查看正文图片原图' : '查看正文图片原图：$descriptiveAlt',
      child: InkWell(
        key: ValueKey('markdown-image-$uri'),
        borderRadius: BorderRadius.circular(tokens.radius12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ContentImageViewerPage(
              url: uri.toString(),
              alt: imageAlt,
              onSaveImage: onSave == null ? null : () => onSave!(uri),
            ),
          ),
        ),
        child: imageContent,
      ),
    );
  }
}

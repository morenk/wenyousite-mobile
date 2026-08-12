import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';

class WenyouMarkdown extends StatefulWidget {
  const WenyouMarkdown({
    required this.data,
    this.diceLabels = const {},
    this.onInternalLink,
    this.onSaveImage,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    super.key,
  });

  final String data;
  final Map<String, String> diceLabels;
  final ValueChanged<Uri>? onInternalLink;
  final Future<String> Function(Uri uri)? onSaveImage;
  final double bodyFontSize;
  final double bodyHeight;

  @override
  State<WenyouMarkdown> createState() => _WenyouMarkdownState();
}

class _WenyouMarkdownState extends State<WenyouMarkdown> {
  late final ValueNotifier<Map<String, String>> _diceLabels;
  MarkdownStyleSheet? _styleSheet;

  @override
  void initState() {
    super.initState();
    _diceLabels = ValueNotifier(Map.unmodifiable(widget.diceLabels));
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
    if (oldWidget.bodyFontSize != widget.bodyFontSize ||
        oldWidget.bodyHeight != widget.bodyHeight) {
      _styleSheet = _createStyleSheet(context);
    }
  }

  @override
  void dispose() {
    _diceLabels.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: MarkdownContent.normalize(widget.data),
      selectable: true,
      softLineBreak: true,
      styleSheet: _styleSheet,
      inlineSyntaxes: [_DiceInlineSyntax()],
      builders: {'wenyou-dice': _DiceMarkdownBuilder(_diceLabels)},
      onTapLink: (_, href, _) => _openLink(context, href),
      imageBuilder: (uri, title, alt) => _MarkdownImage(
        uri: uri,
        title: title,
        alt: alt,
        onSave: widget.onSaveImage,
      ),
    );
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
      a: bodyStyle?.copyWith(
        color: tokens.brand,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: tokens.brand,
      ),
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
      listBullet: bodyStyle?.copyWith(color: tokens.brand),
      code: compactBody?.copyWith(
        color: tokens.text,
        backgroundColor: tokens.softPanel,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w500,
      ),
      codeblockPadding: EdgeInsets.all(tokens.space12),
      codeblockDecoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      blockquote: bodyStyle?.copyWith(fontStyle: FontStyle.italic),
      blockquotePadding: EdgeInsets.all(tokens.space12),
      blockquoteDecoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(left: BorderSide(color: tokens.brand, width: 3)),
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(tokens.radius12),
        ),
      ),
      tableHead: compactBody?.copyWith(fontWeight: FontWeight.w700),
      tableBody: compactBody,
      tableBorder: TableBorder.all(color: tokens.border),
      tableCellsPadding: EdgeInsets.all(tokens.space8),
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
      if (widget.onInternalLink != null) {
        widget.onInternalLink!(internal);
      } else {
        openInternalWenyouLink(context, internal);
      }
      return;
    }
    if (MarkdownContent.isSafeLink(uri)) {
      unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      return;
    }
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
  _DiceMarkdownBuilder(this.labelsByNodeId);

  final ValueListenable<Map<String, String>> labelsByNodeId;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final tokens = context.wenyouTokens;
    final nodeId = element.attributes['node-id']!;
    final notation = element.textContent;
    final style =
        (preferredStyle ?? parentStyle ?? DefaultTextStyle.of(context).style)
            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: ValueListenableBuilder<Map<String, String>>(
        valueListenable: labelsByNodeId,
        builder: (context, labels, _) {
          final label = labels[nodeId] ?? '$notation = ?';
          final isResult = labels.containsKey(nodeId);
          return DecoratedBox(
            key: ValueKey('wenyou-dice-$nodeId'),
            decoration: BoxDecoration(
              color: (isResult ? tokens.accentedBackground : tokens.softPanel)
                  .withValues(alpha: isResult ? 0.3 : 0.7),
              borderRadius: BorderRadius.circular(tokens.radius12 / 2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Text(label, style: style),
            ),
          );
        },
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
        child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
      );
    }
    final isSticker = title?.startsWith('wenyousite-sticker:') == true;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Icon(Icons.image_outlined, color: tokens.mutedText)),
    );
    final image = CachedNetworkImage(
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
    return Semantics(
      button: true,
      image: true,
      label: imageAlt.isEmpty ? '查看正文图片原图' : '查看正文图片原图：$imageAlt',
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

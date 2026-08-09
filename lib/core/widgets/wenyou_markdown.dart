import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

class WenyouMarkdown extends StatelessWidget {
  const WenyouMarkdown({
    required this.data,
    this.diceLabels = const {},
    this.onInternalLink,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    super.key,
  });

  final String data;
  final Map<String, String> diceLabels;
  final ValueChanged<Uri>? onInternalLink;
  final double bodyFontSize;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final theme = Theme.of(context);
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: bodyFontSize,
      height: bodyHeight,
    );
    return MarkdownBody(
      data: MarkdownContent.renderDiceForDisplay(data, diceLabels),
      selectable: true,
      softLineBreak: true,
      styleSheet: baseStyle.copyWith(
        p: bodyStyle,
        a: bodyStyle?.copyWith(
          color: tokens.brand,
          decoration: TextDecoration.underline,
          decorationColor: tokens.brand,
        ),
        blockSpacing: tokens.space12,
        code: theme.textTheme.bodyMedium?.copyWith(
          color: tokens.text,
          backgroundColor: tokens.softPanel,
        ),
        codeblockPadding: EdgeInsets.all(tokens.space12),
        codeblockDecoration: BoxDecoration(
          color: tokens.softPanel,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        blockquotePadding: EdgeInsets.all(tokens.space12),
        blockquoteDecoration: BoxDecoration(
          color: tokens.softPanel,
          border: Border(left: BorderSide(color: tokens.brand, width: 3)),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        tableBorder: TableBorder.all(color: tokens.border),
        tableCellsPadding: EdgeInsets.all(tokens.space8),
      ),
      onTapLink: (_, href, _) => _openLink(href),
      imageBuilder: (uri, title, alt) =>
          _MarkdownImage(uri: uri, title: title, alt: alt),
    );
  }

  void _openLink(String? href) {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null) return;
    if (MarkdownContent.isSafeLink(uri)) {
      unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      return;
    }
    if (!uri.hasScheme && uri.path.startsWith('/')) {
      onInternalLink?.call(uri);
    }
  }
}

class _MarkdownImage extends StatelessWidget {
  const _MarkdownImage({required this.uri, this.title, this.alt});

  final Uri uri;
  final String? title;
  final String? alt;

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
    return Semantics(
      image: true,
      label: alt?.isNotEmpty == true ? alt : '正文图片',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius12),
        child: isSticker
            ? SizedBox.square(dimension: 96, child: image)
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: image,
              ),
      ),
    );
  }
}

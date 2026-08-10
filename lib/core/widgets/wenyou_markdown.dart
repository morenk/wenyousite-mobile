import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

class WenyouMarkdown extends StatelessWidget {
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
          _MarkdownImage(uri: uri, title: title, alt: alt, onSave: onSaveImage),
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

class _MarkdownImage extends StatefulWidget {
  const _MarkdownImage({required this.uri, this.title, this.alt, this.onSave});

  final Uri uri;
  final String? title;
  final String? alt;
  final Future<String> Function(Uri uri)? onSave;

  @override
  State<_MarkdownImage> createState() => _MarkdownImageState();
}

class _MarkdownImageState extends State<_MarkdownImage> {
  var _saving = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (!MarkdownContent.isSafeImage(widget.uri)) {
      return Semantics(
        label: '已阻止不安全图片${widget.alt == null ? '' : '：${widget.alt}'}',
        child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
      );
    }
    final isSticker = widget.title?.startsWith('wenyousite-sticker:') == true;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Icon(Icons.image_outlined, color: tokens.mutedText)),
    );
    final image = CachedNetworkImage(
      imageUrl: widget.uri.toString(),
      fit: BoxFit.contain,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => Semantics(
        label: '图片加载失败${widget.alt == null ? '' : '：${widget.alt}'}',
        child: fallback,
      ),
    );
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: isSticker
          ? SizedBox.square(dimension: 96, child: image)
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: image,
            ),
    );
    return Semantics(
      image: true,
      label: widget.alt?.isNotEmpty == true ? widget.alt : '正文图片',
      child: widget.onSave == null
          ? content
          : Stack(
              clipBehavior: Clip.none,
              children: [
                content,
                Positioned(
                  right: tokens.space4,
                  top: tokens.space4,
                  child: IconButton.filledTonal(
                    key: ValueKey('markdown-save-image-${widget.uri}'),
                    onPressed: _saving ? null : _save,
                    tooltip: '添加到表情收藏',
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_reaction_outlined, size: 20),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await widget.onSave!(widget.uri);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!mounted) return;
      final message = error is ApiFailure ? error.userMessage : '收藏表情失败，请稍后重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

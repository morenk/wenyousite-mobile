import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';

class WenyouMarkdownImage extends StatelessWidget {
  const WenyouMarkdownImage({
    required this.uri,
    super.key,
    this.title,
    this.display,
    this.alt,
    this.onAddToStickers,
    this.onLongPress,
    this.blockAlignment = WenyouTextAlignment.left,
  });

  final Uri uri;
  final MediaDisplay? display;
  final String? title;
  final String? alt;
  final Future<String> Function(Uri uri)? onAddToStickers;
  final VoidCallback? onLongPress;
  final WenyouTextAlignment blockAlignment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final isSticker = title?.startsWith('wenyousite-sticker:') == true;

    Widget preserveBlockImageRow(Widget child) {
      if (isSticker) return child;
      return SizedBox(
        key: ValueKey('markdown-block-image-row-$uri'),
        width: double.infinity,
        child: Align(
          alignment: switch (blockAlignment) {
            WenyouTextAlignment.left => AlignmentDirectional.centerStart,
            WenyouTextAlignment.center => Alignment.center,
            WenyouTextAlignment.right => AlignmentDirectional.centerEnd,
          },
          child: child,
        ),
      );
    }

    if (!MarkdownContent.isSafeImage(uri)) {
      return preserveBlockImageRow(
        Semantics(
          label: '已阻止不安全图片${alt == null ? '' : '：$alt'}',
          onLongPress: onLongPress,
          child: GestureDetector(
            onLongPress: onLongPress,
            child: WenyouIcon(
              WenyouIconIds.statusImageUnavailable,
              color: tokens.mutedText,
            ),
          ),
        ),
      );
    }
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
      ),
    );
    final image = WenyouCachedImage(
      imageUrl: display?.url ?? uri.toString(),
      enableRetry: display != null,
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
        container: true,
        image: true,
        label: alt?.trim().isNotEmpty == true ? alt!.trim() : '收藏表情',
        excludeSemantics: true,
        onLongPress: onLongPress,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Stack(
            alignment: Alignment.center,
            children: [
              imageContent,
              // Image render objects do not contribute text to SelectionArea.
              // Keep the reading label selectable without painting a duplicate.
              const IgnorePointer(
                child: ExcludeSemantics(
                  child: Opacity(opacity: 0, child: Text('[表情]')),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final imageAlt = alt?.trim() ?? '';
    final descriptiveAlt = imageAlt == '图片' ? '' : imageAlt;
    return preserveBlockImageRow(
      Semantics(
        button: true,
        image: true,
        label: descriptiveAlt.isEmpty ? '查看正文图片原图' : '查看正文图片原图：$descriptiveAlt',
        onLongPress: onLongPress,
        child: InkWell(
          key: ValueKey('markdown-image-$uri'),
          borderRadius: BorderRadius.circular(tokens.radius12),
          onLongPress: onLongPress,
          onTap: () => pushWenyouFullscreenPage<void>(
            context: context,
            builder: (_) => ContentImageViewerPage.single(
              url: uri.toString(),
              display: display,
              alt: imageAlt,
              onAddToStickers: onAddToStickers == null
                  ? null
                  : (_) => onAddToStickers!(uri),
            ),
          ),
          child: imageContent,
        ),
      ),
    );
  }
}

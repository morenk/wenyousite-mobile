import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

class DirectMessageOptimisticMediaPlaceholder extends StatelessWidget {
  const DirectMessageOptimisticMediaPlaceholder({
    required this.isSticker,
    super.key,
  });

  final bool isSticker;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox.square(
      dimension: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.onBrandSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: WenyouIcon(
          isSticker
              ? WenyouIconIds.actionAddReaction
              : WenyouIconIds.actionImage,
          color: tokens.onBrandSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class DirectMessageImage extends StatelessWidget {
  const DirectMessageImage({required this.media, super.key});

  final DirectMessageMedia media;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final maxDimension = media.isSticker ? 160.0 : 280.0;
    return Semantics(
      button: true,
      image: true,
      label: media.isSticker ? '私聊表情，点按查看大图' : '私聊图片，点按查看大图',
      child: InkWell(
        onTap: () => _showImage(context),
        borderRadius: BorderRadius.circular(tokens.radius12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDimension,
              maxHeight: maxDimension,
            ),
            child: WenyouCachedImage(
              imageUrl: media.displayUrl,
              fit: BoxFit.contain,
              cacheWidth: maxDimension.ceil(),
              cacheHeight: maxDimension.ceil(),
              placeholder: (_, _) => SizedBox.square(
                dimension: 96,
                child: ColoredBox(
                  color: tokens.softPanel,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
              errorWidget: (_, _, _) => SizedBox.square(
                dimension: 96,
                child: ColoredBox(
                  color: tokens.softPanel,
                  child: WenyouIcon(
                    WenyouIconIds.statusImageUnavailable,
                    color: tokens.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImage(BuildContext context) {
    return showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: WenyouCachedImage(
                    imageUrl: media.url,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => const WenyouIcon(
                      WenyouIconIds.statusImageUnavailable,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(dialogContext),
                  tooltip: '关闭大图',
                  icon: const WenyouIcon(WenyouIconIds.actionClose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

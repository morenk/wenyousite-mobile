import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

const _directMessageImageMaxDimension = 280.0;

class DirectMessagePendingImage extends StatelessWidget {
  const DirectMessagePendingImage({required this.input, super.key});

  final MediaUploadInput input;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      image: true,
      label: '正在发送的图片',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _directMessageImageMaxDimension,
            maxHeight: _directMessageImageMaxDimension,
          ),
          child: MediaUploadInputImage(
            input: input,
            key: const Key('direct-message-pending-local-image'),
            fit: BoxFit.contain,
            cacheWidth: 840,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}

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
    final maxDimension = media.isSticker
        ? WenyouImageContract.stickerDisplayMax
        : _directMessageImageMaxDimension;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final geometry = _DirectMessageImageGeometry.resolve(
                  media: media,
                  constraints: constraints,
                  maxDimension: maxDimension,
                );
                final image = WenyouCachedImage(
                  imageUrl: media.displayUrl,
                  fallbackImageUrls: media.displayUrls
                      .skip(1)
                      .toList(growable: false),
                  width: geometry.size?.width,
                  height: geometry.size?.height,
                  fit: BoxFit.contain,
                  cacheWidth: geometry.cacheWidth,
                  cacheHeight: geometry.cacheHeight,
                  placeholder: (_, _) => _DirectMessageImageState(
                    size: geometry.size,
                    loading: true,
                  ),
                  errorWidget: (_, _, _) => _DirectMessageImageState(
                    size: geometry.size,
                    loading: false,
                  ),
                );
                final size = geometry.size;
                if (size == null) return image;
                return SizedBox.fromSize(
                  key: ValueKey('direct-message-image-frame-${media.id}'),
                  size: size,
                  child: image,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImage(BuildContext context) async {
    await pushWenyouFullscreenPage<void>(
      context: context,
      builder: (_) => ContentImageViewerPage(
        url: media.url,
        alt: media.isSticker ? '私聊表情' : '私聊图片',
      ),
    );
  }
}

class _DirectMessageImageGeometry {
  const _DirectMessageImageGeometry({
    required this.size,
    required this.cacheWidth,
    required this.cacheHeight,
  });

  factory _DirectMessageImageGeometry.resolve({
    required DirectMessageMedia media,
    required BoxConstraints constraints,
    required double maxDimension,
  }) {
    final maxWidth = constraints.hasBoundedWidth
        ? math.min(constraints.maxWidth, maxDimension)
        : maxDimension;
    final maxHeight = constraints.hasBoundedHeight
        ? math.min(constraints.maxHeight, maxDimension)
        : maxDimension;
    final width = media.width;
    final height = media.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return _DirectMessageImageGeometry(
        size: null,
        cacheWidth: maxWidth.ceil(),
        cacheHeight: null,
      );
    }

    final source = Size(width.toDouble(), height.toDouble());
    final destination = applyBoxFit(
      BoxFit.contain,
      source,
      Size(maxWidth, maxHeight),
    ).destination;
    final widthLimited = source.aspectRatio >= maxWidth / maxHeight;
    return _DirectMessageImageGeometry(
      size: destination,
      cacheWidth: widthLimited ? destination.width.ceil() : null,
      cacheHeight: widthLimited ? null : destination.height.ceil(),
    );
  }

  final Size? size;
  final int? cacheWidth;
  final int? cacheHeight;
}

class _DirectMessageImageState extends StatelessWidget {
  const _DirectMessageImageState({required this.size, required this.loading});

  final Size? size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final content = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : WenyouIcon(
                WenyouIconIds.statusImageUnavailable,
                color: tokens.mutedText,
              ),
      ),
    );
    final reservedSize = size;
    if (reservedSize == null) {
      return SizedBox.square(dimension: 96, child: content);
    }
    return SizedBox.fromSize(size: reservedSize, child: content);
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cached network image tuned for scrollable content.
///
/// The package defaults cross-fade every decoded image for up to one second.
/// That forces extra compositing exactly while a list is moving. Wenyou lists
/// render the cached frame immediately and decode only to the requested size.
class WenyouCachedImage extends StatelessWidget {
  const WenyouCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.useOldImageOnUrlChange = false,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool useOldImageOnUrlChange;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
      errorWidget: errorWidget,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      memCacheWidth: _physicalPixels(cacheWidth, devicePixelRatio),
      memCacheHeight: _physicalPixels(cacheHeight, devicePixelRatio),
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      filterQuality: FilterQuality.low,
    );
  }

  int? _physicalPixels(int? logicalPixels, double devicePixelRatio) {
    if (logicalPixels == null) return null;
    return (logicalPixels * devicePixelRatio).round().clamp(1, 4096);
  }

  static Future<bool> evictFromCache(String imageUrl) {
    return CachedNetworkImage.evictFromCache(imageUrl);
  }
}

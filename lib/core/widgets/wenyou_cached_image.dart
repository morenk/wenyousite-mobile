import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Cached network image tuned for scrollable content.
///
/// The package defaults cross-fade every decoded image for up to one second.
/// That forces extra compositing exactly while a list is moving. Wenyou lists
/// render the cached frame immediately and decode only to the requested size.
class WenyouCachedImage extends StatefulWidget {
  const WenyouCachedImage({
    required this.imageUrl,
    this.fallbackImageUrls = const [],
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
  final List<String> fallbackImageUrls;
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
  State<WenyouCachedImage> createState() => _WenyouCachedImageState();

  static Future<bool> evictFromCache(String imageUrl) {
    return CachedNetworkImage.evictFromCache(imageUrl);
  }
}

class _WenyouCachedImageState extends State<WenyouCachedImage> {
  var _index = 0;
  var _advanceScheduled = false;
  var _generation = 0;

  @override
  void didUpdateWidget(covariant WenyouCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        !listEquals(oldWidget.fallbackImageUrls, widget.fallbackImageUrls)) {
      _index = 0;
      _advanceScheduled = false;
      _generation += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    final safeIndex = _index.clamp(0, urls.length - 1);
    final imageUrl = urls[safeIndex];
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      key: ValueKey(imageUrl),
      imageUrl: imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      placeholder: widget.placeholder,
      errorWidget: (context, failedUrl, error) {
        if (safeIndex + 1 < urls.length) {
          _scheduleAdvance(safeIndex);
          return widget.placeholder?.call(context, failedUrl) ??
              const SizedBox.shrink();
        }
        return widget.errorWidget?.call(context, failedUrl, error) ??
            const SizedBox.shrink();
      },
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      memCacheWidth: _physicalPixels(widget.cacheWidth, devicePixelRatio),
      memCacheHeight: _physicalPixels(widget.cacheHeight, devicePixelRatio),
      useOldImageOnUrlChange: widget.useOldImageOnUrlChange,
      filterQuality: FilterQuality.low,
    );
  }

  List<String> get _urls {
    final result = <String>[];
    for (final value in [widget.imageUrl, ...widget.fallbackImageUrls]) {
      final normalized = value.trim();
      if (normalized.isNotEmpty && !result.contains(normalized)) {
        result.add(normalized);
      }
    }
    return result.isEmpty ? const ['about:blank'] : result;
  }

  void _scheduleAdvance(int failedIndex) {
    if (_advanceScheduled) return;
    _advanceScheduled = true;
    final generation = _generation;
    scheduleMicrotask(() {
      _advanceScheduled = false;
      if (!mounted || _generation != generation || _index != failedIndex) {
        return;
      }
      setState(() => _index = failedIndex + 1);
    });
  }

  int? _physicalPixels(int? logicalPixels, double devicePixelRatio) {
    if (logicalPixels == null) return null;
    return (logicalPixels * devicePixelRatio).round().clamp(1, 4096);
  }
}

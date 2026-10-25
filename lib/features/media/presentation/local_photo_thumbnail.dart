import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_ring.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';

class LocalPhotoThumbnail extends StatefulWidget {
  const LocalPhotoThumbnail({
    required this.library,
    required this.photo,
    this.size = 240,
    this.fit = BoxFit.cover,
    super.key,
  });
  final PhotoLibrary library;
  final LocalPhoto photo;
  final int size;
  final BoxFit fit;

  @override
  State<LocalPhotoThumbnail> createState() => _LocalPhotoThumbnailState();
}

class _LocalPhotoThumbnailState extends State<LocalPhotoThumbnail> {
  late Future<Uint8List?> _image = _load();
  Future<Uint8List?> _load() => widget.library.thumbnail(
    widget.photo,
    size: widget.size,
    preserveAspect: widget.fit == BoxFit.contain,
  );
  @override
  void didUpdateWidget(LocalPhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.id != widget.photo.id ||
        oldWidget.library != widget.library ||
        oldWidget.size != widget.size ||
        oldWidget.fit != widget.fit) {
      _image = _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _image,
    builder: (context, snapshot) {
      final data = snapshot.data;
      if (data != null) {
        return Image.memory(
          data,
          fit: widget.fit,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) => _retry(context),
        );
      }
      return ColoredBox(
        color: context.wenyouTokens.softPanel,
        child: snapshot.connectionState == ConnectionState.waiting
            ? const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: WenyouProgressRing(),
                ),
              )
            : _retry(context),
      );
    },
  );

  Widget _retry(BuildContext context) => ColoredBox(
    color: context.wenyouTokens.softPanel,
    child: Center(
      child: IconButton(
        tooltip: '图片加载失败，重试',
        onPressed: () => setState(() {
          _image = _load();
        }),
        icon: const WenyouIcon(WenyouIconIds.actionRefresh),
      ),
    ),
  );
}

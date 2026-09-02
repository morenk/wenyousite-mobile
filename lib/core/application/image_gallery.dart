import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageGallerySource {
  const ImageGallerySource({required this.url, this.fallbackUrls = const []});

  final String url;
  final List<String> fallbackUrls;
}

class ImageGalleryException implements Exception {
  const ImageGalleryException({
    required this.userMessage,
    this.settingsRequired = false,
  });

  final String userMessage;
  final bool settingsRequired;

  @override
  String toString() => userMessage;
}

class ImageGallerySaveOperation {
  const ImageGallerySaveOperation({required this.result, required this.cancel});

  final Future<void> result;
  final void Function() cancel;
}

abstract interface class ImageGalleryService {
  bool get isSupported;

  ImageGallerySaveOperation startSave(ImageGallerySource source);

  Future<void> openSettings();
}

final imageGalleryServiceProvider = Provider<ImageGalleryService>(
  (ref) => const _UnsupportedImageGalleryService(),
);

class _UnsupportedImageGalleryService implements ImageGalleryService {
  const _UnsupportedImageGalleryService();

  @override
  bool get isSupported => false;

  @override
  Future<void> openSettings() async {}

  @override
  ImageGallerySaveOperation startSave(ImageGallerySource source) {
    return ImageGallerySaveOperation(
      result: Future.error(
        const ImageGalleryException(userMessage: '当前设备暂不支持保存图片。'),
      ),
      cancel: () {},
    );
  }
}

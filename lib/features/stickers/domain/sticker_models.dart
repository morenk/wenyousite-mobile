enum StickerImportStatus { processing, completed, failed }

class StickerAsset {
  const StickerAsset({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
  });

  final String id;
  final String url;
  final String thumbnailUrl;
  final int width;
  final int height;
  final bool animated;
  final int frameCount;
  final int durationMs;
}

class UserSticker {
  const UserSticker({
    required this.id,
    required this.position,
    required this.asset,
    required this.markdown,
    this.lastUsedAt,
  });

  final String id;
  final int position;
  final DateTime? lastUsedAt;
  final StickerAsset asset;
  final String markdown;
}

class StickerImport {
  const StickerImport({
    required this.id,
    required this.status,
    required this.alreadySaved,
    this.favorite,
    this.failureCode,
  });

  final String id;
  final StickerImportStatus status;
  final UserSticker? favorite;
  final String? failureCode;
  final bool alreadySaved;
}

class StickerCollection {
  const StickerCollection({
    required this.version,
    required this.limit,
    required this.items,
    required this.recent,
    required this.pendingImports,
  });

  final int version;
  final int limit;
  final List<UserSticker> items;
  final List<UserSticker> recent;
  final List<StickerImport> pendingImports;

  bool get isFull => items.length + pendingImports.length >= limit;
}

sealed class StickerImportSource {
  const StickerImportSource();

  String get requestKey;
}

class StickerMediaSource extends StickerImportSource {
  const StickerMediaSource(this.mediaId);

  final String mediaId;

  @override
  String get requestKey => 'media:$mediaId';
}

class StickerDirectMessageSource extends StickerImportSource {
  const StickerDirectMessageSource(this.directMessageId);

  final String directMessageId;

  @override
  String get requestKey => 'direct:$directMessageId';
}

class StickerPostImageSource extends StickerImportSource {
  const StickerPostImageSource({required this.postId, required this.imageUrl});

  final String postId;
  final String imageUrl;

  @override
  String get requestKey => 'post:$postId:$imageUrl';
}

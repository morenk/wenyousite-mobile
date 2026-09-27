import 'package:wenyousite_mobile/core/media/media_display.dart';

enum ReadingGalleryScope {
  subthread,
  postReplies,
  moment,
  momentComments,
  momentReplies,
}

enum ReadingGalleryOrder { oldest, newest }

class ReadingGalleryRequest {
  const ReadingGalleryRequest({
    required this.scope,
    required this.scopeId,
    required this.anchorId,
    required this.anchorVersion,
    required this.anchorIndex,
    this.order = ReadingGalleryOrder.oldest,
    this.authorId,
  });
  final ReadingGalleryScope scope;
  final String scopeId;
  final String anchorId;
  final int anchorVersion;
  final int anchorIndex;
  final ReadingGalleryOrder order;
  final String? authorId;
}

class ReadingGalleryImage {
  const ReadingGalleryImage({
    required this.id,
    required this.sourceId,
    required this.sourceVersion,
    required this.imageIndex,
    required this.imageCount,
    required this.url,
    this.display,
    this.mediaId,
    this.width,
    this.height,
    this.animated = false,
    this.threadId,
    this.subthreadId,
    this.parentPostId,
    this.momentId,
    this.parentCommentId,
    this.floorNumber,
    this.previewUrls = const [],
  });
  final String id;
  final String sourceId;
  final int sourceVersion;
  final int imageIndex;
  final int imageCount;
  final String url;
  final MediaDisplay? display;
  final String? mediaId;
  final int? width;
  final int? height;
  final bool animated;
  final String? threadId;
  final String? subthreadId;
  final String? parentPostId;
  final String? momentId;
  final String? parentCommentId;
  final int? floorNumber;
  final List<String> previewUrls;
  Object get occurrenceKey => (sourceId, sourceVersion, imageIndex);

  bool sameOccurrence(ReadingGalleryImage other) =>
      sourceId == other.sourceId &&
      sourceVersion == other.sourceVersion &&
      imageIndex == other.imageIndex;
}

class ReadingGalleryPage {
  const ReadingGalleryPage({
    required this.items,
    this.previousCursor,
    this.nextCursor,
    this.anchorItemId,
  });
  final List<ReadingGalleryImage> items;
  final String? previousCursor;
  final String? nextCursor;
  final String? anchorItemId;
}

abstract interface class ReadingGalleryOperation {
  Future<ReadingGalleryPage> get result;
  void cancel();
}

abstract interface class ReadingGalleryRepository {
  ReadingGalleryOperation load(ReadingGalleryRequest request, {String? cursor});
}

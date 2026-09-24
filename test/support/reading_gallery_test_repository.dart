import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

class ReadingGalleryTestRepository implements ReadingGalleryRepository {
  ReadingGalleryTestRepository(this.imagesFor);
  final List<ReadingGalleryImage> Function(ReadingGalleryRequest) imagesFor;
  final requests = <ReadingGalleryRequest>[];

  @override
  ReadingGalleryOperation load(
    ReadingGalleryRequest request, {
    String? cursor,
  }) {
    if (cursor != null) throw StateError('固定测试图集没有续页游标');
    requests.add(request);
    final images = imagesFor(request);
    final anchor = images.singleWhere(
      (image) =>
          image.sourceId == request.anchorId &&
          image.sourceVersion == request.anchorVersion &&
          image.imageIndex == request.anchorIndex,
    );
    return _Operation(
      ReadingGalleryPage(items: images, anchorItemId: anchor.id),
    );
  }
}

List<ReadingGalleryImage> momentGalleryTestImages(
  String momentId,
  List<MomentMedia> media, {
  int version = 1,
}) => [
  for (var index = 0; index < media.length; index++)
    ReadingGalleryImage(
      id: 'moment:$momentId:$version:$index',
      sourceId: momentId,
      sourceVersion: version,
      imageIndex: index,
      imageCount: media.length,
      url: media[index].url,
      mediaId: media[index].id,
      display: media[index].display,
      width: media[index].width,
      height: media[index].height,
      animated: media[index].isAnimated,
      momentId: momentId,
    ),
];

class _Operation implements ReadingGalleryOperation {
  _Operation(ReadingGalleryPage page) : result = Future.value(page);
  @override
  final Future<ReadingGalleryPage> result;
  @override
  void cancel() {}
}

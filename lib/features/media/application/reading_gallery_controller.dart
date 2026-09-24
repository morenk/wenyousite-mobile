import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

final readingGalleryRepositoryProvider = Provider<ReadingGalleryRepository>(
  (ref) =>
      throw UnimplementedError('ReadingGalleryRepository must be provided'),
);

enum ReadingGalleryDirection { previous, next }

/// 图集有独立游标，不推进正文列表，不把新回复插入正在阅读的序列。
class ReadingGalleryController extends ChangeNotifier {
  ReadingGalleryController({
    required this.repository,
    required this.request,
    required ReadingGalleryImage initialImage,
    List<ReadingGalleryImage>? initialImages,
  }) : images = initialImages ?? [initialImage],
       _initialImage = initialImage,
       currentId = initialImage.id;
  final ReadingGalleryImage _initialImage;
  final ReadingGalleryRepository repository;
  final ReadingGalleryRequest request;
  List<ReadingGalleryImage> images;
  String currentId;
  String? previousCursor;
  String? nextCursor;
  Object? failure;
  ReadingGalleryDirection? failedDirection;
  bool initialized = false;
  bool unavailable = false;
  bool needsReload = false;
  final _operations = <ReadingGalleryDirection?, ReadingGalleryOperation>{};
  int _generation = 0;
  bool _disposed = false;

  bool get loading => _operations.isNotEmpty;
  int get currentIndex => images.indexWhere((image) => image.id == currentId);
  ReadingGalleryImage? get current =>
      currentIndex < 0 ? null : images[currentIndex];

  Future<void> start() => _load(null);

  Future<void> loadMore(ReadingGalleryDirection direction) => _load(direction);

  void select(int index) {
    if (_disposed || index < 0 || index >= images.length) return;
    currentId = images[index].id;
    notifyListeners();
  }

  Future<void> retry() => _load(failedDirection);

  Future<void> _load(ReadingGalleryDirection? direction) async {
    if (_disposed ||
        unavailable ||
        needsReload ||
        _operations.containsKey(direction)) {
      return;
    }
    final cursor = direction == ReadingGalleryDirection.previous
        ? previousCursor
        : nextCursor;
    if (direction != null && (!initialized || cursor == null)) return;
    final generation = _generation;
    final operation = repository.load(
      request,
      cursor: direction == null ? null : cursor,
    );
    _operations[direction] = operation;
    failure = null;
    failedDirection = null;
    notifyListeners();
    try {
      final page = await operation.result;
      if (_disposed || generation != _generation) return;
      if (direction == null) {
        final old = current!;
        final anchor = page.items
            .where((item) => item.id == page.anchorItemId)
            .firstOrNull;
        if (anchor == null ||
            !anchor.sameOccurrence(_initialImage) ||
            Uri.parse(anchor.url).toString() !=
                Uri.parse(_initialImage.url).toString()) {
          needsReload = true;
          return;
        }
        images = List.unmodifiable(page.items);
        currentId =
            page.items
                .where((image) => image.sameOccurrence(old))
                .firstOrNull
                ?.id ??
            anchor.id;
        previousCursor = page.previousCursor;
        nextCursor = page.nextCursor;
        initialized = true;
      } else {
        final ids = images.map((image) => image.id).toSet();
        final incoming = page.items
            .where((image) => ids.add(image.id))
            .toList();
        if (direction == ReadingGalleryDirection.previous) {
          images = List.unmodifiable([...incoming, ...images]);
          previousCursor = page.previousCursor;
        } else {
          images = List.unmodifiable([...images, ...incoming]);
          nextCursor = page.nextCursor;
        }
      }
    } on Object catch (error) {
      if (_disposed || generation != _generation) return;
      if (error is ApiFailure &&
          (error.httpStatus == 401 ||
              error.httpStatus == 403 ||
              error.httpStatus == 404)) {
        invalidate();
      } else {
        failure = error;
        failedDirection = direction;
        needsReload =
            error is ApiFailure &&
            ((error.httpStatus == 409 && error.businessCode != 40926) ||
                error.businessCode == 40007);
        if (needsReload) {
          _generation++;
          for (final pending in _operations.values) {
            pending.cancel();
          }
          _operations.clear();
          notifyListeners();
        }
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _operations.remove(direction);
        notifyListeners();
      }
    }
  }

  void invalidate() {
    _generation++;
    for (final operation in _operations.values) {
      operation.cancel();
    }
    _operations.clear();
    images = const [];
    unavailable = true;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    invalidate();
    super.dispose();
  }
}

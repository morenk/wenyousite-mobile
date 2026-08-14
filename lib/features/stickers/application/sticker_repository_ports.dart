import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

abstract interface class StickerRepository {
  Future<StickerCollection> fetchCollection();

  Future<StickerImport> fetchImport(String id);

  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  });

  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  });

  Future<StickerCollection> remove(String favoriteId);
}

final stickerRepositoryProvider = Provider<StickerRepository>((ref) {
  return const _UnboundStickerRepository();
});

class _UnboundStickerRepository implements StickerRepository {
  const _UnboundStickerRepository();

  @override
  Future<StickerCollection> fetchCollection() => Future.error(_error());

  @override
  Future<StickerImport> fetchImport(String id) => Future.error(_error());

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) => Future.error(_error());

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => Future.error(_error());

  @override
  Future<StickerCollection> remove(String favoriteId) {
    return Future.error(_error());
  }
}

StateError _error() => StateError('收藏表情仓储尚未在应用组合根绑定。');

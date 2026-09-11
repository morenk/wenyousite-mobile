import 'dart:async';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

List<String> ids(StickerCollectionController controller) =>
    controller.state.collection!.items.map((item) => item.id).toList();

List<UserSticker> stickers(List<String> ids) => [
  for (final (position, id) in ids.indexed)
    UserSticker(
      id: id,
      position: position,
      asset: StickerAsset(
        id: 'asset-$id',
        url: 'https://cdn.example.com/$id.webp',
        thumbnailUrl: 'https://cdn.example.com/$id-thumb.webp',
        width: 96,
        height: 96,
        animated: false,
        frameCount: 1,
        durationMs: 0,
      ),
      markdown: '![表情](https://cdn.example.com/$id.webp)',
    ),
];

StickerCollection stickerCollection({
  List<String> order = const ['a', 'b', 'c'],
  int version = 3,
}) => StickerCollection(
  version: version,
  limit: 200,
  items: stickers(order),
  recent: const [],
  pendingImports: const [],
);

class ReorderTestRepository implements StickerRepository {
  StickerCollection current = stickerCollection();
  Completer<StickerCollection>? nextRead;
  int reads = 0;
  final writes =
      <
        ({int version, List<String> ids, Completer<StickerCollection> result})
      >[];

  @override
  Future<StickerCollection> fetchCollection() async {
    reads++;
    return nextRead?.future ?? Future.value(current);
  }

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) {
    final result = Completer<StickerCollection>();
    writes.add((version: version, ids: favoriteIds, result: result));
    return result.future;
  }

  void complete(int index) {
    final request = writes[index];
    current = stickerCollection(
      order: request.ids,
      version: request.version + 1,
    );
    request.result.complete(current);
  }

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();
  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) => throw UnimplementedError();
  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();
}

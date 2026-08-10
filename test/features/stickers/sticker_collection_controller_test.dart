import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const StickerMediaSource('media-1'));
  });

  test('处理中的导入会查询状态，并在完成后刷新收藏夹', () async {
    final repository = _MockStickerRepository();
    var collectionReads = 0;
    when(repository.fetchCollection).thenAnswer((_) async {
      collectionReads += 1;
      return collectionReads == 1
          ? _collection(
              pending: const [
                StickerImport(
                  id: 'import-1',
                  status: StickerImportStatus.processing,
                  alreadySaved: false,
                ),
              ],
            )
          : _collection(items: [_sticker()]);
    });
    when(
      () => repository.fetchImport('import-1'),
    ).thenAnswer((_) async => _completedImport());
    final controller = StickerCollectionController(
      repository,
      pollInterval: const Duration(milliseconds: 2),
    );
    addTearDown(controller.dispose);

    await untilCalled(repository.fetchCollection);
    await _waitFor(
      () => controller.state.collection?.items.isNotEmpty ?? false,
    );

    verify(() => repository.fetchImport('import-1')).called(1);
    expect(controller.state.collection?.pendingImports, isEmpty);
    expect(controller.state.successMessage, '表情处理完成，已加入收藏。');
  });

  test('不明确失败保留同一幂等键，显式重试后刷新收藏', () async {
    final repository = _MockStickerRepository();
    final requestIds = <String>[];
    var imports = 0;
    when(
      () => repository.importSource(
        any(),
        clientRequestId: any(named: 'clientRequestId'),
      ),
    ).thenAnswer((invocation) async {
      requestIds.add(invocation.namedArguments[#clientRequestId] as String);
      imports += 1;
      if (imports == 1) {
        throw const ApiFailure(userMessage: '网络中断');
      }
      return _completedImport();
    });
    when(
      repository.fetchCollection,
    ).thenAnswer((_) async => _collection(items: [_sticker()]));
    final controller = StickerCollectionController(
      repository,
      autoStart: false,
      requestIdFactory: () => 'stable-request-id',
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);

    final first = await controller.importMedia('media-1');
    final second = await controller.retryImport();

    expect(first, isNull);
    expect(second?.status, StickerImportStatus.completed);
    expect(requestIds, ['stable-request-id', 'stable-request-id']);
    expect(controller.state.retrySource, isNull);
    expect(controller.state.collection?.items.single.id, 'favorite-1');
  });

  test('排序只接受完整收藏集合，成功后采用服务端版本', () async {
    final repository = _MockStickerRepository();
    final initial = _collection(
      items: [
        _sticker(),
        _sticker(id: 'favorite-2'),
      ],
    );
    when(repository.fetchCollection).thenAnswer((_) async => initial);
    when(
      () => repository.reorder(
        version: 3,
        favoriteIds: const ['favorite-2', 'favorite-1'],
      ),
    ).thenAnswer(
      (_) async => _collection(
        version: 4,
        items: [
          _sticker(id: 'favorite-2'),
          _sticker(position: 1),
        ],
      ),
    );
    final controller = StickerCollectionController(
      repository,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await _waitFor(() => controller.state.collection != null);

    final invalid = await controller.reorder([_sticker()]);
    final valid = await controller.reorder([
      _sticker(id: 'favorite-2'),
      _sticker(),
    ]);

    expect(invalid, isFalse);
    expect(valid, isTrue);
    expect(controller.state.collection?.version, 4);
    verify(
      () => repository.reorder(
        version: 3,
        favoriteIds: const ['favorite-2', 'favorite-1'],
      ),
    ).called(1);
  });
}

class _MockStickerRepository extends Mock implements StickerRepository {}

StickerAsset _asset({String id = 'asset-1'}) => StickerAsset(
  id: id,
  url: 'https://cdn.example.com/$id.webp',
  thumbnailUrl: 'https://cdn.example.com/${id}_thumb.webp',
  width: 96,
  height: 96,
  animated: false,
  frameCount: 1,
  durationMs: 0,
);

UserSticker _sticker({String id = 'favorite-1', int position = 0}) =>
    UserSticker(
      id: id,
      position: position,
      asset: _asset(id: 'asset-$id'),
      markdown: '![表情](https://cdn.example.com/$id.webp)',
    );

StickerImport _completedImport() => StickerImport(
  id: 'import-1',
  status: StickerImportStatus.completed,
  favorite: _sticker(),
  alreadySaved: false,
);

StickerCollection _collection({
  int version = 3,
  List<UserSticker> items = const [],
  List<StickerImport> pending = const [],
}) => StickerCollection(
  version: version,
  limit: 200,
  items: items,
  recent: const [],
  pendingImports: pending,
);

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  throw TimeoutException('condition not reached');
}

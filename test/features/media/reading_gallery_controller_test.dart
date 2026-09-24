import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/reading_gallery_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

void main() {
  late _Repository repository;
  late ReadingGalleryController controller;
  setUp(() {
    repository = _Repository();
    controller = ReadingGalleryController(
      repository: repository,
      request: _request,
      initialImage: _image('clicked', 2),
    );
  });
  tearDown(() => controller.dispose());

  Future<void> initialize() async {
    final pending = controller.start();
    repository.operations.last.complete(
      ReadingGalleryPage(
        items: [_image('middle', 2)],
        anchorItemId: 'middle',
        previousCursor: 'opaque-before',
        nextCursor: 'opaque-after',
      ),
    );
    await pending;
  }

  test('点击后立即保留本地图，首次成功原位确认稳定身份', () async {
    expect(controller.current!.url, _url);
    final pending = controller.start();
    expect(controller.currentId, 'clicked');
    expect(controller.loading, isTrue);
    repository.operations.single.complete(
      ReadingGalleryPage(
        items: [_image('before', 1), _image('middle', 2)],
        anchorItemId: 'middle',
      ),
    );
    await pending;
    expect(controller.currentId, 'middle');
    expect(controller.currentIndex, 1);
    expect(controller.initialized, isTrue);
    expect(controller.loading, isFalse);
  });

  test('双向请求乱序完成仍保留当前图、重复URL位置及固定筛选', () async {
    await initialize();
    final before = controller.loadMore(ReadingGalleryDirection.previous);
    final after = controller.loadMore(ReadingGalleryDirection.next);
    expect(repository.cursors, [null, 'opaque-before', 'opaque-after']);
    expect(
      repository.requests.every((request) => identical(request, _request)),
      isTrue,
    );
    repository.operations[2].complete(
      ReadingGalleryPage(items: [_image('last', 3)]),
    );
    await after;
    controller.select(1);
    repository.operations[1].complete(
      ReadingGalleryPage(items: [_image('first', 1), _image('middle', 2)]),
    );
    await before;
    expect(controller.images.map((image) => image.id), [
      'first',
      'middle',
      'last',
    ]);
    expect(controller.images.map((image) => image.url).toSet(), {_url});
    expect(controller.currentId, 'last');
    expect(controller.currentIndex, 2);
    expect(controller.previousCursor, isNull);
    expect(controller.nextCursor, isNull);
  });

  test('同方向在途不重复请求，网络重试复用游标且不重置当前图', () async {
    await initialize();
    final pending = controller.loadMore(ReadingGalleryDirection.next);
    await controller.loadMore(ReadingGalleryDirection.next);
    expect(repository.operations.length, 2);
    repository.operations.last.fail(const ApiFailure(httpStatus: 503));
    await pending;
    expect(controller.currentId, 'middle');
    expect(controller.needsReload, isFalse);
    final retry = controller.retry();
    expect(repository.cursors.last, 'opaque-after');
    repository.operations.last.complete(
      ReadingGalleryPage(items: [_image('last', 3)]),
    );
    await retry;
    expect(controller.failure, isNull);
    expect(controller.currentId, 'middle');
    expect(controller.images.length, 2);
  });

  for (final status in [401, 403, 404]) {
    test('$status 清除当前图，取消另一方向且忽略迟到响应', () async {
      await initialize();
      final before = controller.loadMore(ReadingGalleryDirection.previous);
      final after = controller.loadMore(ReadingGalleryDirection.next);
      repository.operations[1].fail(ApiFailure(httpStatus: status));
      await before;
      expect(controller.unavailable, isTrue);
      expect(controller.images, isEmpty);
      expect(repository.operations[2].cancelled, isTrue);
      repository.operations[2].complete(
        ReadingGalleryPage(items: [_image('late', 3)]),
      );
      await after;
      expect(controller.images, isEmpty);
      await controller.retry();
      expect(repository.operations.length, 3);
    });
  }

  test('切换账号显式失效后，首次响应也不能恢复旧图', () async {
    final pending = controller.start();
    controller.invalidate();
    repository.operations.single.complete(
      ReadingGalleryPage(items: [_image('middle', 2)], anchorItemId: 'middle'),
    );
    await pending;
    expect(repository.operations.single.cancelled, isTrue);
    expect(controller.images, isEmpty);
    expect(controller.initialized, isFalse);
  });

  test('相同位置的新URL不能冒充原来点击的图', () async {
    final pending = controller.start();
    repository.operations.single.complete(
      ReadingGalleryPage(
        items: [_image('replacement', 2, url: 'https://example.test/new.png')],
        anchorItemId: 'replacement',
      ),
    );
    await pending;
    expect(controller.needsReload, isTrue);
    expect(controller.currentId, 'clicked');
    expect(controller.initialized, isFalse);
  });

  test('历史索引未就绪可以重试，不能标为已初始化的完整图集', () async {
    final pending = controller.start();
    repository.operations.single.fail(
      const ApiFailure(httpStatus: 409, businessCode: 40926),
    );
    await pending;
    expect(controller.needsReload, isFalse);
    expect(controller.initialized, isFalse);
    expect(controller.currentId, 'clicked');
    final retry = controller.retry();
    repository.operations.last.complete(
      ReadingGalleryPage(items: [_image('middle', 2)], anchorItemId: 'middle'),
    );
    await retry;
    expect(controller.initialized, isTrue);
  });

  test('图片版本冲突中断整个会话，另一方向迟到结果不能混入', () async {
    await initialize();
    final before = controller.loadMore(ReadingGalleryDirection.previous);
    final after = controller.loadMore(ReadingGalleryDirection.next);
    repository.operations[1].fail(const ApiFailure(httpStatus: 409));
    await before;
    expect(controller.needsReload, isTrue);
    repository.operations[2].complete(
      ReadingGalleryPage(items: [_image('late', 3)]),
    );
    await after;
    expect(controller.images.map((image) => image.id), ['middle']);
    expect(repository.operations[2].cancelled, isTrue);
  });

  test('本地动态组在首次校验期间切图，校验完成仍停留用户选择', () async {
    controller.dispose();
    controller = ReadingGalleryController(
      repository: repository,
      request: _request,
      initialImage: _image('local-middle', 2),
      initialImages: [_image('local-middle', 2), _image('local-last', 3)],
    );
    final pending = controller.start();
    controller.select(1);
    repository.operations.single.complete(
      ReadingGalleryPage(
        items: [_image('middle', 2), _image('last', 3)],
        anchorItemId: 'middle',
      ),
    );
    await pending;
    expect(controller.currentId, 'last');
    expect(controller.currentIndex, 1);
  });
}

const _url = 'https://example.test/repeated.png';
const _request = ReadingGalleryRequest(
  scope: ReadingGalleryScope.subthread,
  scopeId: 'subthread',
  anchorId: 'post',
  anchorVersion: 7,
  anchorIndex: 2,
  order: ReadingGalleryOrder.newest,
  authorId: 'author',
);

ReadingGalleryImage _image(String id, int index, {String url = _url}) =>
    ReadingGalleryImage(
      id: id,
      sourceId: 'post',
      sourceVersion: 7,
      imageIndex: index,
      imageCount: 4,
      url: url,
    );

class _Repository implements ReadingGalleryRepository {
  final requests = <ReadingGalleryRequest>[];
  final cursors = <String?>[];
  final operations = <_Operation>[];

  @override
  ReadingGalleryOperation load(
    ReadingGalleryRequest request, {
    String? cursor,
  }) {
    requests.add(request);
    cursors.add(cursor);
    final operation = _Operation();
    operations.add(operation);
    return operation;
  }
}

class _Operation implements ReadingGalleryOperation {
  final _result = Completer<ReadingGalleryPage>();
  bool cancelled = false;
  @override
  Future<ReadingGalleryPage> get result => _result.future;
  void complete(ReadingGalleryPage page) => _result.complete(page);
  void fail(Object error) => _result.completeError(error);
  @override
  void cancel() => cancelled = true;
}

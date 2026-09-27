import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/reading_gallery_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

void main() {
  late Dio dio;
  late ApiReadingGalleryRepository repository;
  final seen = <RequestOptions>[];
  var response = <String, Object?>{};
  setUp(() {
    seen.clear();
    response = _page([_image()]);
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          seen.add(request);
          handler.resolve(
            Response<Object>(
              requestOptions: request,
              data: response,
              statusCode: 200,
            ),
          );
        },
      ),
    );
    repository = ApiReadingGalleryRepository(
      WenyouApi(dio: dio, interceptors: const []).getImageGalleryApi(),
    );
  });
  tearDown(() => dio.close(force: true));

  const request = ReadingGalleryRequest(
    scope: ReadingGalleryScope.subthread,
    scopeId: 'subthread',
    anchorId: 'post',
    anchorVersion: 4,
    anchorIndex: 1,
    order: ReadingGalleryOrder.newest,
    authorId: 'author',
  );

  test('初始GET携带点击位置、阅读排序及作者，后续只透传不透明游标', () async {
    final page = await repository.load(request).result;
    expect(page.items.single.sourceVersion, 4);
    expect(seen.single.method, 'GET');
    expect(seen.single.path, '/api/v1/image-gallery');
    expect(seen.single.queryParameters, containsPair('scope', 'SUBTHREAD'));
    expect(seen.single.queryParameters, containsPair('anchorIndex', 1));
    expect(seen.single.queryParameters, containsPair('anchorVersion', 4));
    expect(seen.single.queryParameters, containsPair('order', 'NEWEST'));
    expect(seen.single.queryParameters, containsPair('authorId', 'author'));
    await repository.load(request, cursor: 'opaque:+/token').result;
    expect(seen.last.queryParameters, containsPair('cursor', 'opaque:+/token'));
    expect(seen.last.queryParameters.containsKey('anchorId'), false);
    expect(seen.last.queryParameters.containsKey('anchorIndex'), false);
    expect(seen.last.queryParameters.containsKey('anchorVersion'), false);
  });

  test('同URL不同出现位置保留，重复身份拒绝', () async {
    response = _page([
      _image(),
      {..._image(), 'id': 'second', 'imageIndex': 0},
    ]);
    expect((await repository.load(request).result).items, hasLength(2));
    response = _page([_image(), _image()]);
    await expectLater(
      repository.load(request).result,
      throwsA(isA<ApiFailure>()),
    );
  });

  test('不接受越界位置、未发布路径、不安全地址及丢失定位身份', () async {
    for (final override in [
      {'imageIndex': 2},
      {'sourceVersion': 1.5},
      {'url': 'https://local.invalid/pending/a'},
      {'url': 'https://name:secret@example.test/image'},
      {'threadId': null},
    ]) {
      response = _page([
        {..._image(), ...override},
      ]);
      await expectLater(
        repository.load(request).result,
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('评论保留mediaId与父评论，缺失收藏身份拒绝', () async {
    const commentRequest = ReadingGalleryRequest(
      scope: ReadingGalleryScope.momentReplies,
      scopeId: 'root-comment',
      anchorId: 'reply',
      anchorVersion: 1,
      anchorIndex: 0,
    );
    response = _page([
      {
        ..._image(),
        'sourceId': 'reply',
        'sourceVersion': 1,
        'imageIndex': 0,
        'imageCount': 1,
        'threadId': null,
        'subthreadId': null,
        'momentId': 'moment',
        'parentCommentId': 'root-comment',
        'mediaId': 'comment-media',
      },
    ]);
    final image = (await repository.load(commentRequest).result).items.single;
    expect(image.parentCommentId, 'root-comment');
    expect(image.mediaId, 'comment-media');
    response = _page([
      {..._image(), 'momentId': 'moment', 'parentCommentId': 'root-comment'},
    ]);
    await expectLater(
      repository.load(commentRequest).result,
      throwsA(isA<ApiFailure>()),
    );
  });

  test('取消句柄取消真实Dio令牌', () async {
    final operation = repository.load(request);
    operation.cancel();
    await expectLater(operation.result, throwsA(isA<ApiFailure>()));
  });
}

Map<String, Object?> _image() => {
  'id': 'post-occurrence',
  'sourceId': 'post',
  'sourceVersion': 4,
  'imageIndex': 1,
  'imageCount': 2,
  'mediaId': null,
  'url': 'https://example.test/image.png',
  'display': null,
  'width': null,
  'height': null,
  'animated': false,
  'threadId': 'thread',
  'subthreadId': 'subthread',
  'parentPostId': null,
  'momentId': null,
  'parentCommentId': null,
  'floorNumber': 12,
};

Map<String, Object?> _page(List<Map<String, Object?>> items) => {
  'code': 0,
  'message': 'OK',
  'data': {
    'items': items,
    'previousCursor': null,
    'nextCursor': 'opaque-next',
    'anchorItemId': 'post-occurrence',
  },
};

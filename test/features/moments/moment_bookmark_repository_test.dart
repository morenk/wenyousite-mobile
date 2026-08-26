import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_bookmark_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

void main() {
  test('动态收藏夹查询与创建使用独立接口和动态计数', () async {
    final api = _MockMomentsApi();
    final moments = _MockMomentRepository();
    final repository = ApiMomentBookmarkRepository(api, moments);
    when(() => api.momentsBookmarkFolders()).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/bookmark-folders',
        MomentsBookmarkFolders200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.add(_folderDto('moment-default', '默认收藏夹', count: 3)),
        ),
      ),
    );
    final createBody = CreateMomentBookmarkFolderDto(
      (builder) => builder.name = '灵感',
    );
    when(
      () => api.momentsCreateBookmarkFolder(
        createMomentBookmarkFolderDto: createBody,
      ),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/bookmark-folders',
        MomentsCreateBookmarkFolder201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_folderDto('moment-custom', '灵感')),
        ),
      ),
    );

    final folders = await repository.fetchFolders();
    final created = await repository.createFolder('  灵感  ');

    expect(folders.single.id, 'moment-default');
    expect(folders.single.bookmarkCount, 3);
    expect(created.id, 'moment-custom');
    verify(() => api.momentsBookmarkFolders()).called(1);
    verify(
      () => api.momentsCreateBookmarkFolder(
        createMomentBookmarkFolderDto: createBody,
      ),
    ).called(1);
  });

  test('动态收藏分页、首次入夹、移动和取消只委托动态仓储', () async {
    final api = _MockMomentsApi();
    final moments = _MockMomentRepository();
    final repository = ApiMomentBookmarkRepository(api, moments);
    const page = CursorPage<MomentCard>(items: [], hasMore: false);
    when(
      () => moments.fetchBookmarks(
        folderId: 'moment-custom',
        cursor: 'cursor-1',
        limit: 7,
      ),
    ).thenAnswer((_) async => page);
    when(
      () => moments.setBookmark(
        'moment-1',
        active: true,
        folderId: 'moment-custom',
      ),
    ).thenAnswer(
      (_) async => const MomentActionResult(
        momentId: 'moment-1',
        count: 1,
        active: true,
      ),
    );
    when(
      () => moments.setBookmark('moment-1', active: false, folderId: null),
    ).thenAnswer(
      (_) async => const MomentActionResult(
        momentId: 'moment-1',
        count: 0,
        active: false,
      ),
    );
    when(
      () => moments.moveBookmark('moment-1', 'moment-later'),
    ).thenAnswer((_) async {});

    expect(
      await repository.fetchPage(
        folderId: 'moment-custom',
        cursor: 'cursor-1',
        limit: 7,
      ),
      same(page),
    );
    await repository.setBookmark(
      'moment-1',
      active: true,
      folderId: 'moment-custom',
    );
    await repository.moveBookmark('moment-1', 'moment-later');
    await repository.setBookmark('moment-1', active: false);

    verify(
      () => moments.fetchBookmarks(
        folderId: 'moment-custom',
        cursor: 'cursor-1',
        limit: 7,
      ),
    ).called(1);
    verify(
      () => moments.setBookmark(
        'moment-1',
        active: true,
        folderId: 'moment-custom',
      ),
    ).called(1);
    verify(() => moments.moveBookmark('moment-1', 'moment-later')).called(1);
    verify(
      () => moments.setBookmark('moment-1', active: false, folderId: null),
    ).called(1);
    verifyNever(() => api.momentsBookmarkFolders());
  });

  test('动态收藏夹名称在本地校验且空响应不伪装成功', () async {
    final api = _MockMomentsApi();
    final repository = ApiMomentBookmarkRepository(
      api,
      _MockMomentRepository(),
    );

    await expectLater(
      repository.createFolder('  '),
      throwsA(isA<ApiFailure>()),
    );
    verifyNever(() => api.momentsBookmarkFolders());
  });
}

MomentBookmarkFolderResponseDto _folderDto(
  String id,
  String name, {
  int count = 0,
}) {
  return MomentBookmarkFolderResponseDto(
    (builder) => builder
      ..id = id
      ..name = name
      ..isDefault = id == 'moment-default'
      ..momentBookmarkCount = count
      ..createdAt = DateTime.utc(2026, 8, 27),
  );
}

Response<T> _response<T>(String path, T data) {
  return Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: 200,
  );
}

class _MockMomentsApi extends Mock implements MomentsApi {}

class _MockMomentRepository extends Mock implements MomentRepository {}

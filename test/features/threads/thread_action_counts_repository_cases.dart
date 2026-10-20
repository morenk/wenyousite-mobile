import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';

void registerThreadActionCountsRepositoryCases(
  ThreadDetailResponseDto Function() fixture,
) {
  test('统计可选字段通过真实序列化保留缺失、零值与总数', () async {
    for (final count in <int?>[null, 0, 12345]) {
      final json = Map<String, dynamic>.from(
        standardSerializers.serializeWith(
              ThreadDetailResponseDto.serializer,
              fixture(),
            )!
            as Map,
      );
      if (count != null) {
        json['bookmarkCount'] = count;
        json['subscriberCount'] = count;
      }
      final dto = standardSerializers.deserializeWith(
        ThreadDetailResponseDto.serializer,
        json,
      )!;
      final threadsApi = _MockThreadsApi();
      when(
        () => threadsApi.threadsFindById(id: 'thread-1'),
      ).thenAnswer((_) async => _threadDetailResponse(detail: dto));
      final detail = await ApiThreadDetailRepository(
        threadsApi,
        _MockPostsApi(),
      ).fetchThread('thread-1');
      expect(detail.bookmarkCount, count);
      expect(detail.subscriberCount, count);
    }
  });
  test('负总数是无效响应，不截断成真实零值', () async {
    final threadsApi = _MockThreadsApi();
    when(() => threadsApi.threadsFindById(id: 'thread-1')).thenAnswer(
      (_) async => _threadDetailResponse(
        detail: fixture().rebuild((b) => b.bookmarkCount = -1),
      ),
    );
    await expectLater(
      ApiThreadDetailRepository(
        threadsApi,
        _MockPostsApi(),
      ).fetchThread('thread-1'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockPostsApi extends Mock implements PostsApi {}

Response<ThreadsFindById200Response> _threadDetailResponse({
  required ThreadDetailResponseDto detail,
}) => Response(
  requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
  data: ThreadsFindById200Response(
    (b) => b
      ..code = ApiSuccessEnvelopeCodeEnum.number0
      ..message = 'ok'
      ..data.replace(detail),
  ),
);

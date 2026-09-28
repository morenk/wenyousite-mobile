import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';

import '../../support/post_edited_time_fixture.dart';
import '../threads/thread_detail_page_test_support.dart';

void main() {
  for (final variant in ['missing', 'null', 'edited']) {
    test('真实客户端 $variant 编辑时间贯穿列表、内嵌回复、详情、深链和写回', () async {
      final edited = variant == 'edited' ? '2026-09-29T03:23:45.678Z' : null;
      final expected = edited == null ? null : DateTime.parse(edited);
      final reply = postEditedTimeJson(
        id: 'reply',
        reply: true,
        editedAt: edited,
        includeEditedAt: variant != 'missing',
      );
      final floor = postEditedTimeJson(
        editedAt: edited,
        includeEditedAt: variant != 'missing',
      )..['replies'] = [reply];
      final api = _api((request) {
        if (request.path.endsWith('/subthreads/subthread/posts')) {
          return [floor];
        }
        if (request.path.endsWith('/replies')) return [reply];
        return request.path.endsWith('/reply') ? reply : floor;
      });
      final posts = ApiPostRepository(api.getPostsApi());
      final threads = ApiThreadDetailRepository(
        api.getThreadsApi(),
        api.getPostsApi(),
      );

      final floors = await threads.fetchFloors(subthreadId: 'subthread');
      final main = floors.items.single;
      expect(main.editedAt, expected);
      expect(main.replies.single.editedAt, expected);
      expect(main.version, 9);
      expect(main.createdAt, DateTime.utc(2024, 1, 1, 2));

      final detail = await posts.fetchPost('floor');
      expect(detail.editedAt, expected);
      expect(detail.updatedAt, DateTime.utc(2026, 9, 29, 2));
      final replies = await posts.fetchReplies(rootPostId: 'floor');
      expect(replies.items.single.editedAt, expected);
      final saved = await posts.update(
        postId: 'floor',
        content: '楼层正文',
        version: 8,
      );
      expect(saved.editedAt, expected);

      final floorTarget = await threads.fetchPostTarget('floor');
      expect(floorTarget.floor.editedAt, expected);
      final replyTarget = await threads.fetchPostTarget('reply');
      expect(replyTarget.floor.editedAt, expected);
      expect(replyTarget.floor.replies.single.editedAt, expected);
      expect(replyTarget.focusedReplyId, 'reply');

      final converted = threadFloorAsPost(
        threadDetailPageTestDetail,
        threadDetailPageTestDetail.subthreads.first,
        main,
      );
      expect(converted.editedAt, expected);
      expect(converted.createdAt, main.createdAt);
    });
  }
}

WenyouApi _api(Object Function(RequestOptions request) payload) {
  final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) => handler.resolve(
        Response<Object>(
          requestOptions: request,
          statusCode: 200,
          data: {
            'code': 0,
            'message': 'ok',
            'data': payload(request),
            'meta': {'hasMore': false},
          },
        ),
      ),
    ),
  );
  addTearDown(() => dio.close(force: true));
  return WenyouApi(dio: dio);
}

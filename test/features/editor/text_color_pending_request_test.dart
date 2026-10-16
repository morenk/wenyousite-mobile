import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog_ports.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

class _Posts extends Mock implements PostsApi {}

class _Threads extends Mock implements ThreadsApi {}

class _Users extends Mock implements UsersApi {}

class _Categories extends Mock implements ThreadCategoryCatalogRepository {}

class _PostDto extends Fake implements CreatePostDto {}

class _ThreadDto extends Fake implements CreateThreadDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(_PostDto());
    registerFallbackValue(_ThreadDto());
  });
  for (final original in [true, false, null]) {
    test('待确认请求跨重开冻结颜色声明 $original', () async {
      final current = original != true;
      final expected = original ?? current;
      final content = expected
          ? '<span data-wenyou-color-v1="#123456">正文</span>'
          : '正文';
      final posts = _Posts();
      CreatePostDto? postDto;
      when(
        () => posts.postsCreate(
          subthreadId: 'sub',
          createPostDto: any(named: 'createPostDto'),
          extra: ApiRequestPolicy.idempotentCreate.extra,
        ),
      ).thenAnswer((invocation) async {
        postDto = invocation.namedArguments[#createPostDto] as CreatePostDto;
        throw const ApiFailure(userMessage: '本地模拟超时');
      });
      final restoredPost = PostPublishDraft.fromJson(
        PostPublishDraft(
          pending: PendingPostCreate(
            input: PostCreateInput(
              subthreadId: 'sub',
              content: content,
              clientRequestId: 'same-request',
              textColorSupported: original,
            ),
          ),
        ).toJson(),
      )!.pending!.input;
      expect(restoredPost.textColorSupported, original);
      await expectLater(
        ApiPostRepository(
          posts,
          textColorSupported: current,
        ).create(restoredPost),
        throwsA(isA<ApiFailure>()),
      );
      expect(postDto, isNotNull);
      expect(
        postDto!.textColorVersion,
        expected ? CreatePostDtoTextColorVersionEnum.number1 : null,
      );
      expect(postDto!.clientRequestId, 'same-request');
      final threads = _Threads();
      CreateThreadDto? threadDto;
      when(
        () => threads.threadsCreate(
          createThreadDto: any(named: 'createThreadDto'),
          extra: ApiRequestPolicy.idempotentCreate.extra,
        ),
      ).thenAnswer((invocation) async {
        threadDto =
            invocation.namedArguments[#createThreadDto] as CreateThreadDto;
        throw const ApiFailure(userMessage: '本地模拟超时');
      });
      final restoredThread = ThreadCreatePayload.fromNormalizedJson(
        ThreadCreatePayload(
          clientRequestId: 'same-request',
          title: '主题',
          categorySlug: null,
          visibility: ThreadComposeVisibility.public,
          tags: [],
          body: content,
          textColorSupported: original,
        ).toNormalizedJson(),
      )!;
      expect(restoredThread.textColorSupported, original);
      await expectLater(
        ApiThreadComposeRepository(
          threads,
          _Categories(),
          _Users(),
          textColorSupported: current,
        ).createDraft(restoredThread),
        throwsA(isA<ApiFailure>()),
      );
      expect(threadDto, isNotNull);
      expect(
        threadDto!.textColorVersion,
        expected ? CreateThreadDtoTextColorVersionEnum.number1 : null,
      );
      expect(threadDto!.clientRequestId, 'same-request');
    });
  }
}

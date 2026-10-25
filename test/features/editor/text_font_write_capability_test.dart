import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/thread_category_catalog_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

const _requestId = '550e8400-e29b-41d4-a716-446655440000';
const _body = '普通正文\n\n**保留粗体**';

void main() {
  for (final version in [0, 1, 2]) {
    test('无字体正文按能力$version编码全部九条写入路径', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'));
      addTearDown(dio.close);
      final captured = <Map<String, Object?>>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured.add(Map<String, Object?>.from(options.data as Map));
            // 已经过真实生成序列化；截获后终止，不发送任何网络请求。
            handler.reject(DioException(requestOptions: options));
          },
        ),
      );
      final api = WenyouApi(dio: dio);
      final categories = ApiThreadCategoryCatalogRepository(
        api.getThreadCategoriesApi(),
      );
      final posts = ApiPostRepository(
        api.getPostsApi(),
        textFontSupported: version > 0,
        textFontV2Supported: version == 2,
      );
      final drafts = ApiContentDraftRepository(
        api.getDraftsApi(),
        textFontSupported: version > 0,
        textFontV2Supported: version == 2,
      );
      final compose = ApiThreadComposeRepository(
        api.getThreadsApi(),
        categories,
        api.getUsersApi(),
        textFontSupported: version > 0,
        textFontV2Supported: version == 2,
      );
      final management = ApiThreadManagementRepository(
        api.getThreadsApi(),
        categories,
        textFontSupported: version > 0,
        textFontV2Supported: version == 2,
      );
      final subthreads = ApiSubthreadManagementRepository(
        api.getThreadsApi(),
        api.getSubthreadsApi(),
        textFontSupported: version > 0,
        textFontV2Supported: version == 2,
      );
      final operations = <String, Future<Object?> Function()>{
        '楼层/回复创建': () => posts.create(
          const PostCreateInput(
            subthreadId: 'subthread',
            content: _body,
            clientRequestId: _requestId,
          ),
        ),
        '楼层/回复修改': () =>
            posts.update(postId: 'post', content: _body, version: 1),
        '子贴正文': () =>
            posts.upsertBody(subthreadId: 'subthread', content: _body),
        '草稿创建': () => drafts.create(_body, clientRequestId: _requestId),
        '草稿更新': () => drafts.update(id: 'draft', content: _body, version: 1),
        '主题创建': () => compose.createDraft(
          const ThreadCreatePayload(
            clientRequestId: _requestId,
            title: '测试',
            categorySlug: null,
            visibility: ThreadComposeVisibility.public,
            tags: [],
            body: _body,
          ),
        ),
        '主题聚合': () => compose.saveAggregate(
          remoteDraft: const ThreadRemoteDraft(
            id: 'thread',
            version: 1,
            defaultSubthreadId: 'subthread',
            defaultSubthreadVersion: 1,
            title: '测试',
            categorySlug: null,
            visibility: ThreadComposeVisibility.public,
            tags: [],
            body: _body,
          ),
          title: '测试',
          categorySlug: null,
          visibility: ThreadComposeVisibility.public,
          tags: [],
          body: _body,
          publish: true,
        ),
        '主题管理': () => management.update(
          current: const ThreadManagementSnapshot(
            id: 'thread',
            title: '测试',
            categorySlug: null,
            status: ThreadManagementStatus.recruiting,
            visibility: ThreadManagementVisibility.public,
            version: 1,
            published: true,
            canManage: true,
            isOwner: true,
            defaultSubthreadId: 'subthread',
            defaultSubthreadVersion: 1,
            body: _body,
          ),
          draft: const ThreadManagementDraft(
            title: '修改',
            categorySlug: null,
            status: ThreadManagementStatus.recruiting,
            visibility: ThreadManagementVisibility.public,
          ),
        ),
        '子贴创建': () => subthreads.create(
          threadId: 'thread',
          draft: const SubthreadManagementDraft(
            title: '子贴',
            postingPolicy: SubthreadPostingPolicy.participants,
          ),
          clientRequestId: _requestId,
        ),
      };
      for (final operation in operations.entries) {
        final before = captured.length;
        await expectLater(operation.value(), throwsA(isA<ApiFailure>()));
        expect(captured.length, before + 1, reason: operation.key);
        if (version == 0) {
          expect(
            captured.last,
            isNot(contains('textFontVersion')),
            reason: operation.key,
          );
        } else {
          expect(
            captured.last['textFontVersion'],
            version,
            reason: operation.key,
          );
        }
        if (operation.key != '子贴创建') {
          expect(captured.last['content'], _body, reason: operation.key);
        }
      }
    });
  }

  for (final source in [
    '<span data-wenyou-font-v1="wenkai">旧字体</span>',
    '<span data-wenyou-font-v2="tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa">新字体</span>',
  ]) {
    test('无字体能力时拒绝含真实字体的正文且不清洗源文：$source', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'));
      addTearDown(dio.close);
      var requests = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.reject(DioException(requestOptions: options));
          },
        ),
      );
      final api = WenyouApi(dio: dio);
      final drafts = ApiContentDraftRepository(api.getDraftsApi());
      final posts = ApiPostRepository(api.getPostsApi());
      final categories = ApiThreadCategoryCatalogRepository(
        api.getThreadCategoriesApi(),
      );
      final compose = ApiThreadComposeRepository(
        api.getThreadsApi(),
        categories,
        api.getUsersApi(),
      );
      final management = ApiThreadManagementRepository(
        api.getThreadsApi(),
        categories,
      );
      for (final operation in <Future<Object?> Function()>[
        () => drafts.create(source, clientRequestId: _requestId),
        () => drafts.update(id: 'draft', content: source, version: 1),
        () => posts.create(
          PostCreateInput(
            subthreadId: 'subthread',
            content: source,
            clientRequestId: _requestId,
          ),
        ),
        () => posts.update(postId: 'post', content: source, version: 1),
        () => posts.upsertBody(subthreadId: 'subthread', content: source),
        () => compose.createDraft(
          ThreadCreatePayload(
            clientRequestId: _requestId,
            title: '测试',
            categorySlug: null,
            visibility: ThreadComposeVisibility.public,
            tags: const [],
            body: source,
          ),
        ),
        () => compose.saveAggregate(
          remoteDraft: ThreadRemoteDraft(
            id: 'thread',
            version: 1,
            defaultSubthreadId: 'subthread',
            defaultSubthreadVersion: 1,
            title: '测试',
            categorySlug: null,
            visibility: ThreadComposeVisibility.public,
            tags: const [],
            body: source,
          ),
          title: '测试',
          categorySlug: null,
          visibility: ThreadComposeVisibility.public,
          tags: const [],
          body: source,
          publish: true,
        ),
        () => management.update(
          current: ThreadManagementSnapshot(
            id: 'thread',
            title: '测试',
            categorySlug: null,
            status: ThreadManagementStatus.recruiting,
            visibility: ThreadManagementVisibility.public,
            version: 1,
            published: true,
            canManage: true,
            isOwner: true,
            defaultSubthreadId: 'subthread',
            defaultSubthreadVersion: 1,
            body: source,
          ),
          draft: const ThreadManagementDraft(
            title: '修改',
            categorySlug: null,
            status: ThreadManagementStatus.recruiting,
            visibility: ThreadManagementVisibility.public,
          ),
        ),
      ]) {
        await expectLater(
          operation(),
          throwsA(
            isA<ApiFailure>().having(
              (failure) => failure.businessCode,
              '字体不可用',
              40019,
            ),
          ),
        );
      }
      expect(requests, 0);
    });
  }
}

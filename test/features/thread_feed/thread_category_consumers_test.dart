import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_thread_category_catalog_repository.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/thread_category_catalog_repository.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';

void main() {
  test('发现、标签、创作、管理与目录展示并发时只发一个分类请求', () async {
    final categoriesApi = _Categories();
    final categoryResponse =
        Completer<Response<ThreadCategoriesList200Response>>();
    when(
      () => categoriesApi.threadCategoriesList(extra: any(named: 'extra')),
    ).thenAnswer((_) => categoryResponse.future);
    final threads = _Threads();
    final tags = _Tags();
    final users = _Users();
    const failure = ApiFailure(httpStatus: 503);
    when(
      () => threads.threadsFindAll(tagId: 'tag'),
    ).thenAnswer((_) async => throw failure);
    when(
      () => threads.threadsFindById(id: 'thread'),
    ).thenAnswer((_) async => throw failure);
    when(
      () => tags.tagsGetById(id: 'tag'),
    ).thenAnswer((_) async => throw failure);
    when(() => users.usersGetMe()).thenAnswer((_) async => throw failure);
    final shared = CachedThreadCategoryCatalogRepository(
      ApiThreadCategoryCatalogRepository(categoriesApi),
    );
    final catalog = ThreadCategoryCatalogController(shared, autoStart: false);
    addTearDown(catalog.dispose);
    final home = ApiHomeRepository(threads, shared).fetchCategories();
    final pending = [
      expectLater(
        ApiTagRepository(tags, threads, shared).loadTagThreads('tag'),
        throwsA(same(failure)),
      ),
      expectLater(
        ApiThreadComposeRepository(threads, shared, users).fetchBootstrap(),
        throwsA(same(failure)),
      ),
      expectLater(
        ApiThreadManagementRepository(threads, shared).load('thread'),
        throwsA(same(failure)),
      ),
      catalog.load(),
    ];
    verify(
      () => categoriesApi.threadCategoriesList(extra: any(named: 'extra')),
    ).called(1);
    categoryResponse.complete(
      Response(
        requestOptions: RequestOptions(path: '/api/v1/thread-categories'),
        data: ThreadCategoriesList200Response(
          (b) => b
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace([]),
        ),
      ),
    );
    await Future.wait(pending);
    expect(await home, isEmpty);
    expect(catalog.state.phase, ThreadCategoryCatalogPhase.ready);
    verifyNoMoreInteractions(categoriesApi);
  });
}

class _Categories extends Mock implements ThreadCategoriesApi {}

class _Threads extends Mock implements ThreadsApi {}

class _Tags extends Mock implements TagsApi {}

class _Users extends Mock implements UsersApi {}

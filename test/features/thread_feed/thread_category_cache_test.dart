import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_thread_category_catalog_repository.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_models.dart';

void main() {
  test('其他消费者刷新目录后已挂载分类展示同步采用新名称', () async {
    final source = _Source();
    final repository = CachedThreadCategoryCatalogRepository(source);
    addTearDown(repository.dispose);
    final controller = ThreadCategoryCatalogController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    final initial = controller.load();
    source.requests.single.complete(_categories('旧名称'));
    await initial;
    final refresh = repository.fetchThreadCategories(refresh: true);
    source.requests.last.complete(_categories('新名称'));
    await refresh;
    expect(controller.state.categories.single.name, '新名称');
    expect(source.requests, hasLength(2));
  });

  test('所有目录消费者共享在途读取，缓存有界且强制刷新合并', () async {
    var now = DateTime.utc(2026, 9, 7);
    final source = _Source();
    final repository = CachedThreadCategoryCatalogRepository(
      source,
      now: () => now,
    );
    final first = repository.fetchThreadCategories();
    final second = repository.fetchThreadCategories(refresh: true);
    expect(source.requests, hasLength(1));
    source.requests.single.complete(_categories('演绎'));
    expect(await second, same(await first));
    expect((await repository.fetchThreadCategories()).single.name, '演绎');
    expect(source.requests, hasLength(1));
    final refresh = repository.fetchThreadCategories(refresh: true);
    final joined = repository.fetchThreadCategories();
    expect(source.requests, hasLength(2));
    source.requests.last.complete(_categories('新的名称'));
    expect(await joined, same(await refresh));
    now = now.add(const Duration(minutes: 6));
    final expired = repository.fetchThreadCategories();
    expect(source.requests, hasLength(3));
    source.requests.last.complete(_categories('最新名称'));
    expect((await expired).single.name, '最新名称');
  });

  test('目录刷新失败保留缓存且释放在途锁，下一次显式刷新可重试', () async {
    final source = _Source();
    final repository = CachedThreadCategoryCatalogRepository(source);
    final initial = repository.fetchThreadCategories();
    source.requests.single.complete(_categories('演绎'));
    await initial;
    final failed = repository.fetchThreadCategories(refresh: true);
    final assertion = expectLater(failed, throwsStateError);
    source.requests.last.completeError(StateError('Unavailable.'));
    await assertion;
    expect((await repository.fetchThreadCategories()).single.name, '演绎');
    expect(source.requests, hasLength(2));
    final retry = repository.fetchThreadCategories(refresh: true);
    source.requests.last.complete([]);
    expect(await retry, isEmpty);
    expect(await repository.fetchThreadCategories(), isEmpty);
    expect(source.requests, hasLength(3));
  });
}

List<ThreadCategory> _categories(String name) => [
  ThreadCategory(id: 'category', slug: 'DEDUCTION', name: name, sortOrder: 1),
];

class _Source implements ThreadCategoryCatalogRepository {
  final requests = <Completer<List<ThreadCategory>>>[];
  @override
  Future<List<ThreadCategory>> fetchThreadCategories({bool refresh = false}) {
    final request = Completer<List<ThreadCategory>>();
    requests.add(request);
    return request.future;
  }
}

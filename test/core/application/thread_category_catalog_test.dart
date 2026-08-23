import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';

void main() {
  const categories = [
    HomeCategory(
      id: 'category-deduction',
      slug: 'DEDUCTION',
      name: '演绎',
      sortOrder: 1,
    ),
  ];

  test('分类展示只返回用户 label 与固定降级文案', () {
    expect(
      resolveThreadCategoryPresentation(
        'DEDUCTION',
        categories: categories,
      )?.label,
      '演绎',
    );
    expect(
      resolveThreadCategoryPresentation(
        'ARCHIVED_WORLD',
        categories: categories,
      )?.label,
      '历史分类',
    );
    expect(
      resolveThreadCategoryPresentation(
        'LEAKED_CONSTANT',
        categories: const [
          HomeCategory(
            id: 'category-leaked',
            slug: 'LEAKED_CONSTANT',
            name: 'LEAKED_CONSTANT',
            sortOrder: 2,
          ),
        ],
      )?.label,
      '历史分类',
    );
    expect(
      resolveThreadCategoryPresentation(null, categories: categories)?.label,
      '未分类',
    );
    expect(
      resolveThreadCategoryPresentation(
        'DEDUCTION',
        categories: const [],
        availability: ThreadCategoryCatalogAvailability.unavailable,
      )?.label,
      '分类暂不可用',
    );
    expect(
      resolveThreadCategoryPresentation(
        'DEDUCTION',
        categories: const [],
        availability: ThreadCategoryCatalogAvailability.loading,
      ),
      isNull,
    );
  });

  test('分类目录合并并发读取并在刷新失败时保留最后快照', () async {
    final repository = _ControlledRepository();
    final controller = ThreadCategoryCatalogController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);

    final first = controller.load();
    final second = controller.load();
    expect(repository.calls, 1);
    repository.pending.single.complete(categories);
    await Future.wait([first, second]);
    expect(controller.state.resolve('DEDUCTION')?.label, '演绎');

    final refresh = controller.refresh();
    repository.pending.last.completeError(StateError('offline'));
    await refresh;
    expect(controller.state.phase, ThreadCategoryCatalogPhase.ready);
    expect(controller.state.resolve('DEDUCTION')?.label, '演绎');
  });
}

class _ControlledRepository implements ThreadCategoryCatalogRepository {
  final pending = <Completer<List<HomeCategory>>>[];
  int calls = 0;

  @override
  Future<List<HomeCategory>> fetchThreadCategories() {
    calls += 1;
    final completer = Completer<List<HomeCategory>>();
    pending.add(completer);
    return completer.future;
  }
}

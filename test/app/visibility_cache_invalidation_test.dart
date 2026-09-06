import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/search/application/search_repository_ports.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

void main() {
  test('组合根清空搜索投影，拉黑前在途结果不能恢复旧缓存', () async {
    final repository = _Search();
    final container = ProviderContainer(
      overrides: [
        searchRepositoryProvider.overrideWithValue(repository),
        visibilityCacheInvalidatorProvider.overrideWith(
          (ref) =>
              () => invalidateVisibilityCaches(ref.container),
        ),
      ],
    );
    addTearDown(container.dispose);
    final old = container.read(searchControllerProvider.notifier);
    final pending = old.submit('旧可见内容');
    expect(container.read(searchControllerProvider).query, '旧可见内容');
    container.read(visibilityCacheInvalidatorProvider)();
    expect(container.read(searchControllerProvider).query, isEmpty);
    expect(
      identical(container.read(searchControllerProvider.notifier), old),
      isFalse,
    );
    repository.result.complete([]);
    await pending;
    expect(container.read(searchControllerProvider).query, isEmpty);
  });
}

class _Search extends Fake implements SearchRepository {
  final result = Completer<List<SearchThreadResult>>();
  @override
  Future<List<SearchThreadResult>> searchThreads(String query) => result.future;
}

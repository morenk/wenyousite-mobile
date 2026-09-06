import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/home/application/home_feed_controller.dart';
import 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

void main() {
  for (final succeeds in [true, false]) {
    test('可见性缓存失效后首页迟到${succeeds ? '成功' : '失败'}不写入已释放状态', () async {
      final repository = _Repository();
      final controller = HomeFeedController(repository, autoStart: false);
      final pending = controller.loadInitial();
      controller.dispose();
      if (succeeds) {
        repository.result.complete(const CursorPage(items: [], hasMore: false));
      } else {
        repository.result.completeError(StateError('late request failure'));
      }
      await expectLater(pending, completes);
    });
  }
}

class _Repository implements HomeRepository {
  final result = Completer<CursorPage<ThreadFeedCardModel>>();
  @override
  Future<List<ThreadCategory>> fetchCategories() async => [];
  @override
  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) => result.future;
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/cursor_page_request.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test('过期请求的成功、失败和失效游标均不回写或触发恢复', () async {
    for (final error in [
      null,
      StateError('旧请求'),
      const ApiFailure(userMessage: '失效', businessCode: 40007),
    ]) {
      final pending = Completer<int>();
      var current = true;
      var callbacks = 0;
      final load = loadCursorPage(
        fetch: () => pending.future,
        isCurrent: () => current,
        onPage: (_) => callbacks++,
        onInvalidCursor: () async {
          callbacks++;
        },
        mapFailure: (_) {
          callbacks++;
          return const ApiFailure(userMessage: '错误');
        },
        onFailure: (_) => callbacks++,
      );
      current = false;
      if (error == null) {
        pending.complete(1);
      } else {
        pending.completeError(error);
      }
      await load;
      expect(callbacks, 0);
    }
  });

  test('保留原失败与问题编号，只为当前失效游标调用一次恢复', () async {
    for (final code in [40007, 40301]) {
      final failure = ApiFailure(userMessage: '加载失败', businessCode: code);
      var recovered = 0;
      ApiFailure? received;
      await loadCursorPage<int>(
        fetch: () async => throw failure,
        isCurrent: () => true,
        onPage: (_) => fail('不能成功'),
        onInvalidCursor: () async {
          recovered++;
        },
        mapFailure: (_) => throw StateError('不得重映射 ApiFailure'),
        onFailure: (value) => received = value,
      );
      expect(recovered, code == 40007 ? 1 : 0);
      expect(received, code == 40007 ? isNull : same(failure));
    }
  });
}

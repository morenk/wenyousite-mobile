import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  const reconciler = WriteReconciler();

  test('写入成功直接完成且不读取投影', () async {
    var reads = 0;
    final outcome = await reconciler.run<int, bool>(
      write: () async => 7,
      read: () async {
        reads += 1;
        return true;
      },
      targetReached: (value) => value,
      failureMessage: '操作失败。',
    );

    expect(outcome.status, WriteOutcomeStatus.completed);
    expect(outcome.writeValue, 7);
    expect(outcome.wasReconciled, isFalse);
    expect(reads, 0);
  });

  test('写入结果不明时先通知确认并以已达成投影完成', () async {
    final progress = <WriteOutcomeStatus>[];
    final outcome = await reconciler.run<void, bool>(
      write: () => Future<void>.error(_timeout('write-request')),
      read: () async => true,
      targetReached: (value) => value,
      failureMessage: '操作失败。',
      onProgress: (value) => progress.add(value.status),
    );

    expect(progress, [WriteOutcomeStatus.confirming]);
    expect(outcome.status, WriteOutcomeStatus.completed);
    expect(outcome.wasReconciled, isTrue);
    expect(outcome.projection, isTrue);
  });

  test('权威读取仍为相反状态时保持暂时无法确定', () async {
    final outcome = await reconciler.run<void, bool>(
      write: () => Future<void>.error(_timeout('opposite-request')),
      read: () async => false,
      targetReached: (value) => value,
      failureMessage: '操作失败。',
    );

    expect(outcome.status, WriteOutcomeStatus.indeterminate);
    expect(outcome.projection, isFalse);
    expect(outcome.requestId, 'opposite-request');
  });

  test('确认读取失败时保留原问题编号并保持暂时无法确定', () async {
    final outcome = await reconciler.run<void, bool>(
      write: () => Future<void>.error(_timeout('write-request')),
      read: () => Future<bool>.error(StateError('read failed')),
      targetReached: (value) => value,
      failureMessage: '操作失败。',
    );

    expect(outcome.status, WriteOutcomeStatus.indeterminate);
    expect(outcome.projection, isNull);
    expect(outcome.requestId, 'write-request');
  });

  test('只有业务层列出的冲突码会进入确认', () async {
    var reads = 0;
    Future<bool> read() async {
      reads += 1;
      return true;
    }

    final converged = await reconciler.run<void, bool>(
      write: () => Future<void>.error(
        const ApiFailure(
          userMessage: '已存在',
          httpStatus: 409,
          businessCode: 40904,
        ),
      ),
      read: read,
      targetReached: (value) => value,
      failureMessage: '操作失败。',
      convergentBusinessCodes: const {40904},
    );
    final conflicting = await reconciler.run<void, bool>(
      write: () => Future<void>.error(
        const ApiFailure(
          userMessage: '内容冲突',
          httpStatus: 409,
          businessCode: 40912,
        ),
      ),
      read: read,
      targetReached: (value) => value,
      failureMessage: '操作失败。',
      convergentBusinessCodes: const {40904},
    );

    expect(converged.status, WriteOutcomeStatus.completed);
    expect(conflicting.status, WriteOutcomeStatus.failed);
    expect(reads, 1);
  });

  test('组件销毁后丢弃结果且不开始确认', () async {
    final write = Completer<void>();
    var current = true;
    var reads = 0;
    final future = reconciler.run<void, bool>(
      write: () => write.future,
      read: () async {
        reads += 1;
        return true;
      },
      targetReached: (value) => value,
      failureMessage: '操作失败。',
      isCurrent: () => current,
    );

    current = false;
    write.completeError(_timeout('disposed-request'));
    final outcome = await future;

    expect(outcome.isDiscarded, isTrue);
    expect(reads, 0);
  });

  test('旧确认响应返回后被请求世代丢弃', () async {
    final read = Completer<bool>();
    var epoch = 1;
    final future = reconciler.run<void, bool>(
      write: () => Future<void>.error(_timeout('old-request')),
      read: () => read.future,
      targetReached: (value) => value,
      failureMessage: '操作失败。',
      isCurrent: () => epoch == 1,
    );

    await Future<void>.delayed(Duration.zero);
    epoch = 2;
    read.complete(true);
    final outcome = await future;

    expect(outcome.isDiscarded, isTrue);
  });
}

ApiFailure _timeout(String requestId) {
  return ApiFailure(
    userMessage: '连接超时，请检查网络后重试。',
    requestId: requestId,
    cause: DioException(
      requestOptions: RequestOptions(path: '/write'),
      type: DioExceptionType.receiveTimeout,
    ),
  );
}

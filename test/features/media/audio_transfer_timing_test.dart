import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/audio_transfer_timing.dart';

void main() {
  test('请求起点开始无进展计时，内部超时不标记用户取消', () {
    fakeAsync((clock) {
      final parent = CancelToken();
      final guard = AudioTransferGuard(parent, const AudioTransferTiming());
      Object? failure;
      unawaited(
        guard.wait(Completer<void>().future).catchError((Object error) {
          failure = error;
        }),
      );
      clock.elapse(const Duration(seconds: 29));
      expect(guard.token.isCancelled, isFalse);
      clock.elapse(const Duration(seconds: 1));
      expect(failure, AudioTransferTimeout.idle);
      expect(guard.token.isCancelled, isTrue);
      expect(parent.isCancelled, isFalse);
      guard.dispose();
      clock.flushMicrotasks();
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test('仅实际增长续无进展期限，相同或回退字节不续命', () {
    fakeAsync((clock) {
      final guard = AudioTransferGuard(
        CancelToken(),
        const AudioTransferTiming(),
      );
      Object? failure;
      unawaited(
        guard.wait(Completer<void>().future).catchError((Object error) {
          failure = error;
        }),
      );
      clock.elapse(const Duration(seconds: 20));
      guard.progress(1);
      clock.elapse(const Duration(seconds: 20));
      guard.progress(1);
      guard.progress(0);
      clock.elapse(const Duration(seconds: 10));
      expect(failure, AudioTransferTimeout.idle);
      guard.dispose();
      clock.flushMicrotasks();
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test('持续增长也不能刷新五分钟总期限', () {
    fakeAsync((clock) {
      final guard = AudioTransferGuard(
        CancelToken(),
        const AudioTransferTiming(),
      );
      Object? failure;
      unawaited(
        guard.wait(Completer<void>().future).catchError((Object error) {
          failure = error;
        }),
      );
      for (var bytes = 1; bytes <= 14; bytes++) {
        clock.elapse(const Duration(seconds: 20));
        guard.progress(bytes);
      }
      expect(guard.token.isCancelled, isFalse);
      clock.elapse(const Duration(seconds: 20));
      expect(failure, AudioTransferTimeout.total);
      guard.dispose();
      clock.flushMicrotasks();
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test('成功清计时与监听，不因随后父取消误停已结束请求', () {
    fakeAsync((clock) {
      final parent = CancelToken();
      final guard = AudioTransferGuard(parent, const AudioTransferTiming());
      int? value;
      unawaited(guard.wait(Future.value(1)).then((result) => value = result));
      clock.flushMicrotasks();
      expect(value, 1);
      guard.dispose();
      parent.cancel();
      clock.elapse(const Duration(minutes: 6));
      expect(guard.token.isCancelled, isFalse);
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test('用户取消打断等待并清理，已取消的请求也立即退出', () {
    fakeAsync((clock) {
      for (final alreadyCancelled in [false, true]) {
        final parent = CancelToken();
        if (alreadyCancelled) parent.cancel();
        final guard = AudioTransferGuard(parent, const AudioTransferTiming());
        Object? failure;
        unawaited(
          guard.wait(Completer<void>().future).catchError((Object error) {
            failure = error;
          }),
        );
        parent.cancel();
        clock.flushMicrotasks();
        expect(
          failure,
          isA<DioException>().having(
            (e) => CancelToken.isCancel(e),
            '取消',
            isTrue,
          ),
        );
        guard.dispose();
        clock.flushMicrotasks();
        expect(clock.pendingTimers, isEmpty);
      }
    });
  });

  test('处理等待取消后不留timer，正常间隔可完成', () {
    fakeAsync((clock) {
      final cancel = CancelToken();
      Object? failure;
      unawaited(
        waitForAudioProcessing(const Duration(seconds: 10), cancel).catchError((
          Object error,
        ) {
          failure = error;
        }),
      );
      cancel.cancel();
      clock.flushMicrotasks();
      expect(failure, isA<DioException>());
      expect(clock.pendingTimers, isEmpty);
      var finished = false;
      unawaited(
        waitForAudioProcessing(
          const Duration(seconds: 1),
          CancelToken(),
        ).then((_) => finished = true),
      );
      clock.elapse(const Duration(seconds: 1));
      expect(finished, isTrue);
      expect(clock.pendingTimers, isEmpty);
    });
  });
}

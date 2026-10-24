import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_deadline.dart';

void main() {
  test('timer回调延迟时字节和EOF仍检查截止，重合截止优先总上限', () {
    fakeAsync((time) {
      var now = Duration.zero;
      final expired = <TextFontDeadlineReason>[];
      TextFontTransferDeadline create() => TextFontTransferDeadline(
        firstResponseTimeout: const Duration(seconds: 15),
        progressTimeout: const Duration(seconds: 15),
        maximumDuration: const Duration(minutes: 10),
        elapsed: () => now,
        onTimeout: expired.add,
      );
      final headers = create();
      now = const Duration(seconds: 14);
      expect(headers.responseReceived(), isTrue);
      now = const Duration(seconds: 15);
      expect(headers.check(), isFalse); // EOF，不推进fake timer。
      expect(headers.bytesReceived(1), isFalse);
      expect(expired, [TextFontDeadlineReason.noProgress]);
      now = Duration.zero;
      final total = create();
      for (var second = 10; second <= 580; second += 10) {
        now = Duration(seconds: second);
        expect(total.bytesReceived(1), isTrue);
      }
      now = const Duration(seconds: 585);
      total.bytesReceived(1);
      now = const Duration(minutes: 10);
      expect(total.check(), isFalse);
      expect(expired.last, TextFontDeadlineReason.total);
      expect(time.pendingTimers, isEmpty);
    });
  });

  TextFontTransferDeadline deadline(
    List<TextFontDeadlineReason> expired,
    FakeAsync time,
  ) => TextFontTransferDeadline(
    firstResponseTimeout: const Duration(seconds: 15),
    progressTimeout: const Duration(seconds: 15),
    maximumDuration: const Duration(minutes: 10),
    onTimeout: expired.add,
    elapsed: () => time.elapsed,
  );
  test('持续非空字节超过一分钟仍可完成，不用总15秒限制误杀慢传输', () {
    fakeAsync((time) {
      final expired = <TextFontDeadlineReason>[];
      final value = deadline(expired, time)..responseReceived();
      for (var i = 0; i < 20; i++) {
        time.elapse(const Duration(seconds: 10));
        value.bytesReceived(1024 * 1024);
      }
      value.dispose();
      time.elapse(const Duration(minutes: 20));
      expect(expired, isEmpty);
      expect(time.pendingTimers, isEmpty);
    });
  });
  test('首响应和进度停顿各15秒，零字节不能续期', () {
    fakeAsync((time) {
      final expired = <TextFontDeadlineReason>[];
      deadline(expired, time);
      time.elapse(const Duration(seconds: 15));
      expect(expired, [TextFontDeadlineReason.firstResponse]);
      final value = deadline(expired, time)..responseReceived();
      time.elapse(const Duration(seconds: 10));
      value.bytesReceived(0);
      time.elapse(const Duration(seconds: 5));
      expect(expired.last, TextFontDeadlineReason.noProgress);
      expect(time.pendingTimers, isEmpty);
    });
  });
  test('持续进度不能延长600秒总期限，取消/完成释放所有timer', () {
    fakeAsync((time) {
      final expired = <TextFontDeadlineReason>[];
      final value = deadline(expired, time)..responseReceived();
      for (var i = 0; i < 60; i++) {
        time.elapse(const Duration(seconds: 10));
        value.bytesReceived(1);
      }
      expect(expired, [TextFontDeadlineReason.total]);
      expect(time.pendingTimers, isEmpty);
      deadline(expired, time).dispose();
      time.elapse(const Duration(minutes: 20));
      expect(expired, hasLength(1));
      expect(time.pendingTimers, isEmpty);
    });
  });
}

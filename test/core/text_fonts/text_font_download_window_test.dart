import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';

void main() {
  test('小文件能用余量，但不能推迟队首大文件；同时醒来重新预留', () {
    final window = TextFontDownloadWindow(
      period: const Duration(seconds: 10),
      maximumBytes: 10,
      maximumRequests: 100,
    );
    expect(window.reserve(6, Duration.zero), isTrue);
    expect(
      window.availableAt(9, const Duration(seconds: 1)),
      const Duration(seconds: 10),
    );
    expect(
      window.reserve(4, const Duration(seconds: 1), reservedForEarlier: 9),
      isFalse,
    );
    expect(
      window.reserve(1, const Duration(seconds: 1), reservedForEarlier: 9),
      isTrue,
    );
    expect(
      window.reserve(1, const Duration(seconds: 2), reservedForEarlier: 9),
      isFalse,
    );
    expect(window.reserve(9, const Duration(seconds: 10)), isTrue);
    expect(window.reserve(9, const Duration(seconds: 10)), isFalse);
  });
  test('字节窗口到期自动补充，可持续越过旧累计24MiB，不重置进程状态', () {
    final window = TextFontDownloadWindow(
      period: const Duration(seconds: 60),
      maximumBytes: 24 * 1024 * 1024,
      maximumRequests: 64,
    );
    const chunk = 6 * 1024 * 1024;
    var total = 0;
    for (var round = 0; round < 10; round++) {
      final now = Duration(seconds: 60 * round);
      for (var request = 0; request < 4; request++) {
        expect(window.reserve(chunk, now), isTrue);
        total += chunk;
      }
      expect(window.reserve(chunk, now), isFalse);
      expect(window.availableAt(chunk, now), now + const Duration(seconds: 60));
    }
    expect(total, 240 * 1024 * 1024);
  });
  test('64请求只是滑动窗口，过期后继续；错误尝试不提前退额', () {
    final window = TextFontDownloadWindow(
      period: const Duration(seconds: 60),
      maximumBytes: 1000,
      maximumRequests: 64,
    );
    for (var i = 0; i < 64; i++) {
      expect(window.reserve(1, Duration(seconds: i)), isTrue);
    }
    // 60秒后的最早四项已经过期，窗口内仍只能保留64项。
    for (var i = 0; i < 4; i++) {
      expect(window.reserve(1, const Duration(seconds: 63)), isTrue);
    }
    expect(window.reserve(1, const Duration(seconds: 63)), isFalse);
    expect(
      window.availableAt(1, const Duration(seconds: 63)),
      const Duration(seconds: 64),
    );
    expect(window.reserve(1, const Duration(seconds: 64)), isTrue);
  });
  test('原件可占用普通窗口但不能突破窗口；时钟倒退不释放额度', () {
    final window = TextFontDownloadWindow(
      period: const Duration(seconds: 60),
      maximumBytes: 24 * 1024 * 1024,
      maximumRequests: 64,
    );
    expect(window.reserve(18410600, const Duration(seconds: 10)), isTrue);
    expect(
      window.reserve(6 * 1024 * 1024, const Duration(seconds: 10)),
      isTrue,
    );
    expect(window.reserve(1, Duration.zero), isFalse);
    expect(
      () => window.reserve(25 * 1024 * 1024, Duration.zero),
      throwsRangeError,
    );
  });
}

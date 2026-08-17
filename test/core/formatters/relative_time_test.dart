import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';

void main() {
  test('发布时间遵循 Foundation 的 72 小时相对时间窗口', () {
    final now = DateTime(2026, 8, 12, 12);

    expect(formatWenyouRelativeTime(now, now: now), '刚刚');
    expect(
      formatWenyouRelativeTime(
        now.subtract(const Duration(minutes: 8)),
        now: now,
      ),
      '8 分钟前',
    );
    expect(
      formatWenyouRelativeTime(
        now.subtract(const Duration(hours: 3)),
        now: now,
      ),
      '3 小时前',
    );
    expect(
      formatWenyouRelativeTime(now.subtract(const Duration(days: 2)), now: now),
      '2 天前',
    );
    expect(
      formatWenyouRelativeTime(DateTime(2026, 8, 1, 9, 30), now: now),
      '08-01 09:30',
    );
    expect(
      formatWenyouRelativeTime(DateTime(2025, 12, 31), now: now),
      '2025-12-31 00:00',
    );
  });
}

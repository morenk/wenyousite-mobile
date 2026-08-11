import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';

void main() {
  test('发布时间先显示相对时间，超过一周后显示日期', () {
    final now = DateTime(2026, 8, 12, 12);

    expect(formatWenyouRelativeTime(now, now: now), '刚刚');
    expect(
      formatWenyouRelativeTime(
        now.subtract(const Duration(minutes: 8)),
        now: now,
      ),
      '8分钟前',
    );
    expect(
      formatWenyouRelativeTime(
        now.subtract(const Duration(hours: 3)),
        now: now,
      ),
      '3小时前',
    );
    expect(
      formatWenyouRelativeTime(now.subtract(const Duration(days: 4)), now: now),
      '4天前',
    );
    expect(formatWenyouRelativeTime(DateTime(2026, 8, 1), now: now), '08-01');
    expect(
      formatWenyouRelativeTime(DateTime(2025, 12, 31), now: now),
      '2025-12-31',
    );
  });
}

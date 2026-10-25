import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/formatters/compact_action_count.dart';

void main() {
  test('底栏短计数保留千以下原值并限制数字占位', () {
    const cases = {
      0: '0',
      999: '999',
      1000: '1k',
      1299: '1.2k',
      9999: '9.9k',
      10000: '10k',
      12345: '12k',
      999999: '999k',
      1000000: '1m',
      1234567890: '1.2b',
      1000000000000: '1t',
      1000000000000000: '1e15',
      9223372036854775807: '9e18',
    };
    for (final entry in cases.entries) {
      expect(formatCompactActionCount(entry.key), entry.value);
    }
  });
}

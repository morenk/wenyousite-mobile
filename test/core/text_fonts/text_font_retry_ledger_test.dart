import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';

void main() {
  test('单个片暂时失败不影响同字体其他片，full jitter逐步退避至60秒', () {
    final ledger = TextFontRetryLedger(random: () => 0.5);
    const now = Duration(seconds: 100);
    for (final ms in [500, 1000, 2000, 4000, 8000, 16000, 30000, 30000]) {
      ledger.transientFailure('片A', now);
      expect(ledger.availableAt('片A'), now + Duration(milliseconds: ms));
      expect(ledger.availableAt('片B'), Duration.zero);
      expect(ledger.isTerminal('片A'), isFalse);
    }
  });
  test('可见性/网络重复查询不重置退避，不越过Retry-After', () {
    final ledger = TextFontRetryLedger(random: () => 0);
    ledger.transientFailure(
      '片A',
      Duration.zero,
      retryAfter: const Duration(minutes: 2),
    );
    for (var i = 0; i < 100; i++) {
      expect(ledger.availableAt('片A'), const Duration(minutes: 2));
      expect(ledger.attempts('片A'), 1);
    }
    ledger.success('片A');
    expect(ledger.attempts('片A'), 0);
  });
  test('校验/撤回/原生失败隔离，不通过成功或暂时失败入口自动解除', () {
    final ledger = TextFontRetryLedger(random: () => 0);
    ledger.quarantine('bad-sha');
    ledger.transientFailure('bad-sha', Duration.zero);
    ledger.success('bad-sha');
    expect(ledger.isTerminal('bad-sha'), isTrue);
    expect(ledger.isTerminal('new-sha'), isFalse);
  });
}

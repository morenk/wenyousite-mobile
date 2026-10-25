import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';

String hash(int index) => index.toRadixString(16).padLeft(64, '0');

bool begin(TextFontNativeLedger ledger, int index, int bytes) =>
    ledger.beginNativeAttempt(
      hash: hash(index),
      family: 'family-$index',
      inputBytes: bytes,
    );

void main() {
  test('64 MiB 边界含失败输入，超一字节拒绝且不占新键', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 64 * 1024 * 1024 - 1), isTrue);
    expect(begin(ledger, 2, 1), isTrue);
    expect(begin(ledger, 3, 1), isFalse);
    expect(ledger.chargedInputBytes, 64 * 1024 * 1024);
    expect(ledger.attemptedCount, 2);
    expect(ledger.loadedCount, 0);
  });

  test('1024 键精确上限，无固定家族数量限制', () {
    final ledger = TextFontNativeLedger();
    for (var i = 0; i < 1024; i++) {
      expect(begin(ledger, i, 1), isTrue);
    }
    expect(begin(ledger, 1024, 1), isFalse);
    expect(ledger.attemptedCount, 1024);
    expect(ledger.chargedInputBytes, 1024);
  });

  test('失败或尚未完成的键不能重试，也不能退款', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 20), isTrue);
    expect(begin(ledger, 1, 20), isFalse);
    expect(ledger.attempted(hash: hash(1), family: 'family-1'), isTrue);
    expect(ledger.loaded(hash: hash(1), family: 'family-1'), isFalse);
    expect(begin(ledger, 2, 30), isTrue);
    ledger.completeNativeAttempt(hash: hash(2), family: 'family-2');
    expect(ledger.chargedInputBytes, 50);
    expect(ledger.loadedCount, 1);
  });

  test('成功重复查询与完成回调不重复计费', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 20), isTrue);
    ledger.completeNativeAttempt(hash: hash(1), family: 'family-1');
    ledger.completeNativeAttempt(hash: hash(1), family: 'family-1');
    expect(begin(ledger, 1, 20), isFalse);
    expect(ledger.loaded(hash: hash(1), family: 'family-1'), isTrue);
    expect(ledger.loadedCount, 1);
    expect(ledger.chargedInputBytes, 20);
  });

  test('同 SHA 不同 family 各计一次输入，不能以下载去重代替注册计费', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 20), isTrue);
    expect(
      ledger.beginNativeAttempt(
        hash: hash(1),
        family: 'another-family',
        inputBytes: 20,
      ),
      isTrue,
    );
    expect(ledger.attemptedCount, 2);
    expect(ledger.chargedInputBytes, 40);
  });

  test('不可变 family 不能指向新 SHA，同 SHA 不能声明新长度', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 20), isTrue);
    expect(
      ledger.beginNativeAttempt(
        hash: hash(2),
        family: 'family-1',
        inputBytes: 20,
      ),
      isFalse,
    );
    expect(
      ledger.beginNativeAttempt(
        hash: hash(1),
        family: 'another-family',
        inputBytes: 21,
      ),
      isFalse,
    );
    expect(ledger.attemptedCount, 1);
    expect(ledger.chargedInputBytes, 20);
  });

  test('策略不能突破本地硬上限，也不能放宽此前收紧的额度', () {
    final ledger = TextFontNativeLedger();
    ledger.tighten(maximumInputBytes: 128 * 1024 * 1024, maximumKeys: 2048);
    expect(ledger.maximumInputBytes, 64 * 1024 * 1024);
    expect(ledger.maximumKeys, 1024);
    ledger.tighten(maximumInputBytes: 100, maximumKeys: 3);
    ledger.tighten(maximumInputBytes: 200, maximumKeys: 4);
    expect(ledger.maximumInputBytes, 100);
    expect(ledger.maximumKeys, 3);
  });

  test('目录更新与回滚共用账本，降低到已用量以下不删除历史', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 40), isTrue);
    ledger.completeNativeAttempt(hash: hash(1), family: 'family-1');
    expect(begin(ledger, 2, 30), isTrue);
    ledger.tighten(maximumInputBytes: 20, maximumKeys: 1);
    ledger.tighten(maximumInputBytes: 64 * 1024 * 1024, maximumKeys: 1024);
    expect(begin(ledger, 3, 1), isFalse);
    expect(begin(ledger, 1, 40), isFalse);
    expect(ledger.loaded(hash: hash(1), family: 'family-1'), isTrue);
    expect(ledger.attemptedCount, 2);
    expect(ledger.chargedInputBytes, 70);
  });

  test('零预算暂停新的注册但不清除已成功的记录', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 1), isTrue);
    ledger.completeNativeAttempt(hash: hash(1), family: 'family-1');
    ledger.tighten(maximumInputBytes: 0, maximumKeys: 0);
    expect(begin(ledger, 2, 1), isFalse);
    expect(ledger.loaded(hash: hash(1), family: 'family-1'), isTrue);
  });

  test('无效输入不污染账本，负数策略整体拒绝', () {
    final ledger = TextFontNativeLedger();
    expect(begin(ledger, 1, 0), isFalse);
    expect(begin(ledger, 1, -1), isFalse);
    expect(
      ledger.beginNativeAttempt(hash: 'bad', family: 'family', inputBytes: 1),
      isFalse,
    );
    expect(
      ledger.beginNativeAttempt(hash: hash(1), family: '', inputBytes: 1),
      isFalse,
    );
    expect(
      () => ledger.tighten(maximumInputBytes: 1, maximumKeys: -1),
      throwsArgumentError,
    );
    expect(ledger.maximumInputBytes, 64 * 1024 * 1024);
    expect(ledger.attemptedCount, 0);
    expect(ledger.chargedInputBytes, 0);
  });

  test('未预留不能标记原生加载成功', () {
    final ledger = TextFontNativeLedger();
    expect(
      () => ledger.completeNativeAttempt(hash: hash(1), family: 'family-1'),
      throwsStateError,
    );
    expect(ledger.loadedCount, 0);
  });
}

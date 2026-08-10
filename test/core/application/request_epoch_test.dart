import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/request_epoch.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';

void main() {
  test('新请求和显式失效都会拒绝旧异步结果', () {
    final epoch = RequestEpoch();
    final first = epoch.begin();
    expect(epoch.isCurrent(first), isTrue);

    final second = epoch.begin();
    expect(epoch.isCurrent(first), isFalse);
    expect(epoch.isCurrent(second), isTrue);

    epoch.invalidate();
    expect(epoch.isCurrent(second), isFalse);
  });

  test('分页合并保留既有顺序并忽略跨页重复项', () {
    final merged = mergeUniqueBy(
      const [_Item('1'), _Item('2')],
      const [_Item('2'), _Item('3')],
      keyOf: (item) => item.id,
    );

    expect(merged.map((item) => item.id), ['1', '2', '3']);
    expect(() => merged.add(const _Item('4')), throwsUnsupportedError);
  });
}

class _Item {
  const _Item(this.id);

  final String id;
}

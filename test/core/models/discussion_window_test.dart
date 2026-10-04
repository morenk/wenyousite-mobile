import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';

void main() {
  DiscussionWindow<int> page(int start, int total) => DiscussionWindow(
    items: [for (var i = start; i < start + 20 && i <= total; i++) i],
    total: total,
    maxNumber: total,
    beforeCursor: start > 1 ? 'before-$start' : null,
    afterCursor: start + 20 <= total ? 'after-${start + 19}' : null,
  );

  for (final total in [1000, 5000, 10000]) {
    test('$total 条连续读到末尾仍最多保留120条且可反向分页', () {
      var buffer = DiscussionWindowBuffer(page(1, total));
      for (var start = 21; start < total; start += 20) {
        buffer = buffer.extend(
          page(start, total),
          before: false,
          idOf: (i) => '$i',
        );
        expect(buffer.items.length, lessThanOrEqualTo(120));
      }
      expect(buffer.items.last, total);
      expect(buffer.beforeCursor, 'before-${total - 119}');
      expect(buffer.afterCursor, isNull);
      final previousStart = total - 139;
      buffer = buffer.extend(
        page(previousStart, total),
        before: true,
        idOf: (i) => '$i',
      );
      expect(buffer.items.first, previousStart);
      expect(buffer.items.last, total - 20);
      expect(buffer.afterCursor, 'after-${total - 20}');
    });
  }

  test('读者在请求期间折返时，迟到的新页不挤掉其锚点', () {
    var buffer = DiscussionWindowBuffer(page(1, 1000));
    for (var start = 21; start <= 101; start += 20) {
      buffer = buffer.extend(
        page(start, 1000),
        before: false,
        idOf: (i) => '$i',
      );
    }
    final next = buffer.extend(
      page(121, 1000),
      before: false,
      idOf: (i) => '$i',
      visibleId: '4',
    );
    expect(identical(next, buffer), isTrue);
    expect(next.items, contains(4));
  });
}

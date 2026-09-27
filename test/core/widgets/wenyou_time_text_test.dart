import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';

void main() {
  final now = DateTime(2026, 9, 20, 12);
  final cases = <Duration, String>{
    const Duration(seconds: 59): '刚刚',
    const Duration(minutes: 1): '1 分钟前',
    const Duration(seconds: 3599): '59 分钟前',
    const Duration(hours: 1): '1 小时前',
    const Duration(seconds: 86399): '23 小时前',
    const Duration(days: 1): '1 天前',
    const Duration(seconds: 259199): '2 天前',
    const Duration(days: 3): '09-17',
    const Duration(minutes: -1): '09-20',
  };
  for (final entry in cases.entries) {
    testWidgets('共享内容时间边界 ${entry.key.inSeconds} 秒', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WenyouTimeText(value: now.subtract(entry.key), reference: now),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('跨年日期与读屏保留上下文，普通内容不读时分', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WenyouTimeText(
          value: DateTime(2025, 12, 31, 23, 50),
          reference: now,
          prefix: '子贴 · ',
          semanticsPrefix: '子贴，发布时间：',
          suffix: ' · 已编辑',
        ),
      ),
    );
    expect(find.text('子贴 · 2025-12-31 · 已编辑'), findsOneWidget);
    expect(find.bySemanticsLabel('子贴，发布时间：2025-12-31 · 已编辑'), findsOneWidget);
  });

  test('带时区输入先转本地日期，精确业务仍保留时分', () {
    final local = DateTime(2026, 9, 21, 0, 30);
    final utc = local.toUtc();
    expect(formatWenyouDate(utc), '2026-09-21');
    expect(formatWenyouTime(utc, reference: DateTime(2026, 9, 25)), '09-21');
    expect(formatWenyouExactTime(utc), '2026-09-21 00:30');
  });
}

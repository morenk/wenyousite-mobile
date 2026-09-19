import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reliable_snack_bar.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

void main() {
  testWidgets('尚未实际显示就切后台不消费，恢复后首次显示才确认', (tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    addTearDown(() {
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    final delivered = <Object>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WenyouReliableSnackBar(
          deliveryScope: 'account-day',
          receipt: const WenyouSnackBarReceipt(id: 'today', message: '签到奖励'),
          onDelivered: delivered.add,
          child: const Scaffold(body: Text('内容')),
        ),
      ),
    );
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(delivered, isEmpty);
    expect(find.text('签到奖励'), findsNothing);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('签到奖励'), findsOneWidget);
    expect(delivered, ['today']);
  });

  testWidgets('首次实际显示仅确认一次，消费回执后仍显示四秒', (tester) async {
    WenyouSnackBarReceipt? receipt = const WenyouSnackBarReceipt(
      id: 'today',
      message: '签到奖励',
    );
    final delivered = <Object>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) => WenyouReliableSnackBar(
            deliveryScope: 'account-day',
            receipt: receipt,
            onDelivered: (id) {
              delivered.add(id);
              setState(() => receipt = null);
            },
            child: const Scaffold(body: Text('内容')),
          ),
        ),
      ),
    );
    expect(delivered, isEmpty);
    await tester.pumpAndSettle();
    expect(delivered, ['today']);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    // A shared messenger may report visibility from multiple Scaffolds.
    snackBar.onVisible!();
    snackBar.onVisible!();
    await tester.pump();
    expect(delivered, ['today']);
    expect(snackBar.duration, wenyouExtendedSnackBarDuration);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('签到奖励'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('签到奖励'), findsNothing);
    expect(delivered, ['today']);
  });

  testWidgets('已消费提示在日期或账号作用域变化后移除', (tester) async {
    var scope = 'account-day-1';
    WenyouSnackBarReceipt? receipt = const WenyouSnackBarReceipt(
      id: 'day-1',
      message: '昨日签到奖励',
    );
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return WenyouReliableSnackBar(
              deliveryScope: scope,
              receipt: receipt,
              onDelivered: (_) => setState(() => receipt = null),
              child: const Scaffold(body: Text('内容')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(receipt, isNull);
    expect(find.text('昨日签到奖励'), findsOneWidget);
    rebuild(() => scope = 'account-day-2');
    await tester.pumpAndSettle();
    expect(find.text('昨日签到奖励'), findsNothing);
    rebuild(() {
      receipt = const WenyouSnackBarReceipt(id: 'day-2', message: '今日签到奖励');
    });
    await tester.pumpAndSettle();
    expect(find.text('今日签到奖励'), findsOneWidget);
    expect(receipt, isNull);
  });
}

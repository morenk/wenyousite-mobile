import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reliable_snack_bar.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

void main() {
  for (final accessible in [false, true]) {
    for (final interruption in ['重建', '前后台', '普通反馈', '滑动', '隐藏', '移除', '超时']) {
      testWidgets('$interruption 后不重播，无障碍导航=$accessible', (tester) async {
        _resume(tester);
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        late StateSetter rebuild;
        WenyouSnackBarReceipt? receipt = _receipt('today');
        final delivered = <Object>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            scaffoldMessengerKey: messengerKey,
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    accessibleNavigation: accessible,
                    disableAnimations: accessible,
                  ),
                  child: WenyouReliableSnackBar(
                    deliveryScope: 'account-day',
                    receipt: receipt,
                    onDelivered: (id) {
                      delivered.add(id);
                      setState(() => receipt = null);
                    },
                    child: const Scaffold(body: Text('内容')),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('奖励 today'), findsOneWidget);
        expect(delivered, ['today']);
        switch (interruption) {
          case '重建':
            for (var index = 0; index < 3; index++) {
              rebuild(() {});
              await tester.pumpAndSettle();
              expect(delivered, ['today']);
            }
          case '前后台':
            for (var index = 0; index < 3; index++) {
              tester.binding.handleAppLifecycleStateChanged(
                AppLifecycleState.inactive,
              );
              tester.binding.handleAppLifecycleStateChanged(
                AppLifecycleState.hidden,
              );
              tester.binding.handleAppLifecycleStateChanged(
                AppLifecycleState.paused,
              );
              await tester.pumpAndSettle();
              tester.binding.handleAppLifecycleStateChanged(
                AppLifecycleState.resumed,
              );
              await tester.pumpAndSettle();
              expect(find.text('奖励 today'), findsNothing);
            }
          case '普通反馈':
            for (final message in ['已收藏', '已取消收藏', '已收藏']) {
              messengerKey.currentState!.showWenyouSnackBar(message);
              await tester.pumpAndSettle();
              expect(find.text(message), findsOneWidget);
              expect(find.text('奖励 today'), findsNothing);
            }
          case '滑动':
            await tester.drag(find.byType(SnackBar), const Offset(0, 500));
          case '隐藏':
            messengerKey.currentState!.hideCurrentSnackBar();
          case '移除':
            messengerKey.currentState!.removeCurrentSnackBar();
          case '超时':
            await tester.pump(wenyouExtendedSnackBarDuration);
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        rebuild(() {});
        await tester.pumpAndSettle();
        expect(find.text('奖励 today'), findsNothing);
        expect(delivered, ['today']);
      });
    }
  }

  testWidgets('尚未显示时连续操作反馈只保留最新提示，结束后回执显示一次', (tester) async {
    _resume(tester);
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    late StateSetter rebuild;
    WenyouSnackBarReceipt? receipt;
    final delivered = <Object>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: messengerKey,
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return WenyouReliableSnackBar(
              deliveryScope: 'account-day',
              receipt: receipt,
              onDelivered: delivered.add,
              child: const Scaffold(body: Text('内容')),
            );
          },
        ),
      ),
    );
    messengerKey.currentState!.showWenyouSnackBar('操作 1');
    rebuild(() => receipt = _receipt('today'));
    await tester.pumpAndSettle();
    messengerKey.currentState!.showWenyouSnackBar('操作 2');
    messengerKey.currentState!.showWenyouSnackBar('操作 3');
    await tester.pumpAndSettle();
    expect(find.text('操作 3'), findsOneWidget);
    expect(find.text('奖励 today'), findsNothing);
    expect(delivered, isEmpty);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('奖励 today'), findsOneWidget);
    expect(delivered, ['today']);
    messengerKey.currentState!.showWenyouSnackBar('操作 4');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    // Even if the owner has not removed the receipt, the host never replays it.
    expect(find.text('奖励 today'), findsNothing);
    expect(delivered, ['today']);
  });

  for (final replacement in ['次日', '切号', '退出']) {
    testWidgets('尚未显示的旧回执$replacement 后不能消费新回执', (tester) async {
      _resume(tester);
      var scope = 'old';
      WenyouSnackBarReceipt? receipt = _receipt('old');
      final delivered = <Object>[];
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
                onDelivered: (id) {
                  delivered.add(id);
                  if (receipt?.id == id) setState(() => receipt = null);
                },
                child: const Scaffold(body: Text('内容')),
              );
            },
          ),
        ),
      );
      await tester.pump();
      final oldVisibility = tester
          .widget<SnackBar>(find.byType(SnackBar))
          .onVisible!;
      rebuild(() {
        scope = replacement;
        receipt = replacement == '退出' ? null : _receipt(replacement);
      });
      await tester.pump();
      oldVisibility();
      await tester.pumpAndSettle();
      expect(find.text('奖励 old'), findsNothing);
      expect(delivered, replacement == '退出' ? isEmpty : [replacement]);
      expect(receipt, isNull);
    });
  }
}

WenyouSnackBarReceipt _receipt(String id) =>
    WenyouSnackBarReceipt(id: id, message: '奖励 $id');

void _resume(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  addTearDown(() {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
}

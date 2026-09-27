import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/settings/presentation/appearance_settings_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/background_reminder_settings_panel.dart';

void main() {
  for (final background in [false, true]) {
    testWidgets('${background ? '后台提醒' : '省流量'} 读取失败重试只读，保存失败按原目标重试', (
      tester,
    ) async {
      final store = _Store();
      final container = ProviderContainer(
        overrides: [
          dataSaverPreferenceStoreProvider.overrideWithValue(store),
          initialDataSaverPreferenceStateProvider.overrideWithValue(
            const DataSaverPreferenceState(
              readFailed: true,
              failureMessage: '读取失败',
            ),
          ),
          backgroundReminderPreferenceStoreProvider.overrideWithValue(store),
          initialBackgroundReminderPreferenceProvider.overrideWithValue(
            const BackgroundReminderPreferenceState(
              enabled: false,
              readFailed: true,
              failureMessage: '读取失败',
            ),
          ),
          backgroundExecutionGatewayProvider.overrideWithValue(_Execution()),
        ],
      );
      addTearDown(container.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 900);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: background
                ? const Scaffold(
                    body: WenyouSettingsBody(
                      children: [BackgroundReminderSettingsPanel()],
                    ),
                  )
                : const AppearanceSettingsPage(),
          ),
        ),
      );
      final retryKey = Key(
        background ? 'background-reminder-retry' : 'data-saver-retry',
      );
      await tester.ensureVisible(find.byKey(retryKey));
      await tester.tap(find.byKey(retryKey));
      await tester.pumpAndSettle();
      expect(store.reads, 1);
      expect(store.writes, isEmpty);
      expect(find.text('读取失败'), findsNothing);
      store.failWrite = true;
      final toggle = find.byKey(
        Key(background ? 'background-reminder-toggle' : 'cover-data-saver'),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(store.writes, [true]);
      // 后台提醒回滚，省流量保留本次运行选择；重试都必须写入原目标 true。
      expect(tester.widget<SwitchListTile>(toggle).value, !background);
      expect(find.byType(WenyouSettingsFailure), findsOneWidget);
      store.failWrite = false;
      store.pending = Completer<void>();
      await tester.ensureVisible(find.byKey(retryKey));
      await tester.tap(find.byKey(retryKey));
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
      expect(store.writes, [true, true]);
      store.pending!.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(find.byType(WenyouSettingsFailure), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

class _Store
    implements DataSaverPreferenceStore, BackgroundReminderPreferenceStore {
  int reads = 0;
  final writes = <bool>[];
  bool failWrite = false;
  Completer<void>? pending;
  @override
  Future<bool> read() async {
    reads++;
    return false;
  }

  @override
  Future<void> write(bool value) async {
    writes.add(value);
    if (failWrite) throw StateError('save failed');
    await pending?.future;
  }
}

class _Execution extends UnsupportedBackgroundExecutionGateway {
  @override
  bool get isSupported => true;
}

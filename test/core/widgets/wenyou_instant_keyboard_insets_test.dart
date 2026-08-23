import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_instant_keyboard_insets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android 目标高度在第一帧替换逐帧键盘 inset',
    (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(720, 1520);
      tester.view.viewInsets = const FakeViewPadding(bottom: 80);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
      addTearDown(() {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: WenyouInstantKeyboardInsets(
            child: Builder(
              builder: (context) => Text(
                MediaQuery.viewInsetsOf(context).bottom.toString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );
      expect(find.text('40.0'), findsOneWidget);

      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final completer = Completer<void>();
      await messenger.handlePlatformMessage(
        WenyouInstantKeyboardInsets.channelName,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('keyboardInsetTargetChanged', {
            'bottomPhysicalPixels': 600.0,
          }),
        ),
        (_) => completer.complete(),
      );
      await completer.future;
      await tester.pump();

      expect(find.text('300.0'), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('300.0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('300.0'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    '后台与恢复期间不会重新暴露引擎残留的键盘高度',
    (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(720, 1520);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);

      await tester.pumpWidget(
        MaterialApp(
          home: WenyouInstantKeyboardInsets(
            child: Builder(
              builder: (context) => Text(
                MediaQuery.viewInsetsOf(context).bottom.toString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      await _sendKeyboardTarget(600);
      await tester.pump();
      expect(find.text('300.0'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('0.0'), findsOneWidget);

      await _sendKeyboardTarget(640);
      await tester.pump();
      expect(find.text('0.0'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('0.0'), findsOneWidget);

      await _sendKeyboardTarget(600);
      await tester.pump();
      expect(find.text('300.0'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    '完整后台生命周期保持中性高度直到前台新回调',
    (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(720, 1520);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
      addTearDown(() {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: WenyouInstantKeyboardInsets(
            child: Builder(
              builder: (context) => Text(
                MediaQuery.viewInsetsOf(context).bottom.toString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      await _sendKeyboardTarget(600);
      await tester.pump();
      expect(find.text('300.0'), findsOneWidget);

      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
        expect(find.text('0.0'), findsOneWidget);
      }

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('0.0'), findsOneWidget);

      await _sendKeyboardTarget(0);
      await tester.pump();
      expect(find.text('0.0'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    '非 Android 平台继续使用引擎提供的键盘高度',
    (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(720, 1520);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
      addTearDown(() {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: WenyouInstantKeyboardInsets(
            child: Builder(
              builder: (context) => Text(
                MediaQuery.viewInsetsOf(context).bottom.toString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      expect(find.text('300.0'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('300.0'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('300.0'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}

Future<void> _sendKeyboardTarget(double bottom) async {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final completer = Completer<void>();
  await messenger.handlePlatformMessage(
    WenyouInstantKeyboardInsets.channelName,
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('keyboardInsetTargetChanged', {
        'bottomPhysicalPixels': bottom,
      }),
    ),
    (_) => completer.complete(),
  );
  await completer.future;
}

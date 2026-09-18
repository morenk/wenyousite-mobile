import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
  testWidgets('图标按钮合并业务朗读并在处理中移除点击动作', (tester) async {
    var calls = 0;
    var loading = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => WenyouAsyncIconButton(
              icon: WenyouIconIds.actionMore,
              label: '管理收藏',
              semanticLabel: '管理收藏：长标题',
              loadingLabel: '正在移动收藏：长标题',
              isLoading: loading,
              onPressed: () {
                calls++;
                setState(() => loading = true);
              },
            ),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('管理收藏：长标题'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.bySemanticsLabel('正在移动收藏：长标题'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('正在移动收藏：长标题')),
      matchesSemantics(
        label: '正在移动收藏：长标题',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        isLiveRegion: true,
      ),
    );
    await tester.tap(find.byType(IconButton));
    expect(calls, 1);
  });

  testWidgets('异步按钮在处理期间保留文字宽度且不能再次提交', (tester) async {
    var calls = 0;
    var loading = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return WenyouAsyncButton(
                  label: '保存当前修改',
                  isLoading: loading,
                  onPressed: () {
                    calls++;
                    update(() => loading = true);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    final button = find.byType(FilledButton);
    final before = tester.getSize(button);
    await tester.tap(button);
    await tester.pump();
    expect(tester.getSize(button), before);
    await tester.tap(button);
    expect(calls, 1);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(find.bySemanticsLabel('保存当前修改，处理中'), findsOneWidget);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final variant in WenyouAsyncButtonVariant.values) {
      testWidgets('${theme.brightness} $variant 支持大字号长文案与危险操作', (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var loading = false;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 180,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        update = setState;
                        return WenyouAsyncButton(
                          label: '永久删除当前选择的内容',
                          variant: variant,
                          tone: WenyouAsyncButtonTone.destructive,
                          isLoading: loading,
                          onPressed: () => update(() => loading = true),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final button = find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        );
        final before = tester.getSize(button);
        expect(before.height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
        final style = tester.widget<ButtonStyleButton>(button).style!;
        expect(
          style.foregroundColor!.resolve({}),
          variant == WenyouAsyncButtonVariant.filled
              ? theme.colorScheme.onError
              : theme.colorScheme.error,
        );
        await tester.tap(button);
        await tester.pump();
        expect(tester.getSize(button), before);
        expect(tester.takeException(), isNull);
        expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);
      });
    }
  }
}

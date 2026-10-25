import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_heading_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_tool_area.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

class _Colors implements EditorTextColorPreferenceStore {
  @override
  Future<List<String>> read(String accountId) async => [];
  @override
  Future<void> write(String accountId, List<String> colors) async {}
}

void main() {
  testWidgets('640x400/2x/180键盘：T工具区适应生产父约束且主栏保持可操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final session = RichEditorSession(
      initialMarkdown: 'A',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              textFontSupported: true,
              textFontWriteEnabled: true,
            ),
          ),
          sessionScopeProvider.overrideWithValue(
            const SessionScope(accountId: 'fixture', generation: 0),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('编辑正文')),
            body: LayoutBuilder(
              // 与主题页面/帖子编辑器一致，将真实剩余高度传给共享工具区。
              builder: (context, constraints) => EditorToolArea(
                availableHeight: constraints.maxHeight,
                child: Column(
                  children: [
                    const Expanded(child: SizedBox.expand()),
                    WenyouEditorToolbar(
                      controller: session.controller,
                      enabled: true,
                      textFont: true,
                      onInsertImage: () async {},
                      onSaveDraft: () async {},
                      textColor: EditorTextColorConfiguration(
                        presets: const [],
                        maximumRecentColors: 4,
                        accountId: 'fixture',
                        store: _Colors(),
                        writeEnabled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('editor-toolbar-dock'))).height,
      lessThanOrEqualTo(164),
    );
    expect(
      tester.getRect(find.byKey(const Key('editor-toolbar-primary'))).bottom,
      lessThanOrEqualTo(220),
    );
    expect(
      find.byKey(const Key('editor-font-picker')).hitTestable(),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('自定义'));
    await tester.pumpAndSettle();
    expect(find.text('自定义').hitTestable(), findsOneWidget);
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-rgb-picker')), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-font-picker')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

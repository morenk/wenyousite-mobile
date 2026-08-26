import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/foundation_icon_finder.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('纵向内容宽度只由可用空间和最大宽度决定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: WenyouConstrainedWidth(
              child: ColoredBox(
                key: Key('full-width-content'),
                color: Colors.pink,
                child: Text('短'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('full-width-content'))).width,
      336,
    );

    tester.view.physicalSize = const Size(900, 240);
    await tester.pump();
    expect(
      tester.getSize(find.byKey(const Key('full-width-content'))).width,
      600,
    );
  });

  testWidgets('图标文字操作等宽排列且不创建胶囊按钮', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 180);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: WenyouIconLabelActionBar(
              key: const Key('icon-label-actions'),
              actions: [
                WenyouIconLabelAction(
                  key: const Key('action-edit'),
                  icon: WenyouIconIds.actionEdit,
                  label: '编辑资料',
                  onPressed: () => pressed = true,
                ),
                const WenyouIconLabelAction(
                  key: Key('action-bookmark'),
                  icon: WenyouIconIds.actionBookmark,
                  label: '收藏',
                  onPressed: null,
                ),
                const WenyouIconLabelAction(
                  key: Key('action-message'),
                  icon: WenyouIconIds.contentThread,
                  label: '私聊',
                  onPressed: null,
                ),
                const WenyouIconLabelAction(
                  key: Key('action-moments'),
                  icon: WenyouIconIds.navigationMoments,
                  label: '动态',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final actions = [
      const Key('action-edit'),
      const Key('action-bookmark'),
      const Key('action-message'),
      const Key('action-moments'),
    ];
    expect(
      actions.map((key) => tester.getSize(find.byKey(key)).width).toSet(),
      hasLength(1),
    );
    expect(
      tester.getSize(find.byKey(actions.first)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('icon-label-actions')),
        matching: find.byType(FilledButton),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('icon-label-actions')),
        matching: find.byType(OutlinedButton),
      ),
      findsNothing,
    );
    final edit = find.byKey(const Key('action-edit'));
    final editIcon = find.descendant(
      of: edit,
      matching: findFoundationIcon(WenyouIconIds.actionEdit),
    );
    expect(
      tester.getCenter(editIcon).dy,
      lessThan(tester.getCenter(find.text('编辑资料')).dy),
    );
    expect(tester.getSemantics(edit).label, '编辑资料');

    await expectLater(
      find.byKey(const Key('icon-label-actions')),
      matchesGoldenFile('goldens/icon_label_actions_320.png'),
    );

    await tester.tap(edit);
    expect(pressed, isTrue);
  });

  testWidgets('悬浮输入入口不压缩正文并保留 48dp 命中区', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          key: const Key('composer-action-visual'),
          body: const SizedBox.expand(key: Key('reading-body')),
          floatingActionButton: WenyouComposerAction(
            key: const Key('composer-dock'),
            label: '发表评论…',
            icon: WenyouIconIds.metricComments,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final dock = find.byKey(const Key('composer-dock'));
    final button = find.descendant(
      of: dock,
      matching: find.byType(FilledButton),
    );
    expect(tester.getSize(button).height, 48);
    expect(tester.getSize(button).width, lessThan(200));
    expect(tester.getBottomRight(button).dx, 344);
    expect(tester.getSize(find.byKey(const Key('reading-body'))).height, 240);

    await expectLater(
      find.byKey(const Key('composer-action-visual')),
      matchesGoldenFile('goldens/composer_action_360.png'),
    );

    await tester.tap(find.text('发表评论…'));
    expect(pressed, isTrue);
  });

  testWidgets('固定阅读操作不会随滚动隐藏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          floatingActionButtonAnimator:
              FloatingActionButtonAnimator.noAnimation,
          floatingActionButton: const Icon(
            Icons.edit_rounded,
            key: Key('reading-action'),
          ),
          body: ListView(
            key: const Key('reading-list'),
            children: const [SizedBox(height: 1600)],
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('reading-list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-action')), findsOneWidget);
  });

  testWidgets('异步主按钮在默认和加载状态都保持 48dp', (tester) async {
    Widget buildButton({required bool isLoading}) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: WenyouAsyncPrimaryButton(
                label: '提交',
                isLoading: isLoading,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildButton(isLoading: false));
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
    expect(find.text('提交'), findsOneWidget);

    await tester.pumpWidget(buildButton(isLoading: true));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('编辑器发送按钮区分可发送、禁用和发送中状态', (tester) async {
    Widget buildButton({required bool enabled, required bool loading}) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: WenyouComposerSubmitButton(
              enabled: enabled,
              loading: loading,
              label: '发送',
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    Future<void> expectColors({
      required Color background,
      required Color foreground,
    }) async {
      final button = tester.widget<IconButton>(find.byType(IconButton));
      final style = button.style!;
      expect(style.backgroundColor!.resolve(<WidgetState>{}), background);
      expect(style.foregroundColor!.resolve(<WidgetState>{}), foreground);
    }

    await tester.pumpWidget(buildButton(enabled: true, loading: false));
    await expectColors(
      background: AppTheme.light.colorScheme.primary,
      foreground: AppTheme.light.colorScheme.onPrimary,
    );

    await tester.pumpWidget(buildButton(enabled: false, loading: false));
    await expectColors(
      background: WenyouThemeTokens.light.border,
      foreground: WenyouThemeTokens.light.mutedText,
    );

    await tester.pumpWidget(buildButton(enabled: false, loading: true));
    await expectColors(
      background: AppTheme.light.colorScheme.primary,
      foreground: AppTheme.light.colorScheme.onPrimary,
    );
    expect(find.bySemanticsLabel('发送，处理中'), findsOneWidget);
  });

  testWidgets('状态提示同时展示图标、信息和请求 ID', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouStatusBanner(
            message: '暂时无法提交',
            detail: '问题编号：request-id',
            tone: WenyouStatusTone.error,
          ),
        ),
      ),
    );

    expect(findFoundationIcon(WenyouIconIds.statusError), findsOneWidget);
    expect(find.text('暂时无法提交'), findsOneWidget);
    expect(find.text('问题编号：request-id'), findsOneWidget);
  });

  testWidgets('失败提示统一从 ApiFailure 展示信息和请求 ID', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouFailureBanner(
            failure: ApiFailure(
              userMessage: '加载没有完成',
              requestId: 'failure-request-id',
            ),
          ),
        ),
      ),
    );

    expect(find.text('加载没有完成'), findsOneWidget);
    expect(find.text('问题编号：failure-request-id'), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.statusError), findsOneWidget);
  });

  testWidgets('首屏加载骨架保持列表结构并发布礼貌 live region', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouListSkeleton(label: '正在加载主题', itemCount: 2),
        ),
      ),
    );

    expect(find.byKey(const Key('wenyou-list-skeleton')), findsOneWidget);
    expect(find.byType(WenyouPanel), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel('正在加载主题'), findsOneWidget);
  });
}

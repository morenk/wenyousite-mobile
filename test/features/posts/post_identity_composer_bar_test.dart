import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet_layout.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_identity_composer_bar.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

import '../../support/deterministic_test_fonts.dart';

import '../../support/thread_identity_fixtures.dart';

class _IdentityRepository extends Mock implements ThreadIdentityRepository {
  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      identityTestCollection(await mine(threadId));
}

const _identity = ThreadIdentityState(
  threadId: 'thread',
  userId: 'account',
  enabled: true,
  eligible: true,
  canEdit: true,
  accountName: '站内用户',
  identityToken: 'confirmed',
  display: RpIdentity(id: 'rp', nickname: '白夜'),
);

void main() {
  setUpAll(loadDeterministicTestFonts);

  Future<PostIdentitySelection> pumpBar(
    WidgetTester tester, {
    ThreadIdentityState identity = _identity,
    bool dark = false,
    bool locked = false,
    PostIdentityMode? restored,
    VoidCallback? onSettings,
  }) async {
    final repository = _IdentityRepository();
    when(() => repository.mine('thread')).thenAnswer((_) async => identity);
    final selection = PostIdentitySelection(repository, 'thread');
    if (restored != null) selection.restore(selected: restored, token: 'old');
    addTearDown(selection.dispose);
    await selection.refresh();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('identity-bar-preview'),
            child: ColoredBox(
              color: dark
                  ? AppTheme.dark.scaffoldBackgroundColor
                  : AppTheme.light.scaffoldBackgroundColor,
              child: PostComposerSheetHeader(
                label: '发表楼层',
                expanded: false,
                onResize: null,
                onToggleExpanded: () {},
                identity: PostIdentityComposerBar(
                  selection: selection,
                  locked: locked,
                  onSettings: (_) => onSettings?.call(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return selection;
  }

  testWidgets('两行选项区分模式，选择原身份后只改变本次选择', (tester) async {
    var settings = 0;
    final selection = await pumpBar(tester, onSettings: () => settings++);
    expect(find.text('发表楼层'), findsNothing);
    expect(find.text('编辑资料'), findsNothing);
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
    expect(selection.mode, PostIdentityMode.account);
    await tester.tap(find.byKey(const Key('post-identity-option-rp-rp')));
    await tester.pumpAndSettle();
    expect(selection.mode, PostIdentityMode.rp);
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
    expect(find.text('帖内身份'), findsOneWidget);
    expect(find.text('站内身份'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-identity-option-account')));
    await tester.pumpAndSettle();
    expect(selection.mode, PostIdentityMode.account);
    expect(selection.acceptedToken, isNull);
    expect(settings, 0);
    expect(find.text('站内用户'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('post-identity-option-settings')),
      findsOneWidget,
    );
    final edit = find.byKey(const Key('thread-identity-edit-rp'));
    expect(tester.getSize(edit).shortestSide, greaterThanOrEqualTo(48));
    expect(
      find.descendant(
        of: find.byKey(const Key('post-identity-option-rp-rp')),
        matching: edit,
      ),
      findsOneWidget,
    );
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(settings, 1);
    expect(selection.mode, PostIdentityMode.account);
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(
      tester.getSemantics(edit),
      matchesSemantics(
        tooltip: '编辑白夜',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        textDirection: TextDirection.ltr,
      ),
    );
    Focus.of(
      tester.element(
        find.descendant(of: edit, matching: find.byType(WenyouIcon)),
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(settings, 2);
    expect(selection.mode, PostIdentityMode.account);
    semantics.dispose();
  });

  for (final eligible in [false, true]) {
    testWidgets('没有RP时菜单用加号设置身份，设置入口遵守资格 $eligible', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var settings = 0;
      final selection = await pumpBar(
        tester,
        onSettings: () => settings++,
        identity: ThreadIdentityState(
          threadId: 'thread',
          userId: 'account',
          enabled: true,
          eligible: eligible,
          canEdit: eligible,
          accountName: '站内用户',
        ),
      );
      expect(find.text('站内用户'), findsOneWidget);
      expect(
        find.byKey(const Key('post-composer-identity-mode')),
        eligible ? findsOneWidget : findsNothing,
      );
      expect(find.text('设置帖内身份'), findsNothing);
      if (eligible) {
        await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('post-identity-option-rp')), findsNothing);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/rp_identity_menu_unset_360.png'),
        );
        await tester.tap(
          find.byKey(const Key('post-identity-option-settings')),
        );
        await tester.pumpAndSettle();
        expect(settings, 1);
        expect(selection.mode, PostIdentityMode.account);
      }
    });
  }

  testWidgets('RP不可用时顶部回到站内头像和用户名，不显示状态提示并保留草稿', (tester) async {
    final selection = await pumpBar(
      tester,
      restored: PostIdentityMode.rp,
      identity: const ThreadIdentityState(
        threadId: 'thread',
        userId: 'account',
        enabled: false,
        eligible: false,
        canEdit: false,
        accountName: '站内用户',
        accountAvatarUrl: 'https://images.invalid/account.png',
      ),
    );
    expect(selection.mode, PostIdentityMode.rp);
    expect(selection.acceptedToken, 'old');
    expect(find.text('帖内身份已变化，待确认'), findsNothing);
    expect(find.text('站内身份'), findsNothing);
    expect(find.text('站内用户'), findsOneWidget);
    expect(
      tester.widget<WenyouAvatar>(find.byType(WenyouAvatar)).avatarUrl,
      'https://images.invalid/account.png',
    );
    expect(find.byKey(const Key('post-identity-option-rp')), findsNothing);
    expect(find.byKey(const Key('post-composer-identity-mode')), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('360dp身份栏视觉候选 $dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await pumpBar(tester, dark: dark);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('identity-bar-preview')),
        matchesGoldenFile(
          'goldens/rp_identity_bar_360_${dark ? 'dark' : 'light'}.png',
        ),
      );
      await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/rp_identity_menu_360_${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
    testWidgets('320dp双倍字号长名选择仍可达 $dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpBar(
        tester,
        dark: dark,
        identity: const ThreadIdentityState(
          threadId: 'thread',
          userId: 'account',
          enabled: true,
          eligible: true,
          canEdit: true,
          accountName: '同名用户',
          identityToken: 'confirmed',
          display: RpIdentity(id: 'rp', nickname: '来自群山的白夜与尚未抵达的漫长旅程以及新的故事'),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.byKey(const Key('post-identity-option-account')),
      );
      await tester.tap(find.byKey(const Key('post-identity-option-account')));
      await tester.pumpAndSettle();
      expect(find.text('同名用户'), findsOneWidget);
    });
  }
}

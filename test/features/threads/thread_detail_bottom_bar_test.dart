import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_app_bar_actions.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_bottom_bar.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('他人主题真实喜欢和累计加油为零时显示0并对齐', (tester) async {
    await _mount(tester, zeroCounts: true);
    for (final key in [
      'thread-interaction-like',
      'thread-interaction-bookmark',
      'thread-subscription-menu',
      'thread-detail-tip',
    ]) {
      final action = find.byKey(Key(key));
      final count = find.descendant(of: action, matching: find.text('0'));
      final icon = find.descendant(
        of: action,
        matching: find.byType(WenyouIcon),
      );
      expect(count, findsOneWidget);
      expect(
        tester.getRect(count).top,
        greaterThanOrEqualTo(tester.getRect(icon).bottom),
      );
    }
    expect(
      tester.getSemantics(find.byKey(const Key('thread-detail-tip'))).label,
      '为创作者加油，累计 0 升',
    );
    expect(find.text('0'), findsNWidgets(4));
    await expectLater(
      find.byKey(const Key('bottom-bar-preview')),
      matchesGoldenFile('goldens/thread_bottom_bar_320_zero_counts.png'),
    );
  });
  testWidgets('旧详情缺收藏订阅总数不伪造0', (tester) async {
    await _mount(tester, unknownCounts: true);
    for (final key in [
      'thread-interaction-bookmark',
      'thread-subscription-menu',
    ]) {
      expect(
        find.descendant(of: find.byKey(Key(key)), matching: find.text('0')),
        findsNothing,
      );
      expect(
        tester.getSemantics(find.byKey(Key(key))).label,
        isNot(contains('0 人')),
      );
    }
  });
  testWidgets('加油与收藏订阅在输入框左侧并沿用原回调', (tester) async {
    var tips = 0;
    await _mount(tester, onTip: () => tips++);
    final tip = find.byKey(const Key('thread-detail-tip'));
    expect(tester.getSize(tip), const Size(48, 48));
    expect(
      tester.getRect(tip).right,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const Key('thread-floor-compose'))).left,
      ),
    );
    await tester.tap(tip);
    expect(tips, 1);
  });
  testWidgets('自己的主题不提供自赏入口', (tester) async {
    await _mount(tester, owner: true);
    expect(find.byKey(const Key('thread-detail-tip')), findsNothing);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
  });
  test('移走加油后没有剩余操作的私密读者不显示空更多菜单', () {
    final detail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestDetail,
      subthreads: threadDetailPageTestDetail.subthreads,
      isPrivate: true,
      isCurrentUserOwner: false,
      isCurrentUserPlayer: false,
    );
    final actions = buildThreadDetailAppBarActions(
      threadId: detail.id,
      state: ThreadDetailState(detail: detail),
      onSearch: () {},
      onLatestTarget: (_) {},
      onSelected: (_) {},
    );
    expect(
      actions.whereType<WenyouAnchoredActionBubble<ThreadDetailAppBarAction>>(),
      isEmpty,
    );
  });
  for (final dark in [false, true]) {
    testWidgets('${dark ? 'dark' : 'light'} 回复入口与私聊输入容器底色边框一致', (tester) async {
      await _mount(tester, dark: dark);
      final replyDecoration =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('thread-floor-compose-field')),
                  )
                  .decoration
              as BoxDecoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const Scaffold(
            bottomNavigationBar: WenyouInlineComposerDock(
              dockKey: Key('private-message-input-reference'),
              editor: SizedBox(height: 48),
              leadingActions: [],
              submitAction: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final messageDecoration =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('private-message-input-reference')),
                  )
                  .decoration
              as BoxDecoration;
      expect(replyDecoration.color, messageDecoration.color);
      expect(replyDecoration.border, messageDecoration.border);
    });
  }
  for (final width in [320, 360, 400]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('$width ${dark ? 'dark' : 'light'} 字号$scale 紧凑输入外观与48dp操作', (
          tester,
        ) async {
          var composeCalls = 0;
          await _mount(
            tester,
            width: width,
            dark: dark,
            scale: scale,
            onCompose: () => composeCalls++,
          );
          final bar = find.byKey(const Key('thread-detail-bottom-bar'));
          final compose = find.byKey(const Key('thread-floor-compose'));
          expect(tester.getSize(compose).width, closeTo(width - 208, .1));
          expect(find.text('回复一下'), findsOneWidget);
          expect(find.text('发表楼层'), findsNothing);
          expect(
            tester.getSize(bar).height,
            closeTo(76, .1),
            reason: '48dp操作行、16dp系统安全区与12dp屏幕圆角留白',
          );
          for (final key in [
            'thread-floor-compose',
            'thread-interaction-like',
            'thread-interaction-bookmark',
            'thread-subscription-menu',
          ]) {
            final bounds = tester.getRect(find.byKey(Key(key)));
            expect(bounds.height, greaterThanOrEqualTo(48), reason: key);
            expect(bounds.width, greaterThanOrEqualTo(48), reason: key);
          }
          final actionKeys = [
            'thread-interaction-like',
            'thread-interaction-bookmark',
            'thread-subscription-menu',
            'thread-detail-tip',
          ];
          double? iconCenter;
          Rect? previousBounds;
          for (final key in actionKeys) {
            final action = find.byKey(Key(key));
            final icon = find.descendant(
              of: action,
              matching: find.byType(WenyouIcon),
            );
            iconCenter ??= tester.getCenter(icon).dy;
            expect(tester.getCenter(icon).dy, closeTo(iconCenter, .1));
            final bounds = tester.getRect(action);
            if (previousBounds != null) {
              expect(bounds.left, greaterThanOrEqualTo(previousBounds.right));
            }
            previousBounds = bounds;
          }
          expect(tester.getRect(find.text('12')).top, greaterThan(iconCenter!));
          final field = tester.getRect(
            find.byKey(const Key('thread-floor-compose-field')),
          );
          expect(field.height, lessThanOrEqualTo(48));
          final text = find.descendant(
            of: compose,
            matching: find.byType(RichText),
          );
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
          );
          await expectLater(
            find.byKey(const Key('bottom-bar-preview')),
            matchesGoldenFile(
              'goldens/thread_bottom_bar_${width}_${dark ? 'dark' : 'light'}_${scale == 1 ? 'normal' : 'large'}.png',
            ),
          );
          await tester.tapAt(
            tester.getRect(compose).topCenter + const Offset(0, 1),
          );
          await tester.pump();
          expect(composeCalls, 1, reason: '输入框视觉边界外的48dp点击壳仍有效');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        });
      }
    }
  }

  testWidgets('游客占位保持回复一下，点击沿原登录入口', (tester) async {
    var authCalls = 0;
    var composeCalls = 0;
    await _mount(
      tester,
      authenticated: false,
      onAuthentication: () => authCalls++,
      onCompose: () => composeCalls++,
    );
    expect(find.text('回复一下'), findsOneWidget);
    expect(find.byKey(const Key('thread-interaction-bookmark')), findsNothing);
    expect(find.byKey(const Key('thread-subscription-menu')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    expect(authCalls, 1);
    expect(composeCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('无发言权限不显示输入入口，互动仍可操作', (tester) async {
    await _mount(tester, canCompose: false);
    expect(find.text('回复一下'), findsNothing);
    expect(find.byKey(const Key('thread-floor-compose')), findsNothing);
    for (final key in [
      'thread-interaction-like',
      'thread-interaction-bookmark',
      'thread-subscription-menu',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget);
      expect(
        tester.getSize(find.byKey(Key(key))).height,
        greaterThanOrEqualTo(48),
      );
    }
    await tester.tap(find.byKey(const Key('thread-interaction-like')));
    await tester.pumpAndSettle();
    expect(find.text('13'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320dp两倍字与大额计数使用回复图标兜底且不溢出', (tester) async {
    await _mount(tester, scale: 2, largeCount: true);
    expect(find.text('1m'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const Key('thread-interaction-bookmark')))
          .label,
      contains('999000 人收藏'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('thread-subscription-menu')))
          .label,
      contains('9900000 人订阅官方更新'),
    );
    final compose = find.byKey(const Key('thread-floor-compose'));
    expect(
      find.descendant(of: compose, matching: find.byType(WenyouIcon)),
      findsOneWidget,
    );
    expect(tester.getSemantics(compose).label, contains('回复一下'));
    expect(tester.getSize(compose).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(compose).height, greaterThanOrEqualTo(48));
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-bottom-bar'))).height,
      lessThanOrEqualTo(92),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('bottom-bar-preview')),
      matchesGoldenFile('goldens/thread_bottom_bar_320_other_large_counts.png'),
    );
  });
}

Future<void> _mount(
  WidgetTester tester, {
  int width = 320,
  bool dark = false,
  double scale = 1,
  bool authenticated = true,
  bool canCompose = true,
  bool largeCount = false,
  bool zeroCounts = false,
  bool unknownCounts = false,
  bool owner = false,
  VoidCallback? onCompose,
  VoidCallback? onAuthentication,
  VoidCallback? onTip,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width.toDouble(), 200);
  tester.view.padding = const FakeViewPadding(bottom: 16);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(
        ThreadDetailPageTestMemoryTokenStore(),
      ),
      sessionRemoteProvider.overrideWithValue(
        ThreadDetailPageTestFakeSessionRemote(),
      ),
      threadInteractionRepositoryProvider.overrideWithValue(
        ThreadDetailPageTestFakeThreadInteractionRepository(),
      ),
      threadSubscriptionRepositoryProvider.overrideWithValue(
        ThreadDetailPageTestFakeThreadSubscriptionRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  if (authenticated) {
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          bottomNavigationBar: RepaintBoundary(
            key: const Key('bottom-bar-preview'),
            child: ThreadDetailBottomBar(
              detail: !unknownCounts || largeCount || owner || zeroCounts
                  ? threadDetailPageTestCopyThreadDetail(
                      threadDetailPageTestDetail,
                      subthreads: threadDetailPageTestDetail.subthreads,
                      likeCount: zeroCounts
                          ? 0
                          : largeCount
                          ? 1000000
                          : null,
                      tipTotal: zeroCounts
                          ? '0'
                          : largeCount
                          ? '1234567'
                          : null,
                      bookmarkCount: unknownCounts
                          ? null
                          : zeroCounts
                          ? 0
                          : largeCount
                          ? 999000
                          : 67,
                      subscriberCount: unknownCounts
                          ? null
                          : zeroCounts
                          ? 0
                          : largeCount
                          ? 9900000
                          : 89,
                      isCurrentUserOwner: owner,
                    )
                  : threadDetailPageTestDetail,
              authenticated: authenticated,
              canCompose: canCompose,
              onRequireAuthentication: onAuthentication ?? () {},
              onCompose: onCompose ?? () {},
              onTip: onTip ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

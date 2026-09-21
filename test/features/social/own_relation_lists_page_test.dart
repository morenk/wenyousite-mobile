import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('粉丝深链默认粉丝页签，回关与取消不移粉丝，按钮样式一致', (tester) async {
    final repository = _Repository(following: false);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('粉丝 1'), findsOneWidget);
    expect(find.text('回关'), findsOneWidget);
    for (final button in tester.widgetList<WenyouAsyncButton>(
      find.byType(WenyouAsyncButton),
    )) {
      expect(button.variant, WenyouAsyncButtonVariant.outlined);
    }
    await tester.tap(find.byKey(const ValueKey('follow-u')));
    await tester.pumpAndSettle();
    expect(find.textContaining('互相关注'), findsOneWidget);
    expect(find.text('关注 1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('unfollow-u')));
    await tester.pumpAndSettle();
    expect(find.text('回关'), findsOneWidget);
    expect(find.text('温柔旅人'), findsOneWidget);
    expect(find.text('关注 0'), findsOneWidget);
    expect(repository.writes, ['follow', 'unfollow']);
  });

  testWidgets('移除确认取消不写入，同帧双击仍保持在途锁，成功只清空粉丝', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('removeFollower-u')));
    await tester.pumpAndSettle();
    expect(find.text('移除粉丝「温柔旅人」？'), findsOneWidget);
    expect(find.text('移除后，对方将不再关注你。不会通知对方，对方仍可重新关注你。'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    final pending = Completer<void>();
    repository.pause = pending.future;
    await tester.tap(find.byKey(const ValueKey('removeFollower-u')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-remove-follower')));
    // 两次激活之间不 pump，第二次仍会调用上一帧的回调。
    await tester.tap(find.byKey(const Key('confirm-remove-follower')));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '取消'))
          .onPressed,
      isNull,
    );
    expect(repository.writes, ['remove']);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('还没有粉丝'), findsOneWidget);
    expect(find.text('关注 1'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('移除失败保留确认框与原行，不明结果只提供刷新且不重复写', (tester) async {
    final repository = _Repository()
      ..failure = const ApiFailure(httpStatus: 403, userMessage: '操作失败');
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('removeFollower-u')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-remove-follower')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(WenyouStatusBanner),
      ),
      findsOneWidget,
    );
    repository.failure = const ApiFailure(httpStatus: 503);
    await tester.tap(find.byKey(const Key('confirm-remove-follower')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('刷新列表'),
      ),
      findsOneWidget,
    );
    final count = repository.writes.length;
    await tester.tap(find.byKey(const Key('confirm-remove-follower')));
    await tester.pumpAndSettle();
    expect(repository.writes.length, count);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('温柔旅人'), findsOneWidget);
  });

  testWidgets('本人公开路径使用本人管理，他人公开列表不显示管理动作', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(repository, owner: 'me'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('removeFollower-u')), findsOneWidget);
    expect(repository.publicOwner, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(repository, owner: 'someone'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('removeFollower-u')), findsNothing);
    expect(repository.publicOwner, 'someone');
  });

  testWidgets('切换页签保留各自滚动位置', (tester) async {
    final repository = _Repository(count: 25);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final followerPosition = tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position
        .pixels;
    await tester.tap(find.text('关注 25'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('粉丝 25'));
    await tester.pumpAndSettle();
    final restored = tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position
        .pixels;
    expect(restored, followerPosition);
  });

  testWidgets('切换会话关闭确认，旧操作不能更新新账号', (tester) async {
    final repository = _Repository();
    final scope = StateProvider(
      (ref) => const SessionScope(accountId: 'me', generation: 1),
    );
    final container = ProviderContainer(
      overrides: [
        sessionScopeProvider.overrideWith((ref) => ref.watch(scope)),
        userRelationListRepositoryProvider.overrideWithValue(repository),
        userRelationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: _routerApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('removeFollower-u')));
    await tester.pumpAndSettle();
    container.read(scope.notifier).state = const SessionScope(
      accountId: 'other',
      generation: 2,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.writes, isEmpty);
  });

  for (final dark in [false, true]) {
    testWidgets('320dp 双倍文字长姓名统一描边且触控不少于48dp dark=$dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1100);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _Repository(username: '温柔而漫长的旅途名字也应该完整可读');
      await tester.pumpWidget(_app(repository, scale: 2, dark: dark));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final key in ['unfollow-u', 'removeFollower-u']) {
        final finder = find.byKey(ValueKey(key));
        expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
        expect(
          tester.widget<WenyouAsyncButton>(finder).variant,
          WenyouAsyncButtonVariant.outlined,
        );
      }
    });
  }

  testWidgets('可选导出粉丝页 Widget 渲染图（非真机验收）', (tester) async {
    if (Platform.environment['WENYOU_RELATION_SCREENSHOTS'] != '1') return;
    final font = File('C:/Windows/Fonts/msyh.ttc');
    if (font.existsSync()) {
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
      await loader.load();
    }
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: _app(_Repository(count: 3, mixed: true)),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(boundary),
      matchesGoldenFile('../../../build/relations-ui-followers.png'),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}

Widget _app(
  _Repository repository, {
  String? owner,
  double scale = 1,
  bool dark = false,
}) => ProviderScope(
  overrides: [
    sessionScopeProvider.overrideWithValue(
      const SessionScope(accountId: 'me', generation: 1),
    ),
    userRelationListRepositoryProvider.overrideWithValue(repository),
    userRelationRepositoryProvider.overrideWithValue(repository),
  ],
  child: _routerApp(owner: owner, scale: scale, dark: dark),
);

Widget _routerApp({String? owner, double scale = 1, bool dark = false}) =>
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      routerConfig: GoRouter(
        initialLocation: '/relations',
        routes: [
          GoRoute(
            path: '/relations',
            builder: (_, _) => UserRelationListPage(
              target: owner == null
                  ? const UserRelationListTarget.current(
                      kind: UserRelationListKind.followers,
                    )
                  : UserRelationListTarget.public(
                      kind: UserRelationListKind.followers,
                      userId: owner,
                    ),
            ),
          ),
          GoRoute(
            path: '/users/:userId',
            name: 'user-profile',
            builder: (_, _) => const Scaffold(body: Text('用户资料')),
          ),
        ],
      ),
    );

class _Repository
    implements
        UserRelationRepository,
        FollowerRemovalRepository,
        UserRelationListRepository {
  _Repository({
    this.following = true,
    this.username = '温柔旅人',
    this.count = 1,
    this.mixed = false,
  });
  bool following;
  bool followedBy = true;
  final String username;
  final int count;
  final bool mixed;
  final writes = <String>[];
  String? publicOwner;
  ApiFailure? failure;
  Future<void>? pause;
  List<UserRelationListItem> get items => List.generate(
    count,
    (index) => UserRelationListItem(
      userId: index == 0 ? 'u' : 'u$index',
      username: index == 0 ? username : '同行的朋友 $index',
      level: 4,
      relatedAt: DateTime(2026, 9, 22),
      viewerIsFollowing: mixed && index == 1 ? false : following,
      viewerIsFollowedBy: followedBy,
    ),
  );
  Future<void> write(String action) async {
    writes.add(action);
    if (pause != null) await pause;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> follow(String id) async {
    await write('follow');
    following = true;
  }

  @override
  Future<void> unfollow(String id) async {
    await write('unfollow');
    following = false;
  }

  @override
  Future<void> removeFollower(String id) async {
    await write('remove');
    followedBy = false;
  }

  @override
  Future<void> block(String id) async {}
  @override
  Future<void> unblock(String id) async {}
  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) async {
    publicOwner = userId;
    return following
        ? items.where((item) => item.viewerIsFollowing == true).toList()
        : [];
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async {
    publicOwner = userId;
    return followedBy ? items : [];
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() async => [];
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_identity_profile_preview.dart';
import 'package:wenyousite_mobile/features/stickers/stickers.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card_content.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('资料卡整面板滚动，窄屏明暗与大字号 $dark $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 720);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final content =
            '> 来自群山的白夜\n\n- 新的故事\n- 漫长旅程\n\n${List.filled(scale == 2 ? 15 : 1, '尚未抵达的漫长旅程。').join('\n\n')}';
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postRepositoryProvider.overrideWithValue(
                _Repository()..read = () async => _post(content: content),
              ),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    child: const Text('打开'),
                    onPressed: () => showWenyouSheet<void>(
                      context: context,
                      builder: (_) => WenyouSheetBody(
                        title: '帖内身份',
                        showHeader: false,
                        slivers: [
                          SliverToBoxAdapter(
                            child: ThreadIdentityCardContent(
                              accountName: '小明',
                              identityEnabled: true,
                              historicalName: '白夜',
                              fromPost: true,
                              roleLabel: '楼主',
                              onOpenAccount: () {},
                              profile: PostIdentityProfilePreview(
                                threadId: 'thread',
                                postId: 'post',
                                onOpenPost: (_) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('打开'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(tester.getSize(find.byType(BottomSheet)).height, lessThan(720));
        if (scale == 1) {
          await expectLater(
            find.byType(BottomSheet),
            matchesGoldenFile(
              'goldens/rp_profile_card_320_${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.ensureVisible(
          find.byKey(const Key('thread-identity-open-account')),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('正文复用原渲染配置且没有回复与管理动作', (tester) async {
    final repo = _Repository()
      ..read = () async =>
          _post(content: '> 引用\n\n- 列表\n\n[@白夜](/users/account)');
    final locations = <String>[];
    await _pump(tester, repo, onOpen: locations.add);
    await tester.pumpAndSettle();
    final body = tester.widget<StickerPostMarkdown>(
      find.byType(StickerPostMarkdown),
    );
    expect(body.data, contains('> 引用'));
    expect(body.bodyFontSize, 17);
    expect(body.bodyHeight, 1.8);
    expect(body.mentionLabels, {'/users/account': '白夜'});
    expect(body.diceLabels['die'], '1d6 = 4');
    expect(body.diceDetails['die']!.results, [4]);
    expect(body.onTapText, isNull);
    expect(body.onLongPressNonText, isNull);
    expect(find.text('真实作者'), findsNothing);
    expect(find.text('编辑'), findsNothing);
    await tester.tap(find.byKey(const Key('identity-profile-source')));
    expect(locations, ['/threads/thread?post=post']);
  });

  testWidgets('楼中楼入口保留父楼及回复定位', (tester) async {
    final locations = <String>[];
    await _pump(
      tester,
      _Repository()..read = () async => _post(reply: true),
      onOpen: locations.add,
    );
    await tester.pumpAndSettle();
    expect(find.text('报名 · #4 · 回复 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('identity-profile-source')));
    expect(locations.single, '/threads/thread/posts/parent/replies?post=post');
  });

  testWidgets('每次打开重新读取原文，不复用上次正文', (tester) async {
    final repo = _Repository()..read = () async => _post(content: '旧正文');
    await _pump(tester, repo);
    await tester.pumpAndSettle();
    expect(_body(tester).data, '旧正文');
    repo.read = () async => _post(content: '当前正文');
    await _pump(tester, repo, opening: 2);
    await tester.pumpAndSettle();
    expect(_body(tester).data, '当前正文');
    expect(repo.reads, 2);
  });

  for (final result in ['deleted', 'foreign', 'missing', 'forbidden']) {
    testWidgets('$result 不显示正文或坐标，统一不可用', (tester) async {
      final repo = _Repository()
        ..read = () async {
          if (result == 'missing' || result == 'forbidden') {
            throw ApiFailure(httpStatus: result == 'missing' ? 404 : 403);
          }
          return _post(
            deleted: result == 'deleted',
            threadId: result == 'foreign' ? 'other' : 'thread',
          );
        };
      await _pump(tester, repo);
      await tester.pumpAndSettle();
      expect(find.text('资料暂不可用'), findsOneWidget);
      expect(find.byType(StickerPostMarkdown), findsNothing);
      expect(find.byKey(const Key('identity-profile-source')), findsNothing);
    });
  }

  testWidgets('网络失败仅资料区域重试，成功后再显示正文', (tester) async {
    final repo = _Repository()
      ..read = () async => throw const ApiFailure(httpStatus: 503);
    await _pump(tester, repo);
    await tester.pumpAndSettle();
    expect(find.text('加载失败，重试'), findsOneWidget);
    repo.read = () async => _post();
    await tester.tap(find.text('加载失败，重试'));
    await tester.pumpAndSettle();
    expect(find.byType(StickerPostMarkdown), findsOneWidget);
    expect(repo.reads, 2);
  });

  testWidgets('权限失效立即移除旧正文，迟到结果不能跨账号显示', (tester) async {
    final next = Completer<PostItem>();
    final repo = _Repository()..read = () async => _post(content: '账号A私有正文');
    var account = 'A';
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(repo),
        sessionScopeProvider.overrideWith(
          (ref) => SessionScope(
            accountId: account,
            generation: account == 'A' ? 1 : 2,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _pump(tester, repo, container: container);
    await tester.pumpAndSettle();
    expect(_body(tester).data, '账号A私有正文');
    repo.read = () => next.future;
    container.read(contentVisibilityRevisionProvider.notifier).advance();
    await tester.pump();
    expect(find.byType(StickerPostMarkdown), findsNothing);
    expect(find.byKey(const Key('identity-profile-loading')), findsOneWidget);
    account = 'B';
    repo.read = () async => throw const ApiFailure(httpStatus: 403);
    container.invalidate(sessionScopeProvider);
    await tester.pump();
    next.complete(_post(content: '迟到的A正文'));
    await tester.pumpAndSettle();
    expect(find.text('资料暂不可用'), findsOneWidget);
    expect(find.byType(StickerPostMarkdown), findsNothing);
  });
}

StickerPostMarkdown _body(WidgetTester tester) =>
    tester.widget(find.byType(StickerPostMarkdown));

Future<void> _pump(
  WidgetTester tester,
  _Repository repo, {
  int opening = 1,
  ValueChanged<String>? onOpen,
  ProviderContainer? container,
}) async {
  final child = MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        child: PostIdentityProfilePreview(
          key: ValueKey(opening),
          threadId: 'thread',
          postId: 'post',
          onOpenPost: onOpen ?? (_) {},
        ),
      ),
    ),
  );
  await tester.pumpWidget(
    container != null
        ? UncontrolledProviderScope(container: container, child: child)
        : ProviderScope(
            overrides: [postRepositoryProvider.overrideWithValue(repo)],
            child: child,
          ),
  );
}

PostItem _post({
  String content = '人物资料',
  bool reply = false,
  bool deleted = false,
  String threadId = 'thread',
}) => PostItem(
  id: 'post',
  threadId: threadId,
  subthreadId: 'child',
  author: const PostAuthor(id: 'account', username: '真实作者', level: 1),
  content: content,
  version: 1,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  isBody: false,
  isDeleted: deleted,
  subthreadTitle: '报名',
  floorNumber: reply ? null : 4,
  parentPostId: reply ? 'parent' : null,
  parentFloorNumber: reply ? 4 : null,
  replyNumber: reply ? 2 : null,
  mentionLabels: const {'/users/account': '白夜'},
  diceRolls: const [
    PostDiceRoll(nodeId: 'die', notation: '1d6', results: [4], total: 4),
  ],
);

class _Repository extends Fake implements PostRepository {
  late Future<PostItem> Function() read;
  int reads = 0;
  @override
  Future<PostItem> fetchPost(String postId) {
    reads++;
    return read();
  }
}

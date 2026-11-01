import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';

import '../../support/scripted_http_client_adapter.dart';
import 'post_replies_page_discussion_fixtures.dart';

// 阅读页的字体/预取监听可持续请求帧；按有界帧推进并断言真实状态，
// 不让 pumpAndSettle 等待整个生产装配的全局空闲。
Future<void> pumpReplies(WidgetTester tester) async {
  for (var frame = 0; frame < 8; frame++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

/// 保留启动、能力映射、API 仓库和讨论 provider 的生产依赖链；
/// 仅替换外部 I/O；默认拒绝写入，能力测试仅显式允许内存创建回包。
class RepliesResumeHarness {
  RepliesResumeHarness({
    this.focusedReplyId,
    ProviderContainer Function(List<Override> overrides)? createContainer,
  }) {
    adapter = ScriptedHttpClientAdapter((request) async {
      if (acceptCreates &&
          request.method == 'POST' &&
          request.path == '/api/v1/subthreads/subthread/posts') {
        final input = request.data as Map<String, dynamic>;
        return ScriptedHttpResponse.json(
          envelope({
            ...replyDto(41),
            'replyToPostId': input['replyToPostId'],
            'clientRequestId': input['clientRequestId'],
          }),
        );
      }
      if (request.method != 'GET') throw StateError('意外写入：${request.path}');
      if (request.path == '/api/v1/posts/root') {
        final gate = rootGate;
        rootGate = null;
        if (gate != null) return gate.future;
        return ScriptedHttpResponse.json(envelope(rootDto()));
      }
      if (request.path != '/api/v1/posts/root/replies/window') {
        throw StateError('意外请求：${request.path}');
      }
      return ScriptedHttpResponse.json(envelope(windowDto(request)));
    });
    dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'))
      ..httpClientAdapter = adapter;
    final ioOverrides = <Override>[
      wenyouApiProvider.overrideWithValue(
        WenyouApi(dio: dio, interceptors: []),
      ),
      metaRepositoryProvider.overrideWithValue(meta),
      mobileUpdateServiceProvider.overrideWithValue(const NoDeviceUpdates()),
      tokenStoreProvider.overrideWithValue(tokenStore),
      sessionRemoteProvider.overrideWithValue(
        PostRepliesPageTestFakeSessionRemote(),
      ),
      postThreadContextLookupProvider.overrideWithValue(
        (_) async =>
            const PostThreadContext(isPrivate: false, canManageThread: false),
      ),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        const PostRepliesPageTestFakePostDiscussionAuthorDirectory(),
      ),
    ];
    container = createContainer != null
        ? createContainer(ioOverrides)
        : ProviderContainer(
            overrides: [...productionProviderOverrides(), ...ioOverrides],
          );
  }

  final String? focusedReplyId;
  final meta = ResumeMetaRepository();
  final tokenStore = PostRepliesPageTestMemoryTokenStore();
  late final ScriptedHttpClientAdapter adapter;
  late final Dio dio;
  late final ProviderContainer container;
  Completer<ScriptedHttpResponse>? rootGate;
  String rootContent = '原楼层';
  bool acceptCreates = false;
  final removed = <int>{};

  PostDiscussionControllerProvider get provider =>
      postDiscussionControllerProvider((
        rootPostId: 'root',
        focusedReplyId: focusedReplyId,
      ));
  PostDiscussionController get controller => container.read(provider.notifier);
  PostDiscussionState get state => container.read(provider);
  List<RequestOptions> get postRequests => adapter.requests;

  Future<void> mount(WidgetTester tester, {bool allowLoading = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: StartupGate(
            child: PostRepliesPage(
              threadId: 'thread',
              rootPostId: 'root',
              focusedReplyId: focusedReplyId,
              timeReference: DateTime.utc(2026, 10, 25),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    if (!allowLoading) {
      expect(
        state.phase,
        PostDiscussionPhase.ready,
        reason:
            '${state.failure} ${state.failure?.cause} '
            '${postRequests.map((request) => request.path)}',
      );
    }
  }

  ReadingQuickScrollController reading(WidgetTester tester) => tester
      .widget<ReadingProgressViewport>(find.byType(ReadingProgressViewport))
      .controller;

  Future<ReadingBookmark> readAt(WidgetTester tester, int number) async {
    final finder = find.byKey(Key('post-reply-reply-$number'));
    await tester.scrollUntilVisible(
      finder,
      350,
      maxScrolls: 100,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('post-replies-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(finder);
    await pumpReplies(tester);
    final scroll = reading(tester).scrollController;
    // 懒列表完成布局后，ensureVisible 的估算偏移不保证条目已经顶齐。
    // 按实际几何位置进入目标回复中段，再验证恢复前台是否保持该位置。
    final viewport = find.byKey(const Key('post-replies-list'));
    final offset =
        scroll.offset +
        tester.getTopLeft(finder).dy -
        tester.getTopLeft(viewport).dy +
        90;
    scroll.jumpTo(
      offset.clamp(
        scroll.position.minScrollExtent,
        scroll.position.maxScrollExtent,
      ),
    );
    await pumpReplies(tester);
    final bookmark = reading(tester).captureBookmark()!;
    expect(bookmark.id, 'reply-$number');
    expect(bookmark.offset, greaterThan(40));
    return bookmark;
  }

  Future<void> resume(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpReplies(tester);
  }

  void expectBookmark(WidgetTester tester, ReadingBookmark before) {
    final after = reading(tester).captureBookmark();
    expect(after?.id, before.id, reason: '恢复前台不应跳离当前回复');
    expect(after?.offset, closeTo(before.offset, 1));
    expect(find.byKey(const Key('post-replies-list')), findsOneWidget);
  }

  void close() {
    container.dispose();
    dio.close(force: true);
  }

  Map<String, Object?> rootDto() => {
    ...replyDto(0),
    'id': 'root',
    'parentPostId': null,
    'replyToPostId': null,
    'replyNumber': null,
    'floorNumber': 1,
    'content': rootContent,
    '_count': {'replies': 40},
    'thread': {'id': 'thread', 'title': '测试主题'},
    'subthread': {'id': 'subthread', 'title': '主线'},
    'parentPost': null,
  };

  Map<String, Object?> windowDto(RequestOptions request) {
    final query = request.queryParameters;
    final numbers = [
      for (var i = 1; i <= 40; i++)
        if (!removed.contains(i) &&
            (query['authorId'] == null || authorId(i) == query['authorId']))
          i,
    ];
    final ordered = query['order'] == 'NEWEST'
        ? numbers.reversed.toList()
        : numbers;
    final target =
        (query['number'] as num?)?.toInt() ??
        int.tryParse(
          (query['postId'] as String? ?? '').replaceFirst('reply-', ''),
        );
    final start = query['cursor'] == null
        ? target == null
              ? 0
              : (ordered.indexOf(target) - 3).clamp(0, ordered.length)
        : int.parse(query['cursor'] as String);
    final items = ordered.skip(start).take(20).toList();
    final end = start + items.length;
    return {
      'items': items.map(replyDto).toList(),
      'pinnedItems': <Object?>[],
      'total': ordered.length,
      'maxNumber': 40,
      'target': target == null
          ? null
          : {'id': 'reply-$target', 'number': target},
      'beforeCursor': start == 0 ? null : '0',
      'afterCursor': end < ordered.length ? '$end' : null,
      'hasBefore': start != 0,
      'hasAfter': end < ordered.length,
    };
  }

  String authorId(int number) => number.isEven ? 'author-1' : 'author-2';

  Map<String, Object?> replyDto(int number) => {
    'id': 'reply-$number',
    'threadId': 'thread',
    'subthreadId': 'subthread',
    'authorId': authorId(number),
    'kind': 'FLOOR',
    'floorNumber': null,
    'replyNumber': number,
    'pinnedAt': null,
    'parentPostId': 'root',
    'replyToPostId': 'root',
    'replyToPost': null,
    'clientRequestId': null,
    'content':
        '回复 $number\n\n${List.filled(7, '阅读正文，每条回复保留可滚动的条目内位置。').join('\n\n')}',
    'version': 1,
    'createdAt': '2026-10-24T08:00:00.000Z',
    'updatedAt': '2026-10-24T08:00:00.000Z',
    'deletedAt': null,
    'diceRolls': <Object?>[],
    'author': {
      'id': authorId(number),
      'username': number.isEven ? '自己' : '他人',
      'avatar': null,
      'level': 1,
    },
  };

  static Map<String, Object?> envelope(Object? data) => {
    'code': 0,
    'message': 'ok',
    'data': data,
  };
}

class ResumeMetaRepository implements MetaRepository {
  int calls = 0;
  bool unrelated = false;
  bool mentions = false;
  bool fonts = false;
  bool fontsV2 = false;
  bool colors = false;
  Completer<ContractInfo>? gate;
  bool fail = false;

  ContractInfo nextContract() => ContractInfo(
    contractVersion: '5.44.0-dev.20261024.2',
    markdownContractVersion: 5,
    stickersEnabled: unrelated,
    roleMentionsSupported: mentions,
    textFontSupported: fonts,
    textFontV2Supported: fontsV2,
    textColorSupported: colors,
  );

  @override
  Future<ContractInfo> fetch() async {
    calls++;
    if (fail) throw StateError('离线');
    return gate?.future ?? nextContract();
  }
}

class NoDeviceUpdates implements MobileUpdateService {
  const NoDeviceUpdates();
  @override
  MobileClientPlatform get platform => MobileClientPlatform.unsupported;
  @override
  Future<InstalledAppInfo> readInstalledApp() => throw StateError('意外设备读取');
  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) => throw StateError('意外安装');
}

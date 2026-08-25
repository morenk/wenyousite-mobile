import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';

void main() {
  testWidgets('普通动态详情不请求评论上下文', (tester) async {
    final repository = _TargetRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('普通评论 0'), findsOneWidget);
    expect(repository.contextCalls, 0);
  });

  testWidgets('远端楼中楼目标直接注入、展开、滚动并只框选目标回复', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final target = _comment(
      id: 'reply-target',
      parentId: 'root-target',
      content: '目标回复',
      createdAt: DateTime.utc(2026, 8, 1, 12),
    );
    final repository = _TargetRepository(
      context: MomentCommentContext(
        root: _root(
          id: 'root-target',
          content: '目标主评论',
          createdAt: DateTime.utc(2026, 8, 1, 11),
          replyCount: 7,
          replies: [target],
        ),
        target: target,
      ),
      rootCount: 28,
    );

    await tester.pumpWidget(_app(repository, targetCommentId: 'reply-target'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(repository.contextCalls, 1);
    expect(repository.replyCalls, 0);
    expect(find.text('目标主评论'), findsOneWidget);
    expect(find.text('目标回复').hitTestable(), findsOneWidget);
    expect(
      find.byKey(const ValueKey('target-frame-reply-target')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('target-frame-root-target')),
      findsNothing,
    );
    expect(find.text('查看全部 7 条回复'), findsOneWidget);
  });

  testWidgets('目标评论不可见时保留动态与普通评论且不提供重试', (tester) async {
    final repository = _TargetRepository(
      contextError: const ApiFailure(
        userMessage: '请求失败',
        httpStatus: 404,
        businessCode: 40415,
      ),
    );

    await tester.pumpWidget(
      _app(repository, targetCommentId: 'hidden-comment'),
    );
    await tester.pumpAndSettle();

    expect(find.text('动态正文'), findsOneWidget);
    expect(find.text('普通评论 0'), findsOneWidget);
    expect(find.text('目标评论已不可见'), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-target-retry')), findsNothing);
  });

  testWidgets('评论上下文临时失败时保留正文并可单独重试定位', (tester) async {
    final repository = _TargetRepository(
      contextError: const ApiFailure(
        userMessage: '温油站暂时不可用，请稍后重试。',
        httpStatus: 503,
        requestId: 'request-503',
      ),
    );

    await tester.pumpWidget(_app(repository, targetCommentId: 'reply-target'));
    await tester.pumpAndSettle();

    expect(find.text('动态正文'), findsOneWidget);
    expect(find.text('普通评论 0'), findsOneWidget);
    expect(find.text('问题编号：request-503'), findsOneWidget);
    final retry = find.byKey(const Key('moment-comment-target-retry'));
    expect(retry, findsOneWidget);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(repository.contextCalls, 2);
  });

  testWidgets('详情下拉刷新会同步失效并重读评论定位上下文', (tester) async {
    final target = MomentComment(
      id: 'root-target',
      momentId: 'moment-1',
      author: _author,
      content: '目标主评论',
      deleted: false,
      canDelete: false,
      createdAt: DateTime.utc(2026, 8, 25, 11),
    );
    final repository = _TargetRepository(
      context: MomentCommentContext(
        root: _root(
          id: 'root-target',
          content: '目标主评论',
          createdAt: target.createdAt,
        ),
        target: target,
      ),
    );
    await tester.pumpWidget(_app(repository, targetCommentId: 'root-target'));
    await tester.pumpAndSettle();
    expect(repository.contextCalls, 1);

    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;

    expect(repository.contextCalls, 2);
  });
}

Widget _app(_TargetRepository repository, {String? targetCommentId}) {
  return ProviderScope(
    overrides: [momentRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: MomentDetailPage(
        momentId: 'moment-1',
        targetCommentId: targetCommentId,
      ),
    ),
  );
}

class _TargetRepository extends Fake implements MomentRepository {
  _TargetRepository({this.context, this.contextError, this.rootCount = 1});

  final MomentCommentContext? context;
  final Object? contextError;
  final int rootCount;
  var contextCalls = 0;
  var replyCalls = 0;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async => _detail();

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    return CursorPage(
      items: [
        for (var index = 0; index < rootCount; index++)
          _root(
            id: 'ordinary-$index',
            content: '普通评论 $index',
            createdAt: DateTime.utc(
              2026,
              8,
              25,
              12,
            ).subtract(Duration(minutes: index)),
          ),
      ],
      hasMore: rootCount > limit,
      cursor: rootCount > limit ? 'ordinary-next' : null,
    );
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async => [];

  @override
  Future<MomentCommentContext> fetchCommentContext({
    required String momentId,
    required String commentId,
  }) async {
    contextCalls += 1;
    final error = contextError;
    if (error != null) throw error;
    return context!;
  }

  @override
  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    replyCalls += 1;
    return const CursorPage(items: [], hasMore: false);
  }
}

const _author = MomentAuthor(id: 'user-1', username: '测试用户', level: 1);

MomentDetail _detail() {
  final createdAt = DateTime.utc(2026, 8, 25, 12);
  return MomentDetail(
    card: MomentCard(
      id: 'moment-1',
      author: _author,
      title: '测试动态',
      contentExcerpt: '动态正文',
      coverType: MomentCoverType.text,
      textCoverTheme: MomentTextCoverTheme.rose,
      imageCount: 0,
      likeCount: 0,
      commentCount: 30,
      bookmarkCount: 0,
      tipTotal: '0',
      viewerLiked: false,
      viewerBookmarked: false,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
    content: '动态正文',
    images: const [],
    version: 1,
    canEdit: true,
    canDelete: true,
  );
}

MomentComment _comment({
  required String id,
  required String parentId,
  required String content,
  required DateTime createdAt,
}) {
  return MomentComment(
    id: id,
    momentId: 'moment-1',
    author: _author,
    content: content,
    parentCommentId: parentId,
    deleted: false,
    canDelete: false,
    createdAt: createdAt,
  );
}

MomentRootComment _root({
  required String id,
  required String content,
  required DateTime createdAt,
  int replyCount = 0,
  List<MomentComment> replies = const [],
}) {
  return MomentRootComment(
    id: id,
    momentId: 'moment-1',
    author: _author,
    content: content,
    deleted: false,
    canDelete: false,
    createdAt: createdAt,
    replyCount: replyCount,
    replies: replies,
  );
}

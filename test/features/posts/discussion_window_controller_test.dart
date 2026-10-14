import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import '../threads/thread_detail_page_collaboration_repositories.dart';

void main() {
  for (final count in [1000, 5000, 10000]) {
    test('两种讨论 $count 条长短正文与图片混排，定位一请求且双向缓存不超过 120', () async {
      final repo = _Repository(count);
      final replies = PostDiscussionController(repo, (
        rootPostId: 'root',
        focusedReplyId: null,
      ), autoStart: false);
      final floors = ThreadDetailController(repo, 'thread', autoStart: false);
      addTearDown(replies.dispose);
      addTearDown(floors.dispose);
      await replies.load();
      await floors.loadInitial();
      final before = repo.requests.length;
      await replies.locate(
        number: count ~/ 2,
        order: PostReplyOrder.oldest,
        authorId: null,
        active: () => true,
      );
      expect(repo.requests.length, before + 1);
      await floors.locate(
        number: count ~/ 2,
        subthreadId: floors.state.selectedSubthreadId!,
        order: ThreadFloorOrder.oldest,
        authorId: null,
        active: () => true,
      );
      expect(repo.requests.length, before + 2);
      expect(floors.state.pinnedFloors, isEmpty);
      for (var i = 0; i < 15; i++) {
        replies.visibleReplyId = replies.state.replies.last.id;
        floors.visibleFloorId = floors.state.floors.last.id;
        await replies.loadAdjacent();
        await floors.loadAdjacent();
        expect(replies.state.replies.length, lessThanOrEqualTo(120));
        expect(floors.state.floors.length, lessThanOrEqualTo(120));
      }
      replies.visibleReplyId = replies.state.replies.first.id;
      floors.visibleFloorId = floors.state.floors.first.id;
      final first = replies.state.replies.first.replyNumber!;
      await replies.loadAdjacent(before: true);
      await floors.loadAdjacent(before: true);
      expect(replies.state.replies.first.replyNumber, lessThan(first));
      expect(floors.state.floors.first.floorNumber, lessThan(first));
      expect(replies.state.replies.length, lessThanOrEqualTo(120));
      expect(floors.state.floors.length, lessThanOrEqualTo(120));
    });
  }

  test('默认置顶独立展示且自然窗口抑制重复，精准定位清空置顶', () async {
    final repo = _Repository(1000);
    final controller = ThreadDetailController(repo, 'thread', autoStart: false);
    addTearDown(controller.dispose);
    await controller.loadInitial();
    expect(controller.state.pinnedFloors.single.id, '3');
    expect(controller.state.floors.where((item) => item.id == '3').length, 1);
    await controller.locate(
      number: 3,
      subthreadId: controller.state.selectedSubthreadId!,
      order: ThreadFloorOrder.newest,
      authorId: null,
      active: () => true,
    );
    expect(controller.state.pinnedFloors, isEmpty);
    expect(controller.state.floors.where((item) => item.id == '3').length, 1);
  });

  test('仅 40010 清作者筛选并重试一次，空筛选仍保留全局编号上界', () async {
    final repo = _Repository(5000);
    final controller = PostDiscussionController(repo, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();
    await controller.setAuthor('excluded');
    expect(controller.state.replies, isEmpty);
    expect(controller.state.maxNumber, 5000);
    final count = repo.requests.length;
    final target = await controller.locate(
      number: 4000,
      order: PostReplyOrder.oldest,
      authorId: 'excluded',
      active: () => true,
    );
    expect(target?.clearedAuthor, isTrue);
    expect(controller.state.authorId, isNull);
    expect(repo.requests.length, count + 2);
    repo.failure = const ApiFailure(httpStatus: 404, userMessage: '目标已不可见');
    final old = controller.state.replies;
    await expectLater(
      controller.locate(
        number: 4500,
        order: PostReplyOrder.oldest,
        authorId: 'excluded',
        active: () => true,
      ),
      throwsA(isA<ApiFailure>()),
    );
    expect(controller.state.replies, same(old));
    expect(repo.requests.length, count + 3);
  });

  test('关闭与切换筛选后迟到定位不覆盖内容，按住滑块时迟到分页不应用', () async {
    final repo = _Repository(1000);
    final controller = PostDiscussionController(repo, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();
    final pending = Completer<void>();
    repo.pending = pending;
    var active = true;
    final jump = controller.locate(
      number: 700,
      order: PostReplyOrder.oldest,
      authorId: null,
      active: () => active,
    );
    active = false;
    pending.complete();
    await jump;
    expect(controller.state.replies.first.replyNumber, 1);
    repo.pending = Completer<void>();
    final page = controller.loadAdjacent();
    controller.canApplyPage = () => false;
    repo.pending!.complete();
    await page;
    expect(controller.state.replies.length, 20);
    expect(controller.state.isLoadingMore, isFalse);
    controller.canApplyPage = () => true;
    repo.pending = Completer<void>();
    final late = controller.locate(
      number: 800,
      order: PostReplyOrder.oldest,
      authorId: null,
      active: () => true,
    );
    final held = repo.pending!;
    repo.pending = null;
    await controller.setOrder(PostReplyOrder.newest);
    held.complete();
    await late;
    expect(controller.state.order, PostReplyOrder.newest);
    expect(controller.state.replies.first.replyNumber, 1000);
  });

  test('编辑定位目标刷新正文，删除定位目标保留邻近项且不重取已删目标', () async {
    final repo = _Repository(1000);
    final replies = PostDiscussionController(repo, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    final floors = ThreadDetailController(repo, 'thread', autoStart: false);
    addTearDown(replies.dispose);
    addTearDown(floors.dispose);
    await replies.load();
    await floors.loadInitial();
    await replies.locate(
      number: 500,
      order: PostReplyOrder.oldest,
      authorId: null,
      active: () => true,
    );
    await floors.locate(
      number: 500,
      subthreadId: floors.state.selectedSubthreadId!,
      order: ThreadFloorOrder.oldest,
      authorId: null,
      active: () => true,
    );
    repo.version = 2;
    await replies.refresh();
    await floors.refresh();
    expect(
      replies.state.replies.firstWhere((item) => item.id == '500').version,
      2,
    );
    expect(
      floors.state.floors.firstWhere((item) => item.id == '500').version,
      2,
    );
    final count = repo.requests.length;
    repo.deleted.add(500);
    await replies.removeDeletedReply('500');
    await floors.removeDeletedFloor('500');
    expect(repo.requests.length, count);
    expect(replies.state.replies.any((item) => item.id == '500'), isFalse);
    expect(floors.state.floors.any((item) => item.id == '500'), isFalse);
    expect(replies.state.replies, isNotEmpty);
    expect(floors.state.floors, isNotEmpty);
    await expectLater(
      replies.locate(
        postId: '500',
        order: PostReplyOrder.oldest,
        authorId: null,
        active: () => true,
      ),
      throwsA(isA<ApiFailure>()),
    );
    expect(replies.state.replies, isNotEmpty);
  });

  test('父讨论分页已不可访问时隐藏已展示内容', () async {
    final repo = _Repository(1000);
    final controller = PostDiscussionController(repo, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();
    repo.failure = const ApiFailure(httpStatus: 404, userMessage: '讨论已不可见');
    await controller.loadAdjacent();
    expect(controller.state.phase, PostDiscussionPhase.restricted);
    expect(controller.state.root, isNull);
    expect(controller.state.replies, isEmpty);
  });
}

class _Repository implements PostRepository, ThreadDetailRepository {
  _Repository(this.count);
  final int count;
  final requests =
      <({int? number, String? id, String? cursor, String? author})>[];
  final deleted = <int>{};
  int version = 1;
  ApiFailure? failure;
  Completer<void>? pending;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<PostItem> fetchPost(String id) async => _post(0);
  @override
  Future<ThreadDetailModel> fetchThread(String id) async =>
      threadDetailPageTestDetail;

  Future<DiscussionWindow<T>> _window<T>({
    required T Function(int) item,
    int? number,
    String? postId,
    String? cursor,
    String? authorId,
    required bool newest,
    bool pins = false,
  }) async {
    requests.add((
      number: number,
      id: postId,
      cursor: cursor,
      author: authorId,
    ));
    final target = number ?? (postId == null ? null : int.parse(postId));
    await pending?.future;
    if (failure != null) throw failure!;
    if (target != null && deleted.contains(target)) {
      throw const ApiFailure(httpStatus: 404, userMessage: '目标已删除');
    }
    if (target != null && authorId == 'excluded') {
      throw const ApiFailure(
        httpStatus: 409,
        businessCode: 40010,
        userMessage: '筛选不包含目标',
      );
    }
    final indices = [
      for (var n = 1; n <= count; n++)
        if (!deleted.contains(n) && authorId != 'excluded') n,
    ];
    final ordered = newest ? indices.reversed.toList() : indices;
    final targetIndex = target == null ? 0 : ordered.indexOf(target);
    final start = cursor == null
        ? (targetIndex - 5).clamp(0, ordered.length)
        : int.parse(cursor);
    final end = (start + 20).clamp(0, ordered.length);
    return DiscussionWindow(
      items: ordered.sublist(start, end).map(item).toList(),
      pinnedItems: pins && target == null && cursor == null
          ? [item(3)]
          : const [],
      total: indices.length,
      maxNumber: count,
      targetId: target?.toString(),
      targetNumber: target,
      beforeCursor: start == 0
          ? null
          : '${(start - 20).clamp(0, ordered.length)}',
      afterCursor: end >= ordered.length ? null : '$end',
    );
  }

  @override
  Future<DiscussionWindow<PostItem>> fetchReplyWindow({
    required String rootPostId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => _window(
    item: _post,
    number: number,
    postId: postId,
    cursor: cursor,
    authorId: authorId,
    newest: order == PostReplyOrder.newest,
  );
  @override
  Future<DiscussionWindow<ThreadFloorModel>> fetchFloorWindow({
    required String subthreadId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) => _window(
    item: _floor,
    number: number,
    postId: postId,
    cursor: cursor,
    authorId: authorId,
    newest: order == ThreadFloorOrder.newest,
    pins: true,
  );
  String _content(int n) => switch (n % 3) {
    0 => '短正文',
    1 => '长正文\n' * 20,
    _ => '![插图](https://media.example.test/$n.webp)\n图片之后的正文',
  };

  PostItem _post(int n) => PostItem(
    id: n == 0 ? 'root' : '$n',
    threadId: 'thread',
    subthreadId: 'scope',
    author: const PostAuthor(id: 'author', username: '作者', level: 1),
    content: _content(n),
    version: version,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isBody: false,
    isDeleted: false,
    floorNumber: n == 0 ? 1 : null,
    replyNumber: n == 0 ? null : n,
    parentPostId: n == 0 ? null : 'root',
  );
  ThreadFloorModel _floor(int n) => ThreadFloorModel(
    id: '$n',
    floorNumber: n,
    author: threadDetailPageTestMainFloor.author,
    body: ThreadBodyModel(markdown: _content(n)),
    createdAt: DateTime(2026),
    isDeleted: false,
    replyCount: 0,
    replies: const [],
    version: version,
  );
}

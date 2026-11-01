import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  test('保存原位更新正文版本、骰子、提及与编辑时间，迟到分页不能覆盖', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final before = controller.state;
    final pending = controller.loadAdjacent();
    final post = _post();
    expect(controller.applySavedFloor(post), isTrue);
    final updated = controller.state.floors.single;
    expect(updated.body.markdown, '已确认的新正文');
    expect(updated.version, 2);
    expect(updated.editedAt, post.editedAt);
    expect(updated.body.mentionLabels, {'mentioned': '已确认显示名'});
    expect(updated.body.diceRolls.single.total, 6);
    expect(updated.replies, before.floors.single.replies);
    expect(controller.state.cursor, before.cursor);
    expect(controller.state.maxNumber, before.maxNumber);
    expect(controller.state.isPrefetchingFloors, isFalse);
    repository.page.complete(
      CursorPage(items: [threadDetailPageTestMainFloor], hasMore: false),
    );
    await pending;
    expect(controller.state.floors.single.body.markdown, '已确认的新正文');
    expect(controller.state.cursor, before.cursor);
  });

  test('保存拒绝其他主题、子贴和较旧版本，后台权限撤回仍清空正文', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    expect(controller.applySavedFloor(_post(threadId: 'other')), isFalse);
    expect(controller.applySavedFloor(_post(subthreadId: 'other')), isFalse);
    controller.applySavedFloor(_post());
    controller.applySavedFloor(_post(version: 1, content: '旧正文'));
    expect(controller.state.floors.single.body.markdown, '已确认的新正文');
    repository.restricted = true;
    await controller.refreshMetadata();
    expect(controller.state.phase, ThreadDetailPhase.failed);
    expect(controller.state.floors, isEmpty);
    expect(controller.state.window, isNull);
  });

  test('保存前已经开始的详情刷新不能重新请求旧正文', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    repository.metadata = Completer();
    final refresh = controller.refresh();
    controller.applySavedFloor(_post());
    repository.metadata!.complete(threadDetailPageTestDetail);
    await refresh;
    expect(controller.state.floors.single.body.markdown, '已确认的新正文');
    expect(controller.state.isRefreshing, isFalse);
  });
}

class _Repository extends ThreadDetailPageTestFakeThreadDetailRepository {
  _Repository() : super(nextFloors: []);
  final page = Completer<CursorPage<ThreadFloorModel>>();
  Completer<ThreadDetailModel>? metadata;
  bool restricted = false;
  @override
  Future<ThreadDetailModel> fetchThread(String threadId) {
    if (restricted) {
      throw const ApiFailure(httpStatus: 403, userMessage: '无权访问');
    }
    return metadata?.future ?? super.fetchThread(threadId);
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) => cursor != null
      ? page.future
      : super.fetchFloors(
          subthreadId: subthreadId,
          order: order,
          authorId: authorId,
        );
}

PostItem _post({
  String threadId = 'thread-1',
  String subthreadId = 'subthread-1',
  int version = 2,
  String content = '已确认的新正文',
}) => PostItem(
  id: 'floor-1',
  threadId: threadId,
  subthreadId: subthreadId,
  author: const PostAuthor(id: 'user-1', username: '测试用户', level: 1),
  content: content,
  version: version,
  createdAt: DateTime.utc(2026, 10, 30),
  updatedAt: DateTime.utc(2026, 10, 31),
  editedAt: DateTime.utc(2026, 10, 31),
  isBody: false,
  isDeleted: false,
  floorNumber: 1,
  mentionLabels: const {'mentioned': '已确认显示名'},
  diceRolls: const [
    PostDiceRoll(nodeId: 'dice', notation: '1d6', results: [6], total: 6),
  ],
);

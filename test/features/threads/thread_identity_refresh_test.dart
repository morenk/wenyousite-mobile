import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class _Repository extends Mock implements ThreadDetailRepository {}

void main() {
  for (final metadataOnly in [true, false]) {
    test('${metadataOnly ? '元数据' : '完整'}刷新发现RP关闭时立即清空旧作者、置顶及提及投影', () async {
      final repository = _Repository();
      var enabled = true;
      when(() => repository.fetchThread('thread')).thenAnswer(
        (_) async => ThreadDetailModel(
          id: 'thread',
          title: '主题',
          owner: const ThreadAuthorModel(id: 'user', username: '账号', level: 1),
          status: ThreadDetailStatus.recruiting,
          isPrivate: false,
          isPinned: false,
          viewCount: 0,
          likeCount: 0,
          tipTotal: '0',
          memberCount: 1,
          playerCount: 1,
          postCount: 1,
          tags: const [],
          subthreads: const [
            ThreadSubthreadModel(
              id: 'sub',
              title: '子贴',
              sortOrder: 1,
              postCount: 1,
              postingPolicyLabel: '所有参与人',
            ),
          ],
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          rpIdentityEnabled: enabled,
        ),
      );
      final old = ThreadFloorModel(
        id: 'old',
        floorNumber: 1,
        author: const ThreadAuthorModel(
          id: 'user',
          username: '账号',
          level: 1,
          rpIdentity: RpIdentity(id: 'rp', nickname: '白鸦'),
        ),
        body: const ThreadBodyModel(
          markdown: '[@白鸦](/users/user)',
          mentionLabels: {'user\u0000白鸦': '白鸦'},
        ),
        createdAt: DateTime.utc(2026),
        isDeleted: false,
        replyCount: 0,
        replies: const [],
        pinnedAt: DateTime.utc(2026),
      );
      final reloaded = Completer<DiscussionWindow<ThreadFloorModel>>();
      var reads = 0;
      when(
        () => repository.fetchFloorWindow(
          subthreadId: 'sub',
          order: ThreadFloorOrder.oldest,
          authorId: null,
        ),
      ).thenAnswer(
        (_) => ++reads == 1
            ? Future.value(
                DiscussionWindow(
                  items: [old],
                  pinnedItems: [old],
                  total: 1,
                  maxNumber: 1,
                ),
              )
            : reloaded.future,
      );
      final controller = ThreadDetailController(
        repository,
        'thread',
        autoStart: false,
      );
      addTearDown(controller.dispose);
      await controller.loadInitial();
      expect(controller.state.floors.single.author.displayName, '白鸦');
      enabled = false;
      final refresh = metadataOnly
          ? controller.refreshMetadata()
          : controller.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.detail!.rpIdentityEnabled, isFalse);
      expect(controller.state.floors, isEmpty);
      expect(controller.state.pinnedFloors, isEmpty);
      expect(controller.state.window, isNull);
      reloaded.complete(
        const DiscussionWindow(items: [], total: 0, maxNumber: 0),
      );
      await refresh;
      expect(reads, 2);
    });
  }
}

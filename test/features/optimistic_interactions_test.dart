import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

const _failure = ApiFailure(userMessage: '操作失败', businessCode: 40300);

void main() {
  test('动态点赞结果不明时回读确认计数，不重复写入', () async {
    final repository = _MomentRepository();
    final card = momentCard('one');
    when(
      () => repository.fetchFeed(mode: MomentFeedMode.discover),
    ).thenAnswer((_) async => CursorPage(items: [card], hasMore: false));
    when(
      () => repository.setLike('one', active: true),
    ).thenThrow(const ApiFailure(userMessage: '操作失败', httpStatus: 500));
    when(() => repository.fetchDetail('one')).thenAnswer(
      (_) async => MomentDetail(
        card: card.copyWith(viewerLiked: true, likeCount: 12),
        content: '正文',
        images: const [],
        version: 1,
        canEdit: false,
        canDelete: false,
      ),
    );
    final controller = MomentFeedController(
      repository,
      const MomentFeedTarget.main(MomentFeedMode.discover),
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    expect(await controller.toggleLike(card), isTrue);
    expect(controller.state.items.single.likeCount, 12);
    expect(controller.state.transientFailure, isNull);
    verify(() => repository.setLike('one', active: true)).called(1);
    verify(() => repository.fetchDetail('one')).called(1);
  });

  for (final liked in [false, true]) {
    test('主题点赞立即切换并回滚：原选中 $liked', () async {
      final repository = _ThreadRepository();
      final pending = Completer<int>();
      when(() => repository.like('thread')).thenAnswer((_) => pending.future);
      when(() => repository.unlike('thread')).thenAnswer((_) => pending.future);
      final controller = ThreadInteractionController(
        repository,
        ThreadInteractionTarget(
          threadId: 'thread',
          isLiked: liked,
          likeCount: 3,
          isBookmarked: false,
        ),
      );
      addTearDown(controller.dispose);
      final operation = controller.toggleLike();
      final during = controller.state;
      expect(await controller.toggleLike(), isFalse);
      pending.completeError(_failure);
      expect(await operation, isFalse);
      expect(during.isLiked, !liked);
      expect(during.likeCount, liked ? 2 : 4);
      expect(controller.state.isLiked, liked);
      expect(controller.state.likeCount, 3);
    });
  }

  for (final bookmarked in [false, true]) {
    test('主题收藏立即切换并回滚：原收藏 $bookmarked', () async {
      final repository = _ThreadRepository();
      final pending = Completer<void>();
      when(() => repository.createBookmark('thread', 'folder')).thenAnswer((
        _,
      ) async {
        await pending.future;
        return 'created';
      });
      when(
        () => repository.removeBookmark('bookmark'),
      ).thenAnswer((_) => pending.future);
      final controller = ThreadInteractionController(
        repository,
        ThreadInteractionTarget(
          threadId: 'thread',
          isLiked: false,
          likeCount: 0,
          isBookmarked: bookmarked,
          bookmarkId: bookmarked ? 'bookmark' : null,
        ),
      );
      addTearDown(controller.dispose);
      final operation = controller.toggleBookmark(folderId: 'folder');
      final during = controller.state;
      pending.completeError(_failure);
      expect(await operation, isFalse);
      expect(during.isBookmarked, !bookmarked);
      expect(controller.state.isBookmarked, bookmarked);
      expect(controller.state.bookmarkId, bookmarked ? 'bookmark' : null);
    });
  }

  test('关注立即更新按钮和人数，失败恢复', () async {
    final repository = _RelationRepository();
    final pending = Completer<void>();
    when(() => repository.follow('user')).thenAnswer((_) => pending.future);
    final controller = UserRelationController(
      repository,
      const UserRelationTarget(
        userId: 'user',
        username: '用户',
        isFollowing: false,
        isBlocked: false,
        isBlockedBy: false,
        followerCount: 4,
      ),
    );
    addTearDown(controller.dispose);
    final operation = controller.toggleFollow();
    final during = controller.state;
    pending.completeError(_failure);
    expect(await operation, isFalse);
    expect(during.isFollowing, isTrue);
    expect(during.followerCount, 5);
    expect(controller.state.isFollowing, isFalse);
    expect(controller.state.followerCount, 4);
  });

  for (final userId in <String?>[null, 'player']) {
    test('订阅立即投影但不伪造记录 ID：$userId', () async {
      final repository = _SubscriptionRepository();
      final pending = Completer<ThreadSubscriptionRecord>();
      when(
        () => repository.fetchSubscriptions('thread'),
      ).thenAnswer((_) async => []);
      when(
        () => repository.fetchCandidates('thread', viewerUserId: null),
      ).thenAnswer(
        (_) async => const [
          ThreadSubscriptionCandidate(
            userId: 'player',
            username: '玩家',
            level: 1,
          ),
        ],
      );
      when(
        () => repository.create(
          threadId: 'thread',
          type: userId == null
              ? ThreadSubscriptionType.thread
              : ThreadSubscriptionType.user,
          targetUserId: userId,
        ),
      ).thenAnswer((_) => pending.future);
      final controller = ThreadSubscriptionController(repository, 'thread');
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      final operation = userId == null
          ? controller.toggleThread()
          : controller.toggleUser(userId);
      expect(
        userId == null
            ? controller.state.isThreadSubscribed
            : controller.state.isUserSubscribed(userId),
        isTrue,
      );
      expect(controller.state.subscriptions, isEmpty);
      await controller.load(); // 在途刷新不会覆盖开关。
      pending.completeError(_failure);
      expect(await operation, isFalse);
      expect(
        userId == null
            ? controller.state.isThreadSubscribed
            : controller.state.isUserSubscribed(userId),
        isFalse,
      );
    });
  }

  for (final bookmark in [false, true]) {
    test('动态互动立即更新，迟到刷新不能覆盖，失败恢复：收藏 $bookmark', () async {
      final repository = _MomentRepository();
      final pending = Completer<MomentActionResult>();
      final stale = Completer<CursorPage<MomentCard>>();
      final original = momentCard('one');
      var reads = 0;
      when(
        () => repository.fetchFeed(mode: MomentFeedMode.discover),
      ).thenAnswer(
        (_) => ++reads == 1
            ? Future.value(CursorPage(items: [original], hasMore: false))
            : stale.future,
      );
      when(
        () => repository.setLike('one', active: true),
      ).thenAnswer((_) => pending.future);
      when(
        () => repository.setBookmark('one', active: true, folderId: 'folder'),
      ).thenAnswer((_) => pending.future);
      final controller = MomentFeedController(
        repository,
        const MomentFeedTarget.main(MomentFeedMode.discover),
        autoStart: false,
      );
      addTearDown(controller.dispose);
      await controller.loadInitial();
      final refresh = controller.refresh();
      final operation = bookmark
          ? controller.toggleBookmark(original, folderId: 'folder')
          : controller.toggleLike(original);
      stale.complete(CursorPage(items: [original], hasMore: false));
      await refresh;
      final during = controller.state.items.single;
      pending.completeError(_failure);
      expect(await operation, isFalse);
      expect(bookmark ? during.viewerBookmarked : during.viewerLiked, isTrue);
      expect(bookmark ? during.bookmarkCount : during.likeCount, 3);
      final after = controller.state.items.single;
      expect(bookmark ? after.viewerBookmarked : after.viewerLiked, isFalse);
      expect(bookmark ? after.bookmarkCount : after.likeCount, 2);
    });
  }

  test('不同动态并行互动，失败只回滚自己的字段', () async {
    final repository = _MomentRepository();
    final first = Completer<MomentActionResult>();
    final second = Completer<MomentActionResult>();
    final cards = [momentCard('one'), momentCard('two')];
    when(
      () => repository.fetchFeed(mode: MomentFeedMode.discover),
    ).thenAnswer((_) async => CursorPage(items: cards, hasMore: false));
    when(
      () => repository.setLike('one', active: true),
    ).thenAnswer((_) => first.future);
    when(
      () => repository.setLike('two', active: true),
    ).thenAnswer((_) => second.future);
    final controller = MomentFeedController(
      repository,
      const MomentFeedTarget.main(MomentFeedMode.discover),
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final a = controller.toggleLike(cards[0]);
    final b = controller.toggleLike(cards[1]);
    second.complete(
      const MomentActionResult(momentId: 'two', active: true, count: 20),
    );
    expect(await b, isTrue);
    first.completeError(_failure);
    expect(await a, isFalse);
    expect(controller.state.items[0].viewerLiked, isFalse);
    expect(controller.state.items[1].viewerLiked, isTrue);
    expect(controller.state.items[1].likeCount, 20);
  });
}

class _ThreadRepository extends Mock implements ThreadInteractionRepository {}

class _RelationRepository extends Mock implements UserRelationRepository {}

class _SubscriptionRepository extends Mock
    implements ThreadSubscriptionRepository {}

class _MomentRepository extends Mock implements MomentRepository {}

MomentCard momentCard(String id) => MomentCard(
  id: id,
  author: const MomentAuthor(id: 'author', username: '作者', level: 1),
  title: '动态',
  contentExcerpt: '正文',
  coverType: MomentCoverType.text,
  textCoverTheme: MomentTextCoverTheme.rose,
  imageCount: 0,
  likeCount: 2,
  commentCount: 0,
  bookmarkCount: 2,
  tipTotal: '0',
  viewerLiked: false,
  viewerBookmarked: false,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

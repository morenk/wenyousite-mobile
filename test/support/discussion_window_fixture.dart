import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

/// 将既有交互测试的静态样例转换为窗口；实际窗口/请求上限由专门测试覆盖。
mixin PostWindowFixture implements PostRepository {
  Future<PostItem?> _postTarget(String id, List<PostItem> items) async {
    final known = items.where((item) => item.id == id).firstOrNull;
    if (known != null) return known;
    try {
      return await fetchPost(id);
    } on StateError {
      return items.firstOrNull;
    } on TypeError {
      return items.firstOrNull;
    }
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
  }) async {
    final page = await fetchReplies(
      rootPostId: rootPostId,
      cursor: cursor,
      limit: limit,
      order: order,
      authorId: authorId,
    );
    final target = postId == null
        ? number == null
              ? null
              : page.items
                    .where((item) => item.replyNumber == number)
                    .firstOrNull
        : await _postTarget(postId, page.items);
    if ((number != null || postId != null) && target == null) {
      throw const ApiFailure(httpStatus: 404, userMessage: '目标回复已不可见。');
    }
    if (target != null &&
        authorId != null &&
        target.author.id != authorId &&
        !page.items.any((item) => item.id == target.id)) {
      throw const ApiFailure(
        httpStatus: 409,
        businessCode: 40010,
        userMessage: '筛选不包含目标回复。',
      );
    }
    final items =
        target != null && !page.items.any((item) => item.id == target.id)
        ? [target]
        : page.items;
    return DiscussionWindow(
      items: items,
      total: items.length,
      maxNumber: items.fold(
        0,
        (max, item) => (item.replyNumber ?? 0) > max ? item.replyNumber! : max,
      ),
      targetId: target?.id,
      targetNumber: target?.replyNumber,
      afterCursor: target == null && page.hasMore ? page.cursor : null,
    );
  }
}

mixin FloorWindowFixture implements ThreadDetailRepository {
  Future<ThreadFloorModel?> _floorTarget(
    String id,
    List<ThreadFloorModel> items,
  ) async {
    final known = items.where((item) => item.id == id).firstOrNull;
    if (known != null) return known;
    try {
      return (await fetchPostTarget(id)).floor;
    } on UnsupportedError {
      return items.firstOrNull;
    } on TypeError {
      return items.firstOrNull;
    }
  }

  @override
  Future<DiscussionWindow<ThreadFloorModel>> fetchFloorWindow({
    required String subthreadId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    final page = await fetchFloors(
      subthreadId: subthreadId,
      cursor: cursor,
      limit: limit,
      order: order,
      authorId: authorId,
    );
    final target = postId == null
        ? number == null
              ? null
              : page.items
                    .where((item) => item.floorNumber == number)
                    .firstOrNull
        : await _floorTarget(postId, page.items);
    if ((number != null || postId != null) && target == null) {
      throw const ApiFailure(httpStatus: 404, userMessage: '目标楼层已不可见。');
    }
    if (target != null &&
        authorId != null &&
        target.author.id != authorId &&
        !page.items.any((item) => item.id == target.id)) {
      throw const ApiFailure(
        httpStatus: 409,
        businessCode: 40010,
        userMessage: '筛选不包含目标楼层。',
      );
    }
    final items =
        target != null && !page.items.any((item) => item.id == target.id)
        ? [target]
        : page.items;
    return DiscussionWindow(
      items: sortThreadFloors(items, order),
      total: items.length,
      maxNumber: items.fold(
        0,
        (max, item) => (item.floorNumber ?? 0) > max ? item.floorNumber! : max,
      ),
      targetId: target?.id,
      targetNumber: target?.floorNumber,
      afterCursor: target == null && page.hasMore ? page.cursor : null,
    );
  }
}

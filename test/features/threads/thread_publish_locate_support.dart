import 'dart:async';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'thread_detail_page_test_support.dart';

class PublishedFloorRepository
    extends ThreadDetailPageTestFakeThreadDetailRepository {
  PublishedFloorRepository({super.mainFloors, super.postTarget});
  final targets = <({String id, String subthread, String? author})>[];
  final requests = <Completer<DiscussionWindow<ThreadFloorModel>>>[];
  bool delayMetadata = false;
  final metadataRequests = <Completer<ThreadDetailModel>>[];

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) {
    if (!delayMetadata) return super.fetchThread(threadId);
    threadCalls++;
    final pending = Completer<ThreadDetailModel>();
    metadataRequests.add(pending);
    return pending.future;
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
  }) {
    if (postId != null && postId.startsWith('published-')) {
      targets.add((id: postId, subthread: subthreadId, author: authorId));
      final pending = Completer<DiscussionWindow<ThreadFloorModel>>();
      requests.add(pending);
      return pending.future;
    }
    return super.fetchFloorWindow(
      subthreadId: subthreadId,
      number: number,
      postId: postId,
      cursor: cursor,
      limit: limit,
      order: order,
      authorId: authorId,
    );
  }
}

PostItem publishedPost(
  int number, {
  String subthread = 'subthread-1',
  String? content,
}) => PostItem(
  id: 'published-$number',
  threadId: 'thread-1',
  subthreadId: subthread,
  author: const PostAuthor(id: 'user-1', username: '温柔测试员', level: 3),
  content: content ?? '已发表的第 $number 楼',
  version: 1,
  createdAt: DateTime.utc(2026, 11, 1),
  updatedAt: DateTime.utc(2026, 11, 1),
  isBody: false,
  isDeleted: false,
  floorNumber: number,
);

DiscussionWindow<ThreadFloorModel> publishedWindow(
  int number, {
  List<ThreadFloorModel> before = const [],
}) => DiscussionWindow(
  items: [
    ...before,
    ThreadFloorModel(
      id: 'published-$number',
      floorNumber: number,
      author: threadDetailPageTestAuthor,
      body: ThreadBodyModel(markdown: '已发表的第 $number 楼'),
      createdAt: DateTime.utc(2026, 11, 1),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    ),
  ],
  total: number,
  maxNumber: number,
  targetId: 'published-$number',
  targetNumber: number,
);

class PublishingPostRepository
    extends ThreadDetailPageTestCreatingPostRepository {
  PublishingPostRepository({this.baseNumber = 1});
  final int baseNumber;
  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    return publishedPost(
      createInputs.length + baseNumber,
      subthread: input.subthreadId,
      content: input.content,
    );
  }
}

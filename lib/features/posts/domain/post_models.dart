import 'package:wenyousite_mobile/core/models/cursor_page.dart';

enum PostReplyOrder {
  oldest('最早回复在前', 'OLDEST'),
  newest('最新回复在前', 'NEWEST');

  const PostReplyOrder(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    required this.level,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final int level;
  final String? avatarUrl;
}

class PostDiceRoll {
  const PostDiceRoll({
    required this.nodeId,
    required this.notation,
    required this.results,
    required this.total,
  });

  final String nodeId;
  final String notation;
  final List<int> results;
  final int total;
}

class PostItem {
  const PostItem({
    required this.id,
    required this.threadId,
    required this.subthreadId,
    required this.author,
    required this.content,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.isBody,
    required this.isDeleted,
    this.floorNumber,
    this.parentPostId,
    this.replyToPostId,
    this.replyToAuthor,
    this.clientRequestId,
    this.replyCount = 0,
    this.threadTitle,
    this.subthreadTitle,
    this.diceRolls = const [],
  });

  final String id;
  final String threadId;
  final String subthreadId;
  final PostAuthor author;
  final String content;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBody;
  final bool isDeleted;
  final int? floorNumber;
  final String? parentPostId;
  final String? replyToPostId;
  final PostAuthor? replyToAuthor;
  final String? clientRequestId;
  final int replyCount;
  final String? threadTitle;
  final String? subthreadTitle;
  final List<PostDiceRoll> diceRolls;

  bool isAuthoredBy(String? userId) => userId != null && author.id == userId;
}

class PostCreateInput {
  const PostCreateInput({
    required this.subthreadId,
    required this.content,
    required this.clientRequestId,
    this.parentPostId,
    this.replyToPostId,
  });

  final String subthreadId;
  final String content;
  final String clientRequestId;
  final String? parentPostId;
  final String? replyToPostId;
}

enum PostComposerKind { createFloor, createReply, editPost, upsertBody }

typedef PostComposerTarget = ({
  PostComposerKind kind,
  String threadId,
  String subthreadId,
  String? postId,
  String? parentPostId,
  String? replyToPostId,
  int? version,
  String initialContent,
  String label,
});

class PendingPostCreate {
  const PendingPostCreate({required this.input});

  final PostCreateInput input;
}

class PostEditConflict {
  const PostEditConflict({required this.latest, required this.pendingContent});

  final PostItem latest;
  final String pendingContent;
}

typedef PostReplyPage = CursorPage<PostItem>;

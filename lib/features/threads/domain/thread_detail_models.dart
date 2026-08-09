class ThreadAuthorModel {
  const ThreadAuthorModel({
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

enum ThreadDetailStatus {
  recruiting('招募中'),
  closed('已关闭'),
  finished('已完结'),
  unknown('状态未知');

  const ThreadDetailStatus(this.label);

  final String label;
}

class ThreadDiceRollModel {
  const ThreadDiceRollModel({
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

class ThreadBodyModel {
  const ThreadBodyModel({required this.markdown, this.diceRolls = const []});

  final String markdown;
  final List<ThreadDiceRollModel> diceRolls;
}

class ThreadTagModel {
  const ThreadTagModel({required this.id, required this.name});

  final String id;
  final String name;
}

class ThreadSubthreadModel {
  const ThreadSubthreadModel({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.postCount,
    required this.postingPolicyLabel,
    this.lastPostAt,
    this.body,
  });

  final String id;
  final String title;
  final int sortOrder;
  final int postCount;
  final String postingPolicyLabel;
  final DateTime? lastPostAt;
  final ThreadBodyModel? body;
}

class ThreadDetailModel {
  const ThreadDetailModel({
    required this.id,
    required this.title,
    required this.owner,
    required this.status,
    required this.isPrivate,
    required this.isPinned,
    required this.viewCount,
    required this.likeCount,
    required this.tipTotal,
    required this.memberCount,
    required this.playerCount,
    required this.postCount,
    required this.tags,
    required this.subthreads,
    required this.createdAt,
    required this.updatedAt,
    this.categorySlug,
    this.defaultSubthreadId,
  });

  final String id;
  final String title;
  final ThreadAuthorModel owner;
  final String? categorySlug;
  final ThreadDetailStatus status;
  final bool isPrivate;
  final bool isPinned;
  final int viewCount;
  final int likeCount;
  final String tipTotal;
  final int memberCount;
  final int playerCount;
  final int postCount;
  final List<ThreadTagModel> tags;
  final List<ThreadSubthreadModel> subthreads;
  final String? defaultSubthreadId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ThreadSubthreadModel? subthreadById(String? id) {
    if (id == null) return null;
    for (final subthread in subthreads) {
      if (subthread.id == id) return subthread;
    }
    return null;
  }

  String? preferredSubthreadId([String? currentId]) {
    if (subthreadById(currentId) != null) return currentId;
    if (subthreadById(defaultSubthreadId) != null) return defaultSubthreadId;
    return subthreads.isEmpty ? null : subthreads.first.id;
  }
}

class ThreadReplyModel {
  const ThreadReplyModel({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
    required this.isDeleted,
    this.replyToUsername,
  });

  final String id;
  final ThreadAuthorModel author;
  final ThreadBodyModel body;
  final DateTime createdAt;
  final bool isDeleted;
  final String? replyToUsername;
}

class ThreadFloorModel {
  const ThreadFloorModel({
    required this.id,
    required this.floorNumber,
    required this.author,
    required this.body,
    required this.createdAt,
    required this.isDeleted,
    required this.replyCount,
    required this.replies,
  });

  final String id;
  final int? floorNumber;
  final ThreadAuthorModel author;
  final ThreadBodyModel body;
  final DateTime createdAt;
  final bool isDeleted;
  final int replyCount;
  final List<ThreadReplyModel> replies;
}

class ThreadPostTargetModel {
  const ThreadPostTargetModel({
    required this.requestedPostId,
    required this.threadId,
    required this.subthreadId,
    required this.floor,
    this.focusedReplyId,
  });

  final String requestedPostId;
  final String threadId;
  final String subthreadId;
  final ThreadFloorModel floor;
  final String? focusedReplyId;
}

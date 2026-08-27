enum SubthreadPostingPolicy {
  participants('所有参与人', '主题参与人都可以在这里发帖'),
  collaborators('仅协作者', '只有楼主和协作者可以发帖'),
  players('仅玩家', '只有被标记为玩家的参与人可以发帖');

  const SubthreadPostingPolicy(this.label, this.description);

  final String label;
  final String description;
}

class SubthreadManagementItem {
  const SubthreadManagementItem({
    required this.id,
    required this.threadId,
    required this.title,
    required this.sortOrder,
    required this.postingPolicy,
    required this.version,
    required this.postCount,
    required this.isDefault,
    this.bodyPostId,
    this.bodyVersion,
    this.body = '',
  });

  final String id;
  final String threadId;
  final String title;
  final int sortOrder;
  final SubthreadPostingPolicy postingPolicy;
  final int version;
  final int postCount;
  final bool isDefault;
  final String? bodyPostId;
  final int? bodyVersion;
  final String body;

  bool get hasBody => body.trim().isNotEmpty;

  SubthreadManagementItem copyWith({
    String? title,
    int? sortOrder,
    SubthreadPostingPolicy? postingPolicy,
    int? version,
    int? postCount,
    bool? isDefault,
    Object? bodyPostId = _unset,
    Object? bodyVersion = _unset,
    String? body,
  }) {
    return SubthreadManagementItem(
      id: id,
      threadId: threadId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      postingPolicy: postingPolicy ?? this.postingPolicy,
      version: version ?? this.version,
      postCount: postCount ?? this.postCount,
      isDefault: isDefault ?? this.isDefault,
      bodyPostId: identical(bodyPostId, _unset)
          ? this.bodyPostId
          : bodyPostId as String?,
      bodyVersion: identical(bodyVersion, _unset)
          ? this.bodyVersion
          : bodyVersion as int?,
      body: body ?? this.body,
    );
  }
}

class SubthreadManagementBootstrap {
  const SubthreadManagementBootstrap({
    required this.threadId,
    required this.threadTitle,
    required this.items,
    this.published = true,
  });

  final String threadId;
  final String threadTitle;
  final List<SubthreadManagementItem> items;
  final bool published;

  SubthreadManagementBootstrap copyWith({
    List<SubthreadManagementItem>? items,
  }) {
    return SubthreadManagementBootstrap(
      threadId: threadId,
      threadTitle: threadTitle,
      items: items ?? this.items,
      published: published,
    );
  }
}

class SubthreadManagementDraft {
  const SubthreadManagementDraft({
    required this.title,
    required this.postingPolicy,
  });

  final String title;
  final SubthreadPostingPolicy postingPolicy;

  String get normalizedTitle => title.trim();

  bool differsFrom(SubthreadManagementItem item) {
    return normalizedTitle != item.title || postingPolicy != item.postingPolicy;
  }
}

const _unset = Object();

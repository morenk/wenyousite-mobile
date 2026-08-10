enum ThreadManagementStatus {
  recruiting('招募中'),
  closed('已关闭'),
  finished('已完结');

  const ThreadManagementStatus(this.label);

  final String label;
}

enum ThreadManagementVisibility {
  public('公开', '所有人都可以查看主题'),
  private('仅成员', '只有主题成员可以查看');

  const ThreadManagementVisibility(this.label, this.description);

  final String label;
  final String description;
}

class ThreadManagementCategory {
  const ThreadManagementCategory({
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.description,
    this.isSelectable = true,
  });

  final String slug;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isSelectable;
}

class ThreadManagementSnapshot {
  const ThreadManagementSnapshot({
    required this.id,
    required this.title,
    required this.categorySlug,
    required this.status,
    required this.visibility,
    required this.version,
    required this.published,
    required this.canManage,
    required this.isOwner,
  });

  final String id;
  final String title;
  final String? categorySlug;
  final ThreadManagementStatus status;
  final ThreadManagementVisibility visibility;
  final int version;
  final bool published;
  final bool canManage;
  final bool isOwner;
}

class ThreadManagementBootstrap {
  const ThreadManagementBootstrap({
    required this.thread,
    required this.categories,
  });

  final ThreadManagementSnapshot thread;
  final List<ThreadManagementCategory> categories;

  ThreadManagementBootstrap copyWith({
    ThreadManagementSnapshot? thread,
    List<ThreadManagementCategory>? categories,
  }) {
    return ThreadManagementBootstrap(
      thread: thread ?? this.thread,
      categories: categories ?? this.categories,
    );
  }
}

class ThreadManagementDraft {
  const ThreadManagementDraft({
    required this.title,
    required this.categorySlug,
    required this.status,
    required this.visibility,
  });

  final String title;
  final String? categorySlug;
  final ThreadManagementStatus status;
  final ThreadManagementVisibility visibility;

  bool differsFrom(ThreadManagementSnapshot snapshot) {
    return title.trim() != snapshot.title ||
        categorySlug != snapshot.categorySlug ||
        status != snapshot.status ||
        visibility != snapshot.visibility;
  }
}

class ThreadManagementConflict {
  const ThreadManagementConflict({required this.latest, required this.pending});

  final ThreadManagementBootstrap latest;
  final ThreadManagementDraft pending;
}

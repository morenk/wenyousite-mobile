import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart'
    show normalizeTagNames;

enum ThreadManagementStatus {
  recruiting('招募中'),
  closed('已停招'),
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
    this.defaultSubthreadId,
    this.defaultSubthreadVersion = 0,
    this.bodyPostId,
    this.bodyVersion,
    this.body = '',
    this.tagNames = const [],
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
  final String? defaultSubthreadId;
  final int defaultSubthreadVersion;
  final String? bodyPostId;
  final int? bodyVersion;
  final String body;
  final List<String> tagNames;
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
    this.body = '',
    this.tagNames = const [],
  });

  final String title;
  final String? categorySlug;
  final ThreadManagementStatus status;
  final ThreadManagementVisibility visibility;
  final String body;
  final List<String> tagNames;

  List<String> get normalizedTagNames => normalizeTagNames(tagNames);

  bool differsFrom(ThreadManagementSnapshot snapshot) {
    return title.trim() != snapshot.title ||
        categorySlug != snapshot.categorySlug ||
        status != snapshot.status ||
        visibility != snapshot.visibility ||
        MarkdownContent.normalize(body) != snapshot.body ||
        !_sameStrings(normalizedTagNames, snapshot.tagNames);
  }

  String? validate(ThreadManagementSnapshot snapshot) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return '请输入主题标题';
    if (normalizedTitle.length > 100) return '标题不能超过 100 个字符';
    if (categorySlug == null) return '请选择主题分区';
    final normalizedBody = MarkdownContent.normalize(body);
    if (normalizedBody.length > 10000) return '正文不能超过 10000 个字符';
    if (MarkdownDiceContract.countMarkdownNodes(normalizedBody) >
        MarkdownDiceContract.maximumNodesPerPost) {
      return '当前正文最多可插入 20 个骰子，请删除一个后重试。';
    }
    if (snapshot.published &&
        snapshot.defaultSubthreadId != null &&
        !MarkdownContent.hasVisibleNonDiceContent(normalizedBody)) {
      return '主题正文需要包含文字，骰子可作为补充。';
    }
    if (normalizedTagNames.length > 5) return '最多添加 5 个标签。';
    final tagPattern = RegExp(r'^[A-Za-z0-9_\u4e00-\u9fff#]+$');
    for (final tag in normalizedTagNames) {
      if (tag.length > 20 || !tagPattern.hasMatch(tag)) {
        return '标签只能包含中英文、数字、下划线和 #，且不超过 20 个字符。';
      }
    }
    return null;
  }
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

class ThreadManagementConflict {
  const ThreadManagementConflict({required this.latest, required this.pending});

  final ThreadManagementBootstrap latest;
  final ThreadManagementDraft pending;
}

import 'package:wenyousite_mobile/core/network/api_failure.dart';

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
  });

  final String id;
  final String threadId;
  final String title;
  final int sortOrder;
  final SubthreadPostingPolicy postingPolicy;
  final int version;
  final int postCount;
  final bool isDefault;

  SubthreadManagementItem copyWith({
    String? title,
    int? sortOrder,
    SubthreadPostingPolicy? postingPolicy,
    int? version,
    int? postCount,
    bool? isDefault,
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
    );
  }
}

class SubthreadManagementBootstrap {
  const SubthreadManagementBootstrap({
    required this.threadId,
    required this.threadTitle,
    required this.items,
  });

  final String threadId;
  final String threadTitle;
  final List<SubthreadManagementItem> items;

  SubthreadManagementBootstrap copyWith({
    List<SubthreadManagementItem>? items,
  }) {
    return SubthreadManagementBootstrap(
      threadId: threadId,
      threadTitle: threadTitle,
      items: items ?? this.items,
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

enum SubthreadManagementPhase { loading, ready, failed }

enum SubthreadManagementAction {
  loadingDetail,
  creating,
  updating,
  deleting,
  reordering,
}

class SubthreadManagementState {
  const SubthreadManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.pendingAction,
    this.pendingItemId,
  });

  const SubthreadManagementState.loading()
    : this(phase: SubthreadManagementPhase.loading);

  final SubthreadManagementPhase phase;
  final SubthreadManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final SubthreadManagementAction? pendingAction;
  final String? pendingItemId;

  bool get isBusy => pendingAction != null;

  SubthreadManagementState copyWith({
    SubthreadManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? pendingAction = _unset,
    Object? pendingItemId = _unset,
  }) {
    return SubthreadManagementState(
      phase: phase ?? this.phase,
      bootstrap: identical(bootstrap, _unset)
          ? this.bootstrap
          : bootstrap as SubthreadManagementBootstrap?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as SubthreadManagementAction?,
      pendingItemId: identical(pendingItemId, _unset)
          ? this.pendingItemId
          : pendingItemId as String?,
    );
  }
}

const _unset = Object();

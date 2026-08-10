import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum ThreadInvitationStatus {
  recruiting('招募中'),
  closed('已关闭'),
  finished('已完结'),
  unknown('状态未知');

  const ThreadInvitationStatus(this.label);

  final String label;
}

class ThreadInvitationLink {
  const ThreadInvitationLink({
    required this.id,
    required this.threadId,
    required this.token,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String token;
  final Uri url;
  final DateTime createdAt;
}

class ThreadInvitationPreview {
  const ThreadInvitationPreview({
    required this.threadId,
    required this.title,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    required this.memberCount,
    required this.createdAt,
    required this.alreadyJoined,
    this.categorySlug,
    this.ownerAvatarUrl,
  });

  final String threadId;
  final String title;
  final String? categorySlug;
  final ThreadInvitationStatus status;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int memberCount;
  final DateTime createdAt;
  final bool alreadyJoined;

  ThreadInvitationPreview copyWith({bool? alreadyJoined}) {
    return ThreadInvitationPreview(
      threadId: threadId,
      title: title,
      categorySlug: categorySlug,
      status: status,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
      memberCount: memberCount,
      createdAt: createdAt,
      alreadyJoined: alreadyJoined ?? this.alreadyJoined,
    );
  }
}

class ThreadInvitationJoinResult {
  const ThreadInvitationJoinResult({
    required this.memberId,
    required this.threadId,
    required this.threadTitle,
    required this.userId,
  });

  final String memberId;
  final String threadId;
  final String threadTitle;
  final String userId;
}

class ThreadInviteLinkState {
  const ThreadInviteLinkState({
    this.isGenerating = false,
    this.link,
    this.failure,
  });

  final bool isGenerating;
  final ThreadInvitationLink? link;
  final ApiFailure? failure;

  ThreadInviteLinkState copyWith({
    bool? isGenerating,
    Object? link = _unset,
    Object? failure = _unset,
  }) {
    return ThreadInviteLinkState(
      isGenerating: isGenerating ?? this.isGenerating,
      link: identical(link, _unset) ? this.link : link as ThreadInvitationLink?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
    );
  }
}

enum ThreadInvitationAccessPhase { loading, ready, failed }

class ThreadInvitationAccessState {
  const ThreadInvitationAccessState({
    required this.phase,
    this.preview,
    this.failure,
    this.isJoining = false,
    this.joinFailure,
  });

  const ThreadInvitationAccessState.loading()
    : this(phase: ThreadInvitationAccessPhase.loading);

  final ThreadInvitationAccessPhase phase;
  final ThreadInvitationPreview? preview;
  final ApiFailure? failure;
  final bool isJoining;
  final ApiFailure? joinFailure;

  ThreadInvitationAccessState copyWith({
    ThreadInvitationAccessPhase? phase,
    Object? preview = _unset,
    Object? failure = _unset,
    bool? isJoining,
    Object? joinFailure = _unset,
  }) {
    return ThreadInvitationAccessState(
      phase: phase ?? this.phase,
      preview: identical(preview, _unset)
          ? this.preview
          : preview as ThreadInvitationPreview?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      isJoining: isJoining ?? this.isJoining,
      joinFailure: identical(joinFailure, _unset)
          ? this.joinFailure
          : joinFailure as ApiFailure?,
    );
  }
}

const _unset = Object();

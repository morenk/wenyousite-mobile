import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

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

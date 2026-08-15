import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

enum ContentDraftsPhase { loading, ready, failed }

const _unset = Object();

class ContentDraftsState {
  const ContentDraftsState({
    this.phase = ContentDraftsPhase.loading,
    this.drafts = const [],
    this.usage = const ContentDraftSlotUsage.empty(),
    this.pendingSlot,
    this.pendingDraftId,
    this.failure,
    this.actionFailure,
    this.successMessage,
    this.conflict,
  });

  final ContentDraftsPhase phase;
  final List<ContentDraft> drafts;
  final ContentDraftSlotUsage usage;
  final int? pendingSlot;
  final String? pendingDraftId;
  final ApiFailure? failure;
  final ApiFailure? actionFailure;
  final String? successMessage;
  final ContentDraftConflict? conflict;

  bool get isBusy => pendingSlot != null || pendingDraftId != null;

  ContentDraft? draftAt(int slot) {
    for (final draft in drafts) {
      if (draft.slot == slot) return draft;
    }
    return null;
  }

  ContentDraftsState copyWith({
    ContentDraftsPhase? phase,
    List<ContentDraft>? drafts,
    ContentDraftSlotUsage? usage,
    Object? pendingSlot = _unset,
    Object? pendingDraftId = _unset,
    Object? failure = _unset,
    Object? actionFailure = _unset,
    Object? successMessage = _unset,
    Object? conflict = _unset,
  }) {
    return ContentDraftsState(
      phase: phase ?? this.phase,
      drafts: drafts ?? this.drafts,
      usage: usage ?? this.usage,
      pendingSlot: identical(pendingSlot, _unset)
          ? this.pendingSlot
          : pendingSlot as int?,
      pendingDraftId: identical(pendingDraftId, _unset)
          ? this.pendingDraftId
          : pendingDraftId as String?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as ApiFailure?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      conflict: identical(conflict, _unset)
          ? this.conflict
          : conflict as ContentDraftConflict?,
    );
  }
}

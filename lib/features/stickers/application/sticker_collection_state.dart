import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

enum StickerCollectionPhase { loading, ready, failed }

enum StickerAction { importing, reordering, removing }

const _unset = Object();

class StickerCollectionState {
  const StickerCollectionState({
    this.phase = StickerCollectionPhase.loading,
    this.collection,
    this.action,
    this.actionTarget,
    this.failure,
    this.transientFailure,
    this.retrySource,
    this.successMessage,
  });

  final StickerCollectionPhase phase;
  final StickerCollection? collection;
  final StickerAction? action;
  final String? actionTarget;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final StickerImportSource? retrySource;
  final String? successMessage;

  bool get isBusy => action != null;

  StickerCollectionState copyWith({
    StickerCollectionPhase? phase,
    Object? collection = _unset,
    Object? action = _unset,
    Object? actionTarget = _unset,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    Object? retrySource = _unset,
    Object? successMessage = _unset,
  }) {
    return StickerCollectionState(
      phase: phase ?? this.phase,
      collection: identical(collection, _unset)
          ? this.collection
          : collection as StickerCollection?,
      action: identical(action, _unset)
          ? this.action
          : action as StickerAction?,
      actionTarget: identical(actionTarget, _unset)
          ? this.actionTarget
          : actionTarget as String?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      retrySource: identical(retrySource, _unset)
          ? this.retrySource
          : retrySource as StickerImportSource?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

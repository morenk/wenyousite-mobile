import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum StickerImportStatus { processing, completed, failed }

class StickerAsset {
  const StickerAsset({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
  });

  final String id;
  final String url;
  final String thumbnailUrl;
  final int width;
  final int height;
  final bool animated;
  final int frameCount;
  final int durationMs;
}

class UserSticker {
  const UserSticker({
    required this.id,
    required this.position,
    required this.asset,
    required this.markdown,
    this.lastUsedAt,
  });

  final String id;
  final int position;
  final DateTime? lastUsedAt;
  final StickerAsset asset;
  final String markdown;
}

class StickerImport {
  const StickerImport({
    required this.id,
    required this.status,
    required this.alreadySaved,
    this.favorite,
    this.failureCode,
  });

  final String id;
  final StickerImportStatus status;
  final UserSticker? favorite;
  final String? failureCode;
  final bool alreadySaved;
}

class StickerCollection {
  const StickerCollection({
    required this.version,
    required this.limit,
    required this.items,
    required this.recent,
    required this.pendingImports,
  });

  final int version;
  final int limit;
  final List<UserSticker> items;
  final List<UserSticker> recent;
  final List<StickerImport> pendingImports;

  bool get isFull => items.length + pendingImports.length >= limit;
}

enum StickerCollectionPhase { loading, ready, failed }

enum StickerAction { importing, reordering, removing }

sealed class StickerImportSource {
  const StickerImportSource();

  String get requestKey;
}

class StickerMediaSource extends StickerImportSource {
  const StickerMediaSource(this.mediaId);

  final String mediaId;

  @override
  String get requestKey => 'media:$mediaId';
}

class StickerDirectMessageSource extends StickerImportSource {
  const StickerDirectMessageSource(this.directMessageId);

  final String directMessageId;

  @override
  String get requestKey => 'direct:$directMessageId';
}

class StickerPostImageSource extends StickerImportSource {
  const StickerPostImageSource({required this.postId, required this.imageUrl});

  final String postId;
  final String imageUrl;

  @override
  String get requestKey => 'post:$postId:$imageUrl';
}

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

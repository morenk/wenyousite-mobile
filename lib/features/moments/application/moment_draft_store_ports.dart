import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MomentLocalDraft {
  const MomentLocalDraft({
    required this.title,
    required this.content,
    required this.images,
    required this.updatedAt,
    this.coverMediaId,
    this.clientRequestId,
    this.pendingCreate,
  });

  final String title;
  final String content;
  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final DateTime updatedAt;
  final String? clientRequestId;
  final PendingCreateOperation? pendingCreate;

  MomentLocalDraft withPersistence(
    String requestId, {
    PendingCreateOperation? pending,
  }) => MomentLocalDraft(
    title: title,
    content: content,
    images: images,
    coverMediaId: coverMediaId,
    updatedAt: updatedAt,
    clientRequestId: requestId,
    pendingCreate: pending,
  );

  Map<String, Object?> toJson() => {
    'title': title,
    'content': content,
    'coverMediaId': coverMediaId,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'images': [
      for (final image in images)
        {
          'mediaId': image.mediaId,
          'url': image.url,
          'thumbnailUrl': image.thumbnailUrl,
          'feedUrl': image.feedUrl,
          'mediumUrl': image.mediumUrl,
          'contentType': image.contentType,
          'animated': image.animated,
          'width': image.width,
          'height': image.height,
        },
    ],
  };

  static MomentLocalDraft? fromJson(Object? value) {
    if (value case final Map<String, dynamic> json) {
      final title = json['title'];
      final content = json['content'];
      final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
      final rawImages = json['images'];
      if (title is! String ||
          content is! String ||
          updatedAt == null ||
          rawImages is! List) {
        return null;
      }
      final images = <UploadedEditorImage>[];
      for (final rawImage in rawImages) {
        if (rawImage is! Map<String, dynamic>) return null;
        final mediaId = rawImage['mediaId'];
        final url = rawImage['url'];
        if (mediaId is! String || url is! String) return null;
        images.add(
          UploadedEditorImage(
            mediaId: mediaId,
            url: url,
            thumbnailUrl: rawImage['thumbnailUrl'] as String?,
            feedUrl: rawImage['feedUrl'] as String?,
            mediumUrl: rawImage['mediumUrl'] as String?,
            contentType: rawImage['contentType'] as String?,
            animated: rawImage['animated'] as bool? ?? false,
            width: rawImage['width'] as int?,
            height: rawImage['height'] as int?,
          ),
        );
      }
      return MomentLocalDraft(
        title: title,
        content: content,
        images: List.unmodifiable(images),
        coverMediaId: json['coverMediaId'] as String?,
        updatedAt: updatedAt,
      );
    }
    return null;
  }
}

abstract interface class MomentDraftStore {
  Future<MomentLocalDraft?> read(String ownerId, String? momentId);

  Future<void> write(String ownerId, String? momentId, MomentLocalDraft draft);

  Future<void> delete(String ownerId, String? momentId);

  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft draft,
    PendingCreateOperation operation,
  );

  Future<void> finishCreate(
    String ownerId,
    String requestId, {
    required bool discardDraft,
  });
}

final momentDraftStoreProvider = Provider<MomentDraftStore>((ref) {
  return const _UnboundMomentDraftStore();
});

class _UnboundMomentDraftStore implements MomentDraftStore {
  const _UnboundMomentDraftStore();

  @override
  Future<MomentLocalDraft?> read(String ownerId, String? momentId) =>
      Future.error(_error());

  @override
  Future<void> write(String ownerId, String? momentId, MomentLocalDraft draft) {
    return Future.error(_error());
  }

  @override
  Future<void> delete(String ownerId, String? momentId) =>
      Future.error(_error());

  @override
  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft draft,
    PendingCreateOperation operation,
  ) => Future.error(_error());

  @override
  Future<void> finishCreate(
    String ownerId,
    String requestId, {
    required bool discardDraft,
  }) => Future.error(_error());
}

typedef MomentComposerOwnerResolver = Future<String> Function();

final momentComposerOwnerResolverProvider =
    Provider<MomentComposerOwnerResolver>((ref) {
      return () => Future.error(StateError('动态账号解析尚未在应用组合根绑定。'));
    });

StateError _error() => StateError('动态本机草稿存储尚未在应用组合根绑定。');

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MomentLocalDraft {
  const MomentLocalDraft({
    required this.title,
    required this.content,
    required this.images,
    required this.updatedAt,
    this.coverMediaId,
  });

  final String title;
  final String content;
  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final DateTime updatedAt;

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
  Future<MomentLocalDraft?> read(String? momentId);

  Future<void> write(String? momentId, MomentLocalDraft draft);

  Future<void> delete(String? momentId);
}

class SharedPreferencesMomentDraftStore implements MomentDraftStore {
  static const _prefix = 'moment.compose.draft.v1';

  String _key(String? momentId) => '$_prefix:${momentId ?? 'new'}';

  @override
  Future<MomentLocalDraft?> read(String? momentId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(momentId));
    if (raw == null) return null;
    try {
      final draft = MomentLocalDraft.fromJson(jsonDecode(raw));
      if (draft != null) return draft;
    } on FormatException {
      // Invalid local data is discarded below.
    }
    await preferences.remove(_key(momentId));
    return null;
  }

  @override
  Future<void> write(String? momentId, MomentLocalDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(momentId), jsonEncode(draft.toJson()));
  }

  @override
  Future<void> delete(String? momentId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(momentId));
  }
}

final momentDraftStoreProvider = Provider<MomentDraftStore>((ref) {
  return SharedPreferencesMomentDraftStore();
});

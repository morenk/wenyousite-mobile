import 'dart:convert';

import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

/// Visibility accepted by the thread creation workflow.
enum ThreadComposeVisibility {
  public('PUBLIC', '公开'),
  private('PRIVATE', '私密');

  const ThreadComposeVisibility(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ThreadComposeVisibility fromWireValue(String? value) {
    return value == 'PRIVATE' ? private : public;
  }
}

class ThreadComposeCategory {
  const ThreadComposeCategory({
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.description,
  });

  final String slug;
  final String name;
  final String? description;
  final int sortOrder;
}

class ThreadComposeBootstrap {
  const ThreadComposeBootstrap({
    required this.userId,
    required this.emailVerified,
    required this.categories,
  });

  final String userId;
  final bool emailVerified;
  final List<ThreadComposeCategory> categories;
}

class ThreadRemoteDraft {
  const ThreadRemoteDraft({
    required this.id,
    required this.version,
    required this.defaultSubthreadId,
    required this.defaultSubthreadVersion,
    required this.title,
    required this.categorySlug,
    required this.visibility,
    required this.tags,
    required this.body,
    this.bodyVersion,
  });

  final String id;
  final int version;
  final String defaultSubthreadId;
  final int defaultSubthreadVersion;
  final int? bodyVersion;
  final String title;
  final String? categorySlug;
  final ThreadComposeVisibility visibility;
  final List<String> tags;
  final String body;
}

class ThreadRemoteDraftSummary {
  const ThreadRemoteDraftSummary({
    required this.id,
    required this.title,
    required this.categorySlug,
    required this.visibility,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.subthreadCount,
    required this.postCount,
  });

  final String id;
  final String title;
  final String? categorySlug;
  final ThreadComposeVisibility visibility;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int subthreadCount;
  final int postCount;

  String get displayTitle => title.isEmpty ? '未命名草稿' : title;
}

class ThreadCreatePayload {
  const ThreadCreatePayload({
    required this.clientRequestId,
    required this.title,
    required this.categorySlug,
    required this.visibility,
    required this.tags,
    required this.body,
  });

  final String clientRequestId;
  final String title;
  final String? categorySlug;
  final ThreadComposeVisibility visibility;
  final List<String> tags;
  final String body;

  String toNormalizedJson() {
    return jsonEncode({
      'schemaVersion': 1,
      'clientRequestId': clientRequestId,
      'title': title.trim(),
      'categorySlug': _normalizedOptional(categorySlug),
      'visibility': visibility.wireValue,
      'tags': normalizeTagNames(tags),
      'body': MarkdownContent.normalize(body),
    });
  }

  static ThreadCreatePayload? fromNormalizedJson(String source) {
    try {
      final data = jsonDecode(source);
      if (data is! Map || data['schemaVersion'] != 1) return null;
      final clientRequestId = data['clientRequestId'];
      final title = data['title'];
      final categorySlug = data['categorySlug'];
      final visibility = data['visibility'];
      final tags = data['tags'];
      final body = data['body'];
      if (clientRequestId is! String ||
          clientRequestId.isEmpty ||
          title is! String ||
          categorySlug != null && categorySlug is! String ||
          visibility is! String ||
          tags is! List ||
          tags.any((tag) => tag is! String) ||
          body is! String) {
        return null;
      }
      return ThreadCreatePayload(
        clientRequestId: clientRequestId,
        title: title,
        categorySlug: categorySlug as String?,
        visibility: ThreadComposeVisibility.fromWireValue(visibility),
        tags: List<String>.unmodifiable(tags.cast<String>()),
        body: body,
      );
    } on Object {
      return null;
    }
  }
}

class ThreadSnapshotMetadata {
  const ThreadSnapshotMetadata({
    required this.ownerId,
    required this.title,
    required this.categorySlug,
    required this.visibility,
    required this.tags,
    this.remoteDraft,
  });

  final String ownerId;
  final String title;
  final String? categorySlug;
  final ThreadComposeVisibility visibility;
  final List<String> tags;
  final ThreadRemoteDraft? remoteDraft;

  String toJson() {
    final remote = remoteDraft;
    return jsonEncode({
      'schemaVersion': 1,
      'ownerId': ownerId,
      'title': title,
      'categorySlug': categorySlug,
      'visibility': visibility.wireValue,
      'tags': tags,
      if (remote != null)
        'remoteDraft': {
          'id': remote.id,
          'version': remote.version,
          'defaultSubthreadId': remote.defaultSubthreadId,
          'defaultSubthreadVersion': remote.defaultSubthreadVersion,
          'bodyVersion': remote.bodyVersion,
        },
    });
  }

  static ThreadSnapshotMetadata? fromJson(String source) {
    try {
      final data = jsonDecode(source);
      if (data is! Map || data['schemaVersion'] != 1) return null;
      final ownerId = data['ownerId'];
      final title = data['title'];
      final categorySlug = data['categorySlug'];
      final visibility = data['visibility'];
      final tags = data['tags'];
      if (ownerId is! String ||
          ownerId.isEmpty ||
          title is! String ||
          categorySlug != null && categorySlug is! String ||
          visibility is! String ||
          tags is! List ||
          tags.any((tag) => tag is! String)) {
        return null;
      }
      ThreadRemoteDraft? remoteDraft;
      final remote = data['remoteDraft'];
      if (remote is Map) {
        final id = remote['id'];
        final version = remote['version'];
        final subthreadId = remote['defaultSubthreadId'];
        final subthreadVersion = remote['defaultSubthreadVersion'];
        final bodyVersion = remote['bodyVersion'];
        if (id is String &&
            version is num &&
            subthreadId is String &&
            subthreadVersion is num &&
            (bodyVersion == null || bodyVersion is num)) {
          remoteDraft = ThreadRemoteDraft(
            id: id,
            version: version.toInt(),
            defaultSubthreadId: subthreadId,
            defaultSubthreadVersion: subthreadVersion.toInt(),
            bodyVersion: (bodyVersion as num?)?.toInt(),
            title: title,
            categorySlug: categorySlug as String?,
            visibility: ThreadComposeVisibility.fromWireValue(visibility),
            tags: List<String>.unmodifiable(tags.cast<String>()),
            body: '',
          );
        }
      }
      return ThreadSnapshotMetadata(
        ownerId: ownerId,
        title: title,
        categorySlug: categorySlug as String?,
        visibility: ThreadComposeVisibility.fromWireValue(visibility),
        tags: List<String>.unmodifiable(tags.cast<String>()),
        remoteDraft: remoteDraft,
      );
    } on Object {
      return null;
    }
  }
}

String? validateThreadDraft({
  required String title,
  required String body,
  required List<String> tags,
}) {
  if (title.trim().length > 100) return '标题不能超过 100 个字符。';
  if (MarkdownContent.normalize(body).length > 10000) {
    return '正文不能超过 10000 个字符。';
  }
  final normalizedTags = normalizeTagNames(tags);
  if (normalizedTags.length > 5) return '最多添加 5 个标签。';
  final tagPattern = RegExp(r'^[A-Za-z0-9_\u4e00-\u9fff#]+$');
  for (final tag in normalizedTags) {
    if (tag.length > 20 || !tagPattern.hasMatch(tag)) {
      return '标签只能包含中英文、数字、下划线和 #，且不超过 20 个字符。';
    }
  }
  return null;
}

String? validateThreadPublish({
  required String title,
  required String? categorySlug,
  required String body,
  required List<String> tags,
}) {
  final draftError = validateThreadDraft(title: title, body: body, tags: tags);
  if (draftError != null) return draftError;
  if (title.trim().isEmpty) return '请填写主题标题。';
  if (_normalizedOptional(categorySlug) == null) return '请选择主题分类。';
  if (!MarkdownContent.hasVisibleContent(body)) return '请填写可见的主题正文。';
  return null;
}

List<String> normalizeTagNames(Iterable<String> tags) {
  final seen = <String>{};
  return List<String>.unmodifiable(
    tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty && seen.add(tag)),
  );
}

String? _normalizedOptional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

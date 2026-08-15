import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

const maxThreadTagCount = 5;
const maxTagNameLength = 20;

final RegExp _tagNamePattern = RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fff#]+$');

String normalizeTagName(String value) => value.trim();

String? validateTagName(String value) {
  final normalized = normalizeTagName(value);
  if (normalized.isEmpty) return '请输入标签名称';
  if (normalized.length > maxTagNameLength) return '标签名称不能超过 20 个字符';
  if (!_tagNamePattern.hasMatch(normalized)) {
    return '只能使用中英文、数字、下划线和 #';
  }
  return null;
}

class TopicTagModel {
  const TopicTagModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.color,
    this.description,
  });

  final String id;
  final String name;
  final String? color;
  final String? description;
  final int sortOrder;
  final bool isActive;
}

class ThreadTagManagementBootstrap {
  const ThreadTagManagementBootstrap({
    required this.threadId,
    required this.threadTitle,
    required this.tags,
    required this.suggestions,
  });

  final String threadId;
  final String threadTitle;
  final List<TopicTagModel> tags;
  final List<TopicTagModel> suggestions;

  ThreadTagManagementBootstrap copyWith({
    List<TopicTagModel>? tags,
    List<TopicTagModel>? suggestions,
  }) {
    return ThreadTagManagementBootstrap(
      threadId: threadId,
      threadTitle: threadTitle,
      tags: tags ?? this.tags,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class TagThreadsBootstrap {
  const TagThreadsBootstrap({
    required this.tag,
    required this.categories,
    required this.page,
  });

  final TopicTagModel tag;
  final List<HomeCategory> categories;
  final CursorPage<HomeThreadCardModel> page;
}

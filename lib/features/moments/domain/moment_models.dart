import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';

const _unsetMomentValue = Object();

enum MomentFeedMode { discover, following }

enum MomentFeedKind { main, user }

enum MomentCoverType { image, text }

enum MomentTextCoverTheme { rose, lilac, mint, amber }

enum MomentCommentOrder { newest, oldest }

class MomentFeedTarget {
  const MomentFeedTarget.main(this.mode)
    : kind = MomentFeedKind.main,
      userId = null;

  const MomentFeedTarget.user(String id)
    : kind = MomentFeedKind.user,
      mode = MomentFeedMode.discover,
      userId = id;

  final MomentFeedKind kind;
  final MomentFeedMode mode;
  final String? userId;

  @override
  bool operator ==(Object other) {
    return other is MomentFeedTarget &&
        other.kind == kind &&
        other.mode == mode &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(kind, mode, userId);
}

class MomentAuthor {
  const MomentAuthor({
    required this.id,
    required this.username,
    required this.level,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
}

class MomentMedia {
  const MomentMedia({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.feedUrl,
    this.mediumUrl,
    this.contentType,
    this.animated = false,
    this.width,
    this.height,
  });

  final String id;
  final String url;
  final String? thumbnailUrl;
  final String? feedUrl;
  final String? mediumUrl;
  final String? contentType;
  final bool animated;
  final int? width;
  final int? height;

  List<String> get feedUrls =>
      _orderedMediaUrls([feedUrl, thumbnailUrl, mediumUrl, url]);

  List<String> get contentUrls =>
      _orderedMediaUrls([mediumUrl, thumbnailUrl, url]);

  String get bestFeedUrl => feedUrls.first;

  String get bestContentUrl => contentUrls.first;

  double? get aspectRatio {
    final safeWidth = width;
    final safeHeight = height;
    if (safeWidth == null || safeHeight == null || safeHeight <= 0) return null;
    return safeWidth / safeHeight;
  }
}

List<String> _orderedMediaUrls(Iterable<String?> values) {
  final result = <String>[];
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        !result.contains(normalized)) {
      result.add(normalized);
    }
  }
  return List.unmodifiable(result);
}

class MomentCard {
  const MomentCard({
    required this.id,
    required this.author,
    required this.title,
    required this.contentExcerpt,
    required this.coverType,
    required this.textCoverTheme,
    required this.imageCount,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.tipTotal,
    required this.viewerLiked,
    required this.viewerBookmarked,
    required this.createdAt,
    required this.updatedAt,
    this.coverMedia,
    this.canInteract = true,
    this.bookmarkFolderId,
  });

  final String id;
  final MomentAuthor author;
  final String title;
  final String contentExcerpt;
  final MomentCoverType coverType;
  final MomentTextCoverTheme textCoverTheme;
  final MomentMedia? coverMedia;
  final int imageCount;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final String tipTotal;
  final bool viewerLiked;
  final bool viewerBookmarked;
  final bool canInteract;
  final String? bookmarkFolderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MomentCard copyWith({
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    String? tipTotal,
    bool? viewerLiked,
    bool? viewerBookmarked,
    bool? canInteract,
    Object? bookmarkFolderId = _unsetMomentValue,
  }) {
    return MomentCard(
      id: id,
      author: author,
      title: title,
      contentExcerpt: contentExcerpt,
      coverType: coverType,
      textCoverTheme: textCoverTheme,
      coverMedia: coverMedia,
      imageCount: imageCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      tipTotal: tipTotal ?? this.tipTotal,
      viewerLiked: viewerLiked ?? this.viewerLiked,
      viewerBookmarked: viewerBookmarked ?? this.viewerBookmarked,
      canInteract: canInteract ?? this.canInteract,
      bookmarkFolderId: identical(bookmarkFolderId, _unsetMomentValue)
          ? this.bookmarkFolderId
          : bookmarkFolderId as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class MomentDetail {
  const MomentDetail({
    required this.card,
    required this.content,
    required this.images,
    required this.version,
    required this.canEdit,
    required this.canDelete,
  });

  final MomentCard card;
  final String content;
  final List<MomentMedia> images;
  final int version;
  final bool canEdit;
  final bool canDelete;

  MomentDetail copyWith({MomentCard? card}) {
    return MomentDetail(
      card: card ?? this.card,
      content: content,
      images: images,
      version: version,
      canEdit: canEdit,
      canDelete: canDelete,
    );
  }
}

class MomentSticker {
  const MomentSticker({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.mediumUrl,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
    this.width,
    this.height,
  });

  final String id;
  final String url;
  final String thumbnailUrl;
  final String mediumUrl;
  final int? width;
  final int? height;
  final bool animated;
  final int frameCount;
  final int durationMs;
}

class MomentReplyTarget {
  const MomentReplyTarget({required this.id, required this.author});

  final String id;
  final MomentAuthor author;
}

class MomentComment {
  const MomentComment({
    required this.id,
    required this.momentId,
    required this.author,
    required this.deleted,
    required this.canDelete,
    required this.createdAt,
    this.content,
    this.media,
    this.sticker,
    this.parentCommentId,
    this.replyToComment,
  });

  final String id;
  final String momentId;
  final MomentAuthor author;
  final String? content;
  final MomentMedia? media;
  final MomentSticker? sticker;
  final String? parentCommentId;
  final MomentReplyTarget? replyToComment;
  final bool deleted;
  final bool canDelete;
  final DateTime createdAt;
}

class MomentRootComment extends MomentComment {
  const MomentRootComment({
    required super.id,
    required super.momentId,
    required super.author,
    required super.deleted,
    required super.canDelete,
    required super.createdAt,
    required this.replyCount,
    required this.replies,
    super.content,
    super.media,
    super.sticker,
  });

  final int replyCount;
  final List<MomentComment> replies;

  MomentRootComment copyWith({int? replyCount, List<MomentComment>? replies}) {
    return MomentRootComment(
      id: id,
      momentId: momentId,
      author: author,
      deleted: deleted,
      canDelete: canDelete,
      createdAt: createdAt,
      content: content,
      media: media,
      sticker: sticker,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }
}

class MomentCommentContext {
  const MomentCommentContext({required this.root, required this.target});

  final MomentRootComment root;
  final MomentComment target;

  bool get targetsRoot => root.id == target.id;
}

class MomentActionResult {
  const MomentActionResult({
    required this.momentId,
    required this.count,
    required this.active,
  });

  final String momentId;
  final int count;
  final bool active;
}

class MomentDraftInput {
  const MomentDraftInput({
    required this.title,
    required this.content,
    required this.mediaIds,
    this.coverMediaId,
  });

  final String title;
  final String content;
  final List<String> mediaIds;
  final String? coverMediaId;

  MomentDraftInput normalized() {
    final safeTitle = title.trim();
    final safeContent = content.trim();
    if (safeTitle.length < 2 || safeTitle.length > 40) {
      throw const DomainValidationException('动态标题需要 2～40 个字符。');
    }
    if (safeContent.length > 1000) {
      throw const DomainValidationException('动态正文不能超过 1000 个字符。');
    }
    final ids = mediaIds.map((id) => id.trim()).toList(growable: false);
    if (ids.length > 9) {
      throw const DomainValidationException('每条动态最多添加 9 张图片。');
    }
    if (ids.any((id) => id.isEmpty) || ids.toSet().length != ids.length) {
      throw const DomainValidationException('动态图片信息无效，请重新选择。');
    }
    final cover = coverMediaId?.trim();
    if (cover != null && cover.isNotEmpty && !ids.contains(cover)) {
      throw const DomainValidationException('封面必须来自当前动态图片。');
    }
    return MomentDraftInput(
      title: safeTitle,
      content: safeContent,
      mediaIds: List.unmodifiable(ids),
      coverMediaId: cover == null || cover.isEmpty ? null : cover,
    );
  }
}

class MomentCommentInput {
  const MomentCommentInput({
    this.content,
    this.mediaId,
    this.stickerAssetId,
    this.replyToCommentId,
  });

  final String? content;
  final String? mediaId;
  final String? stickerAssetId;
  final String? replyToCommentId;

  MomentCommentInput normalized() {
    final text = content?.trim();
    final media = mediaId?.trim();
    final sticker = stickerAssetId?.trim();
    final replyTo = replyToCommentId?.trim();
    if ((text?.length ?? 0) > 500) {
      throw const DomainValidationException('评论不能超过 500 个字符。');
    }
    if (media != null &&
        media.isNotEmpty &&
        sticker != null &&
        sticker.isNotEmpty) {
      throw const DomainValidationException('评论图片和表情不能同时发送。');
    }
    if ((text == null || text.isEmpty) &&
        (media == null || media.isEmpty) &&
        (sticker == null || sticker.isEmpty)) {
      throw const DomainValidationException('请输入评论，或选择一张图片/一个表情。');
    }
    return MomentCommentInput(
      content: text == null || text.isEmpty ? null : text,
      mediaId: media == null || media.isEmpty ? null : media,
      stickerAssetId: sticker == null || sticker.isEmpty ? null : sticker,
      replyToCommentId: replyTo == null || replyTo.isEmpty ? null : replyTo,
    );
  }

  String get requestKey => [
    content?.trim() ?? '',
    mediaId?.trim() ?? '',
    stickerAssetId?.trim() ?? '',
    replyToCommentId?.trim() ?? '',
  ].join('|');
}

enum MomentInteractionAction { like, bookmark }

import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';

export 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';

enum BookmarkedThreadStatus { recruiting, closed, finished, unknown }

class BookmarkListItem {
  const BookmarkListItem({
    required this.bookmarkId,
    required this.threadId,
    required this.title,
    required this.status,
    required this.isPrivate,
    required this.isPinned,
    required this.ownerName,
    required this.ownerLevel,
    required this.createdAt,
    required this.memberCount,
    required this.postCount,
    required this.tipTotal,
    this.folderId,
    this.categorySlug,
    this.isPublished = true,
    this.ownerId = '',
    this.ownerAvatarUrl,
    this.lastActivityAt,
    this.preview,
    this.tags = const [],
    this.coverImageUrls = const [],
    this.playerCount,
  });

  final String bookmarkId;
  final String? folderId;
  final String threadId;
  final String title;
  final String? categorySlug;
  final BookmarkedThreadStatus status;
  final bool isPrivate;
  final bool isPinned;
  final bool isPublished;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int ownerLevel;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final String? preview;
  final List<HomeThreadTag> tags;
  final List<String> coverImageUrls;
  final int memberCount;
  final int? playerCount;
  final int postCount;
  final String tipTotal;

  BookmarkListItem copyWithFolderId(String folderId) {
    return BookmarkListItem(
      bookmarkId: bookmarkId,
      folderId: folderId,
      threadId: threadId,
      title: title,
      categorySlug: categorySlug,
      status: status,
      isPrivate: isPrivate,
      isPinned: isPinned,
      isPublished: isPublished,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
      ownerLevel: ownerLevel,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt,
      preview: preview,
      tags: tags,
      coverImageUrls: coverImageUrls,
      memberCount: memberCount,
      playerCount: playerCount,
      postCount: postCount,
      tipTotal: tipTotal,
    );
  }
}

enum BookmarkedThreadStatus { recruiting, closed, finished, unknown }

class BookmarkFolderItem {
  const BookmarkFolderItem({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.bookmarkCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final bool isDefault;
  final int bookmarkCount;
  final DateTime createdAt;
}

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
  });

  final String bookmarkId;
  final String? folderId;
  final String threadId;
  final String title;
  final String? categorySlug;
  final BookmarkedThreadStatus status;
  final bool isPrivate;
  final bool isPinned;
  final String ownerName;
  final int ownerLevel;
  final DateTime createdAt;
  final int memberCount;
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
      ownerName: ownerName,
      ownerLevel: ownerLevel,
      createdAt: createdAt,
      memberCount: memberCount,
      postCount: postCount,
      tipTotal: tipTotal,
    );
  }
}

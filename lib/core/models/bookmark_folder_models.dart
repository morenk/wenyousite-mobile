class BookmarkFolderItem {
  const BookmarkFolderItem({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.bookmarkCount,
    required this.createdAt,
    this.momentBookmarkCount = 0,
  });

  final String id;
  final String name;
  final bool isDefault;
  final int bookmarkCount;
  final int momentBookmarkCount;
  final DateTime createdAt;
}

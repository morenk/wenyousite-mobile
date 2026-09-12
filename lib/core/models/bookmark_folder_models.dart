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

  BookmarkFolderItem copyWith({String? name, int? bookmarkCount}) {
    return BookmarkFolderItem(
      id: id,
      name: name ?? this.name,
      isDefault: isDefault,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      createdAt: createdAt,
    );
  }
}

class BookmarkFolderDeleteResult {
  const BookmarkFolderDeleteResult({
    required this.deletedFolderId,
    required this.destinationFolderId,
  });

  final String deletedFolderId;
  final String destinationFolderId;
}

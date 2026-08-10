enum HomeThreadStatus {
  recruiting('招募中'),
  closed('已关闭'),
  finished('已完结'),
  unknown('状态未知');

  const HomeThreadStatus(this.label);

  final String label;
}

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.description,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final int sortOrder;
}

class HomeThreadTag {
  const HomeThreadTag({required this.id, required this.name});

  final String id;
  final String name;
}

class HomeThreadCardModel {
  const HomeThreadCardModel({
    required this.id,
    required this.title,
    required this.status,
    required this.isPinned,
    required this.ownerId,
    required this.ownerName,
    required this.ownerLevel,
    required this.tags,
    required this.coverImageUrls,
    required this.memberCount,
    required this.playerCount,
    required this.postCount,
    required this.tipTotal,
    required this.lastActivityAt,
    this.categorySlug,
    this.ownerAvatarUrl,
    this.preview,
  });

  final String id;
  final String title;
  final String? categorySlug;
  final HomeThreadStatus status;
  final bool isPinned;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int ownerLevel;
  final String? preview;
  final List<HomeThreadTag> tags;
  final List<String> coverImageUrls;
  final int memberCount;
  final int playerCount;
  final int postCount;
  final String tipTotal;
  final DateTime lastActivityAt;
}

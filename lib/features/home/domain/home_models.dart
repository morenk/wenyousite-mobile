enum HomeFeedSort {
  recommended('recommended', '推荐'),
  newest('newest', '最新发布'),
  active('active', '最近活跃');

  const HomeFeedSort(this.wireValue, this.label);

  final String wireValue;
  final String label;
}

enum HomeThreadStatusFilter {
  all(null, '全部状态'),
  recruiting('RECRUITING', '招募中'),
  closed('CLOSED', '已关闭'),
  finished('FINISHED', '已完结');

  const HomeThreadStatusFilter(this.wireValue, this.label);

  final String? wireValue;
  final String label;
}

enum HomeThreadStatus {
  recruiting('招募中'),
  closed('已关闭'),
  finished('已完结'),
  unknown('状态未知');

  const HomeThreadStatus(this.label);

  final String label;
}

class HomeFeedQuery {
  const HomeFeedQuery({
    this.categorySlug,
    this.sort = HomeFeedSort.recommended,
    this.status = HomeThreadStatusFilter.all,
  });

  final String? categorySlug;
  final HomeFeedSort sort;
  final HomeThreadStatusFilter status;
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

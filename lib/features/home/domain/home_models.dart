export 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

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
  closed('CLOSED', '已停招'),
  finished('FINISHED', '已完结');

  const HomeThreadStatusFilter(this.wireValue, this.label);

  final String? wireValue;
  final String label;
}

class HomeFeedQuery {
  const HomeFeedQuery({
    this.categorySlug,
    this.tagId,
    this.sort = HomeFeedSort.recommended,
    this.status = HomeThreadStatusFilter.all,
  });

  final String? categorySlug;
  final String? tagId;
  final HomeFeedSort sort;
  final HomeThreadStatusFilter status;
}

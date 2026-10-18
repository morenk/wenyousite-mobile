import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// 动态及动态收藏共用布局；卡片、操作、分页和滚动状态由页面提供。
class MomentWaterfallSliver extends StatelessWidget {
  const MomentWaterfallSliver({
    required this.itemKeys,
    required this.itemBuilder,
    this.footer,
    this.footerKey,
    this.columns,
    this.bottom = 0,
    super.key,
  }) : assert(columns == null || columns == 1 || columns == 2),
       assert((footer == null) == (footerKey == null));

  final List<Key> itemKeys;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? footer;
  final Key? footerKey;
  // 默认遵循已发布 Foundation，显式配置用于单列容器和布局回归。
  final int? columns;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final count = itemKeys.length;
    final indexByKey = <Key, int>{
      for (var index = 0; index < count; index++) itemKeys[index]: index,
      ?footerKey: count,
    };
    assert(indexByKey.length == count + (footer == null ? 0 : 1));
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final base = wenyouHorizontalPagePadding(
          context,
          availableWidth: width,
        );
        final available = width - base * 2;
        final contentWidth = available < 600 ? available : 600.0;
        final horizontal = (width - contentWidth) / 2;
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            tokens.space8,
            horizontal,
            bottom,
          ),
          sliver: SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  columns ??
                  (WenyouCollectionContract
                              .mobileDomainLayoutExceptions['moments-feed'] ==
                          'two-column-waterfall'
                      ? 2
                      : 1),
              mainAxisSpacing: tokens.cardGap,
              crossAxisSpacing: tokens.cardGap,
              lastChildLayoutTypeBuilder: (index) =>
                  footer != null && index == count
                  ? LastChildLayoutType.fullCrossAxisExtent
                  : LastChildLayoutType.none,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => KeyedSubtree(
                key: index == count ? footerKey : itemKeys[index],
                child: index == count ? footer! : itemBuilder(context, index),
              ),
              childCount: count + (footer == null ? 0 : 1),
              addAutomaticKeepAlives: false,
              findChildIndexCallback: (key) => indexByKey[key],
            ),
          ),
        );
      },
    );
  }
}

class MomentWaterfallLoadingSliver extends StatelessWidget {
  const MomentWaterfallLoadingSliver({this.label = '正在加载动态', super.key});

  final String label;

  @override
  Widget build(BuildContext context) => MomentWaterfallSliver(
    bottom: context.wenyouTokens.space24,
    itemKeys: [for (var index = 0; index < 4; index++) ValueKey(index)],
    itemBuilder: (context, index) =>
        _MomentWaterfallSkeletonCard(index: index, label: label),
  );
}

class _MomentWaterfallSkeletonCard extends StatelessWidget {
  const _MomentWaterfallSkeletonCard({
    required this.index,
    required this.label,
  });

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.panel,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(tokens.radiusCard),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: index.isEven ? 3 / 4 : 1,
                  child: ColoredBox(color: tokens.softPanel),
                ),
                Padding(
                  padding: EdgeInsets.all(tokens.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: index.isEven ? 0.82 : 0.68,
                        child: const WenyouSkeletonBlock(height: 14),
                      ),
                      SizedBox(height: tokens.space12),
                      FractionallySizedBox(
                        widthFactor: 0.58,
                        child: const WenyouSkeletonBlock(height: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 页签高度随字号变化，由 Flutter 实际测量；内层列表预留相同的遮挡区域。
class WenyouPinnedHeader extends StatelessWidget {
  const WenyouPinnedHeader({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SliverOverlapAbsorber(
    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    sliver: PinnedHeaderSliver(child: child),
  );
}

class WenyouNestedScrollInset extends StatelessWidget {
  const WenyouNestedScrollInset({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorStateOfType<NestedScrollViewState>() == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverOverlapInjector(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// The zero-elevation app panel as slivers, so long contents stay lazy.
/// Tappable rows provide their own transparent Material for ink painting.
class WenyouSliverPanel extends StatelessWidget {
  const WenyouSliverPanel({required this.slivers, super.key});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    assert(
      cardTheme.shape != null,
      'The app CardTheme defines the panel shape.',
    );
    assert((cardTheme.elevation ?? 0) == 0, 'Sliver panels use flat surfaces.');
    return SliverPadding(
      padding: cardTheme.margin ?? EdgeInsets.zero,
      sliver: DecoratedSliver(
        decoration: ShapeDecoration(
          color: context.wenyouTokens.panel,
          shape: cardTheme.shape!,
        ),
        sliver: SliverPadding(
          padding: EdgeInsets.all(context.wenyouTokens.space20),
          sliver: SliverMainAxisGroup(slivers: slivers),
        ),
      ),
    );
  }
}

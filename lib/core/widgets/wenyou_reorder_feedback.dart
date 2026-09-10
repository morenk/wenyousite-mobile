import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';

/// 网格与列表共用的抬起/落下绘制。只动画代理项，不改变其布局尺寸。
class WenyouReorderFeedback extends StatelessWidget {
  const WenyouReorderFeedback({
    required this.child,
    this.lifted = false,
    this.animation,
    super.key,
  });

  final Widget child;
  final bool lifted;

  /// ReorderableListView 的代理沿用框架落位时钟，不另启计时器。
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final reduced = wenyouAnimationsDisabled(context);
    // 动画 builder 的 child 不随每帧重建，文字与图片单独复用绘制层。
    final content = RepaintBoundary(
      child: Material(type: MaterialType.transparency, child: child),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : tokens.minimumTouchTarget;
        // 两侧仅轻微扩张；宽列表不会按图片网格的比例放大到屏幕之外。
        final expansion =
            tokens.space4 /
            width.clamp(tokens.minimumTouchTarget, double.infinity);
        Widget frame(double progress, Widget child) => Transform.translate(
          offset: Offset(0, -tokens.space4 * progress),
          child: Transform.scale(
            scale: 1 + expansion * progress,
            child: PhysicalModel(
              color: Color.lerp(Colors.transparent, tokens.panel, progress)!,
              shadowColor: Theme.of(
                context,
              ).shadowColor.withValues(alpha: 0.16),
              elevation: tokens.space4 * progress,
              borderRadius: BorderRadius.circular(tokens.radius12),
              child: child,
            ),
          ),
        );
        if (reduced) return frame(0, content);
        final externalAnimation = animation;
        if (externalAnimation != null) {
          return AnimatedBuilder(
            animation: externalAnimation,
            child: content,
            builder: (_, child) => frame(
              wenyouStandardMotionCurve.transform(externalAnimation.value),
              child!,
            ),
          );
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: lifted ? 1 : 0),
          duration: WenyouFoundationMotion.standard,
          curve: wenyouStandardMotionCurve,
          child: content,
          builder: (_, progress, child) => frame(progress, child!),
        );
      },
    );
  }
}

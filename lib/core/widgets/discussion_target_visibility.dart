import 'package:flutter/widgets.dart';

/// 将真实阅读可见性传给目标卡，避免定位提示在遮罩背后提前结束。
class DiscussionTargetVisibility extends InheritedWidget {
  const DiscussionTargetVisibility({
    required this.visible,
    required super.child,
    super.key,
  });

  final bool visible;

  static DiscussionTargetVisibility? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DiscussionTargetVisibility>();

  @override
  bool updateShouldNotify(DiscussionTargetVisibility oldWidget) =>
      oldWidget.visible != visible;
}

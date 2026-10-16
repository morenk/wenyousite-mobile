import 'package:flutter/widgets.dart';

/// 工具区外层可能用滚动容器测量高度，显式保留真正可见的父约束。
class EditorToolArea extends InheritedWidget {
  const EditorToolArea({
    required this.availableHeight,
    required super.child,
    super.key,
  });

  final double availableHeight;

  static double? heightOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<EditorToolArea>()
      ?.availableHeight;

  @override
  bool updateShouldNotify(EditorToolArea oldWidget) =>
      oldWidget.availableHeight != availableHeight;
}

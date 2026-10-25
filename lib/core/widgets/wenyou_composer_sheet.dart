import 'package:flutter/material.dart';

Future<T?> showWenyouComposerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool useSafeArea = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: false,
    useSafeArea: useSafeArea,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: builder,
  );
}

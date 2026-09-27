import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 同时支持原生按钮与共享组件，断言真正可点击控件的禁用状态。
Finder findButtonControl(Finder target) => find.descendant(
  of: target,
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is FilledButton ||
        widget is OutlinedButton ||
        widget is TextButton ||
        widget is ElevatedButton ||
        widget is IconButton,
  ),
  matchRoot: true,
);

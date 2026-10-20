import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

/// 仅指定正文片段参与动态字体加载，UI 字体仍由应用主题决定。
class TextFontScope extends ConsumerStatefulWidget {
  const TextFontScope({required this.texts, required this.builder, super.key});
  final Map<String, String> texts;
  final Widget Function(BuildContext, TextFontRuntime?) builder;
  @override
  ConsumerState<TextFontScope> createState() => _TextFontScopeState();
}

class _TextFontScopeState extends ConsumerState<TextFontScope> {
  TextFontRuntime? _runtime;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant TextFontScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_load());
  }

  Future<void> _load() async {
    if (widget.texts.isEmpty) return;
    try {
      final runtime = await ref.read(textFontServiceProvider).load();
      if (!mounted) return;
      if (_runtime != runtime) {
        _runtime?.removeListener(_changed);
        _runtime = runtime..addListener(_changed);
        _changed();
      }
      for (final entry in widget.texts.entries) {
        unawaited(runtime.ensure(entry.key, entry.value));
      }
    } on Object {
      // 平台目录不可用时同样只回退正文，不阻断编辑。
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    final runtime = _runtime;
    if (runtime != null) {
      for (final entry in widget.texts.entries) {
        unawaited(runtime.ensure(entry.key, entry.value));
      }
    }
  }

  @override
  void dispose() {
    _runtime?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _runtime);
}

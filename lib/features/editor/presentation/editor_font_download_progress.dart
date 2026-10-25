import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_progress.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';

/// 只订阅本编辑器主动选择所需的分片，不将传输进度传播为正文重建。
class EditorFontDownloadProgress extends StatefulWidget {
  const EditorFontDownloadProgress({
    required this.runtime,
    required this.font,
    required this.text,
    required this.generation,
    super.key,
  });
  final TextFontRuntime? runtime;
  final String? font;
  final String text;
  final int generation;
  @override
  State<EditorFontDownloadProgress> createState() =>
      _EditorFontDownloadProgressState();
}

class _EditorFontDownloadProgressState
    extends State<EditorFontDownloadProgress> {
  final _tracked = <String>{};
  Timer? _reveal;
  bool _visible = false;

  @override
  void didUpdateWidget(covariant EditorFontDownloadProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.font != widget.font ||
        oldWidget.generation != widget.generation) {
      _tracked.clear();
      _hide();
    }
  }

  void _hide() {
    _reveal?.cancel();
    _reveal = null;
    _visible = false;
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = widget.runtime?.demandQueue;
    return queue == null
        ? _buildProgress(context)
        : ListenableBuilder(
            listenable: queue.progress,
            builder: (context, _) => _buildProgress(context),
          );
  }

  Widget _buildProgress(BuildContext context) {
    final font = widget.font;
    if (font == null || widget.text.trim().isEmpty) {
      _hide();
      return const SizedBox.shrink();
    }
    final queue = widget.runtime?.demandQueue;
    final progress = widget.runtime?.fontUnavailable?.call(font) == true
        ? const TextFontLoadProgress(phase: TextFontProgressPhase.failed)
        : queue?.progressFor(font, widget.text, _tracked) ??
              const TextFontLoadProgress(
                phase: TextFontProgressPhase.preparing,
              );
    if (progress.phase == TextFontProgressPhase.complete) {
      _tracked.clear();
      _hide();
      return const SizedBox.shrink();
    }
    final metadataUnknown = widget.runtime?.manifest?.fonts[font] == null;
    if (!metadataUnknown &&
        !progress.usedNetwork &&
        progress.phase != TextFontProgressPhase.waiting &&
        progress.phase != TextFontProgressPhase.failed) {
      // 已校验缓存直接注册，不闪现下载条。
      _hide();
      return const SizedBox.shrink();
    }
    if (!_visible) {
      _reveal ??= Timer(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _visible = true);
      });
      return const SizedBox.shrink();
    }
    final label = switch (progress.phase) {
      TextFontProgressPhase.preparing => '准备字体',
      TextFontProgressPhase.downloading => '下载字体',
      TextFontProgressPhase.waiting => '等待下载',
      TextFontProgressPhase.applying => '正在应用',
      TextFontProgressPhase.failed => '字体暂不可用',
      TextFontProgressPhase.complete => '字体已应用',
    };
    final total = progress.totalBytes;
    final counter =
        progress.phase == TextFontProgressPhase.downloading ||
            progress.phase == TextFontProgressPhase.preparing &&
                progress.receivedBytes > 0
        ? '${_bytes(progress.receivedBytes)}${total == null ? '' : ' / ${_bytes(total)}'}'
        : '';
    final tokens = context.wenyouTokens;
    return Semantics(
      key: const Key('editor-font-download-progress'),
      label: label,
      liveRegion: true,
      // 读屏只播阶段变化，不逐个网络分块播报数字。
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space16,
            vertical: tokens.space4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultTextStyle(
                style: Theme.of(context).textTheme.wenyouCaption,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: tokens.space8,
                  children: [
                    Text(label),
                    if (counter.isNotEmpty) Text(counter),
                  ],
                ),
              ),
              SizedBox(height: tokens.space4),
              if (progress.phase != TextFontProgressPhase.failed)
                LinearProgressIndicator(
                  key: const Key('editor-font-download-line'),
                  value: progress.fraction,
                  minHeight: 2,
                  color: tokens.actionSurface,
                  backgroundColor: tokens.softPanel,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _bytes(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(1)} MB'
      : '${(value / 1000).round()} KB';
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ContentImageViewerPage extends StatefulWidget {
  const ContentImageViewerPage({
    required this.url,
    required this.alt,
    this.onSaveImage,
    super.key,
  });

  final String url;
  final String alt;
  final Future<String> Function()? onSaveImage;

  @override
  State<ContentImageViewerPage> createState() => _ContentImageViewerPageState();
}

class _ContentImageViewerPageState extends State<ContentImageViewerPage> {
  bool _saving = false;
  ApiFailure? _saveFailure;

  @override
  Widget build(BuildContext context) {
    final alt = widget.alt.trim();
    final tokens = context.wenyouTokens;
    return WenyouImageViewerPage(
      viewerKey: const Key('content-image-viewer'),
      closeTooltip: '关闭原图',
      items: [
        WenyouImageViewerItem(
          url: widget.url,
          semanticLabel: alt.isEmpty ? '正文插图原图' : alt,
        ),
      ],
      titleBuilder: (_, _) => alt.isEmpty ? '正文插图' : alt,
      actions: [
        if (widget.onSaveImage != null)
          PopupMenuButton<_ContentImageAction>(
            key: const Key('content-image-actions'),
            tooltip: '图片操作',
            enabled: !_saving,
            onSelected: (action) {
              if (action == _ContentImageAction.saveSticker) {
                unawaited(_saveImage());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _ContentImageAction.saveSticker,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: WenyouIcon(WenyouIconIds.actionAddReaction),
                  title: Text('添加到表情收藏'),
                ),
              ),
            ],
          ),
        if (_saving)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.onImageViewerBackground,
                ),
              ),
            ),
          ),
      ],
      bottomOverlay: _saveFailure == null
          ? null
          : WenyouFailureBanner(
              failure: _saveFailure!,
              action: TextButton(
                key: const Key('content-image-save-retry'),
                onPressed: _saving ? null : _saveImage,
                child: const Text('重试收藏'),
              ),
            ),
    );
  }

  Future<void> _saveImage() async {
    if (_saving || widget.onSaveImage == null) return;
    setState(() {
      _saving = true;
      _saveFailure = null;
    });
    try {
      final message = await widget.onSaveImage!();
      if (!mounted) return;
      showWenyouSnackBar(context, message);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saveFailure = error is ApiFailure
            ? error
            : const ApiFailure(userMessage: '收藏表情失败，请稍后重试。');
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

enum _ContentImageAction { saveSticker }

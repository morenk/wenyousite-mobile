import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

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
  final TransformationController _transformationController =
      TransformationController();
  double _verticalDrag = 0;
  bool _saving = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alt = widget.alt.trim();
    return Scaffold(
      key: const Key('content-image-viewer'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(alt.isEmpty ? '正文插图' : alt),
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
                    leading: Icon(Icons.add_reaction_outlined),
                    title: Text('添加到表情收藏'),
                  ),
                ),
              ],
            ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: () {
          final zoomed =
              _transformationController.value.getMaxScaleOnAxis() > 1.01;
          _transformationController.value = zoomed
              ? Matrix4.identity()
              : Matrix4.diagonal3Values(2, 2, 1);
        },
        onVerticalDragUpdate: (details) {
          if (_transformationController.value.getMaxScaleOnAxis() <= 1.01) {
            _verticalDrag += details.delta.dy;
          }
        },
        onVerticalDragEnd: (_) {
          if (_verticalDrag > 80 && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          _verticalDrag = 0;
        },
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: Image.network(
              widget.url,
              fit: BoxFit.contain,
              semanticLabel: alt.isEmpty ? '正文插图原图' : alt,
              errorBuilder: (_, _, _) => const _UnavailableContentImage(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_saving || widget.onSaveImage == null) return;
    setState(() => _saving = true);
    try {
      final message = await widget.onSaveImage!();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!mounted) return;
      final message = error is ApiFailure ? error.userMessage : '收藏表情失败，请稍后重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

enum _ContentImageAction { saveSticker }

class _UnavailableContentImage extends StatelessWidget {
  const _UnavailableContentImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      color: context.wenyouTokens.softPanel,
      padding: EdgeInsets.all(context.wenyouTokens.space16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined),
          SizedBox(height: 8),
          Text('原图加载失败，请检查网络后返回重试', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

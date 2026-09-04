import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ContentImageViewerPage extends ConsumerStatefulWidget {
  const ContentImageViewerPage({
    required this.items,
    this.initialIndex = 0,
    this.onAddToStickers,
    this.closeKey,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length);

  factory ContentImageViewerPage.single({
    required String url,
    required String alt,
    List<String> fallbackUrls = const [],
    Object? id,
    Future<String> Function(WenyouImageViewerItem item)? onAddToStickers,
    Key? key,
  }) {
    final normalizedAlt = alt.trim();
    return ContentImageViewerPage(
      key: key,
      items: [
        WenyouImageViewerItem(
          url: url,
          fallbackUrls: fallbackUrls,
          semanticLabel: normalizedAlt.isEmpty ? '正文插图原图' : normalizedAlt,
          id: id,
        ),
      ],
      onAddToStickers: onAddToStickers,
    );
  }

  final List<WenyouImageViewerItem> items;
  final int initialIndex;
  final Future<String> Function(WenyouImageViewerItem item)? onAddToStickers;
  final Key? closeKey;

  @override
  ConsumerState<ContentImageViewerPage> createState() =>
      _ContentImageViewerPageState();
}

class _ContentImageViewerPageState
    extends ConsumerState<ContentImageViewerPage> {
  late int _index;
  _ContentImageAction? _busyAction;
  _ContentImageFailure? _failure;
  ImageGallerySaveOperation? _saveOperation;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
    _saveOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final gallery = ref.watch(imageGalleryServiceProvider);
    final canSave = gallery.isSupported;
    final canAddSticker = widget.onAddToStickers != null;
    final currentFailure = _failure?.targetIndex == _index ? _failure : null;
    return WenyouImageViewerPage(
      viewerKey: const Key('content-image-viewer'),
      closeTooltip: '关闭原图',
      closeKey: widget.closeKey,
      items: widget.items,
      initialIndex: widget.initialIndex,
      onPageChanged: (index) => setState(() => _index = index),
      titleBuilder: (index, count) {
        final label = widget.items[index].semanticLabel.trim();
        if (count == 1) return label.isEmpty ? '查看原图' : label;
        return '${index + 1} / $count';
      },
      actions: [
        if (canSave || canAddSticker)
          PopupMenuButton<_ContentImageAction>(
            key: const Key('content-image-actions'),
            tooltip: '图片操作',
            enabled: _busyAction == null,
            onSelected: (action) {
              switch (action) {
                case _ContentImageAction.saveImage:
                  unawaited(_saveImage(_index));
                case _ContentImageAction.addSticker:
                  unawaited(_addToStickers(_index));
              }
            },
            itemBuilder: (context) => [
              if (canSave)
                const PopupMenuItem(
                  value: _ContentImageAction.saveImage,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: WenyouIcon(WenyouIconIds.actionDownload),
                    title: Text('保存图片'),
                  ),
                ),
              if (canAddSticker)
                const PopupMenuItem(
                  value: _ContentImageAction.addSticker,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: WenyouIcon(WenyouIconIds.actionAddReaction),
                    title: Text('添加到表情收藏'),
                  ),
                ),
            ],
          ),
        if (_busyAction != null)
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
      bottomOverlay: currentFailure == null
          ? null
          : WenyouFailureView(
              failure: currentFailure.failure,
              action: TextButton(
                key: const Key('content-image-action-retry'),
                onPressed: _busyAction == null
                    ? () => unawaited(_retry(currentFailure))
                    : null,
                child: Text(currentFailure.actionLabel),
              ),
            ),
    );
  }

  Future<void> _saveImage(int targetIndex) async {
    if (_busyAction != null) return;
    final gallery = ref.read(imageGalleryServiceProvider);
    if (!gallery.isSupported) return;
    final item = widget.items[targetIndex];
    setState(() {
      _busyAction = _ContentImageAction.saveImage;
      _failure = null;
    });
    final operation = gallery.startSave(
      ImageGallerySource(url: item.url, fallbackUrls: item.fallbackUrls),
    );
    _saveOperation = operation;
    try {
      await operation.result;
      if (!mounted) return;
      showWenyouSnackBar(
        context,
        '图片已保存到系统相册。',
        tone: WenyouSnackBarTone.success,
      );
    } on Object catch (error) {
      if (!mounted) return;
      final galleryFailure = error is ImageGalleryException ? error : null;
      setState(() {
        _failure = _ContentImageFailure(
          targetIndex: targetIndex,
          action: _ContentImageAction.saveImage,
          failure: _localFailure(
            title: '图片保存失败',
            message: galleryFailure?.userMessage ?? '图片保存失败，请稍后重试。',
            recoveryAction: galleryFailure?.settingsRequired ?? false
                ? FailureRecoveryAction.reopen
                : FailureRecoveryAction.retry,
          ),
          settingsRequired: galleryFailure?.settingsRequired ?? false,
        );
      });
    } finally {
      _saveOperation = null;
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Future<void> _addToStickers(int targetIndex) async {
    final addToStickers = widget.onAddToStickers;
    if (_busyAction != null || addToStickers == null) return;
    setState(() {
      _busyAction = _ContentImageAction.addSticker;
      _failure = null;
    });
    try {
      final message = await addToStickers(widget.items[targetIndex]);
      if (!mounted) return;
      showWenyouSnackBar(context, message, tone: WenyouSnackBarTone.success);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = _ContentImageFailure(
          targetIndex: targetIndex,
          action: _ContentImageAction.addSticker,
          failure: error is ApiFailure
              ? UserFacingFailure.fromApi(error)
              : _localFailure(title: '收藏表情失败', message: '收藏表情失败，请稍后重试。'),
        );
      });
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Future<void> _retry(_ContentImageFailure failure) async {
    if (failure.settingsRequired) {
      try {
        await ref.read(imageGalleryServiceProvider).openSettings();
      } on Object catch (error) {
        if (!mounted) return;
        setState(() {
          _failure = _ContentImageFailure(
            targetIndex: failure.targetIndex,
            action: failure.action,
            failure: _localFailure(
              title: '系统设置无法打开',
              message: error is ImageGalleryException
                  ? error.userMessage
                  : '系统设置无法打开，请稍后重试。',
              recoveryAction: FailureRecoveryAction.reopen,
            ),
            settingsRequired: true,
          );
        });
      }
      return;
    }
    switch (failure.action) {
      case _ContentImageAction.saveImage:
        await _saveImage(failure.targetIndex);
      case _ContentImageAction.addSticker:
        await _addToStickers(failure.targetIndex);
    }
  }
}

enum _ContentImageAction { saveImage, addSticker }

class _ContentImageFailure {
  const _ContentImageFailure({
    required this.targetIndex,
    required this.action,
    required this.failure,
    this.settingsRequired = false,
  });

  final int targetIndex;
  final _ContentImageAction action;
  final UserFacingFailure failure;
  final bool settingsRequired;

  String get actionLabel {
    if (settingsRequired) return '前往设置';
    return action == _ContentImageAction.saveImage ? '重试保存' : '重试收藏';
  }
}

UserFacingFailure _localFailure({
  required String title,
  required String message,
  FailureRecoveryAction recoveryAction = FailureRecoveryAction.retry,
}) {
  return UserFacingFailure(
    title: title,
    message: message,
    recoveryAction: recoveryAction,
    placement: FailurePresentationPlacement.inline,
    retainContent: true,
  );
}

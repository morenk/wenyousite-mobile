import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ContentImageViewerPage extends ConsumerStatefulWidget {
  const ContentImageViewerPage({
    required this.items,
    this.initialIndex = 0,
    this.onAddToStickers,
    this.closeKey,
    this.imageBuilder,
    this.titleBuilder,
    this.bottomOverlay,
    this.extraActions = const [],
    this.onPageChanged,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length);

  factory ContentImageViewerPage.single({
    required String url,
    required String alt,
    List<String> fallbackUrls = const [],
    Object? id,
    MediaDisplay? display,
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
          display: display,
        ),
      ],
      onAddToStickers: onAddToStickers,
    );
  }

  final List<WenyouImageViewerItem> items;
  final int initialIndex;
  final Future<String> Function(WenyouImageViewerItem item)? onAddToStickers;
  final Key? closeKey;
  final String Function(int index, int count)? titleBuilder;
  final Widget? bottomOverlay;
  final List<Widget> extraActions;
  final ValueChanged<int>? onPageChanged;
  final Widget? Function(BuildContext context, int index, bool current)?
  imageBuilder;

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
  bool _sessionInvalidated = false;

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
  void didUpdateWidget(covariant ContentImageViewerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldItem = oldWidget.items[_index];
    final next = oldItem.id == null
        ? _index.clamp(0, widget.items.length - 1)
        : widget.items.indexWhere((item) => item.id == oldItem.id);
    _index = next >= 0 ? next : widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(viewerScopeProvider, (previous, next) {
      if (previous != null && previous != next) {
        _saveOperation?.cancel();
        setState(() => _sessionInvalidated = true);
      }
    });
    if (_sessionInvalidated) {
      return Scaffold(
        appBar: AppBar(title: const Text('查看图片')),
        body: const Center(child: Text('请重新打开图片')),
      );
    }
    final tokens = context.wenyouTokens;
    final gallery = ref.watch(imageGalleryServiceProvider);
    final canSave = gallery.isSupported;
    final canAddSticker = widget.onAddToStickers != null;
    final failedItem = _failure?.item;
    final currentFailure =
        failedItem != null &&
            (failedItem.id == null
                ? identical(failedItem, widget.items[_index])
                : failedItem.id == widget.items[_index].id)
        ? _failure
        : null;
    return WenyouImageViewerPage(
      viewerKey: const Key('content-image-viewer'),
      closeTooltip: '关闭原图',
      closeKey: widget.closeKey,
      items: widget.items,
      imageBuilder: widget.imageBuilder,
      initialIndex: widget.initialIndex,
      onPageChanged: (index) {
        setState(() => _index = index);
        widget.onPageChanged?.call(index);
      },
      titleBuilder:
          widget.titleBuilder ??
          (index, count) {
            final label = widget.items[index].semanticLabel.trim();
            if (count == 1) return label.isEmpty ? '查看原图' : label;
            return '${index + 1} / $count';
          },
      actions: [
        ...widget.extraActions,
        if (canSave || canAddSticker)
          PopupMenuButton<_ContentImageAction>(
            icon: const WenyouIcon(WenyouIconIds.actionMore),
            key: const Key('content-image-actions'),
            tooltip: '图片操作',
            enabled: _busyAction == null,
            onSelected: (action) {
              switch (action) {
                case _ContentImageAction.saveImage:
                  unawaited(_saveImage(widget.items[_index]));
                case _ContentImageAction.addSticker:
                  unawaited(_addToStickers(widget.items[_index]));
              }
            },
            itemBuilder: (context) => [
              if (canSave)
                const PopupMenuItem(
                  value: _ContentImageAction.saveImage,
                  child: WenyouMenuActionLabel(
                    icon: WenyouIconIds.actionDownload,
                    label: '保存图片',
                  ),
                ),
              if (canAddSticker)
                const PopupMenuItem(
                  value: _ContentImageAction.addSticker,
                  child: WenyouMenuActionLabel(
                    icon: WenyouIconIds.actionAddReaction,
                    label: '添加到表情收藏',
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
          ? widget.bottomOverlay
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

  Future<void> _saveImage(WenyouImageViewerItem item) async {
    if (_busyAction != null) return;
    final gallery = ref.read(imageGalleryServiceProvider);
    if (!gallery.isSupported) return;

    setState(() {
      _busyAction = _ContentImageAction.saveImage;
      _failure = null;
    });
    final operation = gallery.startSave(
      ImageGallerySource(
        url: item.displayUrls.first,
        fallbackUrls: item.displayUrls.skip(1).toList(growable: false),
      ),
    );
    _saveOperation = operation;
    try {
      await operation.result;
      if (!mounted || _sessionInvalidated) return;
      showWenyouSnackBar(
        context,
        '图片已保存到系统相册。',
        tone: WenyouSnackBarTone.success,
      );
    } on Object catch (error) {
      if (!mounted || _sessionInvalidated) return;
      final galleryFailure = error is ImageGalleryException ? error : null;
      setState(() {
        _failure = _ContentImageFailure(
          item: item,
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

  Future<void> _addToStickers(WenyouImageViewerItem item) async {
    final addToStickers = widget.onAddToStickers;
    if (_busyAction != null || addToStickers == null) return;
    setState(() {
      _busyAction = _ContentImageAction.addSticker;
      _failure = null;
    });
    try {
      final message = await addToStickers(item);
      if (!mounted || _sessionInvalidated) return;
      showWenyouSnackBar(context, message, tone: WenyouSnackBarTone.success);
    } on Object catch (error) {
      if (!mounted || _sessionInvalidated) return;
      setState(() {
        _failure = _ContentImageFailure(
          item: item,
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
        if (!mounted || _sessionInvalidated) return;
        setState(() {
          _failure = _ContentImageFailure(
            item: failure.item,
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
        await _saveImage(failure.item);
      case _ContentImageAction.addSticker:
        await _addToStickers(failure.item);
    }
  }
}

enum _ContentImageAction { saveImage, addSticker }

class _ContentImageFailure {
  const _ContentImageFailure({
    required this.item,
    required this.action,
    required this.failure,
    this.settingsRequired = false,
  });

  final WenyouImageViewerItem item;
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';

enum PendingImageAction { retry, remove }

Future<PendingImageAction?> showPendingImageActions(
  BuildContext context, {
  required String title,
  required String removeLabel,
  String retryLabel = '重试',
  String? detail,
  bool canRetry = true,
}) => showWenyouSheet<PendingImageAction>(
  context: context,
  builder: (sheetContext) => WenyouSheetBody(
    title: title,
    slivers: [
      if (detail != null) SliverToBoxAdapter(child: Text(detail)),
      if (canRetry)
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(retryLabel),
            onTap: () =>
                Navigator.of(sheetContext).pop(PendingImageAction.retry),
          ),
        ),
      SliverToBoxAdapter(
        child: ListTile(
          title: Text(removeLabel),
          onTap: () =>
              Navigator.of(sheetContext).pop(PendingImageAction.remove),
        ),
      ),
    ],
  ),
);

/// 图片承载自己的等待状态；排队、就绪和短于 300ms 的工作不遮挡预览。
class PendingImageOverlay extends StatefulWidget {
  const PendingImageOverlay({
    required this.child,
    required this.active,
    this.failed = false,
    this.onFailureTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final bool active;
  final bool failed;
  final VoidCallback? onFailureTap;
  final String? semanticLabel;

  @override
  State<PendingImageOverlay> createState() => _PendingImageOverlayState();
}

class _PendingImageOverlayState extends State<PendingImageOverlay> {
  Timer? _timer;
  bool _showWaiting = false;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant PendingImageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.failed != widget.failed) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (!widget.active || widget.failed) {
      _showWaiting = false;
      return;
    }
    _showWaiting = false;
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && widget.active && !widget.failed) {
        setState(() => _showWaiting = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      image: true,
      label:
          widget.semanticLabel ??
          (widget.failed
              ? '图片未完成，点按选择操作'
              : widget.active
              ? '图片准备中'
              : '图片预览'),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (_showWaiting && widget.active && !widget.failed)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: tokens.text.withValues(alpha: 0.20),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tokens.onBrandSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.failed)
            Positioned.fill(
              child: Material(
                color: tokens.text.withValues(alpha: 0.28),
                child: InkWell(
                  onTap: widget.onFailureTap,
                  child: Center(
                    child: WenyouIcon(
                      WenyouIconIds.statusError,
                      color: tokens.onBrandSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

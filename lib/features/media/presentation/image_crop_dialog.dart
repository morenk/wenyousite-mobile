import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

Future<MediaUploadInput?> showAvatarCropDialog(
  BuildContext context, {
  required MediaUploadInput input,
  required ImageCropProcessor processor,
}) {
  return showDialog<MediaUploadInput>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AvatarCropDialog(input: input, processor: processor),
  );
}

Future<ProfileCoverImageSelection?> showProfileCoverCropDialog(
  BuildContext context, {
  required MediaUploadInput input,
  required ImageCropProcessor processor,
}) {
  return showDialog<ProfileCoverImageSelection>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProfileCoverCropDialog(input: input, processor: processor),
  );
}

class _AvatarCropDialog extends StatefulWidget {
  const _AvatarCropDialog({required this.input, required this.processor});

  final MediaUploadInput input;
  final ImageCropProcessor processor;

  @override
  State<_AvatarCropDialog> createState() => _AvatarCropDialogState();
}

class _AvatarCropDialogState extends State<_AvatarCropDialog> {
  CropImageSource? _source;
  _CropViewportController? _controller;
  String? _error;
  var _processing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final source = await widget.processor.prepare(widget.input);
      if (!mounted) return;
      setState(() {
        _source = source;
        _controller = _CropViewportController(
          sourceAspectRatio: source.width / source.height,
          targetAspectRatio: 1,
        );
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    }
  }

  Future<void> _save() async {
    final source = _source;
    final controller = _controller;
    if (source == null || controller == null || _processing) return;
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final output = await widget.processor.cropAvatar(source, controller.crop);
      if (!mounted) return;
      Navigator.pop(context, output);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = _messageFor(error);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CropDialogFrame(
      key: const Key('avatar-crop-dialog'),
      title: '裁剪头像',
      description: '拖动图片调整位置，双指缩放或使用滑杆调整取景。',
      processing: _processing,
      error: _error,
      onCancel: () => Navigator.pop(context),
      onSave: _source == null ? null : _save,
      child: _source == null || _controller == null
          ? const _CropPreparing(label: '正在准备头像…')
          : _CropEditor(
              key: const Key('avatar-crop-editor'),
              source: _source!,
              controller: _controller!,
              roundMask: true,
            ),
    );
  }
}

enum _CoverSurface { web, mobile }

class _ProfileCoverCropDialog extends StatefulWidget {
  const _ProfileCoverCropDialog({required this.input, required this.processor});

  final MediaUploadInput input;
  final ImageCropProcessor processor;

  @override
  State<_ProfileCoverCropDialog> createState() =>
      _ProfileCoverCropDialogState();
}

class _ProfileCoverCropDialogState extends State<_ProfileCoverCropDialog> {
  CropImageSource? _source;
  _CropViewportController? _webController;
  _CropViewportController? _mobileController;
  _CoverSurface _surface = _CoverSurface.web;
  String? _error;
  var _processing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final source = await widget.processor.prepare(widget.input);
      if (!mounted) return;
      setState(() {
        _source = source;
        final sourceAspect = source.width / source.height;
        _webController = _CropViewportController(
          sourceAspectRatio: sourceAspect,
          targetAspectRatio: 3,
        );
        _mobileController = _CropViewportController(
          sourceAspectRatio: sourceAspect,
          targetAspectRatio: 2,
        );
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    }
  }

  Future<void> _save() async {
    final source = _source;
    final webController = _webController;
    final mobileController = _mobileController;
    if (source == null ||
        webController == null ||
        mobileController == null ||
        _processing) {
      return;
    }
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final output = await widget.processor.cropProfileCover(
        source,
        webCrop: webController.crop,
        mobileCrop: mobileController.crop,
      );
      if (!mounted) return;
      Navigator.pop(context, output);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = _messageFor(error);
      });
    }
  }

  @override
  void dispose() {
    _webController?.dispose();
    _mobileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    final activeController = switch (_surface) {
      _CoverSurface.web => _webController,
      _CoverSurface.mobile => _mobileController,
    };
    return _CropDialogFrame(
      key: const Key('profile-cover-crop-dialog'),
      title: '调整主页背景取景',
      description: '同一张原图需要分别确认电脑端和移动端的展示范围。',
      processing: _processing,
      error: _error,
      onCancel: () => Navigator.pop(context),
      onSave: source == null ? null : _save,
      child: source == null || activeController == null
          ? const _CropPreparing(label: '正在准备背景图…')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<_CoverSurface>(
                  key: const Key('profile-cover-crop-surface'),
                  segments: const [
                    ButtonSegment(
                      value: _CoverSurface.web,
                      label: Text('电脑端 3:1'),
                    ),
                    ButtonSegment(
                      value: _CoverSurface.mobile,
                      label: Text('移动端 2:1'),
                    ),
                  ],
                  selected: {_surface},
                  onSelectionChanged: _processing
                      ? null
                      : (selection) =>
                            setState(() => _surface = selection.single),
                ),
                SizedBox(height: context.wenyouTokens.space12),
                _CropEditor(
                  key: ValueKey('profile-cover-crop-${_surface.name}'),
                  source: source,
                  controller: activeController,
                ),
                SizedBox(height: context.wenyouTokens.space8),
                Text(
                  _surface == _CoverSurface.web
                      ? '电脑端会生成 1920 × 640 图片'
                      : '移动端会生成 1600 × 800 图片',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _CropDialogFrame extends StatelessWidget {
  const _CropDialogFrame({
    required this.title,
    required this.description,
    required this.processing,
    required this.error,
    required this.onCancel,
    required this.onSave,
    required this.child,
    super.key,
  });

  final String title;
  final String description;
  final bool processing;
  final String? error;
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return PopScope(
      canPop: !processing,
      child: Dialog(
        insetPadding: EdgeInsets.all(tokens.space12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: MediaQuery.sizeOf(context).height - tokens.space24,
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              key: const Key('image-crop-close'),
                              tooltip: '取消',
                              onPressed: processing ? null : onCancel,
                              icon: const WenyouIcon(WenyouIconIds.actionClose),
                            ),
                          ],
                        ),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: tokens.space16),
                        child,
                        if (error != null) ...[
                          SizedBox(height: tokens.space12),
                          Text(
                            error!,
                            key: const Key('image-crop-error'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: processing ? null : onCancel,
                      child: const Text('取消'),
                    ),
                    SizedBox(width: tokens.space8),
                    FilledButton.icon(
                      key: const Key('image-crop-confirm'),
                      onPressed: processing ? null : onSave,
                      icon: processing
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionConfirm),
                      label: Text(processing ? '正在生成…' : '确认取景'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropPreparing extends StatelessWidget {
  const _CropPreparing({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: context.wenyouTokens.space12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _CropEditor extends StatelessWidget {
  const _CropEditor({
    required this.source,
    required this.controller,
    this.roundMask = false,
    super.key,
  });

  final CropImageSource source;
  final _CropViewportController controller;
  final bool roundMask;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: roundMask ? 340 : double.infinity,
            maxHeight: roundMask ? 340 : 280,
          ),
          child: AspectRatio(
            aspectRatio: controller.targetAspectRatio,
            child: _CropViewport(
              source: source,
              controller: controller,
              roundMask: roundMask,
            ),
          ),
        ),
        SizedBox(height: context.wenyouTokens.space8),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Row(
            children: [
              const Text('缩放'),
              Expanded(
                child: Slider(
                  key: const Key('image-crop-zoom'),
                  min: 1,
                  max: 3,
                  value: controller.zoom,
                  onChanged: controller.setZoom,
                ),
              ),
              SizedBox(
                width: 42,
                child: Text('${controller.zoom.toStringAsFixed(1)}×'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CropViewport extends StatefulWidget {
  const _CropViewport({
    required this.source,
    required this.controller,
    required this.roundMask,
  });

  final CropImageSource source;
  final _CropViewportController controller;
  final bool roundMask;

  @override
  State<_CropViewport> createState() => _CropViewportState();
}

class _CropViewportState extends State<_CropViewport> {
  double _startZoom = 1;
  Offset _startCenter = const Offset(.5, .5);
  Offset _startFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          key: const Key('image-crop-viewport'),
          behavior: HitTestBehavior.opaque,
          onScaleStart: (details) {
            _startZoom = widget.controller.zoom;
            _startCenter = widget.controller.center;
            _startFocalPoint = details.localFocalPoint;
          },
          onScaleUpdate: (details) {
            widget.controller.updateGesture(
              viewport: viewport,
              startZoom: _startZoom,
              startCenter: _startCenter,
              focalDelta: details.localFocalPoint - _startFocalPoint,
              scale: details.scale,
            );
          },
          child: ClipRect(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final geometry = widget.controller.geometry(viewport);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: tokens.softPanel),
                    Center(
                      child: Transform.translate(
                        offset: geometry.offset,
                        child: Transform.scale(
                          scale: widget.controller.zoom,
                          child: SizedBox(
                            width: geometry.baseSize.width,
                            height: geometry.baseSize.height,
                            child: Image.memory(
                              widget.source.previewBytes,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _CropFramePainter(
                          round: widget.roundMask,
                          borderColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CropViewportController extends ChangeNotifier {
  _CropViewportController({
    required this.sourceAspectRatio,
    required this.targetAspectRatio,
  });

  final double sourceAspectRatio;
  final double targetAspectRatio;
  double zoom = 1;
  Offset center = const Offset(.5, .5);

  NormalizedCropRect get crop {
    final baseWidth = sourceAspectRatio > targetAspectRatio
        ? targetAspectRatio / sourceAspectRatio
        : 1.0;
    final baseHeight = sourceAspectRatio > targetAspectRatio
        ? 1.0
        : sourceAspectRatio / targetAspectRatio;
    final width = baseWidth / zoom;
    final height = baseHeight / zoom;
    return NormalizedCropRect(
      left: center.dx - width / 2,
      top: center.dy - height / 2,
      width: width,
      height: height,
    );
  }

  void setZoom(double value) {
    zoom = value.clamp(1, 3);
    _clampCenter();
    notifyListeners();
  }

  void updateGesture({
    required Size viewport,
    required double startZoom,
    required Offset startCenter,
    required Offset focalDelta,
    required double scale,
  }) {
    zoom = (startZoom * scale).clamp(1, 3);
    final geometry = this.geometry(viewport);
    final scaledWidth = geometry.baseSize.width * zoom;
    final scaledHeight = geometry.baseSize.height * zoom;
    center = Offset(
      startCenter.dx - focalDelta.dx / scaledWidth,
      startCenter.dy - focalDelta.dy / scaledHeight,
    );
    _clampCenter();
    notifyListeners();
  }

  _CropGeometry geometry(Size viewport) {
    final viewportAspect = viewport.width / viewport.height;
    final baseSize = sourceAspectRatio > viewportAspect
        ? Size(viewport.height * sourceAspectRatio, viewport.height)
        : Size(viewport.width, viewport.width / sourceAspectRatio);
    return _CropGeometry(
      baseSize: baseSize,
      offset: Offset(
        -((center.dx - .5) * baseSize.width * zoom),
        -((center.dy - .5) * baseSize.height * zoom),
      ),
    );
  }

  void _clampCenter() {
    final rect = crop;
    final halfWidth = rect.width / 2;
    final halfHeight = rect.height / 2;
    center = Offset(
      center.dx.clamp(halfWidth, 1 - halfWidth),
      center.dy.clamp(halfHeight, 1 - halfHeight),
    );
  }
}

class _CropGeometry {
  const _CropGeometry({required this.baseSize, required this.offset});

  final Size baseSize;
  final Offset offset;
}

class _CropFramePainter extends CustomPainter {
  const _CropFramePainter({required this.round, required this.borderColor});

  final bool round;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor.withValues(alpha: .9);
    if (round) {
      final oval = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
      final shade = Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addOval(oval),
      );
      canvas.drawPath(
        shade,
        Paint()..color = Colors.black.withValues(alpha: .5),
      );
      canvas.drawOval(oval, border);
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      border,
    );
    final grid = Paint()
      ..strokeWidth = 1
      ..color = borderColor.withValues(alpha: .45);
    for (final fraction in const [1 / 3, 2 / 3]) {
      canvas.drawLine(
        Offset(size.width * fraction, 0),
        Offset(size.width * fraction, size.height),
        grid,
      );
      canvas.drawLine(
        Offset(0, size.height * fraction),
        Offset(size.width, size.height * fraction),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropFramePainter oldDelegate) {
    return round != oldDelegate.round || borderColor != oldDelegate.borderColor;
  }
}

String _messageFor(Object error) {
  if (error is ApiFailure) return error.userMessage;
  return '图片处理失败，请重试或更换图片。';
}

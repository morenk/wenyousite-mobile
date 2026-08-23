import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/image_crop_dialog.dart';

Future<UploadedEditorImage?> pickCropAndUploadEditorImage(
  BuildContext context,
  WidgetRef ref, {
  required Object uploadTaskId,
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
  String title = '裁剪图片',
}) async {
  final inputs = await pickAndCropEditorImages(
    context,
    ref,
    purpose: purpose,
    title: title,
  );
  if (!context.mounted || inputs == null || inputs.isEmpty) return null;
  return ref
      .read(mediaUploadTaskControllerProvider(uploadTaskId).notifier)
      .uploadInput(inputs.single);
}

Future<List<MediaUploadInput>?> pickAndCropEditorImages(
  BuildContext context,
  WidgetRef ref, {
  int maximumSelection = 1,
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
  String title = '裁剪图片',
}) async {
  assert(maximumSelection > 0);
  final picker = ref.read(editorImagePickerPortProvider);
  while (context.mounted) {
    try {
      final List<MediaUploadInput> inputs;
      if (maximumSelection > 1 && picker is MultiEditorImagePicker) {
        inputs = await (picker as MultiEditorImagePicker).pickManyFromGallery(
          limit: maximumSelection,
        );
      } else {
        final input = await picker.pickFromGallery();
        inputs = input == null ? const [] : [input];
      }
      if (!context.mounted || inputs.isEmpty) return null;
      final outputs = await showEditorImageCropDialog(
        context,
        inputs: inputs.take(maximumSelection).toList(growable: false),
        processor: ref.read(imageCropProcessorPortProvider),
        title: title,
      );
      return outputs
          ?.map((output) => output.withPurpose(purpose))
          .toList(growable: false);
    } on Object catch (error) {
      if (!context.mounted) return null;
      final retry = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('选择图片失败'),
          content: Text(imageCropFailureMessage(error)),
          actions: [
            TextButton(
              key: const Key('image-picker-failure-close'),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('关闭'),
            ),
            FilledButton(
              key: const Key('image-picker-failure-retry'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('重新选择'),
            ),
          ],
        ),
      );
      if (retry != true) return null;
    }
  }
  return null;
}

Future<List<MediaUploadInput>?> showEditorImageCropDialog(
  BuildContext context, {
  required List<MediaUploadInput> inputs,
  required ImageCropProcessor processor,
  String title = '裁剪图片',
}) {
  assert(inputs.isNotEmpty);
  return showDialog<List<MediaUploadInput>>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => _EditorImageCropDialog(
      inputs: inputs,
      processor: processor,
      title: title,
    ),
  );
}

class _EditorImageCropDialog extends StatefulWidget {
  const _EditorImageCropDialog({
    required this.inputs,
    required this.processor,
    required this.title,
  });

  final List<MediaUploadInput> inputs;
  final ImageCropProcessor processor;
  final String title;

  @override
  State<_EditorImageCropDialog> createState() => _EditorImageCropDialogState();
}

class _EditorImageCropDialogState extends State<_EditorImageCropDialog> {
  List<CropImageSource>? _sources;
  List<CropViewportController>? _controllers;
  var _selectedIndex = 0;
  var _preparing = true;
  var _processing = false;
  var _processedCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    if (_processing) return;
    setState(() {
      _preparing = true;
      _error = null;
    });
    try {
      final sources = <CropImageSource>[];
      for (final input in widget.inputs) {
        sources.add(await widget.processor.prepare(input));
      }
      if (!mounted) return;
      final controllers = [
        for (final source in sources)
          CropViewportController(
            sourceAspectRatio: source.width / source.height,
            targetAspectRatio: source.width / source.height,
          ),
      ];
      for (final controller
          in _controllers ?? const <CropViewportController>[]) {
        controller.dispose();
      }
      setState(() {
        _sources = List.unmodifiable(sources);
        _controllers = List.unmodifiable(controllers);
        _selectedIndex = 0;
        _preparing = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _preparing = false;
        _error = imageCropFailureMessage(error);
      });
    }
  }

  Future<void> _save() async {
    final sources = _sources;
    final controllers = _controllers;
    if (sources == null || controllers == null || _processing) return;
    setState(() {
      _processing = true;
      _processedCount = 0;
      _error = null;
    });
    try {
      final outputs = <MediaUploadInput>[];
      for (var index = 0; index < sources.length; index++) {
        final source = sources[index];
        outputs.add(
          source.canCrop
              ? await widget.processor.cropImage(
                  source,
                  controllers[index].crop,
                )
              : source.original,
        );
        if (mounted) setState(() => _processedCount = index + 1);
      }
      if (!mounted) return;
      Navigator.pop(context, List<MediaUploadInput>.unmodifiable(outputs));
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = imageCropFailureMessage(error);
      });
    }
  }

  void _selectRatio(_CropRatio ratio) {
    final controllers = _controllers;
    if (controllers == null || _processing) return;
    setState(() {
      controllers[_selectedIndex].setTargetAspectRatio(ratio.value);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers ?? const <CropViewportController>[]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = _sources;
    final controllers = _controllers;
    final ready = sources != null && controllers != null;
    final count = widget.inputs.length;
    final containsGif = sources?.any((source) => !source.canCrop) ?? false;
    final progress = _processing && count > 1
        ? '正在生成 $_processedCount/$count 张图片…'
        : containsGif
        ? 'GIF 动图会保留原图；静态图片仍可逐张裁剪。'
        : '原图保持比例显示；拖动取景框选择区域，双指或使用滑杆调整范围。';
    return ImageCropDialogFrame(
      key: const Key('editor-image-crop-dialog'),
      title: widget.title,
      description: progress,
      processing: _processing,
      error: _error,
      onCancel: () => Navigator.pop(context),
      onSave: ready ? _save : null,
      child: !ready
          ? ImageCropPreparing(
              preparing: _preparing,
              canRetry: !_preparing && _error != null,
              onRetry: _prepare,
            )
          : _buildEditor(sources, controllers),
    );
  }

  Widget _buildEditor(
    List<CropImageSource> sources,
    List<CropViewportController> controllers,
  ) {
    final source = sources[_selectedIndex];
    final controller = controllers[_selectedIndex];
    final ratios = _ratiosFor(source);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (source.canCrop) ...[
          ImageCropEditor(
            key: ValueKey(
              'editor-image-crop-$_selectedIndex-${controller.targetAspectRatio}',
            ),
            source: source,
            controller: controller,
          ),
          SizedBox(height: context.wenyouTokens.space8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final ratio in ratios) ...[
                  ChoiceChip(
                    key: ValueKey(
                      'image-crop-ratio-$_selectedIndex-${ratio.label}',
                    ),
                    label: Text(ratio.label),
                    selected:
                        (controller.targetAspectRatio - ratio.value).abs() <
                        .001,
                    onSelected: _processing ? null : (_) => _selectRatio(ratio),
                  ),
                  if (ratio != ratios.last)
                    SizedBox(width: context.wenyouTokens.space8),
                ],
              ],
            ),
          ),
        ] else
          AspectRatio(
            key: ValueKey('editor-image-gif-preview-$_selectedIndex'),
            aspectRatio: source.width / source.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.wenyouTokens.softPanel,
                borderRadius: BorderRadius.circular(
                  context.wenyouTokens.radius12,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  context.wenyouTokens.radius12,
                ),
                child: Image.memory(source.previewBytes, fit: BoxFit.contain),
              ),
            ),
          ),
        if (sources.length > 1) ...[
          SizedBox(height: context.wenyouTokens.space12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '图片 ${_selectedIndex + 1}/${sources.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(height: context.wenyouTokens.space8),
          _CropThumbnailTabs(
            sources: sources,
            selectedIndex: _selectedIndex,
            enabled: !_processing,
            onSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ],
    );
  }

  List<_CropRatio> _ratiosFor(CropImageSource source) {
    final portrait = source.height > source.width;
    final values = <_CropRatio>[
      _CropRatio('原比例', source.width / source.height),
      const _CropRatio('1:1', 1),
      _CropRatio(portrait ? '3:4' : '4:3', portrait ? 3 / 4 : 4 / 3),
      _CropRatio(portrait ? '9:16' : '16:9', portrait ? 9 / 16 : 16 / 9),
    ];
    final unique = <_CropRatio>[];
    for (final ratio in values) {
      if (unique.every((item) => (item.value - ratio.value).abs() >= .001)) {
        unique.add(ratio);
      }
    }
    return unique;
  }
}

class _CropThumbnailTabs extends StatelessWidget {
  const _CropThumbnailTabs({
    required this.sources,
    required this.selectedIndex,
    required this.enabled,
    required this.onSelected,
  });

  final List<CropImageSource> sources;
  final int selectedIndex;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox(
      key: const Key('image-crop-thumbnail-tabs'),
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sources.length,
        separatorBuilder: (_, _) => SizedBox(width: tokens.space8),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return Semantics(
            button: true,
            selected: selected,
            label: '第 ${index + 1} 张图片',
            child: InkWell(
              key: ValueKey('image-crop-thumbnail-$index'),
              onTap: enabled ? () => onSelected(index) : null,
              borderRadius: BorderRadius.circular(tokens.radius12),
              child: Container(
                width: 64,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tokens.radius12),
                  border: Border.all(
                    color: selected ? tokens.brandForeground : tokens.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radius12),
                  child: Image.memory(
                    sources[index].previewBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CropRatio {
  const _CropRatio(this.label, this.value);

  final String label;
  final double value;
}
